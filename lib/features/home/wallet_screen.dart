part of '../../main.dart';

// ─── Wallet (merged Accounts + Activity) ──────────────────────────────────────

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  // 0=Accounts, 1=Goals, 2=Spending
  int _secondaryTab = 0;
  int _spendPeriod = 1;
  String _filter = 'All';
  String? _expandedAccount;
  bool _autoRefreshingFakeMaya = false;

  static const _secondaryTabs = ['Accounts', 'Goals', 'Spending'];

  Future<void> _refreshFakeMaya() async {
    if (_autoRefreshingFakeMaya) return;
    setState(() => _autoRefreshingFakeMaya = true);
    try {
      await AppScope.of(context).refreshFakeMayaAccount();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FakeMaya wallet refreshed.')),
      );
    } on FakeMayaException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _autoRefreshingFakeMaya = false);
      }
    }
  }

  void _handleAccountTap(_WealthAccount? account, String filterToken) {
    setState(() {
      _filter = filterToken;
      if (account == null) {
        _expandedAccount = null;
      } else if (account.name == 'Wallet' || account.name == 'Savings') {
        _expandedAccount =
            _expandedAccount == account.name ? null : account.name;
      } else {
        _expandedAccount = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final accounts = _buildWealthAccounts(state);

    final allTransactions = state.allTransactions.map(_txFromFakeMaya).toList();
    allTransactions.sort((a, b) {
      final aTime = a.occurredAt;
      final bTime = b.occurredAt;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    final now = DateTime.now();
    final monthTransactions = allTransactions.where((t) {
      final occurredAt = t.occurredAt;
      return occurredAt != null &&
          occurredAt.year == now.year &&
          occurredAt.month == now.month &&
          t.transaction?.isInternalFakeMayaTransfer != true &&
          t.transaction?.excludedFromInsights != true;
    });
    final moneyIn = monthTransactions
        .where((t) => t.amount > 0)
        .fold(0.0, (s, t) => s + t.amount);
    final moneyOut = monthTransactions
        .where((t) => t.amount < 0)
        .fold(0.0, (s, t) => s + t.amount.abs());

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        const PageHeader(eyebrow: 'WALLET', title: 'My Money'),
        if (state.hasFakeMayaLink) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Synced with ${state.fakeMayaLink!.email}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _body,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _autoRefreshingFakeMaya ? null : _refreshFakeMaya,
                  tooltip: 'Refresh FakeMaya',
                  icon: _autoRefreshingFakeMaya
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync_rounded, size: 20),
                  color: _brand,
                  style: IconButton.styleFrom(
                    backgroundColor: _brand.withValues(alpha: .10),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        const SizedBox(height: 10),
        _WalletRecentActivityPreview(
          transactions: allTransactions,
          filter: _filter,
          linked: state.hasFakeMayaLink,
          onTransactionTap: (transaction) => _showWalletTransactionLabelSheet(
            context,
            transaction,
          ),
          onMore: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RecentActivityPage(initialFilter: _filter),
            ),
          ),
        ),
        const SizedBox(height: 18),
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
      ],
    );
  }
}

_TxData _txFromFakeMaya(FakeMayaTransaction tx) {
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

String _transactionSubtitle(FakeMayaTransaction transaction) {
  final detail = transaction.detail.trim();
  final category = transaction.category?.trim() ?? '';
  if (category.isEmpty || category.toLowerCase() == detail.toLowerCase()) {
    return detail;
  }
  return '$detail • $category';
}

List<(String, List<_TxData>)> _groupTransactionsByDate(
  Iterable<_TxData> transactions,
) {
  final groups = <String, List<_TxData>>{};
  for (final transaction in transactions) {
    final label = _dateLabel(transaction.occurredAt);
    groups.putIfAbsent(label, () => []).add(transaction);
  }
  return groups.entries.map((entry) => (entry.key, entry.value)).toList();
}

String _dateLabel(DateTime? date) {
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

Future<void> _showWalletTransactionLabelSheet(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
            _TransactionDetailLine(
              label: transaction.automaticDestination == null
                  ? 'Source'
                  : 'Destination',
              value: transaction.automaticDestination ?? rule.source,
            ),
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
        source: transaction.automaticDestination ?? rule.source,
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

class _WalletRecentActivityPreview extends StatelessWidget {
  const _WalletRecentActivityPreview({
    required this.transactions,
    required this.filter,
    required this.linked,
    required this.onTransactionTap,
    required this.onMore,
  });

  final List<_TxData> transactions;
  final String filter;
  final bool linked;
  final ValueChanged<FakeMayaTransaction> onTransactionTap;
  final VoidCallback onMore;

  static const _previewLimit = 5;

  @override
  Widget build(BuildContext context) {
    final filtered = transactions
        .where((transaction) => transaction.matchesFilter(filter))
        .toList();
    final preview = filtered.take(_previewLimit).toList();
    final hasMore = filtered.length > _previewLimit;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            color: _title,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          filter == 'All'
                              ? 'Latest money movement'
                              : 'Latest $filter movement',
                          style: const TextStyle(
                            color: _body,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onMore,
                    style: TextButton.styleFrom(
                      foregroundColor: _brand,
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Text(
                      hasMore ? 'More' : 'See all',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    label: const Icon(Icons.arrow_forward_rounded, size: 14),
                    iconAlignment: IconAlignment.end,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _border),
            if (preview.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      color: _purple,
                      size: 30,
                    ),
                    const SizedBox(height: 8),
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
                          ? 'Make a movement in FakeMaya, then refresh.'
                          : 'Log a transaction or link FakeMaya for synced activity.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _body,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...preview.asMap().entries.map((entry) {
                final tx = entry.value;
                final isLast = entry.key == preview.length - 1;
                return Column(
                  children: [
                    _ActivityRow(
                      data: tx,
                      onTap: tx.transaction == null
                          ? null
                          : () => onTransactionTap(tx.transaction!),
                    ),
                    if (!isLast)
                      const Divider(height: 1, color: _border, indent: 70),
                  ],
                );
              }),
          ],
        ),
      ),
    );
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
            onTap:
                filterToken == null ? null : () => onTap(account, filterToken),
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
