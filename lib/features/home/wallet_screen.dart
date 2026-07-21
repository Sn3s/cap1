part of '../../main.dart';

// ─── Wallet (merged Accounts + Activity) ──────────────────────────────────────

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  static const _transactionsPerPage = 10;

  // 0=Pyramid, 1=Goals, 2=Spending
  int _secondaryTab = 0;
  int _spendPeriod = 1;
  String _filter = 'All';
  String? _expandedAccount;
  final ScrollController _scrollController = ScrollController();
  int _visibleTransactionCount = _transactionsPerPage;
  int _filteredTransactionCount = 0;

  static const _secondaryTabs = ['Pyramid', 'Goals', 'Spending'];
  static const _filters = [
    'All',
    'Money in',
    'Money out',
    'Cash',
    'Wallet',
    'Savings',
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

  void _handleAccountTap(_WealthAccount? account, String filterToken) {
    setState(() {
      if (_filter != filterToken) {
        _filter = filterToken;
        _visibleTransactionCount = _transactionsPerPage;
      }
      if (account != null &&
          (account.name == 'Wallet' || account.name == 'Savings')) {
        _expandedAccount =
            _expandedAccount == account.name ? null : account.name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final accounts = _buildWealthAccounts(state);

    final linked = state.hasFakeMayaLink;
    final allTransactions =
        state.allTransactions.map(_txFromFakeMaya).toList();
    allTransactions.sort((a, b) {
      final aTime = a.occurredAt;
      final bTime = b.occurredAt;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });
    final filteredTransactions = allTransactions
        .where((transaction) => transaction.matchesFilter(_filter))
        .toList();
    _filteredTransactionCount = filteredTransactions.length;
    final hasOlderTransactions =
        _visibleTransactionCount < _filteredTransactionCount;
    final visibleGroups = _groupTransactionsByDate(
      filteredTransactions.take(_visibleTransactionCount),
    );

    final now = DateTime.now();
    final monthTransactions = allTransactions.where((t) =>
        t.occurredAt != null &&
        t.occurredAt!.year == now.year &&
        t.occurredAt!.month == now.month);
    final moneyIn = monthTransactions
        .where((t) => t.amount > 0)
        .fold(0.0, (s, t) => s + t.amount);
    final moneyOut = monthTransactions
        .where((t) => t.amount < 0)
        .fold(0.0, (s, t) => s + t.amount.abs());

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        const PageHeader(eyebrow: 'WALLET', title: 'My Money'),
        const SizedBox(height: 16),
        _WalletAccountSwitcher(
          accounts: accounts,
          activeFilter: _filter,
          onTap: _handleAccountTap,
        ),
        if (_expandedAccount != null) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _WalletAllocationsCard(
              state: state,
              accountName: _expandedAccount!,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _WalletFlowCard(
                  label: 'Money In',
                  value: moneyIn,
                  color: _sage,
                  icon: Icons.south_west_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WalletFlowCard(
                  label: 'Money Out',
                  value: moneyOut,
                  color: _red,
                  icon: Icons.north_east_rounded,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _WalletSectionDivider(label: 'BREAKDOWN'),
        const SizedBox(height: 12),
        _InsightsFilterBar(
          tabs: _secondaryTabs,
          selected: _secondaryTab,
          onChanged: (i) => setState(() => _secondaryTab = i),
        ),
        const SizedBox(height: 4),
        if (_secondaryTab == 0)
          _PyramidBreakdownSection(accounts: accounts, state: state),
        if (_secondaryTab == 1) _GoalsOverviewSection(state: state),
        if (_secondaryTab == 2)
          _SpendingSection(
            state: state,
            period: _spendPeriod,
            onPeriodChanged: (p) => setState(() => _spendPeriod = p),
          ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        if (linked) ...[
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
          const SizedBox(height: 8),
        ],
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: visibleGroups.isEmpty
              ? _EmptyActivity(linked: linked)
              : Column(
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
                                            : () =>
                                                _showTransactionLabelSheet(
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
              _TransactionDetailLine(label: 'Source', value: rule.source),
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
          source: rule.source,
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
        source: tx.account ?? 'Wallet',
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
        source: tx.account ?? 'Wallet',
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
        source: tx.account ?? 'Wallet',
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
      source: tx.account ?? 'Wallet',
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
}

// ─── Account switcher (new) ────────────────────────────────────────────────────

class _WalletAccountSwitcher extends StatelessWidget {
  const _WalletAccountSwitcher({
    required this.accounts,
    required this.activeFilter,
    required this.onTap,
  });

  final List<_WealthAccount> accounts;
  final String activeFilter;
  final void Function(_WealthAccount? account, String filterToken) onTap;

  static const _nameToFilter = {
    'Cash on Hand': 'Cash',
    'Wallet': 'Wallet',
    'Savings': 'Savings',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: accounts.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          if (i == 0) {
            final total = accounts.fold<double>(0, (s, a) => s + a.balance);
            return _WalletAccountCard(
              label: 'All Accounts',
              sub: 'Combined',
              balance: total,
              color: _brand,
              icon: Icons.account_balance_wallet_rounded,
              active: activeFilter == 'All',
              onTap: () => onTap(null, 'All'),
            );
          }
          final account = accounts[i - 1];
          final filterToken = _nameToFilter[account.name];
          final active = filterToken != null && activeFilter == filterToken;
          return _WalletAccountCard(
            label: account.name,
            sub: account.sub,
            balance: account.balance,
            color: account.color,
            icon: account.icon,
            active: active,
            onTap: filterToken == null
                ? null
                : () => onTap(account, filterToken),
          );
        },
      ),
    );
  }
}

class _WalletAccountCard extends StatelessWidget {
  const _WalletAccountCard({
    required this.label,
    required this.sub,
    required this.balance,
    required this.color,
    required this.icon,
    required this.active,
    this.onTap,
  });

  final String label;
  final String sub;
  final double balance;
  final Color color;
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: active ? 168 : 138,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: active ? null : _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? Colors.transparent : _border),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: active ? Colors.white : color),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : _title,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: active ? Colors.white.withOpacity(0.75) : _body,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              money(balance),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: active ? Colors.white : _title,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Money in / out summary cards (new) ────────────────────────────────────────

class _WalletFlowCard extends StatelessWidget {
  const _WalletFlowCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            money(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _title,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'This month',
            style: TextStyle(
              color: _body,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section divider (new) ─────────────────────────────────────────────────────

class _WalletSectionDivider extends StatelessWidget {
  const _WalletSectionDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: _border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: const TextStyle(
                color: _body,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: _border)),
        ],
      ),
    );
  }
}
