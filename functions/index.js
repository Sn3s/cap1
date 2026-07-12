const {defineSecret} = require("firebase-functions/params");
const {onRequest} = require("firebase-functions/v2/https");

const geminiApiKey = defineSecret("GEMINI_API_KEY");
const defaultModel = "gemini-flash-latest";

exports.geminiGenerateContent = onRequest(
  {
    region: "us-central1",
    secrets: [geminiApiKey],
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async (request, response) => {
    if (request.method === "OPTIONS") {
      response.set("Access-Control-Allow-Origin", "*");
      response.set("Access-Control-Allow-Headers", "content-type");
      response.set("Access-Control-Allow-Methods", "POST, OPTIONS");
      response.status(204).send("");
      return;
    }

    if (request.method !== "POST") {
      response.status(405).json({error: "Method not allowed"});
      return;
    }

    const apiKey = geminiApiKey.value();
    if (!apiKey) {
      response.status(503).json({error: "Gemini API key is not configured"});
      return;
    }

    const modelHeader = request.get("x-shellby-gemini-model") || defaultModel;
    const model = modelHeader.replace(/^models\//, "");
    if (!/^[a-zA-Z0-9_.:-]+$/.test(model)) {
      response.status(400).json({error: "Invalid Gemini model"});
      return;
    }

    try {
      const geminiResponse = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
        {
          method: "POST",
          headers: {
            "content-type": "application/json",
            "x-goog-api-key": apiKey,
          },
          body: JSON.stringify(request.body),
        },
      );
      const text = await geminiResponse.text();
      response.set("Access-Control-Allow-Origin", "*");
      response.status(geminiResponse.status).type("json").send(text);
    } catch (error) {
      response.status(502).json({
        error: "Gemini upstream request failed",
        detail: error instanceof Error ? error.message : String(error),
      });
    }
  },
);
