part of '../main.dart';

class ShellbyAiCoach {
  const ShellbyAiCoach();

  bool get usesGemini => _aiProvider.toLowerCase() == 'gemini';
  bool get usesOllama => _aiProvider.toLowerCase() == 'ollama';
  bool get isConfigured => usesOllama || _geminiApiKey.isNotEmpty;

  Future<MotivationCoachResult> send({
    required String concern,
    required List<ChatMessage> messages,
    required int userAnswerCount,
    required bool shouldSummarize,
    required String? requiredFollowUp,
  }) async {
    if (!isConfigured) {
      throw const AiSetupException();
    }

    final parsed = await _sendJson(
      instructions: _motivationCoachInstructions,
      input: _motivationCoachInput(
        concern,
        messages,
        userAnswerCount,
        shouldSummarize,
        requiredFollowUp,
      ),
      maxOutputTokens: shouldSummarize ? 420 : 280,
    );
    var reply = (parsed['reply'] as String?)?.trim() ??
        'That makes sense. Tell me a little more about why this matters.';
    var conclusion = (parsed['conclusion'] as String?)?.trim() ?? '';
    if (shouldSummarize) {
      reply = _removeTrailingQuestion(reply);
      conclusion = _removeTrailingQuestion(conclusion);
    } else if (requiredFollowUp != null && requiredFollowUp.isNotEmpty) {
      reply = _withRequiredFollowUp(reply, requiredFollowUp);
    }
    return MotivationCoachResult(
      reply: reply,
      conclusion:
          shouldSummarize ? (conclusion.isEmpty ? reply : conclusion) : '',
      isComplete: shouldSummarize,
    );
  }

  Future<GoalCoachResult> recommendGoal({
    required AppState state,
    required List<ChatMessage> messages,
  }) async {
    if (!isConfigured) {
      throw const AiSetupException();
    }

    final parsed = await _sendJson(
      instructions: _goalCoachInstructions,
      input: _goalCoachInput(state, messages),
      maxOutputTokens: 650,
    );
    final title = (parsed['title'] as String?)?.trim();
    final description = (parsed['description'] as String?)?.trim();
    final target = parsed['monthly_target'];
    return GoalCoachResult(
      reply: (parsed['reply'] as String?)?.trim() ??
          'I drafted a first goal from your focus and reason.',
      title: title == null || title.isEmpty
          ? _fallbackGoalTitle(state.primaryConcern)
          : title,
      description: description == null || description.isEmpty
          ? _fallbackGoalDescription(state)
          : description,
      monthlyTarget:
          target is num ? target.toDouble() : state.requiredMonthlyContribution,
    );
  }

  Future<Map<String, dynamic>> _sendJson({
    required String instructions,
    required String input,
    required int maxOutputTokens,
  }) async {
    if (usesOllama) {
      return _sendOllamaJson(
        instructions: instructions,
        input: input,
        maxOutputTokens: maxOutputTokens,
      );
    }
    if (usesGemini) {
      return _sendGeminiJson(
        instructions: instructions,
        input: input,
        maxOutputTokens: maxOutputTokens,
      );
    }
    throw UnsupportedError('Unknown AI_PROVIDER: $_aiProvider');
  }

