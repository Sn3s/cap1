part of '../main.dart';

class ShellbyAiCoach {
  const ShellbyAiCoach();

  bool get _hasGeminiEndpoint =>
      _geminiProxyUrl.isNotEmpty || _geminiApiKey.isNotEmpty;
  bool get usesGemini => _hasGeminiEndpoint;
  bool get usesLocalModel => !usesGemini;
  bool get isConfigured => true;

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

  Future<ActionStageResult> recommendAvailableCashActionStage({
    required AppState state,
  }) async {
    if (!isConfigured) {
      throw const AiSetupException();
    }

    final parsed = await _sendJson(
      instructions: _availableCashActionStageInstructions,
      input: _availableCashActionStageInput(state),
      maxOutputTokens: 900,
    );
    final rawSuggestions = parsed['suggestions'];
    final suggestions = rawSuggestions is List
        ? rawSuggestions
            .whereType<Map<String, dynamic>>()
            .map(_actionStageSuggestionFromJson)
            .where((item) => item.actionId.isNotEmpty)
            .toList()
        : <ActionStageSuggestion>[];
    suggestions.sort((a, b) => a.priority.compareTo(b.priority));
    return ActionStageResult(
      summary: (parsed['summary'] as String?)?.trim().isNotEmpty == true
          ? (parsed['summary'] as String).trim()
          : 'Shellby reviewed the latest 14 days and prepared action updates.',
      firstChange:
          (parsed['first_change'] as String?)?.trim().isNotEmpty == true
              ? (parsed['first_change'] as String).trim()
              : (suggestions.isEmpty
                  ? 'No change is recommended yet.'
                  : suggestions.first.reason),
      suggestions: suggestions,
    );
  }

  Future<String> _sendText({
    required String instructions,
    required String input,
    required int maxOutputTokens,
  }) async {
    if (_hasGeminiEndpoint) {
      try {
        return await _sendGeminiText(
          instructions: instructions,
          input: input,
          maxOutputTokens: maxOutputTokens,
        );
      } on Object catch (error) {
        if (!_shouldUseQwenFallback(error)) rethrow;
      }
    }
    return _sendLocalText(
      instructions: instructions,
      input: input,
      maxOutputTokens: maxOutputTokens,
    );
  }

  Future<String> _sendLocalText({
    required String instructions,
    required String input,
    required int maxOutputTokens,
  }) async {
    final runtime = await _LocalLlamaRuntime.instance();
    return runtime.generateText(
      instructions: instructions,
      input: input,
      maxOutputTokens: maxOutputTokens,
    );
  }

  Future<ActionStageResult> recommendEmergencyFundActionStage({
    required AppState state,
  }) async {
    if (!isConfigured) {
      throw const AiSetupException();
    }

    final parsed = await _sendJson(
      instructions: _emergencyFundActionStageInstructions,
      input: _emergencyFundActionStageInput(state),
      maxOutputTokens: 900,
    );
    final rawSuggestions = parsed['suggestions'];
    final suggestions = rawSuggestions is List
        ? rawSuggestions
            .whereType<Map<String, dynamic>>()
            .map(_actionStageSuggestionFromJson)
            .where((item) => item.actionId.isNotEmpty)
            .toList()
        : <ActionStageSuggestion>[];
    suggestions.sort((a, b) => a.priority.compareTo(b.priority));
    return ActionStageResult(
      summary: (parsed['summary'] as String?)?.trim().isNotEmpty == true
          ? (parsed['summary'] as String).trim()
          : 'Shellby reviewed the latest 14 days and prepared action updates.',
      firstChange:
          (parsed['first_change'] as String?)?.trim().isNotEmpty == true
              ? (parsed['first_change'] as String).trim()
              : (suggestions.isEmpty
                  ? 'No change is recommended yet.'
                  : suggestions.first.reason),
      suggestions: suggestions,
    );
  }

  Future<ActionStageResult> recommendInvestmentActionStage({
    required AppState state,
  }) async {
    if (!isConfigured) {
      throw const AiSetupException();
    }

    final parsed = await _sendJson(
      instructions: _investmentActionStageInstructions,
      input: _investmentActionStageInput(state),
      maxOutputTokens: 900,
    );
    final rawSuggestions = parsed['suggestions'];
    final suggestions = rawSuggestions is List
        ? rawSuggestions
            .whereType<Map<String, dynamic>>()
            .map(_actionStageSuggestionFromJson)
            .where((item) => item.actionId.isNotEmpty)
            .toList()
        : <ActionStageSuggestion>[];
    suggestions.sort((a, b) => a.priority.compareTo(b.priority));
    return ActionStageResult(
      summary: (parsed['summary'] as String?)?.trim().isNotEmpty == true
          ? (parsed['summary'] as String).trim()
          : 'Shellby reviewed the latest portfolio activity and prepared action updates.',
      firstChange:
          (parsed['first_change'] as String?)?.trim().isNotEmpty == true
              ? (parsed['first_change'] as String).trim()
              : (suggestions.isEmpty
                  ? 'No change is recommended yet.'
                  : suggestions.first.reason),
      suggestions: suggestions,
    );
  }

