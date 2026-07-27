part of '../../main.dart';

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
                    alignment: message.fromUser
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
                        border: message.fromUser
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
              child: canFinish
                  ? PrimaryButton(
                      label: 'Finish Discovery',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () =>
                          _push(context, const QuantitativeScreen()),
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
                onPressed: () => _pushAndRemoveAll(context, const MainShell()),
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