  Future<Map<String, dynamic>> _sendOllamaJson({
    required String instructions,
    required String input,
    required int maxOutputTokens,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse('$_ollamaUrl/api/chat'));
      request.headers.contentType = ContentType.json;
      request.write(
        jsonEncode({
          'model': _ollamaModel,
          'stream': false,
          'think': false,
          'format': 'json',
          'messages': [
            {'role': 'system', 'content': instructions},
            {'role': 'user', 'content': input},
          ],
          'options': {'num_predict': maxOutputTokens, 'temperature': 0.4},
        }),
      );

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Ollama request failed: ${response.statusCode} $body');
      }

      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final promptTokens = decoded['prompt_eval_count'] as int? ?? 0;
      final completionTokens = decoded['eval_count'] as int? ?? 0;
      debugPrint(
        'Ollama tokens: prompt=$promptTokens, completion=$completionTokens, total=${promptTokens + completionTokens}',
      );
      final message = decoded['message'];
      final text =
          message is Map<String, dynamic> && message['content'] is String
              ? (message['content'] as String).trim()
              : '';
      final jsonText = _extractJsonObject(text);
      return jsonDecode(jsonText) as Map<String, dynamic>;
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> _sendGeminiJson({
    required String instructions,
    required String input,
    required int maxOutputTokens,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:generateContent?key=$_geminiApiKey',
        ),
      );
      request.headers.contentType = ContentType.json;
      request.write(
        jsonEncode({
          'systemInstruction': {
            'parts': [
              {'text': instructions},
            ],
          },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': input},
              ],
            },
          ],
          'generationConfig': {
            'maxOutputTokens': maxOutputTokens,
            'responseMimeType': 'application/json',
          },
        }),
      );

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Gemini request failed: ${response.statusCode} $body');
      }

      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final text = _extractGeminiText(decoded).trim();
      final jsonText = _extractJsonObject(text);
      return jsonDecode(jsonText) as Map<String, dynamic>;
    } finally {
      client.close(force: true);
    }
  }

  String _motivationCoachInput(
    String concern,
    List<ChatMessage> messages,
    int userAnswerCount,
    bool shouldSummarize,
    String? requiredFollowUp,
  ) {
    final transcript = messages
        .map(
          (message) =>
              '${message.fromUser ? 'User' : 'Shellby'}: ${message.text}',
        )
        .join('\n');
    final alreadyAsked = messages
        .where((message) => !message.fromUser && message.text.contains('?'))
        .map((message) => message.text)
        .join('\n');
    final mode = shouldSummarize
        ? 'Wrap up now with a goal direction. Do not ask another question.'
        : 'Continue briefly. Ask the next goal-shaping question.';
    final nextQuestionGuidance = switch (userAnswerCount) {
      1 =>
        'Next ask what amount, buffer, or measurable result would feel good enough. If they do not know, share one common benchmark once.',
      2 =>
        'Next ask about timeframe or monthly effort. Do not ask again whether the amount feels enough.',
      _ =>
        'Use the answers to derive a suitable first goal direction. No more questions.',
    };
    return '''
Selected financial concern: $concern
User answers so far: $userAnswerCount
Current step: $mode
Question plan: first understand why it matters, then clarify what "enough" means, then clarify timeframe or realistic effort.
Next move: $nextQuestionGuidance
Required follow-up question if continuing: ${requiredFollowUp ?? 'none'}
Questions already asked:
$alreadyAsked

Conversation so far:
$transcript

Respond as Shellby in a warm, practical, and specific way.
First acknowledge what the user just shared. Validate the tradeoff without exaggerating.
Be honest and grounded. Do not over-praise, diagnose, or sound like a script.
Use at least one concrete detail from the user's latest answer so it feels like a real reply.
If the user says they do not know, normalize that briefly. Do not add a separate benchmark unless it appears inside the required follow-up question.
Use general benchmarks only, not regulated financial advice.
Do not repeat a benchmark, phrase, or question already used in the conversation.
Do not restate the whole concern in every reply.
If continuing, write 1-2 short acknowledgement sentences, then end with the required follow-up question exactly as written. Do not add any other question.
If wrapping up, write the reply as a concise, caring summary of what you understand and a suitable first goal direction. Include the goal type, why it matters, and a realistic target or next step if the user gave enough detail.
For the conclusion field, write the same goal direction in one concise paragraph that can be shown under "What you told Shellby".
When wrapping up, reply and conclusion must not contain a question mark.
Do not say "the plan is complete" or describe the chat mechanics.
Return only JSON with keys reply, conclusion, is_complete.
''';
  }

  String _removeTrailingQuestion(String text) {
    final questionIndex = text.indexOf('?');
    if (questionIndex == -1) return text;
    final previousSentence = text.lastIndexOf('.', questionIndex);
    final cutIndex =
        previousSentence == -1 ? questionIndex : previousSentence + 1;
    return text.substring(0, cutIndex).trim();
  }

  String _withRequiredFollowUp(String reply, String requiredFollowUp) {
    final cleaned = _removeTrailingQuestion(reply);
    if (cleaned.isEmpty) return requiredFollowUp;
    if (cleaned.endsWith(requiredFollowUp)) return cleaned;
    return '$cleaned $requiredFollowUp';
  }

  String _goalCoachInput(AppState state, List<ChatMessage> messages) {
    final transcript = messages
        .map(
          (message) =>
              '${message.fromUser ? 'User' : 'Shellby'}: ${message.text}',
        )
        .join('\n');
    return '''
User preparation data:
- Focus: ${state.primaryConcern}
- Reason: ${state.motivation.isEmpty ? 'No final reason yet' : state.motivation}
- Life stage: ${state.age}
- Occupation: ${state.occupation}
- Industry: ${state.industry}
- Employment: ${state.employmentStatus}
- Income type: ${state.incomeType}
- Monthly net income: PHP ${state.income.toStringAsFixed(0)}
- Fixed expenses: PHP ${state.expenses.toStringAsFixed(0)}
- Variable expenses: PHP ${state.variableExpenses.toStringAsFixed(0)}
- Current monthly savings: PHP ${state.savings.toStringAsFixed(0)}
- Emergency fund months: ${state.emergencyMonths.toStringAsFixed(1)}
- Debt payments: PHP ${state.debtPayments.toStringAsFixed(0)}
- Confidence: ${state.confidence.round()}/10
- Financial pressure: ${state.anxiety.round()}/10
- Peer pressure: ${state.peerPressure.round()}/10

Goal chat:
$transcript

Recommend or revise one first goal. The goal must clearly come from the user's focus and reason.
If the user asks to modify it, apply the requested modification.
Return only JSON with keys reply, title, description, monthly_target.
''';
  }

  String _fallbackGoalTitle(String concern) {
    return switch (concern) {
      'Managing debt' => 'Debt Reset',
      'Starting investments' => 'Investment Starter',
      'Controlling spending' => 'Spending Clarity Sprint',
      'Planning a big purchase' => 'Big Purchase Fund',
      'Reducing financial pressure' => 'Money Check-in Routine',
      'Comparing with peers' => 'Peer Benchmark Baseline',
      _ => 'Emergency Shield',
    };
  }

  String _fallbackGoalDescription(AppState state) {
    return 'Set aside ${money(state.requiredMonthlyContribution)} monthly toward ${state.primaryConcern.toLowerCase()} while keeping cash flow realistic.';
  }

  String _extractGeminiText(Map<String, dynamic> decoded) {
    final buffer = StringBuffer();
    final candidates = decoded['candidates'];
    if (candidates is List) {
      for (final candidate in candidates) {
        if (candidate is! Map<String, dynamic>) continue;
        final content = candidate['content'];
        if (content is! Map<String, dynamic>) continue;
        final parts = content['parts'];
        if (parts is! List) continue;
        for (final part in parts) {
          if (part is Map<String, dynamic> && part['text'] is String) {
            buffer.write(part['text']);
          }
        }
      }
    }
    return buffer.toString();
  }

  String _extractJsonObject(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw FormatException('No JSON object found in model response: $text');
    }
    return text.substring(start, end + 1);
  }
}