  Future<ActionStageResult> recommendLifestyleActionStage({
    required AppState state,
  }) async {
    if (!isConfigured) {
      throw const AiSetupException();
    }

    final parsed = await _sendJson(
      instructions: _lifestyleActionStageInstructions,
      input: _lifestyleActionStageInput(state),
      maxOutputTokens: 900,
    );
    final rawSuggestions = parsed['suggestions'];
    final suggestions = rawSuggestions is List
        ? rawSuggestions
            .whereType<Map<String, dynamic>>()
            .map(_actionStageSuggestionFromJson)
            .where((item) => item.actionId.isNotEmpty)
            .toList()
        : <ActionStageSuggestion>[];
    suggestions.sort((a, b) => a.priority.compareTo(b.priority));
    return ActionStageResult(
      summary: (parsed['summary'] as String?)?.trim().isNotEmpty == true
          ? (parsed['summary'] as String).trim()
          : 'Shellby reviewed the latest lifestyle activity and prepared action updates.',
      firstChange:
          (parsed['first_change'] as String?)?.trim().isNotEmpty == true
              ? (parsed['first_change'] as String).trim()
              : (suggestions.isEmpty
                  ? 'No change is recommended yet.'
                  : suggestions.first.reason),
      suggestions: suggestions,
    );
  }

  Future<Map<String, dynamic>> _sendJson({
    required String instructions,
    required String input,
    required int maxOutputTokens,
  }) async {
    if (_hasGeminiEndpoint) {
      try {
        return await _sendGeminiJson(
          instructions: instructions,
          input: input,
          maxOutputTokens: maxOutputTokens,
        );
      } on Object catch (error) {
        if (!_shouldUseQwenFallback(error)) rethrow;
      }
    }
    return _sendLocalJson(
      instructions: instructions,
      input: input,
      maxOutputTokens: maxOutputTokens,
    );
  }

  Future<Map<String, dynamic>> _sendLocalJson({
    required String instructions,
    required String input,
    required int maxOutputTokens,
  }) async {
    final runtime = await _LocalLlamaRuntime.instance();
    final text = await runtime.generateJson(
      instructions: instructions,
      input: input,
      maxOutputTokens: maxOutputTokens,
    );
    final jsonText = _extractJsonObject(text);
    return jsonDecode(jsonText) as Map<String, dynamic>;
  }

  bool _shouldUseQwenFallback(Object error) {
    if (error is SocketException || error is TimeoutException) return true;
    return false;
  }

  Future<Map<String, dynamic>> _sendGeminiJson({
    required String instructions,
    required String input,
    required int maxOutputTokens,
  }) async {
    final body = await _sendGeminiGenerateContent(
      instructions: instructions,
      input: input,
      maxOutputTokens: maxOutputTokens,
      jsonMode: true,
    );
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final text = _extractGeminiText(decoded).trim();
    final jsonText = _extractJsonObject(text);
    return jsonDecode(jsonText) as Map<String, dynamic>;
  }

  Future<String> _sendGeminiText({
    required String instructions,
    required String input,
    required int maxOutputTokens,
  }) async {
    final body = await _sendGeminiGenerateContent(
      instructions: instructions,
      input: input,
      maxOutputTokens: maxOutputTokens,
      jsonMode: false,
    );
    return _extractGeminiText(jsonDecode(body) as Map<String, dynamic>).trim();
  }

