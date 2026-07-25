part of '../../main.dart';

/// Full-page view of wallet transaction history, reachable from the Wallet
/// page's "See Recent Activity" button. Previously this content lived
/// inline at the bottom of the Wallet page's scroll view.
class RecentActivityPage extends StatefulWidget {
  const RecentActivityPage({super.key, this.initialFilter = 'All'});

  final String initialFilter;

  @override
  State<RecentActivityPage> createState() => _RecentActivityPageState();
}

class _RecentActivityPageState extends State<RecentActivityPage> {
  static const _transactionsPerPage = 10;

  late String _filter = widget.initialFilter;
  final ScrollController _scrollController = ScrollController();
  int _visibleTransactionCount = _transactionsPerPage;
  int _filteredTransactionCount = 0;

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

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final linked = state.hasFakeMayaLink;
    final allTransactions = state.allTransactions.map(_txFromFakeMaya).toList();
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

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _title),
        title: const Text(
          'Recent Activity',
          style: TextStyle(color: _title, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            if (linked) ...[
              Row(
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
              const SizedBox(height: 8),
            ],
            SizedBox(
              height: 44,
              child: ListView.separated(
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
            visibleGroups.isEmpty
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
          ],
        ),
      ),
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
}
