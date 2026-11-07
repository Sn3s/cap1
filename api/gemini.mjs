const maxRequestBytes = 256 * 1024;
const maxInputCharacters = 80000;
const maxSystemCharacters = 16000;
const maxOutputTokens = 1000;
const defaultModel = 'gemini-3.1-flash-lite';

function json(body, status = 200) {
  return Response.json(body, {
    status,
    headers: { 'Cache-Control': 'no-store' },
  });
}

function isSameOriginRequest(request) {
  const origin = request.headers.get('origin');
  const host =
    request.headers.get('x-forwarded-host') ?? request.headers.get('host');
  if (!origin || !host) return false;
  try {
    return new URL(origin).host === host;
  } catch {
    return false;
  }
}

function numberInRange(value, fallback, minimum, maximum) {
  const number = Number(value);
  return Number.isFinite(number)
    ? Math.min(maximum, Math.max(minimum, number))
    : fallback;
}

function safeGeminiPayload(body) {
  const systemText = body?.systemInstruction?.parts?.[0]?.text;
  const content = body?.contents?.[0];
  const userText = content?.parts?.[0]?.text;
  if (
    typeof systemText !== 'string' ||
    systemText.length === 0 ||
    systemText.length > maxSystemCharacters ||
    content?.role !== 'user' ||
    typeof userText !== 'string' ||
    userText.length === 0 ||
    userText.length > maxInputCharacters
  ) {
    return null;
  }

  const config = body?.generationConfig ?? {};
  const generationConfig = {
    maxOutputTokens: Math.round(
      numberInRange(config.maxOutputTokens, 520, 1, maxOutputTokens),
    ),
    temperature: numberInRange(config.temperature, 0.4, 0, 1),
    topP: numberInRange(config.topP, 0.9, 0, 1),
  };
  if (config.responseMimeType === 'application/json') {
    generationConfig.responseMimeType = 'application/json';
  }

  // Rebuild the request instead of forwarding arbitrary Gemini fields. This
  // keeps Shellby's proxy text-only, caps usage, and prevents callers from
  // selecting another model or enabling provider-side tools.
  return {
    systemInstruction: { parts: [{ text: systemText }] },
    contents: [{ role: 'user', parts: [{ text: userText }] }],
    generationConfig,
  };
}

export async function OPTIONS() {
  return new Response(null, { status: 204 });
}

export async function POST(request) {
  if (!isSameOriginRequest(request)) {
    return json({ error: 'Same-origin requests only.' }, 403);
  }

  const contentLength = Number(request.headers.get('content-length') ?? 0);
  if (contentLength > maxRequestBytes) {
    return json({ error: 'Request is too large.' }, 413);
  }

  let body;
  try {
    const rawBody = await request.text();
    if (Buffer.byteLength(rawBody, 'utf8') > maxRequestBytes) {
      return json({ error: 'Request is too large.' }, 413);
    }
    body = JSON.parse(rawBody);
  } catch {
    return json({ error: 'Request must contain JSON.' }, 400);
  }

  const payload = safeGeminiPayload(body);
  if (payload == null) {
    return json({ error: 'Unsupported Gemini request.' }, 400);
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    console.error('Gemini request rejected: GEMINI_API_KEY is missing.');
    return json({ error: 'AI service is not configured.' }, 503);
  }

  const model = process.env.GEMINI_MODEL || defaultModel;
  try {
    const upstream = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent`,
      {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: JSON.stringify(payload),
      },
    );
    const text = await upstream.text();
    if (!upstream.ok) {
      console.error(`Gemini upstream failed with status ${upstream.status}.`);
    }
    return new Response(text, {
      status: upstream.status,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'cache-control': 'no-store',
      },
    });
  } catch (error) {
    console.error('Gemini upstream request failed.', error);
    return json({ error: 'AI service is temporarily unavailable.' }, 502);
  }
}
