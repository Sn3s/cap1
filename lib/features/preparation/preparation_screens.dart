part of '../../main.dart';

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
      _push(context, const FinancialConcernScreen());
      return;
    }
    controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  static const _slides = [
    OrientationSlideData(
      icon: Icons.flag_rounded,
      title: 'Shelby helps you develop healthier financial habits.',
      body:
          'He helps in making goals more attainable and handling money less stressful.',
      accent: _brand,
    ),
    OrientationSlideData(
      icon: Icons.insights_rounded,
      title: 'It looks for useful patterns.',
      body:
          'Shelby can help notice spending rhythms, savings gaps, debt pressure, and moments that affect your choices.',
      accent: _purple,
    ),
    OrientationSlideData(
      icon: Icons.lightbulb_rounded,
      title: 'It shares gentle ideas.',
      body:
          'You may get simple prompts, goal ideas, and check-in suggestions that support the focus you choose.',
      accent: _amber,
    ),
    OrientationSlideData(
      icon: Icons.lock_rounded,
      title: 'You stay in control.',
      body:
          'Shelby is not a bank, broker, or financial adviser. It will not move money, change device settings, read files, or collect data you do not approve.',
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
                    onPressed: () =>
                        _push(context, const FinancialConcernScreen()),
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
                  itemBuilder: (context, slideIndex) =>
                      OrientationSlide(data: _slides[slideIndex]),
                ),
              ),
              OrientationDots(count: _slides.length, index: index),
              const SizedBox(height: 24),
              PrimaryButton(
                label: isLast ? 'Choose Focus' : 'Continue',
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
              color: data.accent.withOpacity(.12),
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
            color: Colors.black.withOpacity(.05),
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

class GoalBranch {
  const GoalBranch({
    required this.layer,
    required this.layerDescription,
    required this.firstQuestion,
    required this.icon,
    required this.defaultGoalTitle,
    required this.defaultGoalDescription,
    required this.concerns,
  });

  final String layer;
  final String layerDescription;
  final String firstQuestion;
  final IconData icon;
  final String defaultGoalTitle;
  final String defaultGoalDescription;
  final List<GoalConcern> concerns;

  GoalConcern closestConcern(String answer) {
    final normalized = answer.toLowerCase();
    GoalConcern best = concerns.first;
    var bestScore = -1;
    for (final concern in concerns) {
      final score = concern.keywords
          .where((keyword) => normalized.contains(keyword))
          .length;
      if (score > bestScore) {
        best = concern;
        bestScore = score;
      }
    }
    return best;
  }
}

class GoalConcern {
  const GoalConcern({
    required this.feltNeed,
    required this.followUp,
    required this.goalTitle,
    required this.goalDescription,
    required this.keywords,
    required this.actionIds,
    required this.backgroundEffect,
    this.enableEmotionalLogs = false,
    this.enableStressIndicators = false,
  });

  final String feltNeed;
  final String followUp;
  final String goalTitle;
  final String goalDescription;
  final List<String> keywords;
  final List<String> actionIds;
  final String backgroundEffect;
  final bool enableEmotionalLogs;
  final bool enableStressIndicators;
}

const _goalBranches = [
  GoalBranch(
    layer: 'Cash Flow & Basic Needs',
    layerDescription:
        'Get clear on income, spending, bills, and what has to be covered each month.',
    firstQuestion: 'What is your biggest struggle with day-to-day spending?',
    icon: Icons.account_balance_wallet_rounded,
    defaultGoalTitle: 'Cash Flow Stability Plan',
    defaultGoalDescription:
        'Map income, fixed costs, and spending patterns so your monthly budget has a clear baseline.',
    concerns: [
      GoalConcern(
        feltNeed: 'I just forget to track my expenses.',
        followUp:
            'How often would tracking feel realistic for you: daily, weekly, or every payday?',
        goalTitle: 'Expense Tracking Routine',
        goalDescription:
            'Set up a simple expense tracking routine with reminders matched to your check-in rhythm.',
        keywords: ['forget', 'track', 'expense', 'logging', 'reminder'],
        actionIds: ['ACT3'],
        backgroundEffect:
            'Activates ACT3 tracking and sets up reminders based on the user check-in rhythm.',
      ),
      GoalConcern(
        feltNeed: 'I buy things impulsively when I am stressed or bored.',
        followUp:
            'What usually comes right before the impulse purchase: stress, boredom, social pressure, ads, or wanting a quick reward?',
        goalTitle: 'Emotional Spending Log',
        goalDescription:
            'Track spending alongside mood tags so Shelby can spot emotional spending patterns.',
        keywords: ['impulse', 'stress', 'bored', 'emotion', 'trigger'],
        actionIds: ['ACT3', 'ACT5'],
        backgroundEffect:
            'Activates ACT3 tracking and ACT5 emotional logs for spending-trigger insights.',
        enableEmotionalLogs: true,
      ),
      GoalConcern(
        feltNeed: 'My income changes every month, making it hard to plan.',
        followUp:
            'In a low-income month, what amount can you usually rely on, and which bills must be protected first?',
        goalTitle: 'Irregular Income Buffer',
        goalDescription:
            'Create a hill-and-valley budget that plans from lower-income months instead of a fixed average.',
        keywords: ['income', 'changes', 'irregular', 'variable', 'freelance'],
        actionIds: ['ACT6'],
        backgroundEffect:
            'Activates ACT6 plan adjustments and switches the budget formula for irregular income.',
      ),
    ],
  ),
  GoalBranch(
    layer: 'Financial Safety',
    layerDescription:
        'Build protection against surprise expenses, bill panic, and dipping into emergency money.',
    firstQuestion: 'What stops you from keeping an emergency fund?',
    icon: Icons.shield_rounded,
    defaultGoalTitle: 'Emergency Cushion',
    defaultGoalDescription:
        'Build a practical safety buffer sized around your real bills and essential living costs.',
    concerns: [
      GoalConcern(
        feltNeed: 'I always end up spending my savings on regular things.',
        followUp:
            'When you dip into savings, is it usually for bills, groceries, social plans, emergencies, or impulse purchases?',
        goalTitle: 'Safety Shield Boundary',
        goalDescription:
            'Ring-fence emergency savings and add alerts when regular spending starts pulling from it.',
        keywords: ['spending', 'savings', 'regular', 'dip', 'withdraw'],
        actionIds: ['ACT2'],
        backgroundEffect:
            'Activates ACT2 goal boundaries and warning prompts for emergency fund withdrawals.',
      ),
      GoalConcern(
        feltNeed: 'Unexpected bills constantly surprise and stress me out.',
        followUp:
            'Which bills create the most panic, and are they hard because of timing, amount, or surprise charges?',
        goalTitle: 'Bill Calm Buffer',
        goalDescription:
            'Build a chronological bill buffer that lowers anxiety around upcoming due dates.',
        keywords: ['bill', 'panic', 'stress', 'surprise', 'unexpected'],
        actionIds: ['ACT5'],
        backgroundEffect:
            'Activates ACT5 insights and the financial anxiety score tracker.',
        enableStressIndicators: true,
      ),
      GoalConcern(
        feltNeed: 'I want to save, but I struggle to do it consistently.',
        followUp:
            'Would an automatic savings rule feel better as a percentage of payday income or a fixed peso amount?',
        goalTitle: 'Payday Safety Sweep',
        goalDescription:
            'Set up a payday savings rule that builds the emergency cushion before the money blends into spending.',
        keywords: ['save', 'consistent', 'struggle', 'automatic', 'payday'],
        actionIds: ['ACT2'],
        backgroundEffect:
            'Activates ACT2 goal targets and suggests an automatic savings percentage every payday.',
      ),
    ],
  ),
  GoalBranch(
    layer: 'Accumulating Wealth',
    layerDescription:
        'Move from staying afloat to reducing debt, saving consistently, and starting long-term growth.',
    firstQuestion: 'Where should the app focus to help grow your wealth?',
    icon: Icons.trending_up_rounded,
    defaultGoalTitle: 'Net Worth Growth Plan',
    defaultGoalDescription:
        'Balance debt reduction, regular saving, and starter investing into one trackable plan.',
    concerns: [
      GoalConcern(
        feltNeed: 'I need a clear plan to aggressively pay off my debts.',
        followUp:
            'Which debt should Shelby look at first, and do you care more about lowering interest, monthly pressure, or total payoff time?',
        goalTitle: 'Debt Payoff Map',
        goalDescription:
            'Map a debt snowball or avalanche path so balances start moving in a visible direction.',
        keywords: ['debt', 'pay', 'payoff', 'aggressive', 'loan'],
        actionIds: ['ACT2'],
        backgroundEffect:
            'Activates ACT2 goal targets and the debt repayment target calculator.',
      ),
      GoalConcern(
        feltNeed: 'I want to invest, but I am afraid of losing money.',
        followUp:
            'What would make investing feel safer: learning first, starting tiny, seeing simulations, or avoiding volatile choices?',
        goalTitle: 'Starter Investing Confidence',
        goalDescription:
            'Pair a risk comfort check with a conservative first investing habit and simple growth simulation.',
        keywords: ['invest', 'market', 'risk', 'afraid', 'losing'],
        actionIds: ['ACT5'],
        backgroundEffect:
            'Activates ACT5 insights and triggers a risk tolerance questionnaire path.',
      ),
      GoalConcern(
        feltNeed: 'I tend to spend more money whenever I get a raise.',
        followUp:
            'When your income rises, what grows first: rent, subscriptions, shopping, eating out, travel, or family support?',
        goalTitle: 'Lifestyle Creep Monitor',
        goalDescription:
            'Monitor fixed expenses and spending creep when income changes so wealth gains do not disappear.',
        keywords: ['raise', 'spend more', 'income', 'lifestyle', 'creep'],
        actionIds: ['ACT6'],
        backgroundEffect:
            'Activates ACT6 adjustments and monitors fixed expenses to prevent lifestyle inflation.',
      ),
    ],
  ),
  GoalBranch(
    layer: 'Financial Freedom',
    layerDescription:
        'Plan future milestones, shared goals, and guilt-free experiences without weakening your foundation.',
    firstQuestion: 'How do you want to save for your big life milestones?',
    icon: Icons.flag_rounded,
    defaultGoalTitle: 'Future Lifestyle Fund',
    defaultGoalDescription:
        'Create milestone buckets for meaningful plans while protecting essential money and safety buffers.',
    concerns: [
      GoalConcern(
        feltNeed:
            'I am trying to save for multiple big things at the same time.',
        followUp:
            'Which milestone should come first: home, wedding, school, family support, travel, business, or something else?',
        goalTitle: 'Milestone Bucket Plan',
        goalDescription:
            'Separate big goals into trackable buckets with target amounts, dates, and monthly contributions.',
        keywords: ['multiple', 'big', 'home', 'wedding', 'school'],
        actionIds: ['ACT2'],
        backgroundEffect:
            'Activates ACT2 goal targets and creates independent savings buckets with separate target dates.',
      ),
      GoalConcern(
        feltNeed: 'I am saving for these milestones together with a partner.',
        followUp:
            'What do you need to align on first: target amount, timeline, contribution split, privacy, or spending priorities?',
        goalTitle: 'Shared Future Alignment',
        goalDescription:
            'Prepare a collaborative goal with clear visibility, permissions, and shared progress tracking.',
        keywords: ['partner', 'together', 'shared', 'align', 'collaborate'],
        actionIds: ['ACT4'],
        backgroundEffect:
            'Activates ACT4 collaboration and opens account sharing options with privacy controls.',
      ),
      GoalConcern(
        feltNeed:
            'I want to spend money on travel and hobbies without feeling guilty.',
        followUp:
            'What kind of experience would you like to enjoy without guilt, and how often would feel reasonable?',
        goalTitle: 'Guilt-Free Experience Fund',
        goalDescription:
            'Set aside a clear experience fund so joy spending is planned, visible, and separate from essentials.',
        keywords: ['travel', 'hobby', 'guilty', 'fun', 'spend'],
        actionIds: ['ACT5'],
        backgroundEffect:
            'Activates ACT5 insights and calculates how much fun money is safe to spend.',
      ),
    ],
  ),
];

GoalBranch _branchForLayer(String layer) {
  return _goalBranches.firstWhere(
    (branch) => branch.layer == layer,
    orElse: () => _goalBranches.first,
  );
}

double _monthlyTargetForConcern(AppState state, GoalConcern concern) {
  return switch (concern.goalTitle) {
    'Expense Tracking Routine' => 0,
    'Irregular Income Buffer' => math.max(500, state.expenses * .15),
    'Emotional Spending Log' => 0,
    'Buffer Duration Goal' => math.max(500, state.expenses / 6),
    'Bill Calm Buffer' => math.max(300, state.expenses * .1),
    'Safety Shield Boundary' => math.max(500, state.expenses / 6),
    'Payday Safety Sweep' => math.max(500, state.expenses / 6),
    'Debt Payoff Map' => math.max(400, state.debtPayments * .8),
    'Starter Investing Confidence' => math.max(500, state.income * .08),
    'Lifestyle Creep Monitor' => 0,
    'Milestone Bucket Plan' => math.max(500, state.income * .1),
    'Guilt-Free Experience Fund' => math.max(300, state.income * .05),
    'Shared Future Alignment' => math.max(500, state.income * .08),
    _ => 0,
  };
}

String _reflectionForConcern(GoalConcern concern, String detail) {
  final trimmed = detail.trim();
  final extra = trimmed.isEmpty ? '' : ' You added: "$trimmed"';
  return '${concern.goalDescription} Shelby will start with ${concern.goalTitle.toLowerCase()} because it is specific, trackable, and realistic to configure in the app. ${concern.backgroundEffect}$extra';
}

class PreparationContextScreen extends StatefulWidget {
  const PreparationContextScreen({super.key});

  @override
  State<PreparationContextScreen> createState() =>
      _PreparationContextScreenState();
}

class _PreparationContextScreenState extends State<PreparationContextScreen> {
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final canContinue = state.name.isNotEmpty;
    return OnboardingScaffold(
      phase: 1,
      title: 'Let Shelby know you.',
      subtitle: "Let's start with your name!",
      bottom: PrimaryButton(
        label: 'Continue',
        icon: Icons.arrow_forward_rounded,
        enabled: canContinue,
        onPressed: () => _push(context, const PreparationCredentialsScreen()),
      ),
      child: Column(
        children: [
          LabeledField(
            label: 'Name',
            icon: Icons.person_rounded,
            child: TextField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: inputDecoration('What should Shelby call you?'),
              onChanged: (value) => setState(() => state.name = value.trim()),
            ),
          ),
        ],
      ),
    );
  }
}