class AiSetupException implements Exception {
  const AiSetupException();
}

const _motivationCoachInstructions = '''
You are Shellby, a warm AI onboarding coach for a Philippine personal finance app.
Your job is the Preparation Stage goal-discovery chat.

Use the user's selected concern to ask 3-4 relevant, non-judgmental questions that build toward a specific first goal.
Follow these rules:
- Ask only one question at a time.
- Keep continuing replies under 70 words.
- Do not give regulated financial advice.
- Do not recommend specific securities, banks, or products.
- Use PHP context when money is mentioned.
- Each reply should first respond to the user's answer, then ask the next question.
- Questions should build: why it matters, what amount/result is enough, timeframe or realistic monthly effort.
- If the user does not know, say that is normal and offer a common benchmark or example.
- At the end, conclude with a concise reflection plus a suitable first goal direction.

Return only valid JSON:
{
  "reply": "message shown to the user",
  "conclusion": "a concise goal-direction summary, or empty string if more questions are needed",
  "is_complete": true or false
}
''';

const _goalCoachInstructions = '''
You are Shellby, a warm AI goal-setting coach for a Philippine personal finance app.
Your job is the Preparation Stage "Specify" step.

Use the user's focus, motivation, and financial baseline to recommend one first goal.
Follow these rules:
- The recommended goal must be specific, measurable, realistic, and time-bound.
- Tie the goal to the user's stated reason.
- Keep the description under 35 words.
- Use PHP for money.
- Do not give regulated financial advice.
- Do not recommend specific financial products, banks, brokers, or securities.
- If the user asks a question or requests a modification, answer briefly and revise the goal.
- Prefer safer foundational goals when financial pressure is high or surplus is low.

Return only valid JSON:
{
  "reply": "short coach message explaining the recommendation or revision",
  "title": "short goal title",
  "description": "specific goal sentence with target and timeframe",
  "monthly_target": number
}
''';
