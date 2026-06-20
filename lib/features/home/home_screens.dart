part of '../../main.dart';

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
      const InsightsPage(),
      const GoalsPage(),
      const ActivityPage(),
      const ProfilePage(),
    ];
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_rounded),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'You',
          ),
        ],
      ),
    );
  }
}

String _wholeMoney(String value) {
  final chars = value.split('').reversed.toList();
  final grouped = <String>[];
  for (var i = 0; i < chars.length; i++) {
    if (i != 0 && i % 3 == 0) grouped.add(',');
    grouped.add(chars[i]);
  }
  return grouped.reversed.join();
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final name = state.name.trim();
    final balance =
        state.hasFakeMayaLink ? state.linkedFakeMayaBalance : 24840.55;
    final balanceParts = balance.toStringAsFixed(2).split('.');
    final spendable =
        state.hasFakeMayaLink ? state.fakeMayaLink!.summary.wallet : 1240.0;
    final saved = state.hasFakeMayaLink
        ? state.fakeMayaLink!.summary.savings +
            state.fakeMayaLink!.summary.timeDeposit +
            state.fakeMayaLink!.summary.goalBalance
        : 320.0;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        PageHeader(
          eyebrow: 'GOOD MORNING',
          title: name.isEmpty ? 'Hi!' : 'Hi $name',
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total balance card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL BALANCE',
                      style: TextStyle(
                        color: _body,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          '₱ ${_wholeMoney(balanceParts.first)}',
                                      style: GoogleFonts.nunito(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        color: _title,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '.${balanceParts.last}',
                                      style: GoogleFonts.nunito(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: _body,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _brand.withOpacity(.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 12,
                                      color: _brand,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '₱420 this week',
                                      style: const TextStyle(
                                        color: _brand,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const _MiniBarChart(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Shellby insight card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _bellySoft,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: Image.asset(
                        'assets/images/shellby_wave.webp',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _title,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(text: 'You spent '),
                                TextSpan(
                                  text: '₱48 less',
                                  style: const TextStyle(
                                    color: _brand,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' on takeout this week 🎉',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to see why →',
                            style: const TextStyle(
                              color: _purple,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Spendable + Saved mini cards
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: _brand,
                      label: 'Spendable',
                      value: money(spendable),
                      delta: state.hasFakeMayaLink
                          ? 'FakeMaya wallet'
                          : '↑ ₱80 this week',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStatCard(
                      icon: Icons.savings_rounded,
                      iconColor: _purple,
                      label: 'Saved',
                      value: money(saved),
                      delta: state.hasFakeMayaLink
                          ? 'FakeMaya savings'
                          : '64% of goal',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Goals section header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your goals',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: _title,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: _purple,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _GoalProgressCard(
                emoji: '☕',
                title: 'Coffee fund',
                current: 205,
                target: 250,
                percent: 82,
                color: _brand,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  int _period = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final layers = _insightLayersFor(
      state.fakeMayaLink?.summary.transactions ?? const [],
      _period,
    );
    final categories = layers.expand((layer) => layer.categories).toList();
    final total = categories.fold(0.0, (sum, item) => sum + item.amount);
    final periodLabel =
        ['SPENT THIS WEEK', 'SPENT THIS MONTH', 'SPENT THIS YEAR'][_period];
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(eyebrow: 'WHERE IT WENT', title: 'Insights'),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _bellySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: ['Week', 'Month', 'Year'].asMap().entries.map((e) {
                    final active = _period == e.key;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _period = e.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: active ? _surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: active
                                ? const [
                                    BoxShadow(
                                      color: Color(0x142E1B47),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            e.value,
                            style: TextStyle(
                              color: active ? _title : _body,
                              fontWeight:
                                  active ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              // Spent card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      periodLabel,
                      style: const TextStyle(
                        color: _body,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      money(total),
                      style: GoogleFonts.nunito(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: _title,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (categories.isEmpty)
                      const Text(
                        'Label outgoing transactions to build your spending insights.',
                        style: TextStyle(
                          color: _body,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Row(
                          children: categories.map((category) {
                            return Expanded(
                              flex: math.max(
                                1,
                                (category.amount / total * 100).round(),
                              ),
                              child: Container(
                                height: 10,
                                color: category.color,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'By financial layer',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _title,
                ),
              ),
              const SizedBox(height: 14),
              ...layers.map(
                (layer) => _InsightLayerSection(layer: layer),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightCategory {
  const _InsightCategory({
    required this.label,
    required this.icon,
    required this.color,
    required this.amount,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double amount;
}

class _InsightLayer {
  const _InsightLayer({
    required this.name,
    required this.account,
    required this.icon,
    required this.color,
    required this.categories,
  });

  final String name;
  final String account;
  final IconData icon;
  final Color color;
  final List<_InsightCategory> categories;

  double get total =>
      categories.fold(0.0, (sum, category) => sum + category.amount);
}

List<_InsightLayer> _insightLayersFor(
  List<FakeMayaTransaction> transactions,
  int period,
) {
  final totals = <int, Map<String, double>>{
    1: {},
    2: {},
    3: {},
    4: {},
  };
  for (final transaction in transactions) {
    final title = transaction.title.toLowerCase();
    final category = transaction.category?.trim() ?? '';
    if (!transaction.isLabeled ||
        transaction.excludedFromInsights ||
        transaction.amount >= 0 ||
        (!title.contains('send money') && !title.contains('sent money')) ||
        category.toLowerCase() == 'transfer' ||
        !_isInInsightPeriod(transaction.createdAt, period)) {
      continue;
    }
    final config = _insightCategoryConfig(category);
    totals[config.$1]!.update(
      config.$2,
      (amount) => amount + transaction.amount.abs(),
      ifAbsent: () => transaction.amount.abs(),
    );
  }

  return [
    _buildInsightLayer(
      'Cash Flow & Basic Needs',
      'Wallet spending',
      Icons.account_balance_wallet_rounded,
      _brand,
      totals[1]!,
    ),
    _buildInsightLayer(
      'Financial Safety',
      'Savings protection',
      Icons.shield_rounded,
      _amber,
      totals[2]!,
    ),
    _buildInsightLayer(
      'Accumulating Wealth',
      'Time Deposit and debt',
      Icons.trending_up_rounded,
      _purple,
      totals[3]!,
    ),
    _buildInsightLayer(
      'Financial Freedom',
      'Personal goals and lifestyle',
      Icons.flag_rounded,
      const Color(0xFF6AA8F0),
      totals[4]!,
    ),
  ];
}

_InsightLayer _buildInsightLayer(
  String name,
  String account,
  IconData icon,
  Color color,
  Map<String, double> totals,
) {
  final categories = totals.entries.map((entry) {
    final config = _insightCategoryConfig(entry.key);
    return _InsightCategory(
      label: entry.key,
      icon: config.$3,
      color: config.$4,
      amount: entry.value,
    );
  }).toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));
  return _InsightLayer(
    name: name,
    account: account,
    icon: icon,
    color: color,
    categories: categories,
  );
}

(int, String, IconData, Color) _insightCategoryConfig(String value) {
  final category = value.trim().toLowerCase();
  return switch (category) {
    'food & drink' => (1, 'Food & drink', Icons.restaurant_rounded, _brand),
    'transport' => (1, 'Transport', Icons.directions_bus_rounded, _purple),
    'bills' || 'bills & utilities' => (
        1,
        'Bills & utilities',
        Icons.bolt_rounded,
        _amber
      ),
    'housing' => (1, 'Housing', Icons.home_rounded, _brand),
    'groceries' => (1, 'Groceries', Icons.shopping_cart_rounded, _brand),
    'shopping' => (
        1,
        'Shopping',
        Icons.shopping_bag_rounded,
        const Color(0xFFEE7E9C)
      ),
    'education' => (1, 'Education', Icons.school_rounded, _purple),
    'health' => (2, 'Health', Icons.health_and_safety_rounded, _amber),
    'insurance' => (2, 'Insurance', Icons.verified_user_rounded, _amber),
    'emergency fund' => (2, 'Emergency fund', Icons.emergency_rounded, _amber),
    'debt payment' => (
        3,
        'Debt payment',
        Icons.credit_card_off_rounded,
        _purple
      ),
    'investment' => (3, 'Investment', Icons.show_chart_rounded, _purple),
    'time deposit' => (3, 'Time deposit', Icons.lock_clock_rounded, _purple),
    'entertainment' => (
        4,
        'Entertainment',
        Icons.sports_esports_rounded,
        const Color(0xFF6AA8F0)
      ),
    'travel' => (
        4,
        'Travel',
        Icons.flight_takeoff_rounded,
        const Color(0xFF6AA8F0)
      ),
    'personal goal' => (
        4,
        'Personal goal',
        Icons.flag_rounded,
        const Color(0xFF6AA8F0)
      ),
    'gifts & giving' || 'gift' => (
        4,
        'Gifts & giving',
        Icons.card_giftcard_rounded,
        _red
      ),
    _ => (
        1,
        value.trim().isEmpty ? 'Other expense' : value.trim(),
        Icons.payments_rounded,
        _body
      ),
  };
}

bool _isInInsightPeriod(DateTime? timestamp, int period) {
  if (timestamp == null) return true;
  final now = DateTime.now();
  final local = timestamp.toLocal();
  return switch (period) {
    0 => local.isAfter(now.subtract(const Duration(days: 7))),
    1 => local.year == now.year && local.month == now.month,
    _ => local.year == now.year,
  };
}

class _InsightLayerSection extends StatelessWidget {
  const _InsightLayerSection({required this.layer});

  final _InsightLayer layer;

  @override
  Widget build(BuildContext context) {
    final maxAmount =
        layer.categories.isEmpty ? 1.0 : layer.categories.first.amount;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBubble(
                  layer.icon,
                  color: layer.color,
                  background: layer.color.withOpacity(.12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        layer.name,
                        style: const TextStyle(
                          color: _title,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        layer.account,
                        style: const TextStyle(
                          color: _body,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  money(layer.total),
                  style: TextStyle(
                    color: layer.color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (layer.categories.isEmpty)
              const Text(
                'No labeled spending in this layer for the selected period.',
                style: TextStyle(
                  color: _body,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              ...layer.categories.map(
                (category) => _CategoryRow(
                  icon: category.icon,
                  color: category.color,
                  label: category.label,
                  amount: category.amount,
                  max: maxAmount,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cycle = _goalCycleFor(state);
    final buckets = _goalBucketsFor(state);
    final totalSaved = buckets.fold(0.0, (sum, bucket) => sum + bucket.current);
    final totalTarget = buckets.fold(0.0, (sum, bucket) => sum + bucket.target);
    final primary = buckets.first;
    final cycleSteps = _cycleStepsForGoal(state);
    final irregularIncome = state.selectedGoal == 'Irregular Income Buffer'
        ? _irregularIncomeCycleFor(state)
        : null;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(eyebrow: 'COLLECTION MODE', title: 'Goals'),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _GoalCycleChip(cycle: cycle),
                  const SizedBox(width: 8),
                  _GoalLayerChip(goal: state.selectedGoal),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7C76A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.selectedGoal == 'Irregular Income Buffer'
                          ? 'INCOME BUFFER AVAILABLE'
                          : 'TOTAL IN GOAL BUCKETS',
                      style: const TextStyle(
                        color: _title,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      money(totalSaved),
                      style: GoogleFonts.nunito(
                        color: _title,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.selectedGoal == 'Irregular Income Buffer'
                          ? 'Cash-flow equalizer inside Wallet · ${money(totalTarget)} income floor'
                          : 'of ${money(totalTarget)} across ${buckets.length} active ${buckets.length == 1 ? 'goal' : 'goals'}',
                      style: const TextStyle(
                        color: _title,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _GoalStatTile(
                            label:
                                state.selectedGoal == 'Irregular Income Buffer'
                                    ? 'Income floor'
                                    : 'Cycle target',
                            value:
                                state.selectedGoal == 'Irregular Income Buffer'
                                    ? irregularIncome!.hasFloor
                                        ? money(irregularIncome.floor)
                                        : 'Not set'
                                    : money(cycle.allocation),
                            color: _title,
                            background: Colors.white.withOpacity(.35),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _GoalStatTile(
                            label: irregularIncome == null
                                ? 'Green light'
                                : 'ACT6 status',
                            value: irregularIncome == null
                                ? cycle.greenLight
                                    ? 'Ready'
                                    : 'Waiting'
                                : !irregularIncome.hasFloor
                                    ? 'Set floor'
                                    : irregularIncome.events.isEmpty
                                        ? 'Waiting'
                                        : irregularIncome.isShortfall
                                            ? 'Shortfall'
                                            : 'Surplus',
                            color: irregularIncome == null
                                ? cycle.greenLight
                                    ? _brand
                                    : _amber
                                : !irregularIncome.hasFloor
                                    ? _amber
                                    : irregularIncome.events.isEmpty
                                        ? _amber
                                        : irregularIncome.isShortfall
                                            ? _red
                                            : _brand,
                            background: Colors.white.withOpacity(.35),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _GoalStatTile(
                            label: 'Account',
                            value: primary.accountName
                                .replaceFirst('FakeMaya ', ''),
                            color: _purple,
                            background: Colors.white.withOpacity(.35),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _GoalBucketCard(
                bucket: primary,
                featured: true,
                onTap: () => _showBucketActions(context, primary),
                onEdit: () => _showBucketEditor(context, primary),
                onAllocate: () => _showAllocationSheet(context, primary),
              ),
              if (state.selectedGoal == 'Irregular Income Buffer') ...[
                const SizedBox(height: 16),
                _IrregularIncomeCollectionCard(
                  data: irregularIncome!,
                ),
              ],
              const SizedBox(height: 22),
              AppCard(
                child: Row(
                  children: [
                    IconBubble(
                      Icons.account_balance_wallet_rounded,
                      color: primary.color,
                      background: primary.color.withOpacity(.12),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        '${_layerNameFor(_layerForGoal(state.selectedGoal))} goals use ${primary.accountName} as their source of truth.',
                        style: const TextStyle(
                          color: _body,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SectionTitle(title: 'This cycle', action: cycle.rhythm),
              const SizedBox(height: 12),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: cycleSteps.asMap().entries.map((entry) {
                    final isLast = entry.key == cycleSteps.length - 1;
                    return Column(
                      children: [
                        _GoalCycleStepRow(
                          step: entry.value,
                          index: entry.key + 1,
                          isLast: isLast,
                        ),
                        if (!isLast)
                          const Divider(
                            height: 1,
                            color: _border,
                            indent: 74,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showBucketActions(BuildContext context, _GoalBucket bucket) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalBucketActionsSheet(
        bucket: bucket,
        onEdit: () {
          Navigator.pop(context);
          _showBucketEditor(context, bucket);
        },
        onAllocate: () {
          Navigator.pop(context);
          _showAllocationSheet(context, bucket);
        },
      ),
    );
  }

  Future<void> _showBucketEditor(BuildContext context, _GoalBucket bucket) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalBucketEditorSheet(bucket: bucket),
    );
  }

  Future<void> _showAllocationSheet(BuildContext context, _GoalBucket bucket) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalAllocationSheet(bucket: bucket),
    );
  }
}

class _IrregularIncomeCollectionCard extends StatelessWidget {
  const _IrregularIncomeCollectionCard({required this.data});

  final _IrregularIncomeCycleData data;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final weeklyCheckInRecorded = state.hasCurrentWeekAnxietyCheckIn;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBubble(
                Icons.sync_alt_rounded,
                color: _brand,
                background: _brand.withOpacity(.12),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Collection trace',
                      style: TextStyle(
                        color: _title,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Event-driven income + ACT6 reactions',
                      style: TextStyle(
                        color: _body,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _GoalStatTile(
                  label: 'Income floor',
                  value: data.hasFloor ? money(data.floor) : 'Not set',
                  color: _title,
                  background: _bg,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GoalStatTile(
                  label: 'Income captured',
                  value: money(data.incomeTotal),
                  color: data.isShortfall ? _red : _brand,
                  background: _bg,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _showIncomeFloorSheet(context, state),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: Text(
                  data.hasFloor ? 'Change income floor' : 'Set income floor'),
              style: TextButton.styleFrom(foregroundColor: _purple),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (!data.hasFloor
                      ? _amber
                      : data.isShortfall
                          ? _red
                          : _brand)
                  .withOpacity(.09),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              !data.hasFloor
                  ? 'Set the monthly income floor to start ACT6 comparisons. This value is controlled here and can be changed anytime.'
                  : data.events.isEmpty
                      ? 'Waiting for the next Cash In event. Income amount, sender, and timestamp are captured automatically.'
                      : data.isShortfall
                          ? '${money(data.difference)} below the floor. ACT6 needs a recorded plan adjustment.'
                          : '${money(data.difference)} above the floor. ACT6 can route the surplus to the income buffer.',
              style: TextStyle(
                color: data.hasFloor && data.isShortfall ? _red : _title,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
          if (data.events.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'INCOME EVENTS',
              style: TextStyle(
                color: _body,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            ...data.events.take(5).map((event) {
              final action =
                  state.planAdjustmentActions[event.transaction.transactionId];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.transaction.detail,
                                  style: const TextStyle(
                                    color: _title,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  event.transaction.age,
                                  style: const TextStyle(
                                    color: _body,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                money(event.transaction.amount),
                                style: const TextStyle(
                                  color: _brand,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                !event.hasFloor
                                    ? 'WAITING FOR FLOOR'
                                    : event.isSurplus
                                        ? 'SURPLUS'
                                        : 'SHORTFALL',
                                style: TextStyle(
                                  color: !event.hasFloor
                                      ? _amber
                                      : event.isSurplus
                                          ? _brand
                                          : _red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: event.hasFloor
                              ? () => _showPlanAdjustmentSheet(
                                    context,
                                    state,
                                    event,
                                  )
                              : null,
                          icon: Icon(
                            action == null
                                ? Icons.edit_note_rounded
                                : Icons.check_circle_rounded,
                            size: 17,
                          ),
                          label: Text(action ?? 'Record plan adjustment'),
                          style: TextButton.styleFrom(
                            foregroundColor: action == null ? _purple : _brand,
                            alignment: Alignment.centerLeft,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 12),
          _CollectionStatusRow(
            icon: Icons.receipt_long_rounded,
            title: 'Expense feed',
            detail:
                '${data.labeledExpenseCount}/${data.expenseCount} categorized · ${money(data.expenseTotal)} tracked',
            complete: data.expenseCount > 0 &&
                data.labeledExpenseCount == data.expenseCount,
          ),
          const SizedBox(height: 10),
          _CollectionStatusRow(
            icon: Icons.mood_rounded,
            title: 'Weekly anxiety check-in',
            detail: weeklyCheckInRecorded
                ? '${state.anxietyCheckIns[state.currentAnxietyWeekKey]!.round()} / 5 recorded'
                : 'Not recorded for this cycle',
            complete: weeklyCheckInRecorded,
            onTap: () => _showAnxietyCheckInSheet(context, state),
          ),
        ],
      ),
    );
  }
}

class _CollectionStatusRow extends StatelessWidget {
  const _CollectionStatusRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.complete,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool complete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: complete ? _brand : _purple, size: 20),
            const SizedBox(width: 10),
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
                  Text(
                    detail,
                    style: const TextStyle(
                      color: _body,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded, color: _body),
          ],
        ),
      ),
    );
  }
}

Future<void> _showIncomeFloorSheet(
  BuildContext context,
  AppState state,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _IncomeFloorSheet(state: state),
  );
}

class _IncomeFloorSheet extends StatefulWidget {
  const _IncomeFloorSheet({required this.state});

  final AppState state;

  @override
  State<_IncomeFloorSheet> createState() => _IncomeFloorSheetState();
}

class _IncomeFloorSheetState extends State<_IncomeFloorSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.state.irregularIncomeFloor > 0
        ? widget.state.irregularIncomeFloor.toStringAsFixed(0)
        : '',
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GoalSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Set your income floor',
            style: GoogleFonts.fredoka(
              color: _title,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Use the minimum monthly income your fixed plan should safely rely on—not your best or average month.',
            style: TextStyle(
              color: _body,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: inputDecoration('Monthly income floor'),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Save income floor',
            icon: Icons.check_rounded,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final amount = _parseMoney(_amount.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid income floor.')),
      );
      return;
    }
    widget.state.setIrregularIncomeFloor(amount);
    await widget.state.saveProfile();
    if (mounted) Navigator.pop(context);
  }
}

Future<void> _showPlanAdjustmentSheet(
  BuildContext context,
  AppState state,
  _IrregularIncomeEvent event,
) {
  final actions = event.isSurplus
      ? const [
          'Route surplus to income buffer',
          'Lower this month’s spending cap',
          'Keep surplus available in wallet',
        ]
      : const [
          'Use income buffer for the gap',
          'Reduce variable spending cap',
          'Make no adjustment yet',
        ];
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _GoalSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            event.isSurplus ? 'Route this surplus' : 'Respond to the shortfall',
            style: GoogleFonts.fredoka(
              color: _title,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This records the Plan Adjustment Action used by the next integration stage.',
            style: const TextStyle(color: _body, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ...actions.map(
            (action) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.adjust_rounded, color: _purple),
              title: Text(
                action,
                style: const TextStyle(
                  color: _title,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onTap: () async {
                state.recordPlanAdjustment(
                  transactionId: event.transaction.transactionId,
                  action: action,
                );
                await state.saveProfile();
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showAnxietyCheckInSheet(
  BuildContext context,
  AppState state,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _GoalSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Weekly anxiety check-in',
            style: GoogleFonts.fredoka(
              color: _title,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'How stressed do you feel about income timing this week?',
            style: TextStyle(color: _body, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ...List.generate(5, (index) {
            final score = index + 1;
            final labels = ['Calm', 'Okay', 'Waiting', 'Worried', 'Stressed'];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: _bellySoft,
                foregroundColor: _purple,
                child: Text('$score'),
              ),
              title: Text(
                labels[index],
                style: const TextStyle(
                  color: _title,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onTap: () async {
                state.recordWeeklyAnxietyCheckIn(score.toDouble());
                await state.saveProfile();
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              },
            );
          }),
        ],
      ),
    ),
  );
}

class _GoalBucket {
  const _GoalBucket({
    required this.id,
    required this.emoji,
    required this.name,
    required this.role,
    required this.current,
    required this.target,
    required this.monthly,
    required this.color,
    required this.linked,
    required this.accountName,
    required this.canAllocate,
  });

  final String id;
  final String emoji;
  final String name;
  final String role;
  final double current;
  final double target;
  final double monthly;
  final Color color;
  final bool linked;
  final String accountName;
  final bool canAllocate;

  int get percent =>
      target <= 0 ? 0 : (current / target * 100).clamp(0, 100).round();
  double get remaining => math.max(0, target - current);

  CollectionBucketOverride toOverride() {
    return CollectionBucketOverride(
      id: id,
      name: name,
      role: role,
      emoji: emoji,
      current: current,
      target: target,
      monthly: monthly,
    );
  }

  _GoalBucket applyOverride(CollectionBucketOverride? override) {
    if (override == null) return this;
    return _GoalBucket(
      id: id,
      emoji: override.emoji.trim().isEmpty ? emoji : override.emoji.trim(),
      name: override.name.trim().isEmpty ? name : override.name.trim(),
      role: override.role.trim().isEmpty ? role : override.role.trim(),
      current: linked ? current : override.current,
      target: override.target <= 0 ? target : override.target,
      monthly: override.monthly <= 0 ? monthly : override.monthly,
      color: color,
      linked: linked,
      accountName: accountName,
      canAllocate: canAllocate,
    );
  }
}

class _GoalCycle {
  const _GoalCycle({
    required this.number,
    required this.rhythm,
    required this.allocation,
    required this.greenLight,
  });

  final int number;
  final String rhythm;
  final double allocation;
  final bool greenLight;
}

class _GoalCycleStep {
  const _GoalCycleStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    this.note,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;
  final String? note;
}

class _IrregularIncomeEvent {
  const _IrregularIncomeEvent({
    required this.transaction,
    required this.runningIncome,
    required this.floor,
  });

  final FakeMayaTransaction transaction;
  final double runningIncome;
  final double floor;

  bool get hasFloor => floor > 0;
  bool get isSurplus => hasFloor && runningIncome >= floor;
  double get difference => hasFloor ? (runningIncome - floor).abs() : 0;
}

class _IrregularIncomeCycleData {
  const _IrregularIncomeCycleData({
    required this.floor,
    required this.incomeTotal,
    required this.bufferBalance,
    required this.events,
    required this.expenseCount,
    required this.labeledExpenseCount,
    required this.expenseTotal,
  });

  final double floor;
  final double incomeTotal;
  final double bufferBalance;
  final List<_IrregularIncomeEvent> events;
  final int expenseCount;
  final int labeledExpenseCount;
  final double expenseTotal;

  bool get hasFloor => floor > 0;
  bool get isShortfall => hasFloor && incomeTotal < floor;
  double get difference => hasFloor ? (incomeTotal - floor).abs() : 0;
}

_IrregularIncomeCycleData _irregularIncomeCycleFor(AppState state) {
  final floor = state.irregularIncomeFloor;
  final transactions =
      state.fakeMayaLink?.summary.transactions ?? <FakeMayaTransaction>[];
  final now = DateTime.now();
  final currentMonthIncome = transactions.where((transaction) {
    final date = transaction.createdAt?.toLocal();
    return transaction.title.toLowerCase().contains('cash in') &&
        transaction.amount > 0 &&
        (date == null || (date.year == now.year && date.month == now.month));
  }).toList()
    ..sort((a, b) => (a.createdAt ?? DateTime(1970))
        .compareTo(b.createdAt ?? DateTime(1970)));

  var runningIncome = 0.0;
  final events = <_IrregularIncomeEvent>[];
  for (final transaction in currentMonthIncome) {
    runningIncome += transaction.amount;
    events.add(
      _IrregularIncomeEvent(
        transaction: transaction,
        runningIncome: runningIncome,
        floor: floor,
      ),
    );
  }

  final monthlyIncome = <String, double>{};
  for (final transaction in transactions) {
    if (!transaction.title.toLowerCase().contains('cash in') ||
        transaction.amount <= 0) {
      continue;
    }
    final date = transaction.createdAt?.toLocal() ?? now;
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    monthlyIncome.update(
      key,
      (value) => value + transaction.amount,
      ifAbsent: () => transaction.amount,
    );
  }
  var bufferBalance = 0.0;
  final monthKeys = monthlyIncome.keys.toList()..sort();
  for (final key in monthKeys) {
    bufferBalance = math.max(0, bufferBalance + monthlyIncome[key]! - floor);
  }

  final expenses = transactions.where((transaction) {
    final title = transaction.title.toLowerCase();
    final date = transaction.createdAt?.toLocal();
    return transaction.amount < 0 &&
        (title.contains('send money') || title.contains('sent money')) &&
        (date == null || (date.year == now.year && date.month == now.month));
  }).toList();
  final labeledExpenses = expenses.where(
    (transaction) => transaction.isLabeled && !transaction.excludedFromInsights,
  );

  return _IrregularIncomeCycleData(
    floor: floor,
    incomeTotal: runningIncome,
    bufferBalance: bufferBalance,
    events: events.reversed.toList(),
    expenseCount: expenses.length,
    labeledExpenseCount: labeledExpenses.length,
    expenseTotal: labeledExpenses.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount.abs(),
    ),
  );
}

_GoalCycle _goalCycleFor(AppState state) {
  final rhythm =
      state.checkInRhythm.trim().isEmpty ? 'Weekly' : state.checkInRhythm;
  final cycleNumber = switch (rhythm.toLowerCase()) {
    final text when text.contains('daily') => 7,
    final text when text.contains('payday') => 2,
    final text when text.contains('monthly') => 1,
    _ => 4,
  };
  final allocation = _cycleAllocationFromSelections(state);
  final linkedWallet = state.fakeMayaLink?.summary.wallet ?? 0;
  final greenLight = state.hasFakeMayaLink
      ? linkedWallet >= math.min(allocation, 1000)
      : state.monthlySurplus > 0;
  return _GoalCycle(
    number: cycleNumber,
    rhythm: rhythm,
    allocation: allocation,
    greenLight: greenLight,
  );
}

List<_GoalBucket> _goalBucketsFor(AppState state) {
  final cycle = _goalCycleFor(state);
  final goal = state.selectedGoal;
  final linked = state.hasFakeMayaLink;
  final summary = state.fakeMayaLink?.summary;
  final layer = _layerForGoal(goal);
  final salaryTarget = _salaryBasedMonthlyGoalTarget(state);
  final baseTarget =
      salaryTarget ?? math.max(cycle.allocation * 3, _targetForGoal(state));
  final current = _currentForGoal(state, layer);
  final irregularIncome = goal == 'Irregular Income Buffer'
      ? _irregularIncomeCycleFor(state)
      : null;
  final accountName = switch (layer) {
    1 => 'FakeMaya Wallet',
    2 => 'FakeMaya Savings',
    3 => 'FakeMaya Time Deposit',
    _ => 'FakeMaya Personal Goal',
  };
  final linkedId = switch (layer) {
    1 => 'fakemaya-wallet',
    2 => 'fakemaya-savings',
    3 => 'fakemaya-time-deposit',
    _ => 'fakemaya-personal-goal',
  };
  final accountTarget = layer == 4 && summary != null
      ? math.max(summary.goalTarget, summary.goalBalance)
      : baseTarget;
  final bucket = _GoalBucket(
    id: irregularIncome != null
        ? 'irregular-income-buffer'
        : linked
            ? linkedId
            : _bucketIdFor(goal),
    emoji: layer == 4 && linked
        ? (summary?.goalEmoji ?? _emojiForGoal(goal))
        : _emojiForGoal(goal),
    name: goal,
    role: irregularIncome != null
        ? 'Cash-flow equalizer · held within FakeMaya Wallet'
        : '${_layerNameFor(layer)} · $accountName',
    current: irregularIncome?.bufferBalance ?? current,
    target: irregularIncome?.floor ?? math.max(accountTarget, current),
    monthly: layer == 1 ? 0 : cycle.allocation,
    color: _colorForLayer(layer),
    linked: linked,
    accountName: linked ? accountName : 'Shellby tracked balance',
    canAllocate: layer != 1,
  );
  return [
    bucket.applyOverride(state.goalBucketOverrides[bucket.id]),
  ];
}

String _bucketIdFor(String value) {
  final cleaned = value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return cleaned.isEmpty ? 'goal-bucket' : cleaned;
}

List<_GoalCycleStep> _cycleStepsForGoal(AppState state) {
  final goal = state.selectedGoal;
  final rhythm = state.checkInRhythm;
  if (goal == 'Irregular Income Buffer') {
    final data = _irregularIncomeCycleFor(state);
    final responses = data.events
        .where((event) => state.planAdjustmentActions
            .containsKey(event.transaction.transactionId))
        .length;
    return [
      _GoalCycleStep(
        icon: Icons.call_received_rounded,
        title: 'Auto-capture income events',
        body:
            '${data.events.length} Cash In ${data.events.length == 1 ? 'event' : 'events'} captured with amount, source, and timestamp.',
        color: _brand,
        note: data.events.isEmpty
            ? 'No manual income logging is required.'
            : null,
      ),
      _GoalCycleStep(
        icon: Icons.tune_rounded,
        title: 'Run ACT6 after each credit',
        body: data.hasFloor
            ? '$responses of ${data.events.length} budget adjustment responses recorded against the ${money(data.floor)} floor.'
            : 'Set an income floor before ACT6 can classify credits as surplus or shortfall.',
        color: data.hasFloor &&
                responses == data.events.length &&
                data.events.isNotEmpty
            ? _brand
            : _amber,
        note: !data.hasFloor
            ? 'The income floor is editable from the collection trace.'
            : data.isShortfall
                ? 'Current result: ${money(data.difference)} shortfall.'
                : 'Current result: ${money(data.difference)} surplus.',
      ),
      _GoalCycleStep(
        icon: Icons.fact_check_rounded,
        title: 'Complete the supporting feed',
        body:
            '${data.labeledExpenseCount}/${data.expenseCount} expenses categorized. Weekly anxiety check-in ${state.hasCurrentWeekAnxietyCheckIn ? 'recorded' : 'still due'}.',
        color: state.hasCurrentWeekAnxietyCheckIn ? _purple : _red,
        note:
            'Cash expenses remain a manual fallback when FakeMaya cannot detect them.',
      ),
    ];
  }
  if (_isCashFlowGoal(goal)) {
    return [
      _GoalCycleStep(
        icon: Icons.sync_rounded,
        title: 'Shelby watches your wallet',
        body:
            'Cash Flow & Basic Needs is measured from your FakeMaya Wallet balance and activity.',
        color: _brand,
      ),
      _GoalCycleStep(
        icon: Icons.sell_rounded,
        title: 'Transactions get tagged',
        body: 'Spending, income, merchant, and timing context feed this goal.',
        color: _purple,
      ),
      _GoalCycleStep(
        icon: Icons.event_available_rounded,
        title: '$rhythm summary',
        body:
            'At your chosen rhythm, Shelby shows what changed and what needs attention.',
        color: _amber,
        note:
            'Cash purchases get one gentle reminder when Maya cannot detect them.',
      ),
    ];
  }
  if (_isSafetyGoal(goal)) {
    return [
      _GoalCycleStep(
        icon: Icons.visibility_rounded,
        title: 'Track the savings account',
        body:
            'Financial Safety progress comes directly from your FakeMaya Savings balance.',
        color: _brand,
      ),
      _GoalCycleStep(
        icon: Icons.shield_rounded,
        title: 'Withdrawal guard',
        body:
            'If money leaves a protected bucket, Shelby asks why before logging it.',
        color: _red,
        note: 'This is awareness, not a hard block. Your money stays yours.',
      ),
      _GoalCycleStep(
        icon: Icons.fact_check_rounded,
        title: 'Buffer review',
        body:
            'Each cycle checks whether bills and emergency needs are still covered.',
        color: _purple,
      ),
    ];
  }
  if (_isWealthGoal(goal)) {
    return [
      _GoalCycleStep(
        icon: Icons.account_tree_rounded,
        title: 'Track the time deposit',
        body:
            'Accumulating Wealth progress comes directly from your FakeMaya Time Deposit balance.',
        color: _purple,
      ),
      _GoalCycleStep(
        icon: Icons.payments_rounded,
        title: 'Allocate from wallet',
        body:
            'Shelby uses your pace rule to suggest what can move from Wallet into Time Deposit this cycle.',
        color: _brand,
      ),
      _GoalCycleStep(
        icon: Icons.trending_up_rounded,
        title: 'Review movement',
        body:
            'The cycle completes when balances actually move in the intended direction.',
        color: _amber,
      ),
    ];
  }
  return [
    _GoalCycleStep(
      icon: Icons.flag_rounded,
      title: 'Track your personal goal',
      body:
          'Financial Freedom progress comes directly from your FakeMaya Personal Goal balance.',
      color: _purple,
    ),
    _GoalCycleStep(
      icon: Icons.verified_rounded,
      title: 'Wait for green light',
      body: 'Allocation stays paused until income and essentials look covered.',
      color: _brand,
    ),
    _GoalCycleStep(
      icon: Icons.savings_rounded,
      title: 'Allocate from wallet',
      body:
          'Once green-lit, move the suggested amount from Wallet into your Personal Goal.',
      color: _amber,
      note: 'Your selected plan determines which personal goal Shelby tracks.',
    ),
  ];
}

double _cycleAllocationFromSelections(AppState state) {
  final salaryTarget = _salaryBasedMonthlyGoalTarget(state);
  if (salaryTarget != null) return salaryTarget;

  final monthly = _monthlyAllocationFromSelections(state);
  final divisor = _cycleDivisorFor(state);
  final cycleAmount = monthly / divisor;
  if (cycleAmount <= 0) return 0;
  return math.max(100, _roundToNearest(cycleAmount, 50));
}

double _monthlyAllocationFromSelections(AppState state) {
  final salaryTarget = _salaryBasedMonthlyGoalTarget(state);
  if (salaryTarget != null) return salaryTarget;

  final explicitTarget = state.selectedGoalMonthlyTarget;
  final base = explicitTarget > 0
      ? explicitTarget
      : _monthlyAllocationBaseForGoal(state);
  if (base <= 0) return 0;

  final adjusted = base *
      _responsibilityFactor(state) *
      _incomeStabilityFactor(state) *
      _billsRhythmFactor(state);

  final monthlySurplus = math.max(0.0, state.monthlySurplus);
  if (monthlySurplus <= 0) {
    return math.min(adjusted, math.max(100.0, state.income * .03));
  }

  final cap = _isCashFlowGoal(state.selectedGoal)
      ? math.max(adjusted, monthlySurplus)
      : monthlySurplus * _surplusCapFactor(state);
  return math.min(adjusted, cap);
}

double _monthlyAllocationBaseForGoal(AppState state) {
  final percent = _pacePercentFor(state);
  final goal = state.selectedGoal;
  final income = _goalMonthlyIncome(state);
  if (_isCashFlowGoal(goal)) {
    if (goal == 'Irregular Income Buffer') {
      return math.max(300, state.expenses * .15);
    }
    return 0;
  }
  if (goal == 'Debt Payoff Map') {
    return math.max(400, state.debtPayments * (percent >= .2 ? 1.1 : .8));
  }
  if (goal == 'Lifestyle Creep Monitor') {
    return math.max(300, income * percent);
  }
  if (goal == 'Starter Investing Habit') {
    return math.max(300, income * math.min(percent, .12));
  }
  if (_isSafetyGoal(goal) || _isFreedomGoal(goal)) {
    return math.max(300, income * percent);
  }
  return math.max(300, income * percent);
}

double? _salaryBasedMonthlyGoalTarget(AppState state) {
  return state.monthlySalary > 0 ? state.monthlySalary * .10 : null;
}

double _goalMonthlyIncome(AppState state) {
  return state.monthlySalary > 0 ? state.monthlySalary : state.income;
}

double _pacePercentFor(AppState state) {
  final pace = state.chatDifficultySummary.toLowerCase();
  if (pace.contains('20') ||
      pace.contains('high-focus') ||
      pace.contains('aggressive') ||
      pace.contains('lifestyle-first')) {
    return .20;
  }
  if (pace.contains('5') ||
      pace.contains('relaxed') ||
      pace.contains('safe and slow') ||
      pace.contains('conservative')) {
    return .05;
  }
  return .10;
}

double _cycleDivisorFor(AppState state) {
  final checkIn = state.checkInRhythm.toLowerCase();
  if (checkIn.contains('daily')) return 30;
  if (checkIn.contains('weekly')) return 4.33;
  if (checkIn.contains('monthly')) return 1;

  final incomeRhythm = state.incomeRhythm.toLowerCase();
  if (incomeRhythm.contains('weekly')) return 4.33;
  if (incomeRhythm.contains('twice')) return 2;
  if (incomeRhythm.contains('monthly')) return 1;
  return 2;
}

double _responsibilityFactor(AppState state) {
  final responsibility = state.responsibility.toLowerCase();
  if (responsibility.contains('family')) return .75;
  if (responsibility.contains('shared')) return .85;
  return 1;
}

double _incomeStabilityFactor(AppState state) {
  final type = state.incomeType.toLowerCase();
  final rhythm = state.incomeRhythm.toLowerCase();
  if (type.contains('variable') && rhythm.contains('irregular')) return .70;
  if (type.contains('variable') || rhythm.contains('irregular')) return .82;
  return 1;
}

double _billsRhythmFactor(AppState state) {
  final rhythm = state.billsRhythm.toLowerCase();
  if (rhythm.contains('surprise')) return .80;
  if (rhythm.contains('scattered')) return .90;
  return 1;
}

double _surplusCapFactor(AppState state) {
  final pace = _pacePercentFor(state);
  if (pace >= .20) return .90;
  if (pace <= .05) return .45;
  return .65;
}

double _roundToNearest(double value, double step) {
  return (value / step).round() * step;
}

double _targetForGoal(AppState state) {
  final salaryTarget = _salaryBasedMonthlyGoalTarget(state);
  if (salaryTarget != null) return salaryTarget;

  final goal = state.selectedGoal;
  if (_isCashFlowGoal(goal)) return math.max(5000, state.expenses);
  if (_isSafetyGoal(goal)) return math.max(10000, state.expenses * 2);
  if (_isWealthGoal(goal)) return math.max(15000, state.debtPayments * 12);
  return math.max(25000, state.requiredMonthlyContribution * 4);
}

double _currentForGoal(AppState state, int layer) {
  final summary = state.fakeMayaLink?.summary;
  if (summary != null) {
    return switch (layer) {
      1 => math.max(0, summary.wallet),
      2 => math.max(0, summary.savings),
      3 => math.max(0, summary.timeDeposit),
      _ => summary.goalBalance,
    };
  }
  return switch (layer) {
    1 => math.max(0, state.monthlySurplus),
    2 => state.savings,
    3 => 0,
    _ => 0,
  };
}

String _layerNameFor(int layer) {
  return switch (layer) {
    1 => 'Cash Flow & Basic Needs',
    2 => 'Financial Safety',
    3 => 'Accumulating Wealth',
    _ => 'Financial Freedom',
  };
}

int _layerForGoal(String goal) {
  if (_isCashFlowGoal(goal)) return 1;
  if (_isSafetyGoal(goal)) return 2;
  if (_isWealthGoal(goal)) return 3;
  return 4;
}

bool _isCashFlowGoal(String goal) {
  return goal == 'Expense Tracking Routine' ||
      goal == 'Spending Trigger Tracker' ||
      goal == 'Irregular Income Buffer' ||
      goal == 'Cash Flow Stability Plan';
}

bool _isSafetyGoal(String goal) {
  return goal == 'Safety Shield Boundary' ||
      goal == 'Bill Due-Date Buffer' ||
      goal == 'Payday Safety Sweep' ||
      goal == 'Emergency Cushion';
}

bool _isWealthGoal(String goal) {
  return goal == 'Debt Payoff Map' ||
      goal == 'Starter Investing Habit' ||
      goal == 'Lifestyle Creep Monitor' ||
      goal == 'Net Worth Growth Plan';
}

bool _isFreedomGoal(String goal) =>
    !_isCashFlowGoal(goal) && !_isSafetyGoal(goal) && !_isWealthGoal(goal);

String _emojiForGoal(String goal) {
  return switch (goal) {
    'Expense Tracking Routine' => '🧾',
    'Spending Trigger Tracker' => '🧭',
    'Irregular Income Buffer' => '🌊',
    'Safety Shield Boundary' => '🛡️',
    'Bill Due-Date Buffer' => '📅',
    'Payday Safety Sweep' => '💸',
    'Debt Payoff Map' => '🧱',
    'Starter Investing Habit' => '🌱',
    'Lifestyle Creep Monitor' => '📈',
    'Shared Future Alignment' => '🤝',
    'Planned Experience Fund' => '✈️',
    'Milestone Bucket Plan' || 'Future Lifestyle Fund' => '🎯',
    _ => '🐢',
  };
}

Color _colorForLayer(int layer) {
  return switch (layer) {
    1 => _brand,
    2 => _red,
    3 => _purple,
    _ => const Color(0xFFE7C76A),
  };
}

class _GoalCycleChip extends StatelessWidget {
  const _GoalCycleChip({required this.cycle});

  final _GoalCycle cycle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _bellySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.repeat_rounded, size: 14, color: _purple),
          const SizedBox(width: 6),
          Text(
            'Cycle ${cycle.number} · ${cycle.rhythm}',
            style: const TextStyle(
              color: _purple,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalLayerChip extends StatelessWidget {
  const _GoalLayerChip({required this.goal});

  final String goal;

  @override
  Widget build(BuildContext context) {
    final layer = _layerForGoal(goal);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _colorForLayer(layer).withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'L$layer',
        style: TextStyle(
          color: _colorForLayer(layer),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _GoalStatTile extends StatelessWidget {
  const _GoalStatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final String label;
  final String value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _body,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalBucketCard extends StatelessWidget {
  const _GoalBucketCard({
    required this.bucket,
    this.featured = false,
    this.onTap,
    this.onEdit,
    this.onAllocate,
  });

  final _GoalBucket bucket;
  final bool featured;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onAllocate;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(bucket.emoji,
                    style: TextStyle(fontSize: featured ? 28 : 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bucket.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fredoka(
                          color: _title,
                          fontSize: featured ? 22 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${bucket.role} · ${bucket.linked ? 'FakeMaya linked' : 'Shellby tracked'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _body,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${bucket.percent}%',
                  style: TextStyle(
                    color: bucket.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              money(bucket.current),
              style: GoogleFonts.nunito(
                color: _title,
                fontSize: featured ? 32 : 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: bucket.percent / 100,
                minHeight: featured ? 12 : 9,
                color: bucket.color,
                backgroundColor: bucket.color.withOpacity(.14),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${money(bucket.remaining)} remaining',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${money(bucket.monthly)} / cycle',
                  style: const TextStyle(
                    color: _title,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Edit',
                    icon: Icons.edit_rounded,
                    onPressed: onEdit ?? () {},
                  ),
                ),
                if (bucket.canAllocate) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Allocate',
                      icon: Icons.add_rounded,
                      onPressed: onAllocate ?? () {},
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalBucketActionsSheet extends StatelessWidget {
  const _GoalBucketActionsSheet({
    required this.bucket,
    required this.onEdit,
    required this.onAllocate,
  });

  final _GoalBucket bucket;
  final VoidCallback onEdit;
  final VoidCallback onAllocate;

  @override
  Widget build(BuildContext context) {
    return _GoalSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${bucket.emoji} ${bucket.name}',
            style: GoogleFonts.fredoka(
              color: _title,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${money(bucket.current)} of ${money(bucket.target)} · ${bucket.percent}% funded',
            style: const TextStyle(
              color: _body,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          if (bucket.canAllocate) ...[
            PrimaryButton(
              label: 'Allocate to ${bucket.accountName}',
              icon: Icons.add_rounded,
              onPressed: onAllocate,
            ),
            const SizedBox(height: 10),
          ],
          SecondaryButton(
            label: 'Edit bucket details',
            icon: Icons.edit_rounded,
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

class _GoalBucketEditorSheet extends StatefulWidget {
  const _GoalBucketEditorSheet({required this.bucket});

  final _GoalBucket bucket;

  @override
  State<_GoalBucketEditorSheet> createState() => _GoalBucketEditorSheetState();
}

class _GoalBucketEditorSheetState extends State<_GoalBucketEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emoji;
  late final TextEditingController _name;
  late final TextEditingController _role;
  late final TextEditingController _current;
  late final TextEditingController _target;
  late final TextEditingController _monthly;

  @override
  void initState() {
    super.initState();
    final bucket = widget.bucket;
    _emoji = TextEditingController(text: bucket.emoji);
    _name = TextEditingController(text: bucket.name);
    _role = TextEditingController(text: bucket.role);
    _current = TextEditingController(text: bucket.current.toStringAsFixed(2));
    _target = TextEditingController(text: bucket.target.toStringAsFixed(2));
    _monthly = TextEditingController(text: bucket.monthly.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _emoji.dispose();
    _name.dispose();
    _role.dispose();
    _current.dispose();
    _target.dispose();
    _monthly.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GoalSheetFrame(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit bucket',
              style: GoogleFonts.fredoka(
                color: _title,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                SizedBox(
                  width: 74,
                  child: TextFormField(
                    controller: _emoji,
                    decoration: inputDecoration('Emoji'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _name,
                    decoration: inputDecoration('Bucket name'),
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _role,
              decoration: inputDecoration('Role'),
              validator: _required,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _current,
                    enabled: !widget.bucket.linked,
                    decoration: inputDecoration(
                      widget.bucket.linked
                          ? 'Linked account balance'
                          : 'Current amount',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: _moneyValidator,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _target,
                    decoration: inputDecoration('Target'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: _moneyValidator,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _monthly,
              decoration: inputDecoration('Cycle allocation'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: _moneyValidator,
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Save bucket',
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    return (value ?? '').trim().isEmpty ? 'Required' : null;
  }

  String? _moneyValidator(String? value) {
    final amount = _parseMoney(value ?? '');
    return amount == null || amount < 0 ? 'Enter a valid amount' : null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    AppScope.of(context).updateGoalBucketOverride(
      CollectionBucketOverride(
        id: widget.bucket.id,
        name: _name.text.trim(),
        role: _role.text.trim(),
        emoji: _emoji.text.trim().isEmpty
            ? widget.bucket.emoji
            : _emoji.text.trim(),
        current: _parseMoney(_current.text) ?? widget.bucket.current,
        target: _parseMoney(_target.text) ?? widget.bucket.target,
        monthly: _parseMoney(_monthly.text) ?? widget.bucket.monthly,
      ),
    );
    AppScope.of(context).saveProfile();
    Navigator.pop(context);
  }
}

class _GoalAllocationSheet extends StatefulWidget {
  const _GoalAllocationSheet({required this.bucket});

  final _GoalBucket bucket;

  @override
  State<_GoalAllocationSheet> createState() => _GoalAllocationSheetState();
}

class _GoalAllocationSheetState extends State<_GoalAllocationSheet> {
  static const double _sliderMin = 50;
  static const double _sliderStep = 50;

  late final TextEditingController _amountText;
  late double _amount;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _amount = math.min(
      math.max(_sliderMin, widget.bucket.monthly),
      math.max(_sliderMin, widget.bucket.remaining),
    );
    _amountText = TextEditingController(text: _plainMoney(_amount));
  }

  @override
  void dispose() {
    _amountText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sliderMax = _sliderMax;
    final sliderDivisions = ((sliderMax - _sliderMin) / _sliderStep).round();
    return _GoalSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add to ${widget.bucket.accountName}',
            style: GoogleFonts.fredoka(
              color: _title,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.bucket.linked
                ? 'This moves money from FakeMaya Wallet to ${widget.bucket.accountName}.'
                : 'Manual allocation for this cycle.',
            style: const TextStyle(
              color: _body,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bellySoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Text(
                  'ALLOCATION AMOUNT',
                  style: TextStyle(
                    color: _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  money(_amount),
                  style: GoogleFonts.nunito(
                    color: _title,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountText,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: inputDecoration('Enter allocation amount'),
                  onChanged: _setAmountFromText,
                ),
                const SizedBox(height: 6),
                Slider(
                  min: _sliderMin,
                  max: sliderMax,
                  divisions: sliderDivisions <= 0 ? null : sliderDivisions,
                  value: _amount.clamp(_sliderMin, sliderMax),
                  onChanged: _setAmountFromSlider,
                ),
                Row(
                  children: [
                    const Text(
                      '₱50',
                      style:
                          TextStyle(color: _body, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text(
                      'Suggested ${money(widget.bucket.monthly)}',
                      style: const TextStyle(
                        color: _body,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: _syncing ? 'Syncing...' : 'Allocate ${money(_amount)}',
            icon: Icons.savings_rounded,
            enabled: !_syncing && _amount > 0,
            onPressed: _allocate,
          ),
        ],
      ),
    );
  }

  double get _sliderMax {
    final rawMax = math.max(
      _amount,
      math.max(widget.bucket.remaining, widget.bucket.monthly),
    );
    return math.max(_sliderMin, _roundUpToNearest(rawMax, _sliderStep));
  }

  void _setAmountFromText(String value) {
    final parsed = _parseMoney(value);
    setState(() => _amount = parsed == null || parsed < 0 ? 0 : parsed);
  }

  void _setAmountFromSlider(double value) {
    final snapped = _roundToNearest(value, _sliderStep).clamp(
      _sliderMin,
      _sliderMax,
    );
    setState(() {
      _amount = snapped.toDouble();
      _amountText.text = _plainMoney(_amount);
      _amountText.selection = TextSelection.collapsed(
        offset: _amountText.text.length,
      );
    });
  }

  static double _roundUpToNearest(double value, double step) {
    return (value / step).ceil() * step;
  }

  static String _plainMoney(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  Future<void> _allocate() async {
    if (_syncing || _amount <= 0) return;
    setState(() => _syncing = true);
    try {
      await AppScope.of(context).allocateToGoalBucket(
        bucket: widget.bucket.toOverride(),
        amount: _amount,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.bucket.linked
                ? 'Allocated to ${widget.bucket.accountName} and synced to FakeMaya.'
                : 'Allocation saved.',
          ),
        ),
      );
    } on FakeMayaException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }
}

class _GoalSheetFrame extends StatelessWidget {
  const _GoalSheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

double? _parseMoney(String value) {
  final normalized = value.replaceAll(RegExp(r'[^0-9.]'), '');
  return double.tryParse(normalized);
}

class _GoalCycleStepRow extends StatelessWidget {
  const _GoalCycleStepRow({
    required this.step,
    required this.index,
    required this.isLast,
  });

  final _GoalCycleStep step;
  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: step.color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(step.icon, color: step.color, size: 20),
                    Positioned(
                      right: 4,
                      bottom: 3,
                      child: Text(
                        '$index',
                        style: TextStyle(
                          color: step.color,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    color: _title,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  step.body,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (step.note != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: step.color.withOpacity(.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      step.note!,
                      style: TextStyle(
                        color: step.color,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final settings = [
      _SettingData(
        'User Selections',
        Icons.fact_check_outlined,
        'View',
        () => _push(context, const UserSelectionsScreen()),
      ),
      const _SettingData('Notifications', Icons.notifications_outlined, 'On'),
      const _SettingData('Privacy & security', Icons.shield_outlined, ''),
      _SettingData(
        'Linked accounts',
        Icons.credit_card_outlined,
        state.hasFakeMayaLink ? '1' : 'None',
        () => _push(context, const LinkedAccountsScreen()),
      ),
      const _SettingData('Appearance', Icons.palette_outlined, 'Light'),
    ];
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(eyebrow: 'PROFILE', title: 'You'),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: _bellySoft,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (state.photoUrl ?? '').isEmpty
                          ? Image.asset(
                              'assets/images/shellby_wave.webp',
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              state.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/shellby_wave.webp',
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.name.isEmpty ? 'Shelby user' : state.name,
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: _title,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      state.email.isEmpty
                          ? 'Profile saved securely'
                          : state.email,
                      style: TextStyle(
                        color: _body,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _ProfileStatTile(
                            emoji: '🔥',
                            value: '7',
                            label: 'streak',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ProfileStatTile(
                            emoji: '🎯',
                            value: '${state.healthScore.round()}',
                            label: 'health',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ProfileStatTile(
                            emoji: '💰',
                            value: '₱320',
                            label: 'saved',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Settings',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _title,
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: settings.asMap().entries.map((e) {
                    final s = e.value;
                    final isLast = e.key == settings.length - 1;
                    return Column(
                      children: [
                        _SettingsRow(data: s),
                        if (!isLast)
                          const Divider(
                            height: 1,
                            color: _border,
                            indent: 70,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              SecondaryButton(
                label: 'Sign out',
                icon: Icons.logout_rounded,
                onPressed: () async {
                  await AppScope.of(context).signOut();
                  if (!context.mounted) return;
                  _pushReplacement(context, const WelcomeScreen());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingData {
  const _SettingData(this.title, this.icon, this.value, [this.onTap]);

  final String title;
  final IconData icon;
  final String value;
  final VoidCallback? onTap;
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.data});

  final _SettingData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _bellySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: _purple, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                data.title,
                style: const TextStyle(
                  color: _title,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (data.value.isNotEmpty)
              Text(
                data.value,
                style: const TextStyle(
                  color: _body,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: _body, size: 20),
          ],
        ),
      ),
    );
  }
}

class LinkedAccountsScreen extends StatelessWidget {
  const LinkedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final link = state.fakeMayaLink;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _SelectionsHeader(
              title: 'Linked accounts',
              subtitle:
                  'Connect wallets so Shellby can read balances for your plan.',
              onBack: () => Navigator.maybePop(context),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F8EE),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Color(0xFF00A650),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'FakeMaya',
                                    style: GoogleFonts.fredoka(
                                      color: _title,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    link == null
                                        ? 'Not linked'
                                        : 'Linked as ${link.email}',
                                    style: const TextStyle(
                                      color: _body,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _LinkStatusPill(linked: link != null),
                          ],
                        ),
                        const SizedBox(height: 18),
                        if (link == null) ...[
                          const Text(
                            'Log in to FakeMaya inside Shellby to connect your wallet, savings, time deposit, and goal balances.',
                            style: TextStyle(
                              color: _body,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            label: 'Link account to FakeMaya',
                            icon: Icons.link_rounded,
                            onPressed: () => _showFakeMayaLogin(context),
                          ),
                        ] else ...[
                          _FakeMayaBalanceGrid(summary: link.summary),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: SecondaryButton(
                                  label: 'Refresh',
                                  icon: Icons.sync_rounded,
                                  onPressed: () => _refreshFakeMaya(context),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SecondaryButton(
                                  label: 'Unlink',
                                  icon: Icons.link_off_rounded,
                                  onPressed: () => _unlinkFakeMaya(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (link != null) ...[
                    const SizedBox(height: 16),
                    _FakeMayaAccountList(summary: link.summary),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFakeMayaLogin(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FakeMayaLoginSheet(),
    );
  }

  Future<void> _refreshFakeMaya(BuildContext context) async {
    await _runLinkedAccountAction(
      context,
      action: () => AppScope.of(context).refreshFakeMayaAccount(),
      success: 'FakeMaya balances refreshed.',
    );
  }

  Future<void> _unlinkFakeMaya(BuildContext context) async {
    await _runLinkedAccountAction(
      context,
      action: () => AppScope.of(context).unlinkFakeMayaAccount(),
      success: 'FakeMaya unlinked from Shellby.',
    );
  }

  Future<void> _runLinkedAccountAction(
    BuildContext context, {
    required Future<void> Function() action,
    required String success,
  }) async {
    try {
      await action();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(success)));
    } on FakeMayaException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }
}

class _FakeMayaLoginSheet extends StatefulWidget {
  const _FakeMayaLoginSheet();

  @override
  State<_FakeMayaLoginSheet> createState() => _FakeMayaLoginSheetState();
}

class _FakeMayaLoginSheetState extends State<_FakeMayaLoginSheet> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00B14F),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign in to FakeMaya',
                          style: GoogleFonts.fredoka(
                            color: _title,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          'Shellby will read your balances after login.',
                          style: TextStyle(
                            color: _body,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: inputDecoration('FakeMaya email'),
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'Enter your email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: inputDecoration('FakeMaya password'),
                validator: (value) =>
                    (value ?? '').isEmpty ? 'Enter your password' : null,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: _loading ? 'Linking...' : 'Link account',
                icon: Icons.lock_open_rounded,
                enabled: !_loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AppScope.of(context).linkFakeMayaAccount(
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FakeMaya is now linked to Shellby.')),
      );
    } on FakeMayaException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _LinkStatusPill extends StatelessWidget {
  const _LinkStatusPill({required this.linked});

  final bool linked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: linked ? _brand.withOpacity(.12) : _bellySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        linked ? 'Linked' : 'Available',
        style: TextStyle(
          color: linked ? _brand : _purple,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FakeMayaBalanceGrid extends StatelessWidget {
  const _FakeMayaBalanceGrid({required this.summary});

  final FakeMayaAccountSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _LinkedBalanceTile(
                label: 'Total balance',
                value: money(summary.totalBalance),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LinkedBalanceTile(
                label: 'Available credit',
                value: money(summary.availableCredit),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FakeMayaAccountList extends StatelessWidget {
  const _FakeMayaAccountList({required this.summary});

  final FakeMayaAccountSummary summary;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Wallet', Icons.account_balance_wallet_rounded, summary.wallet),
      ('Savings', Icons.savings_rounded, summary.savings),
      ('Time Deposit', Icons.lock_clock_rounded, summary.timeDeposit),
      ('Personal Goal', Icons.flag_rounded, summary.goalBalance),
      ('Easy Credit Used', Icons.credit_card_rounded, summary.creditUsed),
    ];
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final row = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(row.$2, color: _purple),
                title: Text(
                  row.$1,
                  style: const TextStyle(
                    color: _title,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                trailing: Text(
                  money(row.$3),
                  style: const TextStyle(
                    color: _title,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (entry.key != rows.length - 1)
                const Divider(height: 1, color: _border, indent: 70),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _LinkedBalanceTile extends StatelessWidget {
  const _LinkedBalanceTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _body,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: _title,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class UserSelectionsScreen extends StatelessWidget {
  const UserSelectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _SelectionsHeader(
              title: 'User Selections',
              subtitle: 'Details saved from your onboarding choices.',
              onBack: () => Navigator.maybePop(context),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _SelectionSection(
                    icon: Icons.person_rounded,
                    title: 'Account Details',
                    rows: [
                      ('Name', _fallback(state.name, 'Not provided')),
                      ('Email', _fallback(state.email, 'Not provided')),
                    ],
                  ),
                  _SelectionSection(
                    icon: Icons.work_rounded,
                    title: 'Profile Context',
                    rows: [
                      (
                        'Age & life stage',
                        _fallback(state.age, 'Not selected')
                      ),
                      (
                        'Occupation',
                        _fallback(state.occupation, 'Not provided'),
                      ),
                      ('Industry', state.industry),
                    ],
                  ),
                  _SelectionSection(
                    icon: Icons.event_repeat_rounded,
                    title: 'Money Rhythm',
                    rows: [
                      ('Employment status', state.employmentStatus),
                      ('Income type', state.incomeType),
                      ('Income rhythm', state.incomeRhythm),
                      ('Bills rhythm', state.billsRhythm),
                      ('Financial responsibility', state.responsibility),
                      ('Check-in rhythm', state.checkInRhythm),
                    ],
                  ),
                  _SelectionSection(
                    icon: Icons.chat_bubble_rounded,
                    title: 'Conversation Choices',
                    rows: [
                      ('Primary concern', state.primaryConcern),
                      (
                        'Starting point',
                        _fallback(
                          state.chatSurfaceSummary,
                          'No conversation summary recorded.',
                        ),
                      ),
                      (
                        'Goal focus',
                        _fallback(
                            state.chatGoalFocusSummary, state.selectedGoal),
                      ),
                      (
                        'Timeframe',
                        _fallback(state.chatTimeframeSummary, 'Not selected'),
                      ),
                      (
                        'Pace',
                        _fallback(state.chatDifficultySummary, 'Not selected'),
                      ),
                      (
                        'Helpful reminders',
                        _fallback(state.chatSituationsSummary, 'Not selected'),
                      ),
                      (
                        'Hurdles to watch',
                        _fallback(state.chatChallengesSummary, 'Not selected'),
                      ),
                    ],
                  ),
                  _SelectionSection(
                    icon: Icons.flag_rounded,
                    title: 'Plan Setup',
                    onEdit: () => _showPlanSetupEditor(context, state),
                    rows: [
                      ('Selected goal', state.selectedGoal),
                      ('Goal description', state.selectedGoalDescription),
                      if (state.selectedGoal == 'Irregular Income Buffer')
                        (
                          'Income floor',
                          state.irregularIncomeFloor > 0
                              ? money(state.irregularIncomeFloor)
                              : 'Not set',
                        ),
                      ('Target rule', _targetRuleForGoal(state)),
                      (
                        'Monthly target',
                        money(_monthlyAllocationFromSelections(state)),
                      ),
                      (
                        'First app action',
                        _firstTrackingActionForGoal(state.selectedGoal),
                      ),
                      (
                        'Emotional logs',
                        state.emotionalLogsEnabled ? 'Enabled' : 'Disabled',
                      ),
                      (
                        'Stress indicators',
                        state.stressIndicatorsEnabled ? 'Enabled' : 'Disabled',
                      ),
                    ],
                  ),
                  _SelectionSection(
                    icon: Icons.verified_user_rounded,
                    title: 'Permissions & Consent',
                    rows: [
                      ('Notifications', _yesNo(state.notificationsAllowed)),
                      (
                        'Third-party data linking',
                        _yesNo(state.thirdPartyDataLinkingAllowed),
                      ),
                      (
                        'Automatic data gathering',
                        _yesNo(state.automaticDataGatheringAllowed),
                      ),
                      (
                        'Personal data consent',
                        _yesNo(state.personalDataConsent)
                      ),
                      (
                        'Data retention consent',
                        _yesNo(state.dataRetentionConsent)
                      ),
                    ],
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

class _SelectionsHeader extends StatelessWidget {
  const _SelectionsHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            color: _purple,
            icon: const Icon(Icons.chevron_left_rounded, size: 32),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(title, style: Theme.of(context).textTheme.headlineLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionSection extends StatelessWidget {
  const _SelectionSection({
    required this.icon,
    required this.title,
    required this.rows,
    this.onEdit,
  });

  final IconData icon;
  final String title;
  final List<(String, String)> rows;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _bellySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: _purple, size: 20),
                ),
                const SizedBox(width: 12),
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
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Change'),
                    style: TextButton.styleFrom(
                      foregroundColor: _purple,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...rows.map(
              (row) => SummaryRow(row.$1, row.$2),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showPlanSetupEditor(
  BuildContext context,
  AppState state,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PlanSetupEditorSheet(state: state),
  );
}

class _PlanSetupEditorSheet extends StatefulWidget {
  const _PlanSetupEditorSheet({required this.state});

  final AppState state;

  @override
  State<_PlanSetupEditorSheet> createState() => _PlanSetupEditorSheetState();
}

class _PlanSetupEditorSheetState extends State<_PlanSetupEditorSheet> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: .88,
      child: _GoalSheetFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Change plan setup',
              style: GoogleFonts.fredoka(
                color: _title,
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose a new goal. Its target and tracking actions will update with the plan.',
              style: TextStyle(
                color: _body,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            ..._goalBranches.map(
              (branch) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(branch.icon, color: _purple, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            branch.layer,
                            style: const TextStyle(
                              color: _title,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...[
                      _defaultConcernFor(branch),
                      ...branch.concerns,
                    ].map(
                      (concern) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PlanSetupOption(
                          concern: concern,
                          selected:
                              concern.goalTitle == widget.state.selectedGoal,
                          enabled: !_saving,
                          onTap: () => _selectGoal(branch, concern),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GoalConcern _defaultConcernFor(GoalBranch branch) {
    return GoalConcern(
      feltNeed: branch.layerDescription,
      followUp: '',
      goalTitle: branch.defaultGoalTitle,
      goalDescription: branch.defaultGoalDescription,
      keywords: const [],
      actionIds: const [],
      backgroundEffect: 'Uses the default plan for this focus area.',
    );
  }

  Future<void> _selectGoal(GoalBranch branch, GoalConcern concern) async {
    if (_saving) return;
    setState(() => _saving = true);
    final state = widget.state;
    state.primaryConcern = branch.layer;
    _applyRecommendedConcern(state, concern);
    state.updateGuidedChatSummary(
      goalFocus: _optionSummaryForGoalTitle(branch.layer, concern.goalTitle),
    );
    await state.saveProfile();
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Plan changed to ${concern.goalTitle}.')),
    );
  }
}

class _PlanSetupOption extends StatelessWidget {
  const _PlanSetupOption({
    required this.concern,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final GoalConcern concern;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _bellySoft : _bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? _purple : _border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? _purple : _body,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      concern.goalTitle,
                      style: const TextStyle(
                        color: _title,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      concern.goalDescription,
                      style: const TextStyle(
                        color: _body,
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _fallback(String value, String fallback) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

String _yesNo(bool value) => value ? 'Yes' : 'No';

// ─── Activity page ────────────────────────────────────────────────────────────

class _TxData {
  const _TxData(
    this.name,
    this.category,
    this.amount,
    this.icon,
    this.color, {
    this.age = 'Just now',
    this.source = 'Shellby',
    this.transaction,
  });

  final String name;
  final String category;
  final double amount;
  final IconData icon;
  final Color color;
  final String age;
  final String source;
  final FakeMayaTransaction? transaction;

  bool get countsAsIncome {
    final linkedTransaction = transaction;
    if (linkedTransaction == null) return amount > 0;
    return linkedTransaction.title.toLowerCase().contains('cash in');
  }

  bool get countsAsExpense {
    final linkedTransaction = transaction;
    if (linkedTransaction == null) return amount < 0;
    final title = linkedTransaction.title.toLowerCase();
    return title.contains('send money') || title.contains('sent money');
  }

  double get incomeAmount => countsAsIncome ? amount.abs() : 0;
  double get expenseAmount => countsAsExpense ? amount.abs() : 0;

  DateTime? get occurredAt => transaction?.createdAt?.toLocal();

  String get timeLabel {
    final time = occurredAt;
    if (time == null) return age;
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${time.hour < 12 ? 'AM' : 'PM'}';
  }

  bool matchesFilter(String filter) {
    if (filter == 'All') return true;
    if (filter == 'Money in') return amount > 0;
    if (filter == 'Money out') return amount < 0;
    return category.toLowerCase().contains(filter.toLowerCase()) ||
        name.toLowerCase().contains(filter.toLowerCase());
  }
}

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  static const _transactionsPerPage = 10;

  String _filter = 'All';
  final ScrollController _scrollController = ScrollController();
  int _visibleTransactionCount = _transactionsPerPage;
  int _filteredTransactionCount = 0;

  static const _filters = ['All', 'Money in', 'Money out', 'Wallet', 'Savings'];

  static const _groups = [
    (
      'TODAY',
      [
        _TxData(
            'Blue Bottle', 'Food & drink', -5.40, Icons.coffee_rounded, _brand),
        _TxData('Uniqlo', 'Shopping', -39.90, Icons.shopping_bag_rounded,
            Color(0xFFEE7E9C)),
      ],
    ),
    (
      'YESTERDAY',
      [
        _TxData(
            'Payday', 'Income', 2100.00, Icons.arrow_downward_rounded, _purple),
        _TxData('Electric bill', 'Bills', -64.00, Icons.bolt_rounded, _amber),
        _TxData('Metro card', 'Transport', -20.00, Icons.directions_bus_rounded,
            Color(0xFF6AA8F0)),
      ],
    ),
    (
      'MAY 28',
      [
        _TxData(
            'Netflix', 'Subscription', -15.99, Icons.play_circle_rounded, _red),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadOlderTransactionsIfNeeded);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadOlderTransactionsIfNeeded)
      ..dispose();
    super.dispose();
  }

  void _loadOlderTransactionsIfNeeded() {
    if (!_scrollController.hasClients ||
        _visibleTransactionCount >= _filteredTransactionCount ||
        _scrollController.position.extentAfter > 160) {
      return;
    }

    setState(() {
      _visibleTransactionCount = math.min(
        _visibleTransactionCount + _transactionsPerPage,
        _filteredTransactionCount,
      );
    });
  }

  void _selectFilter(String filter) {
    if (_filter == filter) return;
    setState(() {
      _filter = filter;
      _visibleTransactionCount = _transactionsPerPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final linked = state.hasFakeMayaLink;
    final fakeMayaTransactions =
        state.fakeMayaLink?.summary.transactions ?? const [];
    final allTransactions = linked
        ? fakeMayaTransactions.map(_txFromFakeMaya).toList()
        : _groups.expand((group) => group.$2).toList();
    if (linked) {
      allTransactions.sort((a, b) {
        final aTime = a.occurredAt;
        final bTime = b.occurredAt;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });
    }
    final filteredTransactions = allTransactions
        .where((transaction) => transaction.matchesFilter(_filter))
        .toList();
    _filteredTransactionCount = filteredTransactions.length;
    final hasOlderTransactions =
        linked && _visibleTransactionCount < _filteredTransactionCount;
    final groups = linked
        ? _groupTransactionsByDate(
            filteredTransactions.take(_visibleTransactionCount),
          )
        : _groups;
    final visibleGroups = groups
        .map((group) => linked
            ? group
            : (
                group.$1,
                group.$2.where((tx) => tx.matchesFilter(_filter)).toList(),
              ))
        .where((group) => group.$2.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(eyebrow: 'EVERY MOVE', title: 'Activity'),
        if (linked) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Tracking movement from ${state.fakeMayaLink!.email}',
                    style: const TextStyle(
                      color: _body,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _refreshFakeMaya(context),
                  icon: const Icon(Icons.sync_rounded, size: 18),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final active = _filter == _filters[i];
              return GestureDetector(
                onTap: () => _selectFilter(_filters[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: active ? _brand : _surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: active ? _brand : _border,
                    ),
                  ),
                  child: Text(
                    _filters[i],
                    style: TextStyle(
                      color: active ? Colors.white : _title,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: visibleGroups.isEmpty
              ? _EmptyActivity(linked: linked)
              : ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    _ActivityCalendarSummary(transactions: allTransactions),
                    const SizedBox(height: 18),
                    ...visibleGroups.map((group) {
                      final rows = group.$2;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                _ActivityDateHeader(
                                  label: group.$1,
                                  transactions: rows,
                                ),
                                const Divider(height: 1, color: _border),
                                ...rows.asMap().entries.map((e) {
                                  final tx = e.value;
                                  final isLast = e.key == rows.length - 1;
                                  return Column(
                                    children: [
                                      _ActivityRow(
                                        data: tx,
                                        onTap: tx.transaction == null
                                            ? null
                                            : () => _showTransactionLabelSheet(
                                                  context,
                                                  tx.transaction!,
                                                ),
                                      ),
                                      if (!isLast)
                                        const Divider(
                                          height: 1,
                                          color: _border,
                                          indent: 70,
                                        ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),
                    if (hasOlderTransactions)
                      const Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 12),
                        child: Center(
                          child: Text(
                            'Scroll down to load older transactions',
                            style: TextStyle(
                              color: _body,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _refreshFakeMaya(BuildContext context) async {
    try {
      await AppScope.of(context).refreshFakeMayaAccount();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FakeMaya activity refreshed.')),
      );
    } on FakeMayaException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  static List<(String, List<_TxData>)> _groupTransactionsByDate(
    Iterable<_TxData> transactions,
  ) {
    final groups = <String, List<_TxData>>{};
    for (final transaction in transactions) {
      final label = _dateLabel(transaction.occurredAt);
      groups.putIfAbsent(label, () => []).add(transaction);
    }
    return groups.entries.map((entry) => (entry.key, entry.value)).toList();
  }

  static String _dateLabel(DateTime? date) {
    if (date == null) return 'Earlier';
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final year = date.year == DateTime.now().year ? '' : ', ${date.year}';
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} '
        '${date.day}$year';
  }

  Future<void> _showTransactionLabelSheet(
    BuildContext context,
    FakeMayaTransaction transaction,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TransactionLabelSheet(transaction: transaction),
    );
  }

  static _TxData _txFromFakeMaya(FakeMayaTransaction tx) {
    final amount = tx.amount;
    final title = tx.title.toLowerCase();
    final detail = tx.detail.toLowerCase();
    if (title.contains('cash in') ||
        title.contains('loan') ||
        title.contains('opened')) {
      return _TxData(
        tx.title,
        _transactionSubtitle(tx),
        amount,
        Icons.arrow_downward_rounded,
        _brand,
        age: tx.age,
        source: 'FakeMaya',
        transaction: tx,
      );
    }
    if (title.contains('sent') || title.contains('repayment')) {
      return _TxData(
        tx.title,
        _transactionSubtitle(tx),
        amount,
        Icons.arrow_upward_rounded,
        _red,
        age: tx.age,
        source: 'FakeMaya',
        transaction: tx,
      );
    }
    if (title.contains('deposit') ||
        detail.contains('savings') ||
        detail.contains('goal')) {
      return _TxData(
        tx.title,
        _transactionSubtitle(tx),
        amount,
        Icons.savings_rounded,
        _purple,
        age: tx.age,
        source: 'FakeMaya',
        transaction: tx,
      );
    }
    return _TxData(
      tx.title,
      _transactionSubtitle(tx),
      amount,
      amount >= 0 ? Icons.add_card_rounded : Icons.payments_rounded,
      amount >= 0 ? _brand : _red,
      age: tx.age,
      source: 'FakeMaya',
      transaction: tx,
    );
  }

  static String _transactionSubtitle(FakeMayaTransaction transaction) {
    final detail = transaction.detail.trim();
    final category = transaction.category?.trim() ?? '';
    if (category.isEmpty || category.toLowerCase() == detail.toLowerCase()) {
      return detail;
    }
    return '$detail • $category';
  }
}

class _ActivityCalendarSummary extends StatefulWidget {
  const _ActivityCalendarSummary({required this.transactions});

  final List<_TxData> transactions;

  @override
  State<_ActivityCalendarSummary> createState() =>
      _ActivityCalendarSummaryState();
}

class _ActivityCalendarSummaryState extends State<_ActivityCalendarSummary> {
  bool _expanded = false;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final income =
        widget.transactions.fold(0.0, (sum, tx) => sum + tx.incomeAmount);
    final expense =
        widget.transactions.fold(0.0, (sum, tx) => sum + tx.expenseAmount);
    final balance = income - expense;
    final days = _calendarDays(widget.transactions, _month);

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Monthly',
                style: TextStyle(
                  color: _purple,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Icon(Icons.expand_more_rounded, color: _purple, size: 18),
              const Spacer(),
              if (_expanded) ...[
                IconButton(
                  onPressed: () => setState(() {
                    _month = DateTime(_month.year, _month.month - 1);
                  }),
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: _purple,
                  visualDensity: VisualDensity.compact,
                ),
                Text(
                  '${_month.year} ${_monthLabel(_month.month)}',
                  style: GoogleFonts.fredoka(
                    color: _title,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    _month = DateTime(_month.year, _month.month + 1);
                  }),
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: _purple,
                  visualDensity: VisualDensity.compact,
                ),
                const Spacer(),
              ] else
                Text(
                  '${_month.year} ${_monthLabel(_month.month)}',
                  style: GoogleFonts.fredoka(
                    color: _title,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
                color: _purple,
                style: IconButton.styleFrom(backgroundColor: _bellySoft),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      _WeekdayLabel('Mon'),
                      _WeekdayLabel('Tue'),
                      _WeekdayLabel('Wed'),
                      _WeekdayLabel('Thu'),
                      _WeekdayLabel('Fri'),
                      _WeekdayLabel('Sat'),
                      _WeekdayLabel('Sun'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: days.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: .72,
                    ),
                    itemBuilder: (context, index) {
                      final day = days[index];
                      return _CalendarDayTile(
                        day: day,
                        selected: day.inCurrentMonth &&
                            day.day == DateTime.now().day &&
                            _month.year == DateTime.now().year &&
                            _month.month == DateTime.now().month,
                      );
                    },
                  ),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
          Row(
            children: [
              Expanded(
                child: _ActivitySummaryStat(
                  label: 'Income',
                  value: money(income),
                  color: _brand,
                ),
              ),
              Expanded(
                child: _ActivitySummaryStat(
                  label: 'Expense',
                  value: money(expense),
                  color: _red,
                ),
              ),
              Expanded(
                child: _ActivitySummaryStat(
                  label: 'Balance',
                  value: money(balance),
                  color: _title,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static List<_CalendarDayData> _calendarDays(
    List<_TxData> transactions,
    DateTime month,
  ) {
    final first = DateTime(month.year, month.month);
    final nextMonth = DateTime(month.year, month.month + 1);
    final daysInMonth = nextMonth.difference(first).inDays;
    final leading = first.weekday - DateTime.monday;
    final totalCells = ((leading + daysInMonth + 6) ~/ 7) * 7;
    final cells = <_CalendarDayData>[];
    for (var index = 0; index < totalCells; index++) {
      final date = first.add(Duration(days: index - leading));
      cells.add(
        _CalendarDayData(
          day: date.day,
          income: 0,
          expense: 0,
          inCurrentMonth: date.month == month.month,
        ),
      );
    }

    for (var i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      final dayNumber = (i % daysInMonth) + 1;
      final slot = leading + dayNumber - 1;
      final current = cells[slot];
      cells[slot] = current.copyWith(
        income: current.income + tx.incomeAmount,
        expense: current.expense + tx.expenseAmount,
      );
    }
    return cells;
  }

  static String _monthLabel(int month) {
    const labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return labels[month - 1];
  }
}

class _CalendarDayData {
  const _CalendarDayData({
    required this.day,
    required this.income,
    required this.expense,
    required this.inCurrentMonth,
  });

  final int day;
  final double income;
  final double expense;
  final bool inCurrentMonth;

  _CalendarDayData copyWith({double? income, double? expense}) {
    return _CalendarDayData(
      day: day,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      inCurrentMonth: inCurrentMonth,
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: _body,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CalendarDayTile extends StatelessWidget {
  const _CalendarDayTile({required this.day, required this.selected});

  final _CalendarDayData day;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selected ? const Color(0xFFFFDD64) : _bg;
    final borderColor = selected ? Colors.transparent : _border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              color: day.inCurrentMonth ? _purple : _body.withOpacity(.45),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (day.income > 0)
            FittedBox(
              child: Text(
                money(day.income).replaceFirst('₱ ', '₱'),
                style: const TextStyle(
                  color: _brand,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          if (day.expense > 0)
            FittedBox(
              child: Text(
                money(day.expense).replaceFirst('₱ ', '₱'),
                style: const TextStyle(
                  color: _red,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivitySummaryStat extends StatelessWidget {
  const _ActivitySummaryStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _body,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: GoogleFonts.nunito(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity({required this.linked});

  final bool linked;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        AppCard(
          child: Column(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: _purple,
                size: 34,
              ),
              const SizedBox(height: 10),
              Text(
                linked
                    ? 'No matching FakeMaya activity yet.'
                    : 'No activity yet.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _title,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                linked
                    ? 'Make a wallet, savings, credit, or loan movement in FakeMaya, then refresh.'
                    : 'Link FakeMaya to see wallet movement here.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _body,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityDateHeader extends StatelessWidget {
  const _ActivityDateHeader({
    required this.label,
    required this.transactions,
  });

  final String label;
  final List<_TxData> transactions;

  @override
  Widget build(BuildContext context) {
    final income =
        transactions.fold(0.0, (sum, item) => sum + item.incomeAmount);
    final expense =
        transactions.fold(0.0, (sum, item) => sum + item.expenseAmount);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _title,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (income > 0) ...[
            const Text('IN ',
                style: TextStyle(
                    color: _green, fontSize: 12, fontWeight: FontWeight.w900)),
            Text(money(income),
                style: const TextStyle(
                    color: _title, fontSize: 13, fontWeight: FontWeight.w900)),
          ],
          if (income > 0 && expense > 0) const SizedBox(width: 10),
          if (expense > 0) ...[
            const Text('OUT ',
                style: TextStyle(
                    color: _red, fontSize: 12, fontWeight: FontWeight.w900)),
            Text(money(expense),
                style: const TextStyle(
                    color: _title, fontSize: 13, fontWeight: FontWeight.w900)),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.data, this.onTap});
  final _TxData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final positive = data.amount > 0;
    final transaction = data.transaction;
    final needsLabel = transaction?.isWalletCashMovement == true &&
        transaction?.isLabeled == false;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: data.color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(data.icon, color: data.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        color: _title,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            data.category,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _body,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (needsLabel) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF2D8),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Unlabeled',
                              style: TextStyle(
                                color: Color(0xFF9A6500),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${positive ? '+' : '-'}₱${data.amount.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      color: positive ? _green : _red,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    data.timeLabel,
                    style: const TextStyle(
                      color: _body,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionLabelSheet extends StatefulWidget {
  const _TransactionLabelSheet({required this.transaction});

  final FakeMayaTransaction transaction;

  @override
  State<_TransactionLabelSheet> createState() => _TransactionLabelSheetState();
}

class _TransactionLabelSheetState extends State<_TransactionLabelSheet> {
  static const _incomeCategories = [
    'Salary',
    'Business income',
    'Transfer',
    'Refund',
    'Gift',
    'Other income',
  ];
  static const _expenseCategories = [
    'Food & drink',
    'Transport',
    'Bills & utilities',
    'Housing',
    'Groceries',
    'Shopping',
    'Education',
    'Health',
    'Insurance',
    'Emergency fund',
    'Debt payment',
    'Investment',
    'Time deposit',
    'Entertainment',
    'Travel',
    'Personal goal',
    'Gifts & giving',
    'Transfer',
    'Other expense',
  ];
  static const _tags = [
    'Personal',
    'Work',
    'Family',
    'Recurring',
    'Reimbursable',
  ];

  late String? _category = widget.transaction.category;
  late final TextEditingController _subcategory = TextEditingController(
    text: widget.transaction.subcategory ?? '',
  );
  late String? _tag = widget.transaction.tag;
  late final TextEditingController _note = TextEditingController(
    text: widget.transaction.note ?? '',
  );
  late bool _excluded = widget.transaction.excludedFromInsights;
  bool _saving = false;

  @override
  void dispose() {
    _subcategory.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final categories =
        transaction.amount >= 0 ? _incomeCategories : _expenseCategories;
    return _GoalSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Label transaction',
                      style: GoogleFonts.fredoka(
                        color: _title,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        color: _body,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${transaction.amount >= 0 ? '+' : '-'}₱${transaction.amount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  color: transaction.amount >= 0 ? _green : _red,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _TransactionDetailLine(
            label: 'Type',
            value: transaction.amount >= 0 ? 'Money in' : 'Money out',
          ),
          _TransactionDetailLine(label: 'Account', value: 'FakeMaya Wallet'),
          _TransactionDetailLine(
            label: transaction.title.toLowerCase().contains('cash in')
                ? 'Sender'
                : transaction.title.toLowerCase().contains('sent')
                    ? 'Recipient'
                    : 'Details',
            value: transaction.detail,
          ),
          _TransactionDetailLine(label: 'Time', value: transaction.age),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: categories.contains(_category) ? _category : null,
            decoration: inputDecoration('Choose a category').copyWith(
              labelText: 'Category',
            ),
            items: categories
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _subcategory,
            textCapitalization: TextCapitalization.words,
            decoration: inputDecoration('e.g. Ride hailing').copyWith(
              labelText: 'Subcategory (optional)',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _tags.contains(_tag) ? _tag : null,
            decoration: inputDecoration('Choose a tag').copyWith(
              labelText: 'Tag (optional)',
            ),
            items: _tags
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _tag = value),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _note,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: inputDecoration('Add context for this transaction')
                .copyWith(labelText: 'Note (optional)'),
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _excluded,
            activeColor: _brand,
            title: const Text(
              'Exclude from insights',
              style: TextStyle(color: _title, fontWeight: FontWeight.w800),
            ),
            subtitle: const Text(
              'Shellby won’t use this transaction when learning patterns.',
              style: TextStyle(color: _body, fontSize: 12),
            ),
            onChanged: (value) => setState(() => _excluded = value),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: _saving ? 'Saving…' : 'Save label',
            icon: Icons.check_rounded,
            enabled: _category != null && !_saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final category = _category;
    if (category == null || _saving) return;
    setState(() => _saving = true);
    await AppScope.of(context).labelFakeMayaTransaction(
      transactionId: widget.transaction.transactionId,
      category: category,
      subcategory: _optionalText(_subcategory.text),
      tag: _tag,
      note: _optionalText(_note.text),
      excludedFromInsights: _excluded,
    );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction label saved.')),
    );
  }

  static String? _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _TransactionDetailLine extends StatelessWidget {
  const _TransactionDetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: _body, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  const TextStyle(color: _title, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dashboard helper widgets ──────────────────────────────────────────────────

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart();

  @override
  Widget build(BuildContext context) {
    const heights = [0.55, 0.65, 0.50, 0.75, 0.85, 0.80, 1.0];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: heights.map((h) {
        final isLast = h == 1.0;
        return Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Container(
            width: 7,
            height: 40 * h,
            decoration: BoxDecoration(
              color: isLast ? _brand : _brand.withOpacity(.28),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.delta,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String delta;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: _body,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _title,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            delta,
            style: const TextStyle(
              color: _brand,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  const _GoalProgressCard({
    required this.emoji,
    required this.title,
    required this.current,
    required this.target,
    required this.percent,
    required this.color,
  });
  final String emoji;
  final String title;
  final double current;
  final double target;
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              color: color,
              backgroundColor: color.withOpacity(.12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '₱${current.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: _title,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'of ₱${target.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: _body,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.amount,
    required this.max,
  });
  final IconData icon;
  final Color color;
  final String label;
  final double amount;
  final double max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: _title,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '₱${amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: _title,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: amount / max,
                    minHeight: 6,
                    color: color,
                    backgroundColor: color.withOpacity(.12),
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

class _ProfileStatTile extends StatelessWidget {
  const _ProfileStatTile({
    required this.emoji,
    required this.value,
    required this.label,
  });
  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _title,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: _body,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared page header ────────────────────────────────────────────────────────
