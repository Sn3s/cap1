import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const ShellbyApp());
}

const _brand = Color(0xFF7047B8);
const _sage = Color(0xFF59B284);
const _belly = Color(0xFFD2B5FC);
const _bellySoft = Color(0xFFECE1FD);
const _bg = Color(0xFFF6F3FA);
const _surface = Color(0xFFFFFEFF);
const _title = Color(0xFF241E32);
const _body = Color(0xFF70677C);
const _border = Color(0xFFE3D5F8);
const _green = _sage;
const _red = Color(0xFFF43F5E);
const _amber = Color(0xFFF59E0B);
const _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
const _geminiModel = String.fromEnvironment(
  'GEMINI_MODEL',
  defaultValue: 'gemini-2.5-flash',
);

class ShellbyApp extends StatefulWidget {
  const ShellbyApp({super.key});

  @override
  State<ShellbyApp> createState() => _ShellbyAppState();
}

class _ShellbyAppState extends State<ShellbyApp> {
  final state = AppState();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Shellby',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: _bg,
          colorScheme: ColorScheme.fromSeed(seedColor: _brand),
          fontFamily: 'System',
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 34,
              height: 1.05,
              fontWeight: FontWeight.w900,
              color: _title,
              letterSpacing: 0,
            ),
            headlineMedium: TextStyle(
              fontSize: 26,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: _title,
              letterSpacing: 0,
            ),
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _title,
              letterSpacing: 0,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _body,
              letterSpacing: 0,
            ),
          ),
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  String age = '';
  String occupation = '';
  String industry = 'Technology';
  String employmentStatus = 'Full-time';
  String incomeType = 'Fixed';
  String location = 'Urban';
  String responsibility = 'Mostly myself';
  String primaryConcern = 'Building emergency savings';
  String motivation = '';
  String reflectedMotivation = '';
  String selectedGoal = 'Emergency Shield';
  String selectedGoalDescription =
      'Build a 3-month emergency buffer in the next 12 months.';
  double selectedGoalMonthlyTarget = 0;
  String socialStructure = 'Private only';
  double confidence = 5;
  double anxiety = 5;
  double avoidance = 5;
  double peerPressure = 5;
  double income = 8240;
  double expenses = 3120.5;
  double variableExpenses = 1800;
  double savings = 1200;
  double emergencyMonths = 1.5;
  double debtPayments = 650;
  double investments = 12000;
  double subscriptions = 145;
  bool consentBaseline = true;
  bool consentAi = true;
  bool consentBenchmarking = false;
  bool consentCommunity = false;
  bool consentTrustedCircle = false;
  final Set<String> trackingVariables = {
    'Income',
    'Expenses',
    'Savings progress',
    'Assets and liabilities',
  };
  final Set<String> interferingVariables = {
    'Family obligations',
    'Debt due dates',
  };
  final List<MoneyItem> assets = [
    MoneyItem('Checking Account', 'Primary savings', 2400),
    MoneyItem('Investment Portfolio', 'Vanguard ETF', 12000),
  ];
  final List<MoneyItem> liabilities = [
    MoneyItem('Student Loan', 'Federal Direct', 18500),
    MoneyItem('Credit Card', 'Visa Gold', 850),
  ];
  final List<ChatMessage> messages = [
    ChatMessage(
      false,
      "I'm Shellby. If you could achieve one financial milestone in the next 12 months, what would it be?",
    ),
  ];

  double get totalAssets => assets.fold(0, (sum, item) => sum + item.value);
  double get totalLiabilities =>
      liabilities.fold(0, (sum, item) => sum + item.value);
  double get netWorth => totalAssets - totalLiabilities + 24500.40;
  double get monthlySurplus =>
      income - expenses - variableExpenses - debtPayments;
  double get savingsRate =>
      income <= 0 ? 0 : (savings / income * 100).clamp(0, 100);
  double get debtToIncome =>
      income <= 0 ? 0 : (debtPayments / income * 100).clamp(0, 100);
  double get requiredMonthlyContribution {
    if (selectedGoalMonthlyTarget > 0) return selectedGoalMonthlyTarget;
    if (selectedGoal == 'Debt Reset') return math.max(400, debtPayments * .8);
    if (selectedGoal == 'Investment Starter') {
      return math.max(500, income * .12);
    }
    return math.max(500, expenses * 3 / 12);
  }

  double get feasibilityScore {
    final surplusFit =
        monthlySurplus <= 0
            ? 20
            : (monthlySurplus / requiredMonthlyContribution * 65).clamp(10, 65);
    final confidenceFit = confidence * 2;
    final anxietyPenalty = anxiety * 1.2;
    return (surplusFit + confidenceFit + emergencyMonths * 4 - anxietyPenalty)
        .clamp(0, 100);
  }

  double get healthScore => (45 +
          savingsRate * .35 +
          emergencyMonths * 4 +
          confidence * 2.2 -
          anxiety * .9 -
          debtToIncome * .25 +
          (location == 'Urban' ? 2 : 4))
      .clamp(0, 100);

  void updateConfidence(double value) {
    confidence = value;
    notifyListeners();
  }

  void updateAnxiety(double value) {
    anxiety = value;
    notifyListeners();
  }

  void updateAvoidance(double value) {
    avoidance = value;
    notifyListeners();
  }

  void updatePeerPressure(double value) {
    peerPressure = value;
    notifyListeners();
  }

  void setMotivation(String value) {
    motivation = value.trim();
    reflectedMotivation =
        motivation.isEmpty
            ? 'You want a clearer financial plan that feels realistic for your life.'
            : 'You said: "$motivation"';
    notifyListeners();
  }

  void setRecommendedGoal({
    required String title,
    required String description,
    required double monthlyTarget,
  }) {
    selectedGoal = title;
    selectedGoalDescription = description;
    selectedGoalMonthlyTarget = monthlyTarget;
    notifyListeners();
  }

  void choosePresetGoal(String title, String description) {
    selectedGoal = title;
    selectedGoalDescription = description;
    selectedGoalMonthlyTarget = 0;
    notifyListeners();
  }

  void toggleTrackingVariable(String value) {
    if (trackingVariables.contains(value)) {
      trackingVariables.remove(value);
    } else {
      trackingVariables.add(value);
    }
    notifyListeners();
  }

  void toggleInterferingVariable(String value) {
    if (interferingVariables.contains(value)) {
      interferingVariables.remove(value);
    } else {
      interferingVariables.add(value);
    }
    notifyListeners();
  }

  void sendDiscoveryMessage(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    messages.add(ChatMessage(true, trimmed));
    messages.add(
      const ChatMessage(
        false,
        "That's a powerful vision. Is this primarily about creating a long-term safety net, or fueling significant growth right now?",
      ),
    );
    notifyListeners();
  }

  void addAsset() {
    assets.add(MoneyItem('New Asset', 'Tap to refine later', 0));
    notifyListeners();
  }

  void addLiability() {
    liabilities.add(MoneyItem('New Liability', 'Tap to refine later', 0));
    notifyListeners();
  }
}

class MoneyItem {
  MoneyItem(this.name, this.description, this.value);

  final String name;
  final String description;
  final double value;
}

class ChatMessage {
  const ChatMessage(this.fromUser, this.text);

  final bool fromUser;
  final String text;
}

class MotivationCoachResult {
  const MotivationCoachResult({
    required this.reply,
    required this.conclusion,
    required this.isComplete,
  });

  final String reply;
  final String conclusion;
  final bool isComplete;
}

class GoalCoachResult {
  const GoalCoachResult({
    required this.reply,
    required this.title,
    required this.description,
    required this.monthlyTarget,
  });

  final String reply;
  final String title;
  final String description;
  final double monthlyTarget;
}

class GeminiMotivationCoach {
  const GeminiMotivationCoach();

  bool get isConfigured => _geminiApiKey.isNotEmpty;

  Future<MotivationCoachResult> send({
    required String concern,
    required List<ChatMessage> messages,
  }) async {
    if (!isConfigured) {
      throw const GeminiSetupException();
    }

    final parsed = await _sendJson(
      instructions: _motivationCoachInstructions,
      input: _motivationCoachInput(concern, messages),
      maxOutputTokens: 500,
    );
    return MotivationCoachResult(
      reply:
          (parsed['reply'] as String?)?.trim() ??
          'Tell me a little more about why this matters.',
      conclusion: (parsed['conclusion'] as String?)?.trim() ?? '',
      isComplete: parsed['is_complete'] == true,
    );
  }

