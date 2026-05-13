import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const AheadApp());
}

const _brand = Color(0xFF4F00CF);
const _bg = Color(0xFFF7F7FB);
const _surface = Colors.white;
const _title = Color(0xFF201B2E);
const _body = Color(0xFF6F687C);
const _border = Color(0xFFE8E5EE);
const _green = Color(0xFF10B981);
const _red = Color(0xFFF43F5E);
const _amber = Color(0xFFF59E0B);

class AheadApp extends StatefulWidget {
  const AheadApp({super.key});

  @override
  State<AheadApp> createState() => _AheadAppState();
}

class _AheadAppState extends State<AheadApp> {
  final state = AppState();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Ahead',
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
  String location = 'Urban';
  double confidence = 5;
  double anxiety = 5;
  double income = 8240;
  double expenses = 3120.5;
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
      "I'm Ahead. If you could achieve one milestone in the next 12 months, what would it be?",
    ),
  ];

  double get totalAssets => assets.fold(0, (sum, item) => sum + item.value);
  double get totalLiabilities =>
      liabilities.fold(0, (sum, item) => sum + item.value);
  double get netWorth => totalAssets - totalLiabilities + 24500.40;
  double get healthScore =>
      (60 + confidence * 2.4 - anxiety * 0.8 + (location == 'Urban' ? 2 : 4))
          .clamp(0, 100);

  void updateConfidence(double value) {
    confidence = value;
    notifyListeners();
  }

  void updateAnxiety(double value) {
    anxiety = value;
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
                  color: const Color(0xFFF2EAFF),
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
                "Welcome! Let's personalize Ahead for you!",
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
                onPressed: () => _push(context, const PersonalBaseline()),
              ),
            ],
          ),
        ),
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
                  background: Color(0xFFFFF7E6),
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
                'Ahead Genius',
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
                '-\$32.95',
                false,
              ),
              Divider(height: 1, color: _border),
              TransactionRow(
                'Spotify Premium',
                'Entertainment',
                'May 11, 2026',
                '-\$10.99',
                false,
              ),
              Divider(height: 1, color: _border),
              TransactionRow(
                'Stripe Payout',
                'Freelance',
                'May 10, 2026',
                '+\$1,450.00',
                true,
              ),
              Divider(height: 1, color: _border),
              TransactionRow(
                'Starbucks Coffee',
                'Food & Drink',
                'May 10, 2026',
                '-\$6.50',
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
                backgroundColor: Color(0xFFEFE7FF),
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
              PhaseHeader(phase: phase, total: 6),
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
        backgroundColor: const Color(0xFFEDEAF3),
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
            'Ahead',
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
            backgroundColor: Color(0xFFF0EEF5),
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
                              color: const Color(0xFFFFF7E6),
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
              backgroundColor: const Color(0xFFEFEAF6),
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
            background:
                danger ? const Color(0xFFFFEEF2) : _brand.withValues(alpha: .1),
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
    canvas.drawRRect(body, Paint()..color = const Color(0xFF8B5CF6));
    canvas.drawRRect(
      body.inflate(size.width * .07),
      Paint()..color = const Color(0x338B5CF6),
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
    this.background = const Color(0xFFEFE7FF),
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
          color: selected ? Colors.white : const Color(0xFFEFEFF5),
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
          inactiveColor: const Color(0xFFE1DDE8),
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
      decoration: inputDecoration(label).copyWith(
        prefixIcon: const Icon(Icons.attach_money_rounded, color: _body),
      ),
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
  return '\$${grouped.reversed.join()}.${parts.last}';
}

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}

void _pushReplacement(BuildContext context, Widget page) {
  Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (_) => page));
}
