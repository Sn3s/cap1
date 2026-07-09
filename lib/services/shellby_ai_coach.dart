part of '../main.dart';

class ShellbyAiCoach {
  const ShellbyAiCoach();

  bool get usesGemini => _aiProvider.toLowerCase() == 'gemini';
  bool get usesLocalModel => !usesGemini;
  bool get isConfigured => usesLocalModel || _geminiApiKey.isNotEmpty;

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

  Future<String> chat({
    required AppState state,
    required List<ChatMessage> messages,
    String? screenContext,
  }) async {
    if (!isConfigured) {
      throw const AiSetupException();
    }

    return _sendText(
      instructions: _shellbyChatInstructions,
      input: _shellbyChatInput(
        state,
        messages,
        screenContext: screenContext,
      ),
      maxOutputTokens: 520,
    );
  }

  Future<String> _sendText({
    required String instructions,
    required String input,
    required int maxOutputTokens,
  }) async {
    if (usesGemini) {
      return _sendGeminiText(
        instructions: instructions,
        input: input,
        maxOutputTokens: maxOutputTokens,
      );
    }
    final runtime = await _LocalLlamaRuntime.instance();
    return runtime.generateText(
      instructions: instructions,
      input: input,
      maxOutputTokens: maxOutputTokens,
    );
  }