class PreparationCredentialsScreen extends StatefulWidget {
  const PreparationCredentialsScreen({super.key});

  @override
  State<PreparationCredentialsScreen> createState() =>
      _PreparationCredentialsScreenState();
}

class _PreparationCredentialsScreenState
    extends State<PreparationCredentialsScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _runAuth(Future<void> Function(AppState state) action) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final state = AppScope.of(context);
      await action(state);
      if (!mounted) return;
      _push(context, const LifeContextScreen());
    } catch (error) {
      if (!mounted) return;
      _showAuthError(context, error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      phase: 1,
      title: 'Create your account.',
      subtitle:
          'Use email and password or continue with Google so Shelby can save your profile.',
      bottom: const SizedBox.shrink(),
      child: Column(
        children: [
          LabeledField(
            label: 'Email',
            icon: Icons.mail_rounded,
            child: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: inputDecoration('you@example.com'),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Password',
            icon: Icons.lock_rounded,
            child: TextField(
              controller: passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: inputDecoration('At least 6 characters'),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Create account',
            icon: Icons.person_add_alt_1_rounded,
            enabled: !busy,
            onPressed: () => _runAuth(
              (state) => state.createAccountWithEmail(
                email: emailController.text,
                password: passwordController.text,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _LoginDivider(),
          const SizedBox(height: 18),
          GoogleSignInButton(
            busy: busy,
            onPressed: () => _runAuth(
              (state) => state.signInWithGoogle(
                saveAfterSignIn: false,
                forceFreshGoogleSession: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LifeContextScreen extends StatefulWidget {
  const LifeContextScreen({super.key});

  @override
  State<LifeContextScreen> createState() => _LifeContextScreenState();
}

class _LifeContextScreenState extends State<LifeContextScreen> {
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
      title: 'What are you doing now?',
      subtitle:
          'Your work and life stage shape what feels doable. Shelby uses this to keep suggestions grounded in your real world.',
      bottom: PrimaryButton(
        label: 'Map Money Rhythm',
        icon: Icons.arrow_forward_rounded,
        enabled: canContinue,
        onPressed: () => _push(context, const LifeRhythmScreen()),
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
              items: const [
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
              onChanged: (value) =>
                  setState(() => state.industry = value ?? state.industry),
            ),
          ),
        ],
      ),
    );
  }
}

class LifeRhythmScreen extends StatefulWidget {
  const LifeRhythmScreen({super.key});

  @override
  State<LifeRhythmScreen> createState() => _LifeRhythmScreenState();
}

class _LifeRhythmScreenState extends State<LifeRhythmScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 3,
      title: 'How does money move for you?',
      subtitle:
          'Paydays, bills, shared responsibilities, and check-in habits all shape what Shelby should pay attention to.',
      bottom: PrimaryButton(
        label: 'See How Shelby Helps',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const PreparationOrientScreen()),
      ),
      child: Column(
        children: [
          LabeledField(
            label: 'Employment status',
            icon: Icons.badge_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['Full-time', 'Freelance', 'Contract', 'Mixed']
                  .map(
                    (value) => CompactChoice(
                      label: value,
                      selected: state.employmentStatus == value,
                      onTap: () => setState(
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
            label: 'Income rhythm',
            icon: Icons.event_repeat_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['Weekly', 'Twice a month', 'Monthly', 'Irregular']
                  .map(
                    (value) => CompactChoice(
                      label: value,
                      selected: state.incomeRhythm == value,
                      onTap: () => setState(() => state.incomeRhythm = value),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Bills rhythm',
            icon: Icons.receipt_long_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                'Predictable dates',
                'Scattered dates',
                'Mostly automatic',
                'Often surprise me',
              ]
                  .map(
                    (value) => CompactChoice(
                      label: value,
                      selected: state.billsRhythm == value,
                      onTap: () => setState(() => state.billsRhythm = value),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Financial responsibility',
            icon: Icons.family_restroom_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['Mostly myself', 'Family support', 'Shared household']
                  .map(
                    (value) => CompactChoice(
                      label: value,
                      selected: state.responsibility == value,
                      onTap: () => setState(() => state.responsibility = value),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Money check-in rhythm',
            icon: Icons.fact_check_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['Daily', 'Weekly', 'Monthly', 'Only when needed']
                  .map(
                    (value) => CompactChoice(
                      label: value,
                      selected: state.checkInRhythm == value,
                      onTap: () => setState(() => state.checkInRhythm = value),
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
    return OnboardingScaffold(
      phase: 4,
      title: 'What brought you here today?',
      subtitle:
          'Choose the layer that best matches what you want Shelby to help with first.',
      bottom: PrimaryButton(
        label: 'Tell Shelby Why',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const MotivationSurfaceScreen()),
      ),
      child: Column(
        children: _goalBranches
            .map(
              (branch) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SelectableOption(
                  icon: branch.icon,
                  title: branch.layer,
                  body: branch.layerDescription,
                  selected: state.primaryConcern == branch.layer,
                  onTap: () => setState(() {
                    state.primaryConcern = branch.layer;
                    state.choosePresetGoal(
                      branch.defaultGoalTitle,
                      branch.defaultGoalDescription,
                    );
                  }),
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
  final coach = const ShellbyAiCoach();
  final List<ChatMessage> messages = [];
  bool seeded = false;
  bool loading = false;
  String error = '';
  GoalBranch? activeBranch;
  GoalConcern? activeConcern;
  int detailAnswerCount = 0;

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
    activeBranch = _branchForLayer(concern);
    messages.add(ChatMessage(false, activeBranch!.firstQuestion));
    seeded = true;
  }

  Future<void> sendAnswer([String? value]) async {
    final state = AppScope.of(context);
    final answer = (value ?? controller.text).trim();
    if (answer.isEmpty || loading) return;

    setState(() {
      error = '';
      messages.add(ChatMessage(true, answer));
      controller.clear();
    });
    _scrollToBottom();

    final branch = activeBranch ?? _branchForLayer(state.primaryConcern);
    final concern = activeConcern ?? branch.closestConcern(answer);
    activeConcern = concern;

    if (value != null || detailAnswerCount == 0) {
      detailAnswerCount = 1;
      state.setRecommendedGoal(
        title: concern.goalTitle,
        description: concern.goalDescription,
        monthlyTarget: _monthlyTargetForConcern(state, concern),
      );
      state.configureGoalActions(
        actionIds: concern.actionIds,
        enableEmotionalLogs: concern.enableEmotionalLogs,
        enableStressIndicators: concern.enableStressIndicators,
      );
      setState(() {
        messages.add(ChatMessage(false, concern.followUp));
      });
      _scrollToBottom();
      return;
    }

    detailAnswerCount += 1;
    final summary = _reflectionForConcern(concern, answer);
    state.setMotivation(summary);
    setState(() {
      messages.add(ChatMessage(false, summary));
    });
    _scrollToBottom();
  }

  Future<void> sendAiAnswer(String answer) async {
    final state = AppScope.of(context);
    setState(() {
      loading = true;
    });

    try {
      final userAnswerCount =
          messages.where((message) => message.fromUser).length;
      final shouldSummarize = userAnswerCount >= 3 ||
          (userAnswerCount >= 2 && _acceptsSuggestedDirection(answer));
      final result = await coach.send(
        concern: state.primaryConcern,
        messages: messages,
        userAnswerCount: userAnswerCount,
        shouldSummarize: shouldSummarize,
        requiredFollowUp: shouldSummarize
            ? null
            : _nextGoalDiscoveryQuestion(
                state.primaryConcern,
                userAnswerCount,
              ),
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
    } on AiSetupException {
      if (!mounted) return;
      setState(() {
        loading = false;
        error =
            'Configure AI with Ollama or Gemini. For Ollama: ollama serve, then flutter run --dart-define=AI_PROVIDER=ollama';
        messages.add(
          const ChatMessage(
            false,
            'I can guide this conversation once the AI provider is reachable.',
          ),
        );
      });
      _scrollToBottom();
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error =
            'AI response failed. Check Ollama, connection, API key, or model.';
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
    final branch = activeBranch ?? _branchForLayer(state.primaryConcern);
    final chips = branch.concerns.map((concern) => concern.feltNeed).toList();
    final hasReflection = state.reflectedMotivation.isNotEmpty;
    final canAnswer = !hasReflection && !loading;
    return OnboardingScaffold(
      phase: 5,
      title: 'Tell Shelby what is behind it.',
      subtitle:
          'Share as much or as little as you want. Shelby will ask a few gentle follow-ups and reflect the heart of your goal back to you.',
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
              icon: Icons.chat_bubble_rounded,
              title: 'Guided chat is ready',
              body:
                  'Suggested replies use Shelby’s built-in decision flow. Your typed answer can still be matched to the closest path.',
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
            children: chips
                .map(
                  (chip) => ActionChip(
                    label: Text(chip),
                    onPressed: canAnswer ? () => sendAnswer(chip) : null,
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
                  enabled: !hasReflection,
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
                onPressed: canAnswer ? () => sendAnswer() : null,
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

  String _nextGoalDiscoveryQuestion(String concern, int userAnswerCount) {
    final branch = _branchForLayer(concern);
    return userAnswerCount <= 1
        ? branch.concerns.first.followUp
        : 'What monthly action would feel realistic enough to start with?';
  }

  bool _acceptsSuggestedDirection(String answer) {
    final normalized = answer.toLowerCase();
    final acceptancePhrases = [
      'i agree',
      'agree',
      'yes',
      'yeah',
      'yup',
      'okay',
      'ok',
      'sounds good',
      'that works',
      'good for me',
      'follow what you said',
      'follow your suggestion',
      'follow that',
      'i will follow',
      'i want to follow',
      'let us do that',
      "let's do that",
      'that goal',
      'that target',
    ];
    return acceptancePhrases.any(normalized.contains);
  }
}

class PsychBaselineScreen extends StatelessWidget {
  const PsychBaselineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return OnboardingScaffold(
      phase: 6,
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
      phase: 7,
      title: 'Financial Scaffolding.',
      subtitle:
          'Quantify your economic standing for the financial pyramid health index.',
      bottom: PrimaryButton(
        label: 'Choose Tracking Variables',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const TrackingVariablesScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaselineSummaryStrip(
            assets: state.totalAssets,
            liabilities: state.totalLiabilities,
            netWorth: state.totalAssets - state.totalLiabilities,
          ),
          const SizedBox(height: 18),
          EditableMoneyItemList(
            title: 'Assets',
            total: state.totalAssets,
            items: state.assets,
            icon: Icons.savings_rounded,
            onAdd: () => _showMoneyItemDialog(context, isLiability: false),
            onEdit: (item) => _showMoneyItemDialog(
              context,
              item: item,
              isLiability: false,
            ),
            onDelete: state.removeAsset,
          ),
          const SizedBox(height: 24),
          EditableMoneyItemList(
            title: 'Liabilities',
            total: state.totalLiabilities,
            items: state.liabilities,
            icon: Icons.credit_card_rounded,
            danger: true,
            onAdd: () => _showMoneyItemDialog(context, isLiability: true),
            onEdit: (item) => _showMoneyItemDialog(
              context,
              item: item,
              isLiability: true,
            ),
            onDelete: state.removeLiability,
          ),
        ],
      ),
    );
  }

  Future<void> _showMoneyItemDialog(
    BuildContext context, {
    MoneyItem? item,
    required bool isLiability,
  }) async {
    final state = AppScope.of(context);
    final nameController = TextEditingController(text: item?.name ?? '');
    final descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    final valueController = TextEditingController(
      text:
          item == null || item.value == 0 ? '' : item.value.toStringAsFixed(0),
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final title = item == null
            ? (isLiability ? 'Add Liability' : 'Add Asset')
            : (isLiability ? 'Edit Liability' : 'Edit Asset');
        return AlertDialog(
          backgroundColor: _surface,
          title: Text(
            title,
            style: const TextStyle(color: _title, fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: inputDecoration(
                  isLiability ? 'Credit Card' : 'Investment Portfolio',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                textInputAction: TextInputAction.next,
                decoration: inputDecoration(
                  isLiability ? 'Visa Gold' : 'Vanguard ETF',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration('Amount').copyWith(
                  prefixText: '₱ ',
                  prefixStyle: const TextStyle(
                    color: _title,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (item != null)
              TextButton(
                onPressed: () {
                  if (isLiability) {
                    state.removeLiability(item);
                  } else {
                    state.removeAsset(item);
                  }
                  Navigator.of(dialogContext).pop();
                  setState(() {});
                },
                child: const Text('Delete', style: TextStyle(color: _red)),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(valueController.text) ?? 0;
                if (item == null) {
                  final newItem = MoneyItem(
                    nameController.text.trim().isEmpty
                        ? (isLiability ? 'New Liability' : 'New Asset')
                        : nameController.text.trim(),
                    descriptionController.text.trim().isEmpty
                        ? 'Tap to refine later'
                        : descriptionController.text.trim(),
                    value,
                  );
                  state.addMoneyItem(newItem, isLiability: isLiability);
                } else {
                  state.updateMoneyItem(
                    item,
                    name: nameController.text,
                    description: descriptionController.text,
                    value: value,
                  );
                }
                Navigator.of(dialogContext).pop();
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    valueController.dispose();
  }
}

class BaselineSummaryStrip extends StatelessWidget {
  const BaselineSummaryStrip({
    super.key,
    required this.assets,
    required this.liabilities,
    required this.netWorth,
  });

  final double assets;
  final double liabilities;
  final double netWorth;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(child: ProfileStat(label: 'Assets', value: money(assets))),
          Container(width: 1, height: 42, color: _border),
          Expanded(
            child: ProfileStat(label: 'Liabilities', value: money(liabilities)),
          ),
          Container(width: 1, height: 42, color: _border),
          Expanded(child: ProfileStat(label: 'Net', value: money(netWorth))),
        ],
      ),
    );
  }
}

class EditableMoneyItemList extends StatelessWidget {
  const EditableMoneyItemList({
    super.key,
    required this.title,
    required this.total,
    required this.items,
    required this.icon,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.danger = false,
  });

  final String title;
  final double total;
  final List<MoneyItem> items;
  final IconData icon;
  final VoidCallback onAdd;
  final ValueChanged<MoneyItem> onEdit;
  final ValueChanged<MoneyItem> onDelete;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title, action: money(total), danger: danger),
        const SizedBox(height: 12),
        if (items.isEmpty)
          AppCard(
            child: Text(
              danger ? 'No liabilities added yet.' : 'No assets added yet.',
              style: const TextStyle(color: _body, fontWeight: FontWeight.w700),
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Dismissible(
                key: ValueKey(item),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 22),
                  decoration: BoxDecoration(
                    color: _red,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                onDismissed: (_) => onDelete(item),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => onEdit(item),
                  child: FinancialItemCard(
                    item: item,
                    icon: icon,
                    danger: danger,
                  ),
                ),
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
      phase: 8,
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
              onTap: () =>
                  setState(() => state.toggleInterferingVariable(value)),
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
  final coach = const ShellbyAiCoach();
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
    } on AiSetupException {
      if (!mounted) return;
      state.setRecommendedGoal(
        title: _fallbackTitle(state.primaryConcern),
        description: _fallbackDescription(state),
        monthlyTarget: state.requiredMonthlyContribution,
      );
      setState(() {
        loading = false;
        error =
            'Configure AI with Ollama or Gemini. For Ollama: ollama serve, then flutter run --dart-define=AI_PROVIDER=ollama';
        messages.add(
          const ChatMessage(
            false,
            'I created a local draft for now. Once the AI provider is reachable, I can revise this goal conversationally.',
          ),
        );
      });
      _scrollToBottom();
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Goal AI failed. Check Ollama, connection, API key, or model.';
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
    final goals = _goalBranches
        .expand(
          (branch) => branch.concerns.map(
            (concern) => (concern, branch.icon),
          ),
        )
        .toList();
    return OnboardingScaffold(
      phase: 9,
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
                icon: goal.$2,
                title: goal.$1.goalTitle,
                body: goal.$1.goalDescription,
                selected: state.selectedGoal == goal.$1.goalTitle,
                onTap: () => setState(() {
                  state.choosePresetGoal(
                    goal.$1.goalTitle,
                    goal.$1.goalDescription,
                  );
                  state.selectedGoalMonthlyTarget =
                      _monthlyTargetForConcern(state, goal.$1);
                  state.configureGoalActions(
                    actionIds: goal.$1.actionIds,
                    enableEmotionalLogs: goal.$1.enableEmotionalLogs,
                    enableStressIndicators: goal.$1.enableStressIndicators,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fallbackTitle(String concern) {
    return _branchForLayer(concern).defaultGoalTitle;
  }

  String _fallbackDescription(AppState state) {
    return _branchForLayer(state.primaryConcern).defaultGoalDescription;
  }
}

IconData _goalIconFor(String selectedGoal) {
  for (final branch in _goalBranches) {
    if (branch.defaultGoalTitle == selectedGoal ||
        branch.concerns.any((concern) => concern.goalTitle == selectedGoal)) {
      return branch.icon;
    }
  }
  return Icons.flag_rounded;
}

class GoalFeasibilityScreen extends StatelessWidget {
  const GoalFeasibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final score = state.feasibilityScore.round();
    return OnboardingScaffold(
      phase: 10,
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
            icon: _goalIconFor(state.selectedGoal),
            tag: score >= 75
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
      phase: 11,
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
      phase: 12,
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
            onChanged: (value) =>
                setState(() => state.consentBenchmarking = value),
          ),
          ConsentToggle(
            title: 'Community feedback',
            body: 'Let Shellby use posts and votes with your selected context.',
            value: state.consentCommunity,
            onChanged: (value) =>
                setState(() => state.consentCommunity = value),
          ),
          ConsentToggle(
            title: 'Trusted circle sharing',
            body:
                'Allow selected friends or collaborators to see chosen summaries.',
            value: state.consentTrustedCircle,
            onChanged: (value) =>
                setState(() => state.consentTrustedCircle = value),
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
      phase: 13,
      title: 'Set the social boundary.',
      subtitle:
          'Cooperative finance only works when the sharing structure is explicit before tracking starts.',
      bottom: PrimaryButton(
        label: 'Review Preparation Contract',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const PreparationCommitmentScreen()),
      ),
      child: Column(
        children: options
            .map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SelectableOption(
                  icon: option.$3,
                  title: option.$1,
                  body: option.$2,
                  selected: state.socialStructure == option.$1,
                  onTap: () =>
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
      phase: 14,
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
                SummaryRow('Actions', state.selectedActionIds.join(', ')),
                if (state.emotionalLogsEnabled)
                  const SummaryRow(
                      'Optional signal', 'Emotional spending logs'),
                if (state.stressIndicatorsEnabled)
                  const SummaryRow(
                    'Optional signal',
                    'Financial anxiety score',
                  ),
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
    final action = switch (state.selectedGoal) {
      'Expense Tracking Routine' ||
      'Irregular Income Buffer' ||
      'Emotional Spending Log' ||
      'Cash Flow Stability Plan' =>
        'Log your first income or spending baseline',
      'Buffer Duration Goal' ||
      'Bill Calm Buffer' ||
      'Safety Shield Boundary' ||
      'Payday Safety Sweep' ||
      'Emergency Cushion' =>
        'Allocate your first safety buffer amount',
      'Debt Payoff Map' => 'Add your first debt balance or due date',
      'Starter Investing Confidence' ||
      'Lifestyle Creep Monitor' ||
      'Net Worth Growth Plan' =>
        'Record your first saving or investment habit',
      'Milestone Bucket Plan' ||
      'Guilt-Free Experience Fund' ||
      'Shared Future Alignment' ||
      'Future Lifestyle Fund' =>
        'Create your first milestone bucket',
      _ => 'Add your first goal tracking action',
    };
    return OnboardingScaffold(
      phase: 15,
      title: 'Begin collection.',
      subtitle:
          'The preparation stage is complete. Your first tracking action should directly support the goal you chose.',
      bottom: PrimaryButton(
        label: 'Enter Shellby',
        icon: Icons.arrow_forward_rounded,
        onPressed: () async {
          try {
            if (!state.isSignedIn) {
              await state.signInWithGoogle(
                saveAfterSignIn: false,
                forceFreshGoogleSession: true,
              );
            }
            await state.saveProfile(markOnboardingComplete: true);
            if (!context.mounted) return;
            _pushReplacement(context, const MainShell());
          } catch (error) {
            if (!context.mounted) return;
            _showAuthError(context, error);
          }
        },
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
