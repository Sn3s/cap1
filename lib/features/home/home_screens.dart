// CHANGELOG (two-jar system):
// - GoalsPage: early-return to _TwoJarSetupFlow when needsTarget == 0 (first visit).
// - Added _TwoJarSetupFlow (3-screen setup: survival amount → split slider → confirm).
// - Added _TwoJarGoalsBody (jar cards + ledger trace — STEP 3 placeholder replaced in STEP 3).
// - _targetRuleForGoal updated to two-jar language.
// - onIncomeEvent overflow → undo SnackBar (STEP 4).
// - Bill shortfall sheet (STEP 4).
// - Monthly review card (STEP 5).
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
    final balance = state.hasFakeMayaLink ? state.linkedFakeMayaBalance : 0.0;
    final balanceParts = balance.toStringAsFixed(2).split('.');
    final spendable =
        state.hasFakeMayaLink ? state.fakeMayaLink!.summary.wallet : 0.0;
    final saved = state.hasFakeMayaLink
        ? state.fakeMayaLink!.summary.savings +
            state.fakeMayaLink!.summary.timeDeposit +
            state.fakeMayaLink!.summary.goalBalance
        : 0.0;

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
                              if (state.hasFakeMayaLink)
                                const SizedBox(height: 4),
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
                      child: Text(
                        state.hasFakeMayaLink
                            ? 'Shellby is watching your spending — insights will appear here as patterns build up.'
                            : 'Link your FakeMaya account to unlock spending insights from Shellby.',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _title,
                          height: 1.4,
                        ),
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
                          : 'Link FakeMaya to track',
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
                          : 'Link FakeMaya to track',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Your Pyramid',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _title,
                ),
              ),
              const SizedBox(height: 12),
              _PyramidCard(
                icon: Icons.account_balance_wallet_rounded,
                color: _brand,
                title: 'Cash Flow & Basic Needs',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const _CashFlowPage()),
                ),
                child: _CashFlowPyramidContent(state: state),
              ),
              const SizedBox(height: 10),
              _PyramidCard(
                icon: Icons.shield_rounded,
                color: _amber,
                title: 'Financial Safety',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const _FinancialSafetyPage()),
                ),
                child: _FinancialSafetyPyramidContent(state: state),
              ),
              const SizedBox(height: 10),
              _PyramidCard(
                icon: Icons.trending_up_rounded,
                color: _purple,
                title: 'Accumulating Wealth',
                onTap: () {},
                child: const _BlankPyramidContent(),
              ),
              const SizedBox(height: 10),
              _PyramidCard(
                icon: Icons.flag_rounded,
                color: const Color(0xFF6AA8F0),
                title: 'Financial Freedom',
                onTap: () {},
                child: const _BlankPyramidContent(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Pyramid widgets ───────────────────────────────────────────────────────────

class _PyramidCard extends StatelessWidget {
  const _PyramidCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
    required this.child,
  });
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBubble(icon,
                    color: color, background: color.withOpacity(.12)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _title,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _body, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _BlankPyramidContent extends StatelessWidget {
  const _BlankPyramidContent();
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Coming soon',
      style: TextStyle(color: _body, fontWeight: FontWeight.w600, fontSize: 13),
    );
  }
}