  Future<Map<String, dynamic>> _sendJson({
    required String instructions,
    required String input,
    required int maxOutputTokens,
  }) async {
    if (usesGemini) {
      return _sendGeminiJson(
        instructions: instructions,
        input: input,
        maxOutputTokens: maxOutputTokens,
      );
    }
    final runtime = await _LocalLlamaRuntime.instance();
    final text = await runtime.generateJson(
      instructions: instructions,
      input: input,
      maxOutputTokens: maxOutputTokens,
    );
    final jsonText = _extractJsonObject(text);
    return jsonDecode(jsonText) as Map<String, dynamic>;
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

  Future<String> _sendGeminiText({
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
          },
        }),
      );

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Gemini request failed: ${response.statusCode} $body');
      }

      return _extractGeminiText(jsonDecode(body) as Map<String, dynamic>)
          .trim();
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

  String _shellbyChatInput(
    AppState state,
    List<ChatMessage> messages, {
    String? screenContext,
  }) {
    final transcript = messages
        .map(
          (message) =>
              '${message.fromUser ? 'User' : 'Shellby'}: ${message.text}',
        )
        .join('\n');
    final summary = state.fakeMayaLink?.summary;
    final transactions = state.allTransactions
        .take(10)
        .map(
          (transaction) =>
              '- ${transaction.age}: ${transaction.title} (${transaction.detail}) ${transaction.amountText}; account: ${transaction.account ?? 'Wallet'}; category: ${transaction.category ?? 'unlabeled'}; source: ${transaction.source ?? 'unlabeled'}',
        )
        .join('\n');
    final assets = state.assets
        .take(8)
        .map((item) => '- ${item.name}: ${money(item.value)}')
        .join('\n');
    final liabilities = state.liabilities
        .take(8)
        .map((item) => '- ${item.name}: ${money(item.value)}')
        .join('\n');
    final incomes = state.onboardingIncomeLedger.take(10).map((income) {
      final name = income['name'] ?? 'Income';
      final amount = (income['amount'] as num?)?.toDouble() ?? 0;
      final type = income['stable'] == true ? 'stable' : 'variable';
      final scheduled = income['scheduled'] == true;
      final payDay = (income['payDay'] as num?)?.toInt();
      final timing = scheduled
          ? 'scheduled${payDay == null ? '' : ' on day $payDay'}'
          : 'unscheduled';
      return '- $name: ${money(amount)} ($type, $timing)';
    }).join('\n');
    final expenses = state.onboardingExpenseLedger.take(10).map((expense) {
      final name = expense['name'] ?? expense['label'] ?? 'Expense';
      final amount = (expense['amount'] as num?)?.toDouble() ?? 0;
      final essential = expense['essential'] == true ? 'essential' : 'flex';
      return '- $name: ${money(amount)} ($essential)';
    }).join('\n');

    return '''
Shellby app context:
- User name: ${state.name.trim().isEmpty ? 'unknown' : state.name.trim()}
- Email: ${state.email.trim().isEmpty ? 'unknown' : state.email.trim()}
- Life stage: ${state.age}
- Occupation: ${state.occupation}
- Industry: ${state.industry}
- Employment: ${state.employmentStatus}
- Income rhythm: ${state.incomeRhythm}; income type: ${state.incomeType}
- Primary concern: ${state.primaryConcern}
- Motivation: ${state.motivation.isEmpty ? state.reflectedMotivation : state.motivation}
- Selected goal: ${state.selectedGoal}
- Goal description: ${state.selectedGoalDescription}
- Goal monthly target: ${money(state.selectedGoalMonthlyTarget)}
- Required monthly contribution: ${money(state.requiredMonthlyContribution)}
- Monthly income: ${money(state.income)}
- Monthly salary: ${money(state.monthlySalary)}
- Expenses: ${money(state.expenses)}
- Variable expenses: ${money(state.variableExpenses)}
- Current monthly savings: ${money(state.savings)}
- Debt payments: ${money(state.debtPayments)}
- Investments: ${money(state.investments)}
- Net worth: ${money(state.netWorth)}
- Confidence: ${state.confidence.round()}/10
- Financial pressure: ${state.anxiety.round()}/10
- Avoidance: ${state.avoidance.round()}/10
- Peer pressure: ${state.peerPressure.round()}/10
- Chat summaries: surface="${state.chatSurfaceSummary}", goal="${state.chatGoalFocusSummary}", timeframe="${state.chatTimeframeSummary}", difficulty="${state.chatDifficultySummary}", situations="${state.chatSituationsSummary}", challenges="${state.chatChallengesSummary}"
- FakeMaya linked: ${state.hasFakeMayaLink ? 'yes' : 'no'}
- Wallet: ${money(summary?.wallet ?? 0)}
- Cash on hand: ${money(state.cashOnHandBalance)}
- Savings: ${money(summary?.savings ?? 0)}
- Time deposit: ${money(summary?.timeDeposit ?? 0)}
- Goal balance: ${money(summary?.goalBalance ?? 0)} of ${money(summary?.goalTarget ?? 0)}
- Credit used: ${money(summary?.creditUsed ?? 0)} of ${money(summary?.creditLimit ?? 0)}
- Two-jar needs target: ${money(state.needsTarget)}
- Needs balance: ${money(state.needsBalance)}
- Buffer balance: ${money(state.bufferBalance)}
- Safety shield balance: ${money(state.safetyShieldBalance)}
- Safety shield target: ${money(state.safetyShieldTarget)}

Current Insights screen:
${screenContext?.trim().isNotEmpty == true ? screenContext : 'No specific Insights screen supplied.'}

Assets:
${assets.isEmpty ? 'No manually tracked assets.' : assets}

Liabilities:
${liabilities.isEmpty ? 'No manually tracked liabilities.' : liabilities}

Known income:
${incomes.isEmpty ? 'No detailed income entered.' : incomes}

Known expenses:
${expenses.isEmpty ? 'No detailed expenses entered.' : expenses}

Recent linked transactions:
${transactions.isEmpty ? 'No transactions available.' : transactions}

Conversation:
$transcript

For an Insights analysis, format the first response with short headings:
Summary, Notable patterns, Outliers or changes, and Questions to consider.
Use concise bullets, include relevant values, distinguish missing data from
zero, avoid claiming causation, and use neutral non-judgmental language.
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
  const AiSetupException([this.message = 'AI model is not configured.']);

  final String message;

  @override
  String toString() => 'AiSetupException: $message';
}

class _LocalLlamaRuntime {
  _LocalLlamaRuntime._(this._commandPort);

  static _LocalLlamaRuntime? _instance;
  static Future<_LocalLlamaRuntime>? _creatingInstance;
  final SendPort _commandPort;

  static Future<_LocalLlamaRuntime> instance() async {
    final existing = _instance;
    if (existing != null) {
      return existing;
    }

    final pending = _creatingInstance;
    if (pending != null) {
      return pending;
    }

    final completer = Completer<_LocalLlamaRuntime>();
    _creatingInstance = completer.future;
    try {
      final runtime = await _create();
      _instance = runtime;
      completer.complete(runtime);
      return runtime;
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
      rethrow;
    } finally {
      _creatingInstance = null;
    }
  }

  static Future<_LocalLlamaRuntime> _create() async {
    final modelPath = await _resolveModelPath();
    final readyPort = ReceivePort();
    final isolate = await Isolate.spawn(
      _localLlamaWorkerMain,
      <Object?>[
        readyPort.sendPort,
        modelPath,
        _localModelContextSize,
        Platform.isIOS || Platform.isMacOS ? 'metal' : 'auto',
      ],
      debugName: 'shellby-llamadart-worker',
    );

    final initialMessage = await readyPort.first;
    readyPort.close();
    if (initialMessage is! SendPort) {
      isolate.kill(priority: Isolate.immediate);
      throw StateError(
        initialMessage is Map<String, dynamic> &&
                initialMessage['error'] is String
            ? initialMessage['error'] as String
            : 'Failed to initialize the local model runtime.',
      );
    }

    return _LocalLlamaRuntime._(initialMessage);
  }

  static Future<String> _resolveModelPath() async {
    if (_localModelAsset.trim().isEmpty) {
      throw const AiSetupException(
        'Set LOCAL_MODEL_ASSET to a bundled GGUF file.',
      );
    }

    final supportDirectory = await getApplicationSupportDirectory();
    final modelDirectory = Directory('${supportDirectory.path}/shellby-models');
    if (!await modelDirectory.exists()) {
      await modelDirectory.create(recursive: true);
    }

    final modelFile = File(
      '${modelDirectory.path}/${_assetFileName(_localModelAsset)}',
    );
    if (await modelFile.exists() && await modelFile.length() > 0) {
      return modelFile.path;
    }

    final assetBytes = await rootBundle.load(_localModelAsset);
    await modelFile.writeAsBytes(
      assetBytes.buffer.asUint8List(
        assetBytes.offsetInBytes,
        assetBytes.lengthInBytes,
      ),
      flush: true,
    );
    return modelFile.path;
  }

  Future<String> generateJson({
    required String instructions,
    required String input,
    required int maxOutputTokens,
  }) async {
    return generateText(
      instructions: instructions,
      input: input,
      maxOutputTokens: maxOutputTokens,
    );
  }

  Future<String> generateText({
    required String instructions,
    required String input,
    required int maxOutputTokens,
  }) async {
    final responsePort = ReceivePort();
    _commandPort.send(
      <String, Object?>{
        'command': 'generate-text',
        'instructions': instructions,
        'input': input,
        'maxOutputTokens': maxOutputTokens,
        'replyTo': responsePort.sendPort,
      },
    );

    final response = await responsePort.first;
    responsePort.close();
    if (response is Map<String, dynamic>) {
      final error = response['error'];
      if (error is String && error.isNotEmpty) {
        throw StateError(error);
      }

      final text = response['text'];
      if (text is String) {
        return text;
      }
    }

    throw StateError('The local model runtime returned an unexpected result.');
  }

  static String _assetFileName(String assetPath) {
    final normalized = assetPath.replaceAll('\\', '/');
    final segments = normalized.split('/').where((part) => part.isNotEmpty);
    return segments.isEmpty ? assetPath : segments.last;
  }
}

Future<void> _localLlamaWorkerMain(List<Object?> arguments) async {
  final SendPort readyPort = arguments[0] as SendPort;
  final String modelPath = arguments[1] as String;
  final int contextSize = arguments[2] as int;
  final String backendName = arguments[3] as String;

  final commandPort = ReceivePort();
  final service = LlamaService();

  try {
    await service.init(
      modelPath,
      modelParams: ModelParams(
        contextSize: contextSize,
        gpuLayers: Platform.isIOS || Platform.isMacOS ? 99 : 0,
        preferredBackend:
            backendName == 'metal' ? GpuBackend.metal : GpuBackend.auto,
      ),
    );

    readyPort.send(commandPort.sendPort);

    await for (final message in commandPort) {
      if (message is! Map) continue;
      final replyTo = message['replyTo'];
      if (replyTo is! SendPort) continue;

      final command = message['command'] as String? ?? '';
      if (command == 'generate-json' || command == 'generate-text') {
        try {
          final text = await _generateTextInWorker(
            service: service,
            instructions: message['instructions'] as String? ?? '',
            input: message['input'] as String? ?? '',
            maxOutputTokens: message['maxOutputTokens'] as int? ?? 256,
          );
          replyTo.send(<String, Object?>{'text': text});
        } catch (error) {
          replyTo.send(<String, Object?>{'error': error.toString()});
        }
      } else if (command == 'dispose') {
        service.dispose();
        replyTo.send(<String, Object?>{'text': 'disposed'});
        commandPort.close();
        return;
      }
    }
  } catch (error) {
    readyPort.send(<String, Object?>{'error': error.toString()});
    commandPort.close();
  }
}

Future<String> _generateTextInWorker({
  required LlamaService service,
  required String instructions,
  required String input,
  required int maxOutputTokens,
}) async {
  final buffer = StringBuffer();
  final messages = [
    LlamaChatMessage(
      role: 'system',
      content: instructions,
    ),
    LlamaChatMessage(
      role: 'user',
      content: input,
    ),
  ];
  final prompt = await service.applyChatTemplate(messages);

  await for (final token in service.generate(
    prompt,
    params: GenerationParams(maxTokens: maxOutputTokens, temp: 0.4),
  )) {
    buffer.write(token);
  }

  final text = buffer.toString().trim();
  if (text.isEmpty) {
    throw StateError('The local model returned no content.');
  }
  return text;
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

const _shellbyChatInstructions = '''
You are Shellby, the in-app AI assistant for Shellby, a Philippine personal finance app.
Answer the user's questions about the app and the personal data shown in the provided context.

Rules:
- Be warm, concise, practical, and specific.
- Use PHP/peso amounts when discussing money.
- Use only the data in the context. If something is missing, say Shellby does not have that data yet.
- You may explain what a screen, goal, balance, transaction, or pattern means based on the context.
- Do not claim to move money, change settings, contact providers, or perform actions you cannot perform.
- Do not provide regulated financial advice, investment picks, or guarantees.
- For personal finance suggestions, keep them general and frame them as options to review.
- If the user asks about sensitive data, answer only from the context and avoid exposing access tokens or hidden implementation details.
- Keep most replies under 120 words unless the user asks for a breakdown.
''';
