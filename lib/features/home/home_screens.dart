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
      if (state.essentialExpensesBalance <= 0) {
        return const Text(
          'Tap to set up your monthly expense budget',
          style: TextStyle(color: _body, fontWeight: FontWeight.w600, fontSize: 13),
        );
      }
      return Row(
        children: [
          const Icon(Icons.home_work_rounded, color: _brand, size: 18),
          const SizedBox(width: 8),
          const Expanded(child: Text('Essential Expenses Fund', style: TextStyle(color: _body, fontSize: 12, fontWeight: FontWeight.w700))),
          Text(money(state.essentialExpensesBalance), style: const TextStyle(color: _title, fontWeight: FontWeight.w900)),
        ],
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
        if (state.essentialExpensesBalance > 0) ...[
          Row(
            children: [
              const Icon(Icons.home_work_rounded, color: _brand, size: 16),
              const SizedBox(width: 7),
              const Expanded(child: Text('Allocated to Essential Expenses Fund', style: TextStyle(color: _body, fontSize: 11, fontWeight: FontWeight.w700))),
              Text(money(state.essentialExpensesBalance), style: const TextStyle(color: _title, fontSize: 12, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 9),
        ],
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
    final current = state.safetyShieldBalance + state.displayedEmergencyFundBalance;
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
    if (account != null) {
      out.add(asset.name == 'FakeMaya Wallet'
          ? _WealthAccount(
              name: account.name,
              sub: 'Unallocated e-wallet cash',
              balance: state.unallocatedFakeMayaWallet,
              color: account.color,
              icon: account.icon,
              layer: account.layer,
            )
          : account);
    }
  }

  if (state.essentialExpensesBalance > 0) {
    out.add(_WealthAccount(
      name: 'Essential Expenses Fund',
      sub: 'Allocated from income',
      balance: state.essentialExpensesBalance,
      color: _brand,
      icon: Icons.home_work_rounded,
      layer: 1,
    ));
  }
  if (state.displayedEmergencyFundBalance > 0) {
    out.add(_WealthAccount(
      name: 'Emergency Fund',
      sub: 'Allocated from income',
      balance: state.displayedEmergencyFundBalance,
      color: _amber,
      icon: Icons.shield_rounded,
      layer: 2,
    ));
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

// ─── D1 goal data ────────────────────────────────────────────────────────────

class _D1GoalMeta {
  const _D1GoalMeta({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.layerColor,
    required this.layerLabel,
    required this.actions,
  });
  final String id;
  final String emoji;
  final String title;
  final String description;
  final Color layerColor;
  final String layerLabel;
  final List<_D1ActionMeta> actions;
}

class _D1ActionMeta {
  const _D1ActionMeta({
    required this.id,
    required this.text,
    required this.configLabel,
    required this.configValue,
    required this.destBucket,
    required this.metrics,
    required this.dataPoints,
    required this.activityLog,
  });

  final String id;
  final String text;
  final String configLabel;
  final String configValue;
  final String destBucket;
  final List<({String label, String value, IconData icon})> metrics;
  final List<({String label, String type, String value})> dataPoints;
  final List<({String date, String event, String amount, bool isIn})> activityLog;
}


const _d1GoalMetas = <_D1GoalMeta>[
  _D1GoalMeta(
    id: 'G1',
    emoji: '💵',
    title: 'Maintain Available Cash',
    description: 'Have and maintain enough available cash to cover expenses without financial stress.',
    layerColor: _brand,
    layerLabel: 'Cash Flow',
    actions: [
      _D1ActionMeta(
        id: 'A1',
        text: 'Set aside 50% of each income received into an Essential Expenses Fund.',
        configLabel: 'Allocation',
        configValue: '50% of income',
        destBucket: 'Essential Expenses Fund',
        metrics: [
          (label: 'Savings-to-Spending', value: '1.5 : 1', icon: Icons.balance_rounded),
          (label: 'Monthly Cash Flow', value: '+₱3,200', icon: Icons.trending_up_rounded),
          (label: 'Cash Balance', value: '₱5,500', icon: Icons.account_balance_wallet_rounded),
          (label: 'Fund Balance', value: '₱7,500', icon: Icons.savings_rounded),
        ],
        dataPoints: [
          (label: 'Financial Activity Date', type: 'T', value: 'Jun 15, 2026'),
          (label: 'Income Transaction', type: 'S', value: '₱15,000'),
          (label: 'Transfer Amount', type: 'S', value: '₱7,500'),
          (label: 'Source Bucket', type: 'S', value: 'Main Cash Account'),
          (label: 'Destination Bucket', type: 'S', value: 'Essential Expenses Fund'),
          (label: 'Available Cash Balance', type: 'S', value: '₱5,500'),
          (label: 'Savings-to-Spending Ratio', type: 'I', value: '1.5 : 1'),
          (label: 'Monthly Cash Flow Balance', type: 'I', value: '+₱3,200'),
        ],
        activityLog: [
          (date: 'Jun 15', event: 'Income received → Essential Expenses Fund', amount: '₱7,500', isIn: true),
          (date: 'Jun 1', event: 'Income received → Essential Expenses Fund', amount: '₱6,000', isIn: true),
          (date: 'May 15', event: 'Income received → Essential Expenses Fund', amount: '₱7,500', isIn: true),
        ],
      ),
      _D1ActionMeta(
        id: 'A3',
        text: 'Limit spending in selected categories to a maximum of ₱X per month.',
        configLabel: 'Category budgets',
        configValue: 'Set per category',
        destBucket: 'Monthly spending limits',
        metrics: [
          (label: 'Budget Adherence', value: '75%', icon: Icons.verified_rounded),
          (label: 'Monthly Cash Flow', value: '+₱3,200', icon: Icons.trending_up_rounded),
          (label: 'Next Bill Due', value: 'Jul 5', icon: Icons.calendar_today_rounded),
          (label: 'Fund Balance', value: '₱2,000', icon: Icons.savings_rounded),
        ],
        dataPoints: [
          (label: 'Financial Activity Date', type: 'T', value: 'Jun 15, 2026'),
          (label: 'Scheduled Bill Due Date', type: 'T', value: 'Jul 5, 2026 (rent)'),
          (label: 'Income Transaction', type: 'S', value: '₱15,000'),
          (label: 'Transfer Amount', type: 'S', value: '₱2,000'),
          (label: 'Source Bucket', type: 'S', value: 'Main Cash Account'),
          (label: 'Destination Bucket', type: 'S', value: 'Bills & Obligations Fund'),
          (label: 'Available Cash Balance', type: 'S', value: '₱5,500'),
          (label: 'Budget Adherence Rate', type: 'I', value: '75%'),
          (label: 'Monthly Cash Flow Balance', type: 'I', value: '+₱3,200'),
        ],
        activityLog: [
          (date: 'Jun 15', event: 'Income received → Bills & Obligations Fund', amount: '₱2,000', isIn: true),
          (date: 'Jun 1', event: 'Income received → Bills & Obligations Fund', amount: '₱2,000', isIn: true),
          (date: 'May 25', event: 'Bill paid — Electricity', amount: '-₱1,800', isIn: false),
          (date: 'May 15', event: 'Income received → Bills & Obligations Fund', amount: '₱2,000', isIn: true),
        ],
      ),
    ],
  ),
  _D1GoalMeta(
    id: 'G3',
    emoji: '🛡️',
    title: 'Build Emergency Fund',
    description: 'Build an emergency fund that can cover unexpected expenses.',
    layerColor: _red,
    layerLabel: 'Financial Safety',
    actions: [
      _D1ActionMeta(
        id: 'A8',
        text: 'Transfer 10% of every income received into an Emergency Fund.',
        configLabel: 'Allocation',
        configValue: '10% of income',
        destBucket: 'Emergency Fund',
        metrics: [
          (label: 'Fund Coverage', value: '1.8 months', icon: Icons.shield_rounded),
          (label: 'Fund Balance', value: '₱18,500', icon: Icons.savings_rounded),
          (label: 'Compliance Rate', value: '85%', icon: Icons.verified_rounded),
          (label: 'Cash Balance', value: '₱5,500', icon: Icons.account_balance_wallet_rounded),
        ],
        dataPoints: [
          (label: 'Financial Activity Date', type: 'T', value: 'Jun 15, 2026'),
          (label: 'Income Transaction', type: 'S', value: '₱15,000'),
          (label: 'Transfer Amount', type: 'S', value: '₱1,500'),
          (label: 'Source Bucket', type: 'S', value: 'Main Cash Account'),
          (label: 'Destination Bucket', type: 'S', value: 'Emergency Fund'),
          (label: 'Available Cash Balance', type: 'S', value: '₱5,500'),
          (label: 'Emergency Fund Balance', type: 'S', value: '₱18,500'),
          (label: 'Emergency Fund Coverage', type: 'I', value: '1.8 months'),
          (label: 'Contribution Compliance Rate', type: 'I', value: '85%'),
        ],
        activityLog: [
          (date: 'Jun 15', event: 'Income received → Emergency Fund', amount: '₱1,500', isIn: true),
          (date: 'Jun 1', event: 'Income received → Emergency Fund', amount: '₱1,200', isIn: true),
          (date: 'May 15', event: 'Income received → Emergency Fund', amount: '₱1,500', isIn: true),
          (date: 'May 1', event: 'Income received → Emergency Fund', amount: '₱1,200', isIn: true),
        ],
      ),
      _D1ActionMeta(
        id: 'A10',
        text: 'Replenish withdrawn Emergency Fund amounts within 7 days after receiving income.',
        configLabel: 'Replenish within',
        configValue: '7 days of income',
        destBucket: 'Emergency Fund',
        metrics: [
          (label: 'Fund Coverage', value: '1.8 months', icon: Icons.shield_rounded),
          (label: 'Fund Balance', value: '₱18,500', icon: Icons.savings_rounded),
          (label: 'Compliance Rate', value: '85%', icon: Icons.verified_rounded),
          (label: 'Last Replenished', value: 'Jun 16', icon: Icons.check_circle_rounded),
        ],
        dataPoints: [
          (label: 'Financial Activity Date', type: 'T', value: 'Jun 16, 2026'),
          (label: 'Income Transaction', type: 'S', value: '₱15,000 on Jun 15'),
          (label: 'Transfer Amount', type: 'S', value: '₱3,000 (replenishment)'),
          (label: 'Source Bucket', type: 'S', value: 'Main Cash Account'),
          (label: 'Destination Bucket', type: 'S', value: 'Emergency Fund'),
          (label: 'Available Cash Balance', type: 'S', value: '₱5,500'),
          (label: 'Emergency Fund Balance', type: 'S', value: '₱18,500'),
          (label: 'Emergency Fund Coverage', type: 'I', value: '1.8 months'),
          (label: 'Contribution Compliance Rate', type: 'I', value: '85%'),
        ],
        activityLog: [
          (date: 'Jun 16', event: 'Replenishment → Emergency Fund (1 day after income)', amount: '₱3,000', isIn: true),
          (date: 'Jun 15', event: 'Income received', amount: '₱15,000', isIn: true),
          (date: 'Jun 12', event: 'Emergency withdrawal from fund', amount: '-₱3,000', isIn: false),
          (date: 'Jun 1', event: 'Replenishment → Emergency Fund (3 days after income)', amount: '₱2,500', isIn: true),
        ],
      ),
    ],
  ),
];

// ─── Goals page ───────────────────────────────────────────────────────────────

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  String? _activeGoalId; // null = list view, 'G1' or 'G3' = detail

  @override
  Widget build(BuildContext context) {
    if (_activeGoalId != null) {
      final goal = _d1GoalMetas.firstWhere((g) => g.id == _activeGoalId);
      return _D1GoalDetailScreen(
        goal: goal,
        onBack: () => setState(() => _activeGoalId = null),
      );
    }
    return _D1GoalsMenu(onGoal: (id) => setState(() => _activeGoalId = id));
  }
}

// ─── Goals menu ───────────────────────────────────────────────────────────────

class _D1GoalsMenu extends StatelessWidget {
  const _D1GoalsMenu({required this.onGoal});
  final ValueChanged<String> onGoal;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
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
        const SizedBox(height: 4),
        Text('Goals', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        const Text(
          'Track your progress and actions for each financial goal.',
          style: TextStyle(color: _body, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        for (final goal in _d1GoalMetas) ...[
          _D1GoalCard(goal: goal, onTap: () => onGoal(goal.id)),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _D1GoalCard extends StatelessWidget {
  const _D1GoalCard({required this.goal, required this.onTap});
  final _D1GoalMeta goal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color accent header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: goal.layerColor.withValues(alpha: .08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: goal.layerColor.withValues(alpha: .15))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: goal.layerColor.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(goal.emoji, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal.id,
                      style: TextStyle(
                        color: goal.layerColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: goal.layerColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      goal.layerLabel,
                      style: TextStyle(
                        color: goal.layerColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Goal content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(
                      color: _title,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    goal.description,
                    style: const TextStyle(
                      color: _body,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _GoalPillChip(
                        icon: Icons.bolt_rounded,
                        label: '${goal.actions.length} actions active',
                        color: goal.layerColor,
                      ),
                      const Spacer(),
                      Text(
                        'View details',
                        style: TextStyle(
                          color: goal.layerColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: goal.layerColor),
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

class _GoalPillChip extends StatelessWidget {
  const _GoalPillChip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

// ─── Goal detail screen ───────────────────────────────────────────────────────

class _D1GoalDetailScreen extends StatelessWidget {
  const _D1GoalDetailScreen({required this.goal, required this.onBack});
  final _D1GoalMeta goal;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
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
                      goal.id,
                      style: TextStyle(
                        color: goal.layerColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'Goals',
                      style: TextStyle(color: _title, fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: goal.layerColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  goal.layerLabel,
                  style: TextStyle(color: goal.layerColor, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Hero card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: goal.layerColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(goal.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        goal.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  goal.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .85),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Actions section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ACTIONS',
                style: TextStyle(
                  color: _body,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < goal.actions.length; i++) ...[
                _D1ActionPanel(action: goal.actions[i], goalColor: goal.layerColor),
                if (i < goal.actions.length - 1) const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Action panel (inside goal detail) ───────────────────────────────────────

class _D1ActionPanel extends StatefulWidget {
  const _D1ActionPanel({required this.action, required this.goalColor});
  final _D1ActionMeta action;
  final Color goalColor;

  @override
  State<_D1ActionPanel> createState() => _D1ActionPanelState();
}

class _D1ActionPanelState extends State<_D1ActionPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    final color = widget.goalColor;
    if (action.id == 'A1') {
      return _EssentialExpensesActionPanel(color: color);
    }
    if (action.id == 'A3') {
      return _CategoryBudgetActionPanel(color: color);
    }
    if (action.id == 'A8') {
      return _EmergencyFundIncomeActionPanel(color: color);
    }
    if (action.id == 'A10') {
      return _EmergencyReplenishmentActionPanel(color: color);
    }
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action header tap area
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      action.id,
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      action.text,
                      style: const TextStyle(
                        color: _title,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: _body,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // Config chip row (always visible)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                _GoalPillChip(
                  icon: Icons.tune_rounded,
                  label: '${action.configLabel}: ${action.configValue}',
                  color: color,
                ),
                const SizedBox(width: 8),
                _GoalPillChip(
                  icon: Icons.savings_rounded,
                  label: action.destBucket,
                  color: _purple,
                ),
              ],
            ),
          ),

          // Key metrics grid (always visible)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.2,
              children: [
                for (final m in action.metrics)
                  _ActionMetricTile(
                    icon: m.icon,
                    label: m.label,
                    value: m.value,
                    color: color,
                  ),
              ],
            ),
          ),

          // Expanded section: activity log + data points
          if (_expanded) ...[
            const Divider(height: 1, color: _border),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RECENT ACTIVITY',
                    style: TextStyle(
                      color: _body,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final log in action.activityLog)
                    _ActivityLogRow(
                      date: log.date,
                      event: log.event,
                      amount: log.amount,
                      isIn: log.isIn,
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'DATA BEING TRACKED',
                    style: TextStyle(
                      color: _body,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final dp in action.dataPoints)
                    _DataPointRow(label: dp.label, type: dp.type, value: dp.value),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

FakeMayaTransaction? _latestIncomeTransaction(AppState state) {
  final transactions = state.fakeMayaLink?.summary.transactions ?? const <FakeMayaTransaction>[];
  final incoming = transactions.where((transaction) {
    if (transaction.amount <= 0) return false;
    final text = '${transaction.title} ${transaction.detail}'.toLowerCase();
    return !text.contains('account opened') &&
        (text.contains('income') ||
            text.contains('salary') ||
            text.contains('payroll') ||
            text.contains('cash in') ||
            text.contains('received'));
  }).toList()
    ..sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
  return incoming.isEmpty ? null : incoming.first;
}

class _EssentialExpensesActionPanel extends StatefulWidget {
  const _EssentialExpensesActionPanel({required this.color});
  final Color color;

  @override
  State<_EssentialExpensesActionPanel> createState() => _EssentialExpensesActionPanelState();
}

class _EssentialExpensesActionPanelState extends State<_EssentialExpensesActionPanel> {
  bool busy = false;

  Future<void> _deposit(AppState state, FakeMayaTransaction income) async {
    if (busy || income.createdAt == null) return;
    setState(() => busy = true);
    await state.depositIncomeToEssentialFund(
      transactionId: income.transactionId,
      incomeAmount: income.amount,
      incomeDate: income.createdAt!,
      percentage: 50,
    );
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final income = _latestIncomeTransaction(state);
    final allocation = (income?.amount ?? 0) * .5;
    final alreadyDeposited = income != null && state.hasEssentialAllocationForIncome(income.transactionId);
    final hasEnoughCash = allocation <= state.unallocatedFakeMayaWallet;
    final date = income?.createdAt;
    final localizations = MaterialLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: widget.color.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)),
                child: Text('A1', style: TextStyle(color: widget.color, fontSize: 11, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Set aside 50% of each income received into an Essential Expenses Fund.', style: TextStyle(color: _title, fontSize: 13, height: 1.4, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _brand.withValues(alpha: .08), borderRadius: BorderRadius.circular(16), border: Border.all(color: _brand.withValues(alpha: .18))),
            child: Row(
              children: [
                const Icon(Icons.home_work_rounded, color: _brand),
                const SizedBox(width: 10),
                const Expanded(child: Text('Essential Expenses Fund', style: TextStyle(color: _title, fontWeight: FontWeight.w900))),
                Text(money(state.essentialExpensesBalance), style: const TextStyle(color: _brand, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (income == null)
            const Text('No income transaction found yet. When FakeMaya records salary, cash-in, or received income, it will appear here.', style: TextStyle(color: _body, height: 1.35, fontWeight: FontWeight.w700))
          else ...[
            const Text('LATEST INCOME', style: TextStyle(color: _body, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.payments_rounded, color: _sage, size: 20),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(income.title, style: const TextStyle(color: _title, fontWeight: FontWeight.w900)),
                      if (date != null)
                        Text('${localizations.formatShortDate(date)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date))}', style: const TextStyle(color: _body, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Text(money(income.amount), style: const TextStyle(color: _sage, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: alreadyDeposited
                  ? '50% deposited to fund'
                  : busy
                      ? 'Depositing...'
                      : 'Deposit 50% (${money(allocation)})',
              icon: alreadyDeposited ? Icons.check_circle_rounded : Icons.savings_rounded,
              enabled: !busy && !alreadyDeposited && hasEnoughCash && date != null,
              onPressed: () => _deposit(state, income),
            ),
            if (!alreadyDeposited && !hasEnoughCash) ...[
              const SizedBox(height: 7),
              Text('The unallocated FakeMaya wallet balance is too low for this deposit.', style: TextStyle(color: _red, fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ],
        ],
      ),
    );
  }
}

class _EmergencyFundIncomeActionPanel extends StatefulWidget {
  const _EmergencyFundIncomeActionPanel({required this.color});
  final Color color;

  @override
  State<_EmergencyFundIncomeActionPanel> createState() => _EmergencyFundIncomeActionPanelState();
}

class _EmergencyFundIncomeActionPanelState extends State<_EmergencyFundIncomeActionPanel> {
  bool busy = false;

  Future<void> _deposit(AppState state, FakeMayaTransaction income) async {
    if (busy || income.createdAt == null) return;
    setState(() => busy = true);
    await state.depositIncomeToEmergencyFund(
      transactionId: income.transactionId,
      incomeAmount: income.amount,
      incomeDate: income.createdAt!,
      percentage: 10,
    );
    if (mounted) setState(() => busy = false);
  }

  Future<void> _useFunds(AppState state) async {
    final controller = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('Use Emergency Fund', style: TextStyle(color: _title, fontWeight: FontWeight.w900)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: inputDecoration('Amount used').copyWith(prefixText: '₱ ', helperText: 'Available: ${money(state.displayedEmergencyFundBalance)}'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.replaceAll(',', '')) ?? 0;
              Navigator.of(dialogContext).pop(value > 0 && value <= state.displayedEmergencyFundBalance ? value : null);
            },
            child: const Text('Record withdrawal'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (amount == null) return;
    await state.useD1BucketFunds('emergency', amount);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final income = _latestIncomeTransaction(state);
    final allocation = (income?.amount ?? 0) * .10;
    final deposited = income != null && state.hasEmergencyAllocationForIncome(income.transactionId);
    final canDeposit = allocation <= state.unallocatedFakeMayaWallet;
    final date = income?.createdAt;
    final localizations = MaterialLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: widget.color.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)),
                child: Text('A8', style: TextStyle(color: widget.color, fontSize: 11, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text('Transfer 10% of every income received into an Emergency Fund.', style: TextStyle(color: _title, fontSize: 13, height: 1.4, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _red.withValues(alpha: .07), borderRadius: BorderRadius.circular(16), border: Border.all(color: _red.withValues(alpha: .16))),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: _red),
                const SizedBox(width: 9),
                const Expanded(child: Text('Emergency Fund', style: TextStyle(color: _title, fontWeight: FontWeight.w900))),
                Text(money(state.displayedEmergencyFundBalance), style: const TextStyle(color: _red, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (income == null)
            const Text('No qualifying income transaction found yet.', style: TextStyle(color: _body, fontWeight: FontWeight.w700))
          else ...[
            const Text('LATEST INCOME', style: TextStyle(color: _body, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(Icons.payments_rounded, color: _sage, size: 20),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(income.title, style: const TextStyle(color: _title, fontWeight: FontWeight.w900)),
                      if (date != null) Text('${localizations.formatShortDate(date)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date))}', style: const TextStyle(color: _body, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Text(money(income.amount), style: const TextStyle(color: _sage, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: deposited ? '10% deposited to fund' : busy ? 'Depositing...' : 'Deposit 10% (${money(allocation)})',
              icon: deposited ? Icons.check_circle_rounded : Icons.shield_rounded,
              enabled: !busy && !deposited && canDeposit && date != null,
              onPressed: () => _deposit(state, income),
            ),
          ],
          if (state.displayedEmergencyFundBalance > 0) ...[
            const SizedBox(height: 9),
            TextButton.icon(onPressed: () => _useFunds(state), icon: const Icon(Icons.outbox_rounded), label: const Text('Use emergency funds')),
          ],
        ],
      ),
    );
  }
}

class _EmergencyReplenishmentActionPanel extends StatefulWidget {
  const _EmergencyReplenishmentActionPanel({required this.color});
  final Color color;

  @override
  State<_EmergencyReplenishmentActionPanel> createState() => _EmergencyReplenishmentActionPanelState();
}

class _EmergencyReplenishmentActionPanelState extends State<_EmergencyReplenishmentActionPanel> {
  bool busy = false;

  Future<void> _replenish(AppState state, double amount) async {
    setState(() => busy = true);
    await state.replenishD1EmergencyFund(amount);
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final pending = state.pendingEmergencyReplenishment;
    final withdrawalDate = state.latestEmergencyWithdrawalDate;
    final latestIncome = _latestIncomeTransaction(state);
    final incomeDate = latestIncome?.createdAt;
    final incomeAfterWithdrawal = withdrawalDate != null && incomeDate != null && incomeDate.isAfter(withdrawalDate);
    final deadline = incomeAfterWithdrawal ? incomeDate.add(const Duration(days: 7)) : null;
    final hoursLeft = deadline?.difference(DateTime.now()).inHours ?? 0;
    final daysLeft = math.max(0, (hoursLeft / 24).ceil());
    final overdue = deadline != null && deadline.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: widget.color.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)),
                child: Text('A10', style: TextStyle(color: widget.color, fontSize: 11, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text('Replenish withdrawn Emergency Fund amounts within 7 days after receiving income.', style: TextStyle(color: _title, fontSize: 13, height: 1.4, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 14),
          if (pending <= 0)
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: _sage.withValues(alpha: .1), borderRadius: BorderRadius.circular(14)),
              child: const Row(children: [Icon(Icons.check_circle_rounded, color: _sage), SizedBox(width: 9), Expanded(child: Text('Your Emergency Fund has no amount waiting to be replenished.', style: TextStyle(color: _title, fontWeight: FontWeight.w800)))]),
            )
          else ...[
            _ActionMetricTile(icon: Icons.outbox_rounded, label: 'Amount used', value: money(pending), color: _red),
            const SizedBox(height: 10),
            if (!incomeAfterWithdrawal)
              const Text('Waiting for your next income. The 7-day replenishment countdown starts when that income arrives.', style: TextStyle(color: _body, height: 1.35, fontWeight: FontWeight.w700))
            else ...[
              _ActionMetricTile(
                icon: overdue ? Icons.warning_rounded : Icons.timer_rounded,
                label: overdue ? 'Replenishment overdue' : 'Time remaining',
                value: overdue ? 'Due now' : '$daysLeft day${daysLeft == 1 ? '' : 's'}',
                color: overdue ? _red : _amber,
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: busy ? 'Replenishing...' : 'Replenish ${money(pending)}',
                icon: Icons.restore_rounded,
                enabled: !busy && pending <= state.unallocatedFakeMayaWallet,
                onPressed: () => _replenish(state, pending),
              ),
              if (pending > state.unallocatedFakeMayaWallet) ...[
                const SizedBox(height: 7),
                const Text('The unallocated FakeMaya wallet balance is too low to replenish the full amount.', style: TextStyle(color: _red, fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class _CategoryBudgetActionPanel extends StatefulWidget {
  const _CategoryBudgetActionPanel({required this.color});
  final Color color;

  @override
  State<_CategoryBudgetActionPanel> createState() => _CategoryBudgetActionPanelState();
}

class _CategoryBudgetActionPanelState extends State<_CategoryBudgetActionPanel> {
  double _spentFor(AppState state, String budgetCategory) {
    final now = DateTime.now();
    return (state.fakeMayaLink?.summary.transactions ?? const <FakeMayaTransaction>[])
        .where((transaction) {
          final category = transaction.category?.trim() ?? '';
          final normalized = category.toLowerCase();
          final budgetNormalized = budgetCategory.toLowerCase();
          final matches = normalized == budgetNormalized ||
              (normalized.contains('food') && budgetNormalized.contains('food')) ||
              (normalized.contains('shop') && budgetNormalized.contains('shop'));
          return transaction.amount < 0 &&
              transaction.isLabeled &&
              !transaction.excludedFromInsights &&
              transaction.createdAt?.year == now.year &&
              transaction.createdAt?.month == now.month &&
              matches;
        })
        .fold(0.0, (total, transaction) => total + transaction.amount.abs());
  }

  Future<void> _configure(AppState state) async {
    final categories = <String>{'Food & Drinks', 'Shopping'};
    for (final transaction in state.fakeMayaLink?.summary.transactions ?? const <FakeMayaTransaction>[]) {
      final category = transaction.category?.trim() ?? '';
      if (category.isNotEmpty && category.toLowerCase() != 'transfer') categories.add(category);
    }
    categories.addAll(state.categorySpendingBudgets.keys);
    final ordered = categories.toList()..sort();
    final selected = state.categorySpendingBudgets.isEmpty
        ? <String>{'Food & Drinks', 'Shopping'}
        : state.categorySpendingBudgets.keys.toSet();
    final controllers = {
      for (final category in ordered)
        category: TextEditingController(
          text: state.categorySpendingBudgets[category]?.toStringAsFixed(0) ??
              (category == 'Food & Drinks' ? '5000' : category == 'Shopping' ? '2500' : ''),
        ),
    };

    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final valid = selected.isNotEmpty && selected.every((category) {
            final amount = double.tryParse(controllers[category]!.text.replaceAll(',', '')) ?? 0;
            return amount > 0 && amount <= 1000000;
          });
          return AlertDialog(
            backgroundColor: _surface,
            title: const Text('Set category budgets', style: TextStyle(color: _title, fontWeight: FontWeight.w900)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final category in ordered)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: _brand,
                        value: selected.contains(category),
                        title: Text(category, style: const TextStyle(color: _title, fontWeight: FontWeight.w800)),
                        subtitle: selected.contains(category)
                            ? Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: TextField(
                                  controller: controllers[category],
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: inputDecoration('Monthly budget').copyWith(prefixText: '₱ '),
                                  onChanged: (_) => setDialogState(() {}),
                                ),
                              )
                            : null,
                        onChanged: (value) => setDialogState(() {
                          if (value ?? false) {
                            selected.add(category);
                          } else {
                            selected.remove(category);
                          }
                        }),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
              FilledButton(
                onPressed: valid
                    ? () => Navigator.of(dialogContext).pop({
                          for (final category in selected)
                            category: double.parse(controllers[category]!.text.replaceAll(',', '')),
                        })
                    : null,
                child: const Text('Save budgets'),
              ),
            ],
          );
        },
      ),
    );
    for (final controller in controllers.values) {
      controller.dispose();
    }
    if (result == null) return;
    await state.updateCategorySpendingBudgets(result);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final budgets = state.categorySpendingBudgets;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: widget.color.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)),
                child: Text('A3', style: TextStyle(color: widget.color, fontSize: 11, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text('Limit spending in selected categories to a monthly maximum.', style: TextStyle(color: _title, fontSize: 13, height: 1.4, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 14),
          if (budgets.isEmpty)
            const Text('Choose the categories you want to control and give each one its own monthly budget.', style: TextStyle(color: _body, height: 1.35, fontWeight: FontWeight.w700))
          else
            for (final entry in budgets.entries) ...[
              _CategoryBudgetProgress(
                category: entry.key,
                spent: _spentFor(state, entry.key),
                budget: entry.value,
              ),
              const SizedBox(height: 13),
            ],
          OutlinedButton.icon(
            onPressed: () => _configure(state),
            icon: const Icon(Icons.tune_rounded),
            label: Text(budgets.isEmpty ? 'Choose category budgets' : 'Edit category budgets'),
          ),
        ],
      ),
    );
  }
}

class _CategoryBudgetProgress extends StatelessWidget {
  const _CategoryBudgetProgress({required this.category, required this.spent, required this.budget});
  final String category;
  final double spent;
  final double budget;

  @override
  Widget build(BuildContext context) {
    final progress = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);
    final color = progress >= 1 ? _red : progress >= .8 ? _amber : _brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(category, style: const TextStyle(color: _title, fontWeight: FontWeight.w900))),
            Text('${money(spent)} / ${money(budget)}', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(value: progress, minHeight: 8, color: color, backgroundColor: color.withValues(alpha: .12)),
        ),
        const SizedBox(height: 4),
        Text('${(progress * 100).round()}% used · ${money(math.max(0, budget - spent))} remaining', style: const TextStyle(color: _body, fontSize: 10.5, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ActionMetricTile extends StatelessWidget {
  const _ActionMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _body, fontSize: 9.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _title, fontSize: 12, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityLogRow extends StatelessWidget {
  const _ActivityLogRow({
    required this.date,
    required this.event,
    required this.amount,
    required this.isIn,
  });
  final String date;
  final String event;
  final String amount;
  final bool isIn;

  @override
  Widget build(BuildContext context) {
    final amountColor = isIn ? _sage : _red;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: amountColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(color: _body, fontSize: 10, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 1),
                Text(
                  event,
                  style: const TextStyle(color: _title, fontSize: 12, fontWeight: FontWeight.w700, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: TextStyle(color: amountColor, fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _DataPointRow extends StatelessWidget {
  const _DataPointRow({required this.label, required this.type, required this.value});
  final String label;
  final String type;
  final String value;

  Color get _typeColor => switch (type) {
    'T' => _purple,
    'I' => _brand,
    _ => _body,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _typeColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: Text(
              type,
              style: TextStyle(color: _typeColor, fontSize: 9, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _body, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(color: _title, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
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
                        money(state.selectedGoalMonthlyTarget),
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