  Future<String> _sendGeminiGenerateContent({
    required String instructions,
    required String input,
    required int maxOutputTokens,
    required bool jsonMode,
  }) async {
    final generationConfig = <String, Object>{
      'maxOutputTokens': maxOutputTokens,
      'temperature': 0.4,
      'topP': 0.9,
    };
    if (jsonMode) {
      generationConfig['responseMimeType'] = 'application/json';
    }

    final payload = jsonEncode({
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
      'generationConfig': generationConfig,
    });

    final retries = math.max(0, _geminiMaxRetries);
    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        return await _postGeminiPayload(payload);
      } on _GeminiRequestException catch (error) {
        if (_shouldRetryDirectGemini(error)) {
          return _postGeminiPayload(payload, forceDirectApi: true);
        }
        final canRetry = error.statusCode == 429 || error.statusCode >= 500;
        if (!canRetry || attempt == retries) rethrow;
      } on SocketException {
        if (attempt == retries) rethrow;
      } on TimeoutException {
        if (attempt == retries) rethrow;
      }
      await Future<void>.delayed(
        Duration(milliseconds: 400 * (attempt + 1)),
      );
    }
    throw StateError('Gemini request failed after retrying.');
  }

  bool _shouldRetryDirectGemini(_GeminiRequestException error) {
    return _geminiProxyUrl.isNotEmpty &&
        _geminiApiKey.isNotEmpty &&
        error.statusCode == 404 &&
        !error.directApi;
  }

  Future<String> _postGeminiPayload(
    String payload, {
    bool forceDirectApi = false,
  }) async {
    final client = HttpClient();
    final timeout = Duration(
      seconds: math.max(1, _geminiRequestTimeoutSeconds),
    );
    try {
      final directApi = forceDirectApi || _geminiProxyUrl.isEmpty;
      final request = await client
          .postUrl(_geminiEndpointUri(forceDirectApi: forceDirectApi))
          .timeout(timeout);
      request.headers.contentType = ContentType.json;
      if (!directApi) {
        request.headers.set('x-shellby-gemini-model', _geminiModel);
      } else if (_geminiApiKey.isNotEmpty) {
        request.headers.set('x-goog-api-key', _geminiApiKey);
      }
      request.write(payload);

      final response = await request.close().timeout(timeout);
      final body = await response.transform(utf8.decoder).join().timeout(
            timeout,
          );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _GeminiRequestException(
          statusCode: response.statusCode,
          body: body,
          message: directApi
              ? 'Gemini API request failed'
              : 'Gemini proxy request failed',
          directApi: directApi,
        );
      }
      return body;
    } finally {
      client.close(force: true);
    }
  }

  Uri _geminiEndpointUri({bool forceDirectApi = false}) {
    if (_geminiProxyUrl.isNotEmpty && !forceDirectApi) {
      return Uri.parse(_geminiProxyUrl);
    }
    return Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$_geminiModel:generateContent',
    );
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
      final anchorDate = DateTime.tryParse(
        income['scheduleAnchorDate']?.toString() ?? '',
      );
      final anchorType = income['scheduleAnchorType']?.toString() == 'last'
          ? 'last received'
          : 'next expected';
      final repeat = income['repeatFrequency']?.toString() ?? 'Monthly';
      final timing = scheduled
          ? anchorDate == null
              ? 'scheduled${payDay == null ? '' : ' on day $payDay'}'
              : '$anchorType ${anchorDate.toIso8601String().split('T').first}, repeats $repeat'
          : 'unscheduled';
      return '- $name: ${money(amount)} ($type, $timing)';
    }).join('\n');
    final expenses = state.onboardingExpenseLedger.take(10).map((expense) {
      final name = expense['name'] ?? expense['label'] ?? 'Expense';
      final amount = (expense['amount'] as num?)?.toDouble() ?? 0;
      final essential = expense['essential'] == true ? 'essential' : 'flex';
      final scheduled = expense['scheduled'] == true;
      final dueDay = (expense['dueDay'] as num?)?.toInt();
      final anchorDate = DateTime.tryParse(
        expense['scheduleAnchorDate']?.toString() ?? '',
      );
      final anchorType = expense['scheduleAnchorType']?.toString() == 'last'
          ? 'last paid'
          : 'next due';
      final repeat = expense['repeatFrequency']?.toString() ?? 'Monthly';
      final timing = scheduled
          ? anchorDate == null
              ? 'scheduled${dueDay == null ? '' : ' on day $dueDay'}'
              : '$anchorType ${anchorDate.toIso8601String().split('T').first}, repeats $repeat'
          : 'unscheduled';
      return '- $name: ${money(amount)} ($essential, $timing)';
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

  ActionStageSuggestion _actionStageSuggestionFromJson(
    Map<String, dynamic> json,
  ) {
    final target = <String, String>{};
    final rawTarget = json['target'];
    if (rawTarget is Map) {
      for (final entry in rawTarget.entries) {
        final key = entry.key?.toString() ?? '';
        if (key.isEmpty) continue;
        target[key] = entry.value?.toString() ?? '';
      }
    }
    return ActionStageSuggestion(
      option: json['option']?.toString().trim() ?? 'retain',
      actionId: json['action_id']?.toString().trim() ?? '',
      actionText: json['action_text']?.toString().trim() ?? '',
      priority: (json['priority'] as num?)?.toInt() ?? 99,
      reason: json['reason']?.toString().trim() ?? '',
      target: target,
      replacementActionId: json['replacement_action_id']?.toString().trim(),
    );
  }

  String _availableCashActionStageInput(AppState state) {
    final now = DateTime.now();
    final allTransactions = state.allTransactions
        .where((transaction) => transaction.createdAt != null)
        .toList()
      ..sort((a, b) => (b.createdAt ?? now).compareTo(a.createdAt ?? now));
    final latestDate = allTransactions.isEmpty
        ? now
        : allTransactions.first.createdAt!.toLocal();
    final cutoff = DateTime(
      latestDate.year,
      latestDate.month,
      latestDate.day,
    ).subtract(const Duration(days: 13));
    final latest14 = allTransactions
        .where(
            (transaction) => !transaction.createdAt!.toLocal().isBefore(cutoff))
        .toList();
    final service = IntegrationService.fromState(state);
    final latestWeeks = service.weekRecords
        .where((week) => !week.end.isBefore(cutoff))
        .toList();
    final income = latest14
        .where((transaction) => transaction.amount > 0)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    final spending = latest14
        .where((transaction) => transaction.amount < 0)
        .fold(0.0, (sum, transaction) => sum + transaction.amount.abs());
    final categoryTotals = <String, double>{};
    for (final transaction in latest14.where((item) => item.amount < 0)) {
      final category = transaction.category?.trim().isEmpty == false
          ? transaction.category!.trim()
          : 'Unlabeled';
      categoryTotals.update(
        category,
        (value) => value + transaction.amount.abs(),
        ifAbsent: () => transaction.amount.abs(),
      );
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final selectedBudgets = state.categorySpendingBudgets.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final selectedCategoryNames = state.categorySpendingBudgets.keys.toSet();
    final selectedCategorySpend = sortedCategories
        .where((entry) =>
            selectedCategoryNames.isEmpty ||
            selectedCategoryNames.contains(entry.key))
        .toList();
    final currentActions = state.selectedActionIds
        .where(_availableCashGoalActionIds.contains)
        .map((id) {
      final action = _d2Actions[id];
      final values = state.actionFieldValues[id] ?? const <String, String>{};
      return '- $id: ${action?.text ?? id}; current_target=${jsonEncode(values)}';
    }).join('\n');
    final candidateActions = _availableCashGoalActionIds
        .map((id) => '- $id: ${_d2Actions[id]?.text ?? id}')
        .join('\n');
    final txLines = latest14.take(40).map((transaction) {
      return '- ${transaction.createdAt!.toLocal().toIso8601String().split('T').first}: ${transaction.title}; ${transaction.amount >= 0 ? 'income' : 'spend'} ${money(transaction.amount.abs())}; category=${transaction.category ?? 'unlabeled'}; fund=${transaction.source ?? 'unlabeled'}; account=${transaction.account ?? 'Wallet'}';
    }).join('\n');
    final weekLines = latestWeeks.map((week) {
      return '- ${_shortDate(week.start)}-${_shortDate(week.end)}: income=${money(week.weekIncome)}, spending=${money(week.weekExpense)}, essential_allocation=${money(week.weekRefill)}, classified=${(week.propDaysClassified * 100).round()}%, income_week=${week.isSalaryWeek}, bill_week=${week.isBillWeek}';
    }).join('\n');

    return '''
Goal: Maintain Available Cash.
Action stage window: latest 14 days from ${_shortDate(cutoff)} to ${_shortDate(latestDate)}.

User/onboarding profile:
- Income rhythm: ${state.incomeRhythm}; income type: ${state.incomeType}
- Monthly income baseline: ${money(state.income)}
- Monthly salary: ${money(state.monthlySalary)}
- Monthly expenses baseline: ${money(state.expenses)}
- Monthly essential expenses: ${money(state.monthlyEssentialExpenseTotal)}
- Monthly non-essential expenses: ${money(state.monthlyNonEssentialExpenseTotal)}
- Variable expenses: ${money(state.variableExpenses)}
- Current monthly savings: ${money(state.savings)}
- Confidence: ${state.confidence.round()}/10; pressure: ${state.anxiety.round()}/10

Integration balances:
- FakeMaya linked: ${state.hasFakeMayaLink ? 'yes' : 'no'}
- Wallet: ${money(state.accountBalance('Wallet'))}
- Cash on hand: ${money(state.cashOnHandBalance)}
- Essential Expenses Fund balance: ${money(state.essentialExpensesBalance)}
- Unallocated FakeMaya wallet: ${money(state.unallocatedFakeMayaWallet)}

Latest 14-day totals:
- Income: ${money(income)}
- Spending: ${money(spending)}
- Net flow: ${money(income - spending)}

Category spending, latest 14 days:
${sortedCategories.isEmpty ? 'No spending categories available.' : sortedCategories.take(12).map((entry) => '- ${entry.key}: ${money(entry.value)}').join('\n')}

Selected category budgets:
${selectedBudgets.isEmpty ? 'No selected category budgets configured yet.' : selectedBudgets.map((entry) => '- ${entry.key}: ${money(entry.value)} monthly cap').join('\n')}

Selected category spending, latest 14 days:
${selectedCategorySpend.isEmpty ? 'No selected category spending recorded in the latest 14 days.' : selectedCategorySpend.map((entry) => '- ${entry.key}: ${money(entry.value)} spent').join('\n')}

Current configured actions:
${currentActions.isEmpty ? 'No configured action ids saved yet.' : currentActions}

Available action set:
$candidateActions

Week records:
${weekLines.isEmpty ? 'No week records available.' : weekLines}

Latest transactions:
${txLines.isEmpty ? 'No linked or manual transactions available.' : txLines}

Analyze the integration data and recommend what to change first.
''';
  }

  String _emergencyFundActionStageInput(AppState state) {
    final now = DateTime.now();
    final allTransactions = state.allTransactions
        .where((transaction) => transaction.createdAt != null)
        .toList()
      ..sort((a, b) => (b.createdAt ?? now).compareTo(a.createdAt ?? now));
    final latestDate = allTransactions.isEmpty
        ? now
        : allTransactions.first.createdAt!.toLocal();
    final cutoff = DateTime(
      latestDate.year,
      latestDate.month,
      latestDate.day,
    ).subtract(const Duration(days: 13));
    final activity = _emergencyReflectionActivity(state)
        .where((item) => !item.date.isBefore(cutoff))
        .toList();
    final added = activity
        .where((item) => item.add)
        .fold(0.0, (sum, item) => sum + item.amount);
    final used = activity
        .where((item) => !item.add)
        .fold(0.0, (sum, item) => sum + item.amount);
    final currentActions = state.selectedActionIds
        .where(_emergencyFundGoalActionIds.contains)
        .map((id) {
      final action = _d2Actions[id];
      final values = state.actionFieldValues[id] ?? const <String, String>{};
      return '- $id: ${action?.text ?? id}; current_target=${jsonEncode(values)}';
    }).join('\n');
    final candidateActions = _emergencyFundGoalActionIds
        .map((id) => '- $id: ${_d2Actions[id]?.text ?? id}')
        .join('\n');
    final activityLines = activity.take(20).map((item) {
      return '- ${_shortDate(item.date)}: ${item.title}; ${item.add ? 'added' : 'used'} ${money(item.amount)}; ${item.detail}';
    }).join('\n');

    return '''
Goal: Build Emergency Fund.
Action stage window: latest 14 days from ${_shortDate(cutoff)} to ${_shortDate(latestDate)}.

Emergency Fund balances:
- Current fund balance: ${money(state.displayedEmergencyFundBalance)}
- Three-month target: ${money(state.emergencyFundTarget)}
- Monthly essential expenses: ${money(state.monthlyEssentialExpenseTotal)}
- Months currently covered: ${state.emergencyMonthsCovered.toStringAsFixed(1)}
- Pending replenishment: ${money(state.pendingEmergencyReplenishment)}

Latest 14-day totals:
- Added to fund: ${money(added)}
- Used from fund: ${money(used)}

Current configured actions:
${currentActions.isEmpty ? 'No configured action ids saved yet.' : currentActions}

Available action set:
$candidateActions

Emergency fund activity, latest 14 days:
${activityLines.isEmpty ? 'No emergency fund activity recorded in the latest 14 days.' : activityLines}

Analyze the integration data and recommend what to change first.
''';
  }

  String _investmentActionStageInput(AppState state) {
    final currentActions = state.selectedActionIds
        .where(_investmentGoalActionIds.contains)
        .map((id) {
      final action = _d2Actions[id];
      final values = state.actionFieldValues[id] ?? const <String, String>{};
      return '- $id: ${action?.text ?? id}; current_target=${jsonEncode(values)}';
    }).join('\n');
    final candidateActions = _investmentGoalActionIds
        .map((id) => '- $id: ${_d2Actions[id]?.text ?? id}')
        .join('\n');
    final holdings = state.fakeMayaLink?.summary.investmentHoldings ?? const [];
    final holdingLines = holdings.map((holding) {
      return '- ${holding.name} (${holding.symbol}): ${holding.units.toStringAsFixed(6)} ${holding.unitLabel}, worth ${money(holding.value)}, unrealized ${holding.unrealizedGain >= 0 ? '+' : ''}${money(holding.unrealizedGain)} (${holding.unrealizedGainPercent.toStringAsFixed(1)}%)';
    }).join('\n');
    final transactions = state.fakeMayaLink?.summary.investmentTransactions ??
        const <FakeMayaStockTransaction>[];
    final recentTrades = transactions.take(10).map((tx) {
      final date =
          tx.createdAt == null ? 'unknown date' : _shortDate(tx.createdAt!);
      return '- $date: ${tx.side} ${tx.shares.toStringAsFixed(6)} ${tx.unitLabel} of ${tx.symbol} for ${money(tx.amount)}';
    }).join('\n');
    final baseline = state.investmentReturnBaselineDate;

    return '''
Goal: Grow Investments (Accumulating Wealth).

Investment Portfolio (cash contributions):
- Current balance: ${money(state.investmentBalance)}
- Portfolio value target: ${money(state.investmentPortfolioTarget)}

Annual return tracking:
- Tracking started: ${baseline == null ? 'not started yet' : _shortDate(baseline)}
- Annualized return since tracking started: ${baseline == null ? 'n/a' : '${state.investmentAnnualizedReturnPercent.toStringAsFixed(1)}%'}
- Target annual return: ${state.investmentTargetAnnualReturnPercent.toStringAsFixed(0)}%

FakeMaya stock/crypto holdings (BTC/NVDA):
${holdingLines.isEmpty ? 'No stock or crypto holdings yet.' : holdingLines}

Recent FakeMaya stock/crypto trades:
${recentTrades.isEmpty ? 'No trades recorded yet.' : recentTrades}

Current configured actions:
${currentActions.isEmpty ? 'No configured action ids saved yet.' : currentActions}

Available action set:
$candidateActions

Analyze the integration data and recommend what to change first.
''';
  }

  String _lifestyleActionStageInput(AppState state) {
    final currentActions = state.selectedActionIds
        .where(_lifestyleActionStageActionIds.contains)
        .map((id) {
      final action = _d2Actions[id];
      final values = state.actionFieldValues[id] ?? const <String, String>{};
      return '- $id: ${action?.text ?? id}; current_target=${jsonEncode(values)}';
    }).join('\n');
    final candidateActions = _lifestyleActionStageActionIds
        .map((id) => '- $id: ${_d2Actions[id]?.text ?? id}')
        .join('\n');
    final hobbies = state.lifestyleHobbies;
    final hobbyLines = hobbies.map((hobby) {
      final id = hobby['id'].toString();
      final name = hobby['name'];
      final target = (hobby['target'] as num?)?.toDouble() ?? 0;
      final months = (hobby['months'] as num?)?.toInt() ?? 0;
      final saved = state.lifestyleHobbyBalance(id);
      return '- $name: ${money(saved)} of ${money(target)} saved, $months month window (read-only, not an editable action target)';
    }).join('\n');

    return '''
Goal: Lifestyle Fund (Financial Freedom) - the relaxed top of the financial pyramid, so keep tone light and non-urgent.

Personal Lifestyle Fund:
- Current balance: ${money(state.lifestyleFundBalance)}
- Reserved this month for subscriptions/memberships: ${money(state.lifestyleReservedThisMonth)}
- This week's everyday enjoyment spending: ${money(_currentWeekLifestyleSpend(state))}

Hobby/activity targets (for context only - these are managed as a separate named list in the app, not through the actions below):
${hobbyLines.isEmpty ? 'No hobby or activity targets configured yet.' : hobbyLines}

Current configured actions:
${currentActions.isEmpty ? 'No configured action ids saved yet.' : currentActions}

Available action set:
$candidateActions

Analyze the integration data and recommend what to change first.
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

class _GeminiRequestException implements Exception {
  const _GeminiRequestException({
    required this.statusCode,
    required this.body,
    required this.message,
    required this.directApi,
  });

  final int statusCode;
  final String body;
  final String message;
  final bool directApi;

  @override
  String toString() => '$message: $statusCode $body';
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

const _availableCashActionStageInstructions = '''
You are Shellby, the Action Stage AI for a Philippine personal finance app.
Your job is to analyze the user's latest 14 days of integration data and recommend the first Maintain Available Cash action change.

Allowed actions only:
- A1: Set aside X% of every income received into your Everyday Expenses Fund.
- A3: Limit spending in selected categories to ₱X per month to protect day-to-day cash flow.
- A20: Bring in at least ₱X this month from income, side gigs, or other cash-in to keep available cash on pace.
- A19: Keep at least ₱X available in your Essential Expenses Fund as a minimum cash floor for essentials.

Allowed recommendation option values only:
- retain_action
- change_parameterized_target
- suggest_new_action
- remove_and_replace_action

Rules:
- Use only the provided integration, onboarding, balance, action, and transaction data.
- Prioritize the suggestion that should be changed first.
- Return 1-2 suggestions when data is available, ordered by priority.
- If a current action is working, retain it.
- If the action is useful but the parameter looks too high/low, choose change_parameterized_target.
- If A1 or A3 is missing and the data shows a need for it, choose suggest_new_action.
- If an existing Maintain Available Cash action is less useful than the other allowed action, choose remove_and_replace_action.
- Do not mention irregular income buffers, needs jars, buffer balances, or actions outside A1 and A3.
- Do not recommend products, banks, securities, borrowing, or regulated financial advice.
- Keep reasons concrete and cite a relevant amount, category, balance, or 14-day pattern.
- Use PHP amounts.

Return only valid JSON:
{
  "summary": "1 short paragraph interpreting the latest 14 days",
  "first_change": "the first thing the user should review or change",
  "suggestions": [
    {
      "priority": 1,
      "option": "retain_action | change_parameterized_target | suggest_new_action | remove_and_replace_action",
      "action_id": "A1 | A3",
      "action_text": "short action label",
      "reason": "specific reason grounded in the data",
      "target": {
        "pct": "number if A1 percentage is recommended",
        "amt": "number if A3 peso cap is recommended",
        "categories": "comma-separated categories if A3 is recommended"
      },
      "replacement_action_id": "action id only for remove_and_replace_action, otherwise null"
    }
  ]
}
''';

const _emergencyFundActionStageInstructions = '''
You are Shellby, the Action Stage AI for a Philippine personal finance app.
Your job is to analyze the user's latest 14 days of Emergency Fund activity and recommend the first Build Emergency Fund action change.

Allowed actions only:
- A9: Deposit at least ₱X into the Emergency Fund each month.
- A8: Set aside X% of each income for the Emergency Fund.
- A22: Build your Emergency Fund to cover X months of essential expenses.
- A10: Replenish withdrawn Emergency Fund amounts within X days after receiving income.

Allowed recommendation option values only:
- retain_action
- change_parameterized_target
- suggest_new_action
- remove_and_replace_action

Rules:
- Use only the provided Emergency Fund balance, target, and activity data.
- Prioritize the suggestion that should be changed first.
- Return 1-2 suggestions when data is available, ordered by priority.
- If a current action is working, retain it.
- If the action is useful but the parameter looks too high/low for the target and months covered, choose change_parameterized_target.
- If A9 or A8 is missing and the data shows contributions are inconsistent or behind target, choose suggest_new_action.
- If there is a pending replenishment and no A10 configured, prioritize suggesting A10.
- If an existing Build Emergency Fund action is less useful than another allowed action, choose remove_and_replace_action.
- Do not mention available cash, essential expenses fund, or actions outside A8, A9, A10, and A22.
- Do not recommend products, banks, securities, borrowing, or regulated financial advice.
- Keep reasons concrete and cite a relevant amount, month count, or 14-day pattern.
- Use PHP amounts.

Return only valid JSON:
{
  "summary": "1 short paragraph interpreting the latest 14 days",
  "first_change": "the first thing the user should review or change",
  "suggestions": [
    {
      "priority": 1,
      "option": "retain_action | change_parameterized_target | suggest_new_action | remove_and_replace_action",
      "action_id": "A8 | A9 | A10 | A22",
      "action_text": "short action label",
      "reason": "specific reason grounded in the data",
      "target": {
        "pct": "number if A8 percentage is recommended",
        "amt": "number if A9 peso minimum is recommended",
        "days": "number if A10 replenish window is recommended",
        "months": "number if A22 months of coverage is recommended"
      },
      "replacement_action_id": "action id only for remove_and_replace_action, otherwise null"
    }
  ]
}
''';

const _investmentActionStageInstructions = '''
You are Shellby, the Action Stage AI for a Philippine personal finance app.
Your job is to analyze the user's Investment Portfolio activity, FakeMaya stock/crypto holdings, and annual-return tracking, then recommend the first Grow Investments action change.

Allowed actions only:
- A12: Allocate X% of each income to the Investment Portfolio.
- A23: Build the Investment Portfolio to ₱X.
- A30: Keep your investment portfolio on track to meet your target annual return on investment of X%.

Allowed recommendation option values only:
- retain_action
- change_parameterized_target
- suggest_new_action
- remove_and_replace_action

Rules:
- Use only the provided Investment Portfolio balance, target, annual-return tracking, and FakeMaya holdings/trade data.
- Prioritize the suggestion that should be changed first.
- Return 1-2 suggestions when data is available, ordered by priority.
- If a current action is working, retain it.
- If A30 is tracking and annualized return is meaningfully behind the target, recommend reviewing the investment allocation - never recommend selling holdings, buying specific new assets, timing the market, or any other investing/trading advice. This is not financial advice.
- If A30 has not started tracking yet, suggest starting it.
- If the A23 portfolio target looks too low/high relative to the current balance and contribution pace, choose change_parameterized_target.
- If A12 is missing or its percentage looks inconsistent with the income and contribution pattern shown, choose change_parameterized_target or suggest_new_action.
- Do not mention available cash, emergency fund, lifestyle fund, or actions outside A12, A23, and A30.
- Do not recommend products, banks, specific securities, buying, selling, or any other regulated financial advice - only encourage reviewing the portfolio/allocation in general terms.
- Keep reasons concrete and cite a relevant amount, percentage, or tracking duration.
- Use PHP amounts.

Return only valid JSON:
{
  "summary": "1 short paragraph interpreting the portfolio's current state",
  "first_change": "the first thing the user should review or change",
  "suggestions": [
    {
      "priority": 1,
      "option": "retain_action | change_parameterized_target | suggest_new_action | remove_and_replace_action",
      "action_id": "A12 | A23 | A30",
      "action_text": "short action label",
      "reason": "specific reason grounded in the data",
      "target": {
        "pct": "number if A12 percentage or A30 target annual return is recommended",
        "amt": "number if A23 portfolio value target is recommended"
      },
      "replacement_action_id": "action id only for remove_and_replace_action, otherwise null"
    }
  ]
}
''';

const _lifestyleActionStageInstructions = '''
You are Shellby, the Action Stage AI for a Philippine personal finance app.
Your job is to analyze the user's Personal Lifestyle Fund activity (subscriptions, payday transfers, weekly enjoyment spending) and recommend the first Lifestyle Fund action change. This is the relaxed top of the financial pyramid, not a strict savings goal, so keep the tone light and low-pressure.

Allowed actions only:
- A26: Set aside ₱X each month for subscriptions and memberships.
- A27: Add ₱X to the Personal Lifestyle Fund every payday.
- A28: Keep everyday enjoyment spending within ₱X each week.

Hobby or activity targets (A29) are shown for context only and are NOT an allowed action - they are managed as a separate named list of up to 3 items directly in the app, not through this recommendation flow. Never return "A29" as an action_id.

Allowed recommendation option values only:
- retain_action
- change_parameterized_target
- suggest_new_action
- remove_and_replace_action

Rules:
- Use only the provided Personal Lifestyle Fund balance, monthly subscription reserve, weekly enjoyment spending, and hobby context.
- Prioritize the suggestion that should be changed first.
- Return 1-2 suggestions when data is available, ordered by priority.
- If a current action is working, retain it.
- If A26's monthly target looks mismatched with what is actually being reserved, choose change_parameterized_target.
- If A28's weekly limit is being exceeded repeatedly, suggest raising it to a realistic number rather than scolding the user - this is discretionary spending, not an emergency.
- If A27 is missing and payday transfers to the Personal Lifestyle Fund look inconsistent, choose suggest_new_action.
- Do not mention available cash, emergency fund, investment portfolio, or actions outside A26, A27, and A28.
- Never recommend specific merchants, subscriptions to cancel, or how to spend the money - only whether the configured amounts still fit.
- Keep reasons concrete and cite a relevant amount or spending pattern.
- Use PHP amounts.

Return only valid JSON:
{
  "summary": "1 short, low-pressure paragraph interpreting the lifestyle fund's current state",
  "first_change": "the first thing the user should review or change",
  "suggestions": [
    {
      "priority": 1,
      "option": "retain_action | change_parameterized_target | suggest_new_action | remove_and_replace_action",
      "action_id": "A26 | A27 | A28",
      "action_text": "short action label",
      "reason": "specific reason grounded in the data",
      "target": {
        "amt": "number if a peso amount is recommended"
      },
      "replacement_action_id": "action id only for remove_and_replace_action, otherwise null"
    }
  ]
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
