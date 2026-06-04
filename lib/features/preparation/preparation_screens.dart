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
              (state) => state.signInWithGoogle(saveAfterSignIn: false),
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
      phase: 4,
      title: 'What brought you here today?',
      subtitle:
          'Choose the money question you are most curious about right now. You can always change it later.',
      bottom: PrimaryButton(
        label: 'Tell Shelby Why',
        icon: Icons.arrow_forward_rounded,
        onPressed: () => _push(context, const MotivationSurfaceScreen()),
      ),
      child: Column(
        children: options
            .map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SelectableOption(
                  icon: option.$2,
                  title: option.$1,
                  selected: state.primaryConcern == option.$1,
                  onTap: () => setState(() => state.primaryConcern = option.$1),
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
    final chips = _chipsForConcern(state.primaryConcern);
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
              icon: Icons.key_rounded,
              title: 'Live AI setup needed',
              body:
                  'Run Shellby with Ollama or Gemini enabled to use this chatbot. API keys are not stored in source code.',
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

  String _firstQuestionFor(String concern) {
    return switch (concern) {
      'Building emergency savings' =>
        'What do you want an emergency fund to protect you from, and why would that matter to you?',
      'Managing debt' =>
        'When you think about your debt, what feels most important to change first: stress, cash flow, due dates, or the total balance?',
      'Controlling spending' =>
        'Which spending pattern would you most want to change, and what would feel better if you changed it?',
      'Starting investments' =>
        'What makes investing feel important now, and what would you want it to help you build toward?',
      'Planning a big purchase' =>
        'What purchase are you preparing for, and why does it matter at this stage of your life?',
      'Reducing financial anxiety' =>
        'When does money anxiety show up most, and what would feeling more in control look like for you?',
      'Comparing with peers' =>
        'What do you hope peer comparison will help you understand, and what kind of comparison would actually feel useful?',
      _ =>
        'What made you open Shellby now, even if you are not sure which financial goal to choose yet?',
    };
  }

  String _nextGoalDiscoveryQuestion(String concern, int userAnswerCount) {
    if (userAnswerCount == 1) {
      return switch (concern) {
        'Building emergency savings' =>
          'For your first milestone, would one month of essential expenses, three months, or a specific peso amount feel like the right target?',
        'Managing debt' =>
          'Which first debt target would feel most useful: lowering one balance, reducing monthly payments, or getting current on due dates?',
        'Controlling spending' =>
          'What first reduction target would feel realistic: cutting that category by 10%, setting a peso limit, or another amount?',
        'Starting investments' =>
          'What first investing milestone would feel realistic: a small monthly habit, a starter fund amount, or learning enough to feel confident?',
        'Planning a big purchase' =>
          'How much do you think this purchase will cost, or what rough price range should Shellby plan around?',
        'Reducing financial anxiety' =>
          'What would be a concrete sign that money feels calmer: checking balances weekly, having a buffer, paying bills earlier, or something else?',
        'Comparing with peers' =>
          'What specific comparison would help you most: savings rate, emergency fund months, debt load, spending categories, or income range?',
        _ =>
          'What first result would make Shellby feel useful to you: more savings, less debt stress, clearer spending, or a specific purchase plan?',
      };
    }

    return switch (concern) {
      'Building emergency savings' =>
        'By when would you want to reach that first emergency fund milestone, and about how much could you set aside each month?',
      'Managing debt' =>
        'What timeframe would feel realistic for that first debt target, and how much extra could you put toward it each month?',
      'Controlling spending' =>
        'When would you want to see that spending change, and what habit or limit would make it realistic?',
      'Starting investments' =>
        'How soon would you want to start, and what monthly amount would feel sustainable while keeping your essentials covered?',
      'Planning a big purchase' =>
        'When would you like to make the purchase, and how much could you comfortably save for it each month?',
      'Reducing financial anxiety' =>
        'Over the next month, what small routine would feel realistic enough to lower that anxiety without overwhelming you?',
      'Comparing with peers' =>
        'How often would you want to review that comparison, and what boundary would keep it useful instead of stressful?',
      _ =>
        'What timeframe and monthly effort would feel realistic for that first result?',
    };
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
                icon: goal.$3,
                title: goal.$1,
                body: goal.$2,
                selected: state.selectedGoal == goal.$1,
                onTap: () => setState(
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
            icon: state.selectedGoal == 'Debt Reset'
                ? Icons.credit_score_rounded
                : state.selectedGoal == 'Investment Starter'
                    ? Icons.trending_up_rounded
                    : Icons.shield_rounded,
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
    final action = state.selectedGoal == 'Debt Reset'
        ? 'Add your next debt due date'
        : state.selectedGoal == 'Investment Starter'
            ? 'Record your first investment allocation'
            : 'Allocate your first emergency fund amount';
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
              await state.signInWithGoogle(saveAfterSignIn: false);
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
