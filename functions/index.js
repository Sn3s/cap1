const {defineSecret} = require("firebase-functions/params");
const {onRequest, onCall, HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

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

// ─── Cooperative decision support ──────────────────────────────────────────
// Financial decisions deliberately bypass the general posts collection. These
// callable functions are the only writers: clients cannot add recipients,
// forge votes, or alter aggregate results directly.

const requireUser = (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in first.");
  return request.auth.uid;
};

const text = (value, field, max) => {
  if (typeof value !== "string" || !value.trim() || value.trim().length > max) {
    throw new HttpsError("invalid-argument", `Provide a ${field} up to ${max} characters.`);
  }
  return value.trim();
};

const pairId = (a, b) => a <= b ? `${a}_${b}` : `${b}_${a}`;
const areFriends = async (a, b) =>
  (await db.doc(`friendships/${pairId(a, b)}`).get()).exists;

async function requireConsent(uid, field) {
  const profile = await db.doc(`profiles/${uid}`).get();
  if (profile.data()?.[field] !== true) {
    throw new HttpsError("failed-precondition", "This feature requires your saved consent.");
  }
  return profile.data() || {};
}

async function publicAuthor(uid) {
  const user = await admin.auth().getUser(uid);
  return {
    uid,
    displayName: user.displayName || "Shelby member",
    ...(user.photoURL ? {photoUrl: user.photoURL} : {}),
  };
}

async function consumeDecisionQuota(uid) {
  const ref = db.doc(`communityRateLimits/${uid}`);
  const day = new Date().toISOString().slice(0, 10);
  await db.runTransaction(async (transaction) => {
    const current = await transaction.get(ref);
    const data = current.data() || {};
    const count = data.day === day ? Number(data.decisionCount || 0) : 0;
    if (count >= 5) {
      throw new HttpsError("resource-exhausted", "You can create up to five decision requests per day.");
    }
    transaction.set(ref, {day, decisionCount: count + 1, updatedAt: admin.firestore.FieldValue.serverTimestamp()});
  });
}

exports.createDecisionRequest = onCall({region: "us-central1"}, async (request) => {
  const uid = requireUser(request);
  await requireConsent(uid, "consentCommunity");
  await requireConsent(uid, "consentTrustedCircle");
  await consumeDecisionQuota(uid);
  const message = text(request.data?.message, "question", 250);
  const options = Array.from(new Set((request.data?.options || [])
      .filter((option) => typeof option === "string")
      .map((option) => option.trim())
      .filter(Boolean)));
  if (options.length < 2 || options.length > 4 || options.some((option) => option.length > 60)) {
    throw new HttpsError("invalid-argument", "Choose two to four short options.");
  }
  const recipients = Array.from(new Set((request.data?.recipients || [])
      .filter((id) => typeof id === "string" && id && id !== uid)));
  if (!recipients.length || recipients.length > 10) {
    throw new HttpsError("invalid-argument", "Choose one to ten trusted-circle members.");
  }
  const checks = await Promise.all(recipients.map((recipient) => areFriends(uid, recipient)));
  if (checks.some((allowed) => !allowed)) {
    throw new HttpsError("permission-denied", "Every recipient must be a current friend.");
  }
  const days = Number(request.data?.closeAfterDays || 7);
  if (!Number.isInteger(days) || days < 1 || days > 30) {
    throw new HttpsError("invalid-argument", "Choose a closing date from one to 30 days.");
  }
  const context = request.data?.context;
  const safeContext = typeof context === "string" && context.trim()
    ? text(context, "shared context", 250)
    : null;
  const ref = db.collection("decisionRequests").doc();
  const author = await publicAuthor(uid);
  const closeAt = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + days * 24 * 60 * 60 * 1000));
  await ref.set({
    authorUid: uid,
    author,
    audience: [uid, ...recipients],
    message,
    options,
    ...(safeContext ? {context: safeContext} : {}),
    status: "open",
    closeAt,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return {id: ref.id};
});

exports.respondToDecisionRequest = onCall({region: "us-central1"}, async (request) => {
  const uid = requireUser(request);
  await requireConsent(uid, "consentCommunity");
  const id = text(request.data?.decisionId, "decision id", 128);
  const ref = db.doc(`decisionRequests/${id}`);
  const decision = await ref.get();
  if (!decision.exists) throw new HttpsError("not-found", "This request is no longer available.");
  const data = decision.data();
  if (data.authorUid === uid || !data.audience?.includes(uid) ||
      !(await areFriends(uid, data.authorUid))) {
    throw new HttpsError("permission-denied", "You are not in this trusted circle.");
  }
  if (data.status !== "open" || data.closeAt.toDate() <= new Date()) {
    throw new HttpsError("failed-precondition", "This request is closed.");
  }
  const option = text(request.data?.option, "option", 60);
  if (!data.options.includes(option)) throw new HttpsError("invalid-argument", "Choose a listed option.");
  const comment = typeof request.data?.comment === "string" ? request.data.comment.trim() : "";
  if (comment.length > 250) throw new HttpsError("invalid-argument", "Comment is too long.");
  const allowAiReview = request.data?.allowAiReview === true;
  await ref.collection("responses").doc(uid).set({
    author: await publicAuthor(uid), option, comment, allowAiReview,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return {ok: true};
});

exports.closeDecisionRequest = onCall({region: "us-central1"}, async (request) => {
  const uid = requireUser(request);
  const id = text(request.data?.decisionId, "decision id", 128);
  const ref = db.doc(`decisionRequests/${id}`);
  const snapshot = await ref.get();
  if (!snapshot.exists || snapshot.data().authorUid !== uid) {
    throw new HttpsError("permission-denied", "Only the author can close this request.");
  }
  await ref.update({status: "closed", closedAt: admin.firestore.FieldValue.serverTimestamp()});
  return {ok: true};
});

exports.publishBenchmarkContribution = onCall({region: "us-central1"}, async (request) => {
  const uid = requireUser(request);
  const profile = await requireConsent(uid, "consentBenchmarking");
  const month = new Date().toISOString().slice(0, 7);
  const cohort = String(profile.employmentStatus || "all")
      .toLowerCase().replace(/[^a-z0-9]+/g, "-").slice(0, 40) || "all";
  const emergencyMonths = Number(profile.emergencyMonths || 0);
  const savings = Number(profile.savings || 0);
  const income = Number(profile.income || profile.monthlySalary || 0);
  const contribution = {
    uid, month, cohort,
    emergencyBand: emergencyMonths >= 3 ? "three_plus" : emergencyMonths >= 1 ? "one_to_three" : "under_one",
    savingBand: income > 0 && savings / income >= .2 ? "twenty_plus" : income > 0 && savings > 0 ? "some" : "none",
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  await db.doc(`benchmarkContributions/${uid}_${month}`).set(contribution);
  const all = await db.collection("benchmarkContributions")
      .where("month", "==", month).where("cohort", "==", cohort).get();
  const tally = (field) => all.docs.reduce((result, doc) => {
    const key = doc.data()[field]; result[key] = (result[key] || 0) + 1; return result;
  }, {});
  const aggregate = {month, cohort, eligibleCount: all.size, emergencyBands: tally("emergencyBand"), savingBands: tally("savingBand"), updatedAt: admin.firestore.FieldValue.serverTimestamp()};
  await db.doc(`benchmarkAggregates/${cohort}_${month}`).set(aggregate);
  return {eligible: all.size >= 20, cohort, month};
});

exports.reviewDecisionFeedback = onCall(
  {region: "us-central1", secrets: [geminiApiKey], timeoutSeconds: 60, memory: "256MiB"},
  async (request) => {
    const uid = requireUser(request);
    await requireConsent(uid, "consentAi");
    await requireConsent(uid, "consentCommunity");
    const id = text(request.data?.decisionId, "decision id", 128);
    const decision = await db.doc(`decisionRequests/${id}`).get();
    if (!decision.exists || decision.data().authorUid !== uid) {
      throw new HttpsError("permission-denied", "Only the author can review this request.");
    }
    const data = decision.data();
    const responses = await decision.ref.collection("responses").get();
    const votes = data.options.map((option) => ({option, count: responses.docs.filter((doc) => doc.data().option === option).length}));
    const permittedComments = responses.docs.map((doc) => doc.data())
        .filter((response) => response.allowAiReview && response.comment)
        .map((response) => response.comment);
    const prompt = `You are Shelby, a cautious financial reflection assistant. Summarize perspectives and trade-offs only; do not decide, command transactions, or give financial advice.\nQuestion: ${data.message}\nOptions: ${JSON.stringify(data.options)}\nUser-selected context: ${data.context || "None"}\nVote totals: ${JSON.stringify(votes)}\nComments explicitly permitted for AI review: ${JSON.stringify(permittedComments)}\nReturn concise sections: Perspectives, Trade-offs, Questions to consider, and a final sentence that the decision remains the user's.`;
    const apiKey = geminiApiKey.value();
    if (!apiKey) throw new HttpsError("failed-precondition", "AI review is not configured.");
    const result = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${defaultModel}:generateContent`, {
      method: "POST", headers: {"content-type": "application/json", "x-goog-api-key": apiKey},
      body: JSON.stringify({contents: [{parts: [{text: prompt}]}]}),
    });
    if (!result.ok) throw new HttpsError("unavailable", "Shelby review is unavailable right now.");
    const body = await result.json();
    return {summary: body.candidates?.[0]?.content?.parts?.map((part) => part.text || "").join("") || "No review was generated."};
  },
);