  Future<GoalCoachResult> recommendGoal({
    required AppState state,
    required List<ChatMessage> messages,
  }) async {
    if (!isConfigured) {
      throw const GeminiSetupException();
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
      reply:
          (parsed['reply'] as String?)?.trim() ??
          'I drafted a first goal from your focus and reason.',
      title:
          title == null || title.isEmpty
              ? _fallbackGoalTitle(state.primaryConcern)
              : title,
      description:
          description == null || description.isEmpty
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

  String _motivationCoachInput(String concern, List<ChatMessage> messages) {
    final transcript = messages
        .map(
          (message) =>
              '${message.fromUser ? 'User' : 'Shellby'}: ${message.text}',
        )
        .join('\n');
    return '''
Selected financial concern: $concern

Conversation so far:
$transcript

Respond as Shellby. Ask one deeper question if the user's reason is still vague.
If the motivation is clear enough, provide a conclusion and set is_complete to true.
Return only JSON with keys reply, conclusion, is_complete.
''';
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
- Anxiety: ${state.anxiety.round()}/10
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
      'Reducing financial anxiety' => 'Calm Money Check-in',
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

class GeminiSetupException implements Exception {
  const GeminiSetupException();
}

const _motivationCoachInstructions = '''
You are Shellby, a warm AI onboarding coach for a Philippine personal finance app.
Your job is the Preparation Stage motivation elicitation step.

Use the user's selected concern to ask relevant, non-judgmental follow-up questions.
Follow these rules:
- Ask only one question at a time.
- Keep replies under 55 words.
- Do not give regulated financial advice.
- Do not recommend specific securities, banks, or products.
- Use PHP context when money is mentioned.
- Go deeper into personal meaning, constraints, confidence, anxiety, family obligations, peer pressure, or timing.
- After 2-3 useful user answers, conclude with a concise reflection of the user's motivation.
- If the answer is already clear and personally meaningful, conclude immediately.

Return only valid JSON:
{
  "reply": "message shown to the user",
  "conclusion": "a concise motivation summary, or empty string if more questions are needed",
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
- Prefer safer foundational goals when anxiety is high or surplus is low.

Return only valid JSON:
{
  "reply": "short coach message explaining the recommendation or revision",
  "title": "short goal title",
  "description": "specific goal sentence with target and timeframe",
  "monthly_target": number
}
''';

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  color: _bellySoft,
                  borderRadius: BorderRadius.circular(48),
                ),
                child: const Stack(
                  children: [
                    Positioned(
                      top: 18,
                      right: 18,
                      child: Icon(Icons.star_rounded, color: _amber, size: 42),
                    ),
                    Center(child: Ghost(size: 150)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Welcome! Let's prepare Shellby for you.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Build your financial path through careful reflection and expert AI guidance.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _body,
                  fontSize: 17,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 44),
              PrimaryButton(
                label: 'Get Started',
                icon: Icons.arrow_forward_rounded,
                onPressed:
                    () => _push(context, const PreparationOrientScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PreparationOrientScreen extends StatefulWidget {
  const PreparationOrientScreen({super.key});

  @override
  State<PreparationOrientScreen> createState() =>
      _PreparationOrientScreenState();
}

class _PreparationOrientScreenState extends State<PreparationOrientScreen> {
  final controller = PageController();
  int index = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void next() {
    if (index == _slides.length - 1) {
      _push(context, const PreparationContextScreen());
      return;
    }
    controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  static const _slides = [
    OrientationSlideData(
      icon: Icons.route_rounded,
      title: 'Your money path starts with a map.',
      body:
          'Shellby helps you see your financial baseline before asking you to track anything.',
      accent: _brand,
    ),
    OrientationSlideData(
      icon: Icons.chat_bubble_rounded,
      title: 'First, Shellby asks why.',
      body:
          'A goal works better when it comes from your own reason, not a random preset.',
      accent: _sage,
    ),
    OrientationSlideData(
      icon: Icons.auto_graph_rounded,
      title: 'Then we check if the goal fits.',
      body:
          'Shellby compares your income, expenses, confidence, anxiety, and obligations before recommending a plan.',
      accent: _amber,
    ),
    OrientationSlideData(
      icon: Icons.lock_rounded,
      title: 'You choose what gets used.',
      body:
          'Before collection begins, you decide what stays private, what can power AI, and what can be shared anonymously.',
      accent: _red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLast = index == _slides.length - 1;
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    color: _brand,
                    icon: const Icon(Icons.chevron_left_rounded, size: 32),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed:
                        () => _push(context, const PreparationContextScreen()),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: _body,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  itemCount: _slides.length,
                  onPageChanged: (value) => setState(() => index = value),
                  itemBuilder:
                      (context, slideIndex) =>
                          OrientationSlide(data: _slides[slideIndex]),
                ),
              ),
              OrientationDots(count: _slides.length, index: index),
              const SizedBox(height: 24),
              PrimaryButton(
                label: isLast ? 'Set My Context' : 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: next,
              ),
              const SizedBox(height: 12),
              const Text(
                'Educational guidance only. Not a substitute for licensed financial advice.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _body,
                  fontSize: 11,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrientationSlideData {
  const OrientationSlideData({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color accent;
}

class OrientationSlide extends StatelessWidget {
  const OrientationSlide({super.key, required this.data});

  final OrientationSlideData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 560;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OrientationIllustration(data: data, compact: compact),
            SizedBox(height: compact ? 20 : 34),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: compact ? 28 : 34,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 330),
              child: Text(
                data.body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _body,
                  fontSize: 16,
                  height: 1.38,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class OrientationIllustration extends StatelessWidget {
  const OrientationIllustration({
    super.key,
    required this.data,
    required this.compact,
  });

  final OrientationSlideData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 220.0 : 270.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: data.accent.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            top: size * .08,
            right: size * .12,
            child: MiniBadge(
              icon: data.icon,
              color: data.accent,
              label: 'Prep',
            ),
          ),
          Positioned(
            left: size * .06,
            bottom: size * .18,
            child: MiniBadge(
              icon: Icons.payments_rounded,
              color: _sage,
              label: 'PHP',
            ),
          ),
          Positioned(
            right: size * .08,
            bottom: size * .08,
            child: MiniBadge(
              icon: Icons.check_rounded,
              color: _brand,
              label: 'Fit',
            ),
          ),
          Container(
            width: size * .62,
            height: size * .62,
            decoration: BoxDecoration(
              color: _bellySoft,
              borderRadius: BorderRadius.circular(44),
              border: Border.all(color: _border),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: size * .11,
                  child: Icon(data.icon, color: data.accent, size: 42),
                ),
                Ghost(size: size * .36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MiniBadge extends StatelessWidget {
  const MiniBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class OrientationDots extends StatelessWidget {
  const OrientationDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (dotIndex) {
        final active = dotIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? _brand : _border,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class PreparationContextScreen extends StatefulWidget {
  const PreparationContextScreen({super.key});

  @override
  State<PreparationContextScreen> createState() =>
      _PreparationContextScreenState();
}

class _PreparationContextScreenState extends State<PreparationContextScreen> {
  final occupationController = TextEditingController();

  @override
  void dispose() {
    occupationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final canContinue = state.age.isNotEmpty && state.occupation.isNotEmpty;
    return OnboardingScaffold(
      phase: 2,
      title: 'Establish your context.',
      subtitle:
          'Shellby uses your life stage and obligations to avoid goals that look good on paper but do not fit real life.',
      bottom: PrimaryButton(
        label: 'Choose Focus',
        icon: Icons.arrow_forward_rounded,
        enabled: canContinue,
        onPressed: () => _push(context, const FinancialConcernScreen()),
      ),
      child: Column(
        children: [
          LabeledField(
            label: 'Age & life stage',
            icon: Icons.calendar_today_rounded,
            child: DropdownButtonFormField<String>(
              value: state.age.isEmpty ? null : state.age,
              decoration: inputDecoration('Select your stage'),
              items: const [
                DropdownMenuItem(
                  value: 'Fresh Graduate',
                  child: Text('Fresh Graduate (20-25)'),
                ),
                DropdownMenuItem(
                  value: 'Early Career',
                  child: Text('Early Career (26-35)'),
                ),
                DropdownMenuItem(
                  value: 'Mid-Career',
                  child: Text('Mid-Career (36-50)'),
                ),
              ],
              onChanged: (value) => setState(() => state.age = value ?? ''),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Occupation',
            icon: Icons.work_rounded,
            child: TextField(
              controller: occupationController,
              decoration: inputDecoration('e.g. Software Engineer'),
              onChanged: (value) => setState(() => state.occupation = value),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Industry',
            icon: Icons.business_center_rounded,
            child: DropdownButtonFormField<String>(
              value: state.industry,
              decoration: inputDecoration('Select your industry'),
              items:
                  const [
                    'Technology',
                    'Finance',
                    'Healthcare',
                    'Education',
                    'Business Services',
                    'Retail & E-commerce',
                    'Creative & Media',
                    'Government',
                    'Manufacturing',
                    'Hospitality',
                    'Freelance / Self-employed',
                    'Other',
                  ].map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
              onChanged:
                  (value) =>
                      setState(() => state.industry = value ?? state.industry),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Employment status',
            icon: Icons.badge_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  ['Full-time', 'Freelance', 'Contract', 'Mixed']
                      .map(
                        (value) => CompactChoice(
                          label: value,
                          selected: state.employmentStatus == value,
                          onTap:
                              () => setState(
                                () => state.employmentStatus = value,
                              ),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Income type',
            icon: Icons.payments_rounded,
            child: Row(
              children: [
                Expanded(
                  child: ChoiceTile(
                    label: 'Fixed',
                    selected: state.incomeType == 'Fixed',
                    onTap: () => setState(() => state.incomeType = 'Fixed'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceTile(
                    label: 'Variable',
                    selected: state.incomeType == 'Variable',
                    onTap: () => setState(() => state.incomeType = 'Variable'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Financial responsibility',
            icon: Icons.family_restroom_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  ['Mostly myself', 'Family support', 'Shared household']
                      .map(
                        (value) => CompactChoice(
                          label: value,
                          selected: state.responsibility == value,
                          onTap:
                              () =>
                                  setState(() => state.responsibility = value),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialConcernScreen extends StatefulWidget {
  const FinancialConcernScreen({super.key});

  @override
  State<FinancialConcernScreen> createState() => _FinancialConcernScreenState();
}

class _FinancialConcernScreenState extends State<FinancialConcernScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final options = const [
      ('Building emergency savings', Icons.shield_rounded),
      ('Managing debt', Icons.credit_score_rounded),
      ('Controlling spending', Icons.shopping_bag_rounded),
      ('Starting investments', Icons.trending_up_rounded),
      ('Planning a big purchase', Icons.flag_rounded),
      ('Reducing financial anxiety', Icons.self_improvement_rounded),
      ('Comparing with peers', Icons.groups_rounded),
      ("I'm not sure yet", Icons.help_rounded),
    ];
    return OnboardingScaffold(
      phase: 3,
      title: 'What feels most important?',
      subtitle:
          'Pick one starting focus. This is an invitation, not a permanent commitment.',
      bottom: PrimaryButton(
        label: 'Tell Shellby Why',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const MotivationSurfaceScreen()),
      ),
      child: Column(
        children:
            options
                .map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SelectableOption(
                      icon: option.$2,
                      title: option.$1,
                      selected: state.primaryConcern == option.$1,
                      onTap:
                          () =>
                              setState(() => state.primaryConcern = option.$1),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

class MotivationSurfaceScreen extends StatefulWidget {
  const MotivationSurfaceScreen({super.key});

  @override
  State<MotivationSurfaceScreen> createState() =>
      _MotivationSurfaceScreenState();
}

class _MotivationSurfaceScreenState extends State<MotivationSurfaceScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  final coach = const GeminiMotivationCoach();
  final List<ChatMessage> messages = [];
  bool seeded = false;
  bool loading = false;
  String error = '';

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (seeded) return;
    final concern = AppScope.of(context).primaryConcern;
    messages.add(ChatMessage(false, _firstQuestionFor(concern)));
    seeded = true;
  }

  Future<void> sendAnswer([String? value]) async {
    final state = AppScope.of(context);
    final answer = (value ?? controller.text).trim();
    if (answer.isEmpty || loading) return;

    setState(() {
      error = '';
      loading = true;
      messages.add(ChatMessage(true, answer));
      controller.clear();
    });
    _scrollToBottom();

    try {
      final result = await coach.send(
        concern: state.primaryConcern,
        messages: messages,
      );
      if (!mounted) return;
      setState(() {
        messages.add(ChatMessage(false, result.reply));
        loading = false;
      });
      if (result.isComplete && result.conclusion.isNotEmpty) {
        state.setMotivation(result.conclusion);
      }
      _scrollToBottom();
    } on GeminiSetupException {
      if (!mounted) return;
      setState(() {
        loading = false;
        error =
            'Add a Gemini API key to enable live AI: flutter run --dart-define=GEMINI_API_KEY=your_key';
        messages.add(
          const ChatMessage(
            false,
            'I can guide this conversation once the Gemini API key is configured for the app.',
          ),
        );
      });
      _scrollToBottom();
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'AI response failed. Check your connection, API key, or model.';
        messages.add(
          ChatMessage(
            false,
            'I had trouble reaching the AI service. You can try again in a moment. Details: $exception',
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final chips = _chipsForConcern(state.primaryConcern);
    final hasReflection = state.reflectedMotivation.isNotEmpty;
    return OnboardingScaffold(
      phase: 4,
      title: 'Chat through your reason.',
      subtitle:
          'Shellby asks follow-up questions based on what feels most important, then summarizes your motivation.',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (error.isNotEmpty) ...[
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _red,
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
          ],
          PrimaryButton(
            label: hasReflection ? 'Confirm Reflection' : 'Finish With AI',
            icon: Icons.arrow_forward_rounded,
            enabled: hasReflection && !loading,
            onPressed: () => _push(context, const PsychBaselineScreen()),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!coach.isConfigured) ...[
            const PrepInfoCard(
              icon: Icons.key_rounded,
              title: 'Live AI setup needed',
              body:
                  'Run Shellby with --dart-define=GEMINI_API_KEY=your_key to enable this chatbot. The key is not stored in source code.',
            ),
            const SizedBox(height: 14),
          ],
          AppCard(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 360,
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(14),
                itemCount: messages.length + (loading ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (loading && index == messages.length) {
                    return const ChatBubble(
                      fromUser: false,
                      text: 'Shellby is thinking...',
                      loading: true,
                    );
                  }
                  final message = messages[index];
                  return ChatBubble(
                    fromUser: message.fromUser,
                    text: message.text,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                chips
                    .map(
                      (chip) => ActionChip(
                        label: Text(chip),
                        onPressed: loading ? null : () => sendAnswer(chip),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: inputDecoration('Type your own answer...'),
                  onSubmitted: (_) => sendAnswer(),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: _brand,
                  fixedSize: const Size(54, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: loading ? null : () => sendAnswer(),
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ),
          if (hasReflection) ...[
            const SizedBox(height: 22),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What you told Shellby',
                    style: TextStyle(
                      color: _title,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.reflectedMotivation,
                    style: const TextStyle(
                      color: _body,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _firstQuestionFor(String concern) {
    return switch (concern) {
      'Building emergency savings' =>
        'What kind of unexpected expense are you most hoping your emergency fund can protect you from?',
      'Managing debt' =>
        'When you think about your debt, what feels most stressful right now: the amount, the due dates, or the uncertainty?',
      'Controlling spending' =>
        'Which spending moments feel hardest to control: social plans, online purchases, food, subscriptions, or something else?',
      'Starting investments' =>
        'What makes investing feel important now, and what makes you hesitate?',
      'Planning a big purchase' =>
        'What purchase are you preparing for, and why does it matter at this stage of your life?',
      'Reducing financial anxiety' =>
        'When does money anxiety show up most: checking balances, making decisions, comparing with others, or planning ahead?',
      'Comparing with peers' =>
        'What do you hope peer comparison will help you understand without making you feel pressured?',
      _ =>
        'What made you open Shellby now, even if you are not sure which financial goal to choose yet?',
    };
  }

  List<String> _chipsForConcern(String concern) {
    return switch (concern) {
      'Building emergency savings' => [
        'Medical or family emergencies',
        'Job uncertainty',
        'I want peace of mind',
      ],
      'Managing debt' => [
        'Due dates overwhelm me',
        'Interest worries me',
        'I want a payoff plan',
      ],
      'Controlling spending' => [
        'I keep overspending',
        'Social plans get expensive',
        'Subscriptions pile up',
      ],
      'Starting investments' => [
        'I want to start early',
        'I am scared to invest alone',
        'I need a safe first step',
      ],
      'Planning a big purchase' => [
        'I need a realistic timeline',
        'I do not want debt',
        'This purchase matters to my family',
      ],
      'Reducing financial anxiety' => [
        'I avoid checking balances',
        'Small losses stress me out',
        'I want to feel in control',
      ],
      'Comparing with peers' => [
        'I want to know what is normal',
        'I feel behind',
        'I want anonymous benchmarks',
      ],
      _ => [
        'I want stability',
        'I feel behind my peers',
        'Unexpected expenses scare me',
      ],
    };
  }
}

class PsychBaselineScreen extends StatelessWidget {
  const PsychBaselineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 5,
      title: 'Map your money mindset.',
      subtitle:
          'These scores help Shellby avoid advice that increases pressure or feels impossible to act on.',
      bottom: PrimaryButton(
        label: 'Add Financial Baseline',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const FinancialBaselineScreen()),
      ),
      child: Column(
        children: [
          ScoreSlider(
            title:
                'How confident do you feel making independent financial decisions?',
            left: 'Low',
            right: 'High',
            value: state.confidence,
            onChanged: state.updateConfidence,
          ),
          const SizedBox(height: 34),
          ScoreSlider(
            title: 'How anxious do you feel when checking your finances?',
            left: 'Calm',
            right: 'Anxious',
            value: state.anxiety,
            onChanged: state.updateAnxiety,
          ),
          const SizedBox(height: 34),
          ScoreSlider(
            title: 'How often do you avoid looking at your balances?',
            left: 'Rarely',
            right: 'Often',
            value: state.avoidance,
            onChanged: state.updateAvoidance,
          ),
          const SizedBox(height: 34),
          ScoreSlider(
            title:
                'How much do peers affect your spending or investing choices?',
            left: 'Little',
            right: 'A lot',
            value: state.peerPressure,
            onChanged: state.updatePeerPressure,
          ),
        ],
      ),
    );
  }
}

class FinancialBaselineScreen extends StatefulWidget {
  const FinancialBaselineScreen({super.key});

  @override
  State<FinancialBaselineScreen> createState() =>
      _FinancialBaselineScreenState();
}

class _FinancialBaselineScreenState extends State<FinancialBaselineScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 6,
      title: 'Quantify your baseline.',
      subtitle:
          'This prepares the Financial Pyramid Health Index and keeps goal recommendations grounded in cash flow.',
      bottom: PrimaryButton(
        label: 'Choose Tracking Variables',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const TrackingVariablesScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(index: 1, title: 'Cash Flow'),
          const SizedBox(height: 14),
          MoneyInput(
            label: 'Monthly net income',
            initial: state.income,
            onChanged: (value) => state.income = value,
          ),
          const SizedBox(height: 10),
          MoneyInput(
            label: 'Fixed monthly expenses',
            initial: state.expenses,
            onChanged: (value) => state.expenses = value,
          ),
          const SizedBox(height: 10),
          MoneyInput(
            label: 'Variable monthly expenses',
            initial: state.variableExpenses,
            onChanged: (value) => state.variableExpenses = value,
          ),
          const SizedBox(height: 10),
          MoneyInput(
            label: 'Monthly savings',
            initial: state.savings,
            onChanged: (value) => state.savings = value,
          ),
          const SizedBox(height: 28),
          SectionLabel(index: 2, title: 'Resilience'),
          const SizedBox(height: 14),
          ScoreSlider(
            title: 'How many months of expenses can your emergency fund cover?',
            left: '0',
            right: '10+',
            value: state.emergencyMonths.clamp(1, 10),
            onChanged: (value) => setState(() => state.emergencyMonths = value),
          ),
          const SizedBox(height: 20),
          MoneyInput(
            label: 'Monthly debt payments',
            initial: state.debtPayments,
            onChanged: (value) => state.debtPayments = value,
          ),
          const SizedBox(height: 10),
          MoneyInput(
            label: 'Investments',
            initial: state.investments,
            onChanged: (value) => state.investments = value,
          ),
          const SizedBox(height: 10),
          MoneyInput(
            label: 'Recurring subscriptions',
            initial: state.subscriptions,
            onChanged: (value) => state.subscriptions = value,
          ),
        ],
      ),
    );
  }
}

class TrackingVariablesScreen extends StatefulWidget {
  const TrackingVariablesScreen({super.key});

  @override
  State<TrackingVariablesScreen> createState() =>
      _TrackingVariablesScreenState();
}

class _TrackingVariablesScreenState extends State<TrackingVariablesScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final essential = [
      'Income',
      'Expenses',
      'Savings progress',
      'Assets and liabilities',
      'Debt payments',
      'Goal allocation',
    ];
    final interfering = [
      'Family obligations',
      'Irregular income',
      'Debt due dates',
      'Social spending pressure',
      'Emergency purchases',
      'Subscription creep',
    ];
    return OnboardingScaffold(
      phase: 7,
      title: 'Choose what Shellby tracks.',
      subtitle:
          'Preparation defines the variables before collection starts: what counts, what gets in the way, and what stays optional.',
      bottom: PrimaryButton(
        label: 'Draft Goals',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const GoalQuestionnaireScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(index: 1, title: 'Goal-related variables'),
          const SizedBox(height: 12),
          ...essential.map(
            (value) => ToggleRow(
              title: value,
              selected: state.trackingVariables.contains(value),
              onTap: () => setState(() => state.toggleTrackingVariable(value)),
            ),
          ),
          const SizedBox(height: 24),
          SectionLabel(index: 2, title: 'Interfering variables'),
          const SizedBox(height: 12),
          ...interfering.map(
            (value) => ToggleRow(
              title: value,
              selected: state.interferingVariables.contains(value),
              onTap:
                  () => setState(() => state.toggleInterferingVariable(value)),
            ),
          ),
        ],
      ),
    );
  }
}

class GoalQuestionnaireScreen extends StatefulWidget {
  const GoalQuestionnaireScreen({super.key});

  @override
  State<GoalQuestionnaireScreen> createState() =>
      _GoalQuestionnaireScreenState();
}

class _GoalQuestionnaireScreenState extends State<GoalQuestionnaireScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  final coach = const GeminiMotivationCoach();
  final List<ChatMessage> messages = [];
  bool seeded = false;
  bool loading = false;
  String error = '';

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (seeded) return;
    seeded = true;
    messages.add(
      const ChatMessage(
        false,
        'I drafted a first goal from your focus and reason. You can ask me to explain it or modify the target.',
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => generateGoal());
  }

  Future<void> generateGoal([String? prompt]) async {
    final state = AppScope.of(context);
    if (loading) return;
    setState(() {
      error = '';
      loading = true;
      if (prompt != null && prompt.trim().isNotEmpty) {
        messages.add(ChatMessage(true, prompt.trim()));
        controller.clear();
      }
    });
    _scrollToBottom();

    try {
      final result = await coach.recommendGoal(
        state: state,
        messages: messages,
      );
      if (!mounted) return;
      state.setRecommendedGoal(
        title: result.title,
        description: result.description,
        monthlyTarget: result.monthlyTarget,
      );
      setState(() {
        messages.add(ChatMessage(false, result.reply));
        loading = false;
      });
      _scrollToBottom();
    } on GeminiSetupException {
      if (!mounted) return;
      state.setRecommendedGoal(
        title: _fallbackTitle(state.primaryConcern),
        description: _fallbackDescription(state),
        monthlyTarget: state.requiredMonthlyContribution,
      );
      setState(() {
        loading = false;
        error =
            'Add a Gemini API key to generate and revise goals live: flutter run --dart-define=GEMINI_API_KEY=your_key';
        messages.add(
          const ChatMessage(
            false,
            'I created a local draft for now. With Gemini enabled, I can revise this goal conversationally.',
          ),
        );
      });
      _scrollToBottom();
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Goal AI failed. Check your connection, API key, or model.';
        messages.add(
          ChatMessage(
            false,
            'I had trouble revising the goal. You can try again. Details: $exception',
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final goals = [
      (
        'Emergency Shield',
        'Build a 3-month emergency buffer in the next 12 months.',
        Icons.shield_rounded,
      ),
      (
        'Debt Reset',
        'Reduce high-pressure debt while protecting basic cash flow.',
        Icons.credit_score_rounded,
      ),
      (
        'Investment Starter',
        'Create a first investing habit after savings and obligations are stable.',
        Icons.trending_up_rounded,
      ),
    ];
    return OnboardingScaffold(
      phase: 8,
      title: 'Specify a first goal.',
      subtitle:
          'Shellby uses your focus and reason to recommend one first goal. You can question it, modify it, or choose a common goal below.',
      bottom: PrimaryButton(
        label: 'Check Feasibility',
        icon: Icons.arrow_forward_rounded,
        enabled: !loading,
        onPressed: () => _push(context, const GoalFeasibilityScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconBubble(Icons.auto_awesome_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.selectedGoal,
                        style: const TextStyle(
                          color: _title,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  state.selectedGoalDescription,
                  style: const TextStyle(
                    color: _body,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                SummaryRow(
                  'Suggested monthly target',
                  money(state.requiredMonthlyContribution),
                ),
                SummaryRow('Based on', state.primaryConcern),
                SummaryRow(
                  'Reason',
                  state.motivation.isEmpty
                      ? 'Build a realistic financial plan.'
                      : state.motivation,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (error.isNotEmpty) ...[
            Text(
              error,
              style: const TextStyle(
                color: _red,
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
          ],
          AppCard(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 260,
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(14),
                itemCount: messages.length + (loading ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (loading && index == messages.length) {
                    return const ChatBubble(
                      fromUser: false,
                      text: 'Shellby is refining the goal...',
                      loading: true,
                    );
                  }
                  final message = messages[index];
                  return ChatBubble(
                    fromUser: message.fromUser,
                    text: message.text,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 3,
                  decoration: inputDecoration(
                    'Ask or modify: make it easier, faster, safer...',
                  ),
                  onSubmitted: generateGoal,
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: _brand,
                  fixedSize: const Size(54, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: loading ? null : () => generateGoal(controller.text),
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Other common goals',
            style: TextStyle(
              color: _title,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...goals.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SelectableOption(
                icon: goal.$3,
                title: goal.$1,
                body: goal.$2,
                selected: state.selectedGoal == goal.$1,
                onTap:
                    () => setState(
                      () => state.choosePresetGoal(goal.$1, goal.$2),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fallbackTitle(String concern) {
    return switch (concern) {
      'Managing debt' => 'Debt Reset',
      'Starting investments' => 'Investment Starter',
      'Controlling spending' => 'Spending Clarity Sprint',
      'Planning a big purchase' => 'Big Purchase Fund',
      'Reducing financial anxiety' => 'Calm Money Check-in',
      'Comparing with peers' => 'Peer Benchmark Baseline',
      _ => 'Emergency Shield',
    };
  }

  String _fallbackDescription(AppState state) {
    return 'Set aside ${money(state.requiredMonthlyContribution)} monthly toward ${state.primaryConcern.toLowerCase()} while keeping cash flow realistic.';
  }
}

class GoalFeasibilityScreen extends StatelessWidget {
  const GoalFeasibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final score = state.feasibilityScore.round();
    return OnboardingScaffold(
      phase: 9,
      title: 'Feasibility check.',
      subtitle:
          'A goal should be specific and challenging, but still realistic for your cash flow and confidence level.',
      centerTitle: true,
      bottom: PrimaryButton(
        label: 'Preview Health Index',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const PyramidPreviewScreen()),
      ),
      child: Column(
        children: [
          const Ghost(size: 104, mood: GhostMood.thinking),
          const SizedBox(height: 18),
          GoalCard(
            title: state.selectedGoal,
            description: state.selectedGoalDescription,
            progress: score,
            icon:
                state.selectedGoal == 'Debt Reset'
                    ? Icons.credit_score_rounded
                    : state.selectedGoal == 'Investment Starter'
                    ? Icons.trending_up_rounded
                    : Icons.shield_rounded,
            tag:
                score >= 75
                    ? 'Strong fit'
                    : score >= 50
                    ? 'Adjustable'
                    : 'Needs care',
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                SummaryRow('Monthly surplus', money(state.monthlySurplus)),
                SummaryRow(
                  'Required allocation',
                  money(state.requiredMonthlyContribution),
                ),
                SummaryRow(
                  'Savings rate',
                  '${state.savingsRate.toStringAsFixed(1)}%',
                ),
                SummaryRow(
                  'Debt-to-income',
                  '${state.debtToIncome.toStringAsFixed(1)}%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PyramidPreviewScreen extends StatelessWidget {
  const PyramidPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 10,
      title: 'Preview your OT2 index.',
      subtitle:
          'This is Shellby’s first read on your financial pyramid before regular tracking begins.',
      bottom: PrimaryButton(
        label: 'Set Privacy',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const ConsentPrivacyScreen()),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const FinancialPyramid(),
              Positioned(
                right: 0,
                top: -12,
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Health Score', style: sliderCaption),
                      Text(
                        '${state.healthScore.round()}',
                        style: const TextStyle(
                          color: _brand,
                          fontSize: 40,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              children: [
                SummaryRow(
                  'Sustenance',
                  '${state.savingsRate.toStringAsFixed(1)}% saved',
                ),
                SummaryRow(
                  'Protection',
                  '${state.emergencyMonths.toStringAsFixed(1)} months',
                ),
                SummaryRow(
                  'Borrowing pressure',
                  '${state.debtToIncome.toStringAsFixed(1)}% DTI',
                ),
                SummaryRow(
                  'Mindset',
                  'Confidence ${state.confidence.round()} / Anxiety ${state.anxiety.round()}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConsentPrivacyScreen extends StatefulWidget {
  const ConsentPrivacyScreen({super.key});

  @override
  State<ConsentPrivacyScreen> createState() => _ConsentPrivacyScreenState();
}

class _ConsentPrivacyScreenState extends State<ConsentPrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 11,
      title: 'Choose data permissions.',
      subtitle:
          'Consent is tied to your goal. Essential data powers your plan; optional data expands AI and cooperative features.',
      bottom: PrimaryButton(
        label: 'Choose Sharing Structure',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const SocialStructureScreen()),
      ),
      child: Column(
        children: [
          ConsentToggle(
            title: 'Financial baseline',
            body: 'Required for health score, feasibility, and goal tracking.',
            value: state.consentBaseline,
            locked: true,
            onChanged: (_) {},
          ),
          ConsentToggle(
            title: 'AI analysis',
            body:
                'Use your baseline and goal to generate plain-language nudges.',
            value: state.consentAi,
            onChanged: (value) => setState(() => state.consentAi = value),
          ),
          ConsentToggle(
            title: 'Anonymous peer benchmarks',
            body:
                'Compare against similar life-stage groups without showing identity.',
            value: state.consentBenchmarking,
            onChanged:
                (value) => setState(() => state.consentBenchmarking = value),
          ),
          ConsentToggle(
            title: 'Community feedback',
            body: 'Let Shellby use posts and votes with your selected context.',
            value: state.consentCommunity,
            onChanged:
                (value) => setState(() => state.consentCommunity = value),
          ),
          ConsentToggle(
            title: 'Trusted circle sharing',
            body:
                'Allow selected friends or collaborators to see chosen summaries.',
            value: state.consentTrustedCircle,
            onChanged:
                (value) => setState(() => state.consentTrustedCircle = value),
          ),
        ],
      ),
    );
  }
}

class SocialStructureScreen extends StatefulWidget {
  const SocialStructureScreen({super.key});

  @override
  State<SocialStructureScreen> createState() => _SocialStructureScreenState();
}

class _SocialStructureScreenState extends State<SocialStructureScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final options = [
      (
        'Private only',
        'Only you see your goals, score, and financial details.',
        Icons.lock_rounded,
      ),
      (
        'Anonymous peer benchmarks',
        'See percentiles and norms without exposing your identity.',
        Icons.groups_rounded,
      ),
      (
        'Trusted circle',
        'Share selected summaries with people you explicitly choose.',
        Icons.verified_user_rounded,
      ),
      (
        'Collaborative goal',
        'Prepare for shared goals, payment settling, or pooled contributions.',
        Icons.handshake_rounded,
      ),
    ];
    return OnboardingScaffold(
      phase: 12,
      title: 'Set the social boundary.',
      subtitle:
          'Cooperative finance only works when the sharing structure is explicit before tracking starts.',
      bottom: PrimaryButton(
        label: 'Review Preparation Contract',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const PreparationCommitmentScreen()),
      ),
      child: Column(
        children:
            options
                .map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SelectableOption(
                      icon: option.$3,
                      title: option.$1,
                      body: option.$2,
                      selected: state.socialStructure == option.$1,
                      onTap:
                          () =>
                              setState(() => state.socialStructure = option.$1),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

class PreparationCommitmentScreen extends StatelessWidget {
  const PreparationCommitmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 13,
      title: 'Your preparation contract.',
      subtitle:
          'Shellby reflects your own focus, goal, variables, consent, and sharing choices before collection begins.',
      bottom: PrimaryButton(
        label: 'Start First Tracking Step',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const FirstCollectionHandoffScreen()),
      ),
      child: Column(
        children: [
          AppCard(
            child: Column(
              children: [
                SummaryRow('Focus', state.primaryConcern),
                SummaryRow(
                  'Reason',
                  state.motivation.isEmpty
                      ? 'Build a realistic financial plan.'
                      : state.motivation,
                ),
                SummaryRow('Goal', state.selectedGoal),
                SummaryRow(
                  'Monthly allocation',
                  money(state.requiredMonthlyContribution),
                ),
                SummaryRow('Feasibility', '${state.feasibilityScore.round()}%'),
                SummaryRow('Tracking', state.trackingVariables.join(', ')),
                SummaryRow('Sharing', state.socialStructure),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const PrepInfoCard(
            icon: Icons.edit_rounded,
            title: 'Still adjustable',
            body:
                'Preparation is a contract you can revise. You can edit goals, privacy, and sharing later.',
          ),
        ],
      ),
    );
  }
}

class FirstCollectionHandoffScreen extends StatelessWidget {
  const FirstCollectionHandoffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final action =
        state.selectedGoal == 'Debt Reset'
            ? 'Add your next debt due date'
            : state.selectedGoal == 'Investment Starter'
            ? 'Record your first investment allocation'
            : 'Allocate your first emergency fund amount';
    return OnboardingScaffold(
      phase: 13,
      title: 'Begin collection.',
      subtitle:
          'The preparation stage is complete. Your first tracking action should directly support the goal you chose.',
      bottom: PrimaryButton(
        label: 'Enter Shellby',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _pushReplacement(context, const MainShell()),
      ),
      child: Column(
        children: [
          const Ghost(size: 96),
          const SizedBox(height: 18),
          PrepInfoCard(
            icon: Icons.playlist_add_check_rounded,
            title: action,
            body:
                'This handoff keeps collection connected to your goal instead of dropping you into a blank dashboard.',
          ),
          const SizedBox(height: 12),
          PrepInfoCard(
            icon: Icons.flag_rounded,
            title: state.selectedGoal,
            body:
                'Shellby will use your selected variables and consent choices to build feedback around this goal.',
          ),
        ],
      ),
    );
  }
}

class PersonalBaseline extends StatefulWidget {
  const PersonalBaseline({super.key});

  @override
  State<PersonalBaseline> createState() => _PersonalBaselineState();
}

class _PersonalBaselineState extends State<PersonalBaseline> {
  final occupationController = TextEditingController();

  @override
  void dispose() {
    occupationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final canContinue = state.age.isNotEmpty && state.occupation.isNotEmpty;
    return OnboardingScaffold(
      phase: 1,
      title: 'Establish your context.',
      subtitle:
          'We use this to compare your growth with anonymous peer benchmarking.',
      bottom: PrimaryButton(
        label: 'Continue',
        icon: Icons.arrow_forward_rounded,
        enabled: canContinue,
        onPressed: () => _push(context, const PsychTest()),
      ),
      child: Column(
        children: [
          LabeledField(
            label: 'Age & life stage',
            icon: Icons.calendar_today_rounded,
            child: DropdownButtonFormField<String>(
              value: state.age.isEmpty ? null : state.age,
              decoration: inputDecoration('Select your stage'),
              items: const [
                DropdownMenuItem(
                  value: 'Student',
                  child: Text('Student / Early Learner'),
                ),
                DropdownMenuItem(
                  value: 'Fresh Graduate',
                  child: Text('Fresh Graduate (20-25)'),
                ),
                DropdownMenuItem(
                  value: 'Early Career',
                  child: Text('Early Career (26-35)'),
                ),
                DropdownMenuItem(
                  value: 'Mid-Career',
                  child: Text('Mid-Career (36-50)'),
                ),
                DropdownMenuItem(
                  value: 'Senior Professional',
                  child: Text('Senior Professional (51+)'),
                ),
              ],
              onChanged: (value) => setState(() => state.age = value ?? ''),
            ),
          ),
          const SizedBox(height: 22),
          LabeledField(
            label: 'Occupation',
            icon: Icons.work_rounded,
            child: TextField(
              controller: occupationController,
              decoration: inputDecoration('e.g. Software Engineer').copyWith(
                prefixIcon: const Icon(Icons.search_rounded, color: _body),
              ),
              onChanged: (value) => setState(() => state.occupation = value),
            ),
          ),
          const SizedBox(height: 22),
          LabeledField(
            label: 'Industry',
            icon: Icons.business_center_rounded,
            child: DropdownButtonFormField<String>(
              value: state.industry,
              decoration: inputDecoration('Select your industry'),
              items:
                  const [
                    'Technology',
                    'Finance',
                    'Healthcare',
                    'Education',
                    'Business Services',
                    'Retail & E-commerce',
                    'Creative & Media',
                    'Government',
                    'Manufacturing',
                    'Hospitality',
                    'Freelance / Self-employed',
                    'Other',
                  ].map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
              onChanged:
                  (value) =>
                      setState(() => state.industry = value ?? state.industry),
            ),
          ),
          const SizedBox(height: 22),
          LabeledField(
            label: 'Location variable',
            icon: Icons.location_on_rounded,
            child: Row(
              children: [
                Expanded(
                  child: ChoiceTile(
                    label: 'Urban',
                    selected: state.location == 'Urban',
                    onTap: () => setState(() => state.location = 'Urban'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceTile(
                    label: 'Provincial',
                    selected: state.location == 'Provincial',
                    onTap: () => setState(() => state.location = 'Provincial'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PsychTest extends StatelessWidget {
  const PsychTest({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 2,
      title: 'How do you feel?',
      subtitle:
          'This establishes your baseline for decision confidence and financial anxiety.',
      bottom: PrimaryButton(
        label: 'Identify Goals',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const DiscoveryScreen()),
      ),
      child: Column(
        children: [
          ScoreSlider(
            title:
                'How confident do you feel making independent investment decisions?',
            left: 'Low confidence',
            right: 'Expert level',
            value: state.confidence,
            onChanged: state.updateConfidence,
          ),
          const SizedBox(height: 46),
          ScoreSlider(
            title:
                'How much anxiety do you feel when checking your bank balance?',
            left: 'No anxiety',
            right: 'High anxiety',
            value: state.anxiety,
            onChanged: state.updateAnxiety,
          ),
        ],
      ),
    );
  }
}

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void send() {
    AppScope.of(context).sendDiscoveryMessage(controller.text);
    controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final canFinish = state.messages.where((m) => m.fromUser).length >= 2;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              decoration: const BoxDecoration(
                color: _surface,
                border: Border(bottom: BorderSide(color: _border)),
              ),
              child: Column(
                children: [
                  PhaseHeader(phase: 3, total: 6),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconBubble(Icons.chat_bubble_rounded),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discovery Interview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: _title,
                            ),
                          ),
                          Text(
                            'AI narrative engine active',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: _body,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: state.messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final message = state.messages[index];
                  return Align(
                    alignment:
                        message.fromUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * .78,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: message.fromUser ? _brand : _surface,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            message.fromUser
                                ? null
                                : Border.all(color: _border),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: message.fromUser ? Colors.white : _title,
                          height: 1.35,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: _surface,
                border: Border(top: BorderSide(color: _border)),
              ),
              child:
                  canFinish
                      ? PrimaryButton(
                        label: 'Finish Discovery',
                        icon: Icons.arrow_forward_rounded,
                        onPressed:
                            () => _push(context, const QuantitativeScreen()),
                      )
                      : Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              decoration: inputDecoration(
                                'Type your answer...',
                              ),
                              onSubmitted: (_) => send(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: _brand,
                              fixedSize: const Size(54, 54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: send,
                            icon: const Icon(Icons.arrow_forward_rounded),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuantitativeScreen extends StatefulWidget {
  const QuantitativeScreen({super.key});

  @override
  State<QuantitativeScreen> createState() => _QuantitativeScreenState();
}

class _QuantitativeScreenState extends State<QuantitativeScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 4,
      title: 'Financial Scaffolding.',
      subtitle:
          'Quantify your economic standing for the financial pyramid health index.',
      bottom: PrimaryButton(
        label: 'Calculate Feasibility',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const FeasibilityScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(index: 1, title: 'Income & Expenses'),
          const SizedBox(height: 14),
          MoneyInput(
            label: 'Monthly net income',
            initial: state.income,
            onChanged: (value) => state.income = value,
          ),
          const SizedBox(height: 12),
          MoneyInput(
            label: 'Fixed monthly expenses',
            initial: state.expenses,
            onChanged: (value) => state.expenses = value,
          ),
          const SizedBox(height: 34),
          SectionLabel(index: 2, title: 'Assets & Liabilities'),
          const SizedBox(height: 16),
          ItemList(
            title: 'Assets',
            items: state.assets,
            onAdd: () => setState(state.addAsset),
          ),
          const SizedBox(height: 20),
          ItemList(
            title: 'Liabilities',
            items: state.liabilities,
            danger: true,
            onAdd: () => setState(state.addLiability),
          ),
        ],
      ),
    );
  }
}

class FeasibilityScreen extends StatelessWidget {
  const FeasibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      phase: 5,
      title: 'Sustainable Objectives',
      subtitle: 'Mathematically balanced for your current life cycle.',
      centerTitle: true,
      bottom: PrimaryButton(
        label: 'Confirm Primary Goal',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const OnboardingSummary()),
      ),
      child: Column(
        children: [
          const Ghost(size: 112, mood: GhostMood.thinking),
          const SizedBox(height: 18),
          const GoalCard(
            title: 'Emergency Shield',
            description:
                'Establish a 100,000 safety net with lower-risk monthly funding.',
            progress: 95,
            icon: Icons.shield_rounded,
            tag: 'Highly sustainable',
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Alternative Paths',
              style: TextStyle(
                color: _body,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            child: Row(
              children: [
                const IconBubble(
                  Icons.trending_up_rounded,
                  color: _amber,
                  background: _bellySoft,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aggressive Growth',
                        style: TextStyle(
                          color: _title,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '65% feasible - higher risk',
                        style: TextStyle(
                          color: _body,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: _body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSummary extends StatelessWidget {
  const OnboardingSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Row(
                children: [
                  BackButton(
                    color: _brand,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'OT2 Index',
                    style: TextStyle(
                      color: _brand,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Your Foundation',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Success! You have increased your perceived behavioral control.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _body, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 36),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const FinancialPyramid(),
                  Positioned(
                    right: 0,
                    top: -26,
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Health Score',
                            style: TextStyle(
                              color: _body,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            '${state.healthScore.round()}',
                            style: const TextStyle(
                              color: _brand,
                              fontSize: 42,
                              height: 1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Ghost(size: 70),
              const SizedBox(height: 30),
              const AppCard(
                child: Row(
                  children: [
                    IconBubble(Icons.flag_rounded),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Strategy Set',
                            style: TextStyle(
                              color: _title,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Sustainable emergency fund',
                            style: TextStyle(
                              color: _body,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: _green,
                      child: Icon(
                        Icons.arrow_outward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Start My Journey',
                onPressed: () => _pushReplacement(context, const MainShell()),
              ),
              const SizedBox(height: 16),
              const Text(
                'EMPOWERING YOUR LIFE STAGE WITH AI PRECISION.',
                style: TextStyle(
                  color: _body,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardPage(),
      const BudgetPage(),
      const GoalsPage(),
      const ProfilePage(),
    ];
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [const AppTopBar(), Expanded(child: pages[index])],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        backgroundColor: Colors.white.withValues(alpha: .96),
        indicatorColor: _brand.withValues(alpha: .11),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Budget',
          ),
          NavigationDestination(icon: Icon(Icons.flag_rounded), label: 'Goals'),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Felix!',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your financial health score is up by 4 points this month.',
                    style: TextStyle(
                      color: _body.withValues(alpha: .75),
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: _brand),
              onPressed: () {},
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 22),
        MetricCard(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Current Balance',
          value: money(24500.40),
          trend: '+12.5%',
          positive: true,
        ),
        const SizedBox(height: 12),
        MetricCard(
          icon: Icons.trending_up_rounded,
          label: 'Monthly Revenue',
          value: money(state.income),
          trend: '+8.2%',
          positive: true,
          color: _green,
        ),
        const SizedBox(height: 12),
        MetricCard(
          icon: Icons.credit_card_rounded,
          label: 'Total Expenses',
          value: money(state.expenses),
          trend: '-2.1%',
          positive: false,
          color: _red,
        ),
        const SizedBox(height: 22),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Net Worth Over Time',
                      style: TextStyle(
                        color: _title,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    'Last 6 Months',
                    style: TextStyle(
                      color: _body,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 210,
                child: LineChart(
                  values: const [45, 48, 46, 52, 58, 65],
                  labels: const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Active Goals',
          style: TextStyle(
            color: _title,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        const GoalCard(
          title: 'Emergency Fund',
          description: '3/6 months of expenses covered',
          progress: 52,
          icon: Icons.shield_rounded,
        ),
        const SizedBox(height: 12),
        const GoalCard(
          title: 'Tokyo 2026 trip',
          description: 'Saving for business class and hotel',
          progress: 28,
          icon: Icons.flight_rounded,
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _brand,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _brand.withValues(alpha: .18),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shellby Genius',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You could save an extra 120/mo by switching streaming subscriptions to a family plan.',
                style: TextStyle(
                  color: Colors.white70,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _brand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: const Text('See analysis'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle(title: 'Recent Transactions', action: 'View All'),
        const SizedBox(height: 12),
        const AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              TransactionRow(
                'Apple One Subscription',
                'Entertainment',
                'May 12, 2026',
                '-PHP 369.00',
                false,
              ),
              Divider(height: 1, color: _border),
              TransactionRow(
                'Spotify Premium',
                'Entertainment',
                'May 11, 2026',
                '-PHP 149.00',
                false,
              ),
              Divider(height: 1, color: _border),
              TransactionRow(
                'Stripe Payout',
                'Freelance',
                'May 10, 2026',
                '+PHP 1,450.00',
                true,
              ),
              Divider(height: 1, color: _border),
              TransactionRow(
                'Starbucks Coffee',
                'Food & Drink',
                'May 10, 2026',
                '-PHP 180.00',
                false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  bool assets = true;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final shown = assets ? state.assets : state.liabilities;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Your Items',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        Text(
          "Let's organize your assets and liabilities.",
          style: TextStyle(color: _body, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 22),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Assets')),
            ButtonSegment(value: false, label: Text('Liabilities')),
          ],
          selected: {assets},
          onSelectionChanged: (set) => setState(() => assets = set.first),
        ),
        const SizedBox(height: 24),
        SectionTitle(
          title: assets ? 'Your Assets' : 'Your Liabilities',
          action: money(assets ? state.totalAssets : state.totalLiabilities),
          danger: !assets,
        ),
        const SizedBox(height: 12),
        ...shown.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FinancialItemCard(
              item: item,
              danger: !assets,
              icon:
                  assets
                      ? Icons.account_balance_rounded
                      : Icons.credit_card_rounded,
            ),
          ),
        ),
        DashedAction(
          label: assets ? 'Add Asset' : 'Add Liability',
          onTap:
              assets
                  ? () => setState(state.addAsset)
                  : () => setState(state.addLiability),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: _brand,
            borderRadius: BorderRadius.circular(34),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'AI STRATEGY',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Review your summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "You're nearly there. Organizing these items helps us calculate your net worth precisely.",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _brand,
                ),
                onPressed: () {},
                child: const Text('Review Summary'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Goals',
          style: TextStyle(
            color: _title,
            fontSize: 34,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 18),
        GoalCard(
          title: 'Emergency Shield',
          description: 'Primary path selected during onboarding',
          progress: 95,
          icon: Icons.shield_rounded,
          tag: 'Primary',
        ),
        SizedBox(height: 12),
        GoalCard(
          title: 'Aggressive Growth',
          description: 'Alternative higher-risk route',
          progress: 65,
          icon: Icons.trending_up_rounded,
          tag: 'Explore',
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Profile', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: _bellySoft,
                child: Text(
                  'F',
                  style: TextStyle(
                    color: _brand,
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Felix',
                style: TextStyle(
                  color: _title,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                [
                  if (state.occupation.isNotEmpty) state.occupation,
                  state.industry,
                  if (state.age.isNotEmpty) state.age,
                  state.location,
                ].join(' - '),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _body,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: ProfileStat(
                      label: 'Confidence',
                      value: state.confidence.round().toString(),
                    ),
                  ),
                  Expanded(
                    child: ProfileStat(
                      label: 'Anxiety',
                      value: state.anxiety.round().toString(),
                    ),
                  ),
                  Expanded(
                    child: ProfileStat(
                      label: 'Health',
                      value: state.healthScore.round().toString(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PrepInfoCard extends StatelessWidget {
  const PrepInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBubble(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: _body,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SelectableOption extends StatelessWidget {
  const SelectableOption({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.body,
  });

  final IconData icon;
  final String title;
  final String? body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _bellySoft : _surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? _brand : _border, width: 2),
        ),
        child: Row(
          children: [
            IconBubble(
              icon,
              color: selected ? Colors.white : _brand,
              background: selected ? _brand : _bellySoft,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _title,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (body != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      body!,
                      style: const TextStyle(
                        color: _body,
                        height: 1.3,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? _brand : _body,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.fromUser,
    required this.text,
    this.loading = false,
  });

  final bool fromUser;
  final String text;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .72,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fromUser ? _brand : _bg,
          borderRadius: BorderRadius.circular(18),
          border: fromUser ? null : Border.all(color: _border),
        ),
        child:
            loading
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: fromUser ? Colors.white : _brand,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      text,
                      style: TextStyle(
                        color: fromUser ? Colors.white : _body,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
                : Text(
                  text,
                  style: TextStyle(
                    color: fromUser ? Colors.white : _title,
                    height: 1.32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
      ),
    );
  }
}

class CompactChoice extends StatelessWidget {
  const CompactChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _brand : _surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? _brand : _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _title,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? _brand : _border),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: selected ? _brand : _body,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _title,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConsentToggle extends StatelessWidget {
  const ConsentToggle({
    super.key,
    required this.title,
    required this.body,
    required this.value,
    required this.onChanged,
    this.locked = false,
  });

  final String title;
  final String body;
  final bool value;
  final bool locked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Row(
          children: [
            IconBubble(locked ? Icons.lock_rounded : Icons.tune_rounded),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _title,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: const TextStyle(
                      color: _body,
                      height: 1.25,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              activeColor: _brand,
              onChanged: locked ? null : onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _body, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _title,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.phase,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.bottom,
    this.centerTitle = false,
  });

  final int phase;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget bottom;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              PhaseHeader(phase: phase, total: 13),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                style: const TextStyle(
                  color: _body,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [child],
                ),
              ),
              const SizedBox(height: 18),
              bottom,
            ],
          ),
        ),
      ),
    );
  }
}

class PhaseHeader extends StatelessWidget {
  const PhaseHeader({super.key, required this.phase, required this.total});

  final int phase;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          color: _brand,
          icon: const Icon(Icons.chevron_left_rounded, size: 32),
        ),
        Expanded(child: StepProgress(current: phase, total: total)),
        const SizedBox(width: 14),
        Text(
          'Phase $phase/$total',
          style: const TextStyle(
            color: _body,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: current / total,
        minHeight: 7,
        backgroundColor: _bellySoft,
        color: _brand,
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: _brand,
          disabledBackgroundColor: _brand.withValues(alpha: .25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 10),
              Icon(icon, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .88),
        border: const Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _brand,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.layers_rounded, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text(
            'Shellby',
            style: TextStyle(
              color: _title,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: _body),
          ),
          const CircleAvatar(
            radius: 20,
            backgroundColor: _bellySoft,
            child: Text(
              'F',
              style: TextStyle(color: _brand, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.positive,
    this.color = _brand,
  });

  final IconData icon;
  final String label;
  final String value;
  final String trend;
  final bool positive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBubble(
                icon,
                color: color,
                background: color.withValues(alpha: .1),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (positive ? _green : _red).withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      positive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: positive ? _green : _red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        color: positive ? _green : _red,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(
              color: _title,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: _body,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.icon,
    this.tag,
  });

  final String title;
  final String description;
  final int progress;
  final IconData icon;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              IconBubble(icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: _title,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (tag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _bellySoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag!.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFB45309),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(
                        color: _body,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Text(
                'Current Confidence',
                style: TextStyle(
                  color: _body,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '$progress%',
                style: const TextStyle(
                  color: _brand,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress / 100,
              color: _brand,
              backgroundColor: _bellySoft,
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialItemCard extends StatelessWidget {
  const FinancialItemCard({
    super.key,
    required this.item,
    required this.icon,
    this.danger = false,
  });

  final MoneyItem item;
  final IconData icon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          IconBubble(
            icon,
            color: danger ? _red : _brand,
            background: danger ? const Color(0xFFFFEEF2) : _bellySoft,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: _title,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Text(
            money(item.value),
            style: const TextStyle(
              color: _title,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionRow extends StatelessWidget {
  const TransactionRow(
    this.name,
    this.category,
    this.date,
    this.amount,
    this.positive, {
    super.key,
  });

  final String name;
  final String category;
  final String date;
  final String amount;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconBubble(
            positive ? Icons.arrow_outward_rounded : Icons.south_east_rounded,
            color: positive ? _green : _red,
            background: (positive ? _green : _red).withValues(alpha: .1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: _title,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$category - $date',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: positive ? _green : _title,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class LineChart extends StatelessWidget {
  const LineChart({super.key, required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(values, labels),
      child: const SizedBox.expand(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter(this.values, this.labels);

  final List<double> values;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 36.0;
    const bottom = 28.0;
    const top = 16.0;
    final chartWidth = size.width - left - 8;
    final chartHeight = size.height - top - bottom;
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);

    final grid =
        Paint()
          ..color = _border
          ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = top + chartHeight * i / 3;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), grid);
    }

    Offset point(int i) {
      final x = left + chartWidth * i / (values.length - 1);
      final normalized = (values[i] - minValue) / (maxValue - minValue);
      final y = top + chartHeight * (1 - normalized);
      return Offset(x, y);
    }

    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(point(i).dx, point(i).dy);
    }

    final fill =
        Path.from(path)
          ..lineTo(point(values.length - 1).dx, top + chartHeight)
          ..lineTo(point(0).dx, top + chartHeight)
          ..close();
    canvas.drawPath(fill, Paint()..color = _brand.withValues(alpha: .07));
    canvas.drawPath(
      path,
      Paint()
        ..color = _brand
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(point(i), 4.5, Paint()..color = _brand);
      _drawText(
        canvas,
        labels[i],
        Offset(point(i).dx - 12, size.height - 18),
        10,
        _body,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    double size,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Ghost extends StatefulWidget {
  const Ghost({super.key, this.size = 120, this.mood = GhostMood.happy});

  final double size;
  final GhostMood mood;

  @override
  State<Ghost> createState() => _GhostState();
}

enum GhostMood { happy, thinking }

class _GhostState extends State<Ghost> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final lift = math.sin(controller.value * math.pi) * -8;
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 4,
                child: Transform.scale(
                  scale: 1 + controller.value * .18,
                  child: Container(
                    width: widget.size * .45,
                    height: widget.size * .08,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, lift),
                child: CustomPaint(
                  painter: _GhostPainter(widget.mood),
                  size: Size.square(widget.size * .88),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GhostPainter extends CustomPainter {
  _GhostPainter(this.mood);

  final GhostMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        size.width * .18,
        size.height * .14,
        size.width * .64,
        size.height * .68,
      ),
      topLeft: Radius.circular(size.width * .32),
      topRight: Radius.circular(size.width * .32),
      bottomLeft: Radius.circular(size.width * .07),
      bottomRight: Radius.circular(size.width * .07),
    );
    canvas.drawRRect(body, Paint()..color = _brand);
    canvas.drawRRect(
      body.inflate(size.width * .07),
      Paint()..color = _belly.withValues(alpha: .55),
    );
    final eye =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
    if (mood == GhostMood.thinking) {
      canvas.drawLine(
        Offset(size.width * .34, size.height * .38),
        Offset(size.width * .46, size.height * .38),
        eye,
      );
      canvas.drawLine(
        Offset(size.width * .58, size.height * .38),
        Offset(size.width * .70, size.height * .38),
        eye,
      );
    } else {
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width * .40, size.height * .38),
          radius: size.width * .06,
        ),
        math.pi,
        math.pi,
        false,
        eye,
      );
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width * .64, size.height * .38),
          radius: size.width * .06,
        ),
        math.pi,
        math.pi,
        false,
        eye,
      );
    }
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * .52, size.height * .54),
        width: size.width * .25,
        height: size.height * .16,
      ),
      0,
      math.pi,
      false,
      eye,
    );
  }

  @override
  bool shouldRepaint(covariant _GhostPainter oldDelegate) =>
      oldDelegate.mood != mood;
}

class FinancialPyramid extends StatelessWidget {
  const FinancialPyramid({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 78,
            height: 48,
            decoration: BoxDecoration(
              color: _brand,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Container(
            width: 190,
            height: 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _brand.withValues(alpha: .82),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'GROWTH',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 86,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _brand,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Text(
              'SECURITY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IconBubble extends StatelessWidget {
  const IconBubble(
    this.icon, {
    super.key,
    this.color = _brand,
    this.background = _bellySoft,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.action,
    this.danger = false,
  });

  final String title;
  final String action;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _title,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          action,
          style: TextStyle(
            color: danger ? _red : _brand,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.index, required this.title});

  final int index;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _brand,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$index',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: _title,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Row(
            children: [
              Icon(icon, color: _brand, size: 15),
              const SizedBox(width: 7),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: _title,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _surface : _bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _brand : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _brand : _body,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class ScoreSlider extends StatelessWidget {
  const ScoreSlider({
    super.key,
    required this.title,
    required this.left,
    required this.right,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String left;
  final String right;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: _title,
                  fontSize: 18,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              value.round().toString(),
              style: const TextStyle(
                color: _brand,
                fontSize: 42,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        Slider(
          min: 1,
          max: 10,
          divisions: 9,
          value: value,
          activeColor: _brand,
          inactiveColor: _bellySoft,
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(left.toUpperCase(), style: sliderCaption),
            Text(right.toUpperCase(), style: sliderCaption),
          ],
        ),
      ],
    );
  }
}

const sliderCaption = TextStyle(
  color: _body,
  fontSize: 10,
  fontWeight: FontWeight.w900,
  letterSpacing: 1,
);

class MoneyInput extends StatelessWidget {
  const MoneyInput({
    super.key,
    required this.label,
    required this.initial,
    required this.onChanged,
  });

  final String label;
  final double initial;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial.toStringAsFixed(0),
      keyboardType: TextInputType.number,
      decoration: inputDecoration(
        label,
      ).copyWith(prefixIcon: const Icon(Icons.payments_rounded, color: _body)),
      onChanged: (value) => onChanged(double.tryParse(value) ?? 0),
    );
  }
}

class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
    required this.title,
    required this.items,
    required this.onAdd,
    this.danger = false,
  });

  final String title;
  final List<MoneyItem> items;
  final VoidCallback onAdd;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: sliderCaption),
        const SizedBox(height: 10),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FinancialItemCard(
              item: item,
              danger: danger,
              icon: danger ? Icons.credit_card_rounded : Icons.savings_rounded,
            ),
          ),
        ),
        DashedAction(
          label: danger ? 'Add Liability' : 'Add Asset',
          onTap: onAdd,
          danger: danger,
        ),
      ],
    );
  }
}

class DashedAction extends StatelessWidget {
  const DashedAction({
    super.key,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? _red : _brand;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  const ProfileStat({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: _brand,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: _body,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

InputDecoration inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _brand, width: 2),
    ),
  );
}

String money(double value) {
  final rounded = value.toStringAsFixed(2);
  final parts = rounded.split('.');
  final chars = parts.first.split('').reversed.toList();
  final grouped = <String>[];
  for (var i = 0; i < chars.length; i++) {
    if (i != 0 && i % 3 == 0) grouped.add(',');
    grouped.add(chars[i]);
  }
  return 'PHP ${grouped.reversed.join()}.${parts.last}';
}

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}

void _pushReplacement(BuildContext context, Widget page) {
  Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (_) => page));
}