class _CashFlowPyramidContent extends StatelessWidget {
  const _CashFlowPyramidContent({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final total = state.totalCashFlowBudget;
    if (total == 0) {
      return const Text(
        'Tap to set up your monthly expense budget',
        style:
            TextStyle(color: _body, fontWeight: FontWeight.w600, fontSize: 13),
      );
    }
    // Compute this-month layer-1 spending from FakeMaya if available
    final now = DateTime.now();
    final spent = (state.fakeMayaLink?.summary.transactions ?? [])
        .where((t) =>
            t.amount < 0 &&
            t.isLabeled &&
            !t.excludedFromInsights &&
            (t.createdAt?.year == now.year &&
                t.createdAt?.month == now.month) &&
            _insightCategoryConfig(t.category ?? '').$1 == 1)
        .fold(0.0, (s, t) => s + t.amount.abs());
    final fill = (spent / total).clamp(0.0, 1.0);
    final pct = (fill * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              money(spent),
              style: const TextStyle(
                  color: _title, fontWeight: FontWeight.w800, fontSize: 13),
            ),
            const Spacer(),
            Text(
              'of ${money(total)}',
              style: const TextStyle(
                  color: _body, fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(width: 6),
            Text(
              '$pct%',
              style: TextStyle(
                  color: _brand, fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: fill,
            minHeight: 7,
            color: _brand,
            backgroundColor: _brand.withOpacity(.12),
          ),
        ),
      ],
    );
  }
}

class _FinancialSafetyPyramidContent extends StatelessWidget {
  const _FinancialSafetyPyramidContent({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final budget = state.safetyShieldMonthlyBase;
    final current = state.safetyShieldBalance;
    final max = budget * 6;
    final fill = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final months = budget > 0 ? current / budget : 0.0;
    if (budget == 0) {
      return const Text(
        'Set up Cash Flow & Basic Needs first',
        style:
            TextStyle(color: _body, fontWeight: FontWeight.w600, fontSize: 13),
      );
    }
    final marker3 = 1 / 6; // 3-month mark on 6-month scale
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              money(current),
              style: const TextStyle(
                  color: _title, fontWeight: FontWeight.w800, fontSize: 13),
            ),
            const Spacer(),
            Text(
              '${months.toStringAsFixed(1)} mo / 6 mo',
              style: const TextStyle(
                  color: _body, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: fill,
                minHeight: 7,
                color: _amber,
                backgroundColor: _amber.withOpacity(.12),
              ),
            ),
            // 3-month marker
            Positioned(
              left: MediaQuery.of(context).size.width * 0.6 * marker3 - 1,
              top: 0,
              bottom: 0,
              child: Container(width: 2, color: _amber.withOpacity(.6)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Spacer(),
            Text(
              '3mo',
              style: TextStyle(
                  color: _amber.withOpacity(.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.6 * (1 - marker3) -
                    28),
            Text(
              '6mo',
              style: const TextStyle(
                  color: _body, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Cash Flow setup page ──────────────────────────────────────────────────────

class _CashFlowPage extends StatefulWidget {
  const _CashFlowPage();
  @override
  State<_CashFlowPage> createState() => _CashFlowPageState();
}

class _CashFlowPageState extends State<_CashFlowPage> {
  late List<CashFlowExpense> _expenses;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_saving) {
      _expenses = List.of(AppScope.of(context)
          .cashFlowExpenses
          .map((e) => CashFlowExpense(e.name, e.budget)));
    }
  }

  void _add() {
    setState(() => _expenses.add(CashFlowExpense('', 0)));
  }

  void _remove(int i) => setState(() => _expenses.removeAt(i));

  Future<void> _save() async {
    setState(() => _saving = true);
    await AppScope.of(context).updateCashFlowExpenses(_expenses);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final total = _expenses.fold(0.0, (s, e) => s + e.budget);
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: _title,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LAYER 1',
                          style: TextStyle(
                              color: _body,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2),
                        ),
                        Text('Cash Flow & Basic Needs',
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (total > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: _brand.withOpacity(.1),
                          borderRadius: BorderRadius.circular(18)),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded,
                              color: _brand),
                          const SizedBox(width: 12),
                          Text(
                            'Total budget: ${money(total)}',
                            style: const TextStyle(
                                color: _title,
                                fontWeight: FontWeight.w800,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ..._expenses.asMap().entries.map(
                        (entry) => _ExpenseRow(
                          key: ValueKey(entry.key),
                          expense: entry.value,
                          onRemove: () => _remove(entry.key),
                        ),
                      ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _add,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add expense'),
                    style: TextButton.styleFrom(foregroundColor: _brand),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _saving ? 'Saving…' : 'Save',
                    enabled: !_saving &&
                        _expenses.any((e) => e.name.isNotEmpty && e.budget > 0),
                    onPressed: _save,
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

class _ExpenseRow extends StatefulWidget {
  const _ExpenseRow({super.key, required this.expense, required this.onRemove});
  final CashFlowExpense expense;
  final VoidCallback onRemove;

  @override
  State<_ExpenseRow> createState() => _ExpenseRowState();
}

class _ExpenseRowState extends State<_ExpenseRow> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _budgetCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.expense.name);
    _budgetCtrl = TextEditingController(
      text: widget.expense.budget > 0
          ? widget.expense.budget.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: TextField(
              controller: _nameCtrl,
              decoration: inputDecoration('Expense name'),
              onChanged: (v) => widget.expense.name = v,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _budgetCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: inputDecoration('Budget').copyWith(prefixText: '₱ '),
              onChanged: (v) {
                final parsed =
                    double.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), ''));
                widget.expense.budget = parsed ?? 0;
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            color: _body,
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }
}

// ─── Financial Safety detail page ─────────────────────────────────────────────

class _FinancialSafetyPage extends StatefulWidget {
  const _FinancialSafetyPage();
  @override
  State<_FinancialSafetyPage> createState() => _FinancialSafetyPageState();
}

class _FinancialSafetyPageState extends State<_FinancialSafetyPage> {
  bool _editing = false;
  bool _saving = false;
  double _amount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_saving) _amount = AppScope.of(context).financialSafetyBalance;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await AppScope.of(context).updateFinancialSafetyBalance(_amount);
    if (mounted)
      setState(() {
        _saving = false;
        _editing = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final budget = state.totalCashFlowBudget;
    final target3 = budget * 3;
    final target6 = budget * 6;
    final fill = target6 > 0 ? (_amount / target6).clamp(0.0, 1.0) : 0.0;
    final months = budget > 0 ? _amount / budget : 0.0;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: _title,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LAYER 2',
                          style: TextStyle(
                              color: _body,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2),
                        ),
                        Text('Financial Safety',
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SAFETY FUND',
                          style: TextStyle(
                              color: _body,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          money(_amount),
                          style: GoogleFonts.nunito(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: _title,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${months.toStringAsFixed(1)} months of basic needs covered',
                          style: const TextStyle(
                              color: _body, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        if (budget > 0) ...[
                          // Progress bar with 3-month marker
                          LayoutBuilder(builder: (ctx, box) {
                            final w = box.maxWidth;
                            final markerX = w / 2; // 3mo is half of 6mo
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: fill,
                                    minHeight: 10,
                                    color: _amber,
                                    backgroundColor: _amber.withOpacity(.12),
                                  ),
                                ),
                                Positioned(
                                  left: markerX - 1,
                                  top: -3,
                                  child: Container(
                                    width: 2,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: _amber,
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Spacer(),
                              Text(
                                '3 mo — ${money(target3)}',
                                style: const TextStyle(
                                    color: _amber,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700),
                              ),
                              const Spacer(),
                              Text(
                                '6 mo — ${money(target6)}',
                                style: const TextStyle(
                                    color: _body,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ] else
                          const Text(
                            'Set up Cash Flow & Basic Needs to see your targets.',
                            style: TextStyle(
                                color: _body, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_editing) ...[
                    MoneyInput(
                      label: 'Current safety fund amount',
                      initial: _amount,
                      onChanged: (v) => setState(() => _amount = v),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: _saving ? 'Saving…' : 'Save',
                      enabled: !_saving,
                      onPressed: _save,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => _editing = false),
                        style: TextButton.styleFrom(foregroundColor: _body),
                        child: const Text('Cancel',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ] else
                    PrimaryButton(
                      label: 'Update amount',
                      icon: Icons.edit_rounded,
                      onPressed: () => setState(() => _editing = true),
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

// ─── End pyramid ───────────────────────────────────────────────────────────────

// ─── Wealth account data model ────────────────────────────────────────────────

class _WealthAccount {
  const _WealthAccount({
    required this.name,
    required this.sub,
    required this.balance,
    required this.color,
    required this.icon,
    required this.layer,
  });
  final String name;
  final String sub;
  final double balance;
  final Color color;
  final IconData icon;
  final int layer; // 1-4
}

const _layerColors = [_brand, _amber, _purple, Color(0xFF6AA8F0)];
const _layerIcons = [
  Icons.account_balance_wallet_rounded,
  Icons.shield_rounded,
  Icons.trending_up_rounded,
  Icons.flag_rounded,
];
const _layerNames = [
  'Cash Flow & Basic Needs',
  'Financial Safety',
  'Accumulating Wealth',
  'Financial Freedom',
];

List<_WealthAccount> _buildWealthAccounts(AppState state) {
  final out = <_WealthAccount>[];
  final linkedAssets =
      state.assets.where((item) => item.description == 'Linked from FakeMaya');
  final fakeMayaItems =
      state.fakeMayaLink?.summary.toMoneyItems() ?? linkedAssets;

  for (final asset in fakeMayaItems) {
    final account = _fakeMayaWealthAccount(asset);
    if (account != null) out.add(account);
  }

  for (final asset in state.assets
      .where((item) => item.description != 'Linked from FakeMaya')) {
    out.add(_WealthAccount(
      name: asset.name,
      sub: asset.description,
      balance: asset.value,
      color: _purple,
      icon: Icons.account_balance_rounded,
      layer: 3,
    ));
  }
  return out;
}

_WealthAccount? _fakeMayaWealthAccount(MoneyItem item) {
  return switch (item.name) {
    'FakeMaya Wallet' => _WealthAccount(
        name: item.name,
        sub: 'E-wallet',
        balance: item.value,
        color: _brand,
        icon: Icons.account_balance_wallet_rounded,
        layer: 1,
      ),
    'FakeMaya Savings' => _WealthAccount(
        name: item.name,
        sub: 'Savings account',
        balance: item.value,
        color: _amber,
        icon: Icons.savings_rounded,
        layer: 2,
      ),
    'FakeMaya Time Deposit' => _WealthAccount(
        name: item.name,
        sub: 'Time deposit',
        balance: item.value,
        color: _purple,
        icon: Icons.lock_clock_rounded,
        layer: 3,
      ),
    final name when name.startsWith('FakeMaya ') => _WealthAccount(
        name: item.name,
        sub: 'Goal savings',
        balance: item.value,
        color: const Color(0xFF6AA8F0),
        icon: Icons.flag_rounded,
        layer: 4,
      ),
    _ => null,
  };
}

// ─── Insights / Wealth Overview page ─────────────────────────────────────────

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});
  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  // 0=Overview, 1=Accounts, 2=Pyramid, 3=Goals, 4=Spending
  int _tab = 0;
  int _spendPeriod = 1; // for spending tab

  static const _tabs = ['Overview', 'Accounts', 'Pyramid', 'Goals', 'Spending'];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final accounts = _buildWealthAccounts(state);
    final totalAssets = accounts.fold<double>(0.0, (s, a) => s + a.balance);
    final totalLiabilities = state.totalLiabilities;

    final show = _tab == 0;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const PageHeader(eyebrow: 'WEALTH OVERVIEW', title: 'My Money'),
        const SizedBox(height: 16),
        // Hero card always visible
        _NetWorthHero(assets: totalAssets, liabilities: totalLiabilities),
        const SizedBox(height: 16),
        // Filter tabs
        _InsightsFilterBar(
          tabs: _tabs,
          selected: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 4),
        // Sections
        if (_tab != 4) ...[
          if (show || _tab == 1)
            _AccountsSection(accounts: accounts, compact: !show),
          if (show || _tab == 2)
            _PyramidBreakdownSection(accounts: accounts, state: state),
          if (show || _tab == 3) _GoalsOverviewSection(state: state),
        ] else
          _SpendingSection(
            state: state,
            period: _spendPeriod,
            onPeriodChanged: (p) => setState(() => _spendPeriod = p),
          ),
      ],
    );
  }
}

// ─── Net Worth Hero ───────────────────────────────────────────────────────────

class _NetWorthHero extends StatelessWidget {
  const _NetWorthHero({required this.assets, required this.liabilities});
  final double assets;
  final double liabilities;

  @override
  Widget build(BuildContext context) {
    final net = assets - liabilities;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3D2563), Color(0xFF2E1B47)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E1B47).withOpacity(.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'NET WORTH',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              money(net),
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              height: 1,
              color: Colors.white12,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _HeroStat(
                    label: 'Assets',
                    value: money(assets),
                    color: _brand,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white12),
                Expanded(
                  child: _HeroStat(
                    label: 'Liabilities',
                    value: money(liabilities),
                    color: const Color(0xFFFF8A80),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.nunito(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ─── Filter bar ───────────────────────────────────────────────────────────────

class _InsightsFilterBar extends StatelessWidget {
  const _InsightsFilterBar({
    required this.tabs,
    required this.selected,
    required this.onChanged,
  });
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = selected == i;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: active ? _title : _surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: active ? _title : _border),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: _title.withOpacity(.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  color: active ? Colors.white : _body,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Accounts section ─────────────────────────────────────────────────────────

class _AccountsSection extends StatelessWidget {
  const _AccountsSection({required this.accounts, this.compact = false});
  final List<_WealthAccount> accounts;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            label: 'ACCOUNTS',
            total: accounts.fold<double>(0.0, (s, a) => s + a.balance),
          ),
          const SizedBox(height: 12),
          if (accounts.isEmpty)
            _EmptyWealthCard(
              icon: Icons.account_balance_rounded,
              message:
                  'Link FakeMaya or add assets in Your Profile to see accounts here.',
            )
          else
            _AccountGrid(accounts: accounts),
        ],
      ),
    );
  }
}

class _AccountGrid extends StatelessWidget {
  const _AccountGrid({required this.accounts});
  final List<_WealthAccount> accounts;

  @override
  Widget build(BuildContext context) {
    // Build 2-column grid as rows
    final rows = <Widget>[];
    for (var i = 0; i < accounts.length; i += 2) {
      final left = accounts[i];
      final right = i + 1 < accounts.length ? accounts[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _AccountCard(account: left)),
            const SizedBox(width: 10),
            Expanded(
              child: right != null
                  ? _AccountCard(account: right)
                  : const SizedBox(),
            ),
          ],
        ),
      );
      if (i + 2 < accounts.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account});
  final _WealthAccount account;

  @override
  Widget build(BuildContext context) {
    final c = account.color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.withOpacity(.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.withOpacity(.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.withOpacity(.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(account.icon, color: c, size: 20),
              ),
              const Spacer(),
              _LayerDot(layer: account.layer),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            account.name,
            style: const TextStyle(
              color: _title,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          Text(
            account.sub,
            style: const TextStyle(
              color: _body,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            money(account.balance),
            style: GoogleFonts.nunito(
              color: _title,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerDot extends StatelessWidget {
  const _LayerDot({required this.layer});
  final int layer;

  @override
  Widget build(BuildContext context) {
    final c = _layerColors[layer - 1];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'L$layer',
        style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}

// ─── Pyramid breakdown section ────────────────────────────────────────────────

class _PyramidBreakdownSection extends StatelessWidget {
  const _PyramidBreakdownSection({
    required this.accounts,
    required this.state,
  });
  final List<_WealthAccount> accounts;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final totalAssets = accounts.fold(0.0, (s, a) => s + a.balance);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(label: 'PYRAMID', total: totalAssets),
          const SizedBox(height: 12),
          ...List.generate(4, (i) {
            final layerNum = i + 1;
            final layerAccounts =
                accounts.where((a) => a.layer == layerNum).toList();
            final layerTotal = layerAccounts.fold(0.0, (s, a) => s + a.balance);
            final fill = totalAssets > 0 ? layerTotal / totalAssets : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PyramidBreakdownCard(
                layerNum: layerNum,
                layerTotal: layerTotal,
                fill: fill,
                layerAccounts: layerAccounts,
                state: state,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PyramidBreakdownCard extends StatefulWidget {
  const _PyramidBreakdownCard({
    required this.layerNum,
    required this.layerTotal,
    required this.fill,
    required this.layerAccounts,
    required this.state,
  });
  final int layerNum;
  final double layerTotal;
  final double fill;
  final List<_WealthAccount> layerAccounts;
  final AppState state;

  @override
  State<_PyramidBreakdownCard> createState() => _PyramidBreakdownCardState();
}

class _PyramidBreakdownCardState extends State<_PyramidBreakdownCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = _layerColors[widget.layerNum - 1];
    final icon = _layerIcons[widget.layerNum - 1];
    final name = _layerNames[widget.layerNum - 1];

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _expanded ? c.withOpacity(.4) : _border),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D2E1B47), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.withOpacity(.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: c, size: 22),
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
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Layer ${widget.layerNum}',
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
                      money(widget.layerTotal),
                      style: GoogleFonts.nunito(
                        color: c,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${(widget.fill * 100).round()}% of assets',
                      style: const TextStyle(
                        color: _body,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _body,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: widget.fill,
                minHeight: 6,
                color: c,
                backgroundColor: c.withOpacity(.1),
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: _border),
              const SizedBox(height: 12),
              if (widget.layerAccounts.isEmpty)
                Text(
                  'No accounts tagged to this layer yet.',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                ...widget.layerAccounts.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: a.color.withOpacity(.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(a.icon, color: a.color, size: 14),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            a.name,
                            style: const TextStyle(
                              color: _title,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          money(a.balance),
                          style: GoogleFonts.nunito(
                            color: _title,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Layer-specific context
              _LayerContext(layerNum: widget.layerNum, state: widget.state),
            ],
          ],
        ),
      ),
    );
  }
}

class _LayerContext extends StatelessWidget {
  const _LayerContext({required this.layerNum, required this.state});
  final int layerNum;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    if (layerNum == 1 && state.totalCashFlowBudget > 0) {
      return _ContextChip(
        icon: Icons.receipt_long_rounded,
        text: 'Monthly budget: ${money(state.totalCashFlowBudget)}',
        color: _brand,
      );
    }
    if (layerNum == 2 && state.totalCashFlowBudget > 0) {
      final months = state.financialSafetyBalance / state.totalCashFlowBudget;
      return _ContextChip(
        icon: Icons.shield_rounded,
        text:
            'Safety fund covers ${months.toStringAsFixed(1)} months of basic needs',
        color: _amber,
      );
    }
    if (layerNum == 3 && state.investments > 0) {
      return _ContextChip(
        icon: Icons.show_chart_rounded,
        text: 'Investments tracked: ${money(state.investments)}',
        color: _purple,
      );
    }
    return const SizedBox.shrink();
  }
}

class _ContextChip extends StatelessWidget {
  const _ContextChip(
      {required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Goals overview section ───────────────────────────────────────────────────

class _GoalsOverviewSection extends StatelessWidget {
  const _GoalsOverviewSection({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final hasTwoJar = state.needsTarget > 0;
    final hasSafety = state.totalCashFlowBudget > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(label: 'GOALS & TARGETS', total: null),
          const SizedBox(height: 12),
          if (!hasTwoJar && !hasSafety)
            _EmptyWealthCard(
              icon: Icons.flag_rounded,
              message:
                  'Set up Cash Flow & Basic Needs in the Pyramid to track goals here.',
            )
          else ...[
            if (hasTwoJar) ...[
              _GoalTile(
                icon: Icons.water_drop_rounded,
                color: _brand,
                label: 'Needs Jar',
                sub: 'Layer 1 · Cash Flow',
                current: state.needsBalance,
                target: state.needsTarget,
              ),
              const SizedBox(height: 10),
              _GoalTile(
                icon: Icons.waves_rounded,
                color: _purple,
                label: 'Buffer Jar',
                sub:
                    '${state.bufferMonthsCovered.toStringAsFixed(1)} months covered',
                current: state.bufferBalance,
                target: null,
              ),
              const SizedBox(height: 10),
            ],
            if (hasSafety) _SafetyGoalTile(state: state),
          ],
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.sub,
    required this.current,
    required this.target,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String sub;
  final double current;
  final double? target;

  @override
  Widget build(BuildContext context) {
    final hasTarget = target != null && target! > 0;
    final fill = hasTarget ? (current / target!).clamp(0.0, 1.0) : null;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBubble(icon,
                  color: color, background: color.withOpacity(.12)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: _title,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                    Text(sub,
                        style: const TextStyle(
                            color: _body,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Text(
                money(current),
                style: GoogleFonts.nunito(
                    color: color, fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          if (hasTarget) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: fill,
                minHeight: 7,
                color: color,
                backgroundColor: color.withOpacity(.1),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${((fill ?? 0) * 100).round()}%',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w800, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  'of ${money(target!)}',
                  style: const TextStyle(
                      color: _body, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SafetyGoalTile extends StatelessWidget {
  const _SafetyGoalTile({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final budget = state.totalCashFlowBudget;
    final current = state.financialSafetyBalance;
    final target6 = budget * 6;
    final fill = target6 > 0 ? (current / target6).clamp(0.0, 1.0) : 0.0;
    final months = budget > 0 ? current / budget : 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBubble(Icons.shield_rounded,
                  color: _amber, background: _amber.withOpacity(.12)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Safety Fund',
                        style: TextStyle(
                            color: _title,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                    Text(
                        'Layer 2 · ${months.toStringAsFixed(1)} months covered',
                        style: const TextStyle(
                            color: _body,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Text(money(current),
                  style: GoogleFonts.nunito(
                      color: _amber,
                      fontSize: 17,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (ctx, box) {
            return Stack(clipBehavior: Clip.none, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: fill,
                  minHeight: 7,
                  color: _amber,
                  backgroundColor: _amber.withOpacity(.1),
                ),
              ),
              // 3-month marker
              Positioned(
                left: box.maxWidth / 2 - 1,
                top: -2,
                child: Container(
                    width: 2,
                    height: 11,
                    decoration: BoxDecoration(
                        color: _amber, borderRadius: BorderRadius.circular(1))),
              ),
            ]);
          }),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('${(fill * 100).round()}%',
                  style: const TextStyle(
                      color: _amber,
                      fontWeight: FontWeight.w800,
                      fontSize: 12)),
              const Spacer(),
              Text('3mo: ${money(budget * 3)}',
                  style: TextStyle(
                      color: _amber.withOpacity(.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 10),
              Text('6mo: ${money(budget * 6)}',
                  style: const TextStyle(
                      color: _body, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Spending section (old insights) ─────────────────────────────────────────

class _SpendingSection extends StatelessWidget {
  const _SpendingSection({
    required this.state,
    required this.period,
    required this.onPeriodChanged,
  });
  final AppState state;
  final int period;
  final ValueChanged<int> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final layers = _insightLayersFor(
      state.fakeMayaLink?.summary.transactions ?? const [],
      period,
    );
    final categories = layers.expand((l) => l.categories).toList();
    final total = categories.fold(0.0, (s, c) => s + c.amount);
    final periodLabel =
        ['SPENT THIS WEEK', 'SPENT THIS MONTH', 'SPENT THIS YEAR'][period];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: _bellySoft, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: ['Week', 'Month', 'Year'].asMap().entries.map((e) {
                final active = period == e.key;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onPeriodChanged(e.key),
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
                                    offset: Offset(0, 2))
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
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(periodLabel,
                    style: const TextStyle(
                        color: _body,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text(money(total),
                    style: GoogleFonts.nunito(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: _title,
                        letterSpacing: -0.5)),
                const SizedBox(height: 14),
                if (categories.isEmpty)
                  const Text(
                    'Label outgoing transactions to build your spending insights.',
                    style: TextStyle(
                        color: _body,
                        fontWeight: FontWeight.w700,
                        height: 1.35),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Row(
                      children: categories
                          .map((c) => Expanded(
                                flex: math.max(
                                    1, (c.amount / total * 100).round()),
                                child: Container(height: 10, color: c.color),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('By financial layer',
              style: GoogleFonts.fredoka(
                  fontSize: 22, fontWeight: FontWeight.w600, color: _title)),
          const SizedBox(height: 14),
          ...layers.map((l) => _InsightLayerSection(layer: l)),
        ],
      ),
    );
  }
}

// ─── Shared section header & empty state ─────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.total});
  final String label;
  final double? total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _body,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
        if (total != null) ...[
          const Spacer(),
          Text(
            money(total!),
            style: GoogleFonts.nunito(
              color: _title,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyWealthCard extends StatelessWidget {
  const _EmptyWealthCard({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _bellySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: _body, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: _body,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.4),
            ),
          ),
        ],
      ),
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
    'basic needs' => (1, 'Basic needs', Icons.home_filled, _purple),
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

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  bool _showMenu = true;
  String? _overrideGoal; // null → use state.selectedGoal
  bool _crossAlertShown = false;

  String _activeGoal(AppState state) => _overrideGoal ?? state.selectedGoal;

  void _enterGoal([String? goal]) => setState(() {
        _showMenu = false;
        _crossAlertShown = false;
        _overrideGoal = goal;
      });

  void _backToMenu() => setState(() {
        _showMenu = true;
        _overrideGoal = null;
      });

  void _showGoalPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalPickerSheet(
        onSelect: (goal) {
          Navigator.pop(context);
          _enterGoal(goal);
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_showMenu && !_crossAlertShown) {
      final state = AppScope.of(context);
      final alert = _shieldCrossAlert(state);
      if (alert != null) {
        _crossAlertShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showCrossAlertDialog(context, alert);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    if (_showMenu) {
      return _GoalsMenu(
        onGoal: () => _enterGoal(null),
        onShieldGoal: () => _enterGoal('Safety Shield Boundary'),
        onAddGoal: () => _showGoalPicker(context),
      );
    }

    final activeGoal = _activeGoal(state);
    final onBack = _backToMenu;

    // First-time setup: show jar configuration before normal Goals content.
    if (activeGoal == 'Irregular Income Buffer' && state.needsTarget == 0) {
      return _TwoJarSetupFlow(onBack: onBack);
    }

    // Two-jar UI (configured): replace full page for this goal only.
    if (activeGoal == 'Irregular Income Buffer') {
      return _TwoJarGoalsBody(onBack: onBack);
    }

    // Safety Shield: setup or goal body.
    if (activeGoal == 'Safety Shield Boundary' && !state.shieldIsSetup) {
      return _ShieldSetupFlow(onBack: onBack);
    }
    if (activeGoal == 'Safety Shield Boundary') {
      return _ShieldGoalBody(onBack: onBack);
    }

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
        _GoalDetailHeader(eyebrow: 'COLLECTION MODE', onBack: onBack),
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
                          ? 'BASIC NEEDS BUCKET'
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
                          ? 'Buffer: ${money(irregularIncome?.bufferBalance ?? 0)} · Target: ${money(totalTarget)}'
                          : 'of ${money(totalTarget)} across ${buckets.length} active ${buckets.length == 1 ? 'goal' : 'goals'}',
                      style: const TextStyle(
                        color: _title,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (irregularIncome != null)
                _IrregularIncomeCollectionCard(data: irregularIncome)
              else
                _GoalBucketCard(
                  bucket: primary,
                  featured: true,
                  onTap: () => _showBucketActions(context, primary),
                  onEdit: () => _showBucketEditor(context, primary),
                  onAllocate: () => _showAllocationSheet(context, primary),
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

// ─── Goals menu ───────────────────────────────────────────────────────────────

class _GoalsMenu extends StatelessWidget {
  const _GoalsMenu({
    required this.onGoal,
    required this.onShieldGoal,
    required this.onAddGoal,
  });

  final VoidCallback onGoal;
  final VoidCallback onShieldGoal;
  final VoidCallback onAddGoal;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final shieldMonths = state.safetyShieldMonthsCovered;
    final shieldStatus = !state.shieldIsSetup
        ? 'Tap to set up'
        : shieldMonths >= 3
            ? '${shieldMonths.toStringAsFixed(1)} months · Funded'
            : '${shieldMonths.toStringAsFixed(1)} months · Building';
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MY GOALS',
                      style: TextStyle(
                        color: _body,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Goals',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded, size: 28),
                color: _title,
                tooltip: 'Add a goal',
                onPressed: onAddGoal,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _GoalMenuCard(
                title: state.selectedGoal,
                description: state.selectedGoalDescription,
                onTap: onGoal,
              ),
              const SizedBox(height: 12),
              _GoalMenuCard(
                title: 'Safety Shield Boundary',
                description: shieldStatus,
                emoji: '🛡️',
                layerColor: _amber,
                onTap: onShieldGoal,
              ),
              // Interplay section — only shown when both goals are active
              if (state.needsTarget > 0 && state.shieldIsSetup) ...[
                const SizedBox(height: 20),
                Builder(builder: (ctx) {
                  final alert = _shieldCrossAlert(state);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GOAL INTERPLAY',
                        style: TextStyle(
                          color: _body,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (alert != null) ...[
                        _CrossAlertCard(
                          title: alert.title,
                          body: alert.body,
                          hint: alert.hint,
                          critical: alert.critical,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _ShieldAllocationSplitCard(state: state),
                    ],
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalMenuCard extends StatelessWidget {
  const _GoalMenuCard({
    required this.title,
    required this.description,
    required this.onTap,
    this.emoji,
    this.layerColor,
  });

  final String title;
  final String description;
  final VoidCallback onTap;
  final String? emoji;
  final Color? layerColor;

  @override
  Widget build(BuildContext context) {
    final color = layerColor;
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Row(
          children: [
            if (emoji != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (color ?? _purple).withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(emoji!, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _title,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _body,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right_rounded, color: _body),
          ],
        ),
      ),
    );
  }
}

class _GoalPickerSheet extends StatelessWidget {
  const _GoalPickerSheet({required this.onSelect});
  final ValueChanged<String> onSelect;

  static const _available = [
    (
      'Safety Shield Boundary',
      '🛡️',
      'Build a 3–6 month emergency fund in your savings account.',
      _amber,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _GoalSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add a goal',
            style: GoogleFonts.fredoka(
                color: _title, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose a goal to add to your Goals screen.',
            style: TextStyle(color: _body, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          for (final (title, emoji, desc, color) in _available)
            GestureDetector(
              onTap: () => onSelect(title),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  color: _title,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(desc,
                              style: const TextStyle(
                                  color: _body,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: _body),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Shared back-button header used by goal detail views.
class _GoalDetailHeader extends StatelessWidget {
  const _GoalDetailHeader({
    required this.eyebrow,
    required this.onBack,
    this.actions = const [],
  });

  final String eyebrow;
  final VoidCallback onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 4, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: _title,
            onPressed: onBack,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Goals',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

// ─── Two-jar first-time setup ─────────────────────────────────────────────────

class _TwoJarSetupFlow extends StatefulWidget {
  const _TwoJarSetupFlow({required this.onBack});

  final VoidCallback onBack;

  @override
  State<_TwoJarSetupFlow> createState() => _TwoJarSetupFlowState();
}

class _TwoJarSetupFlowState extends State<_TwoJarSetupFlow> {
  int _page = 0;
  double _needsTarget = 0;
  int _needsPercent = 70;
  bool _seeded = false;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    final state = AppScope.of(context);
    _needsTarget = state.expenses > 0 ? state.expenses : 3000;
    final ratio = state.income <= 0
        ? 0.6
        : (state.expenses / state.income).clamp(0.0, 1.0);
    _needsPercent = (50 + (ratio * 30)).round().clamp(50, 80);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            if (_page == 0)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: _title,
                  onPressed: widget.onBack,
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: switch (_page) {
                  0 => _JarSetupScreenA(
                      key: const ValueKey(0),
                      needsTarget: _needsTarget,
                      onChanged: (v) => setState(() => _needsTarget = v),
                      onNext: () => setState(() => _page = 1),
                    ),
                  1 => _JarSetupScreenB(
                      key: const ValueKey(1),
                      needsPercent: _needsPercent,
                      needsTarget: _needsTarget,
                      onChanged: (v) => setState(() => _needsPercent = v),
                      onBack: () => setState(() => _page = 0),
                      onNext: () => setState(() => _page = 2),
                    ),
                  _ => _JarSetupScreenC(
                      key: const ValueKey(2),
                      needsTarget: _needsTarget,
                      needsPercent: _needsPercent,
                      busy: _busy,
                      onBack: () => setState(() => _page = 1),
                      onStart: _start,
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _start() async {
    if (_busy) return;
    setState(() => _busy = true);
    await AppScope.of(context).setupTwoJars(
      needsTarget: _needsTarget,
      needsPercent: _needsPercent,
    );
    // setupTwoJars calls notifyListeners → GoalsPage rebuilds → needsTarget > 0
    // so the setup flow is no longer returned; no explicit pop needed.
  }
}

// ── Screen A: survival amount ──────────────────────────────────────────────────

class _JarSetupScreenA extends StatefulWidget {
  const _JarSetupScreenA({
    super.key,
    required this.needsTarget,
    required this.onChanged,
    required this.onNext,
  });

  final double needsTarget;
  final ValueChanged<double> onChanged;
  final VoidCallback onNext;

  @override
  State<_JarSetupScreenA> createState() => _JarSetupScreenAState();
}

class _JarSetupScreenAState extends State<_JarSetupScreenA> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.needsTarget.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _JarSetupShell(
      stepDots: const _SetupDots(total: 3, current: 0),
      title: 'What do you need to survive a month?',
      subtitle:
          'This keeps your lights on. We fill this first, every time money comes in.',
      bottom: PrimaryButton(
        label: 'Next',
        icon: Icons.arrow_forward_rounded,
        onPressed: widget.onNext,
      ),
      child: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: inputDecoration('Monthly survival amount').copyWith(
          prefixIcon: const Icon(Icons.payments_rounded, color: _body),
        ),
        onChanged: (v) {
          final parsed = double.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), ''));
          if (parsed != null) widget.onChanged(parsed);
        },
      ),
    );
  }
}

// ── Screen B: split slider ─────────────────────────────────────────────────────

class _JarSetupScreenB extends StatelessWidget {
  const _JarSetupScreenB({
    super.key,
    required this.needsPercent,
    required this.needsTarget,
    required this.onChanged,
    required this.onBack,
    required this.onNext,
  });

  final int needsPercent;
  final double needsTarget;
  final ValueChanged<int> onChanged;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bufferPercent = 100 - needsPercent;
    final sampleAmount = needsTarget > 0 ? needsTarget : 1000.0;
    final toNeeds = sampleAmount * needsPercent / 100;
    final toBuffer = sampleAmount - toNeeds;

    return _JarSetupShell(
      stepDots: const _SetupDots(total: 3, current: 1),
      title: 'How should we split each peso?',
      subtitle:
          'Needs gets filled first. Anything left after it\'s full goes to Buffer.',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: 'Next',
            icon: Icons.arrow_forward_rounded,
            onPressed: onNext,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onBack,
            style: TextButton.styleFrom(foregroundColor: _body),
            child: const Text(
              'Back',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _JarLabel(
                label: 'Needs',
                percent: needsPercent,
                color: _brand,
              ),
              const Spacer(),
              _JarLabel(
                label: 'Buffer',
                percent: bufferPercent,
                color: _purple,
              ),
            ],
          ),
          Slider(
            min: 50,
            max: 90,
            divisions: 40,
            value: needsPercent.toDouble(),
            activeColor: _brand,
            onChanged: (v) => onChanged(v.round()),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _bellySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'On ${money(sampleAmount)} → ${money(toNeeds)} Needs, ${money(toBuffer)} Buffer',
              style: const TextStyle(
                color: _title,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JarLabel extends StatelessWidget {
  const _JarLabel({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          '$percent%',
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ── Screen C: confirmation ─────────────────────────────────────────────────────

class _JarSetupScreenC extends StatelessWidget {
  const _JarSetupScreenC({
    super.key,
    required this.needsTarget,
    required this.needsPercent,
    required this.busy,
    required this.onBack,
    required this.onStart,
  });

  final double needsTarget;
  final int needsPercent;
  final bool busy;
  final VoidCallback onBack;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final bufferPercent = 100 - needsPercent;
    return _JarSetupShell(
      stepDots: const _SetupDots(total: 3, current: 2),
      title: "Here's your plan",
      subtitle: '',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: busy ? 'Setting up…' : 'Start',
            icon: Icons.check_rounded,
            enabled: !busy,
            onPressed: onStart,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: busy ? null : onBack,
            style: TextButton.styleFrom(foregroundColor: _body),
            child: const Text(
              'Back',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BucketTile(
              emoji: '🛒',
              label: 'Needs',
              balance: 0,
              target: needsTarget,
              percent: needsPercent / 100,
              color: _brand,
              full: false,
            ),
            const SizedBox(height: 10),
            _BucketTile(
              emoji: '🌊',
              label: 'Buffer',
              balance: 0,
              target: 0,
              percent: bufferPercent / 100,
              color: _purple,
              full: false,
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: _border),
            const SizedBox(height: 12),
            Text(
              'Each payday we fill Needs first. When it\'s full, extra builds your Buffer. '
              'We\'ll only ask you something when a bill is bigger than your Needs jar.',
              style: const TextStyle(
                color: _body,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared setup scaffold ──────────────────────────────────────────────────────

class _JarSetupShell extends StatelessWidget {
  const _JarSetupShell({
    required this.stepDots,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.bottom,
  });

  final Widget stepDots;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          stepDots,
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: _body,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 28),
          Expanded(
            child: SingleChildScrollView(child: child),
          ),
          const SizedBox(height: 18),
          bottom,
        ],
      ),
    );
  }
}

class _SetupDots extends StatelessWidget {
  const _SetupDots({required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(right: 6),
          width: active ? 20 : 8,
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

// ─── End two-jar setup ─────────────────────────────────────────────────────────

// ─── Two-jar Goals page body ───────────────────────────────────────────────────

class _TwoJarGoalsBody extends StatelessWidget {
  const _TwoJarGoalsBody({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cycle = _goalCycleFor(state);
    final hasRecentShortfall = state.jarLedger
        .take(5)
        .any((e) => e.type == JarEventType.billPaid && e.bufferOut > 0);
    final needsStatus = state.needsFull
        ? 'Full'
        : hasRecentShortfall
            ? 'Short'
            : 'Filling';
    final months = state.bufferMonthsCovered;
    final monthsLabel = months < 0.1
        ? 'Less than a week covered'
        : months < 1
            ? 'About ${(months * 4).round()} weeks covered'
            : 'Covers about ${months.toStringAsFixed(1)} thin months';

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _GoalDetailHeader(
          eyebrow: 'YOUR JARS',
          onBack: onBack,
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              color: _body,
              tooltip: 'Summary',
              onPressed: () => _showJarSummarySheet(context, state),
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              color: _body,
              tooltip: 'Configure',
              onPressed: () => _showJarConfigSheet(context, state),
            ),
          ],
        ),
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
              const SizedBox(height: 14),
              // Two stat tiles
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      icon: Icons.water_drop_rounded,
                      iconColor: _brand,
                      label: 'Needs',
                      value: money(state.needsBalance),
                      delta: 'of ${money(state.needsTarget)}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStatCard(
                      icon: Icons.waves_rounded,
                      iconColor: _purple,
                      label: 'Buffer',
                      value: money(state.bufferBalance),
                      delta: monthsLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Needs jar card
              _NeedsJarCard(
                balance: state.needsBalance,
                target: state.needsTarget,
                statusWord: needsStatus,
                needsPercent: state.needsPercent,
              ),
              const SizedBox(height: 12),
              // Buffer jar card
              _BufferJarCard(
                balance: state.bufferBalance,
                bufferPercent: 100 - state.needsPercent,
                monthsLabel: monthsLabel,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Log income',
                icon: Icons.add_rounded,
                onPressed: () => _showLogIncomeSheet(context, state),
              ),
              const SizedBox(height: 22),
              SectionTitle(
                title: 'Recent activity',
                action: '${state.jarLedger.length} events',
              ),
              const SizedBox(height: 12),
              _LedgerTraceCard(ledger: state.jarLedger),
              const SizedBox(height: 16),
              _WeeklyCheckInTile(state: state),
            ],
          ),
        ),
      ],
    );
  }
}


class _NeedsJarCard extends StatelessWidget {
  const _NeedsJarCard({
    required this.balance,
    required this.target,
    required this.statusWord,
    required this.needsPercent,
  });

  final double balance;
  final double target;
  final String statusWord;
  final int needsPercent;

  @override
  Widget build(BuildContext context) {
    final fill = target > 0 ? (balance / target).clamp(0.0, 1.0) : 0.0;
    final statusColor = switch (statusWord) {
      'Full' => _brand,
      'Short' => _red,
      _ => _amber,
    };
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🛒', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Needs',
                      style: TextStyle(
                        color: _title,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$needsPercent% of each income drop',
                      style: const TextStyle(
                        color: _body,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  statusWord,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money(balance),
                style: GoogleFonts.nunito(
                  color: _title,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  'of ${money(target)}',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: fill,
              minHeight: 8,
              color: _brand,
              backgroundColor: _brand.withOpacity(.14),
            ),
          ),
        ],
      ),
    );
  }
}

class _BufferJarCard extends StatelessWidget {
  const _BufferJarCard({
    required this.balance,
    required this.bufferPercent,
    required this.monthsLabel,
  });

  final double balance;
  final int bufferPercent;
  final String monthsLabel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const Text('🌊', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buffer',
                  style: TextStyle(
                    color: _title,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$bufferPercent% of each income drop',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money(balance),
                style: GoogleFonts.nunito(
                  color: _purple,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                monthsLabel,
                style: const TextStyle(
                  color: _body,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LedgerTraceCard extends StatelessWidget {
  const _LedgerTraceCard({required this.ledger});

  final List<JarEvent> ledger;

  @override
  Widget build(BuildContext context) {
    final entries = ledger.take(6).toList();
    if (entries.isEmpty) {
      return AppCard(
        child: const Text(
          'No activity yet. Log your first income drop to see it here.',
          style: TextStyle(
            color: _body,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
      );
    }
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: entries.asMap().entries.map((entry) {
          final isLast = entry.key == entries.length - 1;
          final event = entry.value;
          final isIncome = event.type == JarEventType.income;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: (isIncome ? _brand : _red).withOpacity(.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isIncome
                            ? Icons.call_received_rounded
                            : Icons.receipt_rounded,
                        size: 14,
                        color: isIncome ? _brand : _red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.sentence,
                            style: const TextStyle(
                              color: _title,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatJarTimestamp(event.timestamp),
                            style: const TextStyle(
                              color: _body,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, color: _border, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}

String _formatJarTimestamp(DateTime ts) {
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
  final local = ts.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final min = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '${months[local.month - 1]} ${local.day}, $hour:$min $period';
}

class _WeeklyCheckInTile extends StatelessWidget {
  const _WeeklyCheckInTile({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final done = state.hasCurrentWeekAnxietyCheckIn;
    return InkWell(
      onTap: done ? null : () => _showAnxietyCheckInSheet(context, state),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _bellySoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              done ? Icons.mood_rounded : Icons.sentiment_neutral_rounded,
              color: done ? _brand : _body,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                done
                    ? 'Weekly check-in recorded — ${state.anxietyCheckIns[state.currentAnxietyWeekKey]!.round()} / 5'
                    : 'How stressed do you feel about money this week?',
                style: TextStyle(
                  color: done ? _body : _title,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            if (!done)
              const Icon(Icons.chevron_right_rounded, color: _body, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Two-jar sheet functions ───────────────────────────────────────────────────

Future<void> _showLogIncomeSheet(BuildContext context, AppState state) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _LogIncomeSheet(state: state),
  );
}

class _LogIncomeSheet extends StatefulWidget {
  const _LogIncomeSheet({required this.state});
  final AppState state;

  @override
  State<_LogIncomeSheet> createState() => _LogIncomeSheetState();
}

class _LogIncomeSheetState extends State<_LogIncomeSheet> {
  double _amount = 0;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final needsShare = _amount * widget.state.needsPercent / 100;
    final bufferShare = _amount - needsShare;
    return _GoalSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Log income',
            style: GoogleFonts.fredoka(
              color: _title,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.state.needsPercent}% goes to Needs, ${100 - widget.state.needsPercent}% to Buffer.',
            style: const TextStyle(color: _body, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          MoneyInput(
            label: 'Amount received',
            initial: 0,
            onChanged: (v) => setState(() => _amount = v),
          ),
          if (_amount > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SplitPreviewTile(
                    label: 'Needs',
                    amount: needsShare,
                    color: _purple,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SplitPreviewTile(
                    label: 'Buffer',
                    amount: bufferShare,
                    color: _amber,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: _loading ? 'Saving…' : 'Confirm',
            enabled: _amount > 0 && !_loading,
            onPressed: () {
              setState(() => _loading = true);
              final result = widget.state.onIncomeEvent(_amount);
              Navigator.pop(context);
              if (result.overflow) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Needs is full! ${money(result.toBuffer)} went to Buffer.',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: widget.state.undoLastIncomeSplit,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SplitPreviewTile extends StatelessWidget {
  const _SplitPreviewTile({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            money(amount),
            style: GoogleFonts.nunito(
              color: _title,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Config and summary sheets ────────────────────────────────────────────────

Future<void> _showJarConfigSheet(BuildContext context, AppState state) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _JarConfigSheet(state: state),
  );
}

class _JarConfigSheet extends StatefulWidget {
  const _JarConfigSheet({required this.state});
  final AppState state;

  @override
  State<_JarConfigSheet> createState() => _JarConfigSheetState();
}

class _JarConfigSheetState extends State<_JarConfigSheet> {
  late double _needsTarget;
  late int _needsPercent;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _needsTarget = widget.state.needsTarget;
    _needsPercent = widget.state.needsPercent;
  }

  @override
  Widget build(BuildContext context) {
    final bufferPercent = 100 - _needsPercent;
    return _GoalSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Configure jars',
            style: GoogleFonts.fredoka(
              color: _title,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Changing these won\'t reset your current balances.',
            style: TextStyle(color: _body, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          MoneyInput(
            label: 'Monthly basic needs amount',
            initial: _needsTarget,
            onChanged: (v) => setState(() => _needsTarget = v),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Needs allocation',
                style: TextStyle(
                  color: _title,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '$_needsPercent% needs · $bufferPercent% buffer',
                style: const TextStyle(
                  color: _body,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Slider(
            value: _needsPercent.toDouble(),
            min: 50,
            max: 90,
            divisions: 8,
            activeColor: _purple,
            onChanged: (v) => setState(() => _needsPercent = v.round()),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: _saving ? 'Saving…' : 'Save changes',
            enabled: !_saving,
            onPressed: () {
              setState(() => _saving = true);
              widget.state
                  .updateJarConfig(
                needsTarget: _needsTarget,
                needsPercent: _needsPercent,
              )
                  .then((_) {
                if (context.mounted) Navigator.pop(context);
              });
            },
          ),
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              style: TextButton.styleFrom(foregroundColor: _body),
              onPressed: _saving
                  ? null
                  : () {
                      setState(() => _saving = true);
                      widget.state.seedDemoTwoJarData().then((_) {
                        if (context.mounted) Navigator.pop(context);
                      });
                    },
              child: const Text(
                'Load IIB-only sample scenario',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Center(
            child: TextButton(
              style: TextButton.styleFrom(foregroundColor: _amber),
              onPressed: _saving
                  ? null
                  : () {
                      setState(() => _saving = true);
                      widget.state.seedDemoCombinedGoals().then((_) {
                        if (context.mounted) Navigator.pop(context);
                      });
                    },
              child: const Text(
                'Load combined IIB + Safety Shield demo',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showJarSummarySheet(BuildContext context, AppState state) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _JarSummarySheet(state: state),
  );
}

class _JarSummarySheet extends StatelessWidget {
  const _JarSummarySheet({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1);

    double billsFromLedger(int year, int month) => state.jarLedger
        .where((e) =>
            e.type == JarEventType.billPaid &&
            e.timestamp.year == year &&
            e.timestamp.month == month)
        .fold(0.0, (s, e) => s + e.needsOut + e.bufferOut);

    final thisMonthBills = billsFromLedger(now.year, now.month);
    final lastMonthBills = billsFromLedger(prev.year, prev.month);

    final adviceFromTransactions = _buildMonthEndAdvice(
      state.needsTarget,
      state.needsBalance,
      state.bufferBalance,
      state.fakeMayaLink?.summary.transactions ?? [],
      now,
    );

    final advice = <String>[
      ...adviceFromTransactions,
      // Bill increase from jarLedger (covers demo scenario even without FakeMaya).
      if (lastMonthBills > 0 && thisMonthBills > lastMonthBills * 1.10)
        'Bills up ${money(thisMonthBills - lastMonthBills)} vs last month — consider raising your Needs allocation %.',
      if (thisMonthBills > 0 && thisMonthBills > state.needsTarget)
        'Bills exceeded your Needs target of ${money(state.needsTarget)}. Consider finding additional income streams or earning higher income.',
      if (state.bufferMonthsCovered < 1 && state.bufferBalance > 0)
        'Buffer covers less than 1 month. Keep allocating until you have 3 months covered.',
      if (state.bufferMonthsCovered >= 1 &&
          state.needsBalance < state.needsTarget)
        'Buffer is healthy — consider moving some to Needs to fill it faster.',
    ];

    return _GoalSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Monthly summary',
            style: GoogleFonts.fredoka(
              color: _title,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          if (lastMonthBills > 0 || thisMonthBills > 0) ...[
            const Text(
              'BILLS LOGGED',
              style: TextStyle(
                color: _body,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _SummaryStatTile(
                    label: 'This month',
                    value: money(thisMonthBills),
                    color: _title,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryStatTile(
                    label: 'Last month',
                    value: lastMonthBills > 0 ? money(lastMonthBills) : '—',
                    color: _body,
                  ),
                ),
                if (lastMonthBills > 0 && thisMonthBills > lastMonthBills) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryStatTile(
                      label: 'Increase',
                      value: '+${money(thisMonthBills - lastMonthBills)}',
                      color: _red,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (advice.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _brand.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Looking good — jars are on track.',
                style: TextStyle(
                  color: _title,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else ...[
            const Text(
              'SUGGESTIONS',
              style: TextStyle(
                color: _body,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            ...advice.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2, right: 10),
                      child: Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 16,
                        color: _amber,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: _title,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (state.bufferMonthsCovered >= 1 &&
              state.needsBalance < state.needsTarget)
            TextButton(
              onPressed: () {
                state.transferBufferToNeeds();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: _purple),
              child: const Text(
                'Move Buffer surplus → fill Needs now',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryStatTile extends StatelessWidget {
  const _SummaryStatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _bellySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _body,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.nunito(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── End two-jar Goals body ────────────────────────────────────────────────────

// ─── Safety Shield goal ────────────────────────────────────────────────────────

// Returns (title, body, hint, critical).
// hint = one-line suggested action the user can take right now.
({String title, String body, String hint, bool critical})? _shieldCrossAlert(AppState state) {
  // Only show when both goals are active.
  if (state.needsTarget <= 0 || !state.shieldIsSetup) return null;

  final shieldMonths = state.safetyShieldMonthsCovered;
  final bufferMonths = state.bufferMonthsCovered;
  final bufferBalance = state.bufferBalance;
  final bufferTarget = state.needsTarget;
  final bufferDipped = state.jarLedger.take(10).any((e) => e.bufferOut > 0);
  final shieldPct = (state.safetyShieldAllocationPercent * 100).round();
  final bufferPct = (100 - state.needsPercent);

  // Scenario 1 — Critical: both nets depleted.
  if (shieldMonths < 0.5 && bufferMonths < 0.5) {
    return (
      title: 'Both safety nets are nearly empty',
      body: 'Your buffer (${bufferPct}% of income) and Safety Shield ($shieldPct% of income) '
          'are both below half a month. Cut discretionary spending now and direct every surplus peso '
          'to Needs first, then buffer, then Shield.',
      hint: 'Deposit to Safety Shield now — even a small amount rebuilds the habit.',
      critical: true,
    );
  }

  // Scenario 2 — Buffer was tapped AND shield is under 1 month.
  if (bufferDipped && shieldMonths < 1.0) {
    return (
      title: 'Buffer tapped — emergency fund is low',
      body: 'Your buffer covered a shortfall (${money(bufferBalance)} remaining) '
          'and your Safety Shield is below 1 month. These are separate pots with separate '
          'allocations — buffer at $bufferPct%, Shield at $shieldPct%. '
          'Consider a one-time deposit to Shield so it doesn\'t stay low while buffer rebuilds.',
      hint: 'Manually deposit to Safety Shield — it will not touch your buffer allocation.',
      critical: false,
    );
  }

  // Scenario 3 — Buffer critically low, shield has funds to cover.
  if (bufferMonths < 0.2 && shieldMonths >= 1.0) {
    return (
      title: 'Buffer near empty — Shield can help',
      body: 'Your buffer jar is almost empty (${money(bufferBalance)}). '
          'Your Safety Shield has ${shieldMonths.toStringAsFixed(1)} months covered. '
          'You can transfer from savings to wallet as a last resort, but refill buffer '
          'with the next income event ($bufferPct% allocation) first.',
      hint: 'Transfer from Safety Shield savings only if Needs jar cannot cover upcoming bills.',
      critical: false,
    );
  }

  // Scenario 4 — Shield fully funded, buffer could be stronger.
  if (shieldMonths >= state.safetyShieldTargetMonths && bufferMonths < 0.5) {
    return (
      title: 'Shield goal reached — rebuild your buffer',
      body: 'Your Safety Shield hit ${state.safetyShieldTargetMonths}-month target. '
          'Your buffer is thin (${bufferMonths.toStringAsFixed(1)} months). '
          'Consider temporarily reducing Shield allocation ($shieldPct%) '
          'and adding it to your buffer split until buffer is full again.',
      hint: 'Go to IIB goal → Adjust settings to increase buffer % temporarily.',
      critical: false,
    );
  }

  // Scenario 5 — Shield overfunded (≥ 6mo), suggest redirecting to wealth.
  if (shieldMonths >= 6 && bufferMonths >= 0.8) {
    return (
      title: 'Both goals strong — time to grow wealth',
      body: 'Your Safety Shield covers ${shieldMonths.toStringAsFixed(1)} months and your '
          'buffer is healthy. You can safely redirect some of your $shieldPct% Shield '
          'allocation to Layer 3 (investments or time deposit) without weakening either net.',
      hint: 'Reduce Shield allocation and open a new Layer 3 goal.',
      critical: false,
    );
  }

  return null;
}

Future<void> _showCrossAlertDialog(
  BuildContext context,
  ({String title, String body, String hint, bool critical}) alert,
) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: _surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          Icon(
            alert.critical ? Icons.warning_rounded : Icons.link_rounded,
            color: alert.critical ? _red : _amber,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              alert.title,
              style: GoogleFonts.fredoka(
                  color: _title, fontSize: 19, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alert.body,
            style: const TextStyle(
                color: _body, fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (alert.critical ? _red : _amber).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    size: 14, color: alert.critical ? _red : _amber),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    alert.hint,
                    style: TextStyle(
                        color: alert.critical ? _red : _amber,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: alert.critical ? _red : _amber),
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

class _CrossAlertCard extends StatelessWidget {
  const _CrossAlertCard({
    required this.title,
    required this.body,
    required this.hint,
    required this.critical,
  });

  final String title;
  final String body;
  final String hint;
  final bool critical;

  @override
  Widget build(BuildContext context) {
    final color = critical ? _red : _amber;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            critical ? Icons.warning_rounded : Icons.link_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(body,
                    style: const TextStyle(
                        color: _body,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.35)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        size: 12, color: color),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hint,
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shield setup flow ─────────────────────────────────────────────────────────

class _ShieldSetupFlow extends StatefulWidget {
  const _ShieldSetupFlow({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_ShieldSetupFlow> createState() => _ShieldSetupFlowState();
}

class _ShieldSetupFlowState extends State<_ShieldSetupFlow> {
  int _page = 0;
  int _targetMonths = 3;
  double _allocPercent = 10;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            if (_page == 0)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: _title,
                  onPressed: widget.onBack,
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _page == 0
                    ? _ShieldSetupScreenA(
                        key: const ValueKey(0),
                        targetMonths: _targetMonths,
                        onChanged: (v) => setState(() => _targetMonths = v),
                        onNext: () => setState(() => _page = 1),
                      )
                    : _ShieldSetupScreenB(
                        key: const ValueKey(1),
                        allocPercent: _allocPercent,
                        targetMonths: _targetMonths,
                        busy: _busy,
                        onChanged: (v) => setState(() => _allocPercent = v),
                        onBack: () => setState(() => _page = 0),
                        onStart: _start,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _start() async {
    if (_busy) return;
    setState(() => _busy = true);
    await AppScope.of(context).setupSafetyShield(
      allocationPercent: _allocPercent / 100,
      targetMonths: _targetMonths,
    );
    // notifyListeners → GoalsPage rebuilds → shieldIsSetup = true
  }
}

class _ShieldSetupScreenA extends StatelessWidget {
  const _ShieldSetupScreenA({
    super.key,
    required this.targetMonths,
    required this.onChanged,
    required this.onNext,
  });

  final int targetMonths;
  final ValueChanged<int> onChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final monthly = state.safetyShieldMonthlyBase;
    return _JarSetupShell(
      stepDots: _SetupDots(total: 2, current: 0),
      title: 'How big should your safety net be?',
      subtitle:
          'Standard advice is 3–6 months of living expenses. '
          'You can always adjust this later.',
      child: Column(
        children: [
          for (final months in [3, 6])
            GestureDetector(
              onTap: () => onChanged(months),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: targetMonths == months
                      ? _amber.withOpacity(.1)
                      : _surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        targetMonths == months ? _amber : _border,
                    width: targetMonths == months ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text('🛡️',
                        style: TextStyle(
                            fontSize: targetMonths == months ? 28 : 22)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$months months',
                            style: TextStyle(
                              color: _title,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            monthly > 0
                                ? 'Target: ${money(monthly * months)}'
                                : months == 3
                                    ? 'Conservative safety net'
                                    : 'Full emergency cushion',
                            style: const TextStyle(
                                color: _body,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    if (targetMonths == months)
                      const Icon(Icons.check_circle_rounded,
                          color: _amber, size: 22),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'Custom:',
                style: TextStyle(
                    color: _body, fontSize: 13, fontWeight: FontWeight.w700),
              ),
              Expanded(
                child: Slider(
                  value: targetMonths.toDouble(),
                  min: 1,
                  max: 12,
                  divisions: 11,
                  activeColor: _amber,
                  label: '$targetMonths mo',
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
              Text(
                '${targetMonths}mo',
                style: const TextStyle(
                    color: _title, fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
      bottom: PrimaryButton(
        label: 'Next →',
        onPressed: onNext,
      ),
    );
  }
}

class _ShieldSetupScreenB extends StatelessWidget {
  const _ShieldSetupScreenB({
    super.key,
    required this.allocPercent,
    required this.targetMonths,
    required this.busy,
    required this.onChanged,
    required this.onBack,
    required this.onStart,
  });

  final double allocPercent;
  final int targetMonths;
  final bool busy;
  final ValueChanged<double> onChanged;
  final VoidCallback onBack;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final monthly = state.safetyShieldMonthlyBase;
    final perIncome = monthly * allocPercent / 100;
    final remaining = state.safetyShieldTarget - state.safetyShieldBalance;
    final monthsToGoal = (perIncome > 0 && monthly > 0)
        ? (remaining / perIncome).ceil()
        : null;
    return _JarSetupShell(
      stepDots: _SetupDots(total: 2, current: 1),
      title: 'What % goes to your shield?',
      subtitle:
          'Each time income hits your FakeMaya wallet, this share moves toward your emergency fund.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${allocPercent.round()}% of each income',
                style: const TextStyle(
                    color: _title, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              if (monthly > 0)
                Text(
                  '≈ ${money(perIncome)} / income event',
                  style: const TextStyle(
                      color: _body,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
            ],
          ),
          Slider(
            value: allocPercent,
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: _amber,
            label: '${allocPercent.round()}%',
            onChanged: onChanged,
          ),
          const SizedBox(height: 6),
          if (monthsToGoal != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _bellySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded, color: _purple, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'At this rate: ~$monthsToGoal income events to reach '
                      '${targetMonths}-month target',
                      style: const TextStyle(
                          color: _purple,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR SHIELD COVERS',
                  style: TextStyle(
                      color: _body,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1),
                ),
                const SizedBox(height: 8),
                for (final item in [
                  'Rent and housing costs',
                  'Utilities and groceries',
                  'Minimum debt payments',
                  'Transportation essentials',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_rounded,
                            size: 14, color: _amber),
                        const SizedBox(width: 6),
                        Text(item,
                            style: const TextStyle(
                                color: _body,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottom: Column(
        children: [
          PrimaryButton(
            label: busy ? 'Setting up…' : 'Start Safety Shield',
            enabled: !busy,
            onPressed: onStart,
          ),
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: _body),
            onPressed: busy ? null : onBack,
            child: const Text('← Back'),
          ),
        ],
      ),
    );
  }
}

// ── Shield goal body ──────────────────────────────────────────────────────────

class _ShieldGoalBody extends StatelessWidget {
  const _ShieldGoalBody({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final monthly = state.safetyShieldMonthlyBase;
    final balance = state.safetyShieldBalance;
    final months = state.safetyShieldMonthsCovered;
    final allocPct = (state.safetyShieldAllocationPercent * 100).round();
    final targetMonths = state.safetyShieldTargetMonths;
    final fill6 = monthly > 0 ? (balance / (monthly * 6)).clamp(0.0, 1.0) : 0.0;
    final marker3 = 1 / 6;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _GoalDetailHeader(
          eyebrow: 'SAFETY SHIELD',
          onBack: onBack,
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              color: _body,
              tooltip: 'Summary',
              onPressed: () => _showShieldSummarySheet(context, state),
            ),
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              color: _body,
              tooltip: 'Adjust settings',
              onPressed: () => _showShieldConfigSheet(context, state),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _GoalCycleChip(cycle: _goalCycleFor(state)),
                  const SizedBox(width: 8),
                  _GoalLayerChip(goal: state.selectedGoal),
                ],
              ),
              const SizedBox(height: 14),
              // Hero balance card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _amber.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EMERGENCY FUND',
                      style: TextStyle(
                          color: _amber,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      money(balance),
                      style: GoogleFonts.nunito(
                        color: _title,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${months.toStringAsFixed(1)} months covered · target ${targetMonths}mo',
                      style: const TextStyle(
                          color: _body, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Dual-marker progress bar (3mo / 6mo scale)
              LayoutBuilder(builder: (context, constraints) {
                final w = constraints.maxWidth;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: fill6,
                            minHeight: 12,
                            color: _amber,
                            backgroundColor: _amber.withValues(alpha: 0.14),
                          ),
                        ),
                        Positioned(
                          left: w * marker3 - 1,
                          top: 0,
                          bottom: 0,
                          child: Container(width: 2, color: _amber.withValues(alpha: 0.5)),
                        ),
                        Positioned(
                          left: w * 2 / 3 - 1,
                          top: 0,
                          bottom: 0,
                          child: Container(width: 2, color: _amber.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SizedBox(width: w * marker3, child: const Text('')),
                        SizedBox(
                          width: w * marker3,
                          child: const Text('3mo',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: _amber, fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                        SizedBox(
                          width: w * marker3,
                          child: const Text('6mo',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: _amber, fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                );
              }),
              const SizedBox(height: 14),
              // Mini stat row
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      icon: Icons.shield_rounded,
                      iconColor: _amber,
                      label: 'Shield balance',
                      value: money(balance),
                      delta: state.hasFakeMayaLink ? 'FakeMaya Savings' : 'Manually tracked',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStatCard(
                      icon: Icons.percent_rounded,
                      iconColor: _purple,
                      label: 'Allocation',
                      value: '$allocPct%',
                      delta: monthly > 0
                          ? '≈ ${money(monthly * allocPct / 100)} / income'
                          : 'per income event',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Deposit button — moves wallet→savings when FakeMaya linked.
              PrimaryButton(
                label: state.hasFakeMayaLink ? 'Deposit to Safety Shield' : 'Log a deposit',
                icon: Icons.savings_rounded,
                onPressed: () => _showShieldDepositSheet(context, state),
              ),
              const SizedBox(height: 16),
              _WeeklyCheckInTile(state: state),
            ],
          ),
        ),
      ],
    );
  }
}

List<(IconData, String, Color)> _shieldAdvice(
  AppState state,
  double months,
  int allocPct,
  double monthly,
  double balance,
  double target,
) {
  final items = <(IconData, String, Color)>[];
  if (months < 1) {
    items.add((
      Icons.info_outline_rounded,
      'You have less than 1 month covered. Focus on reaching 1 month first — '
          'that alone puts you ahead of most households.',
      _amber,
    ));
  } else if (months < 3) {
    items.add((
      Icons.trending_up_rounded,
      'Good start — ${months.toStringAsFixed(1)} months covered. '
          'Keep going to reach the 3-month milestone.',
      _brand,
    ));
  } else if (months < 6) {
    items.add((
      Icons.check_circle_outline_rounded,
      '3+ months funded — you have the standard safety net. '
          'Stretching to 6 months gives you extra resilience.',
      _brand,
    ));
  } else {
    items.add((
      Icons.star_rounded,
      'Emergency fund fully funded at ${months.toStringAsFixed(1)} months. '
          'Consider redirecting surplus to wealth-building goals.',
      _brand,
    ));
  }
  if (state.hasFakeMayaLink) {
    items.add((
      Icons.account_balance_rounded,
      'Your Safety Shield is tracked from your FakeMaya Savings account. '
          'Every deposit into savings automatically grows your shield.',
      _purple,
    ));
  }
  if (monthly > 0 && allocPct > 0) {
    final perEvent = monthly * allocPct / 100;
    final eventsNeeded = target > balance
        ? ((target - balance) / perEvent).ceil()
        : 0;
    if (eventsNeeded > 0) {
      items.add((
        Icons.schedule_rounded,
        'At $allocPct% per income event (≈ ${money(perEvent)}), '
            'you need about $eventsNeeded more income events to reach your target.',
        _body,
      ));
    }
  }
  items.add((
    Icons.lightbulb_outline_rounded,
    'Keep this fund in a separate savings account — never in your daily wallet. '
        'Out of sight, out of temptation.',
    _body,
  ));
  return items;
}

Future<void> _showShieldSummarySheet(BuildContext context, AppState state) {
  final months = state.safetyShieldMonthsCovered;
  final allocPct = state.safetyShieldAllocationPercent.round();
  final monthly = state.income;
  final balance = state.safetyShieldBalance;
  final target = state.safetyShieldTarget;
  final advice = _shieldAdvice(state, months, allocPct, monthly, balance, target);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const Text(
              'Safety Shield Summary',
              style: TextStyle(color: _title, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            SectionTitle(title: 'Insights & advice', action: ''),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: advice.asMap().entries.map((entry) {
                  final isLast = entry.key == advice.length - 1;
                  final a = entry.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(a.$1, size: 18, color: a.$3),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(a.$2,
                                  style: const TextStyle(
                                      color: _body, fontSize: 13, fontWeight: FontWeight.w600, height: 1.35)),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast) const Divider(height: 1, color: _border, indent: 46),
                    ],
                  );
                }).toList(),
              ),
            ),
            if (state.shieldLedger.isNotEmpty) ...[
              const SizedBox(height: 22),
              SectionTitle(
                  title: 'Deposit history',
                  action: '${state.shieldLedger.length} entries'),
              const SizedBox(height: 10),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: state.shieldLedger.asMap().entries.map((entry) {
                    final isLast = entry.key == state.shieldLedger.length - 1;
                    final e = entry.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.savings_rounded, size: 16, color: _amber),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(e.sentence,
                                    style: const TextStyle(
                                        color: _body, fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                              Text(
                                _formatJarTimestamp(e.timestamp),
                                style: const TextStyle(
                                    color: _body, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast) const Divider(height: 1, color: _border, indent: 44),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Future<void> _showShieldConfigSheet(BuildContext context, AppState state) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ShieldConfigSheet(state: state),
  );
}

Future<void> _showShieldDepositSheet(BuildContext context, AppState state) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ShieldDepositSheet(state: state),
  );
}

// Shows the buffer% and shield% allocations side-by-side so user can see they're independent.
class _ShieldAllocationSplitCard extends StatelessWidget {
  const _ShieldAllocationSplitCard({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final bufferPct = 100 - state.needsPercent;
    final needsPct = state.needsPercent;
    final shieldPct = (state.safetyShieldAllocationPercent * 100).round();
    final monthly = state.safetyShieldMonthlyBase;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bellySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HOW EACH INCOME SPLITS',
            style: TextStyle(
                color: _body,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1),
          ),
          const SizedBox(height: 10),
          _AllocRow(
              label: 'Needs jar',
              percent: needsPct,
              color: _brand,
              note: monthly > 0 ? '≈ ${money(monthly * needsPct / 100)}' : ''),
          const SizedBox(height: 6),
          _AllocRow(
              label: 'Buffer jar',
              percent: bufferPct,
              color: _purple,
              note: monthly > 0 ? '≈ ${money(monthly * bufferPct / 100)}' : ''),
          const SizedBox(height: 6),
          _AllocRow(
              label: 'Safety Shield',
              percent: shieldPct,
              color: _amber,
              note: monthly > 0
                  ? '≈ ${money(monthly * shieldPct / 100)} → savings'
                  : '→ savings'),
          const SizedBox(height: 8),
          Text(
            'Buffer and Shield use separate allocations — '
            'depositing to Shield does not reduce your buffer.',
            style: const TextStyle(
                color: _body, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AllocRow extends StatelessWidget {
  const _AllocRow({
    required this.label,
    required this.percent,
    required this.color,
    required this.note,
  });

  final String label;
  final int percent;
  final Color color;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  color: _title, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        Text(
          '$percent%',
          style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.w900),
        ),
        if (note.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(note,
              style: const TextStyle(
                  color: _body, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }
}

class _ShieldConfigSheet extends StatefulWidget {
  const _ShieldConfigSheet({required this.state});
  final AppState state;

  @override
  State<_ShieldConfigSheet> createState() => _ShieldConfigSheetState();
}

class _ShieldConfigSheetState extends State<_ShieldConfigSheet> {
  late double _allocPercent =
      widget.state.safetyShieldAllocationPercent * 100;
  late int _targetMonths = widget.state.safetyShieldTargetMonths;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final monthly = widget.state.safetyShieldMonthlyBase;
    return _GoalSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Adjust Safety Shield',
            style: GoogleFonts.fredoka(
                color: _title, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Changes take effect immediately. Balances are not reset.',
            style: TextStyle(color: _body, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Target months',
                  style: TextStyle(
                      color: _title, fontWeight: FontWeight.w800)),
              Text('$_targetMonths months',
                  style:
                      const TextStyle(color: _amber, fontWeight: FontWeight.w800)),
            ],
          ),
          Slider(
            value: _targetMonths.toDouble(),
            min: 1,
            max: 12,
            divisions: 11,
            activeColor: _amber,
            label: '$_targetMonths mo',
            onChanged: (v) => setState(() => _targetMonths = v.round()),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Income allocation',
                  style: TextStyle(
                      color: _title, fontWeight: FontWeight.w800)),
              Text(
                '${_allocPercent.round()}%'
                '${monthly > 0 ? ' ≈ ${money(monthly * _allocPercent / 100)}' : ''}',
                style: const TextStyle(
                    color: _amber, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          Slider(
            value: _allocPercent,
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: _amber,
            label: '${_allocPercent.round()}%',
            onChanged: (v) => setState(() => _allocPercent = v),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: _saving ? 'Saving…' : 'Save changes',
            enabled: !_saving,
            onPressed: () {
              setState(() => _saving = true);
              widget.state
                  .updateShieldConfig(
                allocationPercent: _allocPercent / 100,
                targetMonths: _targetMonths,
              )
                  .then((_) {
                if (context.mounted) Navigator.pop(context);
              });
            },
          ),
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              style: TextButton.styleFrom(foregroundColor: _body),
              onPressed: _saving
                  ? null
                  : () {
                      setState(() => _saving = true);
                      widget.state.seedDemoCombinedGoals().then((_) {
                        if (context.mounted) Navigator.pop(context);
                      });
                    },
              child: const Text(
                'Load combined goals demo (IIB + Shield)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShieldDepositSheet extends StatefulWidget {
  const _ShieldDepositSheet({required this.state});
  final AppState state;

  @override
  State<_ShieldDepositSheet> createState() => _ShieldDepositSheetState();
}

class _ShieldDepositSheetState extends State<_ShieldDepositSheet> {
  double _amount = 0;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final linked = widget.state.hasFakeMayaLink;
    return _GoalSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Deposit to Safety Shield',
            style: GoogleFonts.fredoka(
                color: _title, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            linked
                ? 'Moves money from your FakeMaya wallet into your savings account. '
                    'This is separate from your buffer allocation.'
                : 'Record money you moved into your emergency fund savings. '
                    'This is tracked independently from your buffer.',
            style: const TextStyle(color: _body, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          MoneyInput(
            label: linked ? 'Amount to move to savings' : 'Amount deposited',
            initial: _amount,
            onChanged: (v) => setState(() => _amount = v),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: _saving
                ? 'Saving…'
                : linked
                    ? 'Move to savings'
                    : 'Log deposit',
            enabled: !_saving && _amount > 0,
            onPressed: () {
              setState(() => _saving = true);
              widget.state.allocateToSafetyShield(_amount).then((_) {
                if (context.mounted) Navigator.pop(context);
              }).catchError((_) {
                if (context.mounted) setState(() => _saving = false);
              });
            },
          ),
        ],
      ),
    );
  }
}

// ─── End Safety Shield goal ────────────────────────────────────────────────────

class _IrregularIncomeCollectionCard extends StatelessWidget {
  const _IrregularIncomeCollectionCard({required this.data});

  final _IrregularIncomeCycleData data;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final hasAlerts = data.monthEndAdvice.isNotEmpty &&
        (DateTime.now().day >= 25 || data.case2Occurred);
    final billCount = data.events.where((e) => !e.isIncome).length;
    final incomeCount = data.events.where((e) => e.isIncome).length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBubble(
                Icons.water_drop_rounded,
                color: _brand,
                background: _brand.withOpacity(.12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Needs Collection',
                      style: TextStyle(
                        color: _title,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      data.hasFloor
                          ? '$incomeCount income · $billCount bills this month'
                          : 'Tap Setup to start collecting',
                      style: const TextStyle(
                        color: _body,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasAlerts)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _amber.withOpacity(.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${data.monthEndAdvice.length} alerts',
                    style: const TextStyle(
                      color: _amber,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BucketTile(
                  emoji: '🛒',
                  label: 'Basic Needs',
                  balance: data.needsBalance,
                  target: data.needsTarget,
                  percent: data.needsPercent,
                  color: _brand,
                  full: data.needsFull,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BucketTile(
                  emoji: '🌊',
                  label: 'Buffer',
                  balance: data.bufferBalance,
                  target: data.needsTarget,
                  percent: data.bufferPercent,
                  color: _purple,
                  full: data.bufferFull,
                ),
              ),
            ],
          ),
          if (data.activeCase != 'none') ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (data.activeCase == 'Case 1' ? _amber : _brand)
                    .withOpacity(.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                data.activeCase == 'Case 1'
                    ? 'Basic Needs is full — income now flows to Buffer only.'
                    : 'Buffer filled first — surplus moved into Basic Needs.',
                style: TextStyle(
                  color: data.activeCase == 'Case 1' ? _amber : _brand,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () =>
                      _showIrregularIncomeActivitySheet(context, data, state),
                  icon: const Icon(Icons.history_rounded, size: 16),
                  label: const Text('Activity'),
                  style: TextButton.styleFrom(foregroundColor: _brand),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showBasicNeedsConfigSheet(context, state),
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: Text(data.hasFloor ? 'Settings' : 'Setup'),
                  style: TextButton.styleFrom(foregroundColor: _purple),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BucketTile extends StatelessWidget {
  const _BucketTile({
    required this.emoji,
    required this.label,
    required this.balance,
    required this.target,
    required this.percent,
    required this.color,
    required this.full,
  });

  final String emoji;
  final String label;
  final double balance;
  final double target;
  final double percent;
  final Color color;
  final bool full;

  @override
  Widget build(BuildContext context) {
    final fill = target > 0 ? (balance / target).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (full)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'FULL',
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            money(balance),
            style: const TextStyle(
              color: _title,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (target > 0) ...[
            const SizedBox(height: 2),
            Text(
              'of ${money(target)}',
              style: const TextStyle(
                color: _body,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: fill,
                minHeight: 6,
                color: color,
                backgroundColor: color.withOpacity(.14),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '${(percent * 100).round()}% per income',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeEventRow extends StatelessWidget {
  const _IncomeEventRow({required this.event});

  final _BucketEvent event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
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
                      fontSize: 13,
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
                  '+${money(event.needsAdded)} needs · +${money(event.bufferAdded)} buf',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BillEventRow extends StatelessWidget {
  const _BillEventRow({required this.event});

  final _BucketEvent event;

  @override
  Widget build(BuildContext context) {
    final covered = event.note?.startsWith('Covered') ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          fontSize: 13,
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
                      money(event.transaction.amount.abs()),
                      style: const TextStyle(
                        color: _red,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      covered ? 'COVERED' : 'BUFFER USED',
                      style: TextStyle(
                        color: covered ? _brand : _amber,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (event.note != null && event.note!.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                event.note!,
                style: const TextStyle(
                  color: _body,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
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

Future<void> _showIrregularIncomeActivitySheet(
  BuildContext context,
  _IrregularIncomeCycleData data,
  AppState state,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _IrregularIncomeActivitySheet(data: data, state: state),
  );
}

class _IrregularIncomeActivitySheet extends StatelessWidget {
  const _IrregularIncomeActivitySheet(
      {required this.data, required this.state});
  final _IrregularIncomeCycleData data;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final incomeEvents = data.events.where((e) => e.isIncome).toList();
    final billEvents = data.events.where((e) => !e.isIncome).toList();
    final hasAdvice = data.monthEndAdvice.isNotEmpty &&
        (DateTime.now().day >= 25 || data.case2Occurred);
    final weeklyDone = state.hasCurrentWeekAnxietyCheckIn;

    return _GoalSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Activity & Alerts',
            style: GoogleFonts.fredoka(
              color: _title,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Income drops, bills, and month-end notes',
            style: const TextStyle(color: _body, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),

          // ── expense + check-in status ───────────────────────────────
          _CollectionStatusRow(
            icon: Icons.receipt_long_rounded,
            title: 'Expense feed',
            detail:
                '${data.labeledExpenseCount}/${data.expenseCount} categorized · ${money(data.expenseTotal)} tracked',
            complete: data.expenseCount > 0 &&
                data.labeledExpenseCount == data.expenseCount,
          ),
          const SizedBox(height: 8),
          _CollectionStatusRow(
            icon: Icons.mood_rounded,
            title: 'Weekly check-in',
            detail: weeklyDone
                ? '${state.anxietyCheckIns[state.currentAnxietyWeekKey]!.round()} / 5 recorded'
                : 'Not recorded yet this week',
            complete: weeklyDone,
            onTap: () {
              Navigator.pop(context);
              _showAnxietyCheckInSheet(context, state);
            },
          ),

          if (incomeEvents.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'INCOME',
              style: TextStyle(
                  color: _body,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1),
            ),
            const SizedBox(height: 8),
            ...incomeEvents.map((e) => _IncomeEventRow(event: e)),
          ],

          if (billEvents.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'BILLS PAID',
              style: TextStyle(
                  color: _body,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1),
            ),
            const SizedBox(height: 8),
            ...billEvents.map((e) => _BillEventRow(event: e)),
          ],

          if (hasAdvice) ...[
            const SizedBox(height: 20),
            const Text(
              'MONTH-END NOTES',
              style: TextStyle(
                  color: _body,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1),
            ),
            const SizedBox(height: 8),
            ...data.monthEndAdvice.map(
              (advice) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _amber.withOpacity(.09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    advice,
                    style: const TextStyle(
                      color: _title,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ],

          if (incomeEvents.isEmpty && billEvents.isEmpty && !hasAdvice) ...[
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'No activity yet this month.\nIncome drops will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _body, fontWeight: FontWeight.w700, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

Future<void> _showBasicNeedsConfigSheet(
  BuildContext context,
  AppState state,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BasicNeedsConfigSheet(state: state),
  );
}

class _BasicNeedsConfigSheet extends StatefulWidget {
  const _BasicNeedsConfigSheet({required this.state});

  final AppState state;

  @override
  State<_BasicNeedsConfigSheet> createState() => _BasicNeedsConfigSheetState();
}

class _BasicNeedsConfigSheetState extends State<_BasicNeedsConfigSheet> {
  late final TextEditingController _target;
  late double _needsPercent;
  late double _bufferPercent;

  @override
  void initState() {
    super.initState();
    final s = widget.state;
    _target = TextEditingController(
      text: s.basicNeedsMonthlyTarget > 0
          ? s.basicNeedsMonthlyTarget.toStringAsFixed(0)
          : '',
    );
    _needsPercent = s.basicNeedsAllocationPercent;
    _bufferPercent = s.bufferAllocationPercent;
  }

  @override
  void dispose() {
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPct = _needsPercent + _bufferPercent;
    return _GoalSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Basic Needs setup',
            style: GoogleFonts.fredoka(
              color: _title,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Set your monthly basic needs cost and how much of each income drop goes to each bucket.',
            style: TextStyle(
                color: _body, fontWeight: FontWeight.w700, height: 1.35),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _target,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: inputDecoration(
                'Monthly basic needs amount (food, transport, bills)'),
          ),
          const SizedBox(height: 18),
          _PercentSlider(
            label: 'Needs allocation',
            sublabel:
                '${(_needsPercent * 100).round()}% of each income drop → Basic Needs',
            value: _needsPercent,
            color: _brand,
            onChanged: (v) => setState(() => _needsPercent = v),
          ),
          const SizedBox(height: 10),
          _PercentSlider(
            label: 'Buffer allocation',
            sublabel:
                '${(_bufferPercent * 100).round()}% of each income drop → Buffer',
            value: _bufferPercent,
            color: _purple,
            onChanged: (v) => setState(() => _bufferPercent = v),
          ),
          const SizedBox(height: 6),
          Text(
            'Total allocated per income drop: ${(totalPct * 100).round()}%',
            style: TextStyle(
              color: totalPct > 1.0 ? _red : _body,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Save',
            icon: Icons.check_rounded,
            enabled: totalPct <= 1.0,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final amount = _parseMoney(_target.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter a valid monthly basic needs amount.')),
      );
      return;
    }
    widget.state.setBasicNeedsConfig(
      monthlyTarget: amount,
      needsPercent: _needsPercent,
      bufferPercent: _bufferPercent,
    );
    await widget.state.saveProfile();
    if (mounted) Navigator.pop(context);
  }
}

class _PercentSlider extends StatelessWidget {
  const _PercentSlider({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final String sublabel;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: _title, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 2),
        Text(
          sublabel,
          style: const TextStyle(
              color: _body, fontSize: 12, fontWeight: FontWeight.w700),
        ),
        Slider(
          min: 0,
          max: 1,
          divisions: 20,
          value: value,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }
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

class _BucketEvent {
  const _BucketEvent({
    required this.transaction,
    required this.isIncome,
    required this.needsAdded,
    required this.bufferAdded,
    required this.needsBalance,
    required this.bufferBalance,
    this.note,
  });

  final FakeMayaTransaction transaction;
  final bool isIncome;
  final double needsAdded;
  final double bufferAdded;
  final double needsBalance;
  final double bufferBalance;
  final String? note;
}

class _IrregularIncomeCycleData {
  const _IrregularIncomeCycleData({
    required this.needsTarget,
    required this.needsPercent,
    required this.bufferPercent,
    required this.needsBalance,
    required this.bufferBalance,
    required this.case2Occurred,
    required this.events,
    required this.expenseCount,
    required this.labeledExpenseCount,
    required this.expenseTotal,
    required this.monthEndAdvice,
  });

  final double needsTarget;
  final double needsPercent;
  final double bufferPercent;
  final double needsBalance;
  final double bufferBalance;
  final bool case2Occurred;
  final List<_BucketEvent> events;
  final int expenseCount;
  final int labeledExpenseCount;
  final double expenseTotal;
  final List<String> monthEndAdvice;

  bool get hasFloor => needsTarget > 0;
  double get floor => needsTarget;
  bool get needsFull => needsTarget > 0 && needsBalance >= needsTarget;
  bool get bufferFull => needsTarget > 0 && bufferBalance >= needsTarget;
  bool get isShortfall => hasFloor && needsBalance < needsTarget;
  double get difference => hasFloor ? (needsBalance - needsTarget).abs() : 0;
  double get incomeTotal => events
      .where((e) => e.isIncome)
      .fold(0.0, (s, e) => s + e.transaction.amount);

  String get activeCase {
    if (case2Occurred) return 'Case 2';
    if (needsFull) return 'Case 1';
    return 'none';
  }
}

_IrregularIncomeCycleData _irregularIncomeCycleFor(AppState state) {
  final needsTarget = state.basicNeedsMonthlyTarget;
  final needsPercent = state.basicNeedsAllocationPercent;
  final bufferPercent = state.bufferAllocationPercent;
  // ponytail: buffer "full" threshold = one month of basic needs; raise when user sets a separate buffer target
  final bufferTarget = needsTarget;

  final transactions =
      state.fakeMayaLink?.summary.transactions ?? <FakeMayaTransaction>[];
  final now = DateTime.now();

  final monthTxns = transactions.where((t) {
    final date = t.createdAt?.toLocal();
    return date == null || (date.year == now.year && date.month == now.month);
  }).toList()
    ..sort((a, b) => (a.createdAt ?? DateTime(1970))
        .compareTo(b.createdAt ?? DateTime(1970)));

  var needsBalance = 0.0;
  var bufferBalance = 0.0;
  var case2Occurred = false;
  final events = <_BucketEvent>[];

  for (final t in monthTxns) {
    final title = t.title.toLowerCase();
    final isIncome = t.amount > 0 && title.contains('cash in');
    final isBill = t.amount < 0 &&
        (title.contains('send money') || title.contains('sent money')) &&
        _isBasicNeedsCategory(t.category ?? '');

    if (isIncome) {
      final needsAdd = (needsTarget > 0 && needsBalance < needsTarget)
          ? math.min(t.amount * needsPercent, needsTarget - needsBalance)
          : 0.0;
      final bufferAdd = t.amount * bufferPercent;
      needsBalance += needsAdd;
      bufferBalance += bufferAdd;

      // Case 2: buffer overflowed while needs bucket still not full
      if (needsTarget > 0 &&
          bufferTarget > 0 &&
          bufferBalance >= bufferTarget &&
          needsBalance < needsTarget) {
        final topUp = math.min(
          bufferBalance - bufferTarget,
          needsTarget - needsBalance,
        );
        if (topUp > 0) {
          needsBalance += topUp;
          bufferBalance -= topUp;
          case2Occurred = true;
        }
      }

      events.add(_BucketEvent(
        transaction: t,
        isIncome: true,
        needsAdded: needsAdd,
        bufferAdded: bufferAdd,
        needsBalance: needsBalance,
        bufferBalance: bufferBalance,
      ));
    } else if (isBill) {
      final billAmount = t.amount.abs();
      final String note;
      if (needsBalance >= billAmount) {
        needsBalance -= billAmount;
        note = 'Covered by Basic Needs bucket';
      } else if (needsBalance + bufferBalance >= billAmount) {
        final fromBuffer = billAmount - needsBalance;
        needsBalance = 0;
        bufferBalance -= fromBuffer;
        note =
            'Needs + ₱${fromBuffer.toStringAsFixed(0)} from Buffer. Allocation resumed.';
      } else {
        final remaining = billAmount - needsBalance;
        needsBalance = 0;
        bufferBalance = math.max(0, bufferBalance - remaining);
        note = 'Insufficient funds in both buckets for this bill.';
      }
      events.add(_BucketEvent(
        transaction: t,
        isIncome: false,
        needsAdded: 0,
        bufferAdded: 0,
        needsBalance: needsBalance,
        bufferBalance: bufferBalance,
        note: note,
      ));
    }
  }

  final expenses = monthTxns.where((t) {
    final title = t.title.toLowerCase();
    return t.amount < 0 &&
        (title.contains('send money') || title.contains('sent money'));
  }).toList();
  final labeledExpenses =
      expenses.where((t) => t.isLabeled && !t.excludedFromInsights);

  return _IrregularIncomeCycleData(
    needsTarget: needsTarget,
    needsPercent: needsPercent,
    bufferPercent: bufferPercent,
    needsBalance: needsBalance,
    bufferBalance: bufferBalance,
    case2Occurred: case2Occurred,
    events: events.reversed.toList(),
    expenseCount: expenses.length,
    labeledExpenseCount: labeledExpenses.length,
    expenseTotal: labeledExpenses.fold(0.0, (s, t) => s + t.amount.abs()),
    monthEndAdvice: _buildMonthEndAdvice(
      needsTarget,
      needsBalance,
      bufferBalance,
      transactions,
      now,
    ),
  );
}

bool _isBasicNeedsCategory(String category) {
  final cat = category.trim().toLowerCase();
  return cat == 'basic needs' ||
      cat == 'food & drink' ||
      cat == 'food' ||
      cat == 'transport' ||
      cat == 'bills' ||
      cat == 'bills & utilities' ||
      cat == 'groceries' ||
      cat == 'housing';
}

List<String> _buildMonthEndAdvice(
  double needsTarget,
  double needsBalance,
  double bufferBalance,
  List<FakeMayaTransaction> transactions,
  DateTime now,
) {
  if (needsTarget <= 0) return const [];
  final advice = <String>[];

  double billsInMonth(int year, int month) => transactions.where((t) {
        final date = t.createdAt?.toLocal();
        return t.amount < 0 &&
            _isBasicNeedsCategory(t.category ?? '') &&
            date != null &&
            date.year == year &&
            date.month == month;
      }).fold(0.0, (s, t) => s + t.amount.abs());

  final thisMonthBills = billsInMonth(now.year, now.month);
  final prev = DateTime(now.year, now.month - 1);
  final lastMonthBills = billsInMonth(prev.year, prev.month);

  if (lastMonthBills > 0 && thisMonthBills > lastMonthBills * 1.10) {
    advice.add(
      'Bills up ${money(thisMonthBills - lastMonthBills)} vs last month — consider raising your needs allocation %.',
    );
  }
  if (needsBalance < needsTarget * 0.5) {
    advice.add(
      'Needs bucket is less than half full. Look for additional income streams or raise the allocation %.',
    );
  }
  if (bufferBalance <= 0) {
    advice.add(
      'Buffer is empty. Once basic needs are covered, focus on building the buffer for bill surprises.',
    );
  }
  return advice;
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
        ? 'Basic Needs · Buffer: ${money(irregularIncome.bufferBalance)}'
        : '${_layerNameFor(layer)} · $accountName',
    current: irregularIncome?.needsBalance ?? current,
    target: irregularIncome?.needsTarget ?? math.max(accountTarget, current),
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
    final incomeCount = data.events.where((e) => e.isIncome).length;
    return [
      _GoalCycleStep(
        icon: Icons.call_received_rounded,
        title: 'Income captured',
        body:
            '$incomeCount income ${incomeCount == 1 ? 'event' : 'events'} this month — '
            'allocating ${(data.needsPercent * 100).round()}% to needs, '
            '${(data.bufferPercent * 100).round()}% to buffer.',
        color: _brand,
        note: data.events.isEmpty ? 'Waiting for a Cash In transaction.' : null,
      ),
      _GoalCycleStep(
        icon: Icons.water_drop_rounded,
        title: data.activeCase == 'none'
            ? 'Both buckets filling'
            : 'Case detected: ${data.activeCase}',
        body: data.activeCase == 'Case 1'
            ? 'Basic Needs is full — pausing needs allocation, income now goes to Buffer.'
            : data.activeCase == 'Case 2'
                ? 'Buffer filled first — moved surplus into Basic Needs to top it up.'
                : !data.hasFloor
                    ? 'Set up allocation to start the two-bucket system.'
                    : 'Needs: ${money(data.needsBalance)} / ${money(data.needsTarget)} · '
                        'Buffer: ${money(data.bufferBalance)}',
        color: data.activeCase == 'none' ? _purple : _amber,
      ),
      _GoalCycleStep(
        icon: Icons.fact_check_rounded,
        title: 'Complete the expense feed',
        body:
            '${data.labeledExpenseCount}/${data.expenseCount} expenses categorized. '
            'Weekly check-in ${state.hasCurrentWeekAnxietyCheckIn ? 'recorded' : 'still due'}.',
        color: state.hasCurrentWeekAnxietyCheckIn ? _purple : _red,
        note:
            'Bills labeled as food, transport, or bills are tracked against your needs bucket.',
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

  static const _groups = <(String, List<_TxData>)>[];

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
  ) async {
    final state = AppScope.of(context);
    final rule = state.transactionLabelRules[transaction.patternKey];
    if (rule != null && !transaction.isLabeled) {
      final useRule = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'Similar transaction',
            style: GoogleFonts.fredoka(
              color: _title,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'A similar transaction happened before. Is this the same?'),
              const SizedBox(height: 10),
              _TransactionDetailLine(label: 'Category', value: rule.category),
              if (rule.subcategory != null && rule.subcategory!.isNotEmpty)
                _TransactionDetailLine(label: 'Sub', value: rule.subcategory!),
              if (rule.tag != null && rule.tag!.isNotEmpty)
                _TransactionDetailLine(label: 'Tag', value: rule.tag!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No, I\'ll edit'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _brand),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Yes, same'),
            ),
          ],
        ),
      );
      if (useRule == true && context.mounted) {
        await state.labelFakeMayaTransaction(
          transactionId: transaction.transactionId,
          category: rule.category,
          subcategory: rule.subcategory,
          tag: rule.tag,
          note: rule.note,
        );
        return;
      }
      if (!context.mounted) return;
    }
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
    final monthTransactions = _transactionsForMonth(
      widget.transactions,
      _month,
    );
    final income =
        monthTransactions.fold(0.0, (total, tx) => total + tx.incomeAmount);
    final expense =
        monthTransactions.fold(0.0, (total, tx) => total + tx.expenseAmount);
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

    for (final tx in transactions) {
      final occurredAt = tx.occurredAt;
      if (occurredAt == null ||
          occurredAt.year != month.year ||
          occurredAt.month != month.month) {
        continue;
      }
      final slot = leading + occurredAt.day - 1;
      final current = cells[slot];
      cells[slot] = current.copyWith(
        income: current.income + tx.incomeAmount,
        expense: current.expense + tx.expenseAmount,
      );
    }
    return cells;
  }

  static List<_TxData> _transactionsForMonth(
    List<_TxData> transactions,
    DateTime month,
  ) {
    final now = DateTime.now();
    final hasDatedTransactions =
        transactions.any((transaction) => transaction.occurredAt != null);
    return transactions.where((transaction) {
      final occurredAt = transaction.occurredAt;
      if (occurredAt == null) {
        return !hasDatedTransactions &&
            month.year == now.year &&
            month.month == now.month;
      }
      return occurredAt.year == month.year && occurredAt.month == month.month;
    }).toList();
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
    'Basic Needs',
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
              "Shellby won't use this transaction when learning patterns.",
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
