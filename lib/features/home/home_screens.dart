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
  final _goalsKey = GlobalKey<_GoalsPageState>();

  void openGoal(String goalId) {
    setState(() => index = 2);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _goalsKey.currentState?.openGoal(goalId);
    });
  }

  Future<void> _showManualTransactionSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ManualTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardPage(),
      const WalletPage(),
      GoalsPage(key: _goalsKey),
      const InsightsPage(),
    ];
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            pages[index],
            Positioned(
              bottom: 14,
              right: 16,
              child: _AiSparkleButton(
                onPressed: () => _push(context, const ShellbyChatPage()),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _AddTransactionButton(
        onPressed: () => _showManualTransactionSheet(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _MainNavBar(
        index: index,
        onChanged: (value) => setState(() => index = value),
      ),
    );
  }
}

class _MainNavBar extends StatelessWidget {
  const _MainNavBar({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
    (icon: Icons.track_changes_rounded, label: 'Goals'),
    (icon: Icons.bar_chart_rounded, label: 'Insights'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavBarItem(
                      item: _items[0],
                      selected: index == 0,
                      onTap: () => onChanged(0),
                    ),
                    _NavBarItem(
                      item: _items[1],
                      selected: index == 1,
                      onTap: () => onChanged(1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 72),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavBarItem(
                      item: _items[2],
                      selected: index == 2,
                      onTap: () => onChanged(2),
                    ),
                    _NavBarItem(
                      item: _items[3],
                      selected: index == 3,
                      onTap: () => onChanged(3),
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

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ({IconData icon, String label}) item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _brand : _body;
    return InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                color: selected ? _brand.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(item.icon, color: color, size: 24),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTransactionButton extends StatelessWidget {
  const _AddTransactionButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Add transaction',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _brand.withOpacity(0.55),
              blurRadius: 20,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: _brand.withOpacity(0.30),
              blurRadius: 36,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Material(
          color: _brand,
          shape: const CircleBorder(),
          elevation: 4,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 64,
              height: 64,
              child: Icon(Icons.add_rounded, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}

class _AiSparkleButton extends StatelessWidget {
  const _AiSparkleButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Ask Shellby',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _purple.withOpacity(0.55),
              blurRadius: 16,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: _purple.withOpacity(0.32),
              blurRadius: 28,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Material(
          color: _purple,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
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

String _homeInsightGlimpse(AppState state) {
  if (state.allTransactions.isEmpty) {
    return "Log your first transaction and I'll start spotting patterns to help you save more!";
  }
  final score = state.healthScore;
  if (score >= 75) {
    return "You're doing great this week — your habits are setting you up for real progress. Keep the streak going!";
  }
  if (score >= 50) {
    return "You're building solid momentum. A little more consistency this week could take your goals even further!";
  }
  return 'Every transaction you log helps me find smarter ways to help you save. Small steps add up fast!';
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _refreshingFakeMaya = false;

  Future<void> _refreshFakeMaya() async {
    if (_refreshingFakeMaya) return;
    setState(() => _refreshingFakeMaya = true);
    try {
      await AppScope.of(context).refreshFakeMayaAccount();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FakeMaya account refreshed.')),
      );
    } on FakeMayaException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _refreshingFakeMaya = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final name = state.name.trim();
    final balance = state.accountBalance('Cash on Hand') +
        state.accountBalance('Wallet') +
        state.accountBalance('Savings') +
        state.accountBalance('Time Deposit') +
        state.accountBalance('Goal Savings');
    final balanceParts = balance.toStringAsFixed(2).split('.');
    final spendable =
        state.accountBalance('Cash on Hand') + state.accountBalance('Wallet');
    final saved = state.accountBalance('Savings') +
        state.accountBalance('Time Deposit') +
        state.accountBalance('Goal Savings');

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shellby suggests',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: _purple,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _homeInsightGlimpse(state),
                            style: GoogleFonts.nunito(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _title,
                              height: 1.4,
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
                      delta: state.isAccountSynced('Wallet')
                          ? 'Wallet · synced'
                          : 'Cash and wallet · manual',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStatCard(
                      icon: Icons.savings_rounded,
                      iconColor: _purple,
                      label: 'Saved',
                      value: money(saved),
                      delta: state.fakeMayaSyncedAccounts.any(
                        const {'Savings', 'Time Deposit', 'Goal Savings'}
                            .contains,
                      )
                          ? 'Savings · mixed sources'
                          : 'Savings · manual',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pyramid',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: _title,
                      ),
                    ),
                  ),
                  if (state.hasFakeMayaLink)
                    IconButton(
                      onPressed: _refreshingFakeMaya ? null : _refreshFakeMaya,
                      tooltip: 'Refresh FakeMaya account',
                      icon: _refreshingFakeMaya
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
              const SizedBox(height: 12),
              _PyramidCard(
                icon: Icons.home_filled,
                color: _brand,
                title: _pyramidCashFlowLayer,
                onTap: () => _openBaselineLedgerPage(
                  context,
                  state,
                  _pyramidCashFlowLayer,
                  _brand,
                ),
                child: _PyramidTransactionListContent(
                  state: state,
                  layer: _pyramidCashFlowLayer,
                  color: _brand,
                ),
              ),
              const SizedBox(height: 10),
              _PyramidCard(
                icon: Icons.shield_rounded,
                color: _amber,
                title: _pyramidEmergencyLayer,
                onTap: () => _openBaselineLedgerPage(
                  context,
                  state,
                  _pyramidEmergencyLayer,
                  _amber,
                ),
                child: _PyramidTransactionListContent(
                  state: state,
                  layer: _pyramidEmergencyLayer,
                  color: _amber,
                ),
              ),
              const SizedBox(height: 10),
              _PyramidCard(
                icon: Icons.trending_up_rounded,
                color: _purple,
                title: _pyramidWealthLayer,
                onTap: () => _openBaselineLedgerPage(
                  context,
                  state,
                  _pyramidWealthLayer,
                  _purple,
                ),
                child: _PyramidTransactionListContent(
                  state: state,
                  layer: _pyramidWealthLayer,
                  color: _purple,
                ),
              ),
              const SizedBox(height: 10),
              _PyramidCard(
                icon: Icons.flag_rounded,
                color: const Color(0xFF6AA8F0),
                title: _pyramidFreedomLayer,
                onTap: () => _openBaselineLedgerPage(
                  context,
                  state,
                  _pyramidFreedomLayer,
                  const Color(0xFF6AA8F0),
                ),
                child: _PyramidTransactionListContent(
                  state: state,
                  layer: _pyramidFreedomLayer,
                  color: const Color(0xFF6AA8F0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ShellbyChatPage extends StatefulWidget {
  const ShellbyChatPage({
    super.key,
    this.analysisTitle,
    this.analysisContext,
  });

  final String? analysisTitle;
  final String? analysisContext;

  @override
  State<ShellbyChatPage> createState() => _ShellbyChatPageState();
}

class _ShellbyChatPageState extends State<ShellbyChatPage> {
  final _coach = const ShellbyAiCoach();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late final List<ChatMessage> _messages;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _messages = [
      ChatMessage(
        false,
        widget.analysisTitle == null
            ? 'Hi, I am Shellby. Ask me about your goals, balances, transactions, or anything in the app.'
            : 'I can help you explore the ${widget.analysisTitle} data. I will begin with a summary, then you can ask about any detail.',
      ),
    ];
    if (widget.analysisContext?.trim().isNotEmpty == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.text =
            'Analyze this screen and explain the most important patterns.';
        _send();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final state = AppScope.of(context);
    setState(() {
      _messages.add(ChatMessage(true, text));
      _sending = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final reply = await _coach.chat(
        state: state,
        messages: _messages,
        screenContext: widget.analysisContext,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            false,
            reply.isEmpty
                ? 'I could not form a reply from the current app context yet.'
                : reply,
          ),
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            false,
            _chatErrorMessage(error),
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _scrollToBottom();
      }
    }
  }

  String _chatErrorMessage(Object error) {
    final text = error.toString();
    if (text.contains('Unable to load asset') ||
        text.contains('Set LOCAL_MODEL_ASSET')) {
      return 'I need the bundled GGUF model before I can chat locally. Add the Qwen model under assets/models/ or run with the Gemini provider.';
    }
    if (text.contains('AI model is not configured')) {
      return 'I need either an internet connection for Gemini or the bundled Qwen model under assets/models/ before I can chat.';
    }
    if (text.contains('Gemini proxy request failed: 404')) {
      return 'Gemini proxy was not found. Check GEMINI_PROXY_URL, or run with GEMINI_API_KEY so Shellby can call Gemini directly.';
    }
    if (text.contains('Gemini API request failed: 404')) {
      return 'Gemini model was not found. Shellby is set to $_geminiModel; use a GenerateContent model such as gemini-3.1-flash-lite.';
    }
    return 'I hit a setup issue while starting the AI model. $text';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: _bellySoft,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/shellby_wave.webp',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shellby',
                          style: GoogleFonts.fredoka(
                            color: _title,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.analysisTitle == null
                              ? 'Your app & money chat mate'
                              : '${widget.analysisTitle} chat',
                          style: const TextStyle(
                            color: _body,
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
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return const ChatBubble(
                      fromUser: false,
                      text: 'Thinking...',
                      loading: true,
                    );
                  }
                  final message = _messages[index];
                  return ChatBubble(
                    fromUser: message.fromUser,
                    text: message.text,
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: _messages.length + (_sending ? 1 : 0),
              ),
            ),
            AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: const BoxDecoration(
                  color: _surface,
                  border: Border(top: BorderSide(color: _border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !_sending,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Ask about your app data...',
                          filled: true,
                          fillColor: const Color(0xFFF3F1EC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
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
                            borderSide:
                                const BorderSide(color: _brand, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: _sending ? null : _send,
                      icon: const Icon(Icons.send_rounded),
                      tooltip: 'Send',
                      style: IconButton.styleFrom(
                        backgroundColor: _brand,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _border,
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
}

// ─── Pyramid widgets ───────────────────────────────────────────────────────────

const _pyramidCashFlowLayer = 'Cash Flow & Basic Needs';
const _pyramidEmergencyLayer = 'Financial Safety';
const _pyramidWealthLayer = 'Accumulating Wealth';
const _pyramidFreedomLayer = 'Financial Freedom';

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

class _PyramidTransactionListContent extends StatelessWidget {
  const _PyramidTransactionListContent({
    required this.state,
    required this.layer,
    required this.color,
  });

  final AppState state;
  final String layer;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final entries = _onboardingEntriesForLayer(state, layer);
    final income = entries.where((entry) => entry.isIncome).toList();
    final expenses = entries.where((entry) => !entry.isIncome).toList();
    final incomeTotal =
        income.fold<double>(0, (total, entry) => total + entry.amount);
    final expenseTotal =
        expenses.fold<double>(0, (total, entry) => total + entry.amount);
    final labels = _pyramidSummaryLabelsForLayer(layer);
    if (!_pyramidLayerAllowsIncome(layer)) {
      return _PyramidSummaryTile(
        label: labels.$2,
        count: expenses.length,
        total: expenseTotal,
        color: color,
      );
    }
    return Row(
      children: [
        Expanded(
          child: _PyramidSummaryTile(
            label: labels.$1,
            count: income.length,
            total: incomeTotal,
            color: _sage,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PyramidSummaryTile(
            label: labels.$2,
            count: expenses.length,
            total: expenseTotal,
            color: color,
          ),
        ),
      ],
    );
  }
}

(String, String) _pyramidSummaryLabelsForLayer(String layer) {
  return switch (layer) {
    _pyramidEmergencyLayer => ('Emergency fund', 'Insurance payments'),
    _pyramidWealthLayer => ('Assets', 'Liabilities'),
    _pyramidFreedomLayer => ('', 'Freedom expenses'),
    _ => ('Income', 'Expenses'),
  };
}

bool _pyramidLayerAllowsIncome(String layer) => layer != _pyramidFreedomLayer;

/// Shows the FakeMaya bucket tied to this pyramid layer and its current
/// balance — 0 until a transaction or goal action has actually moved money
/// into it.
class _PyramidMayaBucketTile extends StatelessWidget {
  const _PyramidMayaBucketTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  final String emoji;
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .16)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maya · $label',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  money(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
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

class _PyramidSummaryTile extends StatelessWidget {
  const _PyramidSummaryTile({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  final String label;
  final int count;
  final double total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .16)),
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
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            money(total),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count item${count == 1 ? '' : 's'}',
            style: const TextStyle(
              color: _body,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PyramidLedgerSection extends StatelessWidget {
  const _PyramidLedgerSection({
    required this.entries,
    required this.emptyText,
    required this.onEdit,
    required this.onDelete,
  });

  final List<_PyramidBaselineEntry> entries;
  final String emptyText;
  final ValueChanged<_PyramidBaselineEntry> onEdit;
  final ValueChanged<_PyramidBaselineEntry> onDelete;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Text(
            emptyText,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _body, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }
    final sections = _PyramidLedgerDisplayItem.fromEntries(entries);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemBuilder: (context, index) {
        final item = sections[index];
        final sectionTitle = item.sectionTitle;
        if (sectionTitle != null) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
            child: Text(
              sectionTitle,
              style: const TextStyle(
                color: _body,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          );
        }
        final entry = item.entry!;
        return _PyramidLedgerEntryCard(
          entry: entry,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: sections.length,
    );
  }
}

class _PyramidLedgerDisplayItem {
  const _PyramidLedgerDisplayItem.entry(this.entry) : sectionTitle = null;
  const _PyramidLedgerDisplayItem.section(this.sectionTitle) : entry = null;

  final _PyramidBaselineEntry? entry;
  final String? sectionTitle;

  static List<_PyramidLedgerDisplayItem> fromEntries(
    List<_PyramidBaselineEntry> entries,
  ) {
    final shouldGroupDueDateExpenses = entries.any((entry) =>
            !entry.isIncome &&
            _pyramidLayerGroupsExpenseDueDates(entry.layer)) &&
        entries.every((entry) =>
            !entry.isIncome && _pyramidLayerGroupsExpenseDueDates(entry.layer));
    if (!shouldGroupDueDateExpenses) {
      return [
        for (final entry in entries) _PyramidLedgerDisplayItem.entry(entry)
      ];
    }
    final withDueDate = entries.where((entry) => entry.hasDueDate).toList();
    final withoutDueDate = entries.where((entry) => !entry.hasDueDate).toList();
    return [
      if (withDueDate.isNotEmpty) ...[
        const _PyramidLedgerDisplayItem.section('With due date'),
        for (final entry in withDueDate) _PyramidLedgerDisplayItem.entry(entry),
      ],
      if (withoutDueDate.isNotEmpty) ...[
        const _PyramidLedgerDisplayItem.section('Without due date'),
        for (final entry in withoutDueDate)
          _PyramidLedgerDisplayItem.entry(entry),
      ],
    ];
  }
}

bool _pyramidLayerGroupsExpenseDueDates(String layer) =>
    layer == _pyramidCashFlowLayer || layer == _pyramidFreedomLayer;

class _PyramidLedgerEntryCard extends StatelessWidget {
  const _PyramidLedgerEntryCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final _PyramidBaselineEntry entry;
  final ValueChanged<_PyramidBaselineEntry> onEdit;
  final ValueChanged<_PyramidBaselineEntry> onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(entry.icon, color: entry.isIncome ? _sage : _body),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    color: _title,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  entry.detail,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money(entry.amount),
                style: TextStyle(
                  color: entry.isIncome ? _sage : _red,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              if (entry.editable)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      onPressed: () => onEdit(entry),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: _red,
                      ),
                      onPressed: () => onDelete(entry),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PyramidBaselineLedgerPage extends StatefulWidget {
  const _PyramidBaselineLedgerPage({required this.initialLayer});

  final String initialLayer;

  @override
  State<_PyramidBaselineLedgerPage> createState() =>
      _PyramidBaselineLedgerPageState();
}

class _PyramidBaselineLedgerPageState extends State<_PyramidBaselineLedgerPage>
    with SingleTickerProviderStateMixin {
  static const layers = [
    _pyramidCashFlowLayer,
    _pyramidEmergencyLayer,
    _pyramidWealthLayer,
    _pyramidFreedomLayer,
  ];

  late final TabController _layerController;
  int mode = 1;
  bool _refreshingAssets = false;
  bool _refreshingLiabilities = false;

  @override
  void initState() {
    super.initState();
    final initial = layers.indexOf(widget.initialLayer);
    _layerController = TabController(
      length: layers.length,
      vsync: this,
      initialIndex: initial < 0 ? 0 : initial,
    )..addListener(() {
        if (!_layerController.indexIsChanging) {
          setState(() {
            if (!_pyramidLayerAllowsIncome(currentLayer)) mode = 1;
          });
        }
      });
  }

  @override
  void dispose() {
    _layerController.dispose();
    super.dispose();
  }

  String get currentLayer => layers[_layerController.index];

  Future<void> _refreshFakeMayaAssets() async {
    if (_refreshingAssets) return;
    setState(() => _refreshingAssets = true);
    try {
      await AppScope.of(context).refreshFakeMayaAssetPrices();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FakeMaya asset prices refreshed.')),
      );
    } on FakeMayaException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _refreshingAssets = false);
      }
    }
  }

  Future<void> _refreshFakeMayaLiabilities() async {
    if (_refreshingLiabilities) return;
    setState(() => _refreshingLiabilities = true);
    try {
      await AppScope.of(context).refreshFakeMayaAccount();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FakeMaya liabilities refreshed.')),
      );
    } on FakeMayaException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _refreshingLiabilities = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final entries = _onboardingEntriesForLayer(state, currentLayer);
    final income = entries.where((entry) => entry.isIncome).toList();
    final expenses = entries.where((entry) => !entry.isIncome).toList();
    final allowsIncome = _pyramidLayerAllowsIncome(currentLayer);
    final shown = mode == 0 && allowsIncome ? income : expenses;
    final showingWealthAssets =
        currentLayer == _pyramidWealthLayer && mode == 0 && allowsIncome;
    final showingWealthLiabilities =
        currentLayer == _pyramidWealthLayer && (mode == 1 || !allowsIncome);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _title,
        elevation: 0,
        title: const Text(
          'Pyramid',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        bottom: TabBar(
          controller: _layerController,
          isScrollable: true,
          labelColor: _brand,
          unselectedLabelColor: _body,
          indicatorColor: _brand,
          tabs: const [
            Tab(text: _pyramidCashFlowLayer),
            Tab(text: _pyramidEmergencyLayer),
            Tab(text: _pyramidWealthLayer),
            Tab(text: _pyramidFreedomLayer),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(mode == 0 && allowsIncome ? 'Add income' : 'Add expense'),
        onPressed: () => mode == 0 && allowsIncome
            ? _editIncome(context, state, currentLayer)
            : _editExpense(context, state, currentLayer),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                if (allowsIncome) ...[
                  _LedgerModeButton(
                    label: _pyramidSummaryLabelsForLayer(currentLayer).$1,
                    selected: mode == 0,
                    color: _sage,
                    onTap: () => setState(() => mode = 0),
                  ),
                  const SizedBox(width: 10),
                ],
                _LedgerModeButton(
                  label: _pyramidSummaryLabelsForLayer(currentLayer).$2,
                  selected: mode == 1 || !allowsIncome,
                  color: _brand,
                  onTap: () => setState(() => mode = 1),
                ),
              ],
            ),
          ),
          _LedgerTotalsStrip(income: income, expenses: expenses),
          if (showingWealthAssets && state.hasFakeMayaLink)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _refreshingAssets
                          ? 'Updating assets. Showing the last synced values.'
                          : 'Showing the last synced FakeMaya asset values.',
                      style: const TextStyle(
                        color: _body,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed:
                        _refreshingAssets ? null : _refreshFakeMayaAssets,
                    icon: _refreshingAssets
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync_rounded, size: 17),
                    label: const Text('Refresh assets'),
                  ),
                ],
              ),
            ),
          if (showingWealthLiabilities && state.hasFakeMayaLink)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _refreshingLiabilities
                          ? 'Updating liabilities. Showing the last synced values.'
                          : 'Showing the last synced FakeMaya liabilities.',
                      style: const TextStyle(
                        color: _body,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _refreshingLiabilities
                        ? null
                        : _refreshFakeMayaLiabilities,
                    icon: _refreshingLiabilities
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync_rounded, size: 17),
                    label: const Text('Refresh liabilities'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _PyramidLedgerSection(
              entries: shown,
              emptyText: mode == 0 && allowsIncome
                  ? 'No saved ${_pyramidSummaryLabelsForLayer(currentLayer).$1.toLowerCase()} in this layer yet.'
                  : 'No saved ${_pyramidSummaryLabelsForLayer(currentLayer).$2.toLowerCase()} in this layer yet.',
              onEdit: (entry) => entry.isIncome
                  ? _editIncome(context, state, currentLayer, entry)
                  : _editExpense(context, state, currentLayer, entry),
              onDelete: (entry) => _deleteEntry(context, state, entry),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editIncome(
    BuildContext context,
    AppState state,
    String layer, [
    _PyramidBaselineEntry? entry,
  ]) async {
    final result = await _showIncomeLedgerDialog(context, layer, entry);
    if (result == null) return;
    if (entry == null || entry.index < 0) {
      state.onboardingIncomeLedger.add(result);
    } else {
      state.onboardingIncomeLedger[entry.index] = result;
    }
    await state.saveOnboardingLedgerEdits();
    if (mounted) setState(() {});
  }

  Future<void> _editExpense(
    BuildContext context,
    AppState state,
    String layer, [
    _PyramidBaselineEntry? entry,
  ]) async {
    final result = await _showExpenseLedgerDialog(context, layer, entry);
    if (result == null) return;
    if (entry == null || entry.index < 0) {
      state.onboardingExpenseLedger.add(result);
    } else {
      state.onboardingExpenseLedger[entry.index] = result;
    }
    await state.saveOnboardingLedgerEdits();
    if (mounted) setState(() {});
  }

  Future<void> _deleteEntry(
    BuildContext context,
    AppState state,
    _PyramidBaselineEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('Delete ledger item?'),
        content: Text(entry.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (entry.isIncome) {
      if (entry.index < 0) return;
      state.onboardingIncomeLedger.removeAt(entry.index);
    } else {
      if (entry.index < 0) return;
      state.onboardingExpenseLedger.removeAt(entry.index);
    }
    await state.saveOnboardingLedgerEdits();
    if (mounted) setState(() {});
  }
}

class _LedgerModeButton extends StatelessWidget {
  const _LedgerModeButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: .14) : _surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? color : _border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? color : _body,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _LedgerTotalsStrip extends StatelessWidget {
  const _LedgerTotalsStrip({required this.income, required this.expenses});

  final List<_PyramidBaselineEntry> income;
  final List<_PyramidBaselineEntry> expenses;

  @override
  Widget build(BuildContext context) {
    final incomeTotal =
        income.fold<double>(0, (total, entry) => total + entry.amount);
    final expenseTotal =
        expenses.fold<double>(0, (total, entry) => total + entry.amount);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _PyramidSummaryTile(
              label: 'Income',
              count: income.length,
              total: incomeTotal,
              color: _sage,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PyramidSummaryTile(
              label: 'Expenses',
              count: expenses.length,
              total: expenseTotal,
              color: _red,
            ),
          ),
        ],
      ),
    );
  }
}

void _openBaselineLedgerPage(
  BuildContext context,
  AppState state,
  String layer,
  Color color,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => _PyramidBaselineLedgerPage(initialLayer: layer),
    ),
  );
}

Future<Map<String, dynamic>?> _showIncomeLedgerDialog(
  BuildContext context,
  String layer, [
  _PyramidBaselineEntry? entry,
]) {
  final name = TextEditingController(text: entry?.name ?? '');
  final amount = TextEditingController(
    text: entry == null ? '' : entry.amount.toStringAsFixed(0),
  );
  var stable = entry?.data['stable'] == true;
  var scheduled = entry?.data['scheduled'] == true;
  var payDay = (entry?.data['payDay'] as num?)?.toInt();
  var scheduleAnchorType =
      entry?.data['scheduleAnchorType']?.toString() == 'last' ? 'last' : 'next';
  var scheduleAnchorDate = DateTime.tryParse(
    entry?.data['scheduleAnchorDate']?.toString() ?? '',
  );
  var repeatFrequency = _normalizedScheduleRepeat(
    entry?.data['repeatFrequency']?.toString(),
  );
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: _surface,
        title: Text(entry == null ? 'Add income' : 'Edit income'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: inputDecoration('Income source'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: inputDecoration('Monthly amount')
                    .copyWith(prefixText: '₱ '),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: stable,
                onChanged: (value) =>
                    setDialogState(() => stable = value ?? false),
                title: const Text('Stable income'),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: scheduled,
                onChanged: (value) =>
                    setDialogState(() => scheduled = value ?? false),
                title: const Text('Scheduled income'),
              ),
              if (scheduled) ...[
                const SizedBox(height: 8),
                _ScheduleEditor(
                  title: 'Income schedule',
                  icon: Icons.payments_rounded,
                  anchorType: scheduleAnchorType,
                  lastLabel: 'Last received',
                  nextLabel: 'Next expected',
                  anchorDate: scheduleAnchorDate,
                  repeatFrequency: repeatFrequency,
                  missingDateMessage: 'Choose a known income date.',
                  onAnchorTypeChanged: (value) =>
                      setDialogState(() => scheduleAnchorType = value),
                  onPickDate: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: scheduleAnchorDate ?? now,
                      firstDate: DateTime(now.year - 5),
                      lastDate: DateTime(now.year + 5),
                    );
                    if (picked == null) return;
                    setDialogState(() {
                      scheduleAnchorDate = picked;
                      payDay = picked.day;
                    });
                  },
                  onRepeatChanged: (value) =>
                      setDialogState(() => repeatFrequency = value),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = _baselineAmount(amount.text);
              if (name.text.trim().isEmpty || parsed <= 0) return;
              final inferredPayDay = scheduleAnchorDate?.day ?? payDay;
              Navigator.pop(context, {
                'name': name.text.trim(),
                'amount': parsed,
                'stable': stable,
                'scheduled': scheduled,
                'payDay': scheduled ? inferredPayDay : null,
                'scheduleAnchorType': scheduled ? scheduleAnchorType : null,
                'scheduleAnchorDate':
                    scheduled ? scheduleAnchorDate?.toIso8601String() : null,
                'repeatFrequency': scheduled ? repeatFrequency : null,
                'layer': layer,
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  ).whenComplete(() {
    name.dispose();
    amount.dispose();
  });
}

Future<Map<String, dynamic>?> _showExpenseLedgerDialog(
  BuildContext context,
  String layer, [
  _PyramidBaselineEntry? entry,
]) {
  final name = TextEditingController(text: entry?.name ?? '');
  final amount = TextEditingController(
    text: entry == null ? '' : entry.amount.toStringAsFixed(0),
  );
  var expenseLayer = _expenseLayerForType(layer);
  if (entry?.data['expenseType'] != null || entry?.data['layer'] != null) {
    expenseLayer = expenseLayerFromValue(
            entry?.data['expenseType'] ?? entry?.data['layer']) ??
        expenseLayer;
  }
  var scheduled = entry?.data['scheduled'] == true;
  var dueDay = (entry?.data['dueDay'] as num?)?.toInt();
  var scheduleAnchorType =
      entry?.data['scheduleAnchorType']?.toString() == 'last' ? 'last' : 'next';
  var scheduleAnchorDate = DateTime.tryParse(
    entry?.data['scheduleAnchorDate']?.toString() ?? '',
  );
  var repeatFrequency = _normalizedScheduleRepeat(
    entry?.data['repeatFrequency']?.toString(),
  );
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: _surface,
        title: Text(entry == null ? 'Add expense' : 'Edit expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: inputDecoration('Expense name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: inputDecoration('Monthly amount')
                    .copyWith(prefixText: '₱ '),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<ExpenseLayer>(
                value: expenseLayer,
                decoration: inputDecoration('Expense type'),
                items: ExpenseLayer.values
                    .map((layer) => DropdownMenuItem(
                          value: layer,
                          child: Text(layer.label),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => expenseLayer = value),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: scheduled,
                onChanged: (value) =>
                    setDialogState(() => scheduled = value ?? false),
                title: const Text('Scheduled bill'),
              ),
              if (scheduled) ...[
                const SizedBox(height: 8),
                _ScheduleEditor(
                  title: 'Bill schedule',
                  icon: Icons.receipt_long_rounded,
                  anchorType: scheduleAnchorType,
                  lastLabel: 'Last paid',
                  nextLabel: 'Next due',
                  anchorDate: scheduleAnchorDate,
                  repeatFrequency: repeatFrequency,
                  missingDateMessage: 'Choose a known bill date.',
                  onAnchorTypeChanged: (value) =>
                      setDialogState(() => scheduleAnchorType = value),
                  onPickDate: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: scheduleAnchorDate ?? now,
                      firstDate: DateTime(now.year - 5),
                      lastDate: DateTime(now.year + 5),
                    );
                    if (picked == null) return;
                    setDialogState(() {
                      scheduleAnchorDate = picked;
                      dueDay = picked.day;
                    });
                  },
                  onRepeatChanged: (value) =>
                      setDialogState(() => repeatFrequency = value),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = _baselineAmount(amount.text);
              if (name.text.trim().isEmpty || parsed <= 0) return;
              final inferredDueDay = scheduleAnchorDate?.day ?? dueDay;
              Navigator.pop(context, {
                'name': name.text.trim(),
                'amount': parsed,
                'essential': expenseLayer == ExpenseLayer.basicNeeds,
                'expenseType': expenseLayer?.name,
                'scheduled': scheduled,
                'dueDay': scheduled ? inferredDueDay : null,
                'scheduleAnchorType': scheduled ? scheduleAnchorType : null,
                'scheduleAnchorDate':
                    scheduled ? scheduleAnchorDate?.toIso8601String() : null,
                'repeatFrequency': scheduled ? repeatFrequency : null,
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  ).whenComplete(() {
    name.dispose();
    amount.dispose();
  });
}

ExpenseLayer? _expenseLayerForType(String layer) {
  return switch (layer) {
    _pyramidEmergencyLayer ||
    'Emergency / Insurance' =>
      ExpenseLayer.emergencyInsurance,
    _pyramidWealthLayer || 'Debt / Investments' => ExpenseLayer.debtInvestments,
    _pyramidFreedomLayer || 'Non-Essentials' => ExpenseLayer.nonEssentials,
    _ => ExpenseLayer.basicNeeds,
  };
}

class _PyramidBaselineEntry {
  const _PyramidBaselineEntry({
    required this.index,
    required this.data,
    required this.name,
    required this.amount,
    required this.isIncome,
    required this.layer,
    required this.detail,
    required this.icon,
    this.editable = true,
    this.hasDueDate = false,
  });

  final int index;
  final Map<String, dynamic> data;
  final String name;
  final double amount;
  final bool isIncome;
  final String layer;
  final String detail;
  final IconData icon;
  final bool editable;
  final bool hasDueDate;
}

List<_PyramidBaselineEntry> _onboardingEntriesForLayer(
  AppState state,
  String layer,
) {
  final incomeLedger = state.onboardingIncomeLedger.isNotEmpty
      ? state.onboardingIncomeLedger
      : _fallbackIncomeLedger(state);
  final rawExpenseLedger = state.onboardingExpenseLedger.isNotEmpty
      ? state.onboardingExpenseLedger
      : _fallbackExpenseLedger(state);
  final expenseLedger = _expenseLedgerWithoutStaleFakeMayaCredit(
    state,
    rawExpenseLedger,
  );
  final entries = <_PyramidBaselineEntry>[
    for (var index = 0; index < incomeLedger.length; index++)
      _incomeBaselineEntry(
        index < state.onboardingIncomeLedger.length ? index : -1,
        incomeLedger[index],
      ),
    for (var index = 0; index < expenseLedger.length; index++)
      _expenseBaselineEntry(
        index < state.onboardingExpenseLedger.length ? index : -1,
        expenseLedger[index],
      ),
    if (layer == _pyramidWealthLayer) ...[
      ..._pyramidAssetEntries(state),
      ..._pyramidLiabilityEntries(state),
    ],
  ].where((entry) => entry.amount > 0 && entry.layer == layer).toList()
    ..sort((a, b) {
      if (a.isIncome != b.isIncome) return a.isIncome ? -1 : 1;
      return b.amount.compareTo(a.amount);
    });
  return entries;
}

List<Map<String, dynamic>> _expenseLedgerWithoutStaleFakeMayaCredit(
  AppState state,
  List<Map<String, dynamic>> ledger,
) {
  final summary = state.fakeMayaLink?.summary;
  if (summary == null || summary.creditLimit <= 0) return ledger;
  return [
    for (final row in ledger)
      if (!_isFakeMayaCreditPlaceholder(row)) row,
  ];
}

bool _isFakeMayaCreditPlaceholder(Map<String, dynamic> row) {
  final name = row['name']?.toString().trim().toLowerCase() ?? '';
  if (name.isEmpty) return false;
  return name == 'credit card payment' ||
      name == 'maya easy credit' ||
      (name.contains('credit') && name.contains('payment'));
}

List<_PyramidBaselineEntry> _pyramidAssetEntries(AppState state) {
  final seen = <String>{};
  _PyramidBaselineEntry entryFromMoneyItem(MoneyItem asset) {
    seen.add(asset.name);
    return _PyramidBaselineEntry(
      index: -1,
      data: const {},
      name: asset.name,
      amount: asset.value,
      isIncome: true,
      layer: _pyramidWealthLayer,
      detail: asset.description,
      icon: Icons.trending_up_rounded,
      editable: false,
    );
  }

  return [
    for (final asset in state.assets)
      if (!_isCashLikeFakeMayaAsset(asset)) entryFromMoneyItem(asset),
    for (final holding in state.fakeMayaLink?.summary.investmentHoldings ??
        const <FakeMayaInvestmentHolding>[])
      if (holding.price > 0 &&
          !seen.contains('${holding.name} (${holding.symbol})'))
        entryFromMoneyItem(holding.toMoneyItem()),
  ];
}

List<_PyramidBaselineEntry> _pyramidLiabilityEntries(AppState state) {
  final seen = <String>{};
  _PyramidBaselineEntry entryFromMoneyItem(MoneyItem liability) {
    seen.add(liability.name);
    return _PyramidBaselineEntry(
      index: -1,
      data: const {},
      name: liability.name,
      amount: liability.value,
      isIncome: false,
      layer: _pyramidWealthLayer,
      detail: liability.description,
      icon: Icons.account_balance_rounded,
      editable: false,
    );
  }

  final linkedCredit = state.fakeMayaLink?.summary.creditLiability;
  return [
    for (final liability in state.liabilities) entryFromMoneyItem(liability),
    if (linkedCredit != null && !seen.contains(linkedCredit.name))
      entryFromMoneyItem(linkedCredit),
  ];
}

bool _isCashLikeFakeMayaAsset(MoneyItem item) {
  if (!item.description.contains('FakeMaya')) return false;
  return const {
    'Wallet',
    'Savings',
    'Time Deposit',
    'Goal Savings',
  }.contains(item.name);
}

List<Map<String, dynamic>> _fallbackIncomeLedger(AppState state) {
  if (state.income <= 0) return const [];
  return [
    {
      'name': 'Monthly income baseline',
      'amount': state.income,
      'stable': state.monthlySalary > 0 && state.irregularIncomeFloor <= 0,
      'scheduled': false,
      'payDay': null,
      'layer': _pyramidCashFlowLayer,
    },
  ];
}

List<Map<String, dynamic>> _fallbackExpenseLedger(AppState state) {
  if (state.cashFlowExpenses.isNotEmpty) {
    return [
      for (final expense in state.cashFlowExpenses)
        {
          'name': expense.name,
          'amount': expense.budget,
          'essential': expense.layer == ExpenseLayer.basicNeeds,
          'expenseType': expense.layer.name,
          'scheduled': false,
          'dueDay': null,
        },
    ];
  }
  final entries = <Map<String, dynamic>>[];
  if (state.expenses > 0) {
    entries.add({
      'name': 'Fixed monthly expenses',
      'amount': state.expenses,
      'essential': true,
      'expenseType': ExpenseLayer.basicNeeds.name,
      'scheduled': false,
      'dueDay': null,
    });
  }
  if (state.variableExpenses > 0) {
    entries.add({
      'name': 'Variable monthly expenses',
      'amount': state.variableExpenses,
      'essential': false,
      'expenseType': ExpenseLayer.nonEssentials.name,
      'scheduled': false,
      'dueDay': null,
    });
  }
  if (state.debtPayments > 0) {
    entries.add({
      'name': 'Debt payments',
      'amount': state.debtPayments,
      'essential': false,
      'expenseType': ExpenseLayer.debtInvestments.name,
      'scheduled': false,
      'dueDay': null,
    });
  }
  return entries;
}

_PyramidBaselineEntry _incomeBaselineEntry(
  int index,
  Map<String, dynamic> data,
) {
  final scheduled = data['scheduled'] == true;
  final stable = data['stable'] == true;
  final payDay = (data['payDay'] as num?)?.toInt();
  final anchorDate =
      DateTime.tryParse(data['scheduleAnchorDate']?.toString() ?? '');
  final anchorType =
      data['scheduleAnchorType']?.toString() == 'last' ? 'Last' : 'Next';
  final repeat = data['repeatFrequency']?.toString() ?? 'Monthly';
  final tags = [
    stable ? 'Stable' : 'Variable',
    if (scheduled)
      anchorDate == null
          ? payDay == null
              ? 'Scheduled'
              : 'Day $payDay monthly'
          : '$anchorType ${_shortDate(anchorDate)} · $repeat',
  ];
  return _PyramidBaselineEntry(
    index: index,
    data: data,
    name: _baselineText(data['name'], 'Income source'),
    amount: _baselineAmount(data['amount']),
    isIncome: true,
    layer: _layerFromBaselineTag(data['layer'] ?? data['incomeType']) ??
        _pyramidCashFlowLayer,
    detail: tags.join(' · '),
    icon: Icons.payments_rounded,
  );
}

_PyramidBaselineEntry _expenseBaselineEntry(
  int index,
  Map<String, dynamic> data,
) {
  final layer = expenseLayerFromValue(data['expenseType'] ?? data['layer']);
  final scheduled = data['scheduled'] == true;
  final dueDay = (data['dueDay'] as num?)?.toInt();
  final anchorDate =
      DateTime.tryParse(data['scheduleAnchorDate']?.toString() ?? '');
  final anchorType = data['scheduleAnchorType']?.toString() == 'last'
      ? 'Last paid'
      : 'Next due';
  final repeat = data['repeatFrequency']?.toString() ?? 'Monthly';
  final detail = [
    layer?.label ?? 'Expense',
    if (scheduled)
      anchorDate == null
          ? dueDay == null
              ? 'Scheduled bill'
              : 'Due day $dueDay'
          : '$anchorType ${_shortDate(anchorDate)} · $repeat',
  ].join(' · ');
  return _PyramidBaselineEntry(
    index: index,
    data: data,
    name: _baselineText(data['name'], 'Expense'),
    amount: _baselineAmount(data['amount']),
    isIncome: false,
    layer: _pyramidLayerForExpenseLayer(layer),
    detail: detail,
    icon: layer == null ? Icons.receipt_long_rounded : _expenseLayerIcon(layer),
    hasDueDate: _baselineExpenseHasDueDate(data),
  );
}

bool _baselineExpenseHasDueDate(Map<String, dynamic> data) {
  if (data['scheduled'] == true) return true;
  if ((data['dueDay'] as num?) != null) return true;
  if (DateTime.tryParse(data['scheduleAnchorDate']?.toString() ?? '') != null) {
    return true;
  }
  return DateTime.tryParse(data['dueDate']?.toString() ?? '') != null;
}

String _pyramidLayerForExpenseLayer(ExpenseLayer? layer) {
  return switch (layer) {
    ExpenseLayer.emergencyInsurance => _pyramidEmergencyLayer,
    ExpenseLayer.debtInvestments => _pyramidWealthLayer,
    ExpenseLayer.nonEssentials => _pyramidFreedomLayer,
    _ => _pyramidCashFlowLayer,
  };
}

String? _layerFromBaselineTag(Object? value) {
  final tag = value?.toString().trim().toLowerCase() ?? '';
  if (tag.isEmpty) return null;
  if (tag.contains('cash') || tag.contains('basic')) {
    return _pyramidCashFlowLayer;
  }
  if (tag.contains('emergency') ||
      tag.contains('insurance') ||
      tag.contains('safety')) {
    return _pyramidEmergencyLayer;
  }
  if (tag.contains('asset') ||
      tag.contains('liabil') ||
      tag.contains('investment') ||
      tag.contains('debt') ||
      tag.contains('wealth')) {
    return _pyramidWealthLayer;
  }
  if (tag.contains('freedom') ||
      tag.contains('nonessential') ||
      tag.contains('lifestyle')) {
    return _pyramidFreedomLayer;
  }
  return null;
}

String _baselineText(Object? value, String fallback) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

double _baselineAmount(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().replaceAll(',', '') ?? '') ?? 0;
}

void _showPyramidBaselineSheet(
  BuildContext context,
  AppState state,
  String layer,
  Color color,
) {
  final entries = _onboardingEntriesForLayer(state, layer);
  final income = entries.where((entry) => entry.isIncome).toList();
  final expenses = entries.where((entry) => !entry.isIncome).toList();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: _surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                IconBubble(Icons.layers_rounded,
                    color: color, background: color.withValues(alpha: .12)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    layer,
                    style: const TextStyle(
                      color: _title,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Saved from onboarding monthly income and expenses.',
              style: TextStyle(color: _body, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _PyramidBaselineSheetSection(
              title: 'Income',
              entries: income,
              color: _sage,
              emptyText: 'No onboarding income is linked to this type.',
            ),
            const SizedBox(height: 16),
            _PyramidBaselineSheetSection(
              title: 'Expenses',
              entries: expenses,
              color: color,
              emptyText: 'No onboarding expenses are linked to this type.',
            ),
          ],
        ),
      ),
    ),
  );
}

class _PyramidBaselineSheetSection extends StatelessWidget {
  const _PyramidBaselineSheetSection({
    required this.title,
    required this.entries,
    required this.color,
    required this.emptyText,
  });

  final String title;
  final List<_PyramidBaselineEntry> entries;
  final Color color;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: _title,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              money(total),
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          Text(
            emptyText,
            style: const TextStyle(color: _body, fontWeight: FontWeight.w700),
          )
        else
          for (final entry in entries) ...[
            _PyramidBaselineSheetRow(entry: entry),
            if (entry != entries.last) const Divider(height: 16),
          ],
      ],
    );
  }
}

class _PyramidBaselineSheetRow extends StatelessWidget {
  const _PyramidBaselineSheetRow({required this.entry});

  final _PyramidBaselineEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(entry.icon, color: entry.isIncome ? _sage : _body),
      title: Text(
        entry.name,
        style: const TextStyle(color: _title, fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        entry.detail,
        style: const TextStyle(color: _body, fontWeight: FontWeight.w700),
      ),
      trailing: Text(
        money(entry.amount),
        style: TextStyle(
          color: entry.isIncome ? _sage : _red,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _pyramidLayerForTransaction(FakeMayaTransaction transaction) {
  final source = transaction.source?.trim().toLowerCase() ?? '';
  if (source.isNotEmpty) {
    if (source == 'basic needs fund' ||
        source == 'e-wallet' ||
        source == 'wallet' ||
        source == 'cash on hand' ||
        source.contains('cash flow')) {
      return 'Cash Flow & Basic Needs';
    }
    if (source == 'emergency fund' || source.contains('safety')) {
      return 'Financial Safety';
    }
    if (source == 'investment' ||
        source == 'time deposit' ||
        source.contains('investment') ||
        source.contains('wealth')) {
      return 'Accumulating Wealth';
    }
    if (source == 'lifestyle fund' ||
        source.contains('lifestyle') ||
        source.contains('freedom')) {
      return 'Financial Freedom';
    }
  }

  if (transaction.amount > 0) return 'Cash Flow & Basic Needs';

  return switch (_insightCategoryConfig(transaction.category ?? '').$1) {
    2 => 'Financial Safety',
    3 => 'Accumulating Wealth',
    4 => 'Financial Freedom',
    _ => 'Cash Flow & Basic Needs',
  };
}

// Compute this-month layer-1 (essentials) spending from FakeMaya if available.
double _cashFlowMonthlySpent(AppState state) {
  final now = DateTime.now();
  return (state.fakeMayaLink?.summary.transactions ?? [])
      .where((t) =>
          t.amount < 0 &&
          t.isLabeled &&
          !t.excludedFromInsights &&
          (t.createdAt?.year == now.year && t.createdAt?.month == now.month) &&
          _insightCategoryConfig(t.category ?? '').$1 == 1)
      .fold(0.0, (s, t) => s + t.amount.abs());
}

double _maintainAvailableCashExpectedSpend(AppState state) {
  final basicNeeds = state.monthlyEssentialExpenseTotal;
  if (basicNeeds > 0) return basicNeeds;
  return state.cashFlowBudgetForLayer(ExpenseLayer.basicNeeds);
}

/// "Maintain Available Cash" goal is on track when this month's essentials
/// spend hasn't exceeded the basic-needs baseline budget.
bool isCashFlowGoalOnTrack(AppState state) {
  final total = _maintainAvailableCashExpectedSpend(state);
  if (total <= 0) return false;
  return _cashFlowMonthlySpent(state) <= total;
}

/// "Build Emergency Fund" is complete once the Emergency Fund reaches the
/// six-month Financial Safety target. A22 can still track a smaller configured
/// coverage action, but the goal itself is six months.
bool isEmergencyFundGoalOnTrack(AppState state) {
  final target = _financialSafetyGoalTarget(state);
  if (target <= 0) return false;
  return state.displayedEmergencyFundBalance >= target;
}

bool isLifestyleGoalOnTrack(AppState state) {
  final weeklyLimit = _configuredActionAmount(
    state,
    'A28',
    math.max(100.0, _monthlyLifestyleBase(state) / 4.33),
  );
  return state.lifestyleFundBalance > 0 &&
      _currentWeekLifestyleSpend(state) <= weeklyLimit;
}

/// "Grow Investments" goal is on track once the portfolio has reached its
/// target — replaces the previous always-neutral placeholder now that a
/// real target field (`investmentPortfolioTarget`) is available.
bool isInvestmentGoalOnTrack(AppState state) {
  final target = _configuredInvestmentGoalTarget(state);
  if (target <= 0) return false;
  return state.investmentPortfolioValue >= target;
}

double _clampPercent(double value) => value.isFinite ? value.clamp(0, 100) : 0;

/// Percent-complete for each canonical goal card, clamped 0-100. These are
/// separate from the on-track booleans above: a goal can be "on track" well
/// before it reaches 100% (e.g. the emergency fund) or vice versa.
double cashFlowGoalPercent(AppState state) {
  return maintainAvailableCashFeasibility(state).toDouble();
}

int maintainAvailableCashFeasibility(AppState state) {
  final total = _maintainAvailableCashExpectedSpend(state);
  if (total <= 0) return 0;
  final now = DateTime.now();
  final spent = (state.fakeMayaLink?.summary.transactions ??
          const <FakeMayaTransaction>[])
      .where((transaction) =>
          transaction.amount < 0 &&
          transaction.isLabeled &&
          !transaction.excludedFromInsights &&
          transaction.createdAt?.year == now.year &&
          transaction.createdAt?.month == now.month &&
          _insightCategoryConfig(transaction.category ?? '').$1 == 1)
      .fold(0.0, (sum, transaction) => sum + transaction.amount.abs());
  final wallet = state.fakeMayaLink?.summary.wallet ?? 0;
  final remaining = math.max(0.0, total - spent);
  final essentialExpected = total;
  final latestIncome = _latestIncomeTransaction(state)?.amount ?? 0;
  final coverageScore =
      (wallet / math.max(remaining, total * .1)).clamp(0.0, 1.0);
  final essentialScore = essentialExpected <= 0
      ? coverageScore
      : (state.essentialExpensesBalance / essentialExpected).clamp(0.0, 1.0);
  final spendingScore = spent <= total ? 1.0 : (total / spent).clamp(0.0, 1.0);
  final incomeScore = (latestIncome / total).clamp(0.0, 1.0);
  return ((coverageScore * .55 +
              essentialScore * .20 +
              spendingScore * .15 +
              incomeScore * .10) *
          100)
      .round();
}

double emergencyFundGoalPercent(AppState state) {
  final target = _financialSafetyGoalTarget(state);
  if (target <= 0) return 0;
  final current = state.displayedEmergencyFundBalance;
  return _clampPercent((current / target) * 100);
}

const double _financialSafetyGoalMonths = 6.0;

double _financialSafetyGoalTarget(AppState state) {
  final monthlyEssentials = state.monthlyEssentialExpenseTotal;
  if (monthlyEssentials > 0) {
    return monthlyEssentials * _financialSafetyGoalMonths;
  }
  return math.max(60000.0, state.emergencyFundTarget * 2);
}

double _configuredEmergencyCoverageMonths(AppState state) {
  final raw = _configuredActionValues(state, 'A22')['months'];
  final configured = double.tryParse((raw ?? '').replaceAll(',', '').trim());
  if (configured != null && configured > 0) return configured;
  return 3.0;
}

double _configuredEmergencyCoverageTarget(AppState state) {
  final monthlyEssentials = state.monthlyEssentialExpenseTotal;
  if (monthlyEssentials > 0) {
    return monthlyEssentials * _configuredEmergencyCoverageMonths(state);
  }
  return math.max(30000.0, state.emergencyFundTarget);
}

double investmentGoalPercent(AppState state) {
  final target = _configuredInvestmentGoalTarget(state);
  if (target <= 0) return 0;
  return _clampPercent((state.investmentPortfolioValue / target) * 100);
}

double _configuredInvestmentGoalTarget(AppState state) {
  final raw = _configuredActionValues(state, 'A23')['amt'];
  final configured = double.tryParse((raw ?? '').replaceAll(',', '').trim());
  if (configured != null && configured > 0) return configured;
  return state.investmentPortfolioTarget;
}

double lifestyleGoalPercent(AppState state) {
  final weeklyLimit = _configuredActionAmount(
    state,
    'A28',
    math.max(100.0, _monthlyLifestyleBase(state) / 4.33),
  );
  if (weeklyLimit <= 0) return 0;
  final spent = _currentWeekLifestyleSpend(state);
  return _clampPercent((1 - (spent / weeklyLimit)) * 100);
}

/// Investment Portfolio percent change over the latest 14 days, derived from
/// `investment_gain`/`investment_loss` ledger entries against the balance
/// they moved from. Used as the neutral "+/-X%" stat on the Accumulating
/// Wealth insights header — intentionally not colored green/red there.
double investmentChangeLast14Days(AppState state) {
  final cutoff = DateTime.now().subtract(const Duration(days: 14));
  var delta = 0.0;
  for (final entry in state.d1Ledger) {
    final type = entry['type']?.toString();
    if (type != 'investment_gain' && type != 'investment_loss') continue;
    final date = DateTime.tryParse(entry['date']?.toString() ?? '');
    if (date == null || date.isBefore(cutoff)) continue;
    final amount = (entry['amount'] as num?)?.toDouble() ?? 0;
    delta += type == 'investment_gain' ? amount : -amount;
  }
  final baseline = state.investmentPortfolioValue - delta;
  if (baseline <= 0) return 0;
  return (delta / baseline) * 100;
}

/// Layer -> canonical goal id shown on the Goals page (only these 4 goals
/// have full `_D1GoalMeta` card content authored).
const _layerCanonicalGoalId = <String, String>{
  'Cash Flow & Basic Needs': 'G1',
  'Financial Safety': 'G3',
  'Accumulating Wealth': 'G5',
  'Financial Freedom': 'G8',
};

/// Add Goal unlock rule: which layer becomes addable given the layer chosen
/// at onboarding. `null` means no layer unlocks (Coming Soon).
const _addGoalUnlockMap = <String, String?>{
  'Cash Flow & Basic Needs': 'Financial Safety',
  'Financial Safety': 'Cash Flow & Basic Needs',
  'Accumulating Wealth': null,
  'Financial Freedom': null,
};

bool _isGoalOnTrack(String goalId, AppState state) {
  switch (goalId) {
    case 'G1':
      return isCashFlowGoalOnTrack(state);
    case 'G3':
      return isEmergencyFundGoalOnTrack(state);
    case 'G5':
      return isInvestmentGoalOnTrack(state);
    case 'G8':
      return isLifestyleGoalOnTrack(state);
    default:
      return false;
  }
}

double _goalPercent(String goalId, AppState state) {
  switch (goalId) {
    case 'G1':
      return cashFlowGoalPercent(state);
    case 'G3':
      return emergencyFundGoalPercent(state);
    case 'G5':
      return investmentGoalPercent(state);
    case 'G8':
      return lifestyleGoalPercent(state);
    default:
      return 0;
  }
}

/// Which pyramid layer a given onboarding-catalog goal id belongs to (e.g.
/// 'G8' -> 'Financial Freedom'), used as a fallback so the goal actually
/// selected during onboarding is respected even if it isn't the layer's
/// default pick.
String? _layerForGoalId(String goalId) {
  for (final entry in _motivationGoalIds.entries) {
    if (entry.value.contains(goalId)) return entry.key;
  }
  return null;
}

String? _motivationForGoalId(String goalId) => _layerForGoalId(goalId);

Future<void> _confirmAndEnsureFakeMayaBucketForGoal(
  BuildContext context,
  AppState state,
  String goalId,
) async {
  final motivation = _motivationForGoalId(goalId);
  if (motivation == null) {
    return;
  }
  if (state.mockDataEnabled) {
    return;
  }
  final bucketId = fakeMayaBucketIdForMotivation(motivation);
  var link = state.fakeMayaLink;
  if (bucketId != null && link != null) {
    try {
      await state.refreshFakeMayaAccount(reconcileBuckets: false);
      link = state.fakeMayaLink;
    } on FakeMayaException {
      link = state.fakeMayaLink;
    }
  }
  final bucketExists = bucketId != null &&
      link != null &&
      link.summary.personalGoalById(bucketId) != null;
  if (bucketExists) {
    return;
  }
  final bucketMissing = bucketId != null &&
      link != null &&
      link.summary.personalGoalById(bucketId) == null;
  final needsConfirmation = bucketMissing || link == null;
  if (!needsConfirmation) {
    return;
  }
  final agreed = await confirmFakeMayaBucketCreation(
    context,
    motivation: motivation,
  );
  if (!agreed || !context.mounted) {
    return;
  }
  if (state.fakeMayaLink == null) {
    await showFakeMayaLinkRequiredForBucket(context);
    return;
  }
  await state.ensureFakeMayaBucketForMotivation(motivation);
}

/// Which canonical goal cards should render on the Goals page. The
/// Reflection Demo account always shows all of them (showcase account).
/// Real accounts always see the goal for their onboarding pick —
/// preferring the layer implied by `selectedGoalId` (falling back to
/// `primaryConcern` when that's unset) — plus whatever goals were
/// explicitly added via "+ Add Goal" (`AppState.addedGoalIds`). This is
/// intentionally NOT based on action-selection overlap
/// (`_insightsAdoptedMotivations`) — several goals share action ids across
/// their catalogs (e.g. G4 and G3 both include 'A10'), which would falsely
/// mark a goal "added" just because an unrelated goal's action overlaps.
Set<String> _visibleGoalIds(AppState state) {
  if (_insightsIsReflectionDemoAccount(state)) {
    return _d1GoalMetas.map((g) => g.id).toSet();
  }
  final ids = <String>{...state.addedGoalIds};
  final onboardingLayer =
      _layerForGoalId(state.selectedGoalId) ?? state.primaryConcern;
  final primaryGoalId = _layerCanonicalGoalId[onboardingLayer];
  if (primaryGoalId != null) ids.add(primaryGoalId);
  return ids;
}

/// (goals on track, goals total) across the goals currently visible to
/// this account.
(int, int) goalsOnTrackSummary(AppState state) {
  final visible = _visibleGoalIds(state);
  final onTrack = visible.where((id) => _isGoalOnTrack(id, state)).length;
  return (onTrack, visible.length);
}

class _CashFlowPyramidContent extends StatelessWidget {
  const _CashFlowPyramidContent({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final total = state.cashFlowPyramidBaseline;
    if (total == 0) {
      if (state.essentialExpensesBalance <= 0) {
        return const Text(
          'Add monthly expenses during setup to build this layer',
          style: TextStyle(
              color: _body, fontWeight: FontWeight.w600, fontSize: 13),
        );
      }
      return Row(
        children: [
          const Icon(Icons.home_work_rounded, color: _brand, size: 18),
          const SizedBox(width: 8),
          const Expanded(
              child: Text('Essential Expenses Fund',
                  style: TextStyle(
                      color: _body,
                      fontSize: 12,
                      fontWeight: FontWeight.w700))),
          Text(money(state.essentialExpensesBalance),
              style:
                  const TextStyle(color: _title, fontWeight: FontWeight.w900)),
        ],
      );
    }
    final spent = _cashFlowMonthlySpent(state);
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
              const Expanded(
                  child: Text('Allocated to Essential Expenses Fund',
                      style: TextStyle(
                          color: _body,
                          fontSize: 11,
                          fontWeight: FontWeight.w700))),
              Text(money(state.essentialExpensesBalance),
                  style: const TextStyle(
                      color: _title,
                      fontSize: 12,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 9),
        ],
        if (state.monthlyExpenseLedgerTotal > 0) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Essential ${money(state.monthlyEssentialExpenseTotal)}',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Non-essential ${money(state.monthlyNonEssentialExpenseTotal)}',
                style: const TextStyle(
                  color: _body,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
    final current =
        state.safetyShieldBalance + state.displayedEmergencyFundBalance;
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
          .map((e) => CashFlowExpense(e.name, e.budget, layer: e.layer)));
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
    final layerTotals = {
      for (final layer in ExpenseLayer.values)
        layer: _expenses
            .where((expense) => expense.layer == layer)
            .fold(0.0, (sum, expense) => sum + expense.budget),
    };
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
                          'EXPENSES',
                          style: TextStyle(
                              color: _body,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2),
                        ),
                        Text('Plan your expenses',
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
                          color: _brand.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                          const SizedBox(height: 12),
                          for (final layer in ExpenseLayer.values)
                            if ((layerTotals[layer] ?? 0) > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      _expenseLayerIcon(layer),
                                      size: 16,
                                      color: _expenseLayerColor(layer),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        layer.label,
                                        style: const TextStyle(
                                          color: _body,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      money(layerTotals[layer] ?? 0),
                                      style: const TextStyle(
                                        color: _title,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    decoration:
                        inputDecoration('Budget').copyWith(prefixText: '₱ '),
                    onChanged: (v) {
                      final parsed =
                          double.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), ''));
                      widget.expense.budget = parsed ?? 0;
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Remove expense',
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: _body,
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<ExpenseLayer>(
              value: widget.expense.layer,
              isExpanded: true,
              decoration: inputDecoration('Expense type').copyWith(
                labelText: 'Expense type',
                prefixIcon: Icon(
                  _expenseLayerIcon(widget.expense.layer),
                  color: _expenseLayerColor(widget.expense.layer),
                ),
              ),
              items: ExpenseLayer.values
                  .map(
                    (layer) => DropdownMenuItem(
                      value: layer,
                      child: Text(
                        layer.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (layer) {
                if (layer == null) return;
                setState(() => widget.expense.layer = layer);
              },
            ),
            const SizedBox(height: 7),
            Text(
              widget.expense.layer.examples,
              style: TextStyle(
                color: _expenseLayerColor(widget.expense.layer),
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _expenseLayerIcon(ExpenseLayer layer) => switch (layer) {
      ExpenseLayer.basicNeeds => Icons.home_rounded,
      ExpenseLayer.emergencyInsurance => Icons.health_and_safety_rounded,
      ExpenseLayer.debtInvestments => Icons.account_balance_rounded,
      ExpenseLayer.nonEssentials => Icons.interests_rounded,
    };

Color _expenseLayerColor(ExpenseLayer layer) => switch (layer) {
      ExpenseLayer.basicNeeds => _brand,
      ExpenseLayer.emergencyInsurance => _amber,
      ExpenseLayer.debtInvestments => _purple,
      ExpenseLayer.nonEssentials => _sage,
    };

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
    final budget = state.cashFlowPyramidBaseline;
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
  final out = <_WealthAccount>[
    _WealthAccount(
      name: 'Cash on Hand',
      sub: 'Manual',
      balance: state.accountBalance('Cash on Hand'),
      color: _sage,
      icon: Icons.payments_rounded,
      layer: 1,
    ),
    _WealthAccount(
      name: 'Wallet',
      sub: state.isAccountSynced('Wallet') ? 'Synced' : 'Manual',
      balance: state.accountBalance('Wallet'),
      color: _brand,
      icon: Icons.account_balance_wallet_rounded,
      layer: 1,
    ),
    _WealthAccount(
      name: 'Savings',
      sub: state.isAccountSynced('Savings') ? 'Synced' : 'Manual',
      balance: state.accountBalance('Savings'),
      color: _amber,
      icon: Icons.savings_rounded,
      layer: 2,
    ),
    _WealthAccount(
      name: 'Time Deposit',
      sub: state.isAccountSynced('Time Deposit') ? 'Synced' : 'Manual',
      balance: state.accountBalance('Time Deposit'),
      color: _purple,
      icon: Icons.lock_clock_rounded,
      layer: 3,
    ),
    if (state.accountExistsInFakeMaya('Goal Savings'))
      _WealthAccount(
        name: 'Goal Savings',
        sub: state.isAccountSynced('Goal Savings') ? 'Synced' : 'Manual',
        balance: state.accountBalance('Goal Savings'),
        color: const Color(0xFF6AA8F0),
        icon: Icons.flag_rounded,
        layer: 4,
      ),
  ];
  for (final asset
      in state.assets.where((item) => !item.description.contains('FakeMaya'))) {
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

// ─── Insights / Wealth Overview page ─────────────────────────────────────────

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});
  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

// Canonical motivation → Insights tab label, in display order.
const _insightsMotivationTabs = <(String motivation, String label)>[
  ('Cash Flow & Basic Needs', 'Available cash'),
  ('Financial Safety', 'Emergency fund'),
  ('Accumulating Wealth', 'Accumulating wealth'),
  ('Financial Freedom', 'Financial freedom'),
];

bool _insightsGoalAdopted(AppState state, String goalId) {
  final actionIds = _goalActionIds[goalId] ?? const <String>[];
  return actionIds.any(state.selectedActionIds.contains);
}

Set<String> _insightsAdoptedMotivations(AppState state) {
  return {
    for (final entry in _motivationGoalIds.entries)
      if (entry.value.any(
        (goalId) => _insightsGoalAdopted(state, goalId),
      ))
        entry.key,
  };
}

Set<String> _insightsVisibleMotivations(AppState state) {
  if (_insightsIsReflectionDemoAccount(state)) {
    return _insightsMotivationTabs.map((entry) => entry.$1).toSet();
  }
  final motivations = <String>{};
  for (final goalId in _visibleGoalIds(state)) {
    final layer = _layerForGoalId(goalId);
    if (layer != null) motivations.add(layer);
  }
  final onboardingLayer =
      _layerForGoalId(state.selectedGoalId) ?? state.primaryConcern;
  if (_layerCanonicalGoalId.containsKey(onboardingLayer)) {
    motivations.add(onboardingLayer);
  }
  return motivations;
}

bool _insightsIsReflectionDemoAccount(AppState state) =>
    state.email == 'reflection@test.com';

bool _hasAnyInsightTransactionData(AppState state) {
  return state.allTransactions.any(
    (transaction) =>
        !transaction.excludedFromInsights && transaction.createdAt != null,
  );
}

bool _hasUsableInsightTransactionData(AppState state) {
  return state.allTransactions.any(
    (transaction) =>
        transaction.isLabeled &&
        !transaction.excludedFromInsights &&
        transaction.createdAt != null,
  );
}

class _InsightsPageState extends State<InsightsPage> {
  int _goal = 0;
  DateTime? _selectedWeek;
  DateTime? _selectedMonth;
  final _actionStageKey = GlobalKey();
  final _emergencyActionStageKey = GlobalKey();
  final _investmentActionStageKey = GlobalKey();
  final _freedomActionStageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final service = IntegrationService.fromState(state);
    // The Reflection Demo account shows every motivation tab; real accounts
    // only show the motivation layer they picked or explicitly added.
    final adopted = _insightsVisibleMotivations(state);
    final visibleMotivations = [
      for (final entry in _insightsMotivationTabs)
        if (adopted.contains(entry.$1)) entry,
    ];
    final tabs = ['Overview', for (final entry in visibleMotivations) entry.$2];
    final activeIndex = _goal < tabs.length ? _goal : 0;
    final activeMotivation =
        activeIndex == 0 ? null : visibleMotivations[activeIndex - 1].$1;
    final hasAnyTransactions = _hasAnyInsightTransactionData(state);
    final hasUsableTransactions = _insightsIsReflectionDemoAccount(state) ||
        _hasUsableInsightTransactionData(state);

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const PageHeader(eyebrow: 'REFLECTION', title: 'Goal Insights'),
        const SizedBox(height: 16),
        _InsightsTabSwitcher(
          tabs: tabs,
          selected: activeIndex,
          onChanged: (value) => setState(() {
            _goal = value;
            _selectedWeek = null;
            _selectedMonth = null;
          }),
        ),
        const SizedBox(height: 12),
        if (!hasUsableTransactions)
          _InsightsNoTransactionDataCard(hasAnyTransactions: hasAnyTransactions)
        else
          switch (activeMotivation) {
            null => _InsightsOverview(state: state, service: service),
            'Cash Flow & Basic Needs' => _CashReflectionExplorer(
                state: state,
                service: service,
                selectedMonth: _selectedMonth,
                onMonthSelected: (month) => setState(() {
                  _selectedMonth = month;
                  _selectedWeek = null;
                }),
                actionStageKey: _actionStageKey,
              ),
            'Financial Safety' => _EmergencyReflectionExplorer(
                state: state,
                service: service,
                selectedMonth: _selectedMonth,
                onMonthSelected: (month) => setState(() {
                  _selectedMonth = month;
                  _selectedWeek = null;
                }),
                selectedWeek: _selectedWeek,
                onWeekSelected: (week) => setState(() => _selectedWeek = week),
                actionStageKey: _emergencyActionStageKey,
              ),
            'Accumulating Wealth' => _AccumulatingWealthExplorer(
                state: state,
                selectedMonth: _selectedMonth,
                onMonthSelected: (month) => setState(() {
                  _selectedMonth = month;
                  _selectedWeek = null;
                }),
                actionStageKey: _investmentActionStageKey,
              ),
            'Financial Freedom' => _FinancialFreedomExplorer(
                state: state,
                actionStageKey: _freedomActionStageKey,
              ),
            _ => _MotivationGoalsSummary(
                state: state,
                motivation: activeMotivation,
              ),
          },
      ],
    );
  }
}

class _InsightsNoTransactionDataCard extends StatelessWidget {
  const _InsightsNoTransactionDataCard({required this.hasAnyTransactions});

  final bool hasAnyTransactions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconBubble(Icons.insights_rounded),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasAnyTransactions
                        ? 'Not enough transaction data yet'
                        : 'No transaction data yet',
                    style: const TextStyle(
                      color: _title,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasAnyTransactions
                        ? 'Shellby needs more labeled transaction history before it can make reliable goal insights.'
                        : 'Link a FakeMaya account or log transactions first. Once Shellby has enough activity, your goal insights will appear here.',
                    style: const TextStyle(
                      color: _body,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
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

/// A lightweight stand-in Insights tab for motivations that don't have a
/// full custom analysis page yet (Accumulating Wealth, Financial Freedom) —
/// shows the goal(s) adopted under this motivation with their action list,
/// reusing the same goal-card treatment as the Goals tab.
class _MotivationGoalsSummary extends StatelessWidget {
  const _MotivationGoalsSummary(
      {required this.state, required this.motivation});
  final AppState state;
  final String motivation;

  @override
  Widget build(BuildContext context) {
    final goalIds = _motivationGoalIds[motivation] ?? const <String>[];
    final goals = _d1GoalMetas
        .where((goal) =>
            goalIds.contains(goal.id) && _insightsGoalAdopted(state, goal.id))
        .toList();
    final isWealth = motivation == 'Accumulating Wealth';
    final change = isWealth ? investmentChangeLast14Days(state) : 0.0;
    final onTrack = !isWealth && isLifestyleGoalOnTrack(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GoalInsightHeader(
          icon: isWealth ? Icons.trending_up_rounded : Icons.flag_rounded,
          title: isWealth ? 'Accumulating Wealth' : 'Financial Freedom',
          color: isWealth ? _purple : const Color(0xFF6AA8F0),
          subtitle: isWealth
              ? 'Investment Portfolio'
              : 'Steadily build wealth over time',
          statText: isWealth
              ? '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% · 14 days'
              : (onTrack ? 'On track' : null),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Full insights for this goal are on the way. Here's what you've set up so far.",
                style: TextStyle(
                    color: _body,
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              for (final goal in goals) ...[
                _D1GoalCard(
                  goal: goal,
                  onTap: () {
                    final shell =
                        context.findAncestorStateOfType<_MainShellState>();
                    if (shell != null) {
                      shell.openGoal(goal.id);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GoalsPage(initialGoalId: goal.id),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightsTabSwitcher extends StatelessWidget {
  const _InsightsTabSwitcher({
    required this.tabs,
    required this.selected,
    required this.onChanged,
  });
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _bellySoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected == i ? _surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: selected == i
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        tabs[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected == i ? _purple : _body,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A "reflection question" prompt card. When [child] is supplied, it's
/// nested directly inside the same card (behind a divider) so it reads as
/// the answer to the question above it, rather than a separate, seemingly
/// unrelated card floating right below.
class _ReflectionQuestion extends StatelessWidget {
  const _ReflectionQuestion({
    required this.question,
    required this.detail,
    this.child,
  });
  final String question;
  final String detail;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: _bellySoft,
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                  alignment: Alignment.center,
                  child:
                      const Icon(Icons.help_rounded, size: 13, color: _purple),
                ),
                const SizedBox(width: 8),
                const Text(
                  'REFLECTION QUESTION',
                  style: TextStyle(
                    color: _purple,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question,
              style: const TextStyle(
                color: _title,
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              detail,
              style: const TextStyle(
                color: _body,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (child != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                child: child!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightsAiSummaryCard extends StatelessWidget {
  const _InsightsAiSummaryCard({
    required this.suggestionCount,
    required this.summaryExcerpt,
    required this.onTap,
  });
  final int suggestionCount;
  final String summaryExcerpt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5DC295), _brand, Color(0xFF2D7A58)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _brand.withOpacity(0.30),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: Image.asset(
                        'assets/images/shellby_wave.webp',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Shellby analyzed your',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '14-Day Financial Pattern',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (suggestionCount > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$suggestionCount new suggestion${suggestionCount == 1 ? '' : 's'}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          summaryExcerpt,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Tap to ask Shellby about this',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white.withOpacity(0.9), size: 14),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

DateTime _insightsCutoff() => DateTime.now().subtract(const Duration(days: 14));

List<FakeMayaTransaction> _last14DaysTransactions(AppState state) {
  final cutoff = _insightsCutoff();
  return state.allTransactions
      .where((transaction) =>
          transaction.isLabeled &&
          !transaction.excludedFromInsights &&
          transaction.createdAt != null &&
          !transaction.createdAt!.isBefore(cutoff))
      .toList()
    ..sort((a, b) => (b.createdAt ?? DateTime(1970))
        .compareTo(a.createdAt ?? DateTime(1970)));
}

const _overviewPalette = [
  _brand,
  _purple,
  _amber,
  _red,
  Color(0xFF6AA8F0),
  _sage,
];

class _InsightsOverview extends StatelessWidget {
  const _InsightsOverview({required this.state, required this.service});
  final AppState state;
  final IntegrationService service;

  @override
  Widget build(BuildContext context) {
    final transactions = _last14DaysTransactions(state);
    final inflow = transactions
        .where((transaction) =>
            transaction.amount > 0 && !transaction.isInternalFakeMayaTransfer)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    final outflow = transactions
        .where((transaction) => transaction.amount < 0)
        .fold(0.0, (sum, transaction) => sum + transaction.amount.abs());
    final netFlow = inflow - outflow;
    final categories = _transactionTotals(
      transactions.where((transaction) => transaction.amount < 0),
      (transaction) => transaction.category ?? 'Unclassified',
    );
    final sources = _transactionTotals(
      transactions,
      (transaction) => transaction.source ?? 'Unclassified',
    );

    final suggestionCount = (isCashFlowGoalOnTrack(state) ? 0 : 1) +
        (isEmergencyFundGoalOnTrack(state) ? 0 : 1);

    return Column(
      children: [
        _InsightsAiSummaryCard(
          suggestionCount: suggestionCount,
          summaryExcerpt: _moneyFlowInsight(inflow, outflow),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ShellbyChatPage(
                  analysisTitle: 'Insights overview',
                  analysisContext: _overviewAnalysisContext(state, service),
                ),
              ),
            );
          },
        ),
        _OverviewCard(
          title: 'Money Summary',
          child: Row(
            children: [
              Expanded(
                child: _OverviewMetric(
                  label: 'Money in',
                  value: money(inflow),
                  color: _sage,
                  icon: Icons.south_west_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OverviewMetric(
                  label: 'Money out',
                  value: money(outflow),
                  color: _red,
                  icon: Icons.north_east_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OverviewMetric(
                  label: 'Net flow',
                  value: money(netFlow),
                  color: netFlow >= 0 ? _brand : _amber,
                  icon: Icons.swap_vert_rounded,
                ),
              ),
            ],
          ),
          insight: _AiInsightNote(
            trend: inflow == 0 && outflow == 0
                ? _InsightTrend.neutral
                : (netFlow >= 0 ? _InsightTrend.up : _InsightTrend.down),
            text: _moneyFlowInsight(inflow, outflow),
          ),
        ),
        _OverviewCard(
          title: 'Where Your Money Went',
          child: categories.isEmpty
              ? const _ReflectionEmpty(
                  message: 'No spending in the last 14 days yet.')
              : _ColoredBreakdownList(totals: categories),
          insight: _AiInsightNote(
            trend: _InsightTrend.neutral,
            text: _categoryInsight(categories, outflow),
          ),
        ),
        _OverviewCard(
          title: 'Which Funds You Used',
          child: sources.isEmpty
              ? const _ReflectionEmpty(
                  message: 'No fund activity in the last 14 days yet.')
              : _ColoredBreakdownList(totals: sources),
          insight: _AiInsightNote(
            trend: _InsightTrend.neutral,
            text: _fundInsight(sources),
          ),
        ),
      ],
    );
  }
}

String _moneyFlowInsight(double inflow, double outflow) {
  if (inflow == 0 && outflow == 0) {
    return 'No money movement in the last 14 days yet — log a transaction to start seeing insights here.';
  }
  final net = inflow - outflow;
  if (net > 0) {
    return 'You brought in ${money(net)} more than you spent over the last 14 days — a healthy positive net flow.';
  }
  if (net < 0) {
    return 'You spent ${money(net.abs())} more than you brought in over the last 14 days — worth keeping an eye on.';
  }
  return 'Money in and money out balanced out exactly over the last 14 days.';
}

String _categoryInsight(Map<String, double> categories, double outflow) {
  if (categories.isEmpty) {
    return 'Nothing has been categorized as spending in the last 14 days yet.';
  }
  final top = categories.entries.first;
  final pct = outflow > 0 ? (top.value / outflow * 100).round() : 0;
  return '${top.key} was your biggest category over the last 14 days — $pct% of your spending (${money(top.value)}).';
}

String _fundInsight(Map<String, double> sources) {
  if (sources.isEmpty) {
    return 'No fund has handled any transactions in the last 14 days yet.';
  }
  final top = sources.entries.first;
  return '${top.key} saw the most activity over the last 14 days, handling ${money(top.value)} in total.';
}

enum _InsightTrend { up, down, neutral }

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.child,
    required this.insight,
  });
  final String title;
  final Widget child;
  final Widget insight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _title,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            child,
            const SizedBox(height: 12),
            insight,
          ],
        ),
      ),
    );
  }
}

class _ColoredBreakdownList extends StatelessWidget {
  const _ColoredBreakdownList({required this.totals});
  final Map<String, double> totals;

  @override
  Widget build(BuildContext context) {
    final maxValue = totals.values.reduce(math.max);
    final total = totals.values.fold(0.0, (sum, value) => sum + value);
    final entries = totals.entries.take(6).toList();
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == entries.length - 1 ? 0 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entries[i].key,
                        style: const TextStyle(
                          color: _title,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${money(entries[i].value)} · ${(entries[i].value / total * 100).round()}%',
                      style: const TextStyle(
                        color: _body,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: entries[i].value / maxValue,
                    minHeight: 8,
                    color: _overviewPalette[i % _overviewPalette.length],
                    backgroundColor: _border.withValues(alpha: .45),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AiInsightNote extends StatelessWidget {
  const _AiInsightNote({required this.text, required this.trend});
  final String text;
  final _InsightTrend trend;

  @override
  Widget build(BuildContext context) {
    final trendColor = switch (trend) {
      _InsightTrend.up => _sage,
      _InsightTrend.down => _red,
      _InsightTrend.neutral => _purple,
    };
    final trendIcon = switch (trend) {
      _InsightTrend.up => Icons.trending_up_rounded,
      _InsightTrend.down => Icons.trending_down_rounded,
      _InsightTrend.neutral => Icons.insights_rounded,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: _purple, size: 12),
              const SizedBox(width: 5),
              const Text(
                'AI INSIGHT',
                style: TextStyle(
                  color: _purple,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(trendIcon, color: trendColor, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Map<String, double> _transactionTotals(
  Iterable<FakeMayaTransaction> transactions,
  String Function(FakeMayaTransaction transaction) labelFor,
) {
  final totals = <String, double>{};
  for (final transaction in transactions) {
    totals.update(
      labelFor(transaction),
      (value) => value + transaction.amount.abs(),
      ifAbsent: () => transaction.amount.abs(),
    );
  }
  return Map.fromEntries(
    totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
  );
}

String _overviewAnalysisContext(
  AppState state,
  IntegrationService service,
) {
  final labeled = _last14DaysTransactions(state);
  final inflow = labeled
      .where((transaction) =>
          transaction.amount > 0 && !transaction.isInternalFakeMayaTransfer)
      .fold(0.0, (sum, transaction) => sum + transaction.amount);
  final outflow = labeled
      .where((transaction) => transaction.amount < 0)
      .fold(0.0, (sum, transaction) => sum + transaction.amount.abs());
  final categories = _transactionTotals(
    labeled.where((transaction) => transaction.amount < 0),
    (transaction) => transaction.category ?? 'Unclassified',
  );
  final sources = _transactionTotals(
    labeled,
    (transaction) => transaction.source ?? 'Unclassified',
  );
  return '''
Screen: Insights Overview
Question: Where is my money moving, and what stands out?
Classified transactions in the last 14 days: ${labeled.length}
Money in: ${money(inflow)}
Money out: ${money(outflow)}
Net flow: ${money(inflow - outflow)}
Expense categories:
${categories.entries.map((entry) => '- ${entry.key}: ${money(entry.value)}').join('\n')}
Fund transaction volume:
${sources.entries.map((entry) => '- ${entry.key}: ${money(entry.value)}').join('\n')}
Weekly records available: ${service.weekRecords.length}
''';
}

String _availableCashAnalysisContext(
  AppState state,
  IntegrationService service,
) {
  final months = _cashMonthsFor(state, service);
  final currentMonth = months.isEmpty ? null : months.last;
  final essentialDeposits = currentMonth == null
      ? 0.0
      : _monthLedgerAmount(state, currentMonth.start, 'essential_deposit');
  final selectedBudgets = state.categorySpendingBudgets;
  final selectedCategories = selectedBudgets.keys.toSet();
  final selectedCategorySpend = currentMonth == null
      ? <String, double>{}
      : Map.fromEntries(currentMonth.spendingCategories.entries.where(
          (entry) =>
              selectedCategories.isEmpty ||
              selectedCategories.contains(entry.key),
        ));
  final actionScores = currentMonth?.actionScores ?? const <_CashActionScore>[];
  final walletAvailable = math.max(
    state.accountBalance('Wallet'),
    state.cashOnHandBalance,
  );
  return '''
Screen: Available Cash goal
Question: Are the selected cash-in, cash-floor, allocation, and spending-limit actions protecting available cash?
Current wallet available: ${money(walletAvailable)}
Cash on hand: ${money(state.cashOnHandBalance)}
Essential Expenses Fund balance: ${money(state.essentialExpensesBalance)}
Unallocated FakeMaya wallet: ${money(state.unallocatedFakeMayaWallet)}
Monthly essential expense baseline: ${money(state.monthlyEssentialExpenseTotal)}
Configured Maintain Available Cash actions:
- A1: Set aside a configured percent of each income into the Essential Expenses Fund.
- A3: Limit spending in selected categories to configured monthly caps.
- A20: Bring in at least the configured monthly cash-in target.
- A19: Keep the Essential Expenses Fund at or above the configured peso minimum.
Selected category budgets:
${selectedBudgets.isEmpty ? 'No selected category budgets configured yet.' : selectedBudgets.entries.map((entry) => '- ${entry.key}: ${money(entry.value)} monthly cap').join('\n')}
Monthly cash indexes:
${months.map((month) => '- ${_monthLabel(month.start)}: canPayBills=${month.canPayBills}, bills needed ${money(month.billNeed)}, wallet available ${money(month.walletAvailable)}, income ${money(month.income)}, spending ${money(month.spending)}, goal resiliency ${_scorePercent(month.goalResiliencyScore)}%').join('\n')}
Open basic-needs bill obligations:
${state.openBasicNeedsBillObligations.isEmpty ? 'No unpaid basic-needs bill obligations.' : state.openBasicNeedsBillObligations.map((bill) => '- ${bill['name']}: remaining ${money(_billRemaining(bill))}').join('\n')}
Current month action evidence:
- Essential deposits recorded: ${money(essentialDeposits)}
${actionScores.map((score) => '- ${score.id}: ${_scorePercent(score.score)}%, ${score.detail}; formula=${score.formula}').join('\n')}
Selected category spending this month:
${selectedCategorySpend.isEmpty ? 'No selected category spending recorded this month.' : selectedCategorySpend.entries.map((entry) => '- ${entry.key}: ${money(entry.value)} spent').join('\n')}
Weekly cash-flow data:
${service.weekRecords.map((week) => '- ${_shortDate(week.start)}: income ${money(week.weekIncome)}, spending ${money(week.weekExpense)}, essential allocation ${money(week.weekRefill)}, coverage ${(week.propDaysClassified * 100).round()}%, incomeWeek=${week.isSalaryWeek}, billWeek=${week.isBillWeek}, noticeableEvent=${week.hadEmergency}').join('\n')}
''';
}

String _emergencyAnalysisContext(
  AppState state,
  IntegrationService service,
) {
  final activity = _emergencyReflectionActivity(state);
  final monthlyEssentials = state.monthlyEssentialExpenseTotal;
  final target = _financialSafetyGoalTarget(state);
  return '''
Screen: Emergency Fund goal
Question: When did my emergency fund change, and which events explain the change?
Current fund balance: ${money(state.displayedEmergencyFundBalance)}
Six-month Financial Safety goal: ${money(target)}
Monthly essential expenses: ${money(monthlyEssentials)}
Pending replenishment: ${money(state.pendingEmergencyReplenishment)}
Tracked weekly periods: ${service.weekRecords.length}
Emergency activity:
${activity.isEmpty ? 'No emergency activity recorded.' : activity.map((item) => '- ${_shortDate(item.date)}: ${item.title}, ${item.add ? 'added' : 'used'} ${money(item.amount)}, ${item.detail}').join('\n')}
''';
}

class _BreakdownSection extends StatelessWidget {
  const _BreakdownSection({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.totals,
    required this.emptyMessage,
    required this.color,
  });
  final String eyebrow;
  final String title;
  final String subtitle;
  final Map<String, double> totals;
  final String emptyMessage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxValue = totals.isEmpty ? 1.0 : totals.values.reduce(math.max);
    final total = totals.values.fold(0.0, (sum, value) => sum + value);
    return _ExplorerSection(
      eyebrow: eyebrow,
      title: title,
      subtitle: subtitle,
      child: totals.isEmpty
          ? _ReflectionEmpty(message: emptyMessage)
          : Column(
              children: [
                for (final entry in totals.entries.take(8))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  color: _title,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Text(
                              '${money(entry.value)} · ${(entry.value / total * 100).round()}%',
                              style: const TextStyle(
                                color: _body,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: entry.value / maxValue,
                            minHeight: 9,
                            color: color,
                            backgroundColor: _border.withValues(alpha: .45),
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

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(height: 7),
          Text(label,
              style: const TextStyle(
                  color: _body, fontSize: 9, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _CashMonthInsight {
  const _CashMonthInsight({
    required this.start,
    required this.weeks,
    required this.transactions,
    required this.income,
    required this.spending,
    required this.billNeed,
    required this.walletAvailable,
    required this.openObligations,
    required this.incomeSources,
    required this.spendingCategories,
    required this.actionScores,
  });

  final DateTime start;
  final List<WeekRecord> weeks;
  final List<FakeMayaTransaction> transactions;
  final double income;
  final double spending;
  final double billNeed;
  final double walletAvailable;
  final List<Map<String, dynamic>> openObligations;
  final Map<String, double> incomeSources;
  final Map<String, double> spendingCategories;
  final List<_CashActionScore> actionScores;

  bool get canPayBills => walletAvailable >= billNeed;
  double get billScore =>
      billNeed <= 0 ? 1 : (walletAvailable / billNeed).clamp(0.0, 1.0);
  double get goalResiliencyScore => actionScores.isEmpty
      ? 0
      : actionScores.fold<double>(0, (sum, item) => sum + item.score) /
          actionScores.length;
}

class _CashActionScore {
  const _CashActionScore({
    required this.id,
    required this.title,
    required this.score,
    required this.detail,
    required this.pattern,
    required this.weekLabels,
    required this.actualLabel,
    required this.targetLabel,
    required this.formula,
    required this.evidence,
    this.applicableMeasures = const ['Consistency', 'Resiliency', 'Adherence'],
    this.emptyReason = 'Not enough data to make a calculation',
  });

  final String id;
  final String title;
  final double score;
  final String detail;
  final List<double> pattern;
  final List<String> weekLabels;
  final String actualLabel;
  final String targetLabel;
  final String formula;
  final List<String> evidence;

  /// Which of Consistency/Resiliency/Adherence make sense for this
  /// particular action. Most actions are recurring weekly behaviors where
  /// all three apply; event-triggered actions (e.g. "replenish within X
  /// days of a withdrawal") don't have a meaningful weekly-activity
  /// Consistency measure, so they can opt out of it here.
  final List<String> applicableMeasures;

  /// Shown instead of the measure gauges when there isn't enough data
  /// (empty pattern) — lets an action explain *why* in its own terms
  /// (e.g. "no withdrawals to replenish this month" vs. the generic
  /// "not enough data").
  final String emptyReason;
}

/// Average of whichever measures actually have a score for this action.
/// Returns null only when every applicable measure is missing data.
int? _overallActionScore(List<_ActionMeasure> measures) {
  final scored = measures.where((measure) => measure.hasScore).toList();
  if (scored.isEmpty) return null;
  final total = scored.fold<int>(0, (sum, measure) => sum + measure.percent!);
  return (total / scored.length).round();
}

int _scorePercent(double value) => (value * 100).round().clamp(0, 100);

Color _resiliencyScoreColor(num percent) {
  final score = percent.clamp(0, 100);
  if (score >= 80) return _sage;
  if (score >= 60) return _amber;
  return _red;
}

Color _resiliencyValueColor(double value) =>
    _resiliencyScoreColor(_scorePercent(value));

double _averageWeeklyResiliency(List<double> pattern) {
  if (pattern.isEmpty) return 0;
  return pattern.fold<double>(0, (total, value) => total + value) /
      pattern.length;
}

List<String> _weekLabels(List<WeekRecord> weeks) {
  return [
    for (final week in weeks)
      '${_shortDate(week.start)}-${_shortDate(week.end)}',
  ];
}

bool _isScheduledBasicNeedsBill(Map<String, dynamic> expense) {
  return expenseLayerForLedger(expense) == ExpenseLayer.basicNeeds &&
      expense['scheduled'] == true &&
      DateTime.tryParse(expense['scheduleAnchorDate']?.toString() ?? '') !=
          null;
}

List<Map<String, dynamic>> _scheduledBasicNeedsBills(AppState state) {
  return state.onboardingExpenseLedger
      .where(_isScheduledBasicNeedsBill)
      .map((expense) => Map<String, dynamic>.from(expense))
      .toList();
}

DateTime? _scheduledBillDueDateForMonth(
  Map<String, dynamic> expense,
  DateTime month,
) {
  final anchor =
      DateTime.tryParse(expense['scheduleAnchorDate']?.toString() ?? '');
  if (anchor == null) return null;
  final lastDay = DateTime(month.year, month.month + 1, 0).day;
  return DateTime(
      month.year, month.month, math.min(anchor.day, lastDay).toInt());
}

double _scheduledBasicNeedsBillNeedForMonth(
  AppState state,
  DateTime month,
) {
  return _scheduledBasicNeedsBills(state).fold<double>(0, (total, expense) {
    final due = _scheduledBillDueDateForMonth(expense, month);
    if (due == null || !_sameMonth(due, month)) return total;
    return total + _doubleValue(expense['amount'], 0);
  });
}

List<_CashMonthInsight> _cashMonthsFor(
  AppState state,
  IntegrationService service,
) {
  final transactions = state.allTransactions
      .where((transaction) =>
          transaction.isLabeled &&
          !transaction.excludedFromInsights &&
          transaction.createdAt != null)
      .toList();
  final starts = <DateTime>{
    ...service.weekRecords.map((week) => _monthStart(week.start)),
    ...transactions.map((transaction) => _monthStart(transaction.createdAt!)),
    ...state.openBasicNeedsBillObligations
        .map((bill) => DateTime.tryParse(bill['dueDate']?.toString() ?? ''))
        .whereType<DateTime>()
        .map(_monthStart),
    ..._scheduledBasicNeedsBills(state)
        .map((bill) =>
            DateTime.tryParse(bill['scheduleAnchorDate']?.toString() ?? ''))
        .whereType<DateTime>()
        .map(_monthStart),
  }.toList()
    ..sort();
  return starts.map((month) {
    final monthWeeks = service.weekRecords
        .where((week) => _sameMonth(week.start, month))
        .toList();
    final monthTransactions = transactions
        .where((transaction) => _sameMonth(transaction.createdAt!, month))
        .toList()
      ..sort((a, b) => (b.createdAt ?? DateTime(1970))
          .compareTo(a.createdAt ?? DateTime(1970)));
    final income = monthTransactions
        .where((transaction) =>
            transaction.amount > 0 && !transaction.isInternalFakeMayaTransfer)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    final spending = monthTransactions
        .where((transaction) => transaction.amount < 0)
        .fold(0.0, (sum, transaction) => sum + transaction.amount.abs());
    final monthObligations = state.openBasicNeedsBillObligations.where((bill) {
      final due = DateTime.tryParse(bill['dueDate']?.toString() ?? '');
      return due == null || _sameMonth(due, month);
    }).toList();
    final obligationNeed = monthObligations.fold<double>(
      0,
      (total, bill) => total + _billRemaining(bill),
    );
    final billNeed =
        _scheduledBasicNeedsBillNeedForMonth(state, month) + obligationNeed;
    final wallet = math.max(
      state.accountBalance('Wallet'),
      state.cashOnHandBalance,
    );
    final incomeSources = _transactionTotals(
      monthTransactions.where((transaction) =>
          transaction.amount > 0 && !transaction.isInternalFakeMayaTransfer),
      (transaction) => transaction.category ?? 'Income',
    );
    final spendingCategories = _transactionTotals(
      monthTransactions.where((transaction) => transaction.amount < 0),
      (transaction) => transaction.category ?? 'Unclassified',
    );
    return _CashMonthInsight(
      start: month,
      weeks: monthWeeks,
      transactions: monthTransactions,
      income: income,
      spending: spending,
      billNeed: billNeed,
      walletAvailable: wallet,
      openObligations: monthObligations,
      incomeSources: incomeSources,
      spendingCategories: spendingCategories,
      actionScores: _availableCashActionScores(
        state: state,
        monthStart: month,
        weeks: monthWeeks,
        transactions: monthTransactions,
        income: income,
      ),
    );
  }).toList();
}

List<_CashActionScore> _availableCashActionScores({
  required AppState state,
  required DateTime monthStart,
  required List<WeekRecord> weeks,
  required List<FakeMayaTransaction> transactions,
  required double income,
}) {
  final configured = state.selectedActionIds
      .where(_availableCashGoalActionIds.contains)
      .toList();
  final actionIds =
      configured.isEmpty ? _availableCashGoalActionIds : configured;
  return [
    for (final id in actionIds)
      _cashActionScoreFor(
        id: id,
        state: state,
        monthStart: monthStart,
        weeks: weeks,
        transactions: transactions,
        income: income,
      ),
  ].whereType<_CashActionScore>().toList();
}

List<_CashActionScore> _emergencyFundActionScores({
  required AppState state,
  required DateTime monthStart,
  required List<WeekRecord> weeks,
  required List<FakeMayaTransaction> transactions,
  required double income,
}) {
  final configured = state.selectedActionIds
      .where(_emergencyFundGoalActionIds.contains)
      .toList();
  final actionIds =
      configured.isEmpty ? _emergencyFundGoalActionIds : configured;
  return [
    for (final id in actionIds)
      _cashActionScoreFor(
        id: id,
        state: state,
        monthStart: monthStart,
        weeks: weeks,
        transactions: transactions,
        income: income,
      ),
  ].whereType<_CashActionScore>().toList();
}

_CashActionScore? _cashActionScoreFor({
  required String id,
  required AppState state,
  required DateTime monthStart,
  required List<WeekRecord> weeks,
  required List<FakeMayaTransaction> transactions,
  required double income,
}) {
  final values = state.actionFieldValues[id] ?? const <String, String>{};
  double configuredNumber(String key, double fallback) {
    return double.tryParse((values[key] ?? '').replaceAll(',', '').trim()) ??
        fallback;
  }

  final weekCount = math.max(1, weeks.length);
  final action = _d2Actions[id];
  if (id == 'A1') {
    final recommended = action == null
        ? 50.0
        : double.parse(
            _recommendationsForActionField(state, action, action.fields.first)
                .first);
    final targetPct = configuredNumber('pct', recommended) / 100;
    final allocated =
        _monthLedgerAmount(state, monthStart, 'essential_deposit');
    final fallbackAllocated = transactions
        .where((transaction) =>
            transaction.amount > 0 &&
            transaction.source?.toLowerCase() == 'basic needs fund')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    final actual = allocated > 0 ? allocated : fallbackAllocated;
    final targetAmount = income * targetPct;
    final pattern = weeks
        .map((week) => week.weekIncome <= 0
            ? 0.0
            : (_ledgerAmountInRange(state, week.start, week.end,
                        const {'essential_deposit'}) /
                    (week.weekIncome * targetPct))
                .clamp(0.0, 1.5))
        .toList();
    return _CashActionScore(
      id: id,
      title: 'Set aside income for essentials',
      score: _averageWeeklyResiliency(pattern),
      detail:
          '${money(actual)} allocated toward a ${money(targetAmount)} monthly target.',
      pattern: pattern,
      weekLabels: _weekLabels(weeks),
      actualLabel: money(actual),
      targetLabel: money(targetAmount),
      formula:
          'Resiliency = average of each available week: weekly essential allocation ÷ configured ${targetPct * 100}% of weekly income.',
      evidence: [
        'Monthly income counted: ${money(income)}',
        'Configured allocation: ${(targetPct * 100).round()}%',
        'Essential allocation found: ${money(actual)}',
      ],
    );
  }
  if (id == 'A3') {
    final recommended = action == null
        ? 3000.0
        : double.parse(
            _recommendationsForActionField(state, action, action.fields.first)
                .first);
    final cap = configuredNumber('amt', recommended);
    final configuredCategories = (values['categories'] ?? '')
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
    final selectedCategories = <String>{
      ...state.categorySpendingBudgets.keys,
      ...configuredCategories,
    };
    final categoryTotals = _transactionTotals(
      transactions.where((transaction) {
        if (transaction.amount >= 0) return false;
        final category = transaction.category ?? 'Unclassified';
        return selectedCategories.isEmpty ||
            selectedCategories.contains(category);
      }),
      (transaction) => transaction.category ?? 'Unclassified',
    );
    final totalCap = state.categorySpendingBudgets.isNotEmpty
        ? state.categorySpendingBudgets.entries
            .where((entry) =>
                selectedCategories.isEmpty ||
                selectedCategories.contains(entry.key))
            .fold(0.0, (sum, entry) => sum + entry.value)
        : cap * math.max(1, selectedCategories.length);
    final pattern = weeks.map((week) {
      final spent = week.days.expand((day) => day.transactions).where(
        (transaction) {
          if (transaction.amount >= 0 || transaction.excludedFromInsights) {
            return false;
          }
          final category = transaction.category ?? 'Unclassified';
          return selectedCategories.isEmpty ||
              selectedCategories.contains(category);
        },
      ).fold(0.0, (sum, transaction) => sum + transaction.amount.abs());
      final weeklyCap = totalCap / weekCount;
      return spent <= 0 ? 1.0 : (weeklyCap / spent).clamp(0.0, 1.0);
    }).toList();
    final selectedSpend =
        categoryTotals.values.fold(0.0, (sum, value) => sum + value);
    return _CashActionScore(
      id: id,
      title: 'Keep categories under cap',
      score: _averageWeeklyResiliency(pattern),
      detail:
          '${categoryTotals.length} selected category/categories checked against ${money(totalCap)}.',
      pattern: pattern,
      weekLabels: _weekLabels(weeks),
      actualLabel: money(selectedSpend),
      targetLabel: money(totalCap),
      formula:
          'Resiliency = average of each available week: weekly selected-category cap ÷ selected-category spending, capped at 100%.',
      evidence: [
        'Configured category cap total: ${money(totalCap)}',
        if (selectedCategories.isNotEmpty)
          'Selected categories: ${selectedCategories.join(', ')}',
        if (categoryTotals.isEmpty)
          'No selected category spending was recorded this month.'
        else
          ...categoryTotals.entries.map(
            (entry) => '${entry.key}: ${money(entry.value)} spent',
          ),
      ],
    );
  }
  if (id == 'A2') {
    final recommended = action == null
        ? math.max(1000.0, state.monthlyNonEssentialExpenseTotal)
        : double.parse(
            _recommendationsForActionField(state, action, action.fields.first)
                .first);
    final cap = configuredNumber('amt', recommended);
    final discretionary = transactions
        .where((transaction) =>
            transaction.amount < 0 &&
            !_isEssentialCashCategory(transaction.category))
        .fold(0.0, (sum, transaction) => sum + transaction.amount.abs());
    final pattern = weeks.map((week) {
      final weekSpend = week.days.expand((day) => day.transactions).where(
        (transaction) {
          return transaction.amount < 0 &&
              !transaction.excludedFromInsights &&
              !_isEssentialCashCategory(transaction.category);
        },
      ).fold(0.0, (sum, transaction) => sum + transaction.amount.abs());
      final weeklyCap = cap / weekCount;
      return weekSpend <= 0 ? 1.0 : (weeklyCap / weekSpend).clamp(0.0, 1.0);
    }).toList();
    return _CashActionScore(
      id: id,
      title: 'Cap discretionary spending',
      score: _averageWeeklyResiliency(pattern),
      detail:
          '${money(discretionary)} discretionary spending checked against ${money(cap)}.',
      pattern: pattern,
      weekLabels: _weekLabels(weeks),
      actualLabel: money(discretionary),
      targetLabel: money(cap),
      formula:
          'Resiliency = average of each available week: weekly discretionary cap ÷ weekly discretionary spending, capped at 100%.',
      evidence: [
        'Configured discretionary cap: ${money(cap)}',
        'Discretionary spending found: ${money(discretionary)}',
      ],
    );
  }
  if (id == 'A20') {
    final recommended = action == null
        ? _recommendedMonthlyEarnings(state)
        : double.parse(
            _recommendationsForActionField(state, action, action.fields.first)
                .first);
    final target = configuredNumber('amt', recommended);
    final monthIncome = income > 0
        ? income
        : transactions
            .where((transaction) => transaction.amount > 0)
            .where((transaction) => !transaction.isInternalFakeMayaTransfer)
            .fold(0.0, (sum, transaction) => sum + transaction.amount);
    final ratio = target <= 0 ? 0.0 : (monthIncome / target).clamp(0.0, 1.0);
    return _CashActionScore(
      id: id,
      title: 'Reach monthly cash-in target',
      score: ratio,
      detail:
          '${money(monthIncome)} brought in toward a ${money(target)} monthly cash-in target.',
      pattern: [ratio],
      weekLabels: const ['Current'],
      actualLabel: money(monthIncome),
      targetLabel: money(target),
      formula:
          'Progress = monthly income and other cash-in ÷ configured monthly cash-in target, capped at 100%.',
      evidence: [
        'Configured monthly cash-in target: ${money(target)}',
        'Monthly cash-in counted: ${money(monthIncome)}',
      ],
      applicableMeasures: const ['Resiliency'],
    );
  }
  if (id == 'A19') {
    final recommended = action == null
        ? _recommendedEssentialFundFloor(state)
        : double.parse(
            _recommendationsForActionField(state, action, action.fields.first)
                .first);
    final floor = configuredNumber('amt', recommended);
    final currentFund = state.essentialExpensesBalance;
    final pattern = weeks.isEmpty
        ? <double>[floor <= 0 ? 0 : (currentFund / floor).clamp(0.0, 1.0)]
        : weeks
            .map((week) => floor <= 0
                ? 0.0
                : (week.needsBalanceEnd / floor).clamp(0.0, 1.0))
            .toList();
    return _CashActionScore(
      id: id,
      title: 'Keep Essential Expenses Fund above floor',
      score: _averageWeeklyResiliency(pattern),
      detail:
          '${money(currentFund)} saved against a ${money(floor)} Essential Expenses Fund minimum.',
      pattern: pattern,
      weekLabels: weeks.isEmpty ? const ['Current'] : _weekLabels(weeks),
      actualLabel: money(currentFund),
      targetLabel: money(floor),
      formula:
          'Progress = Essential Expenses Fund balance ÷ configured peso floor. The recommended floor is based on essential expenses, monthly income, and surplus.',
      evidence: [
        'Configured Essential Expenses Fund floor: ${money(floor)}',
        'Essential Expenses Fund amount counted: ${money(currentFund)}',
        'Monthly essential expense baseline: ${money(_monthlyEssentialBase(state))}',
        'Monthly income baseline: ${money(_monthlyIncomeBase(state))}',
      ],
    );
  }
  if (id == 'A21') {
    final recommended = action == null
        ? 14.0
        : double.parse(
            _recommendationsForActionField(state, action, action.fields.first)
                .first);
    final days = configuredNumber('days', recommended);
    final dailyExpense = math.max(1.0, state.monthlyEssentialExpenseTotal / 30);
    final targetAmount = dailyExpense * days;
    final currentFund = math.max(
      state.essentialExpensesBalance,
      math.max(state.needsBalance, state.accountBalance('Wallet')),
    );
    final currentDays = currentFund / dailyExpense;
    final pattern = weeks.isEmpty
        ? <double>[targetAmount <= 0 ? 0 : (currentFund / targetAmount)]
        : weeks
            .map((week) => targetAmount <= 0
                ? 0.0
                : (week.needsBalanceEnd / targetAmount).clamp(0.0, 1.0))
            .toList();
    return _CashActionScore(
      id: id,
      title: 'Keep Everyday Fund days covered',
      score: _averageWeeklyResiliency(pattern),
      detail:
          '${currentDays.toStringAsFixed(1)} days available toward a ${days.toStringAsFixed(0)} day target.',
      pattern: pattern,
      weekLabels: weeks.isEmpty ? const ['Current'] : _weekLabels(weeks),
      actualLabel: '${currentDays.toStringAsFixed(1)} days',
      targetLabel: '${days.toStringAsFixed(0)} days',
      formula:
          'Resiliency = average of each available week: Everyday Fund balance ÷ (${days.toStringAsFixed(0)} days × estimated daily essential expenses).',
      evidence: [
        'Daily essential expense estimate: ${money(dailyExpense)}',
        'Everyday Fund amount counted: ${money(currentFund)}',
        'Target amount: ${money(targetAmount)}',
      ],
    );
  }
  if (id == 'A8') {
    final recommended = action == null
        ? 10.0
        : double.parse(
            _recommendationsForActionField(state, action, action.fields.first)
                .first);
    final targetPct = configuredNumber('pct', recommended) / 100;
    final allocated =
        _monthLedgerAmount(state, monthStart, 'emergency_deposit');
    final targetAmount = income * targetPct;
    final pattern = weeks
        .map((week) => week.weekIncome <= 0
            ? 0.0
            : (_ledgerAmountInRange(state, week.start, week.end,
                        const {'emergency_deposit'}) /
                    (week.weekIncome * targetPct))
                .clamp(0.0, 1.5))
        .toList();
    return _CashActionScore(
      id: id,
      title: 'Set aside income for Emergency Fund',
      score: _averageWeeklyResiliency(pattern),
      detail:
          '${money(allocated)} allocated toward a ${money(targetAmount)} monthly target.',
      pattern: pattern,
      weekLabels: _weekLabels(weeks),
      actualLabel: money(allocated),
      targetLabel: money(targetAmount),
      formula:
          'Resiliency = average of each available week: weekly Emergency Fund allocation ÷ configured ${(targetPct * 100).round()}% of weekly income.',
      evidence: [
        'Monthly income counted: ${money(income)}',
        'Configured allocation: ${(targetPct * 100).round()}%',
        'Emergency Fund allocation found: ${money(allocated)}',
      ],
    );
  }
  if (id == 'A9') {
    final recommended = action == null
        ? 1000.0
        : double.parse(
            _recommendationsForActionField(state, action, action.fields.first)
                .first);
    final minDeposit = configuredNumber('amt', recommended);
    const depositTypes = {'emergency_deposit', 'ef_replenish'};
    final monthTotal =
        _monthLedgerAmount(state, monthStart, 'emergency_deposit') +
            _monthLedgerAmount(state, monthStart, 'ef_replenish');
    final pattern = weeks.isEmpty
        ? <double>[
            minDeposit <= 0 ? 0 : (monthTotal / minDeposit).clamp(0.0, 1.0)
          ]
        : weeks.map((week) {
            final weeklyTotal =
                _ledgerAmountInRange(state, week.start, week.end, depositTypes);
            final weeklyTarget = minDeposit / weekCount;
            return weeklyTarget <= 0
                ? 0.0
                : (weeklyTotal / weeklyTarget).clamp(0.0, 1.0);
          }).toList();
    return _CashActionScore(
      id: id,
      title: 'Deposit Emergency Fund minimum',
      score: _averageWeeklyResiliency(pattern),
      detail:
          '${money(monthTotal)} deposited toward a ${money(minDeposit)} monthly minimum.',
      pattern: pattern,
      weekLabels: weeks.isEmpty ? const ['Current'] : _weekLabels(weeks),
      actualLabel: money(monthTotal),
      targetLabel: money(minDeposit),
      formula:
          'Progress = monthly Emergency Fund deposits ÷ configured ${money(minDeposit)} minimum, capped at 100%.',
      evidence: [
        'Configured minimum monthly deposit: ${money(minDeposit)}',
        'Emergency Fund deposits found: ${money(monthTotal)}',
      ],
    );
  }
  if (id == 'A10') {
    final recommended = action == null
        ? 7.0
        : double.parse(
            _recommendationsForActionField(state, action, action.fields.first)
                .first);
    final targetDays = configuredNumber('days', recommended);
    final withdrawals = state.d1Ledger.where((entry) {
      if (entry['type']?.toString() != 'use_emergency') return false;
      final date = DateTime.tryParse(entry['date']?.toString() ?? '');
      return date != null && _sameMonth(date, monthStart);
    }).toList()
      ..sort((a, b) => DateTime.parse(a['date'].toString())
          .compareTo(DateTime.parse(b['date'].toString())));
    final replenishDates = state.d1Ledger
        .where((entry) => const {'ef_replenish', 'emergency_deposit'}
            .contains(entry['type']?.toString()))
        .map((entry) => DateTime.tryParse(entry['date']?.toString() ?? ''))
        .whereType<DateTime>()
        .toList()
      ..sort();
    final now = DateTime.now();
    final pattern = <double>[];
    final labels = <String>[];
    final elapsedDays = <int>[];
    final evidenceLines = <String>[];
    for (final withdrawal in withdrawals) {
      final withdrawDate = DateTime.parse(withdrawal['date'].toString());
      final amount = (withdrawal['amount'] as num?)?.toDouble() ?? 0;
      final nextReplenish = replenishDates
          .where((date) => date.isAfter(withdrawDate))
          .firstOrNull;
      final elapsed = (nextReplenish ?? now).difference(withdrawDate).inDays;
      elapsedDays.add(elapsed);
      pattern.add(targetDays <= 0
          ? 0.0
          : (targetDays / math.max(1, elapsed)).clamp(0.0, 1.0));
      labels.add(_shortDate(withdrawDate));
      evidenceLines.add(nextReplenish == null
          ? '${_shortDate(withdrawDate)}: withdrew ${money(amount)}, not yet replenished ($elapsed days so far)'
          : '${_shortDate(withdrawDate)}: withdrew ${money(amount)}, replenished in $elapsed days');
    }
    final avgDays = elapsedDays.isEmpty
        ? 0.0
        : elapsedDays.fold(0, (sum, value) => sum + value) / elapsedDays.length;
    return _CashActionScore(
      id: id,
      title: 'Replenish Emergency Fund withdrawals',
      score: _averageWeeklyResiliency(pattern),
      detail: withdrawals.isEmpty
          ? 'No withdrawals were recorded this month.'
          : '${withdrawals.length} withdrawal${withdrawals.length == 1 ? '' : 's'} checked against a ${targetDays.toStringAsFixed(0)}-day replenishment target.',
      pattern: pattern,
      weekLabels: labels,
      actualLabel: withdrawals.isEmpty
          ? 'No withdrawals'
          : '${avgDays.toStringAsFixed(1)}d avg',
      targetLabel: '${targetDays.toStringAsFixed(0)}d',
      formula:
          'Resiliency = for each withdrawal this month, configured ${targetDays.toStringAsFixed(0)}-day target ÷ actual days to replenish, capped at 100%.',
      evidence: evidenceLines.isEmpty
          ? const ['No Emergency Fund withdrawals were recorded this month.']
          : evidenceLines,
      applicableMeasures: const ['Resiliency', 'Adherence'],
      emptyReason: 'No withdrawals to replenish this month.',
    );
  }
  if (id == 'A22') {
    final months = _configuredEmergencyCoverageMonths(state);
    final monthlyEssentials = state.monthlyEssentialExpenseTotal;
    final target = _configuredEmergencyCoverageTarget(state);
    final currentFund = state.displayedEmergencyFundBalance;
    final ratio = target <= 0 ? 0.0 : (currentFund / target).clamp(0.0, 1.0);
    return _CashActionScore(
      id: id,
      title: 'Build Emergency Fund coverage',
      score: ratio,
      detail:
          '${money(currentFund)} saved toward a ${months.toStringAsFixed(0)}-month (${money(target)}) target.',
      pattern: [ratio],
      weekLabels: const ['Current'],
      actualLabel: money(currentFund),
      targetLabel: money(target),
      formula:
          'Progress = current Emergency Fund balance ÷ configured ${months.toStringAsFixed(0)}-month essential-expense target.',
      evidence: [
        'Configured coverage target: ${months.toStringAsFixed(0)} months',
        'Monthly essential expenses: ${money(monthlyEssentials)}',
        'Emergency Fund balance counted: ${money(currentFund)}',
      ],
      applicableMeasures: const ['Resiliency'],
    );
  }
  return null;
}

/// Accumulating Wealth (G5)'s action scores. A12 is month-aware because it can
/// compare each income event with its matching investment transfer; A23/A30 stay
/// single-point portfolio health checks.
List<_CashActionScore> _investmentActionScores({
  required AppState state,
  DateTime? monthStart,
}) {
  final configured =
      state.selectedActionIds.where(_investmentGoalActionIds.contains).toList();
  final actionIds = configured.isEmpty ? _investmentGoalActionIds : configured;
  return [
    for (final id in actionIds)
      _investmentActionScoreFor(
        id: id,
        state: state,
        monthStart: monthStart,
      ),
  ].whereType<_CashActionScore>().toList();
}

_CashActionScore? _investmentActionScoreFor({
  required String id,
  required AppState state,
  DateTime? monthStart,
}) {
  final values = state.actionFieldValues[id] ?? const <String, String>{};
  double configuredNumber(String key, double fallback) {
    return double.tryParse((values[key] ?? '').replaceAll(',', '').trim()) ??
        fallback;
  }

  final balance = state.investmentPortfolioValue;
  if (id == 'A12') {
    final pct = configuredNumber('pct', 10);
    final incomes = monthStart == null
        ? [
            if (_latestIncomeTransaction(state) case final latestIncome?)
              latestIncome,
          ]
        : _incomeTransactionsForInvestmentMonth(state, monthStart);
    if (incomes.isEmpty) {
      return _CashActionScore(
        id: id,
        title: 'Invest a share of income',
        score: 0,
        detail: monthStart == null
            ? 'No income has been detected yet to invest a share of.'
            : 'No income was detected in ${_monthLabel(monthStart)} to invest a share of.',
        pattern: const [],
        weekLabels: const [],
        actualLabel: money(0),
        targetLabel: '${pct.toStringAsFixed(0)}% of income',
        formula:
            'Progress = invested amount from income ÷ configured ${pct.toStringAsFixed(0)}% income target.',
        evidence: [
          monthStart == null
              ? 'No income transaction detected yet'
              : 'No income transaction detected for ${_monthLabel(monthStart)}'
        ],
        emptyReason: monthStart == null
            ? 'No income has been detected yet to invest a share of.'
            : 'No income has been detected for ${_monthLabel(monthStart)}.',
      );
    }
    final ratios = <double>[];
    final labels = <String>[];
    var expected = 0.0;
    var actual = 0.0;
    for (final income in incomes) {
      final target = income.amount * pct / 100;
      final invested =
          _investmentDepositsForIncome(state, income.transactionId);
      expected += target;
      actual += invested;
      ratios.add(target <= 0 ? 0 : (invested / target).clamp(0.0, 1.0));
      labels.add(
          income.createdAt == null ? 'Income' : _shortDate(income.createdAt!));
    }
    final ratio = ratios.isEmpty
        ? 0.0
        : ratios.fold<double>(0, (total, value) => total + value) /
            ratios.length;
    return _CashActionScore(
      id: id,
      title: 'Invest a share of income',
      score: ratio,
      detail:
          '${money(actual)} invested toward ${money(expected)} expected from ${pct.toStringAsFixed(0)}% of income${monthStart == null ? '' : ' in ${_monthLabel(monthStart)}'}.',
      pattern: ratios,
      weekLabels: labels,
      actualLabel: money(actual),
      targetLabel: money(expected),
      formula:
          'Progress = invested amount from each income ÷ configured ${pct.toStringAsFixed(0)}% income target.',
      evidence: [
        'Configured contribution: ${pct.toStringAsFixed(0)}% of each income',
        'Income counted: ${money(incomes.fold<double>(0, (total, income) => total + income.amount))}',
        'Investment deposits from income: ${money(actual)}',
      ],
    );
  }
  if (id == 'A23') {
    final target = configuredNumber('amt', state.investmentPortfolioTarget);
    final ratio = target <= 0 ? 0.0 : (balance / target).clamp(0.0, 1.0);
    return _CashActionScore(
      id: id,
      title: 'Build the Investment Portfolio',
      score: ratio,
      detail:
          '${money(balance)} saved toward a ${money(target)} portfolio target.',
      pattern: [ratio],
      weekLabels: const ['Current'],
      actualLabel: money(balance),
      targetLabel: money(target),
      formula:
          'Progress = current Investment Portfolio balance ÷ configured target.',
      evidence: [
        'Configured portfolio target: ${money(target)}',
        'Investment Portfolio balance: ${money(balance)}',
      ],
      applicableMeasures: const ['Resiliency'],
    );
  }
  if (id == 'A30') {
    final target =
        configuredNumber('pct', state.investmentTargetAnnualReturnPercent);
    final baseline = state.investmentReturnBaselineDate;
    final tracking = baseline != null;
    final actual = state.investmentAnnualizedReturnPercent;
    if (!tracking) {
      return _CashActionScore(
        id: id,
        title: 'Meet the annual return target',
        score: 0,
        detail:
            'Start tracking to compare performance with the ${target.toStringAsFixed(0)}% target.',
        pattern: const [],
        weekLabels: const [],
        actualLabel: 'Not tracking',
        targetLabel: '${target.toStringAsFixed(0)}%',
        formula:
            'Progress = annualized investment return since tracking started ÷ configured target annual return.',
        evidence: const ['Tracking has not started yet'],
        applicableMeasures: const ['Resiliency'],
        emptyReason: 'Start tracking to see this action\'s score.',
      );
    }
    final ratio = target <= 0 ? 1.0 : (actual / target).clamp(0.0, 1.0);
    return _CashActionScore(
      id: id,
      title: 'Meet the annual return target',
      score: ratio,
      detail:
          '${actual.toStringAsFixed(1)}% annualized return toward a ${target.toStringAsFixed(0)}% target.',
      pattern: [ratio],
      weekLabels: const ['Current'],
      actualLabel: '${actual.toStringAsFixed(1)}%',
      targetLabel: '${target.toStringAsFixed(0)}%',
      formula:
          'Progress = annualized investment return since tracking started ÷ configured target annual return.',
      evidence: [
        'Configured target annual return: ${target.toStringAsFixed(0)}%',
        'Tracking since: ${_shortDate(baseline)}',
      ],
      applicableMeasures: const ['Resiliency'],
    );
  }
  return null;
}

/// Financial Freedom (G8)'s action scores. The pyramid's top layer is
/// intentionally relaxed - each action (A26-A29) is still scored as a
/// single current-state point, the same "pattern: [ratio]" shape used for
/// Accumulating Wealth's actions, since none of these have a natural
/// multi-week series either.
List<_CashActionScore> _lifestyleActionScores({required AppState state}) {
  final configured =
      state.selectedActionIds.where(_lifestyleGoalActionIds.contains).toList();
  final actionIds = configured.isEmpty ? _lifestyleGoalActionIds : configured;
  return [
    for (final id in actionIds) _lifestyleActionScoreFor(id: id, state: state),
  ].whereType<_CashActionScore>().toList();
}

_CashActionScore? _lifestyleActionScoreFor({
  required String id,
  required AppState state,
}) {
  double configuredNumber(String key, double fallback) {
    final values = state.actionFieldValues[id] ?? const <String, String>{};
    return double.tryParse((values[key] ?? '').replaceAll(',', '').trim()) ??
        fallback;
  }

  if (id == 'A26') {
    final target = configuredNumber('amt', _monthlySubscriptionBase(state));
    final reserved = state.lifestyleReservedThisMonth;
    final ratio = target <= 0 ? 0.0 : (reserved / target).clamp(0.0, 1.0);
    return _CashActionScore(
      id: id,
      title: 'Set aside subscriptions and memberships money',
      score: ratio,
      detail:
          '${money(reserved)} reserved this month toward a ${money(target)} target.',
      pattern: [ratio],
      weekLabels: const ['This month'],
      actualLabel: money(reserved),
      targetLabel: money(target),
      formula:
          'Progress = amount reserved this month ÷ configured monthly subscriptions target.',
      evidence: [
        'Configured monthly target: ${money(target)}',
        'Reserved this month: ${money(reserved)}',
      ],
    );
  }
  if (id == 'A27') {
    final amount = configuredNumber('amt', 1000);
    final latestIncome = _latestIncomeTransaction(state);
    if (latestIncome == null) {
      return _CashActionScore(
        id: id,
        title: 'Add to the Personal Lifestyle Fund every payday',
        score: 0,
        detail: 'No income has been detected yet to fund a payday transfer.',
        pattern: const [],
        weekLabels: const [],
        actualLabel: money(0),
        targetLabel: money(amount),
        formula:
            'Progress = whether the configured payday transfer was made for the latest income.',
        evidence: const ['No income transaction detected yet'],
        emptyReason:
            'No income has been detected yet to fund a payday transfer.',
      );
    }
    final done = state.hasLifestylePaydayAllocation(latestIncome.transactionId);
    final ratio = done ? 1.0 : 0.0;
    return _CashActionScore(
      id: id,
      title: 'Add to the Personal Lifestyle Fund every payday',
      score: ratio,
      detail: done
          ? '${money(amount)} was added to the Personal Lifestyle Fund on the latest payday.'
          : '${money(amount)} has not been added yet for the latest payday.',
      pattern: [ratio],
      weekLabels: const ['Latest payday'],
      actualLabel: done ? money(amount) : money(0),
      targetLabel: money(amount),
      formula:
          'Progress = whether the configured payday transfer was made for the latest income.',
      evidence: [
        'Configured payday amount: ${money(amount)}',
        'Latest payday: ${money(latestIncome.amount)}',
      ],
    );
  }
  if (id == 'A28') {
    final limit = configuredNumber('amt', 1500);
    final spent = _currentWeekLifestyleSpend(state);
    final ratio =
        limit <= 0 || spent <= limit ? 1.0 : (limit / spent).clamp(0.0, 1.0);
    return _CashActionScore(
      id: id,
      title: 'Keep everyday enjoyment spending within the weekly limit',
      score: ratio,
      detail: spent <= limit
          ? '${money(spent)} spent this week, within the ${money(limit)} limit.'
          : '${money(spent)} spent this week, over the ${money(limit)} limit.',
      pattern: [ratio],
      weekLabels: const ['This week'],
      actualLabel: money(spent),
      targetLabel: money(limit),
      formula:
          'Progress = configured weekly limit ÷ actual spend when over the limit, otherwise full credit.',
      evidence: [
        'Configured weekly limit: ${money(limit)}',
        'Spent this week: ${money(spent)}',
      ],
    );
  }
  if (id == 'A29') {
    final hobbies = state.lifestyleHobbies;
    if (hobbies.isEmpty) {
      return _CashActionScore(
        id: id,
        title: 'Save toward a hobby or activity',
        score: 0,
        detail: 'No hobby or activity targets have been set up yet.',
        pattern: const [],
        weekLabels: const [],
        actualLabel: money(0),
        targetLabel: 'Not set',
        formula:
            'Progress = total saved across configured hobbies ÷ their combined target.',
        evidence: const ['No hobbies configured yet'],
        emptyReason:
            'Add a hobby or activity target to see this action\'s score.',
      );
    }
    var totalSaved = 0.0;
    var totalTarget = 0.0;
    for (final hobby in hobbies) {
      totalSaved += state.lifestyleHobbyBalance(hobby['id'].toString());
      totalTarget += (hobby['target'] as num?)?.toDouble() ?? 0;
    }
    final ratio =
        totalTarget <= 0 ? 0.0 : (totalSaved / totalTarget).clamp(0.0, 1.0);
    final names = hobbies.map((h) => (h['name'] ?? '').toString()).join(', ');
    return _CashActionScore(
      id: id,
      title: 'Save toward a hobby or activity',
      score: ratio,
      detail:
          '${money(totalSaved)} saved toward $names (${money(totalTarget)} combined target).',
      pattern: [ratio],
      weekLabels: const ['Current'],
      actualLabel: money(totalSaved),
      targetLabel: money(totalTarget),
      formula:
          'Progress = total saved across configured hobbies ÷ their combined target.',
      evidence: [
        'Hobbies configured: ${hobbies.length}',
        'Combined target: ${money(totalTarget)}',
      ],
    );
  }
  return null;
}

double _ledgerAmountInRange(
  AppState state,
  DateTime start,
  DateTime end,
  Set<String> types,
) {
  return state.d1Ledger.where((entry) {
    if (!types.contains(entry['type']?.toString())) return false;
    final date = DateTime.tryParse(entry['date']?.toString() ?? '');
    return date != null &&
        !date.isBefore(start) &&
        date.isBefore(end.add(const Duration(days: 1)));
  }).fold(
      0.0, (sum, entry) => sum + ((entry['amount'] as num?)?.toDouble() ?? 0));
}

bool _isEssentialCashCategory(String? rawCategory) {
  final category = rawCategory?.trim().toLowerCase() ?? '';
  return category.contains('basic') ||
      category.contains('bill') ||
      category.contains('utilit') ||
      category.contains('rent') ||
      category.contains('housing') ||
      category.contains('grocery') ||
      category.contains('food') ||
      category.contains('transport') ||
      category.contains('health') ||
      category.contains('insurance');
}

double _monthLedgerAmount(AppState state, DateTime monthStart, String type) {
  return state.d1Ledger.where((entry) {
    if (entry['type']?.toString() != type) return false;
    final date = DateTime.tryParse(entry['date']?.toString() ?? '');
    return date != null && _sameMonth(date, monthStart);
  }).fold(
      0.0, (sum, entry) => sum + ((entry['amount'] as num?)?.toDouble() ?? 0));
}

bool _isBillLikeTransaction(FakeMayaTransaction transaction) {
  if (transaction.amount >= 0) return false;
  final text =
      '${transaction.title} ${transaction.category ?? ''} ${transaction.detail}'
          .toLowerCase();
  return text.contains('bill') ||
      text.contains('rent') ||
      text.contains('utility') ||
      text.contains('electric') ||
      text.contains('water') ||
      text.contains('internet') ||
      text.contains('payment');
}

DateTime _monthStart(DateTime value) => DateTime(value.year, value.month);

bool _sameMonth(DateTime value, DateTime month) =>
    value.year == month.year && value.month == month.month;

String _monthLabel(DateTime value) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[value.month - 1]} ${value.year}';
}

class _CashMonthSelector extends StatelessWidget {
  const _CashMonthSelector({
    required this.months,
    required this.selected,
    required this.onSelected,
  });

  final List<_CashMonthInsight> months;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          reverse: true,
          itemCount: months.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, reversedIndex) {
            final index = months.length - 1 - reversedIndex;
            final month = months[index];
            final active = selected == month.start;
            return ChoiceChip(
              selected: active,
              label: Text(_monthLabel(month.start)),
              onSelected: (_) => onSelected(month.start),
              selectedColor: _title,
              backgroundColor: _surface,
              labelStyle: TextStyle(
                color: active ? Colors.white : _body,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
              side: BorderSide(color: active ? _title : _border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InsightMonthSelector extends StatelessWidget {
  const _InsightMonthSelector({
    required this.months,
    required this.selected,
    required this.onSelected,
  });

  final List<DateTime> months;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    if (months.length <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          reverse: true,
          itemCount: months.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, reversedIndex) {
            final index = months.length - 1 - reversedIndex;
            final month = months[index];
            final active = selected == month;
            return ChoiceChip(
              selected: active,
              label: Text(_monthLabel(month)),
              onSelected: (_) => onSelected(month),
              selectedColor: _title,
              backgroundColor: _surface,
              labelStyle: TextStyle(
                color: active ? Colors.white : _body,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
              side: BorderSide(color: active ? _title : _border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            );
          },
        ),
      ),
    );
  }
}

String _cashIndexInsight(_CashMonthInsight month) {
  final billScore = _scorePercent(month.billScore);
  if (month.canPayBills) {
    return 'Your wallet covers ${money(month.billNeed)} in bills for ${_monthLabel(month.start)} with room to spare — ${money(month.walletAvailable - month.billNeed)} left over.';
  }
  return "You're at $billScore% of what you need to cover ${_monthLabel(month.start)}'s bills — ${money(month.billNeed - month.walletAvailable)} short of the ${money(month.billNeed)} needed.";
}

class _AvailableCashAnswerCard extends StatelessWidget {
  const _AvailableCashAnswerCard({
    required this.months,
    required this.month,
    required this.selectedMonth,
    required this.onMonthSelected,
  });
  final List<_CashMonthInsight> months;
  final _CashMonthInsight month;
  final DateTime? selectedMonth;
  final ValueChanged<DateTime> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    final billScore = _scorePercent(month.billScore);
    final resiliencyScore = _scorePercent(month.goalResiliencyScore);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'REFLECTION QUESTION',
              style: TextStyle(
                color: _purple,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Can this month’s available cash cover bills?',
              style: TextStyle(
                color: _title,
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Here’s the answer for the month you pick below.',
              style: TextStyle(
                color: _body,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            if (months.length > 1) ...[
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  itemCount: months.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, reversedIndex) {
                    final index = months.length - 1 - reversedIndex;
                    final item = months[index];
                    final active = selectedMonth == item.start;
                    return ChoiceChip(
                      selected: active,
                      label: Text(_monthLabel(item.start)),
                      onSelected: (_) => onMonthSelected(item.start),
                      selectedColor: _title,
                      backgroundColor: _surface,
                      labelStyle: TextStyle(
                        color: active ? Colors.white : _body,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                      side: BorderSide(color: active ? _title : _border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        month.canPayBills
                            ? Icons.check_circle_rounded
                            : Icons.error_rounded,
                        color: month.canPayBills ? _sage : _red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          month.canPayBills
                              ? 'Yes, your wallet can cover this month’s bills'
                              : 'No, your wallet cannot cover this month’s bills yet',
                          style: const TextStyle(
                            color: _title,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_monthLabel(month.start)} · Bills need ${money(month.billNeed)} and wallet has ${money(month.walletAvailable)}.',
                    style: const TextStyle(
                      color: _body,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (month.openObligations.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _amber.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _amber.withValues(alpha: .2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Unpaid bills included',
                            style: TextStyle(
                              color: _title,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          for (final bill in month.openObligations.take(3))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      bill['name']?.toString() ??
                                          'Basic needs bill',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: _body,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    money(_billRemaining(bill)),
                                    style: const TextStyle(
                                      color: _amber,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _OverviewMetric(
                          label: 'Bill readiness',
                          value: '$billScore%',
                          color: month.canPayBills ? _sage : _red,
                          icon: month.canPayBills
                              ? Icons.check_circle_rounded
                              : Icons.error_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _OverviewMetric(
                          label: 'Need',
                          value: money(month.billNeed),
                          color: _amber,
                          icon: Icons.receipt_long_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _OverviewMetric(
                          label: 'Have',
                          value: money(month.walletAvailable),
                          color: _brand,
                          icon: Icons.account_balance_wallet_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: month.billScore,
                      minHeight: 8,
                      color: month.canPayBills ? _sage : _red,
                      backgroundColor: _border.withValues(alpha: .5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _OverviewMetric(
                          label: 'Earned',
                          value: money(month.income),
                          color: _sage,
                          icon: Icons.south_west_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _OverviewMetric(
                          label: 'Spent',
                          value: money(month.spending),
                          color: _red,
                          icon: Icons.north_east_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _OverviewMetric(
                          label: 'Goal resiliency',
                          value: '$resiliencyScore%',
                          color: _resiliencyScoreColor(resiliencyScore),
                          icon: Icons.task_alt_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _AiInsightNote(
              trend: month.canPayBills ? _InsightTrend.up : _InsightTrend.down,
              text: _cashIndexInsight(month),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashMonthStatusSection extends StatelessWidget {
  const _CashMonthStatusSection({required this.month});

  final _CashMonthInsight month;

  @override
  Widget build(BuildContext context) {
    final resiliencyScore = _scorePercent(month.goalResiliencyScore);
    final billScore = _scorePercent(month.billScore);
    return _ExplorerSection(
      eyebrow: 'MONTH · CASH INDEX',
      title: month.canPayBills
          ? 'Yes, your wallet can cover this month’s bills'
          : 'No, your wallet cannot cover this month’s bills yet',
      subtitle:
          '${_monthLabel(month.start)} · Bills need ${money(month.billNeed)} and wallet has ${money(month.walletAvailable)}.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _OverviewMetric(
                  label: 'Bill readiness',
                  value: '$billScore%',
                  color: month.canPayBills ? _sage : _red,
                  icon: month.canPayBills
                      ? Icons.check_circle_rounded
                      : Icons.error_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OverviewMetric(
                  label: 'Need',
                  value: money(month.billNeed),
                  color: _amber,
                  icon: Icons.receipt_long_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OverviewMetric(
                  label: 'Have',
                  value: money(month.walletAvailable),
                  color: _brand,
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: month.billScore,
            minHeight: 10,
            color: month.canPayBills ? _sage : _red,
            backgroundColor: _border.withValues(alpha: .5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OverviewMetric(
                  label: 'Earned',
                  value: money(month.income),
                  color: _sage,
                  icon: Icons.south_west_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OverviewMetric(
                  label: 'Spent',
                  value: money(month.spending),
                  color: _red,
                  icon: Icons.north_east_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OverviewMetric(
                  label: 'Goal resiliency',
                  value: '$resiliencyScore%',
                  color: _resiliencyScoreColor(resiliencyScore),
                  icon: Icons.task_alt_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionMeasure {
  const _ActionMeasure(this.label, this.percent, {this.missingReason});

  final String label;
  final int? percent;
  final String? missingReason;

  bool get hasScore => percent != null;
}

/// Consistency, Resiliency, and Adherence, derived from the same weekly
/// [_CashActionScore.pattern] data every action already computes:
/// - Resiliency: the action's overall score (how well the target held up
///   week to week, including partial misses) — always shown.
/// - Adherence: % of weeks the target was fully met.
/// - Consistency: % of weeks with any measurable activity at all.
/// Single-point actions still show all three: Consistency marks whether any
/// data exists, and Adherence marks whether that one point fully met target.
List<_ActionMeasure> _actionMeasures(_CashActionScore action) {
  final applicable = action.applicableMeasures;
  if (action.pattern.isEmpty) {
    return [
      for (final label in applicable)
        _ActionMeasure(label, null, missingReason: action.emptyReason),
    ];
  }
  final resiliency = _ActionMeasure('Resiliency', _scorePercent(action.score));
  final adherence = _scorePercent(
    action.pattern.where((value) => value >= 1.0).length /
        action.pattern.length,
  );
  final consistency = _scorePercent(
    action.pattern.where((value) => value > 0).length / action.pattern.length,
  );
  final byLabel = {
    'Consistency': _ActionMeasure('Consistency', consistency),
    'Resiliency': resiliency,
    'Adherence': _ActionMeasure('Adherence', adherence),
  };
  return [for (final label in applicable) byLabel[label]!];
}

class _CircularScoreGauge extends StatelessWidget {
  const _CircularScoreGauge({
    required this.label,
    required this.percent,
    this.size = 60,
    this.strokeWidth = 6,
    this.valueFontSize = 15,
  });

  factory _CircularScoreGauge.forMeasure(_ActionMeasure measure) =>
      _CircularScoreGauge(label: measure.label, percent: measure.percent);

  final String label;
  final int? percent;
  final double size;
  final double strokeWidth;
  final double valueFontSize;

  @override
  Widget build(BuildContext context) {
    final color = percent == null ? _body : _resiliencyScoreColor(percent!);
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: percent == null ? 0 : percent! / 100,
                  strokeWidth: strokeWidth,
                  color: color,
                  backgroundColor: _border,
                ),
              ),
              Text(
                percent == null ? 'N/A' : '$percent',
                style: TextStyle(
                  color: color,
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: _title,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ActionProgressSection extends StatelessWidget {
  const _ActionProgressSection({
    required this.actionScores,
    this.eyebrow = 'MONTH · ACTION PROGRESS',
    this.title = 'Your actions, measured',
    this.subtitle =
        'Each action shows an overall score — tap it to see the Consistency, Resiliency, and Adherence behind it.',
  });

  final List<_CashActionScore> actionScores;
  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _ExplorerSection(
      eyebrow: eyebrow,
      title: title,
      subtitle: subtitle,
      child: actionScores.isEmpty
          ? const _ReflectionEmpty(
              message: 'No action scores are available yet.')
          : Column(
              children: [
                for (final action in actionScores)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ActionMeasureCard(action: action),
                  ),
              ],
            ),
    );
  }
}

/// One action's overall score (average of whichever measures apply) shown
/// up front via a circular gauge on the right, with the Consistency/
/// Resiliency/Adherence breakdown — only the measures that are actually
/// applicable to this action — always visible below it. Tapping anywhere on
/// the card opens the full weekly-pattern dialog for a deeper dive.
class _ActionMeasureCard extends StatelessWidget {
  const _ActionMeasureCard({required this.action});

  final _CashActionScore action;

  @override
  Widget build(BuildContext context) {
    final measures = _actionMeasures(action);
    final overall = _overallActionScore(measures);
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => _showCashActionScoreDetails(context, action),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: _bellySoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child:
                        const Icon(Icons.bolt_rounded, size: 13, color: _brand),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _d2Actions[action.id]?.text ?? action.title,
                          style: const TextStyle(
                            color: _title,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          action.detail,
                          style: const TextStyle(
                            color: _body,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _CircularScoreGauge(
                    label: 'Score',
                    percent: overall,
                    size: 54,
                    strokeWidth: 5,
                    valueFontSize: 15,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _AiInsightNote(
                trend: _actionInsightTrend(measures),
                text: _actionInsight(action, measures),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _actionMeasuredInputLabel(action),
                      style: const TextStyle(
                        color: _body,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Text(
                    'Full breakdown',
                    style: TextStyle(
                      color: _purple,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: _purple, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _actionMeasuredInputLabel(_CashActionScore action) =>
    'Measured input: ${action.actualLabel} · configured target: ${action.targetLabel}';

_InsightTrend _actionInsightTrend(List<_ActionMeasure> measures) {
  final scored = measures.where((measure) => measure.hasScore).toList();
  if (scored.isEmpty) return _InsightTrend.neutral;
  final lowest = scored.reduce((a, b) => a.percent! <= b.percent! ? a : b);
  if (lowest.percent! >= 80) return _InsightTrend.up;
  if (lowest.percent! >= 50) return _InsightTrend.neutral;
  return _InsightTrend.down;
}

String _actionInsight(_CashActionScore action, List<_ActionMeasure> measures) {
  final scored = measures.where((measure) => measure.hasScore).toList();
  if (scored.isEmpty) {
    return 'Not enough data to make a calculation yet. Add or sync more labeled activity for this action.';
  }
  final lowest = scored.reduce((a, b) => a.percent! <= b.percent! ? a : b);
  if (lowest.percent! >= 80) {
    return "Strong performance across the board for this action — keep it up.";
  }
  final label = lowest.label.toLowerCase();
  final detail = switch (lowest.label) {
    'Consistency' =>
      "you're not logging activity for this action every week — try to keep it up weekly.",
    'Adherence' =>
      "you're hitting the target less often than not — consider a smaller target if it feels out of reach.",
    _ =>
      "the target has been hard to hold onto some weeks, even with partial progress.",
  };
  return 'Your $label is the area to watch here — $detail';
}

Widget _dialogSectionLabel(String text) => Text(
      text,
      style: const TextStyle(
        color: _title,
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    );

/// Reconfirms — once per motivation, at onboarding or via "+ Add Goal" —
/// that Shellby will auto-create the matching FakeMaya personal-goal
/// bucket. Returns false immediately (no dialog shown) if the motivation
/// has no FakeMaya bucket mapping.
Future<bool> confirmFakeMayaBucketCreation(
  BuildContext context, {
  required String motivation,
}) async {
  final bucketName = fakeMayaBucketNameForMotivation(motivation);
  if (bucketName == null) return false;
  final agreed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      backgroundColor: _surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _bellySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.savings_rounded,
                      color: _brand, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Maya bucket',
                        style: TextStyle(
                          color: _title,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'For $motivation',
                        style: const TextStyle(
                          color: _body,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: _body,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Adding this goal will create a corresponding '
                          'bucket on your Maya account called ',
                    ),
                    TextSpan(
                      text: '"$bucketName"',
                      style: const TextStyle(
                        color: _title,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const TextSpan(
                      text: '. Shellby actions for this goal will deposit '
                          'into it automatically. Do you agree?',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _body,
                      side: const BorderSide(color: _border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Not now',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: _brand,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Create bucket',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return agreed ?? false;
}

Future<void> showFakeMayaLinkRequiredForBucket(BuildContext context) async {
  final shouldLink = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => Dialog(
      backgroundColor: _surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _bellySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child:
                      const Icon(Icons.link_rounded, color: _brand, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Link FakeMaya first',
                    style: GoogleFonts.fredoka(
                      color: _title,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Shellby needs a linked FakeMaya account before it can create a Maya bucket for this goal.',
              style: TextStyle(
                color: _body,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _body,
                      side: const BorderSide(color: _border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Not now',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: _brand,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Link account',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (shouldLink == true && context.mounted) {
    _push(
      context,
      const LinkedAccountsScreen(openFakeMayaLoginOnStart: true),
    );
  }
}

void _showCashActionScoreDetails(
  BuildContext context,
  _CashActionScore action,
) {
  final measures = _actionMeasures(action);
  final missingReason = measures
      .map((measure) => measure.missingReason)
      .whereType<String>()
      .firstOrNull;
  final patternStats = _distributionStats(
    action.pattern.map((value) => value.clamp(0.0, 1.0) * 100).toList(),
  );
  showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: _surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        // Bounding this explicitly (rather than leaving it to Dialog's
        // implicit sizing) guarantees the scrollable body below always
        // gets real, non-zero height to work with, so long action lists
        // (lots of evidence/weekly bars) scroll instead of overflowing
        // and clipping the gauges at the top.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${action.title} resiliency',
                style: const TextStyle(
                  color: _title,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (final measure in measures)
                            _CircularScoreGauge.forMeasure(measure),
                        ],
                      ),
                      if (missingReason != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          missingReason,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _body,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: _bellySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _actionMeasuredInputLabel(action),
                          style: const TextStyle(
                            color: _purple,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        action.formula,
                        style: const TextStyle(
                          color: _body,
                          fontSize: 11.5,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Divider(height: 1, color: _border),
                      const SizedBox(height: 16),
                      _dialogSectionLabel('Data behind the score'),
                      const SizedBox(height: 8),
                      for (final item in action.evidence)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 5),
                                child:
                                    Icon(Icons.circle, color: _purple, size: 5),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    color: _body,
                                    fontSize: 11.5,
                                    height: 1.35,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (action.pattern.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: _border),
                        const SizedBox(height: 16),
                        if (patternStats != null) ...[
                          _dialogSectionLabel('Score measures'),
                          const SizedBox(height: 10),
                          _StatsGrid(
                            stats: patternStats,
                            valueFormatter: (value) => '${value.round()}%',
                            modeEmptyLabel: 'No repeat',
                          ),
                          const SizedBox(height: 18),
                        ],
                        _dialogSectionLabel('Percentage rate per week'),
                        const SizedBox(height: 10),
                        for (var i = 0; i < action.pattern.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Builder(builder: (context) {
                              final weekColor =
                                  _resiliencyValueColor(action.pattern[i]);
                              return Row(
                                children: [
                                  SizedBox(
                                    width: 54,
                                    child: Text(
                                      i < action.weekLabels.length
                                          ? action.weekLabels[i]
                                          : 'Week ${i + 1}',
                                      style: const TextStyle(
                                        color: _body,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        value:
                                            action.pattern[i].clamp(0.0, 1.0),
                                        minHeight: 8,
                                        color: weekColor,
                                        backgroundColor:
                                            _border.withValues(alpha: .5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_scorePercent(action.pattern[i])}%',
                                    style: TextStyle(
                                      color: weekColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Close',
                    style:
                        TextStyle(color: _purple, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Goal-agnostic "N suggestions for X" banner: runs the goal's action stage
/// in the background and, once it resolves, shows a tappable pill that
/// scrolls down to the Action Stage section. Shared by Available Cash and
/// Emergency Fund (and any future goal with its own action stage).
class _GoalSuggestionBanner extends StatefulWidget {
  const _GoalSuggestionBanner({
    required this.goalLabel,
    required this.allowedActionIds,
    required this.runStage,
    required this.color,
    required this.onViewSuggestions,
  });

  final String goalLabel;
  final List<String> allowedActionIds;
  final Future<ActionStageResult> Function(ShellbyAiCoach coach, AppState state)
      runStage;
  final Color color;
  final VoidCallback onViewSuggestions;

  @override
  State<_GoalSuggestionBanner> createState() => _GoalSuggestionBannerState();
}

class _GoalSuggestionBannerState extends State<_GoalSuggestionBanner> {
  final _coach = const ShellbyAiCoach();
  bool _started = false;
  bool _loading = true;
  int? _count;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _load();
    }
  }

  Future<void> _load() async {
    final state = AppScope.of(context);
    try {
      final result = await widget.runStage(_coach, state);
      if (!mounted) return;
      setState(() {
        _count = _actionStageDisplaySuggestions(
          result,
          state,
          widget.allowedActionIds,
        ).length;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _brand,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Checking for suggestions…',
              style: TextStyle(
                color: _body,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }
    final count = _count;
    if (count == null || count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: GestureDetector(
        onTap: widget.onViewSuggestions,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$count suggestion${count == 1 ? '' : 's'} for ${widget.goalLabel}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

/// Goal-agnostic Action Stage section: reviews the latest integration data
/// against a specific goal's action set and lets the user apply the
/// recommended change. Parameterized so it can drive both Maintain
/// Available Cash (G1) and Build Emergency Fund (G3) with the same UI.
class _GoalActionStageSection extends StatefulWidget {
  const _GoalActionStageSection({
    super.key,
    required this.goalId,
    required this.goalLabel,
    required this.allowedActionIds,
    required this.subtitle,
    required this.emptyMessage,
    required this.runStage,
  });

  final String goalId;
  final String goalLabel;
  final List<String> allowedActionIds;
  final String subtitle;
  final String emptyMessage;
  final Future<ActionStageResult> Function(ShellbyAiCoach coach, AppState state)
      runStage;

  @override
  State<_GoalActionStageSection> createState() =>
      _GoalActionStageSectionState();
}

class _GoalActionStageSectionState extends State<_GoalActionStageSection> {
  final _coach = const ShellbyAiCoach();
  ActionStageResult? _result;
  String? _error;
  bool _loading = false;
  bool _autoStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_autoStarted) {
      _autoStarted = true;
      _runStage();
    }
  }

  Future<void> _runStage() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.runStage(_coach, AppScope.of(context));
      if (!mounted) return;
      setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _aiActionStageError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ExplorerSection(
      eyebrow: 'ACTION STAGE · LATEST 14 DAYS',
      title: 'What should change first?',
      subtitle: widget.subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionStageOptionChip(label: 'Retain'),
              _ActionStageOptionChip(label: 'Change target'),
              _ActionStageOptionChip(label: 'Suggest new'),
              _ActionStageOptionChip(label: 'Replace'),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _runStage,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_rounded, size: 18),
            label: Text(_loading ? 'Analyzing...' : 'Run action stage'),
            style: FilledButton.styleFrom(backgroundColor: _purple),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                color: _red,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 14),
            _ActionStageFirstChange(result: _result!),
            const SizedBox(height: 12),
            for (final suggestion in _actionStageDisplaySuggestions(
              _result!,
              AppScope.of(context),
              widget.allowedActionIds,
            )) ...[
              _ActionStageSuggestionCard(
                suggestion: suggestion,
                onTap: () => _applySuggestion(suggestion),
              ),
              const SizedBox(height: 10),
            ],
          ] else if (!_loading) ...[
            const SizedBox(height: 12),
            Text(
              widget.emptyMessage,
              style: const TextStyle(
                color: _body,
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _applySuggestion(ActionStageSuggestion suggestion) async {
    final state = AppScope.of(context);
    final accepted = await _confirmActionStageSuggestion(
      context,
      state,
      suggestion,
      allowedActionIds: widget.allowedActionIds,
      goalLabel: widget.goalLabel,
    );
    if (!mounted || accepted != true) return;

    final message = await _applyActionStageSuggestion(
      state,
      suggestion,
      allowedActionIds: widget.allowedActionIds,
      goalLabel: widget.goalLabel,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    final shell = context.findAncestorStateOfType<_MainShellState>();
    if (shell != null) {
      shell.openGoal(widget.goalId);
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GoalsPage(initialGoalId: widget.goalId),
        ),
      );
    }
    if (mounted) setState(() {});
  }
}

Future<bool?> _confirmActionStageSuggestion(
  BuildContext context,
  AppState state,
  ActionStageSuggestion suggestion, {
  required List<String> allowedActionIds,
  required String goalLabel,
}) {
  final allowed = allowedActionIds.toSet();
  final actionId = _actionStageTargetActionId(suggestion);
  if (!allowed.contains(actionId)) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cannot apply this recommendation'),
        content: Text(
          'This recommendation is outside the $goalLabel action set.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  final action = _d2Actions[actionId];
  final current = state.actionFieldValues[actionId] ?? const <String, String>{};
  final next = _cleanActionStageTarget(
    actionId,
    suggestion.target,
    state,
    useFallbacks:
        suggestion.option != 'retain_action' || suggestion.target.isNotEmpty,
  );
  final changes = _actionStageChangeRows(
    actionId: actionId,
    current: current,
    next: next,
  );
  final optionLabel = _actionStageOptionReviewLabel(suggestion.option);
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: _surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: _bellySoft,
                        borderRadius: BorderRadius.all(Radius.circular(13)),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.tune_rounded,
                          color: _brand, size: 21),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Review Action Change',
                            style: TextStyle(
                              color: _title,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$optionLabel for ${action?.text ?? suggestion.actionText}',
                            style: const TextStyle(
                              color: _body,
                              fontSize: 11.5,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (suggestion.reason.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      suggestion.reason,
                      style: const TextStyle(
                        color: _body,
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                const Text(
                  'WHAT\'S CHANGING',
                  style: TextStyle(
                    color: _body,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                if (changes.isEmpty)
                  const Text(
                    'No configurable values will change. This action will only be retained or added to the goal.',
                    style: TextStyle(color: _body, fontSize: 12, height: 1.35),
                  )
                else
                  ...changes.map(
                    (row) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ActionStageChangeRow(row: row),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _body,
                          side: const BorderSide(color: _border),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Reject',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: _brand,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Accept',
                            style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _ActionStageFirstChange extends StatelessWidget {
  const _ActionStageFirstChange({required this.result});

  final ActionStageResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _purple.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _purple.withValues(alpha: .16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.bolt_rounded, color: _purple, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'First change',
                  style: TextStyle(
                    color: _title,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.firstChange,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
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

class _ActionStageSuggestionCard extends StatelessWidget {
  const _ActionStageSuggestionCard({
    required this.suggestion,
    required this.onTap,
  });

  final ActionStageSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _actionStageOptionColor(suggestion.option);
    final target = _actionStageTargetText(suggestion.target);
    final detail = [
      if (target.isNotEmpty) target,
      if (suggestion.replacementActionId?.isNotEmpty == true)
        'Replace: ${suggestion.replacementActionId}',
    ].join(' · ');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _actionStageOptionLabel(suggestion.option),
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (detail.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _title,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    suggestion.actionText.isEmpty
                        ? (_d2Actions[suggestion.actionId]?.text ?? 'Action')
                        : suggestion.actionText,
                    style: const TextStyle(
                      color: _title,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suggestion.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _body,
                      fontSize: 11.5,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: _body, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ActionStageOptionChip extends StatelessWidget {
  const _ActionStageOptionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _bellySoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _body,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _aiActionStageError(Object error) {
  final text = error.toString();
  if (text.contains('Unable to load asset') ||
      text.contains('Set LOCAL_MODEL_ASSET')) {
    return 'Shellby needs the bundled Qwen model for offline action review, or internet access for Gemini.';
  }
  if (text.contains('Gemini proxy request failed: 404')) {
    return 'Gemini proxy was not found. Check GEMINI_PROXY_URL, or run with GEMINI_API_KEY so Shellby can call Gemini directly.';
  }
  if (text.contains('Gemini API request failed: 404')) {
    return 'Gemini model was not found. Shellby is set to $_geminiModel; use a GenerateContent model such as gemini-3.1-flash-lite.';
  }
  return 'Shellby could not complete the action review yet. $text';
}

String _actionStageOptionLabel(String option) {
  return switch (option) {
    'retain_action' => 'Retain',
    'change_parameterized_target' => 'Change target',
    'suggest_new_action' => 'Suggest new',
    'remove_and_replace_action' => 'Replace',
    _ => option.replaceAll('_', ' '),
  };
}

String _actionStageOptionReviewLabel(String option) {
  return switch (option) {
    'retain_action' => 'Retain action',
    'change_parameterized_target' => 'Change target',
    'suggest_new_action' => 'Add action',
    'remove_and_replace_action' => 'Replace action',
    _ => 'Update action',
  };
}

Color _actionStageOptionColor(String option) {
  return switch (option) {
    'retain_action' => _sage,
    'change_parameterized_target' => _amber,
    'suggest_new_action' => _purple,
    'remove_and_replace_action' => _red,
    _ => _body,
  };
}

String _actionStageTargetText(Map<String, String> target) {
  final parts = <String>[];
  final pct = target['pct']?.trim();
  final amount = target['amt']?.trim();
  final days = target['days']?.trim();
  final months = target['months']?.trim();
  final categories = target['categories']?.trim();
  if (pct?.isNotEmpty == true) parts.add('$pct%');
  if (amount?.isNotEmpty == true) {
    final parsed = double.tryParse(amount!.replaceAll(',', ''));
    parts.add(parsed == null ? '₱$amount' : money(parsed));
  }
  if (days?.isNotEmpty == true) parts.add('$days days');
  if (months?.isNotEmpty == true) parts.add('$months mo.');
  if (categories?.isNotEmpty == true) parts.add(categories!);
  return parts.join(' · ');
}

String _actionStageTargetActionId(ActionStageSuggestion suggestion) {
  if (suggestion.option == 'remove_and_replace_action') {
    final replacement = suggestion.replacementActionId;
    if (replacement != null && replacement.trim().isNotEmpty) {
      return replacement.trim();
    }
  }
  return suggestion.actionId;
}

String _actionStageFieldLabel(String actionId, String key) {
  final action = _d2Actions[actionId];
  final field = action?.fields.where((item) => item.key == key).firstOrNull;
  if (field != null) return field.label;
  return switch (key) {
    'pct' => 'Allocation percentage',
    'amt' => 'Monthly cap',
    'categories' => 'Selected categories',
    _ => key,
  };
}

String _formatActionStageFieldValue(String key, String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'Not set';
  final numeric = double.tryParse(trimmed.replaceAll(',', ''));
  if (key == 'pct' && numeric != null) return '${numeric.toStringAsFixed(0)}%';
  if (key == 'amt' && numeric != null) return money(numeric);
  if (key == 'days' && numeric != null) {
    return '${numeric.toStringAsFixed(0)} days';
  }
  if (key == 'months' && numeric != null) {
    return '${numeric.toStringAsFixed(0)} mo.';
  }
  return trimmed;
}

List<_ActionStageChange> _actionStageChangeRows({
  required String actionId,
  required Map<String, String> current,
  required Map<String, String> next,
}) {
  final keys = <String>{...current.keys, ...next.keys}.toList();
  keys.sort((a, b) {
    const order = ['pct', 'amt', 'months', 'days', 'categories'];
    final ai = order.indexOf(a);
    final bi = order.indexOf(b);
    if (ai != -1 || bi != -1) {
      return (ai == -1 ? 99 : ai).compareTo(bi == -1 ? 99 : bi);
    }
    return a.compareTo(b);
  });
  return [
    for (final key in keys)
      if ((current[key] ?? '').trim() != (next[key] ?? '').trim())
        _ActionStageChange(
          label: _actionStageFieldLabel(actionId, key),
          current: _formatActionStageFieldValue(key, current[key] ?? ''),
          next: _formatActionStageFieldValue(key, next[key] ?? ''),
        ),
  ];
}

class _ActionStageChange {
  const _ActionStageChange({
    required this.label,
    required this.current,
    required this.next,
  });

  final String label;
  final String current;
  final String next;
}

class _ActionStageChangeRow extends StatelessWidget {
  const _ActionStageChangeRow({required this.row});

  final _ActionStageChange row;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          row.label,
          style: const TextStyle(
            color: _title,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _ActionStageValueChip(value: row.current, isNew: false),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward_rounded, size: 16, color: _body),
            ),
            Expanded(
              child: _ActionStageValueChip(value: row.next, isNew: true),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionStageValueChip extends StatelessWidget {
  const _ActionStageValueChip({required this.value, required this.isNew});

  final String value;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final color = isNew ? _brand : _red;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

List<ActionStageSuggestion> _actionStageDisplaySuggestions(
  ActionStageResult result,
  AppState state,
  List<String> allowedActionIds,
) {
  final shown = <ActionStageSuggestion>[];
  final seen = <String>{};
  for (final suggestion in result.suggestions) {
    if (!allowedActionIds.contains(suggestion.actionId)) continue;
    final key = '${suggestion.option}:${suggestion.actionId}';
    if (seen.add(key)) shown.add(suggestion);
  }
  for (final id in allowedActionIds) {
    if (shown.any((suggestion) => suggestion.actionId == id)) continue;
    final selected = state.selectedActionIds.contains(id);
    shown.add(
      ActionStageSuggestion(
        option: selected ? 'retain_action' : 'suggest_new_action',
        actionId: id,
        actionText: _d2Actions[id]?.text ?? id,
        priority: 50 + shown.length,
        reason: selected
            ? 'This action is already part of the plan and can be kept if it still matches the latest data.'
            : 'This is one of the available actions you can add if it fits the latest data.',
        target: _defaultActionStageTarget(id, state),
        replacementActionId: null,
      ),
    );
  }
  shown.sort((a, b) => a.priority.compareTo(b.priority));
  return shown.take(4).toList();
}

Map<String, String> _defaultActionStageTarget(String id, AppState state) {
  final action = _d2Actions[id];
  if (action == null || action.fields.isEmpty) return const {};
  final values = state.actionFieldValues[id] ?? const <String, String>{};
  return {
    for (final field in action.fields)
      field.key: values[field.key] ??
          _recommendationsForActionField(state, action, field).first,
  };
}

Future<String> _applyActionStageSuggestion(
  AppState state,
  ActionStageSuggestion suggestion, {
  required List<String> allowedActionIds,
  required String goalLabel,
}) async {
  final allowed = allowedActionIds.toSet();
  final ids = state.selectedActionIds.where(allowed.contains).toList();
  if (ids.isEmpty) ids.addAll(allowedActionIds);

  final option = suggestion.option;
  var targetActionId = suggestion.actionId;
  if (!allowed.contains(targetActionId)) {
    return 'This recommendation is outside the $goalLabel action set.';
  }

  if (option == 'remove_and_replace_action') {
    ids.remove(suggestion.actionId);
    final replacement = suggestion.replacementActionId;
    if (replacement != null && allowed.contains(replacement)) {
      targetActionId = replacement;
      if (!ids.contains(replacement)) ids.add(replacement);
      state.actionFieldValues.remove(suggestion.actionId);
    } else if (!ids.contains(targetActionId)) {
      ids.add(targetActionId);
    }
  } else if (option == 'suggest_new_action' ||
      option == 'change_parameterized_target') {
    if (!ids.contains(targetActionId)) ids.add(targetActionId);
  }

  final targetValues = _cleanActionStageTarget(
    targetActionId,
    suggestion.target,
    state,
    useFallbacks:
        suggestion.option != 'retain_action' || suggestion.target.isNotEmpty,
  );
  if (targetValues.isNotEmpty) {
    state.actionFieldValues[targetActionId] = targetValues;
  }
  _applyActionStageCategoryBudgets(state, targetActionId, targetValues);

  state.setActionsForGoal(
    allowedActionIds: allowedActionIds,
    actionIds: ids.where(allowed.contains),
    clearRemovedValues: false,
  );
  await state.saveProfile();
  final targetLabel = _d2Actions[targetActionId]?.text ?? targetActionId;
  return switch (option) {
    'retain_action' => 'Kept: $targetLabel',
    'change_parameterized_target' => 'Updated target for: $targetLabel',
    'suggest_new_action' => 'Added to $goalLabel: $targetLabel',
    'remove_and_replace_action' => 'Replaced with: $targetLabel',
    _ => 'Updated: $targetLabel',
  };
}

Map<String, String> _cleanActionStageTarget(
  String actionId,
  Map<String, String> target,
  AppState state, {
  bool useFallbacks = true,
}) {
  final action = _d2Actions[actionId];
  if (action == null) return const {};
  final fallback = _defaultActionStageTarget(actionId, state);
  final cleaned = <String, String>{};
  for (final field in action.fields) {
    final raw = target[field.key]?.trim();
    if (raw == null || raw.isEmpty) {
      if (!useFallbacks) continue;
      final fallbackValue = fallback[field.key];
      if (fallbackValue != null) cleaned[field.key] = fallbackValue;
      continue;
    }
    final numeric = double.tryParse(raw.replaceAll(',', ''));
    if (numeric == null) {
      cleaned[field.key] = raw;
    } else if (field.isPercent) {
      cleaned[field.key] = numeric.clamp(1, 100).toStringAsFixed(0);
    } else {
      cleaned[field.key] = numeric.clamp(1, 1000000).toStringAsFixed(0);
    }
  }
  final categories = target['categories']?.trim();
  if (categories?.isNotEmpty == true) cleaned['categories'] = categories!;
  return cleaned;
}

void _applyActionStageCategoryBudgets(
  AppState state,
  String actionId,
  Map<String, String> target,
) {
  if (actionId != 'A3') return;
  final amount = double.tryParse(
    (target['amt'] ?? '').replaceAll(',', '').trim(),
  );
  final categories = (target['categories'] ?? '')
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty);
  if (amount == null || amount <= 0 || categories.isEmpty) return;
  for (final category in categories) {
    state.categorySpendingBudgets[category] = amount;
  }
}

/// Gradient "hero" header shown at the top of each individual goal insights
/// page (Available Cash / Emergency Fund / Accumulating Wealth / Financial
/// Freedom), tinted to that goal's assigned color with soft decorative
/// bubbles. `statText` renders as a neutral pill under the title/subtitle
/// (e.g. "2.4 mo. covered", "On track", "+3.1%") — intentionally never
/// tinted green/red so it doesn't read as good/bad news on its own.
class _GoalInsightHeader extends StatelessWidget {
  const _GoalInsightHeader({
    required this.icon,
    required this.title,
    required this.color,
    this.subtitle,
    this.statText,
  });

  final IconData icon;
  final String title;
  final Color color;
  final String? subtitle;
  final String? statText;

  @override
  Widget build(BuildContext context) {
    final deep = Color.lerp(color, Colors.black, .22)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, deep],
            ),
          ),
          // clipBehavior: none lets the bubbles paint past the content's own
          // bounds; the sizing spacer below gives them a full-card canvas to
          // do that on, and the outer ClipRRect trims everything to the
          // rounded card shape so the bubbles reach every edge cleanly.
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const SizedBox(width: double.infinity, height: 118),
              const Positioned(
                left: -26,
                top: -30,
                child: _HeaderBubble(size: 90, alpha: .10),
              ),
              const Positioned(
                left: 88,
                bottom: -38,
                child: _HeaderBubble(size: 62, alpha: .08),
              ),
              const Positioned(
                right: -26,
                top: -36,
                child: _HeaderBubble(size: 104, alpha: .12),
              ),
              const Positioned(
                right: 56,
                bottom: -32,
                child: _HeaderBubble(size: 58, alpha: .09),
              ),
              const Positioned(
                right: -16,
                bottom: -20,
                child: _HeaderBubble(size: 52, alpha: .15),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .20),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .80),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (statText != null) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
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

class _HeaderBubble extends StatelessWidget {
  const _HeaderBubble({required this.size, required this.alpha});
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: alpha),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _CashReflectionExplorer extends StatelessWidget {
  const _CashReflectionExplorer({
    required this.state,
    required this.service,
    required this.selectedMonth,
    required this.onMonthSelected,
    required this.actionStageKey,
  });
  final AppState state;
  final IntegrationService service;
  final DateTime? selectedMonth;
  final ValueChanged<DateTime> onMonthSelected;
  final GlobalKey actionStageKey;

  @override
  Widget build(BuildContext context) {
    final months = _cashMonthsFor(state, service);
    final activeMonth =
        months.where((month) => month.start == selectedMonth).firstOrNull ??
            (months.isEmpty ? null : months.last);

    return Column(
      children: [
        const _GoalInsightHeader(
          icon: Icons.account_balance_wallet_rounded,
          title: 'Available Cash',
          color: _brand,
        ),
        _GoalSuggestionBanner(
          goalLabel: 'available cash',
          allowedActionIds: _availableCashGoalActionIds,
          color: _brand,
          runStage: (coach, state) =>
              coach.recommendAvailableCashActionStage(state: state),
          onViewSuggestions: () {
            final target = actionStageKey.currentContext;
            if (target != null) {
              Scrollable.ensureVisible(
                target,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
        if (activeMonth != null) ...[
          _AvailableCashAnswerCard(
            months: months,
            month: activeMonth,
            selectedMonth: activeMonth.start,
            onMonthSelected: onMonthSelected,
          ),
          _ActionProgressSection(actionScores: activeMonth.actionScores),
          _GoalActionStageSection(
            key: actionStageKey,
            goalId: 'G1',
            goalLabel: 'Maintain Available Cash',
            allowedActionIds: _availableCashGoalActionIds,
            subtitle:
                'Shellby reviews the latest integration data against the Maintain Available Cash action set.',
            emptyMessage:
                'The stage will compare current actions with the Maintain Available Cash action set, then rank what to review first.',
            runStage: (coach, state) =>
                coach.recommendAvailableCashActionStage(state: state),
          ),
        ],
      ],
    );
  }
}

class _CashWeekDetail extends StatelessWidget {
  const _CashWeekDetail({required this.week});
  final WeekRecord week;

  @override
  Widget build(BuildContext context) {
    final transactions = week.days
        .expand((day) => day.transactions)
        .where((transaction) =>
            transaction.isLabeled &&
            !transaction.excludedFromInsights &&
            transaction.source?.toLowerCase() == 'basic needs fund')
        .toList()
      ..sort((a, b) => (b.createdAt ?? DateTime(1970))
          .compareTo(a.createdAt ?? DateTime(1970)));
    final events = week.days.expand((day) => day.events).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final complete = week.days.where((day) => day.fullyClassified).length;

    return _ExplorerSection(
      eyebrow: 'DETAIL · SELECTED WEEK',
      title: '${_shortDate(week.start)}–${_shortDate(week.end)}',
      subtitle:
          '${money(week.weekExpense)} spent · $complete of ${week.days.length} days complete',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WeekContextRow(
            income: week.isSalaryWeek,
            bills: week.isBillWeek,
            interference: week.hadEmergency,
          ),
          const SizedBox(height: 12),
          if (events.isEmpty && transactions.isEmpty)
            const _ReflectionEmpty(
                message: 'No activity was recorded for this week.')
          else ...[
            for (final event in events)
              _ReflectionDetailRow(
                icon: event.type == JarEventType.income
                    ? Icons.south_west_rounded
                    : Icons.receipt_long_rounded,
                color: event.type == JarEventType.income ? _sage : _amber,
                title: event.sentence,
                detail: '${_shortDate(event.timestamp)} · Money event',
                amount: null,
              ),
            for (final transaction in transactions)
              _ReflectionDetailRow(
                icon: transaction.amount >= 0
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded,
                color: transaction.amount >= 0 ? _sage : _brand,
                title: transaction.title,
                detail:
                    '${transaction.category} · ${_shortDate(transaction.createdAt ?? week.start)}',
                amount:
                    '${transaction.amount >= 0 ? '+' : '-'}${money(transaction.amount.abs())}',
              ),
          ],
        ],
      ),
    );
  }
}

/// Suggested minimum monthly Emergency Fund contribution: the user's
/// configured A9 amount if set, otherwise the same recommendation shown
/// during onboarding for that action.
double _emergencyMonthlyContribution(AppState state) {
  final configured = double.tryParse(
    (state.actionFieldValues['A9']?['amt'] ?? '').replaceAll(',', '').trim(),
  );
  if (configured != null && configured > 0) return configured;
  return _emergencyMonthlyDepositBase(state);
}

/// First card on the Emergency Fund insights page: a circular "percent of
/// target" ring on the left, key fund figures on the right.
class _EmergencyFundOverviewCard extends StatelessWidget {
  const _EmergencyFundOverviewCard({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final current = state.displayedEmergencyFundBalance;
    final target = _financialSafetyGoalTarget(state);
    final percent = emergencyFundGoalPercent(state);
    final monthlyContribution = _emergencyMonthlyContribution(state);
    final monthsCovered = state.emergencyMonthsCovered;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _CircularGoalRing(percent: percent, color: _red),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Fund',
                    style: TextStyle(
                      color: _body,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    money(current),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 13),
                  _EmergencyMetricLine(
                    label: '6-Mo. Goal',
                    value: money(target),
                  ),
                  const SizedBox(height: 8),
                  _EmergencyMetricLine(
                    label: 'Monthly +',
                    value: money(monthlyContribution),
                  ),
                  const SizedBox(height: 8),
                  _EmergencyMetricLine(
                    label: 'Mo. Covered',
                    value: '${monthsCovered.toStringAsFixed(1)} mo',
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

class _EmergencyMetricLine extends StatelessWidget {
  const _EmergencyMetricLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _body,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

/// Circular "percent of target" progress ring. The percent label stays
/// black and the "of target" caption grey regardless of the ring color, so
/// it reads as a neutral measurement rather than good/bad news.
class _CircularGoalRing extends StatelessWidget {
  const _CircularGoalRing({
    required this.percent,
    required this.color,
    this.size = 128,
    this.strokeWidth = 13,
  });

  final double percent;
  final Color color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 100.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GoalRingPainter(
              percent: clamped,
              color: color,
              strokeWidth: strokeWidth,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${clamped.round()}%',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'of target',
                style: TextStyle(
                  color: _body,
                  fontSize: 10.5,
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

class _GoalRingPainter extends CustomPainter {
  _GoalRingPainter({
    required this.percent,
    required this.color,
    required this.strokeWidth,
  });

  final double percent;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final track = Paint()
      ..color = _border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    if (percent > 0) {
      final sweep = 2 * math.pi * (percent / 100);
      final progress = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweep,
        false,
        progress,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GoalRingPainter oldDelegate) =>
      oldDelegate.percent != percent || oldDelegate.color != color;
}

/// Coverage Milestones card: progress toward the 3-month minimum safety net
/// and the 6-month recommended coverage, both measured against the same
/// current fund balance.
class _EmergencyMilestonesCard extends StatelessWidget {
  const _EmergencyMilestonesCard({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final current = state.displayedEmergencyFundBalance;
    final essentials = state.monthlyEssentialExpenseTotal;
    final threeMonth =
        essentials > 0 ? essentials * 3 : state.emergencyFundTarget;
    final sixMonth =
        essentials > 0 ? essentials * 6 : state.emergencyFundTarget * 2;
    return _ExplorerSection(
      eyebrow: 'COVERAGE MILESTONES',
      title: 'How far does the fund stretch?',
      subtitle:
          'Progress toward the minimum safety net and the recommended full coverage.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CoverageMilestoneRow(
            title: '3-Month Fund',
            subtitle: 'Minimum safety net',
            current: current,
            target: threeMonth,
          ),
          const SizedBox(height: 18),
          _CoverageMilestoneRow(
            title: '6-Month Fund',
            subtitle: 'Recommended coverage',
            current: current,
            target: sixMonth,
          ),
        ],
      ),
    );
  }
}

class _CoverageMilestoneRow extends StatelessWidget {
  const _CoverageMilestoneRow({
    required this.title,
    required this.subtitle,
    required this.current,
    required this.target,
  });

  final String title;
  final String subtitle;
  final double current;
  final double target;

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _title,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
              '${(progress * 100).round()}%',
              style: const TextStyle(
                color: _title,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ThinBar(value: progress, color: _red),
        const SizedBox(height: 6),
        Text(
          '${money(current)} of ${money(target)}',
          style: const TextStyle(
            color: _body,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─── Accumulating Wealth (G5) insights ─────────────────────────────────────

class _AccumulatingWealthExplorer extends StatelessWidget {
  const _AccumulatingWealthExplorer({
    required this.state,
    required this.selectedMonth,
    required this.onMonthSelected,
    required this.actionStageKey,
  });
  final AppState state;
  final DateTime? selectedMonth;
  final ValueChanged<DateTime> onMonthSelected;
  final GlobalKey actionStageKey;

  @override
  Widget build(BuildContext context) {
    final holdings = state.fakeMayaLink?.summary.investmentHoldings ?? const [];
    final months = _investmentInsightMonths(state);
    final activeMonth =
        months.where((month) => month == selectedMonth).firstOrNull ??
            (months.isEmpty ? _monthStart(DateTime.now()) : months.last);
    final totalValue = state.investmentPortfolioValue;
    final investmentScores =
        _investmentActionScores(state: state, monthStart: activeMonth);

    return Column(
      children: [
        _GoalInsightHeader(
          icon: Icons.trending_up_rounded,
          title: 'Accumulating Wealth',
          color: _purple,
          subtitle: 'Grow your investments',
          statText: '${money(totalValue)} total',
        ),
        _GoalSuggestionBanner(
          goalLabel: 'accumulating wealth',
          allowedActionIds: _investmentGoalActionIds,
          color: _purple,
          runStage: (coach, state) =>
              coach.recommendInvestmentActionStage(state: state),
          onViewSuggestions: () {
            final target = actionStageKey.currentContext;
            if (target != null) {
              Scrollable.ensureVisible(
                target,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
        _PortfolioValueCard(holdings: holdings),
        _InvestmentMetricsGrid(state: state, holdings: holdings),
        _InvestmentHoldingsCard(holdings: holdings),
        _InsightMonthSelector(
          months: months,
          selected: activeMonth,
          onSelected: onMonthSelected,
        ),
        _ActionProgressSection(actionScores: investmentScores),
        _GoalActionStageSection(
          key: actionStageKey,
          goalId: 'G5',
          goalLabel: 'Grow Investments',
          allowedActionIds: _investmentGoalActionIds,
          subtitle:
              'Shellby reviews the latest Investment Portfolio and FakeMaya trading activity against the Grow Investments action set.',
          emptyMessage:
              'The stage will compare current actions with the Grow Investments action set, then rank what to review first.',
          runStage: (coach, state) =>
              coach.recommendInvestmentActionStage(state: state),
        ),
      ],
    );
  }
}

enum _PortfolioRange { oneWeek, oneMonth, threeMonths, sixMonths, oneYear }

extension on _PortfolioRange {
  String get label => switch (this) {
        _PortfolioRange.oneWeek => '1W',
        _PortfolioRange.oneMonth => '1M',
        _PortfolioRange.threeMonths => '3M',
        _PortfolioRange.sixMonths => '6M',
        _PortfolioRange.oneYear => '1Y',
      };
  int get days => switch (this) {
        _PortfolioRange.oneWeek => 7,
        _PortfolioRange.oneMonth => 30,
        _PortfolioRange.threeMonths => 90,
        _PortfolioRange.sixMonths => 180,
        _PortfolioRange.oneYear => 365,
      };
}

class _PortfolioHistoryPoint {
  const _PortfolioHistoryPoint(this.date, this.value);
  final DateTime date;
  final double value;
}

List<DateTime> _investmentInsightMonths(AppState state) {
  final months = <DateTime>{
    ...state.allTransactions
        .where((transaction) => transaction.createdAt != null)
        .map((transaction) => _monthStart(transaction.createdAt!)),
    ...state.d1Ledger
        .map((entry) => DateTime.tryParse(entry['date']?.toString() ?? ''))
        .whereType<DateTime>()
        .map(_monthStart),
    ...(state.fakeMayaLink?.summary.investmentTransactions ??
            const <FakeMayaStockTransaction>[])
        .map((transaction) => transaction.createdAt)
        .whereType<DateTime>()
        .map(_monthStart),
  }.toList()
    ..sort();
  if (months.isEmpty) return [_monthStart(DateTime.now())];
  return months;
}

/// Builds a daily portfolio-value series from FakeMaya's currently-held
/// units and CoinGecko's live historical prices. FakeMaya itself never
/// tracks historical holdings changes, so this approximates "what the
/// current holdings would have been worth" rather than replaying exact
/// past trades - the same simplification FakeMaya's own single-price
/// model already makes.
List<_PortfolioHistoryPoint> _buildPortfolioHistory({
  required Map<String, List<FakeMayaPricePoint>> pricesBySymbol,
  required List<FakeMayaInvestmentHolding> holdings,
}) {
  final held = holdings.where((holding) => holding.units > 0).toList();
  if (held.isEmpty) return const [];
  final allDays = <DateTime>{};
  for (final series in pricesBySymbol.values) {
    for (final point in series) {
      allDays.add(DateTime(point.date.year, point.date.month, point.date.day));
    }
  }
  if (allDays.isEmpty) return const [];
  final sortedDays = allDays.toList()..sort();

  double nearestPrice(List<FakeMayaPricePoint> series, DateTime day) {
    if (series.isEmpty) return 0;
    var best = series.first;
    var bestDiff = series.first.date.difference(day).abs();
    for (final point in series) {
      final diff = point.date.difference(day).abs();
      if (diff < bestDiff) {
        best = point;
        bestDiff = diff;
      }
    }
    return best.price;
  }

  return sortedDays.map((day) {
    var total = 0.0;
    for (final holding in held) {
      final series = pricesBySymbol[holding.symbol] ?? const [];
      total += holding.units * nearestPrice(series, day);
    }
    return _PortfolioHistoryPoint(day, total);
  }).toList();
}

class _PortfolioValueCard extends StatefulWidget {
  const _PortfolioValueCard({required this.holdings});
  final List<FakeMayaInvestmentHolding> holdings;

  @override
  State<_PortfolioValueCard> createState() => _PortfolioValueCardState();
}

class _PortfolioValueCardState extends State<_PortfolioValueCard> {
  _PortfolioRange _range = _PortfolioRange.oneMonth;
  bool _loading = false;
  String? _error;
  List<_PortfolioHistoryPoint> _history = const [];
  _PortfolioHistoryPoint? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _PortfolioValueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_holdingsKey(oldWidget.holdings) != _holdingsKey(widget.holdings)) {
      _load();
    }
  }

  String _holdingsKey(List<FakeMayaInvestmentHolding> holdings) =>
      holdings.map((h) => '${h.symbol}:${h.units}').join(',');

  Future<void> _load() async {
    final held = widget.holdings.where((h) => h.units > 0).toList();
    if (held.isEmpty) {
      setState(() {
        _history = const [];
        _loading = false;
        _error = null;
        _selected = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _selected = null;
    });
    try {
      final prices = await FakeMayaService.loadHistoricalInvestmentPrices(
        days: _range.days,
      );
      if (!mounted) return;
      setState(() {
        _history =
            _buildPortfolioHistory(pricesBySymbol: prices, holdings: held);
        _loading = false;
      });
    } on FakeMayaException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unavailable to load price history right now.';
        _loading = false;
      });
    }
  }

  void _changeRange(_PortfolioRange range) {
    if (range == _range) return;
    setState(() => _range = range);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final held = widget.holdings.where((h) => h.units > 0).toList();
    final currentValue = held.fold<double>(0, (total, h) => total + h.value);
    final startValue = _history.isEmpty ? currentValue : _history.first.value;
    final displayed = _selected ?? (_history.isEmpty ? null : _history.last);
    final displayedValue = displayed?.value ?? currentValue;
    final delta = displayedValue - startValue;
    final deltaPercent = startValue <= 0 ? 0.0 : delta / startValue * 100;
    final positive = delta >= 0;
    final color = positive ? _sage : _red;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PORTFOLIO VALUE',
                        style: TextStyle(
                          color: _body,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        money(displayedValue),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (held.isNotEmpty)
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      positive
                                          ? Icons.arrow_upward_rounded
                                          : Icons.arrow_downward_rounded,
                                      size: 10,
                                      color: color,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${positive ? '+' : '-'}${money(delta.abs())}',
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${positive ? '+' : ''}${deltaPercent.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            if (_selected != null)
                              Text(
                                _shortDate(_selected!.date),
                                style: const TextStyle(
                                  color: _body,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final range in _PortfolioRange.values)
                      _RangeChip(
                        label: range.label,
                        selected: range == _range,
                        onTap: () => _changeRange(range),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (held.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No stock or crypto holdings yet. Buy BTC or NVDA in FakeMaya\'s Crypto page to see performance here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _body,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
              )
            else if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _red,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              )
            else ...[
              _PortfolioLineChart(
                points: _history,
                color: color,
                onPointSelected: (point) => setState(() => _selected = point),
              ),
              if (_history.length >= 2) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_shortDate(_history.first.date),
                        style: const TextStyle(
                            color: _body,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                    Text(_shortDate(_history[_history.length ~/ 2].date),
                        style: const TextStyle(
                            color: _body,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                    Text(_shortDate(_history.last.date),
                        style: const TextStyle(
                            color: _body,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? _title : _bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? _title : _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _body,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

/// A tappable/draggable line chart of portfolio value over time. Dragging
/// or tapping shows a crosshair at the nearest point and reports it via
/// [onPointSelected] (null once released) so the parent card can "zoom in"
/// its header metrics to that point in time.
class _PortfolioLineChart extends StatefulWidget {
  const _PortfolioLineChart({
    required this.points,
    required this.color,
    required this.onPointSelected,
  });
  final List<_PortfolioHistoryPoint> points;
  final Color color;
  final ValueChanged<_PortfolioHistoryPoint?> onPointSelected;

  @override
  State<_PortfolioLineChart> createState() => _PortfolioLineChartState();
}

class _PortfolioLineChartState extends State<_PortfolioLineChart> {
  int? _selectedIndex;

  void _select(Offset localPosition, Size size) {
    if (widget.points.length < 2 || size.width <= 0) return;
    final fraction = (localPosition.dx / size.width).clamp(0.0, 1.0);
    final index = (fraction * (widget.points.length - 1)).round();
    setState(() => _selectedIndex = index);
    widget.onPointSelected(widget.points[index]);
  }

  void _clear() {
    if (_selectedIndex == null) return;
    setState(() => _selectedIndex = null);
    widget.onPointSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.length < 2) {
      return const SizedBox(
        height: 210,
        child: Center(
          child: Text(
            'Not enough price history yet.',
            style: TextStyle(
                color: _body, fontWeight: FontWeight.w700, fontSize: 11.5),
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, 210);
        return GestureDetector(
          onTapDown: (details) => _select(details.localPosition, size),
          onHorizontalDragStart: (details) =>
              _select(details.localPosition, size),
          onHorizontalDragUpdate: (details) =>
              _select(details.localPosition, size),
          onHorizontalDragEnd: (_) => _clear(),
          onTapUp: (_) => _clear(),
          child: SizedBox(
            height: 210,
            width: double.infinity,
            child: CustomPaint(
              painter: _PortfolioLinePainter(
                points: widget.points,
                color: widget.color,
                selectedIndex: _selectedIndex,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PortfolioLinePainter extends CustomPainter {
  _PortfolioLinePainter({
    required this.points,
    required this.color,
    required this.selectedIndex,
  });
  final List<_PortfolioHistoryPoint> points;
  final Color color;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final values = points.map((p) => p.value).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range =
        (maxValue - minValue).abs() < 0.01 ? 1.0 : maxValue - minValue;

    Offset offsetFor(int index) {
      final x =
          points.length <= 1 ? 0.0 : size.width * index / (points.length - 1);
      final y = size.height -
          ((points[index].value - minValue) / range) * size.height;
      return Offset(x, y.clamp(0.0, size.height));
    }

    final linePath = Path();
    final fillPath = Path();
    for (var i = 0; i < points.length; i++) {
      final offset = offsetFor(i);
      if (i == 0) {
        linePath.moveTo(offset.dx, offset.dy);
        fillPath.moveTo(offset.dx, offset.dy);
      } else {
        linePath.lineTo(offset.dx, offset.dy);
        fillPath.lineTo(offset.dx, offset.dy);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: .18), color.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final selected = selectedIndex;
    if (selected != null && selected >= 0 && selected < points.length) {
      final offset = offsetFor(selected);
      final dashPaint = Paint()
        ..color = color.withValues(alpha: .45)
        ..strokeWidth = 1;
      var y = 0.0;
      const dashHeight = 4.0;
      const dashGap = 3.0;
      while (y < size.height) {
        canvas.drawLine(
          Offset(offset.dx, y),
          Offset(offset.dx, math.min(y + dashHeight, size.height)),
          dashPaint,
        );
        y += dashHeight + dashGap;
      }
      canvas.drawCircle(offset, 5, Paint()..color = color);
      canvas.drawCircle(
        offset,
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PortfolioLinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.color != color;
  }
}

class _InvestmentMetricsGrid extends StatefulWidget {
  const _InvestmentMetricsGrid({required this.state, required this.holdings});
  final AppState state;
  final List<FakeMayaInvestmentHolding> holdings;

  @override
  State<_InvestmentMetricsGrid> createState() => _InvestmentMetricsGridState();
}

class _InvestmentMetricsGridState extends State<_InvestmentMetricsGrid> {
  Map<String, FakeMayaAssetQuote>? _quotes;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    try {
      final quotes = await FakeMayaService.loadLiveInvestmentQuotes();
      if (mounted) setState(() => _quotes = quotes);
    } catch (_) {
      // Fall back silently to whatever FakeMaya-reported holding price is
      // already available - a failed live refresh shouldn't block the rest
      // of the page.
    }
  }

  FakeMayaInvestmentHolding? _holdingFor(String symbol) =>
      widget.holdings.where((h) => h.symbol == symbol).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final totalInvested = state.investmentBalance +
        (state.fakeMayaLink?.summary.investmentHoldingsCostBasis ?? 0);
    final tracking = state.investmentReturnBaselineDate != null;
    final annualizedReturn = state.investmentAnnualizedReturnPercent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: [
          _MetricMiniCard(
            label: 'Total Invested',
            value: money(totalInvested),
            icon: Icons.savings_rounded,
            color: _purple,
          ),
          _MetricMiniCard(
            label: 'Annualized Return',
            value: tracking
                ? '${annualizedReturn >= 0 ? '+' : ''}${annualizedReturn.toStringAsFixed(1)}%'
                : 'Not tracking',
            icon: annualizedReturn >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: !tracking ? _body : (annualizedReturn >= 0 ? _sage : _red),
          ),
          _StockPerformanceCard(
            symbol: 'BTC',
            name: 'Bitcoin',
            quote: _quotes?['BTC'],
            holding: _holdingFor('BTC'),
          ),
          _StockPerformanceCard(
            symbol: 'NVDA',
            name: 'NVIDIA',
            quote: _quotes?['NVDA'],
            holding: _holdingFor('NVDA'),
          ),
        ],
      ),
    );
  }
}

class _MetricMiniCard extends StatelessWidget {
  const _MetricMiniCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
                color: _body, fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

/// A dark "market pulse" card for one of FakeMaya's 2 tradeable assets,
/// showing its live price and 24h change regardless of whether the user
/// currently holds it.
class _StockPerformanceCard extends StatelessWidget {
  const _StockPerformanceCard({
    required this.symbol,
    required this.name,
    required this.quote,
    required this.holding,
  });
  final String symbol;
  final String name;
  final FakeMayaAssetQuote? quote;
  final FakeMayaInvestmentHolding? holding;

  @override
  Widget build(BuildContext context) {
    final price = quote?.price ?? holding?.price ?? 0;
    final change = quote?.changePercent24h ?? 0;
    final positive = change >= 0;
    final accent =
        symbol == 'BTC' ? const Color(0xFFF5C518) : const Color(0xFF76B900);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF14101C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                symbol,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              price > 0 ? money(price) : '—',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 4),
          if (price > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  positive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 11,
                  color: positive ? _sage : _red,
                ),
                const SizedBox(width: 2),
                Text(
                  '${change.abs().toStringAsFixed(2)}% 24h',
                  style: TextStyle(
                    color: positive ? _sage : _red,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _InvestmentHoldingsCard extends StatelessWidget {
  const _InvestmentHoldingsCard({required this.holdings});
  final List<FakeMayaInvestmentHolding> holdings;

  @override
  Widget build(BuildContext context) {
    final held = holdings.where((h) => h.units > 0).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HOLDINGS',
              style: TextStyle(
                color: _body,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            if (held.isEmpty)
              const Text(
                'No stock or crypto holdings yet. Buy BTC or NVDA in FakeMaya\'s Crypto page to see them here.',
                style: TextStyle(
                  color: _body,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              )
            else
              for (var i = 0; i < held.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: _border),
                  ),
                _HoldingRow(holding: held[i]),
              ],
          ],
        ),
      ),
    );
  }
}

class _HoldingRow extends StatelessWidget {
  const _HoldingRow({required this.holding});
  final FakeMayaInvestmentHolding holding;

  @override
  Widget build(BuildContext context) {
    final accent = holding.symbol == 'BTC'
        ? const Color(0xFFF5C518)
        : const Color(0xFF76B900);
    final gain = holding.unrealizedGain;
    final gainPercent = holding.unrealizedGainPercent;
    final positive = gain >= 0;
    final hasCostBasis = holding.costBasis > 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3,
          height: 40,
          decoration: BoxDecoration(
              color: accent, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                holding.name,
                style: const TextStyle(
                    color: _title, fontSize: 13.5, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                holding.type == 'crypto' ? 'Crypto' : 'Stock',
                style: const TextStyle(
                    color: _body, fontSize: 10.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              money(holding.value),
              style: const TextStyle(
                  color: _title, fontSize: 13.5, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              hasCostBasis
                  ? '${positive ? '+' : ''}${gainPercent.toStringAsFixed(2)}%'
                  : '—',
              style: TextStyle(
                color: hasCostBasis ? (positive ? _sage : _red) : _body,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Financial Freedom (G8 / Lifestyle Fund) insights ───────────────────────

const _freedomColor = Color(0xFF6AA8F0);

class _FinancialFreedomExplorer extends StatelessWidget {
  const _FinancialFreedomExplorer({
    required this.state,
    required this.actionStageKey,
  });
  final AppState state;
  final GlobalKey actionStageKey;

  @override
  Widget build(BuildContext context) {
    final hobbies = state.lifestyleHobbies;
    final hobbiesSaved = hobbies.fold<double>(
      0,
      (total, hobby) =>
          total + state.lifestyleHobbyBalance(hobby['id'].toString()),
    );
    final totalValue = state.lifestyleFundBalance + hobbiesSaved;
    final lifestyleScores = _lifestyleActionScores(state: state);
    return Column(
      children: [
        _GoalInsightHeader(
          icon: Icons.celebration_rounded,
          title: 'Financial Freedom',
          color: _freedomColor,
          subtitle: 'Enjoy life, on your terms',
          statText: '${money(totalValue)} total',
        ),
        _GoalSuggestionBanner(
          goalLabel: 'financial freedom',
          allowedActionIds: _lifestyleActionStageActionIds,
          color: _freedomColor,
          runStage: (coach, state) =>
              coach.recommendLifestyleActionStage(state: state),
          onViewSuggestions: () {
            final target = actionStageKey.currentContext;
            if (target != null) {
              Scrollable.ensureVisible(
                target,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
        _LifestyleTargetFundsCard(state: state),
        _LifestyleOverviewGrid(state: state),
        _LifestyleWeeklySpendCard(state: state),
        _LifestyleContributionsChart(
          points: _lifestyleMonthlyContributions(state),
          balance: state.lifestyleFundBalance,
        ),
        _ActionProgressSection(actionScores: lifestyleScores),
        _GoalActionStageSection(
          key: actionStageKey,
          goalId: 'G8',
          goalLabel: 'Lifestyle Fund',
          allowedActionIds: _lifestyleActionStageActionIds,
          subtitle:
              'Shellby reviews the latest Personal Lifestyle Fund activity against the Lifestyle Fund action set.',
          emptyMessage:
              'The stage will compare current actions with the Lifestyle Fund action set, then rank what to review first.',
          runStage: (coach, state) =>
              coach.recommendLifestyleActionStage(state: state),
        ),
      ],
    );
  }
}

class _LifestyleTargetFundsCard extends StatelessWidget {
  const _LifestyleTargetFundsCard({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final hobbies = state.lifestyleHobbies;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TARGET FUNDS',
              style: TextStyle(
                color: _body,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hobby and activity progress',
              style: TextStyle(
                color: _title,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            if (hobbies.isEmpty)
              Text(
                'No hobby or activity targets yet. Add up to 3 from the Lifestyle Fund goal in Goals to see progress here.',
                style: TextStyle(
                  color: _body,
                  fontSize: 11.5,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              for (var i = 0; i < hobbies.length; i++) ...[
                _HobbyProgressLine(hobby: hobbies[i], state: state),
                if (i < hobbies.length - 1) const SizedBox(height: 16),
              ],
          ],
        ),
      ),
    );
  }
}

class _HobbyProgressLine extends StatelessWidget {
  const _HobbyProgressLine({required this.hobby, required this.state});
  final Map<String, dynamic> hobby;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final id = hobby['id'].toString();
    final name = (hobby['name'] ?? 'Hobby').toString();
    final target = (hobby['target'] as num?)?.toDouble() ?? 0;
    final months = (hobby['months'] as num?)?.toInt() ?? 6;
    final saved = state.lifestyleHobbyBalance(id);
    final progress = target <= 0 ? 0.0 : (saved / target).clamp(0.0, 1.0);
    final complete = saved >= target && target > 0;
    final started = state.lifestyleHobbyStartedAt(id) ?? DateTime.now();
    final due = DateTime(started.year, started.month + months, started.day);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: _title,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              complete ? 'Funded' : 'By ${_shortDate(due)}',
              style: TextStyle(
                color: complete ? _sage : _body,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _LabeledProgressBar(
          value: progress,
          color: complete ? _sage : _freedomColor,
          leadingLabel: money(saved),
          trailingLabel: money(target),
        ),
      ],
    );
  }
}

class _LifestyleOverviewGrid extends StatelessWidget {
  const _LifestyleOverviewGrid({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final target = _configuredActionAmount(
      state,
      'A26',
      _monthlySubscriptionBase(state),
    );
    final reserved = state.lifestyleReservedThisMonth;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: _MetricMiniCard(
              label: 'Subscriptions this month',
              value: '${money(reserved)} / ${money(target)}',
              icon: Icons.subscriptions_rounded,
              color: _freedomColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MetricMiniCard(
              label: 'Personal Lifestyle Fund',
              value: money(state.lifestyleFundBalance),
              icon: Icons.account_balance_wallet_rounded,
              color: _freedomColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LifestyleWeeklySpendCard extends StatelessWidget {
  const _LifestyleWeeklySpendCard({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final limit = _configuredActionAmount(state, 'A28', 1500);
    final spent = _currentWeekLifestyleSpend(state);
    final over = spent > limit;
    final progress = limit <= 0 ? 1.0 : (spent / limit);
    final color = over ? _red : _freedomColor;
    final pastWeeks = [
      for (var i = 3; i >= 0; i--) _lifestyleSpendForCompletedWeek(state, i),
    ];
    final maxWeek = [...pastWeeks, spent, limit].fold<double>(1, math.max);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EVERYDAY ENJOYMENT',
              style: TextStyle(
                color: _body,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  money(spent),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'of ${money(limit)} this week',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _body,
                      fontSize: 11,
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
                value: progress.clamp(0.0, 1.0),
                minHeight: 9,
                color: color,
                backgroundColor: color.withValues(alpha: .12),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              over
                  ? '${money(spent - limit)} over the weekly limit - no pressure, just something to notice.'
                  : '${money(math.max(0.0, limit - spent))} left in this week\'s enjoyment budget.',
              style: TextStyle(
                color: over ? _red : _body,
                fontSize: 10.5,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < pastWeeks.length; i++)
                  Expanded(
                    child: _WeeklySpendBar(
                      label: '${pastWeeks.length - i}w ago',
                      value: pastWeeks[i],
                      limit: limit,
                      maxValue: maxWeek,
                    ),
                  ),
                Expanded(
                  child: _WeeklySpendBar(
                    label: 'This wk',
                    value: spent,
                    limit: limit,
                    maxValue: maxWeek,
                    emphasize: true,
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

class _WeeklySpendBar extends StatelessWidget {
  const _WeeklySpendBar({
    required this.label,
    required this.value,
    required this.limit,
    required this.maxValue,
    this.emphasize = false,
  });
  final String label;
  final double value;
  final double limit;
  final double maxValue;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final over = limit > 0 && value > limit;
    final color = over ? _red : _freedomColor;
    final height = 56 * (value / maxValue).clamp(0.03, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 56,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: emphasize ? 1 : .45),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: emphasize ? _title : _body,
              fontSize: 9.5,
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LifestyleContributionsChart extends StatelessWidget {
  const _LifestyleContributionsChart({
    required this.points,
    required this.balance,
  });
  final List<_MonthlyContributionPoint> points;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final maxValue = points.map((p) => p.amount).fold<double>(1, math.max);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PERSONAL LIFESTYLE FUND',
              style: TextStyle(
                color: _body,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              money(balance),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Monthly contributions',
              style: TextStyle(
                color: _body,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final point in points)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 78 *
                                  (point.amount / maxValue).clamp(0.02, 1.0),
                              decoration: BoxDecoration(
                                color: _freedomColor.withValues(
                                  alpha: point.amount > 0 ? 1 : .15,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              point.label,
                              style: const TextStyle(
                                color: _body,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _EmergencyReflectionExplorer extends StatelessWidget {
  const _EmergencyReflectionExplorer({
    required this.state,
    required this.service,
    required this.selectedMonth,
    required this.onMonthSelected,
    required this.selectedWeek,
    required this.onWeekSelected,
    required this.actionStageKey,
  });
  final AppState state;
  final IntegrationService service;
  final DateTime? selectedMonth;
  final ValueChanged<DateTime> onMonthSelected;
  final DateTime? selectedWeek;
  final ValueChanged<DateTime> onWeekSelected;
  final GlobalKey actionStageKey;

  @override
  Widget build(BuildContext context) {
    final activity = _emergencyReflectionActivity(state);
    final starts = <DateTime>{
      ...service.weekRecords.map((week) => week.start),
      ...activity.map((item) => _mondayOf(item.date)),
    }.toList()
      ..sort();
    final allWeeks = starts.map((start) {
      final items =
          activity.where((item) => _mondayOf(item.date) == start).toList();
      return _EmergencyReflectionWeek(
        start: start,
        added: items
            .where((item) => item.add)
            .fold(0.0, (sum, item) => sum + item.amount),
        used: items
            .where((item) => !item.add)
            .fold(0.0, (sum, item) => sum + item.amount),
        activity: items,
        coverage: service.weekRecords
                .where((week) => week.start == start)
                .firstOrNull
                ?.propDaysClassified ??
            0,
      );
    }).toList();
    final months = <DateTime>{
      ...allWeeks.map((week) => _monthStart(week.start)),
      ...activity.map((item) => _monthStart(item.date)),
      ...state.allTransactions
          .where((transaction) => transaction.createdAt != null)
          .map((transaction) => _monthStart(transaction.createdAt!)),
      ...state.d1Ledger
          .map((entry) => DateTime.tryParse(entry['date']?.toString() ?? ''))
          .whereType<DateTime>()
          .map(_monthStart),
    }.toList()
      ..sort();
    final activeMonth =
        months.where((month) => month == selectedMonth).firstOrNull ??
            (months.isEmpty ? _monthStart(DateTime.now()) : months.last);
    final weeks =
        allWeeks.where((week) => _sameMonth(week.start, activeMonth)).toList();
    final monthWeekRecords = service.weekRecords
        .where((week) => _sameMonth(week.start, activeMonth))
        .toList();
    final selected =
        weeks.where((week) => week.start == selectedWeek).firstOrNull ??
            (weeks.isEmpty ? null : weeks.last);
    final monthlyEssentials = state.monthlyEssentialExpenseTotal;
    final target = _financialSafetyGoalTarget(state);
    final monthIncome = state.allTransactions
        .where((transaction) =>
            transaction.amount > 0 &&
            !transaction.isInternalFakeMayaTransfer &&
            transaction.createdAt != null &&
            _sameMonth(transaction.createdAt!, activeMonth))
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    final monthTransactions = state.allTransactions
        .where((transaction) =>
            transaction.createdAt != null &&
            _sameMonth(transaction.createdAt!, activeMonth))
        .toList();
    final efScores = _emergencyFundActionScores(
      state: state,
      monthStart: activeMonth,
      weeks: monthWeekRecords,
      transactions: monthTransactions,
      income: monthIncome,
    );

    return Column(
      children: [
        _GoalInsightHeader(
          icon: Icons.shield_rounded,
          title: 'Emergency Fund',
          color: _red,
          subtitle: 'Build a safety net',
          statText:
              '${state.emergencyMonthsCovered.toStringAsFixed(1)} mo. covered',
        ),
        _GoalSuggestionBanner(
          goalLabel: 'emergency fund',
          allowedActionIds: _emergencyFundGoalActionIds,
          color: _red,
          runStage: (coach, state) =>
              coach.recommendEmergencyFundActionStage(state: state),
          onViewSuggestions: () {
            final target = actionStageKey.currentContext;
            if (target != null) {
              Scrollable.ensureVisible(
                target,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
        _EmergencyFundOverviewCard(state: state),
        _EmergencyMilestonesCard(state: state),
        _InsightMonthSelector(
          months: months,
          selected: activeMonth,
          onSelected: onMonthSelected,
        ),
        _ReflectionQuestion(
          question:
              'When did my emergency fund change in ${_monthLabel(activeMonth)}, and which events explain the change?',
          detail:
              'The chart below answers this for the selected month: additions and use are broken out week by week so you can see exactly when the fund moved.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Emergency fund movement',
                style: TextStyle(
                  color: _title,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_monthLabel(activeMonth)} activity · ${money(state.displayedEmergencyFundBalance)} saved toward ${money(target)} overall.',
                style: const TextStyle(
                  color: _body,
                  fontSize: 11,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _EmergencyMovementImpactSummary(
                weeks: weeks,
                selected: selected,
                goalTarget: target,
                currentBalance: state.displayedEmergencyFundBalance,
              ),
              const SizedBox(height: 14),
              _SelectableWeeklyChart(
                weeks: weeks
                    .map((week) => _WeeklyChartItem(
                          start: week.start,
                          value: week.added,
                          comparisonValue: week.used,
                          coverage: week.coverage,
                        ))
                    .toList(),
                selected: selected?.start,
                primaryLabel: 'Added',
                comparisonLabel: 'Used',
                primaryColor: _sage,
                comparisonColor: _red,
                onSelected: onWeekSelected,
              ),
              const SizedBox(height: 14),
              if (selected == null)
                const _ReflectionEmpty(
                  message:
                      'Select a week to review its Emergency Fund records.',
                )
              else
                _EmergencyWeekRecordList(week: selected),
            ],
          ),
        ),
        _ActionProgressSection(actionScores: efScores),
        _GoalActionStageSection(
          key: actionStageKey,
          goalId: 'G3',
          goalLabel: 'Build Emergency Fund',
          allowedActionIds: _emergencyFundGoalActionIds,
          subtitle:
              'Shellby reviews the latest Emergency Fund activity against the Build Emergency Fund action set.',
          emptyMessage:
              'The stage will compare current actions with the Build Emergency Fund action set, then rank what to review first.',
          runStage: (coach, state) =>
              coach.recommendEmergencyFundActionStage(state: state),
        ),
      ],
    );
  }
}

class _EmergencyMovementImpactSummary extends StatelessWidget {
  const _EmergencyMovementImpactSummary({
    required this.weeks,
    required this.selected,
    required this.goalTarget,
    required this.currentBalance,
  });

  final List<_EmergencyReflectionWeek> weeks;
  final _EmergencyReflectionWeek? selected;
  final double goalTarget;
  final double currentBalance;

  @override
  Widget build(BuildContext context) {
    final added = weeks.fold<double>(0, (sum, week) => sum + week.added);
    final used = weeks.fold<double>(0, (sum, week) => sum + week.used);
    final net = added - used;
    final selectedNet =
        selected == null ? 0.0 : selected!.added - selected!.used;
    final gap = math.max(0.0, goalTarget - currentBalance);
    final selectedText = selected == null
        ? 'No week selected'
        : '${_shortDate(selected!.start)} week: ${selectedNet >= 0 ? '+' : '-'}${money(selectedNet.abs())} net';
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _EmergencyMovementMetric(
          label: 'Month net',
          value: '${net >= 0 ? '+' : '-'}${money(net.abs())}',
          color: net >= 0 ? _sage : _red,
        ),
        _EmergencyMovementMetric(
          label: 'Added',
          value: money(added),
          color: _sage,
        ),
        _EmergencyMovementMetric(
          label: 'Used',
          value: money(used),
          color: used > 0 ? _red : _body,
        ),
        _EmergencyMovementMetric(
          label: '6-mo gap',
          value: money(gap),
          color: gap <= 0 ? _sage : _amber,
        ),
        _EmergencyMovementMetric(
          label: 'Selected',
          value: selectedText,
          color: selectedNet >= 0 ? _sage : _red,
          wide: true,
        ),
      ],
    );
  }
}

class _EmergencyMovementMetric extends StatelessWidget {
  const _EmergencyMovementMetric({
    required this.label,
    required this.value,
    required this.color,
    this.wide = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: wide ? 208 : 100,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: .18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _body,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: wide ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: wide ? 11 : 12,
                height: 1.2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyReflectionWeek {
  const _EmergencyReflectionWeek({
    required this.start,
    required this.added,
    required this.used,
    required this.activity,
    required this.coverage,
  });
  final DateTime start;
  final double added;
  final double used;
  final List<_EmergencyReflectionItem> activity;
  final double coverage;
}

class _EmergencyReflectionItem {
  const _EmergencyReflectionItem({
    required this.title,
    required this.detail,
    required this.amount,
    required this.date,
    required this.add,
  });
  final String title;
  final String detail;
  final double amount;
  final DateTime date;
  final bool add;
}

List<_EmergencyReflectionItem> _emergencyReflectionActivity(AppState state) {
  final activity = <_EmergencyReflectionItem>[];
  final recordedTransactionIds = <String>{};
  final transactionsById = {
    for (final transaction in state.allTransactions)
      transaction.transactionId: transaction,
  };
  for (final entry in state.d1Ledger) {
    final type = entry['type']?.toString();
    if (!const {
      'emergency_deposit',
      'use_emergency',
      'ef_replenish',
    }.contains(type)) {
      continue;
    }
    final date = DateTime.tryParse(entry['date']?.toString() ?? '');
    if (date == null) continue;
    final transactionId = entry['sourceTransactionId']?.toString();
    if (transactionId != null) recordedTransactionIds.add(transactionId);
    final transaction =
        transactionId == null ? null : transactionsById[transactionId];
    final transactionDetail = transaction == null
        ? null
        : [
            if ((transaction.category ?? '').trim().isNotEmpty)
              transaction.category!.trim(),
            if ((transaction.source ?? '').trim().isNotEmpty)
              transaction.source!.trim(),
            transaction.detail,
          ].where((part) => part.trim().isNotEmpty).join(' · ');
    activity.add(_EmergencyReflectionItem(
      title: switch (type) {
        'emergency_deposit' => transaction?.title ?? 'Income contribution',
        'ef_replenish' => 'Fund replenished',
        _ => transaction?.title ?? 'Emergency fund used',
      },
      detail: switch (type) {
        'emergency_deposit' => transactionDetail ?? 'Scheduled contribution',
        'ef_replenish' => 'Previous withdrawal restored',
        _ => transactionDetail ?? 'Withdrawal',
      },
      amount: (entry['amount'] as num?)?.toDouble() ?? 0,
      date: date,
      add: type != 'use_emergency',
    ));
  }
  for (final transaction in state.allTransactions) {
    if (!transaction.isLabeled ||
        transaction.excludedFromInsights ||
        transaction.source?.toLowerCase() != 'emergency fund') {
      continue;
    }
    if (recordedTransactionIds.contains(transaction.transactionId)) continue;
    final date = transaction.createdAt ?? transaction.labeledAt;
    if (date == null) continue;
    activity.add(_EmergencyReflectionItem(
      title: transaction.title,
      detail: transaction.category ?? 'Emergency fund activity',
      amount: transaction.amount.abs(),
      date: date,
      add: transaction.amount >= 0,
    ));
  }
  activity.sort((a, b) => b.date.compareTo(a.date));
  return activity;
}

class _EmergencyWeekDetail extends StatelessWidget {
  const _EmergencyWeekDetail({required this.week});
  final _EmergencyReflectionWeek week;

  @override
  Widget build(BuildContext context) {
    final end = week.start.add(const Duration(days: 6));
    return _ExplorerSection(
      eyebrow: 'DETAIL · SELECTED WEEK',
      title: '${_shortDate(week.start)}–${_shortDate(end)}',
      subtitle:
          '${money(week.added)} added · ${money(week.used)} used · ${(week.coverage * 100).round()}% data coverage',
      child: week.activity.isEmpty
          ? const _ReflectionEmpty(
              message: 'No emergency fund movement was recorded this week.')
          : Column(
              children: [
                for (final item in week.activity)
                  _ReflectionDetailRow(
                    icon: item.add
                        ? Icons.south_west_rounded
                        : Icons.north_east_rounded,
                    color: item.add ? _sage : _red,
                    title: item.title,
                    detail: '${item.detail} · ${_shortDate(item.date)}',
                    amount: '${item.add ? '+' : '-'}${money(item.amount)}',
                  ),
              ],
            ),
    );
  }
}

class _EmergencyWeekRecordList extends StatelessWidget {
  const _EmergencyWeekRecordList({required this.week});
  final _EmergencyReflectionWeek week;

  @override
  Widget build(BuildContext context) {
    final end = week.start.add(const Duration(days: 6));
    final records = week.activity.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: _border),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                'Records behind ${_shortDate(week.start)}-${_shortDate(end)}',
                style: const TextStyle(
                  color: _title,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${money(week.added)} in · ${money(week.used)} out',
              style: const TextStyle(
                color: _body,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (records.isEmpty)
          const _ReflectionEmpty(
            message: 'No Emergency Fund records were found for this week.',
          )
        else
          for (final item in records)
            _ReflectionDetailRow(
              icon: item.add
                  ? Icons.south_west_rounded
                  : Icons.north_east_rounded,
              color: item.add ? _sage : _red,
              title: item.title,
              detail: '${item.detail} · ${_shortDate(item.date)}',
              amount: '${item.add ? '+' : '-'}${money(item.amount)}',
            ),
      ],
    );
  }
}

DateTime _mondayOf(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

class _WeeklyChartItem {
  const _WeeklyChartItem({
    required this.start,
    required this.value,
    required this.comparisonValue,
    required this.coverage,
    this.isIncomeWeek = false,
    this.isBillWeek = false,
    this.hadInterference = false,
  });
  final DateTime start;
  final double value;
  final double comparisonValue;
  final double coverage;
  final bool isIncomeWeek;
  final bool isBillWeek;
  final bool hadInterference;
}

class _DistributionStats {
  const _DistributionStats({
    required this.min,
    required this.median,
    required this.max,
    required this.mean,
    required this.stdDev,
    required this.mode,
  });

  final double min;
  final double median;
  final double max;
  final double mean;
  final double stdDev;
  final double? mode;
}

_DistributionStats? _distributionStats(List<double> rawValues) {
  final values = rawValues
      .where((value) => value.isFinite)
      .map((value) => value < 0 ? value.abs() : value)
      .toList()
    ..sort();
  if (values.isEmpty) return null;
  final mean =
      values.fold<double>(0, (sum, value) => sum + value) / values.length;
  final variance = values.fold<double>(
        0,
        (sum, value) => sum + math.pow(value - mean, 2).toDouble(),
      ) /
      values.length;
  return _DistributionStats(
    min: values.first,
    median: _percentile(values, .5),
    max: values.last,
    mean: mean,
    stdDev: math.sqrt(variance),
    mode: _mode(values),
  );
}

double _percentile(List<double> sortedValues, double percentile) {
  if (sortedValues.length == 1) return sortedValues.first;
  final position = (sortedValues.length - 1) * percentile;
  final lower = position.floor();
  final upper = position.ceil();
  if (lower == upper) return sortedValues[lower];
  final weight = position - lower;
  return sortedValues[lower] +
      (sortedValues[upper] - sortedValues[lower]) * weight;
}

double? _mode(List<double> sortedValues) {
  final counts = <int, int>{};
  for (final value in sortedValues) {
    final rounded = value.round();
    counts[rounded] = (counts[rounded] ?? 0) + 1;
  }
  var bestValue = 0;
  var bestCount = 0;
  for (final entry in counts.entries) {
    if (entry.value > bestCount) {
      bestValue = entry.key;
      bestCount = entry.value;
    }
  }
  return bestCount <= 1 ? null : bestValue.toDouble();
}

class _SelectableWeeklyChartWithStats extends StatelessWidget {
  const _SelectableWeeklyChartWithStats({
    required this.weeks,
    required this.selected,
    required this.primaryLabel,
    required this.comparisonLabel,
    required this.primaryColor,
    required this.onSelected,
  });

  final List<_WeeklyChartItem> weeks;
  final DateTime? selected;
  final String primaryLabel;
  final String comparisonLabel;
  final Color primaryColor;
  Color get comparisonColor => _purple;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final availableValues = weeks
        .where((week) => week.coverage > 0)
        .map((week) => week.value)
        .toList();
    final stats = _distributionStats(availableValues);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SelectableWeeklyChart(
          weeks: weeks,
          selected: selected,
          primaryLabel: primaryLabel,
          comparisonLabel: comparisonLabel,
          primaryColor: primaryColor,
          comparisonColor: comparisonColor,
          onSelected: onSelected,
        ),
        if (stats != null) ...[
          const SizedBox(height: 14),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 12),
          const Text(
            'Monthly weekly spending measures',
            style: TextStyle(
              color: _title,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          _StatsGrid(
            stats: stats,
            valueFormatter: money,
            modeEmptyLabel: 'No repeat',
          ),
        ],
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.stats,
    required this.valueFormatter,
    required this.modeEmptyLabel,
  });

  final _DistributionStats stats;
  final String Function(double value) valueFormatter;
  final String modeEmptyLabel;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Mean', valueFormatter(stats.mean)),
      ('Median', valueFormatter(stats.median)),
      (
        'Mode',
        stats.mode == null ? modeEmptyLabel : valueFormatter(stats.mode!)
      ),
      ('Std dev', valueFormatter(stats.stdDev)),
      ('Min', valueFormatter(stats.min)),
      ('Max', valueFormatter(stats.max)),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          SizedBox(
            width: 96,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _bellySoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$1,
                    style: const TextStyle(
                      color: _body,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _title,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SelectableWeeklyChart extends StatelessWidget {
  const _SelectableWeeklyChart({
    required this.weeks,
    required this.selected,
    required this.primaryLabel,
    required this.comparisonLabel,
    required this.primaryColor,
    required this.onSelected,
    this.comparisonColor = _purple,
  });
  final List<_WeeklyChartItem> weeks;
  final DateTime? selected;
  final String primaryLabel;
  final String comparisonLabel;
  final Color primaryColor;
  final Color comparisonColor;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    if (weeks.isEmpty) {
      return const SizedBox(
        height: 190,
        child: _ReflectionEmpty(message: 'No weekly data is available yet.'),
      );
    }
    final visible =
        weeks.length > 14 ? weeks.sublist(weeks.length - 14) : weeks;
    final maxValue = visible.fold<double>(
      1,
      (largest, week) =>
          math.max(largest, math.max(week.value, week.comparisonValue)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 7,
          children: [
            _ChartLegend(color: primaryColor, label: primaryLabel),
            _ChartLegend(color: comparisonColor, label: comparisonLabel),
            const _ChartLegend(color: _border, label: 'Missing data'),
            if (visible.any((week) => week.isIncomeWeek))
              const _ContextLegend(
                  icon: Icons.payments_rounded, label: 'Income'),
            if (visible.any((week) => week.isBillWeek))
              const _ContextLegend(
                  icon: Icons.receipt_long_rounded, label: 'Bills'),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 196,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 46,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(money(maxValue), style: _chartAxisStyle),
                    Text(money(maxValue / 2), style: _chartAxisStyle),
                    const Text('₱0', style: _chartAxisStyle),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, reversedIndex) {
                    final index = visible.length - 1 - reversedIndex;
                    final week = visible[index];
                    return _SelectableWeekBars(
                      week: week,
                      maxValue: maxValue,
                      selected: selected == week.start ||
                          (selected == null && index == visible.length - 1),
                      primaryColor: primaryColor,
                      comparisonColor: comparisonColor,
                      onTap: () => onSelected(week.start),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap a week to highlight it.',
          style: TextStyle(
            color: _body,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

const _chartAxisStyle = TextStyle(
  color: _body,
  fontSize: 9,
  fontWeight: FontWeight.w800,
);

class _SelectableWeekBars extends StatelessWidget {
  const _SelectableWeekBars({
    required this.week,
    required this.maxValue,
    required this.selected,
    required this.primaryColor,
    required this.comparisonColor,
    required this.onTap,
  });
  final _WeeklyChartItem week;
  final double maxValue;
  final bool selected;
  final Color primaryColor;
  final Color comparisonColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final missing = week.coverage <= 0;
    return Semantics(
      button: true,
      selected: selected,
      label:
          'Week of ${_shortDate(week.start)}, ${money(week.value)} and ${money(week.comparisonValue)}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 54,
          padding: const EdgeInsets.fromLTRB(5, 7, 5, 5),
          decoration: BoxDecoration(
            color: selected ? _bellySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? _title : Colors.transparent,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 18,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (week.isIncomeWeek)
                      const Icon(Icons.payments_rounded,
                          size: 13, color: _sage),
                    if (week.isBillWeek)
                      const Icon(Icons.receipt_long_rounded,
                          size: 13, color: _amber),
                    if (week.hadInterference)
                      const Icon(Icons.info_outline_rounded,
                          size: 13, color: _red),
                  ],
                ),
              ),
              Expanded(
                child: missing
                    ? Container(
                        width: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: _border),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const RotatedBox(
                          quarterTurns: 3,
                          child: Text('NO DATA', style: _chartAxisStyle),
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _VerticalBar(
                            value: week.value / maxValue,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 4),
                          _VerticalBar(
                            value: week.comparisonValue / maxValue,
                            color: comparisonColor,
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 5),
              Text(
                _shortDate(week.start),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? _title : _body,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalBar extends StatelessWidget {
  const _VerticalBar({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: value.clamp(.025, 1.0),
        child: Container(
          width: 13,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
      ),
    );
  }
}

class _ExplorerSection extends StatelessWidget {
  const _ExplorerSection({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: const TextStyle(
                color: _purple,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                color: _title,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: _body,
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 15),
            child,
          ],
        ),
      ),
    );
  }
}

class _WeekContextRow extends StatelessWidget {
  const _WeekContextRow({
    required this.income,
    required this.bills,
    required this.interference,
  });
  final bool income;
  final bool bills;
  final bool interference;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        if (income)
          const _ReflectionContextChip(
              icon: Icons.payments_rounded, label: 'Income week', color: _sage),
        if (bills)
          const _ReflectionContextChip(
              icon: Icons.receipt_long_rounded,
              label: 'Bill week',
              color: _amber),
        if (interference)
          const _ReflectionContextChip(
              icon: Icons.info_outline_rounded,
              label: 'Noticeable event',
              color: _red),
        if (!income && !bills && !interference)
          const Text(
            'No income, bill, or emergency context recorded.',
            style: TextStyle(
                color: _body, fontSize: 11, fontWeight: FontWeight.w700),
          ),
      ],
    );
  }
}

class _ReflectionContextChip extends StatelessWidget {
  const _ReflectionContextChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _ContextLegend extends StatelessWidget {
  const _ContextLegend({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _body, size: 12),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: _body, fontSize: 10, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _ReflectionDetailRow extends StatelessWidget {
  const _ReflectionDetailRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
    required this.amount,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final String? amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: _title,
                        fontSize: 12,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(detail,
                    style: const TextStyle(
                        color: _body,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          if (amount != null) ...[
            const SizedBox(width: 8),
            Text(amount!,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w900)),
          ],
        ],
      ),
    );
  }
}

class _ExplorerEmpty extends StatelessWidget {
  const _ExplorerEmpty();

  @override
  Widget build(BuildContext context) {
    return const _ExplorerSection(
      eyebrow: 'DETAIL',
      title: 'No week selected',
      subtitle: 'Weekly detail will appear once activity has been recorded.',
      child: _ReflectionEmpty(message: 'No activity is available yet.'),
    );
  }
}

class _ReflectionCoverageBanner extends StatelessWidget {
  const _ReflectionCoverageBanner({required this.service});
  final IntegrationService service;

  @override
  Widget build(BuildContext context) {
    final tracked =
        service.dayRecords.where((day) => day.fullyClassified).length;
    final total = service.dayRecords.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bellySoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            const Icon(Icons.fact_check_rounded, color: _purple, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$tracked of $total days fully tracked - cash is manual and may be under-counted.',
                style: const TextStyle(
                  color: _title,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JarTimelineSection extends StatelessWidget {
  const _JarTimelineSection({required this.service});
  final IntegrationService service;

  @override
  Widget build(BuildContext context) {
    final weeks = service.weekRecords;
    final hasRange = weeks.length >= 6;
    final spendValues = weeks.map((week) => week.avgSpendPerDay).toList();
    final avg = spendValues.isEmpty
        ? 0.0
        : spendValues.reduce((a, b) => a + b) / spendValues.length;
    final variance = spendValues.isEmpty
        ? 0.0
        : spendValues
                .map((value) => math.pow(value - avg, 2).toDouble())
                .reduce((a, b) => a + b) /
            spendValues.length;
    final usualHigh = avg + math.sqrt(variance);

    return _ReflectionSection(
      title: 'Jar Timeline',
      caption:
          'Weekly ending balances in pesos. Shaded columns mark income or bill weeks; gaps mean no synced data was available.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reflection question: How do jar balances move across income,
          // bill, and unusual weeks? Insight types: trend + event/context + anomaly.
          SizedBox(
            height: 210,
            child: weeks.isEmpty
                ? const _ReflectionEmpty(message: 'No jar weeks tracked yet.')
                : CustomPaint(
                    painter: _JarTimelinePainter(
                      weeks: weeks,
                      targetNeeds: service.needsTarget,
                      targetBuffer: service.bufferTarget,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: weeks.map((week) {
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => _showWeekDetail(context, week),
                            child: const SizedBox.expand(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 14,
            runSpacing: 7,
            children: [
              _ChartLegend(color: _brand, label: 'Needs balance'),
              _ChartLegend(color: _purple, label: 'Buffer balance'),
              _ChartLegend(color: _amber, label: 'Bill week'),
              _ChartLegend(color: _sage, label: 'Income week'),
            ],
          ),
          if (hasRange)
            ...weeks
                .where((week) => week.avgSpendPerDay > usualHigh)
                .take(2)
                .map(
                  (week) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _NeutralNotice(
                      label:
                          'Noticeable change - tap to review ${_shortDate(week.start)}',
                      onTap: () => _showWeekDetail(context, week),
                    ),
                  ),
                )
          else
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'At least 6 weeks are needed before showing trend notes.',
                style: TextStyle(
                  color: _body,
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

class _SpendComparisonSection extends StatelessWidget {
  const _SpendComparisonSection({
    required this.service,
    required this.filter,
    required this.onFilterChanged,
  });
  final IntegrationService service;
  final String? filter;
  final ValueChanged<String?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final afterIncome = <DayRecord>[];
    final beforeNext = <DayRecord>[];
    for (final week in service.weekRecords) {
      for (final day in week.days) {
        if (day.date.difference(week.start).inDays <= 2) {
          afterIncome.add(day);
        } else if (day.date.difference(week.start).inDays >= 4) {
          beforeNext.add(day);
        }
      }
    }
    double average(List<DayRecord> days) => days.isEmpty
        ? 0
        : days.fold(0.0, (sum, day) => sum + day.expenseTotal) / days.length;
    final afterValue = average(afterIncome);
    final beforeValue = average(beforeNext);
    final filtered = (filter == 'after' ? afterIncome : beforeNext)
        .expand((day) => day.transactions)
        .where((transaction) =>
            transaction.amount < 0 &&
            transaction.isLabeled &&
            transaction.source?.toLowerCase() == 'basic needs fund')
        .take(8)
        .toList();

    return _ReflectionSection(
      title: 'Spend Comparison',
      caption:
          'Compare average pesos per day, not stacked totals, so shorter and longer segments stay readable.',
      child: Column(
        children: [
          // Reflection question: How does average daily spending compare after
          // income versus before the next income? Insight type: comparison.
          _ComparisonBars(
            leftLabel: 'After income',
            rightLabel: 'Before next income',
            leftValue: afterValue,
            rightValue: beforeValue,
            selected: filter,
            onSelected: onFilterChanged,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              filter == null
                  ? 'Tap a bar to review matching activity.'
                  : 'Showing ${filter == 'after' ? 'after-income' : 'before-next-income'} activity',
              style: const TextStyle(
                color: _body,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (filter != null) ...[
            const SizedBox(height: 8),
            for (final transaction in filtered)
              TransactionRow(
                transaction.title,
                transaction.category ?? 'Unclassified',
                _shortDate(transaction.createdAt ?? DateTime.now()),
                money(transaction.amount.abs()),
                transaction.amount > 0 &&
                    !transaction.isInternalFakeMayaTransfer,
              ),
          ],
        ],
      ),
    );
  }
}

class _GoalVsActualSection extends StatelessWidget {
  const _GoalVsActualSection({required this.service});
  final IntegrationService service;

  @override
  Widget build(BuildContext context) {
    final latest =
        service.weekRecords.isEmpty ? null : service.weekRecords.last;
    final needs = latest?.needsBalanceEnd ?? 0;
    final buffer = latest?.bufferBalanceEnd ?? 0;
    return _ReflectionSection(
      title: 'Goal vs Actual per Jar',
      caption:
          'Read each jar separately: target and current balance are paired so one jar does not hide the other.',
      child: Column(
        children: [
          // Reflection question: Where is each jar relative to its own target?
          // Insight type: goal-related.
          _GoalPairBar(
            label: 'Needs',
            target: service.needsTarget,
            current: needs,
            color: _brand,
          ),
          const SizedBox(height: 14),
          _GoalPairBar(
            label: 'Buffer',
            target: service.bufferTarget,
            current: buffer,
            color: _purple,
          ),
        ],
      ),
    );
  }
}

class _DataTrustSection extends StatelessWidget {
  const _DataTrustSection({required this.service});
  final IntegrationService service;

  @override
  Widget build(BuildContext context) {
    return _ReflectionSection(
      title: 'Data Trust',
      caption:
          'This calendar shows how much information supports each day in the charts. A date with no activity is kept separate from a recorded zero.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reflection question: How complete is the data behind the charts?
          // Insight type: data quality/missingness.
          _CoverageGrid(days: service.dayRecords),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _CoverageLegend(
                  color: _brand, label: 'Complete: synced and labeled'),
              _CoverageLegend(
                  color: _purple, label: 'Inferred: jar activity only'),
              _CoverageLegend(
                  color: _border, label: 'Missing: no synced activity'),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmergencyGoalOverview extends StatelessWidget {
  const _EmergencyGoalOverview({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final monthlyEssentials = state.monthlyEssentialExpenseTotal;
    final current = state.displayedEmergencyFundBalance;
    final target = _financialSafetyGoalTarget(state);
    final months = monthlyEssentials > 0 ? current / monthlyEssentials : 0.0;
    final adherence = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    final pending = state.pendingEmergencyReplenishment;

    return _ReflectionSection(
      title: 'Emergency Fund Overview',
      caption:
          'Current savings are compared with the six-month Financial Safety goal. Progress is capped at 100% so extra savings do not hide another missing measure.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GoalPairBar(
            label: 'Emergency fund',
            target: target,
            current: current,
            color: _amber,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LabeledMetric(
                  label: 'Goal adherence',
                  value: '${(adherence * 100).round()}%',
                  note: 'Current ÷ target',
                  color: _amber,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LabeledMetric(
                  label: 'Months covered',
                  value: months.toStringAsFixed(1),
                  note: 'Essential expenses',
                  color: _brand,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LabeledMetric(
                  label: 'To replenish',
                  value: money(pending),
                  note: pending > 0 ? 'Still pending' : 'Nothing pending',
                  color: pending > 0 ? _red : _sage,
                ),
              ),
            ],
          ),
          if (monthlyEssentials <= 0) ...[
            const SizedBox(height: 12),
            const _DataNote(
              text:
                  'Monthly essential expenses are not available yet, so a temporary ₱30,000 minimum target is used.',
            ),
          ],
        ],
      ),
    );
  }
}

class _EmergencyActivityReflection extends StatelessWidget {
  const _EmergencyActivityReflection({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final activity =
        <({String label, double amount, DateTime? date, bool add})>[];
    for (final entry in state.d1Ledger) {
      final type = entry['type']?.toString();
      if (!const {
        'emergency_deposit',
        'use_emergency',
        'ef_replenish',
      }.contains(type)) {
        continue;
      }
      activity.add((
        label: switch (type) {
          'emergency_deposit' => 'Income contribution',
          'ef_replenish' => 'Replenishment',
          _ => 'Emergency withdrawal',
        },
        amount: (entry['amount'] as num?)?.toDouble() ?? 0,
        date: DateTime.tryParse(entry['date']?.toString() ?? ''),
        add: type != 'use_emergency',
      ));
    }
    for (final transaction in state.fakeMayaLink?.summary.transactions ??
        const <FakeMayaTransaction>[]) {
      if (!transaction.isLabeled ||
          transaction.excludedFromInsights ||
          transaction.source?.toLowerCase() != 'emergency fund') {
        continue;
      }
      activity.add((
        label: transaction.category ?? 'Emergency fund activity',
        amount: transaction.amount.abs(),
        date: transaction.createdAt,
        add: transaction.amount >= 0,
      ));
    }
    activity.sort((a, b) =>
        (b.date ?? DateTime(1970)).compareTo(a.date ?? DateTime(1970)));
    final maxAmount = activity.fold<double>(
      1,
      (largest, item) => math.max(largest, item.amount),
    );

    return _ReflectionSection(
      title: 'Contributions and Use',
      caption:
          'Each bar uses the same peso scale. Green adds to the fund; red uses the fund. The list is ordered from newest to oldest.',
      child: activity.isEmpty
          ? const _ReflectionEmpty(
              message:
                  'No emergency fund activity is recorded yet. New contributions and withdrawals will appear here.',
            )
          : Column(
              children: [
                const Row(
                  children: [
                    _ChartLegend(color: _sage, label: 'Added'),
                    SizedBox(width: 14),
                    _ChartLegend(color: _red, label: 'Used'),
                  ],
                ),
                const SizedBox(height: 14),
                for (final item in activity.take(12))
                  _EmergencyActivityBar(item: item, maxAmount: maxAmount),
              ],
            ),
    );
  }
}

class _EmergencyActivityBar extends StatelessWidget {
  const _EmergencyActivityBar({required this.item, required this.maxAmount});
  final ({String label, double amount, DateTime? date, bool add}) item;
  final double maxAmount;

  @override
  Widget build(BuildContext context) {
    final color = item.add ? _sage : _red;
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${item.add ? '+' : '-'}${money(item.amount)}',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: item.amount / maxAmount,
                    minHeight: 8,
                    color: color,
                    backgroundColor: _border.withValues(alpha: .5),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              SizedBox(
                width: 46,
                child: Text(
                  item.date == null ? 'No date' : _shortDate(item.date!),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LabeledMetric extends StatelessWidget {
  const _LabeledMetric({
    required this.label,
    required this.value,
    required this.note,
    required this.color,
  });
  final String label;
  final String value;
  final String note;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: _body, fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(note,
              style: const TextStyle(
                  color: _body, fontSize: 9, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DataNote extends StatelessWidget {
  const _DataNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline_rounded, color: _body, size: 16),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: _body,
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: _body,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ReflectionSection extends StatelessWidget {
  const _ReflectionSection({
    required this.title,
    required this.caption,
    required this.child,
  });
  final String title;
  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _title,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              caption,
              style: const TextStyle(
                color: _body,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _ReflectionEmpty extends StatelessWidget {
  const _ReflectionEmpty({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          message,
          style: const TextStyle(color: _body, fontWeight: FontWeight.w700),
        ),
      );
}

class _NeutralNotice extends StatelessWidget {
  const _NeutralNotice({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _amber.withOpacity(.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _amber.withOpacity(.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_rounded, color: _amber, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _title,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonBars extends StatelessWidget {
  const _ComparisonBars({
    required this.leftLabel,
    required this.rightLabel,
    required this.leftValue,
    required this.rightValue,
    required this.selected,
    required this.onSelected,
  });
  final String leftLabel;
  final String rightLabel;
  final double leftValue;
  final double rightValue;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final maxValue =
        math.max(leftValue, rightValue).clamp(1.0, double.infinity);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _ComparisonBar(
          id: 'after',
          label: leftLabel,
          value: leftValue,
          maxValue: maxValue,
          selected: selected == 'after',
          color: _brand,
          onTap: () => onSelected(selected == 'after' ? null : 'after'),
        ),
        const SizedBox(width: 14),
        _ComparisonBar(
          id: 'before',
          label: rightLabel,
          value: rightValue,
          maxValue: maxValue,
          selected: selected == 'before',
          color: _purple,
          onTap: () => onSelected(selected == 'before' ? null : 'before'),
        ),
      ],
    );
  }
}

class _ComparisonBar extends StatelessWidget {
  const _ComparisonBar({
    required this.id,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String id;
  final String label;
  final double value;
  final double maxValue;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final height = 32 + 102 * (value / maxValue);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Text(
              money(value),
              style: TextStyle(
                color: selected ? color : _title,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: height,
                decoration: BoxDecoration(
                  color: color.withOpacity(selected ? .95 : .58),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _body,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalPairBar extends StatelessWidget {
  const _GoalPairBar({
    required this.label,
    required this.target,
    required this.current,
    required this.color,
  });
  final String label;
  final double target;
  final double current;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxValue = math.max(target, current).clamp(1.0, double.infinity);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _title,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${money(current)} current',
              style: const TextStyle(
                color: _body,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(
              width: 52,
              child: Text(
                'Target',
                style: TextStyle(
                  color: _body,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: _ThinBar(
                value: target / maxValue,
                color: color.withOpacity(.22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const SizedBox(
              width: 52,
              child: Text(
                'Current',
                style: TextStyle(
                  color: _body,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: _ThinBar(value: current / maxValue, color: color),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Target ${money(target)}',
          style: const TextStyle(
            color: _body,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ThinBar extends StatelessWidget {
  const _ThinBar({required this.value, required this.color});
  final double value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 9,
        color: color,
        backgroundColor: _border.withOpacity(.5),
      ),
    );
  }
}

class _CoverageGrid extends StatelessWidget {
  const _CoverageGrid({required this.days});
  final List<DayRecord> days;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const SizedBox(
        height: 90,
        child: _ReflectionEmpty(message: 'No coverage days yet.'),
      );
    }
    final byDate = {
      for (final day in days)
        DateTime(day.date.year, day.date.month, day.date.day): day,
    };
    final first = days.first.date;
    final last = days.last.date;
    var weekStart =
        first.subtract(Duration(days: first.weekday - DateTime.monday));
    final weeks = <DateTime>[];
    while (!weekStart.isAfter(last)) {
      weeks.add(weekStart);
      weekStart = weekStart.add(const Duration(days: 7));
    }

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 58),
            for (final label in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _body,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        for (final start in weeks)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 58,
                  child: Text(
                    _shortDate(start),
                    style: const TextStyle(
                      color: _body,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                for (var offset = 0; offset < 7; offset++)
                  Expanded(
                    child: _CoverageDay(
                      date: start.add(Duration(days: offset)),
                      day: byDate[DateTime(
                        start.add(Duration(days: offset)).year,
                        start.add(Duration(days: offset)).month,
                        start.add(Duration(days: offset)).day,
                      )],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CoverageLegend extends StatelessWidget {
  const _CoverageLegend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: _body,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _CoverageDay extends StatelessWidget {
  const _CoverageDay({required this.date, required this.day});
  final DateTime date;
  final DayRecord? day;

  @override
  Widget build(BuildContext context) {
    final record = day;
    final status = record == null
        ? 'Outside tracked range'
        : record.fullyClassified
            ? 'Complete'
            : record.wasInferred
                ? 'Inferred'
                : 'Missing';
    final color = record == null
        ? Colors.transparent
        : record.fullyClassified
            ? _brand
            : record.wasInferred
                ? _purple
                : _border;
    final filled = record?.fullyClassified ?? false;
    return Tooltip(
      message: '${_shortDate(date)}: $status',
      child: Container(
        height: 27,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: record == null ? _border.withValues(alpha: .35) : color,
            width: record?.wasInferred == true ? 2 : 1,
          ),
        ),
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: filled ? Colors.white : _body,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _JarTimelinePainter extends CustomPainter {
  _JarTimelinePainter({
    required this.weeks,
    required this.targetNeeds,
    required this.targetBuffer,
  });
  final List<WeekRecord> weeks;
  final double targetNeeds;
  final double targetBuffer;

  @override
  void paint(Canvas canvas, Size size) {
    if (weeks.isEmpty) return;
    const left = 54.0;
    const top = 18.0;
    const bottom = 32.0;
    final chartWidth = size.width - left - 8;
    final chartHeight = size.height - top - bottom;
    final maxValue = [
      targetNeeds,
      targetBuffer,
      ...weeks.map((week) => week.needsBalanceEnd),
      ...weeks.map((week) => week.bufferBalanceEnd),
    ].fold(1.0, math.max);
    final bandPaint = Paint()..color = _brand.withOpacity(.08);
    final targetY = top + chartHeight * (1 - (targetNeeds / maxValue));
    canvas.drawRect(
      Rect.fromLTWH(left, math.max(top, targetY - 8), chartWidth, 16),
      bandPaint,
    );
    final gridPaint = Paint()
      ..color = _border
      ..strokeWidth = 1;
    for (final fraction in [0.0, .5, 1.0]) {
      final y = top + chartHeight * fraction;
      canvas.drawLine(Offset(left, y), Offset(left + chartWidth, y), gridPaint);
      _paintChartText(
        canvas,
        money(maxValue * (1 - fraction)),
        Offset(0, y - 6),
        maxWidth: left - 7,
        align: TextAlign.right,
      );
    }
    _paintChartText(
      canvas,
      'Needs target',
      Offset(left + 4, math.max(top, targetY - 17)),
      color: _brand,
      fontWeight: FontWeight.w800,
    );
    final segmentWidth = chartWidth / weeks.length;
    for (var i = 0; i < weeks.length; i++) {
      final week = weeks[i];
      if (week.isBillWeek || week.isSalaryWeek) {
        final paint = Paint()
          ..color = (week.isBillWeek ? _amber : _sage).withOpacity(.10);
        canvas.drawRect(
          Rect.fromLTWH(
              left + i * segmentWidth, top, segmentWidth, chartHeight),
          paint,
        );
      }
    }
    void drawSeries(double Function(WeekRecord week) valueFor, Color color) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      Path? path;
      for (var i = 0; i < weeks.length; i++) {
        final week = weeks[i];
        final x = left + segmentWidth * i + segmentWidth / 2;
        final y = top + chartHeight * (1 - (valueFor(week) / maxValue));
        final hasCoverage = week.propDaysClassified > 0;
        if (!hasCoverage) {
          if (path != null) canvas.drawPath(path, paint);
          path = null;
          continue;
        }
        final activePath = path;
        if (activePath == null) {
          path = Path()..moveTo(x, y);
        } else {
          activePath.lineTo(x, y);
        }
      }
      if (path != null) canvas.drawPath(path, paint);
    }

    drawSeries((week) => week.needsBalanceEnd, _brand);
    drawSeries((week) => week.bufferBalanceEnd, _purple);

    final labelIndexes = <int>{0, weeks.length ~/ 2, weeks.length - 1};
    for (final index in labelIndexes) {
      final x = left + segmentWidth * index + segmentWidth / 2;
      _paintChartText(
        canvas,
        _shortDate(weeks[index].start),
        Offset(x - 25, top + chartHeight + 8),
        maxWidth: 50,
        align: TextAlign.center,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _JarTimelinePainter oldDelegate) =>
      oldDelegate.weeks != weeks ||
      oldDelegate.targetNeeds != targetNeeds ||
      oldDelegate.targetBuffer != targetBuffer;
}

void _paintChartText(
  Canvas canvas,
  String text,
  Offset offset, {
  double maxWidth = 90,
  TextAlign align = TextAlign.left,
  Color color = _body,
  FontWeight fontWeight = FontWeight.w700,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 9,
        fontWeight: fontWeight,
      ),
    ),
    textAlign: align,
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout(maxWidth: maxWidth);
  painter.paint(canvas, offset);
}

void _showExpectedSpendDetail(BuildContext context, AppState state) {
  final ledger = state.onboardingExpenseLedger;
  final useLedger = ledger.isNotEmpty;
  final items = useLedger
      ? ledger
          .where((expense) =>
              expenseLayerForLedger(expense) == ExpenseLayer.basicNeeds)
          .map((e) => (
                name: (e['name'] as String?)?.trim().isNotEmpty == true
                    ? e['name'] as String
                    : 'Untitled expense',
                amount: (e['amount'] as num?)?.toDouble() ?? 0,
                essential: e['essential'] as bool? ?? false,
              ))
          .toList()
      : state.cashFlowExpenses
          .where((expense) => expense.layer == ExpenseLayer.basicNeeds)
          .map((e) => (name: e.name, amount: e.budget, essential: false))
          .toList();
  final expected = _maintainAvailableCashExpectedSpend(state);
  items.sort((a, b) => b.amount.compareTo(a.amount));

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: _surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        shrinkWrap: true,
        children: [
          const Text(
            'Expected basic-needs spend',
            style: TextStyle(
              color: _title,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'What your ${money(expected)} basic-needs baseline is made of.',
            style: const TextStyle(color: _body, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No expenses logged yet. Add your monthly expenses to see them here.',
                style: TextStyle(color: _body, fontSize: 13),
              ),
            )
          else
            for (final item in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.receipt_long_rounded,
                  color: item.essential ? _purple : _amber,
                ),
                title: Text(item.name),
                subtitle: useLedger
                    ? Text(item.essential ? 'Essential' : 'Non-essential')
                    : null,
                trailing: Text(
                  money(item.amount),
                  style: const TextStyle(
                      color: _title, fontWeight: FontWeight.w900),
                ),
              ),
        ],
      ),
    ),
  );
}

void _showWeekDetail(BuildContext context, WeekRecord week) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: _surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final transactions = week.days.expand((day) => day.transactions).toList();
      final events = week.days.expand((day) => day.events).toList();
      return SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          children: [
            Text(
              '${_shortDate(week.start)} - ${_shortDate(week.end)}',
              style: const TextStyle(
                color: _title,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            for (final event in events)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  event.type == JarEventType.income
                      ? Icons.arrow_downward_rounded
                      : Icons.receipt_long_rounded,
                  color: event.type == JarEventType.income ? _brand : _amber,
                ),
                title: Text(event.sentence),
                subtitle: Text(_shortDate(event.timestamp)),
              ),
            for (final transaction in transactions.take(12))
              TransactionRow(
                transaction.title,
                transaction.category ?? 'Unclassified',
                _shortDate(transaction.createdAt ?? week.start),
                money(transaction.amount.abs()),
                transaction.amount > 0 &&
                    !transaction.isInternalFakeMayaTransfer,
              ),
          ],
        ),
      );
    },
  );
}

String _shortDate(DateTime value) {
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
  return '${months[value.month - 1]} ${value.day}';
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

class _AccountsSection extends StatefulWidget {
  const _AccountsSection(
      {required this.accounts, required this.state, this.compact = false});
  final List<_WealthAccount> accounts;
  final AppState state;
  final bool compact;

  @override
  State<_AccountsSection> createState() => _AccountsSectionState();
}

class _AccountsSectionState extends State<_AccountsSection> {
  String? expandedAccount;

  void _toggleAccount(_WealthAccount account) {
    if (account.name != 'Wallet' && account.name != 'Savings') {
      return;
    }
    setState(() {
      expandedAccount = expandedAccount == account.name ? null : account.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accounts = widget.accounts;
    final state = widget.state;
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
                  'Log account balances manually or sync selected accounts in Settings.',
            )
          else
            _AccountGrid(
              accounts: accounts,
              expandedAccount: expandedAccount,
              onAccountTap: _toggleAccount,
            ),
          if (expandedAccount != null) ...[
            const SizedBox(height: 12),
            _WalletAllocationsCard(
              state: state,
              accountName: expandedAccount!,
            ),
          ],
        ],
      ),
    );
  }
}

class _WalletAllocationsCard extends StatelessWidget {
  const _WalletAllocationsCard(
      {required this.state, required this.accountName});
  final AppState state;
  final String accountName;

  @override
  Widget build(BuildContext context) {
    final wallet = state.accountBalance('Wallet');
    final hasEssentialExpenseBucket = state.fakeMayaBucketExists(
      FakeMayaPersonalGoal.essentialExpenseFundId,
    );
    final hasEmergencyBucket = state.fakeMayaBucketExists(
      FakeMayaPersonalGoal.emergencyFundId,
    );
    final walletAllocations = <(String, double, Color, IconData)>[
      if (hasEssentialExpenseBucket && state.essentialExpensesBalance > 0)
        (
          'Essential Expenses Fund',
          state.essentialExpensesBalance,
          _brand,
          Icons.home_work_rounded
        ),
      if (state.billsObligationsBalance > 0)
        (
          'Bills & Obligations',
          state.billsObligationsBalance,
          _purple,
          Icons.event_note_rounded
        ),
    ];
    final savings = state.accountBalance('Savings');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _bellySoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (accountName == 'Wallet') ...[
            const Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded,
                    color: _brand, size: 20),
                SizedBox(width: 8),
                Expanded(
                    child: Text('Inside Wallet',
                        style: TextStyle(
                            color: _title,
                            fontSize: 15,
                            fontWeight: FontWeight.w900))),
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              'These funds are earmarked portions of your wallet balance—not separate accounts or additional money.',
              style: TextStyle(
                  color: _body,
                  fontSize: 11.5,
                  height: 1.35,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (walletAllocations.isEmpty)
              const Text(
                'No wallet money is earmarked yet.',
                style: TextStyle(
                    color: _body, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            for (final allocation in walletAllocations) ...[
              Row(
                children: [
                  Icon(allocation.$4, color: allocation.$3, size: 17),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(allocation.$1,
                          style: const TextStyle(
                              color: _title,
                              fontSize: 12,
                              fontWeight: FontWeight.w800))),
                  Text(money(allocation.$2),
                      style: TextStyle(
                          color: allocation.$3,
                          fontSize: 12,
                          fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            const Divider(height: 8, color: _border),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                    child: Text('Unallocated wallet money',
                        style: TextStyle(
                            color: _body,
                            fontSize: 12,
                            fontWeight: FontWeight.w800))),
                Text(money(state.unallocatedFakeMayaWallet),
                    style: const TextStyle(
                        color: _title,
                        fontSize: 13,
                        fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Expanded(
                    child: Text('Full Wallet balance',
                        style: TextStyle(
                            color: _body,
                            fontSize: 11,
                            fontWeight: FontWeight.w700))),
                Text(money(wallet),
                    style: const TextStyle(
                        color: _body,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ],
          if (accountName == 'Savings') ...[
            const Row(
              children: [
                Icon(Icons.savings_rounded, color: _amber, size: 20),
                SizedBox(width: 8),
                Expanded(
                    child: Text('Inside Savings',
                        style: TextStyle(
                            color: _title,
                            fontSize: 15,
                            fontWeight: FontWeight.w900))),
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              'Emergency Fund is an earmarked portion of Savings—not a separate account or additional money.',
              style: TextStyle(
                  color: _body,
                  fontSize: 11.5,
                  height: 1.35,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (state.displayedEmergencyFundBalance <= 0)
              const Text(
                'No savings money is earmarked yet.',
                style: TextStyle(
                    color: _body, fontSize: 12, fontWeight: FontWeight.w700),
              )
            else if (hasEmergencyBucket)
              Row(
                children: [
                  const Icon(Icons.shield_rounded, color: _amber, size: 17),
                  const SizedBox(width: 8),
                  const Expanded(
                      child: Text('Emergency Fund',
                          style: TextStyle(
                              color: _title,
                              fontSize: 12,
                              fontWeight: FontWeight.w800))),
                  Text(money(state.displayedEmergencyFundBalance),
                      style: const TextStyle(
                          color: _amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            const SizedBox(height: 8),
            const Divider(height: 8, color: _border),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                    child: Text('Unallocated savings money',
                        style: TextStyle(
                            color: _body,
                            fontSize: 12,
                            fontWeight: FontWeight.w800))),
                Text(money(state.unallocatedFakeMayaSavings),
                    style: const TextStyle(
                        color: _title,
                        fontSize: 13,
                        fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Expanded(
                    child: Text('Full Savings balance',
                        style: TextStyle(
                            color: _body,
                            fontSize: 11,
                            fontWeight: FontWeight.w700))),
                Text(money(savings),
                    style: const TextStyle(
                        color: _body,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountGrid extends StatelessWidget {
  const _AccountGrid({
    required this.accounts,
    required this.expandedAccount,
    required this.onAccountTap,
  });
  final List<_WealthAccount> accounts;
  final String? expandedAccount;
  final ValueChanged<_WealthAccount> onAccountTap;

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
            Expanded(
              child: _AccountCard(
                account: left,
                expanded: expandedAccount == left.name,
                onTap: () => onAccountTap(left),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: right != null
                  ? _AccountCard(
                      account: right,
                      expanded: expandedAccount == right.name,
                      onTap: () => onAccountTap(right),
                    )
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
  const _AccountCard(
      {required this.account, required this.expanded, required this.onTap});
  final _WealthAccount account;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = account.color;
    final expandable = account.name == 'Wallet' || account.name == 'Savings';
    return InkWell(
      onTap: expandable ? onTap : null,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.withOpacity(.07),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: expanded ? c : c.withOpacity(.22),
            width: expanded ? 1.6 : 1,
          ),
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
                if (expandable)
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: c,
                    size: 20,
                  )
                else
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
          const _SectionHeader(label: 'ACCOUNTS', total: null),
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
              _PyramidMayaBucketRow(
                layerNum: widget.layerNum,
                state: widget.state,
                color: c,
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

/// The FakeMaya bucket tied to this pyramid layer's motivation and its
/// current balance, pulled live from the linked FakeMaya account — 0 until
/// a transaction or goal action has actually moved money into it. Renders
/// nothing if this layer has no bucket mapping.
class _PyramidMayaBucketRow extends StatelessWidget {
  const _PyramidMayaBucketRow({
    required this.layerNum,
    required this.state,
    required this.color,
  });

  final int layerNum;
  final AppState state;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bucketId = fakeMayaBucketIdForMotivation(_layerNames[layerNum - 1]);
    if (bucketId == null) return const SizedBox.shrink();
    final bucket = state.fakeMayaLink?.summary.personalGoalById(bucketId);
    if (state.fakeMayaLink != null && bucket == null) {
      return const SizedBox.shrink();
    }
    final bucketTemplate = FakeMayaPersonalGoal.defaultForId(bucketId);
    final bucketBalance = bucket?.balance ?? 0.0;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: _PyramidMayaBucketTile(
        emoji: bucketTemplate.emoji,
        label: bucketTemplate.name,
        value: bucketBalance,
        color: color,
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
    if (layerNum == 1 && state.cashFlowPyramidBaseline > 0) {
      return _ContextChip(
        icon: Icons.receipt_long_rounded,
        text: 'Monthly expenses: ${money(state.cashFlowPyramidBaseline)}',
        color: _brand,
      );
    }
    if (layerNum == 2 && state.cashFlowPyramidBaseline > 0) {
      final months =
          state.financialSafetyBalance / state.cashFlowPyramidBaseline;
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
    final hasSafety = state.cashFlowPyramidBaseline > 0;

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
    final budget = state.cashFlowPyramidBaseline;
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
  final List<({String date, String event, String amount, bool isIn})>
      activityLog;
}

const _d1GoalMetas = <_D1GoalMeta>[
  _D1GoalMeta(
    id: 'G1',
    emoji: '💵',
    title: 'Maintain Available Cash',
    description:
        'Have and maintain enough available cash to cover expenses without financial stress.',
    layerColor: _brand,
    layerLabel: 'Cash Flow',
    actions: [
      _D1ActionMeta(
        id: 'A1',
        text:
            'Set aside 50% of each income received into an Essential Expenses Fund.',
        configLabel: 'Allocation',
        configValue: '50% of income',
        destBucket: 'Essential Expenses Fund',
        metrics: [
          (
            label: 'Savings-to-Spending',
            value: '1.5 : 1',
            icon: Icons.balance_rounded
          ),
          (
            label: 'Monthly Cash Flow',
            value: '+₱3,200',
            icon: Icons.trending_up_rounded
          ),
          (
            label: 'Cash Balance',
            value: '₱5,500',
            icon: Icons.account_balance_wallet_rounded
          ),
          (label: 'Fund Balance', value: '₱7,500', icon: Icons.savings_rounded),
        ],
        dataPoints: [
          (label: 'Financial Activity Date', type: 'T', value: 'Jun 15, 2026'),
          (label: 'Income Transaction', type: 'S', value: '₱15,000'),
          (label: 'Transfer Amount', type: 'S', value: '₱7,500'),
          (label: 'Source Bucket', type: 'S', value: 'Main Cash Account'),
          (
            label: 'Destination Bucket',
            type: 'S',
            value: 'Essential Expenses Fund'
          ),
          (label: 'Available Cash Balance', type: 'S', value: '₱5,500'),
          (label: 'Savings-to-Spending Ratio', type: 'I', value: '1.5 : 1'),
          (label: 'Monthly Cash Flow Balance', type: 'I', value: '+₱3,200'),
        ],
        activityLog: [
          (
            date: 'Jun 15',
            event: 'Income received → Essential Expenses Fund',
            amount: '₱7,500',
            isIn: true
          ),
          (
            date: 'Jun 1',
            event: 'Income received → Essential Expenses Fund',
            amount: '₱6,000',
            isIn: true
          ),
          (
            date: 'May 15',
            event: 'Income received → Essential Expenses Fund',
            amount: '₱7,500',
            isIn: true
          ),
        ],
      ),
      _D1ActionMeta(
        id: 'A3',
        text:
            'Limit spending in selected categories to a maximum of ₱X per month.',
        configLabel: 'Category budgets',
        configValue: 'Set per category',
        destBucket: 'Monthly spending limits',
        metrics: [
          (
            label: 'Budget Adherence',
            value: '75%',
            icon: Icons.verified_rounded
          ),
          (
            label: 'Monthly Cash Flow',
            value: '+₱3,200',
            icon: Icons.trending_up_rounded
          ),
          (
            label: 'Next Bill Due',
            value: 'Jul 5',
            icon: Icons.calendar_today_rounded
          ),
          (label: 'Fund Balance', value: '₱2,000', icon: Icons.savings_rounded),
        ],
        dataPoints: [
          (label: 'Financial Activity Date', type: 'T', value: 'Jun 15, 2026'),
          (
            label: 'Scheduled Bill Due Date',
            type: 'T',
            value: 'Jul 5, 2026 (rent)'
          ),
          (label: 'Income Transaction', type: 'S', value: '₱15,000'),
          (label: 'Transfer Amount', type: 'S', value: '₱2,000'),
          (label: 'Source Bucket', type: 'S', value: 'Main Cash Account'),
          (
            label: 'Destination Bucket',
            type: 'S',
            value: 'Bills & Obligations Fund'
          ),
          (label: 'Available Cash Balance', type: 'S', value: '₱5,500'),
          (label: 'Budget Adherence Rate', type: 'I', value: '75%'),
          (label: 'Monthly Cash Flow Balance', type: 'I', value: '+₱3,200'),
        ],
        activityLog: [
          (
            date: 'Jun 15',
            event: 'Income received → Bills & Obligations Fund',
            amount: '₱2,000',
            isIn: true
          ),
          (
            date: 'Jun 1',
            event: 'Income received → Bills & Obligations Fund',
            amount: '₱2,000',
            isIn: true
          ),
          (
            date: 'May 25',
            event: 'Bill paid — Electricity',
            amount: '-₱1,800',
            isIn: false
          ),
          (
            date: 'May 15',
            event: 'Income received → Bills & Obligations Fund',
            amount: '₱2,000',
            isIn: true
          ),
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
          (
            label: 'Fund Coverage',
            value: '1.8 months',
            icon: Icons.shield_rounded
          ),
          (
            label: 'Fund Balance',
            value: '₱18,500',
            icon: Icons.savings_rounded
          ),
          (
            label: 'Compliance Rate',
            value: '85%',
            icon: Icons.verified_rounded
          ),
          (
            label: 'Cash Balance',
            value: '₱5,500',
            icon: Icons.account_balance_wallet_rounded
          ),
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
          (
            date: 'Jun 15',
            event: 'Income received → Emergency Fund',
            amount: '₱1,500',
            isIn: true
          ),
          (
            date: 'Jun 1',
            event: 'Income received → Emergency Fund',
            amount: '₱1,200',
            isIn: true
          ),
          (
            date: 'May 15',
            event: 'Income received → Emergency Fund',
            amount: '₱1,500',
            isIn: true
          ),
          (
            date: 'May 1',
            event: 'Income received → Emergency Fund',
            amount: '₱1,200',
            isIn: true
          ),
        ],
      ),
      _D1ActionMeta(
        id: 'A10',
        text:
            'Replenish withdrawn Emergency Fund amounts within 7 days after receiving income.',
        configLabel: 'Replenish within',
        configValue: '7 days of income',
        destBucket: 'Emergency Fund',
        metrics: [
          (
            label: 'Fund Coverage',
            value: '1.8 months',
            icon: Icons.shield_rounded
          ),
          (
            label: 'Fund Balance',
            value: '₱18,500',
            icon: Icons.savings_rounded
          ),
          (
            label: 'Compliance Rate',
            value: '85%',
            icon: Icons.verified_rounded
          ),
          (
            label: 'Last Replenished',
            value: 'Jun 16',
            icon: Icons.check_circle_rounded
          ),
        ],
        dataPoints: [
          (label: 'Financial Activity Date', type: 'T', value: 'Jun 16, 2026'),
          (label: 'Income Transaction', type: 'S', value: '₱15,000 on Jun 15'),
          (
            label: 'Transfer Amount',
            type: 'S',
            value: '₱3,000 (replenishment)'
          ),
          (label: 'Source Bucket', type: 'S', value: 'Main Cash Account'),
          (label: 'Destination Bucket', type: 'S', value: 'Emergency Fund'),
          (label: 'Available Cash Balance', type: 'S', value: '₱5,500'),
          (label: 'Emergency Fund Balance', type: 'S', value: '₱18,500'),
          (label: 'Emergency Fund Coverage', type: 'I', value: '1.8 months'),
          (label: 'Contribution Compliance Rate', type: 'I', value: '85%'),
        ],
        activityLog: [
          (
            date: 'Jun 16',
            event: 'Replenishment → Emergency Fund (1 day after income)',
            amount: '₱3,000',
            isIn: true
          ),
          (
            date: 'Jun 15',
            event: 'Income received',
            amount: '₱15,000',
            isIn: true
          ),
          (
            date: 'Jun 12',
            event: 'Emergency withdrawal from fund',
            amount: '-₱3,000',
            isIn: false
          ),
          (
            date: 'Jun 1',
            event: 'Replenishment → Emergency Fund (3 days after income)',
            amount: '₱2,500',
            isIn: true
          ),
        ],
      ),
    ],
  ),
  _D1GoalMeta(
    id: 'G5',
    emoji: '📈',
    title: 'Grow Investments',
    description:
        'Have a growing investment portfolio that steadily builds wealth over time.',
    layerColor: _purple,
    layerLabel: 'Accumulating Wealth',
    actions: [
      _D1ActionMeta(
        id: 'A12',
        text: 'Allocate 10% of each income to the Investment Portfolio.',
        configLabel: 'Allocation',
        configValue: '10% of income',
        destBucket: 'Investment Portfolio',
        metrics: [
          (
            label: 'Portfolio Balance',
            value: '₱24,000',
            icon: Icons.show_chart_rounded
          ),
          (
            label: 'Invested This Month',
            value: '₱1,500',
            icon: Icons.trending_up_rounded
          ),
          (
            label: 'Compliance Rate',
            value: '80%',
            icon: Icons.verified_rounded
          ),
          (
            label: 'Cash Balance',
            value: '₱5,500',
            icon: Icons.account_balance_wallet_rounded
          ),
        ],
        dataPoints: [
          (label: 'Financial Activity Date', type: 'T', value: 'Jun 15, 2026'),
          (label: 'Income Transaction', type: 'S', value: '₱15,000'),
          (label: 'Transfer Amount', type: 'S', value: '₱1,500'),
          (label: 'Source Bucket', type: 'S', value: 'Main Cash Account'),
          (
            label: 'Destination Bucket',
            type: 'S',
            value: 'Investment Portfolio'
          ),
          (label: 'Available Cash Balance', type: 'S', value: '₱5,500'),
          (label: 'Investment Account Balance', type: 'S', value: '₱24,000'),
          (label: 'Contribution Compliance Rate', type: 'I', value: '80%'),
        ],
        activityLog: [
          (
            date: 'Jun 15',
            event: 'Income received → Investment Portfolio',
            amount: '₱1,500',
            isIn: true
          ),
          (
            date: 'Jun 1',
            event: 'Income received → Investment Portfolio',
            amount: '₱1,200',
            isIn: true
          ),
          (
            date: 'May 15',
            event: 'Income received → Investment Portfolio',
            amount: '₱1,500',
            isIn: true
          ),
        ],
      ),
      _D1ActionMeta(
        id: 'A14',
        text:
            'Transfer 50% of unspent monthly funds toward investments at the end of each month.',
        configLabel: 'Month-end sweep',
        configValue: '50% of unspent funds',
        destBucket: 'Investment Portfolio',
        metrics: [
          (
            label: 'Portfolio Balance',
            value: '₱24,000',
            icon: Icons.show_chart_rounded
          ),
          (
            label: 'Unspent This Month',
            value: '₱3,200',
            icon: Icons.savings_rounded
          ),
          (
            label: 'Last Sweep',
            value: 'May 31',
            icon: Icons.check_circle_rounded
          ),
          (
            label: 'Cash Balance',
            value: '₱5,500',
            icon: Icons.account_balance_wallet_rounded
          ),
        ],
        dataPoints: [
          (label: 'Financial Activity Date', type: 'T', value: 'May 31, 2026'),
          (label: 'Unspent Monthly Funds', type: 'S', value: '₱3,200'),
          (label: 'Transfer Amount', type: 'S', value: '₱1,600'),
          (label: 'Source Bucket', type: 'S', value: 'Main Cash Account'),
          (
            label: 'Destination Bucket',
            type: 'S',
            value: 'Investment Portfolio'
          ),
          (label: 'Investment Account Balance', type: 'S', value: '₱24,000'),
        ],
        activityLog: [
          (
            date: 'May 31',
            event: 'Month-end sweep → Investment Portfolio',
            amount: '₱1,600',
            isIn: true
          ),
          (
            date: 'Apr 30',
            event: 'Month-end sweep → Investment Portfolio',
            amount: '₱1,100',
            isIn: true
          ),
        ],
      ),
    ],
  ),
  _D1GoalMeta(
    id: 'G8',
    emoji: '🎨',
    title: 'Lifestyle Fund',
    description:
        'Consistently have money set aside for personal lifestyle activities, hobbies, and everyday enjoyment.',
    layerColor: Color(0xFF4F86C6),
    layerLabel: 'Financial Freedom',
    actions: [],
  ),
];

// ─── Goals page ───────────────────────────────────────────────────────────────

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key, this.initialGoalId});

  final String? initialGoalId;

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  String? _activeGoalId; // null = list view, 'G1' or 'G3' = detail

  @override
  void initState() {
    super.initState();
    _activeGoalId = widget.initialGoalId;
  }

  void openGoal(String goalId) {
    if (!mounted) return;
    setState(() => _activeGoalId = goalId);
  }

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
    final state = AppScope.of(context);
    final (onTrack, total) = goalsOnTrackSummary(state);
    final visibleGoalIds = _visibleGoalIds(state);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const PageHeader(eyebrow: 'MY GOALS', title: 'Goals'),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddGoalScreen()),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _brand,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Goal',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _WeeklyProgressCard(onTrack: onTrack, total: total),
        ),
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Track your progress and actions for each financial goal.',
            style: TextStyle(
                color: _body, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (final goal in _d1GoalMetas)
                if (visibleGoalIds.contains(goal.id)) ...[
                  _D1GoalCard(goal: goal, onTap: () => onGoal(goal.id)),
                  const SizedBox(height: 14),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard({required this.onTrack, required this.total});
  final int onTrack;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_purple, Color(0xFF5A3FA0)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Image.asset(
              'assets/images/shellby_wave.webp',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WEEKLY PROGRESS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$onTrack of $total goals on track!',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _daysRemainingThisWeekLabel(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
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

String _daysRemainingThisWeekLabel() {
  final daysLeft = 7 - DateTime.now().weekday;
  if (daysLeft <= 0) return 'Last day of the week';
  return '$daysLeft day${daysLeft == 1 ? '' : 's'} remaining this week';
}

double _currentWeekLifestyleSpend(AppState state) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  final lifestylePattern = RegExp(
    r'entertainment|travel|personal goal|movie|cinema|concert|game|hobby|coffee|cafe|restaurant|bar',
    caseSensitive: false,
  );
  final recurringPattern = RegExp(
    r'subscription|membership|stream|netflix|spotify|gym|club|app plan',
    caseSensitive: false,
  );
  return state.allTransactions.where((transaction) {
    final date = transaction.createdAt ?? transaction.labeledAt;
    if (transaction.amount >= 0 ||
        transaction.excludedFromInsights ||
        date == null ||
        date.isBefore(start) ||
        date.isAfter(now)) {
      return false;
    }
    final category = transaction.category ?? '';
    final layer = _insightCategoryConfig(category).$1;
    final text =
        '$category ${transaction.title} ${transaction.detail}'.toLowerCase();
    if (recurringPattern.hasMatch(text)) return false;
    return layer == 4 || lifestylePattern.hasMatch(text);
  }).fold<double>(
    0,
    (total, transaction) => total + transaction.amount.abs(),
  );
}

/// Everyday-enjoyment spend for a completed week, [weeksAgo] weeks back
/// (0 = the most recently completed week before this one). Used for the
/// Financial Freedom insights page's weekly spending trend, separate from
/// [_currentWeekLifestyleSpend] which cuts off at "now" for the in-progress
/// week rather than a fixed 7-day window.
double _lifestyleSpendForCompletedWeek(AppState state, int weeksAgo) {
  final now = DateTime.now();
  final thisWeekStart = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  final start = thisWeekStart.subtract(Duration(days: 7 * (weeksAgo + 1)));
  final end = start.add(const Duration(days: 7));
  final lifestylePattern = RegExp(
    r'entertainment|travel|personal goal|movie|cinema|concert|game|hobby|coffee|cafe|restaurant|bar',
    caseSensitive: false,
  );
  final recurringPattern = RegExp(
    r'subscription|membership|stream|netflix|spotify|gym|club|app plan',
    caseSensitive: false,
  );
  return state.allTransactions.where((transaction) {
    final date = transaction.createdAt ?? transaction.labeledAt;
    if (transaction.amount >= 0 ||
        transaction.excludedFromInsights ||
        date == null ||
        date.isBefore(start) ||
        !date.isBefore(end)) {
      return false;
    }
    final category = transaction.category ?? '';
    final layer = _insightCategoryConfig(category).$1;
    final text =
        '$category ${transaction.title} ${transaction.detail}'.toLowerCase();
    if (recurringPattern.hasMatch(text)) return false;
    return layer == 4 || lifestylePattern.hasMatch(text);
  }).fold<double>(
    0,
    (total, transaction) => total + transaction.amount.abs(),
  );
}

/// Combined Personal Lifestyle Fund inflow (A26 subscription reserves + A27
/// payday transfers) for the last [months] calendar months, oldest first -
/// the data behind the Financial Freedom insights page's contributions bar
/// chart.
List<_MonthlyContributionPoint> _lifestyleMonthlyContributions(
  AppState state, {
  int months = 6,
}) {
  final now = DateTime.now();
  final buckets = <DateTime, double>{};
  for (var i = months - 1; i >= 0; i--) {
    final monthDate = DateTime(now.year, now.month - i, 1);
    buckets[monthDate] = 0;
  }
  const types = {'lifestyle_subscription_reserve', 'lifestyle_payday'};
  for (final entry in state.d1Ledger) {
    if (!types.contains(entry['type']?.toString())) continue;
    final date = DateTime.tryParse(entry['date']?.toString() ?? '');
    if (date == null) continue;
    final monthKey = DateTime(date.year, date.month, 1);
    if (!buckets.containsKey(monthKey)) continue;
    buckets[monthKey] =
        (buckets[monthKey] ?? 0) + ((entry['amount'] as num?)?.toDouble() ?? 0);
  }
  const monthLabels = [
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
  return buckets.entries
      .map((entry) => _MonthlyContributionPoint(
            monthLabels[entry.key.month - 1],
            entry.value,
          ))
      .toList();
}

class _MonthlyContributionPoint {
  const _MonthlyContributionPoint(this.label, this.amount);
  final String label;
  final double amount;
}

class _D1GoalCard extends StatelessWidget {
  const _D1GoalCard({required this.goal, required this.onTap});
  final _D1GoalMeta goal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final actionCount = _goalDetailActionsFor(context, goal).length;
    final onTrack = _isGoalOnTrack(goal.id, state);
    final percent = _goalPercent(goal.id, state);
    final accent = _goalProgressColor(goal.id, percent);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Neutral header (color no longer encodes the layer)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: const BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: _border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: _bellySoft,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    alignment: Alignment.center,
                    child:
                        Text(goal.emoji, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal.id,
                      style: const TextStyle(
                        color: _body,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  if (onTrack)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'On Track',
                        style: TextStyle(
                          color: accent,
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
                    goal.layerLabel,
                    style: const TextStyle(
                      color: _body,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .4,
                    ),
                  ),
                  const SizedBox(height: 2),
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
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      minHeight: 7,
                      backgroundColor: _border,
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${percent.round()}% of goal',
                    style: const TextStyle(
                      color: _body,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _GoalPillChip(
                        icon: Icons.bolt_rounded,
                        label: '$actionCount actions active',
                        color: accent,
                      ),
                      const Spacer(),
                      Text(
                        'View details',
                        style: TextStyle(
                          color: accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_rounded,
                          size: 16, color: accent),
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

Color _goalProgressColor(String goalId, double percent) {
  if (goalId == 'G1') {
    return _feasibilityColor(percent.round());
  }
  return _brand;
}

Color _feasibilityColor(int score) {
  if (score >= 80) return _sage;
  if (score >= 60) return _brand;
  if (score >= 40) return _amber;
  return _red;
}

class _GoalPillChip extends StatelessWidget {
  const _GoalPillChip(
      {required this.icon, required this.label, required this.color});
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
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

// ─── Goal detail screen ───────────────────────────────────────────────────────

class _D1GoalDetailScreen extends StatefulWidget {
  const _D1GoalDetailScreen({required this.goal, required this.onBack});
  final _D1GoalMeta goal;
  final VoidCallback onBack;

  @override
  State<_D1GoalDetailScreen> createState() => _D1GoalDetailScreenState();
}

class _D1GoalDetailScreenState extends State<_D1GoalDetailScreen> {
  bool _checkedBucket = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkedBucket) return;
    _checkedBucket = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _confirmAndEnsureFakeMayaBucketForGoal(
        context,
        AppScope.of(context),
        widget.goal.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final actions = _goalDetailActionsFor(context, goal);
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
                onPressed: widget.onBack,
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
                      style: TextStyle(
                          color: _title,
                          fontSize: 22,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: goal.layerColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  goal.layerLabel,
                  style: TextStyle(
                      color: goal.layerColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800),
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
        if (goal.id == 'G1') ...[
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _MaintainAvailableCashSummary(),
          ),
        ],
        if (goal.id == 'G3') ...[
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _EmergencyFundSummary(),
          ),
        ],
        if (goal.id == 'G5') ...[
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _GrowInvestmentsSummary(),
          ),
        ],
        if (goal.id == 'G8') ...[
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _LifestyleFundSummary(),
          ),
        ],
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
              const SizedBox(height: 10),
              _GoalActionPickerButton(goal: goal),
              const SizedBox(height: 12),
              for (var i = 0; i < actions.length; i++) ...[
                _D1ActionPanel(action: actions[i], goalColor: goal.layerColor),
                if (i < actions.length - 1) const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        if (goal.id == 'G1') ...[
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _BillObligationsPanel(),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _CashFlowTransactionsList(),
          ),
        ],
        if (goal.id == 'G3') ...[
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _EmergencyFundTransactionsList(),
          ),
        ],
        if (goal.id == 'G5') ...[
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _InvestmentTransactionsList(),
          ),
        ],
        if (goal.id == 'G8') ...[
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _LifestyleTransactionsList(),
          ),
        ],
      ],
    );
  }
}

List<_D1ActionMeta> _goalDetailActionsFor(
  BuildContext context,
  _D1GoalMeta goal,
) {
  final state = AppScope.of(context);
  if (goal.id == 'G3') {
    final selected = state.selectedActionIds
        .where(_emergencyFundGoalActionIds.contains)
        .toList();
    final ids = selected.isEmpty ? _emergencyFundGoalActionIds : selected;
    return [
      for (final id in ids) _emergencyFundD1ActionMeta(id, state),
    ].whereType<_D1ActionMeta>().toList();
  }
  if (goal.id == 'G5') {
    final selected = state.selectedActionIds
        .where(_investmentGoalActionIds.contains)
        .toList();
    final ids = selected.isEmpty ? _investmentGoalActionIds : selected;
    return [
      for (final id in ids) _investmentD1ActionMeta(id, state),
    ].whereType<_D1ActionMeta>().toList();
  }
  if (goal.id == 'G8') {
    final selected = state.selectedActionIds
        .where(_lifestyleGoalActionIds.contains)
        .toList();
    final ids = selected.isEmpty ? _lifestyleGoalActionIds : selected;
    return [
      for (final id in ids) _lifestyleD1ActionMeta(id, state),
    ].whereType<_D1ActionMeta>().toList();
  }
  if (goal.id != 'G1') return goal.actions;
  final selected = state.selectedActionIds
      .where(_availableCashGoalActionIds.contains)
      .toList();
  final ids = selected.isEmpty ? _availableCashGoalActionIds : selected;
  return [
    for (final id in ids) _availableCashD1ActionMeta(id, state),
  ].whereType<_D1ActionMeta>().toList();
}

class _GoalActionPickerButton extends StatelessWidget {
  const _GoalActionPickerButton({required this.goal});

  final _D1GoalMeta goal;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showGoalActionPicker(context, goal),
      icon: const Icon(Icons.tune_rounded, size: 18),
      label: const Text('Edit actions'),
      style: OutlinedButton.styleFrom(
        foregroundColor: goal.layerColor,
        side: BorderSide(color: goal.layerColor.withValues(alpha: .35)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

Future<void> _showGoalActionPicker(BuildContext context, _D1GoalMeta goal) {
  final state = AppScope.of(context);
  final allowedActionIds = _goalActionIds[goal.id] ?? const <String>[];
  final explicit =
      state.selectedActionIds.where(allowedActionIds.contains).toSet();
  final draft = <String>{
    if (explicit.isEmpty) ...allowedActionIds else ...explicit,
  };
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: _surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        final canSave = draft.isNotEmpty;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              18,
              20,
              20 + MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${goal.title} Actions',
                        style: const TextStyle(
                          color: _title,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final id in allowedActionIds) ...[
                  _GoalActionToggle(
                    actionId: id,
                    selected: draft.contains(id),
                    color: goal.layerColor,
                    onChanged: (selected) {
                      setSheetState(() {
                        if (selected) {
                          draft.add(id);
                        } else {
                          draft.remove(id);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                if (!canSave) ...[
                  const SizedBox(height: 2),
                  const Text(
                    'Keep at least one action active for this goal.',
                    style: TextStyle(
                      color: _red,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                FilledButton.icon(
                  onPressed: canSave
                      ? () async {
                          await _confirmAndEnsureFakeMayaBucketForGoal(
                            context,
                            state,
                            goal.id,
                          );
                          state.setActionsForGoal(
                            allowedActionIds: allowedActionIds,
                            actionIds: draft,
                          );
                          await state.saveProfile();
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        }
                      : null,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Save actions'),
                  style: FilledButton.styleFrom(
                    backgroundColor: goal.layerColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _GoalActionToggle extends StatelessWidget {
  const _GoalActionToggle({
    required this.actionId,
    required this.selected,
    required this.color,
    required this.onChanged,
  });

  final String actionId;
  final bool selected;
  final Color color;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final action = _d2Actions[actionId];
    return InkWell(
      onTap: () => onChanged(!selected),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: .08) : _bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color.withValues(alpha: .4) : _border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: selected,
              activeColor: color,
              onChanged: (value) => onChanged(value ?? false),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actionId,
                    style: const TextStyle(
                      color: _body,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    action?.text ?? actionId,
                    style: const TextStyle(
                      color: _title,
                      fontSize: 13,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                    ),
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

_D1ActionMeta? _emergencyFundD1ActionMeta(String id, AppState state) {
  final values = _configuredActionValues(state, id);
  final current = state.displayedEmergencyFundBalance;
  final monthlyEssentials = math.max(1.0, state.monthlyEssentialExpenseTotal);
  final monthsCovered = current / monthlyEssentials;
  if (id == 'A9') {
    final amount = double.tryParse(
          (values['amt'] ?? '').replaceAll(',', '').trim(),
        ) ??
        _emergencyMonthlyDepositBase(state);
    final deposited = _currentMonthEmergencyDeposits(state);
    return _D1ActionMeta(
      id: 'A9',
      text:
          'Deposit at least ${money(amount)} into the Emergency Fund each month.',
      configLabel: 'Monthly deposit',
      configValue: money(amount),
      destBucket: 'Emergency Fund',
      metrics: [
        (
          label: 'Deposited this month',
          value: money(deposited),
          icon: Icons.savings_rounded
        ),
        (
          label: 'Monthly target',
          value: money(amount),
          icon: Icons.flag_rounded
        ),
        (
          label: 'Fund balance',
          value: money(current),
          icon: Icons.shield_rounded
        ),
        (
          label: 'Months covered',
          value: monthsCovered.toStringAsFixed(1),
          icon: Icons.calendar_month_rounded
        ),
      ],
      dataPoints: [
        (
          label: 'Emergency Fund monthly deposit',
          type: 'S',
          value: money(amount)
        ),
        (label: 'Emergency Fund balance', type: 'S', value: money(current)),
        (
          label: 'Emergency Fund coverage',
          type: 'I',
          value: '${monthsCovered.toStringAsFixed(1)} months'
        ),
      ],
      activityLog: const [],
    );
  }
  if (id == 'A8') {
    final pct =
        double.tryParse((values['pct'] ?? '').replaceAll(',', '').trim()) ?? 10;
    return _D1ActionMeta(
      id: 'A8',
      text:
          'Set aside ${pct.toStringAsFixed(0)}% of each income for the Emergency Fund.',
      configLabel: 'Allocation',
      configValue: '${pct.toStringAsFixed(0)}% of income',
      destBucket: 'Emergency Fund',
      metrics: [
        (
          label: 'Fund coverage',
          value: '${monthsCovered.toStringAsFixed(1)} months',
          icon: Icons.shield_rounded
        ),
        (
          label: 'Fund balance',
          value: money(current),
          icon: Icons.savings_rounded
        ),
        (
          label: 'Pending replenish',
          value: money(state.pendingEmergencyReplenishment),
          icon: Icons.restore_rounded
        ),
        (
          label: 'Wallet available',
          value: money(state.unallocatedFakeMayaWallet),
          icon: Icons.account_balance_wallet_rounded
        ),
      ],
      dataPoints: [
        (label: 'Income transaction', type: 'S', value: 'Latest income'),
        (
          label: 'Transfer percentage',
          type: 'I',
          value: '${pct.toStringAsFixed(0)}%'
        ),
        (label: 'Emergency Fund balance', type: 'S', value: money(current)),
      ],
      activityLog: const [],
    );
  }
  if (id == 'A22') {
    final months = _configuredEmergencyCoverageMonths(state);
    final target = _configuredEmergencyCoverageTarget(state);
    return _D1ActionMeta(
      id: 'A22',
      text:
          'Build your Emergency Fund to cover ${months.toStringAsFixed(0)} months of essential expenses.',
      configLabel: 'Coverage target',
      configValue: '${months.toStringAsFixed(0)} months',
      destBucket: 'Emergency Fund',
      metrics: [
        (
          label: 'Fund balance',
          value: money(current),
          icon: Icons.savings_rounded
        ),
        (label: 'Target', value: money(target), icon: Icons.flag_rounded),
        (
          label: 'Months covered',
          value: monthsCovered.toStringAsFixed(1),
          icon: Icons.calendar_month_rounded
        ),
        (
          label: 'Gap',
          value: money(math.max(0.0, target - current)),
          icon: Icons.trending_up_rounded
        ),
      ],
      dataPoints: [
        (
          label: 'Monthly essential expenses',
          type: 'S',
          value: money(monthlyEssentials)
        ),
        (label: 'Emergency Fund target', type: 'S', value: money(target)),
        (
          label: 'Emergency Fund coverage',
          type: 'I',
          value: '${monthsCovered.toStringAsFixed(1)} months'
        ),
      ],
      activityLog: const [],
    );
  }
  if (id == 'A10') {
    final days =
        double.tryParse((values['days'] ?? '').replaceAll(',', '').trim()) ?? 7;
    return _D1ActionMeta(
      id: 'A10',
      text:
          'Replenish withdrawn Emergency Fund amounts within ${days.toStringAsFixed(0)} days after receiving income.',
      configLabel: 'Replenish within',
      configValue: '${days.toStringAsFixed(0)} days of income',
      destBucket: 'Emergency Fund',
      metrics: [
        (
          label: 'Pending replenish',
          value: money(state.pendingEmergencyReplenishment),
          icon: Icons.restore_rounded
        ),
        (
          label: 'Fund balance',
          value: money(current),
          icon: Icons.savings_rounded
        ),
        (
          label: 'Fund coverage',
          value: '${monthsCovered.toStringAsFixed(1)} months',
          icon: Icons.shield_rounded
        ),
        (
          label: 'Wallet available',
          value: money(state.unallocatedFakeMayaWallet),
          icon: Icons.account_balance_wallet_rounded
        ),
      ],
      dataPoints: [
        (
          label: 'Emergency Fund withdrawal',
          type: 'S',
          value: money(state.pendingEmergencyReplenishment)
        ),
        (
          label: 'Replenishment window',
          type: 'I',
          value: '${days.toStringAsFixed(0)} days'
        ),
        (label: 'Emergency Fund balance', type: 'S', value: money(current)),
      ],
      activityLog: const [],
    );
  }
  return null;
}

_D1ActionMeta? _investmentD1ActionMeta(String id, AppState state) {
  final values = _configuredActionValues(state, id);
  final balance = state.investmentPortfolioValue;
  if (id == 'A12') {
    final pct =
        double.tryParse((values['pct'] ?? '').replaceAll(',', '').trim()) ?? 10;
    final latestIncome = _latestIncomeTransaction(state);
    final contribution = (latestIncome?.amount ?? 0) * pct / 100;
    final done = latestIncome != null &&
        state.hasInvestmentAllocationForIncome(latestIncome.transactionId);
    return _D1ActionMeta(
      id: 'A12',
      text:
          'Allocate ${pct.toStringAsFixed(0)}% of each income to the Investment Portfolio.',
      configLabel: 'Income allocation',
      configValue: '${pct.toStringAsFixed(0)}% of income',
      destBucket: 'Investment Portfolio',
      metrics: [
        (
          label: 'Portfolio balance',
          value: money(balance),
          icon: Icons.show_chart_rounded
        ),
        (
          label: 'Latest contribution',
          value: money(contribution),
          icon: Icons.trending_up_rounded
        ),
        (
          label: 'Latest income handled',
          value: done ? 'Yes' : 'No',
          icon: Icons.verified_rounded
        ),
        (
          label: 'Wallet available',
          value: money(state.unallocatedFakeMayaWallet),
          icon: Icons.account_balance_wallet_rounded
        ),
      ],
      dataPoints: [
        (
          label: 'Income transaction',
          type: 'S',
          value: latestIncome == null
              ? 'None detected'
              : money(latestIncome.amount)
        ),
        (label: 'Contribution amount', type: 'S', value: money(contribution)),
        (label: 'Investment account balance', type: 'S', value: money(balance)),
      ],
      activityLog: const [],
    );
  }
  if (id == 'A23') {
    final amount = double.tryParse(
          (values['amt'] ?? '').replaceAll(',', '').trim(),
        ) ??
        state.investmentPortfolioTarget;
    final remaining = math.max(0.0, amount - balance);
    return _D1ActionMeta(
      id: 'A23',
      text: 'Build the Investment Portfolio to ${money(amount)}.',
      configLabel: 'Portfolio target',
      configValue: money(amount),
      destBucket: 'Investment Portfolio',
      metrics: [
        (
          label: 'Portfolio balance',
          value: money(balance),
          icon: Icons.show_chart_rounded
        ),
        (
          label: 'Portfolio target',
          value: money(amount),
          icon: Icons.flag_rounded
        ),
        (
          label: 'Remaining',
          value: money(remaining),
          icon: Icons.timelapse_rounded
        ),
        (
          label: 'Progress',
          value:
              '${amount <= 0 ? 0 : (balance / amount * 100).clamp(0, 100).round()}%',
          icon: Icons.insights_rounded
        ),
      ],
      dataPoints: [
        (label: 'Investment account balance', type: 'S', value: money(balance)),
        (label: 'Portfolio value target', type: 'I', value: money(amount)),
        (label: 'Remaining portfolio gap', type: 'I', value: money(remaining)),
      ],
      activityLog: const [],
    );
  }
  if (id == 'A30') {
    final target = double.tryParse(
          (values['pct'] ?? '').replaceAll(',', '').trim(),
        ) ??
        state.investmentTargetAnnualReturnPercent;
    final tracking = state.investmentReturnBaselineDate != null;
    final actual = state.investmentAnnualizedReturnPercent;
    final onTrack = state.isInvestmentAnnualReturnOnTrack;
    return _D1ActionMeta(
      id: 'A30',
      text:
          'Keep your investment portfolio on track to meet your target annual return on investment of ${target.toStringAsFixed(0)}%.',
      configLabel: 'Target annual return',
      configValue: '${target.toStringAsFixed(0)}%',
      destBucket: 'Investment Portfolio',
      metrics: [
        (
          label: 'Annualized return',
          value: tracking ? '${actual.toStringAsFixed(1)}%' : 'Not tracking',
          icon: actual >= 0
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded
        ),
        (
          label: 'Target annual return',
          value: '${target.toStringAsFixed(0)}%',
          icon: Icons.flag_rounded
        ),
        (
          label: tracking
              ? (onTrack ? 'Ahead of target' : 'Behind target')
              : 'Status',
          value: tracking ? (onTrack ? 'Yes' : 'No') : 'Not started',
          icon: onTrack ? Icons.check_circle_rounded : Icons.warning_rounded
        ),
        (
          label: 'Portfolio balance',
          value: money(balance),
          icon: Icons.show_chart_rounded
        ),
      ],
      dataPoints: [
        (label: 'Investment account balance', type: 'S', value: money(balance)),
        (
          label: 'Target annual return',
          type: 'I',
          value: '${target.toStringAsFixed(0)}%'
        ),
        (
          label: 'Annualized return since tracking started',
          type: 'I',
          value: tracking ? '${actual.toStringAsFixed(1)}%' : 'Not tracking'
        ),
      ],
      activityLog: const [],
    );
  }
  return null;
}

_D1ActionMeta? _lifestyleD1ActionMeta(String id, AppState state) {
  final values = _configuredActionValues(state, id);
  final available = state.lifestyleFundBalance;
  if (id == 'A26') {
    final target = _configuredActionAmount(
      state,
      'A26',
      _monthlySubscriptionBase(state),
    );
    final reserved = state.lifestyleReservedThisMonth;
    return _D1ActionMeta(
      id: id,
      text:
          'Set aside ${money(target)} each month for subscriptions and memberships.',
      configLabel: 'Monthly recurring costs',
      configValue: money(target),
      destBucket: 'Lifestyle Fund',
      metrics: [
        (
          label: 'Reserved this month',
          value: money(reserved),
          icon: Icons.subscriptions_rounded
        ),
        (
          label: 'Monthly target',
          value: money(target),
          icon: Icons.flag_rounded
        ),
        (
          label: 'Lifestyle Fund',
          value: money(available),
          icon: Icons.account_balance_wallet_rounded
        ),
        (
          label: 'Still needed',
          value: money(math.max(0.0, target - reserved)),
          icon: Icons.timelapse_rounded
        ),
      ],
      dataPoints: [
        (
          label: 'Lifestyle contribution amount',
          type: 'S',
          value: money(reserved)
        ),
        (
          label: 'Monthly recurring-cost target',
          type: 'I',
          value: money(target)
        ),
        (label: 'Lifestyle Fund balance', type: 'S', value: money(available)),
      ],
      activityLog: const [],
    );
  }
  if (id == 'A27') {
    final amount =
        double.tryParse((values['amt'] ?? '').replaceAll(',', '')) ?? 1000;
    final income = _latestIncomeTransaction(state);
    final handled = income != null &&
        state.hasLifestylePaydayAllocation(income.transactionId);
    return _D1ActionMeta(
      id: id,
      text: 'Add ${money(amount)} to the Personal Lifestyle Fund every payday.',
      configLabel: 'Every payday',
      configValue: money(amount),
      destBucket: 'Personal Lifestyle Fund',
      metrics: [
        (
          label: 'Latest payday',
          value: income == null ? 'None detected' : money(income.amount),
          icon: Icons.payments_rounded
        ),
        (
          label: 'Payday amount',
          value: money(amount),
          icon: Icons.savings_rounded
        ),
        (
          label: 'Latest payday handled',
          value: handled ? 'Yes' : 'No',
          icon: Icons.verified_rounded
        ),
        (
          label: 'Enjoyment available',
          value: money(available),
          icon: Icons.celebration_rounded
        ),
      ],
      dataPoints: [
        (
          label: 'Income transaction',
          type: 'S',
          value: income == null ? 'None detected' : money(income.amount)
        ),
        (
          label: 'Lifestyle contribution amount',
          type: 'S',
          value: money(amount)
        ),
        (label: 'Lifestyle Fund balance', type: 'S', value: money(available)),
      ],
      activityLog: const [],
    );
  }
  if (id == 'A28') {
    final limit =
        double.tryParse((values['amt'] ?? '').replaceAll(',', '')) ?? 1500;
    final spent = _currentWeekLifestyleSpend(state);
    return _D1ActionMeta(
      id: id,
      text:
          'Keep everyday enjoyment spending within ${money(limit)} each week.',
      configLabel: 'Weekly limit',
      configValue: money(limit),
      destBucket: 'Everyday enjoyment spending',
      metrics: [
        (
          label: 'Spent this week',
          value: money(spent),
          icon: Icons.receipt_long_rounded
        ),
        (label: 'Weekly limit', value: money(limit), icon: Icons.flag_rounded),
        (
          label: spent > limit ? 'Over limit' : 'Remaining',
          value: money(math.max(0.0, limit - spent)),
          icon:
              spent > limit ? Icons.warning_rounded : Icons.check_circle_rounded
        ),
        (
          label: 'Days remaining',
          value: _daysRemainingThisWeekLabel(),
          icon: Icons.calendar_today_rounded
        ),
      ],
      dataPoints: [
        (label: 'Lifestyle spending amount', type: 'S', value: money(spent)),
        (label: 'Weekly lifestyle limit', type: 'I', value: money(limit)),
      ],
      activityLog: const [],
    );
  }
  if (id == 'A29') {
    final hobbies = state.lifestyleHobbies;
    if (hobbies.isEmpty) {
      return _D1ActionMeta(
        id: id,
        text: 'Save toward a hobby or activity within a set number of months.',
        configLabel: 'Activity target',
        configValue: 'Not set up yet',
        destBucket: 'Personal Lifestyle Fund',
        metrics: const [
          (label: 'Hobbies tracked', value: '0 of 3', icon: Icons.flag_rounded),
        ],
        dataPoints: const [
          (label: 'Hobbies configured', type: 'I', value: '0'),
        ],
        activityLog: const [],
      );
    }
    var totalSaved = 0.0;
    var totalTarget = 0.0;
    DateTime? nextDue;
    for (final hobby in hobbies) {
      final hobbyId = hobby['id'].toString();
      final target = (hobby['target'] as num?)?.toDouble() ?? 0;
      final months = (hobby['months'] as num?)?.toInt() ?? 6;
      final saved = state.lifestyleHobbyBalance(hobbyId);
      totalSaved += saved;
      totalTarget += target;
      if (saved < target) {
        final started =
            state.lifestyleHobbyStartedAt(hobbyId) ?? DateTime.now();
        final due = DateTime(started.year, started.month + months, started.day);
        if (nextDue == null || due.isBefore(nextDue)) nextDue = due;
      }
    }
    final names =
        hobbies.map((hobby) => (hobby['name'] ?? '').toString()).join(', ');
    return _D1ActionMeta(
      id: id,
      text: hobbies.length == 1
          ? 'Save ${money((hobbies.first['target'] as num?)?.toDouble() ?? 0)} for $names.'
          : 'Save toward $names.',
      configLabel: 'Hobbies tracked',
      configValue: '${hobbies.length} of ${AppState.lifestyleHobbyLimit}',
      destBucket: 'Personal Lifestyle Fund',
      metrics: [
        (
          label: 'Saved across hobbies',
          value: money(totalSaved),
          icon: Icons.savings_rounded
        ),
        (
          label: 'Combined target',
          value: money(totalTarget),
          icon: Icons.flag_rounded
        ),
        (
          label: 'Still needed',
          value: money(math.max(0.0, totalTarget - totalSaved)),
          icon: Icons.timelapse_rounded
        ),
        (
          label: 'Next target date',
          value: nextDue == null ? 'All funded' : _shortDate(nextDue),
          icon: Icons.event_rounded
        ),
      ],
      dataPoints: [
        (
          label: 'Personal Lifestyle Fund balance (hobbies)',
          type: 'S',
          value: money(totalSaved)
        ),
        (label: 'Combined hobby target', type: 'I', value: money(totalTarget)),
        (label: 'Hobbies configured', type: 'I', value: '${hobbies.length}'),
      ],
      activityLog: const [],
    );
  }
  return null;
}

_D1ActionMeta? _availableCashD1ActionMeta(String id, AppState state) {
  final existing = _d1GoalMetas
      .firstWhere((goal) => goal.id == 'G1')
      .actions
      .where((action) => action.id == id)
      .firstOrNull;
  final values = state.actionFieldValues[id] ?? const <String, String>{};
  final d2 = _d2Actions[id];
  if (id == 'A1' && existing != null) {
    final pct = values['pct'] ?? '50';
    return _copyD1ActionMeta(
      existing,
      text:
          'Set aside $pct% of each income received into an Everyday Expenses Fund.',
      configValue: '$pct% of income',
    );
  }
  if (id == 'A3' && existing != null) {
    final budgets = state.categorySpendingBudgets;
    final amount = values['amt'];
    final categories = values['categories'];
    return _copyD1ActionMeta(
      existing,
      text: d2?.text ?? existing.text,
      configValue: budgets.isNotEmpty
          ? '${budgets.length} category budget(s)'
          : amount == null
              ? 'Set per category'
              : '${money(double.tryParse(amount) ?? 0)} per month',
      destBucket:
          categories?.isNotEmpty == true ? categories! : existing.destBucket,
    );
  }
  if (id == 'A2') {
    final amount = double.tryParse(values['amt'] ?? '') ??
        math.max(1000.0, state.monthlyNonEssentialExpenseTotal);
    return _D1ActionMeta(
      id: 'A2',
      text:
          'Cap total discretionary spending at ${money(amount)} per month so your essentials stay covered.',
      configLabel: 'Discretionary cap',
      configValue: money(amount),
      destBucket: 'Everyday cash flow',
      metrics: [
        (label: 'Monthly cap', value: money(amount), icon: Icons.lock_rounded),
        (
          label: 'Discretionary baseline',
          value: money(state.monthlyNonEssentialExpenseTotal),
          icon: Icons.shopping_bag_rounded
        ),
        (
          label: 'Wallet',
          value: money(state.accountBalance('Wallet')),
          icon: Icons.account_balance_wallet_rounded
        ),
        (
          label: 'Essential fund',
          value: money(state.essentialExpensesBalance),
          icon: Icons.savings_rounded
        ),
      ],
      dataPoints: [
        (label: 'Spending cap', type: 'S', value: money(amount)),
        (
          label: 'Monthly non-essential baseline',
          type: 'S',
          value: money(state.monthlyNonEssentialExpenseTotal)
        ),
        (
          label: 'Available wallet balance',
          type: 'S',
          value: money(state.accountBalance('Wallet'))
        ),
      ],
      activityLog: const [],
    );
  }
  if (id == 'A20') {
    final monthlyIncome = _monthlyIncomeBase(state);
    final monthlyExpenses = _monthlyExpenseBase(state);
    final recommended = d2 == null
        ? _recommendedMonthlyEarnings(state)
        : double.parse(
            _recommendationsForActionField(state, d2, d2.fields.first).first);
    final amount = double.tryParse(values['amt'] ?? '') ?? recommended;
    return _D1ActionMeta(
      id: 'A20',
      text:
          'Bring in at least ${money(amount)} this month from income, side gigs, or other cash-in so your available cash target stays on pace.',
      configLabel: 'Monthly cash-in target',
      configValue: money(amount),
      destBucket: 'Monthly cash flow',
      metrics: [
        (
          label: 'Cash-in target',
          value: money(amount),
          icon: Icons.flag_rounded
        ),
        (
          label: 'Income baseline',
          value: money(monthlyIncome),
          icon: Icons.payments_rounded
        ),
        (
          label: 'Monthly expenses',
          value: money(monthlyExpenses),
          icon: Icons.receipt_long_rounded
        ),
        (
          label: 'Cash flow',
          value: money(monthlyIncome - monthlyExpenses),
          icon: Icons.trending_up_rounded
        ),
      ],
      dataPoints: [
        (label: 'Monthly cash-in target', type: 'S', value: money(amount)),
        (
          label: 'Income transaction amount',
          type: 'S',
          value: money(monthlyIncome)
        ),
        (
          label: 'Current available cash balance',
          type: 'S',
          value: money(state.accountBalance('Wallet'))
        ),
      ],
      activityLog: const [],
    );
  }
  if (id == 'A19') {
    final monthlyExpenseBase = _monthlyExpenseBase(state);
    final recommended = d2 == null
        ? _recommendedEssentialFundFloor(state)
        : double.parse(
            _recommendationsForActionField(state, d2, d2.fields.first).first);
    final amount = double.tryParse(values['amt'] ?? '') ?? recommended;
    final currentFund = state.essentialExpensesBalance;
    final monthlyExpenses = math.max(1.0, monthlyExpenseBase);
    final monthsCovered = currentFund / monthlyExpenses;
    return _D1ActionMeta(
      id: 'A19',
      text:
          'Keep at least ${money(amount)} in your Essential Expenses Fund so essentials stay covered even before the next income arrives.',
      configLabel: 'Essential Expenses Fund minimum',
      configValue: money(amount),
      destBucket: 'Essential Expenses Fund',
      metrics: [
        (
          label: 'Minimum floor',
          value: money(amount),
          icon: Icons.horizontal_rule_rounded
        ),
        (
          label: 'Essential fund',
          value: money(currentFund),
          icon: Icons.savings_rounded
        ),
        (
          label: 'Monthly expenses',
          value: money(monthlyExpenses),
          icon: Icons.receipt_long_rounded
        ),
        (
          label: 'Months covered',
          value: monthsCovered.toStringAsFixed(1),
          icon: Icons.calendar_month_rounded
        ),
      ],
      dataPoints: [
        (
          label: 'Essential Expenses Fund floor',
          type: 'S',
          value: money(amount)
        ),
        (
          label: 'Essential Expenses Fund balance',
          type: 'S',
          value: money(currentFund)
        ),
        (
          label: 'Monthly expense baseline',
          type: 'S',
          value: money(monthlyExpenses)
        ),
      ],
      activityLog: const [],
    );
  }
  if (id == 'A21') {
    final days = double.tryParse(values['days'] ?? '') ?? 14;
    final daily = math.max(1.0, state.monthlyEssentialExpenseTotal / 30);
    final target = daily * days;
    return _D1ActionMeta(
      id: 'A21',
      text:
          "Keep at least ${days.toStringAsFixed(0)} days' worth of expenses available in your Everyday Fund at all times.",
      configLabel: 'Everyday fund floor',
      configValue: '${days.toStringAsFixed(0)} days',
      destBucket: 'Everyday Fund',
      metrics: [
        (label: 'Target floor', value: money(target), icon: Icons.flag_rounded),
        (
          label: 'Daily expenses',
          value: money(daily),
          icon: Icons.today_rounded
        ),
        (
          label: 'Everyday fund',
          value: money(
              math.max(state.essentialExpensesBalance, state.needsBalance)),
          icon: Icons.savings_rounded
        ),
        (
          label: 'Wallet',
          value: money(state.accountBalance('Wallet')),
          icon: Icons.account_balance_wallet_rounded
        ),
      ],
      dataPoints: [
        (
          label: 'Required days available',
          type: 'I',
          value: days.toStringAsFixed(0)
        ),
        (label: 'Target floor amount', type: 'S', value: money(target)),
        (label: 'Daily essential estimate', type: 'S', value: money(daily)),
      ],
      activityLog: const [],
    );
  }
  return existing;
}

_D1ActionMeta _copyD1ActionMeta(
  _D1ActionMeta action, {
  String? text,
  String? configValue,
  String? destBucket,
}) {
  return _D1ActionMeta(
    id: action.id,
    text: text ?? action.text,
    configLabel: action.configLabel,
    configValue: configValue ?? action.configValue,
    destBucket: destBucket ?? action.destBucket,
    metrics: action.metrics,
    dataPoints: action.dataPoints,
    activityLog: action.activityLog,
  );
}

class _MaintainAvailableCashSummary extends StatelessWidget {
  const _MaintainAvailableCashSummary();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final now = DateTime.now();
    final spent = (state.fakeMayaLink?.summary.transactions ??
            const <FakeMayaTransaction>[])
        .where((transaction) =>
            transaction.amount < 0 &&
            transaction.isLabeled &&
            !transaction.excludedFromInsights &&
            transaction.createdAt?.year == now.year &&
            transaction.createdAt?.month == now.month &&
            _insightCategoryConfig(transaction.category ?? '').$1 == 1)
        .fold(0.0, (total, transaction) => total + transaction.amount.abs());
    final wallet = state.fakeMayaLink?.summary.wallet ?? 0;
    final expected = _maintainAvailableCashExpectedSpend(state);
    final remaining = math.max(0.0, expected - spent);
    final feasibility = maintainAvailableCashFeasibility(state);
    final feasibilityColor = _feasibilityColor(feasibility);
    final feasibilityLabel = feasibility >= 80
        ? 'Strong'
        : feasibility >= 60
            ? 'Workable'
            : feasibility >= 40
                ? 'Needs attention'
                : 'At risk';
    final coveragePercent = remaining <= 0
        ? 100
        : ((wallet / remaining).clamp(0.0, 1.0) * 100).round();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MONTHLY CASH POSITION',
            style: TextStyle(
              color: _body,
              fontSize: 10,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CashPositionMetric(
                  icon: Icons.receipt_long_rounded,
                  label: 'Basic needs',
                  value: money(expected),
                  color: _purple,
                  onTap: () => _showExpectedSpendDetail(context, state),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _CashPositionMetric(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'In wallet',
                  value: money(wallet),
                  color: _brand,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _CashPositionMetric(
                  icon: Icons.payments_rounded,
                  label: 'Cash flow spent',
                  value: money(spent),
                  color: _amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: feasibilityColor.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: feasibilityColor.withValues(alpha: .18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Goal feasibility · $feasibilityLabel',
                        style: const TextStyle(
                          color: _title,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '$feasibility%',
                      style: TextStyle(
                        color: feasibilityColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: feasibility / 100,
                    minHeight: 9,
                    color: feasibilityColor,
                    backgroundColor: feasibilityColor.withValues(alpha: .14),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  expected <= 0
                      ? 'Complete the Monthly Expenses baseline to calculate feasibility.'
                      : 'Your wallet covers $coveragePercent% of the ${money(remaining)} still expected this month. The score also considers essential-fund allocation, spending against plan, and your latest income.',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 10.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
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

class _BillObligationsPanel extends StatelessWidget {
  const _BillObligationsPanel();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final openBills = state.openBasicNeedsBillObligations;
    final totalNeed = state.openBasicNeedsBillNeed;
    final scheduledCount = _scheduledBasicNeedsBills(state).length;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _amber.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: _amber,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Needs Bills',
                      style: TextStyle(
                        color: _title,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      totalNeed > 0
                          ? '${money(totalNeed)} still needs to be covered'
                          : scheduledCount > 0
                              ? '$scheduledCount scheduled bill${scheduledCount == 1 ? '' : 's'} ready to check'
                              : 'Add a scheduled Basic Needs bill first',
                      style: const TextStyle(
                        color: _body,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _showBillPlanSheet(context),
                icon: const Icon(Icons.playlist_add_rounded, size: 18),
                label: const Text('Check bill'),
              ),
            ],
          ),
          if (openBills.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final bill in openBills.take(3)) ...[
              _BillObligationRow(bill: bill),
              if (bill != openBills.take(3).last)
                const Divider(height: 14, color: _border),
            ],
          ],
        ],
      ),
    );
  }
}

class _BillObligationRow extends StatelessWidget {
  const _BillObligationRow({required this.bill});

  final Map<String, dynamic> bill;

  @override
  Widget build(BuildContext context) {
    final expected = _doubleValue(bill['expectedAmount'], 0);
    final paid = _doubleValue(bill['paidAmount'], 0);
    final remaining = math.max(0.0, expected - paid);
    final dueDate = DateTime.tryParse(bill['dueDate']?.toString() ?? '');
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bill['name']?.toString() ?? 'Basic needs bill',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _title,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                dueDate == null
                    ? 'Paid ${money(paid)} of ${money(expected)}'
                    : '${_shortDate(dueDate)} · Paid ${money(paid)} of ${money(expected)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _body,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: _red.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _red.withValues(alpha: .18)),
          ),
          child: Text(
            money(remaining),
            style: const TextStyle(
              color: _red,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _showBillPlanSheet(BuildContext context) async {
  final state = AppScope.of(context);
  final openBills = state.openBasicNeedsBillObligations;
  final scheduledBills = _scheduledBasicNeedsBills(state);
  final currentMonth = _monthStart(DateTime.now());
  final candidates = <({
    String label,
    String? obligationId,
    String name,
    double amount,
    double paid,
    DateTime? dueDate
  })>[
    for (final bill in openBills)
      (
        label:
            '${bill['name'] ?? 'Bill'} · remaining ${money(_billRemaining(bill))}',
        obligationId: bill['id']?.toString(),
        name: bill['name']?.toString() ?? 'Basic needs bill',
        amount: _doubleValue(bill['expectedAmount'], 0),
        paid: _doubleValue(bill['paidAmount'], 0),
        dueDate: DateTime.tryParse(bill['dueDate']?.toString() ?? ''),
      ),
    for (final expense in scheduledBills)
      (
        label:
            '${expense['name']?.toString() ?? 'Basic needs bill'} · ${_shortDate(_scheduledBillDueDateForMonth(expense, currentMonth) ?? currentMonth)}',
        obligationId: null,
        name: expense['name']?.toString() ?? 'Basic needs bill',
        amount: _doubleValue(expense['amount'], 0),
        paid: 0.0,
        dueDate: _scheduledBillDueDateForMonth(expense, currentMonth),
      ),
  ];
  final hasBillCandidates = candidates.isNotEmpty;
  final initial = candidates.isNotEmpty
      ? candidates.first
      : (
          label: 'No scheduled bill',
          obligationId: null,
          name: '',
          amount: 0.0,
          paid: 0.0,
          dueDate: null,
        );
  var selected = initial;
  final nameController = TextEditingController(text: initial.name);
  final amountController =
      TextEditingController(text: initial.amount.toStringAsFixed(0));
  final essentialController = TextEditingController();
  final walletController = TextEditingController();
  final savingsController = TextEditingController();
  DateTime dueDate = initial.dueDate ?? DateTime.now();

  void applyRecommendation() {
    final amount = _moneyFieldValue(amountController);
    var remaining = math.max(0, amount - selected.paid);
    final essential = math.min(state.essentialExpensesBalance, remaining);
    remaining -= essential;
    final wallet = math.min(state.accountBalance('Wallet'), remaining);
    remaining -= wallet;
    final savings = math.min(state.safetyShieldBalance, remaining);
    essentialController.text = essential.toStringAsFixed(0);
    walletController.text = wallet.toStringAsFixed(0);
    savingsController.text = savings.toStringAsFixed(0);
  }

  applyRecommendation();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: _surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final amount = _moneyFieldValue(amountController);
          final essential = _moneyFieldValue(essentialController);
          final wallet = _moneyFieldValue(walletController);
          final savings = _moneyFieldValue(savingsController);
          final dueNow = math.max(0.0, amount - selected.paid);
          final planned =
              math.min(dueNow, essential + wallet + savings).toDouble();
          final unpaid = math.max(0.0, dueNow - planned);
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Can I pay this bill?',
                      style: TextStyle(
                        color: _title,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasBillCandidates
                          ? 'Choose a scheduled basic-needs bill, then adjust where the money will come from.'
                          : 'Only Basic Needs expenses with a scheduled date can be checked as bills.',
                      style: const TextStyle(
                        color: _body,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (!hasBillCandidates) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _amber.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _amber.withValues(alpha: .2),
                          ),
                        ),
                        child: const Text(
                          'Unscheduled expenses are treated as monthly category estimates. Add a scheduled date to a Basic Needs expense before using bill readiness.',
                          style: TextStyle(
                            color: _body,
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                    if (hasBillCandidates) ...[
                      DropdownButtonFormField<String>(
                        value: selected.label,
                        isExpanded: true,
                        decoration: inputDecoration('Bill').copyWith(
                          labelText: 'Bill',
                        ),
                        items: [
                          for (final candidate in candidates)
                            DropdownMenuItem(
                              value: candidate.label,
                              child: Text(
                                candidate.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          final next = candidates.firstWhere(
                            (candidate) => candidate.label == value,
                            orElse: () => selected,
                          );
                          setSheetState(() {
                            selected = next;
                            nameController.text = next.name;
                            amountController.text =
                                next.amount.toStringAsFixed(0);
                            dueDate = next.dueDate ?? DateTime.now();
                            applyRecommendation();
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            decoration: inputDecoration('Bill name').copyWith(
                              labelText: 'Bill name',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: inputDecoration('Amount').copyWith(
                              labelText: 'Amount',
                              prefixText: '₱ ',
                              helperText: selected.paid > 0
                                  ? '${money(selected.paid)} already covered'
                                  : null,
                            ),
                            onChanged: (_) =>
                                setSheetState(applyRecommendation),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _BillSourceField(
                          controller: essentialController,
                          label: 'Essential fund',
                          helper: money(state.essentialExpensesBalance),
                          onChanged: () => setSheetState(() {}),
                        ),
                        _BillSourceField(
                          controller: walletController,
                          label: 'Wallet',
                          helper: money(state.accountBalance('Wallet')),
                          onChanged: () => setSheetState(() {}),
                        ),
                        _BillSourceField(
                          controller: savingsController,
                          label: 'Savings',
                          helper: money(state.safetyShieldBalance),
                          onChanged: () => setSheetState(() {}),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: unpaid > 0
                            ? _red.withValues(alpha: .07)
                            : _sage.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: unpaid > 0
                              ? _red.withValues(alpha: .18)
                              : _sage.withValues(alpha: .2),
                        ),
                      ),
                      child: Text(
                        unpaid > 0
                            ? '${money(planned)} can be paid now. ${money(unpaid)} will stay as unpaid.'
                            : '${money(planned)} covers this bill.',
                        style: TextStyle(
                          color: unpaid > 0 ? _red : _sage,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => setSheetState(applyRecommendation),
                          child: const Text('Use recommendation'),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: !hasBillCandidates || amount <= 0
                              ? null
                              : () async {
                                  await state.recordBasicNeedsBillPlan(
                                    obligationId: selected.obligationId,
                                    name: nameController.text,
                                    expectedAmount: amount,
                                    fromEssentialFund: essential,
                                    fromWallet: wallet,
                                    fromSavings: savings,
                                    dueDate: dueDate,
                                  );
                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                  }
                                },
                          child: const Text('Record plan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );

  nameController.dispose();
  amountController.dispose();
  essentialController.dispose();
  walletController.dispose();
  savingsController.dispose();
}

double _moneyFieldValue(TextEditingController controller) {
  return double.tryParse(controller.text.replaceAll(',', '').trim()) ?? 0;
}

class _BillSourceField extends StatelessWidget {
  const _BillSourceField({
    required this.controller,
    required this.label,
    required this.helper,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String helper;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 154,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: inputDecoration(label).copyWith(
          labelText: label,
          helperText: helper,
          prefixText: '₱ ',
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }
}

class _CashPositionMetric extends StatelessWidget {
  const _CashPositionMetric(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color,
      this.onTap});
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(height: 7),
          Text(label,
              maxLines: 2,
              style: const TextStyle(
                  color: _body,
                  fontSize: 9.5,
                  height: 1.15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: const TextStyle(
                    color: _title, fontSize: 13, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: content,
    );
  }
}

class _EmergencyFundSummary extends StatelessWidget {
  const _EmergencyFundSummary();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final monthlyEssentials = state.monthlyEssentialExpenseTotal;
    final current = state.displayedEmergencyFundBalance;
    final pending = state.pendingEmergencyReplenishment;
    final target = _financialSafetyGoalTarget(state);
    final coverageMonths =
        monthlyEssentials > 0 ? current / monthlyEssentials : 0.0;
    final latestIncome = _latestIncomeTransaction(state);
    final contributionMade = latestIncome != null &&
        state.hasEmergencyAllocationForIncome(latestIncome.transactionId);
    final targetProgress = (current / target).clamp(0.0, 1.0);
    final recoveryScore = pending <= 0
        ? 1.0
        : (state.unallocatedFakeMayaWallet / pending).clamp(0.0, 1.0);
    final contributionScore = contributionMade ? 1.0 : 0.0;
    final feasibility = ((targetProgress * .65 +
                recoveryScore * .20 +
                contributionScore * .15) *
            100)
        .round();
    final scoreColor = feasibility >= 80
        ? _sage
        : feasibility >= 60
            ? _brand
            : feasibility >= 40
                ? _amber
                : _red;
    final scoreLabel = feasibility >= 80
        ? 'Strong'
        : feasibility >= 60
            ? 'Workable'
            : feasibility >= 40
                ? 'Needs attention'
                : 'At risk';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FINANCIAL SAFETY POSITION',
            style: TextStyle(
              color: _body,
              fontSize: 10,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CashPositionMetric(
                  icon: Icons.shield_rounded,
                  label: 'Emergency fund',
                  value: money(current),
                  color: _amber,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _CashPositionMetric(
                  icon: Icons.restore_rounded,
                  label: 'To replenish',
                  value: money(pending),
                  color: pending > 0 ? _red : _sage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scoreColor.withValues(alpha: .18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Goal feasibility · $scoreLabel',
                        style: const TextStyle(
                          color: _title,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '$feasibility%',
                      style: TextStyle(
                        color: scoreColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: feasibility / 100,
                    minHeight: 9,
                    color: scoreColor,
                    backgroundColor: scoreColor.withValues(alpha: .14),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'The fund covers ${coverageMonths.toStringAsFixed(1)} months of essential expenses toward a 3-month target of ${money(target)}. The score also considers pending replenishment and whether the latest income received its 10% contribution.',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 10.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
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

class _CashFlowTransactionsList extends StatelessWidget {
  const _CashFlowTransactionsList();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final transactions = (state.fakeMayaLink?.summary.transactions ??
            const <FakeMayaTransaction>[])
        .where((transaction) =>
            transaction.isLabeled &&
            !transaction.excludedFromInsights &&
            _insightCategoryConfig(transaction.category ?? '').$1 == 1)
        .toList()
      ..sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CASH FLOW & BASIC NEEDS TRANSACTIONS',
          style: TextStyle(
            color: _body,
            fontSize: 11,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        if (transactions.isEmpty)
          const AppCard(
            child: Text(
              'No labeled Cash Flow & Basic Needs transactions yet.',
              style: TextStyle(
                color: _body,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < transactions.length; i++) ...[
                  _CashFlowTransactionRow(transaction: transactions[i]),
                  if (i < transactions.length - 1)
                    const Divider(height: 18, color: _border),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _CashFlowTransactionRow extends StatelessWidget {
  const _CashFlowTransactionRow({required this.transaction});
  final FakeMayaTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final incoming = transaction.amount >= 0;
    final color = incoming ? _sage : _red;
    final category = _insightCategoryConfig(transaction.category ?? '');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: category.$4.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(category.$3, color: category.$4, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _title,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${category.$2} · ${transaction.age}',
                style: const TextStyle(
                  color: _body,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${incoming ? '+' : '-'}${money(transaction.amount.abs())}',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _GrowInvestmentsSummary extends StatelessWidget {
  const _GrowInvestmentsSummary();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final balance = state.investmentPortfolioValue;
    final target =
        _configuredActionAmount(state, 'A23', state.investmentPortfolioTarget);
    final latestIncome = _latestIncomeTransaction(state);
    final contributionMade = latestIncome != null &&
        state.hasInvestmentAllocationForIncome(latestIncome.transactionId);
    final targetProgress =
        target <= 0 ? 0.0 : (balance / target).clamp(0.0, 1.0);
    final contributionScore = contributionMade ? 1.0 : 0.0;
    final returnTarget = state.investmentTargetAnnualReturnPercent;
    final returnTracking = state.investmentReturnBaselineDate != null;
    final returnScore = !returnTracking
        ? 0.5 // neutral until the user starts tracking an annual return
        : returnTarget <= 0
            ? 1.0
            : (state.investmentAnnualizedReturnPercent / returnTarget)
                .clamp(0.0, 1.0);
    final feasibility =
        ((targetProgress * .40 + returnScore * .35 + contributionScore * .25) *
                100)
            .round();
    final scoreColor = feasibility >= 80
        ? _sage
        : feasibility >= 60
            ? _brand
            : feasibility >= 40
                ? _amber
                : _red;
    final scoreLabel = feasibility >= 80
        ? 'Strong'
        : feasibility >= 60
            ? 'Workable'
            : feasibility >= 40
                ? 'Needs attention'
                : 'At risk';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACCUMULATING WEALTH POSITION',
            style: TextStyle(
              color: _body,
              fontSize: 10,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CashPositionMetric(
                  icon: Icons.show_chart_rounded,
                  label: 'Portfolio balance',
                  value: money(balance),
                  color: _purple,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _CashPositionMetric(
                  icon: state.investmentNetReturnThisMonth >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  label: 'Net return this month',
                  value: money(state.investmentNetReturnThisMonth),
                  color: state.investmentNetReturnThisMonth >= 0 ? _sage : _red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scoreColor.withValues(alpha: .18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Goal feasibility · $scoreLabel',
                        style: const TextStyle(
                          color: _title,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '$feasibility%',
                      style: TextStyle(
                        color: scoreColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: feasibility / 100,
                    minHeight: 9,
                    color: scoreColor,
                    backgroundColor: scoreColor.withValues(alpha: .14),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Your portfolio is ${(targetProgress * 100).round()}% of the ${money(target)} target. The score also considers whether the latest income was invested and how the annualized return compares with your ${returnTarget.toStringAsFixed(0)}% target.',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 10.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
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

class _LifestyleFundSummary extends StatelessWidget {
  const _LifestyleFundSummary();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final subscriptionTarget = _configuredActionAmount(
      state,
      'A26',
      _monthlySubscriptionBase(state),
    );
    final weeklyLimit = _configuredActionAmount(state, 'A28', 1500);
    final hobbies = state.lifestyleHobbies;
    final hobbyTotalTarget = hobbies.fold<double>(
      0,
      (total, hobby) => total + ((hobby['target'] as num?)?.toDouble() ?? 0),
    );
    final hobbyTotalSaved = hobbies.fold<double>(
      0,
      (total, hobby) =>
          total + state.lifestyleHobbyBalance(hobby['id'].toString()),
    );
    final reserved = state.lifestyleReservedThisMonth;
    final weeklySpent = _currentWeekLifestyleSpend(state);
    final recurringProgress = subscriptionTarget <= 0
        ? 0.0
        : (reserved / subscriptionTarget).clamp(0.0, 1.0);
    final weeklyScore =
        weeklyLimit <= 0 || weeklySpent <= weeklyLimit ? 1.0 : 0.0;
    final activityProgress = hobbyTotalTarget <= 0
        ? 0.0
        : (hobbyTotalSaved / hobbyTotalTarget).clamp(0.0, 1.0);
    final score =
        ((recurringProgress * .4 + weeklyScore * .25 + activityProgress * .35) *
                100)
            .round();
    final color = score >= 70
        ? _sage
        : score >= 40
            ? _amber
            : _red;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LIFESTYLE FUND POSITION',
            style: TextStyle(
              color: _body,
              fontSize: 10,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CashPositionMetric(
                  icon: Icons.celebration_rounded,
                  label: 'Enjoyment available',
                  value: money(state.lifestyleFundBalance),
                  color: const Color(0xFF4F86C6),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _CashPositionMetric(
                  icon: Icons.savings_rounded,
                  label: 'Activity savings',
                  value: money(hobbyTotalSaved),
                  color: _purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Lifestyle funding progress',
                  style: TextStyle(
                    color: _title,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$score%',
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            color: color,
            backgroundColor: color.withValues(alpha: .12),
          ),
          const SizedBox(height: 7),
          Text(
            '${money(reserved)} of ${money(subscriptionTarget)} is reserved for recurring lifestyle costs. This week\'s enjoyment spending is ${money(weeklySpent)} of ${money(weeklyLimit)}.',
            style: const TextStyle(
              color: _body,
              fontSize: 10.5,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyActivityItem {
  const _EmergencyActivityItem(
      {required this.title,
      required this.detail,
      required this.amount,
      required this.date,
      required this.incoming,
      required this.icon});
  final String title;
  final String detail;
  final double amount;
  final DateTime? date;
  final bool incoming;
  final IconData icon;
}

class _EmergencyFundTransactionsList extends StatelessWidget {
  const _EmergencyFundTransactionsList();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final activity = <_EmergencyActivityItem>[];
    for (final transaction in state.fakeMayaLink?.summary.transactions ??
        const <FakeMayaTransaction>[]) {
      if (!transaction.isLabeled ||
          transaction.excludedFromInsights ||
          _insightCategoryConfig(transaction.category ?? '').$1 != 2) {
        continue;
      }
      final category = _insightCategoryConfig(transaction.category ?? '');
      activity.add(_EmergencyActivityItem(
        title: transaction.title,
        detail: category.$2,
        amount: transaction.amount.abs(),
        date: transaction.createdAt ?? transaction.labeledAt,
        incoming: transaction.amount >= 0,
        icon: category.$3,
      ));
    }
    for (final entry in state.d1Ledger) {
      final type = entry['type']?.toString() ?? '';
      final amount = (entry['amount'] as num?)?.toDouble() ?? 0;
      final date = DateTime.tryParse(entry['date']?.toString() ?? '');
      switch (type) {
        case 'emergency_deposit':
          activity.add(_EmergencyActivityItem(
            title: 'Income contribution',
            detail: '10% deposited to Emergency Fund',
            amount: amount,
            date: date,
            incoming: true,
            icon: Icons.savings_rounded,
          ));
        case 'use_emergency':
          activity.add(_EmergencyActivityItem(
            title: 'Emergency Fund used',
            detail: 'Waiting to be replenished',
            amount: amount,
            date: date,
            incoming: false,
            icon: Icons.outbox_rounded,
          ));
        case 'ef_replenish':
          activity.add(_EmergencyActivityItem(
            title: 'Emergency Fund replenished',
            detail: 'Withdrawn amount restored',
            amount: amount,
            date: date,
            incoming: true,
            icon: Icons.restore_rounded,
          ));
      }
    }
    activity.sort((a, b) => (b.date ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.date ?? DateTime.fromMillisecondsSinceEpoch(0)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FINANCIAL SAFETY TRANSACTIONS',
          style: TextStyle(
            color: _body,
            fontSize: 11,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        if (activity.isEmpty)
          const AppCard(
            child: Text(
              'No Financial Safety or Emergency Fund activity yet.',
              style: TextStyle(
                color: _body,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < activity.length; i++) ...[
                  _EmergencyActivityRow(item: activity[i]),
                  if (i < activity.length - 1)
                    const Divider(height: 18, color: _border),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _InvestmentTransactionsList extends StatelessWidget {
  const _InvestmentTransactionsList();

  @override
  Widget build(BuildContext context) {
    final activity = <_EmergencyActivityItem>[];
    for (final entry in AppScope.of(context).d1Ledger) {
      final type = entry['type']?.toString() ?? '';
      final amount = (entry['amount'] as num?)?.toDouble() ?? 0;
      final date = DateTime.tryParse(entry['date']?.toString() ?? '');
      switch (type) {
        case 'investment_deposit':
          final percentage = (entry['percentage'] as num?)?.toDouble() ?? 10;
          activity.add(
            _EmergencyActivityItem(
              title: 'Income contribution',
              detail:
                  '${percentage.toStringAsFixed(0)}% deposited to Investment Portfolio',
              amount: amount,
              date: date,
              incoming: true,
              icon: Icons.trending_up_rounded,
            ),
          );
        case 'investment_sweep':
          final percentage = (entry['percentage'] as num?)?.toDouble() ?? 50;
          activity.add(
            _EmergencyActivityItem(
              title: 'Month-end sweep',
              detail:
                  '${percentage.toStringAsFixed(0)}% of unspent funds invested',
              amount: amount,
              date: date,
              incoming: true,
              icon: Icons.auto_graph_rounded,
            ),
          );
        case 'investment_monthly':
          activity.add(
            _EmergencyActivityItem(
              title: 'Monthly contribution',
              detail: 'Invested toward this month\'s target',
              amount: amount,
              date: date,
              incoming: true,
              icon: Icons.flag_rounded,
            ),
          );
        case 'investment_windfall':
          final percentage = (entry['percentage'] as num?)?.toDouble() ?? 50;
          activity.add(
            _EmergencyActivityItem(
              title: 'Windfall contribution',
              detail:
                  '${percentage.toStringAsFixed(0)}% of unexpected cash-in invested',
              amount: amount,
              date: date,
              incoming: true,
              icon: Icons.bolt_rounded,
            ),
          );
        case 'investment_review':
          activity.add(
            _EmergencyActivityItem(
              title: 'Portfolio reviewed',
              detail: 'Review and rebalance check completed',
              amount: 0,
              date: date,
              incoming: true,
              icon: Icons.fact_check_rounded,
            ),
          );
        case 'investment_gain':
          activity.add(
            _EmergencyActivityItem(
              title: 'Investment earnings',
              detail: 'Portfolio gain recorded',
              amount: amount,
              date: date,
              incoming: true,
              icon: Icons.trending_up_rounded,
            ),
          );
        case 'investment_loss':
          activity.add(
            _EmergencyActivityItem(
              title: 'Investment loss',
              detail: 'Portfolio loss recorded',
              amount: amount,
              date: date,
              incoming: false,
              icon: Icons.trending_down_rounded,
            ),
          );
      }
    }
    activity.sort((a, b) => (b.date ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.date ?? DateTime.fromMillisecondsSinceEpoch(0)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACCUMULATING WEALTH TRANSACTIONS',
          style: TextStyle(
            color: _body,
            fontSize: 11,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        if (activity.isEmpty)
          const AppCard(
            child: Text(
              'No Investment Portfolio activity yet.',
              style: TextStyle(
                color: _body,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < activity.length; i++) ...[
                  _EmergencyActivityRow(item: activity[i]),
                  if (i < activity.length - 1)
                    const Divider(height: 18, color: _border),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _LifestyleTransactionsList extends StatelessWidget {
  const _LifestyleTransactionsList();

  @override
  Widget build(BuildContext context) {
    final activity = <_EmergencyActivityItem>[];
    for (final entry in AppScope.of(context).d1Ledger) {
      final amount = (entry['amount'] as num?)?.toDouble() ?? 0;
      final date = DateTime.tryParse(entry['date']?.toString() ?? '');
      switch (entry['type']) {
        case 'lifestyle_subscription_reserve':
          activity.add(_EmergencyActivityItem(
            title: 'Recurring costs reserved',
            detail: 'Subscriptions and memberships',
            amount: amount,
            date: date,
            incoming: true,
            icon: Icons.subscriptions_rounded,
          ));
        case 'lifestyle_payday':
          activity.add(_EmergencyActivityItem(
            title: 'Payday enjoyment contribution',
            detail: 'Added to Personal Lifestyle Fund',
            amount: amount,
            date: date,
            incoming: true,
            icon: Icons.celebration_rounded,
          ));
        case 'lifestyle_activity_deposit':
          activity.add(_EmergencyActivityItem(
            title: 'Activity savings',
            detail: 'Added to Hobby or Activity Fund',
            amount: amount,
            date: date,
            incoming: true,
            icon: Icons.savings_rounded,
          ));
      }
    }
    activity.sort((a, b) => (b.date ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.date ?? DateTime.fromMillisecondsSinceEpoch(0)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LIFESTYLE FUND ACTIVITY',
          style: TextStyle(
            color: _body,
            fontSize: 11,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        if (activity.isEmpty)
          const AppCard(
            child: Text(
              'No Lifestyle Fund activity yet.',
              style: TextStyle(
                color: _body,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < activity.length; i++) ...[
                  _EmergencyActivityRow(item: activity[i]),
                  if (i < activity.length - 1)
                    const Divider(height: 18, color: _border),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _EmergencyActivityRow extends StatelessWidget {
  const _EmergencyActivityRow({required this.item});
  final _EmergencyActivityItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.incoming ? _sage : _red;
    final localizations = MaterialLocalizations.of(context);
    final dateText = item.date == null
        ? 'Date unavailable'
        : '${localizations.formatShortDate(item.date!)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(item.date!))}';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, color: color, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title,
                  style: const TextStyle(
                      color: _title, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text('${item.detail} · $dateText',
                  style: const TextStyle(
                      color: _body, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${item.incoming ? '+' : '-'}${money(item.amount)}',
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w900),
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
      final pct = double.tryParse(
            (AppScope.of(context).actionFieldValues['A1']?['pct'] ?? '')
                .replaceAll(',', ''),
          ) ??
          50;
      return _EssentialExpensesActionPanel(
        color: color,
        percentage: pct.clamp(0, 100).toDouble(),
      );
    }
    if (action.id == 'A3') {
      return _CategoryBudgetActionPanel(color: color);
    }
    if (action.id == 'A20') {
      return _MonthlyCashInActionPanel(color: color);
    }
    if (action.id == 'A19') {
      return _EverydayFundFloorActionPanel(color: color);
    }
    if (action.id == 'A8') {
      final pct = double.tryParse(
            (_configuredActionValues(AppScope.of(context), 'A8')['pct'] ?? '')
                .replaceAll(',', ''),
          ) ??
          10;
      return _EmergencyFundIncomeActionPanel(
        color: color,
        percentage: pct.clamp(0, 100).toDouble(),
      );
    }
    if (action.id == 'A9') {
      return _EmergencyMonthlyDepositActionPanel(color: color);
    }
    if (action.id == 'A22') {
      return _EmergencyFundCoverageActionPanel(color: color);
    }
    if (action.id == 'A10') {
      final days = double.tryParse(
            (_configuredActionValues(AppScope.of(context), 'A10')['days'] ?? '')
                .replaceAll(',', ''),
          ) ??
          7;
      return _EmergencyReplenishmentActionPanel(
        color: color,
        days: days.clamp(1, 30).toDouble(),
      );
    }
    if (action.id == 'A12') {
      final pct = double.tryParse(
            (_configuredActionValues(AppScope.of(context), 'A12')['pct'] ?? '')
                .replaceAll(',', ''),
          ) ??
          10;
      return _InvestmentIncomeActionPanel(
        color: color,
        percentage: pct.clamp(0, 100).toDouble(),
      );
    }
    if (action.id == 'A23') {
      return _InvestmentPortfolioTargetActionPanel(color: color);
    }
    if (action.id == 'A30') {
      return _InvestmentAnnualReturnActionPanel(color: color);
    }
    if (action.id == 'A26') {
      return _LifestyleSubscriptionsActionPanel(color: color);
    }
    if (action.id == 'A27') {
      return _LifestylePaydayActionPanel(color: color);
    }
    if (action.id == 'A28') {
      return _LifestyleWeeklyLimitActionPanel(color: color);
    }
    if (action.id == 'A29') {
      return _LifestyleHobbyActionPanel(color: color);
    }
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      action.id,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .5),
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
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
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
                    _DataPointRow(
                        label: dp.label, type: dp.type, value: dp.value),
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

bool _isIncomeTransaction(FakeMayaTransaction transaction) {
  if (transaction.amount <= 0 || transaction.isInternalFakeMayaTransfer) {
    return false;
  }
  final text = '${transaction.title} ${transaction.detail}'.toLowerCase();
  return !text.contains('account opened') &&
      (text.contains('income') ||
          text.contains('salary') ||
          text.contains('payroll') ||
          text.contains('cash in') ||
          text.contains('received'));
}

FakeMayaTransaction? _latestIncomeTransaction(AppState state) {
  final transactions =
      state.fakeMayaLink?.summary.transactions ?? const <FakeMayaTransaction>[];
  final incoming = transactions.where(_isIncomeTransaction).toList()
    ..sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
  return incoming.isEmpty ? null : incoming.first;
}

List<FakeMayaTransaction> _incomeTransactionsForInvestmentMonth(
  AppState state,
  DateTime monthStart,
) {
  final transactions =
      state.fakeMayaLink?.summary.transactions ?? const <FakeMayaTransaction>[];
  return transactions
      .where((transaction) =>
          _isIncomeTransaction(transaction) &&
          transaction.createdAt != null &&
          _sameMonth(transaction.createdAt!, monthStart))
      .toList()
    ..sort((a, b) => (a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
}

double _investmentDepositsForIncome(AppState state, String transactionId) {
  var total = 0.0;
  for (final entry in state.d1Ledger) {
    if (entry['type'] != 'investment_deposit') continue;
    if (entry['sourceTransactionId']?.toString() != transactionId) continue;
    total += (entry['amount'] as num?)?.toDouble() ?? 0;
  }
  return total;
}

class _EssentialExpensesActionPanel extends StatefulWidget {
  const _EssentialExpensesActionPanel({
    required this.color,
    required this.percentage,
  });
  final Color color;
  final double percentage;

  @override
  State<_EssentialExpensesActionPanel> createState() =>
      _EssentialExpensesActionPanelState();
}

class _EssentialExpensesActionPanelState
    extends State<_EssentialExpensesActionPanel> {
  bool busy = false;

  Future<void> _deposit(
    AppState state,
    List<FakeMayaTransaction> incomes, {
    double percentage = 50,
  }) async {
    if (busy || incomes.isEmpty) return;
    final confirmedPercentage = await _confirmDeposit(
      state,
      incomes,
      percentage,
    );
    if (confirmedPercentage == null) return;
    if (mounted) setState(() => busy = true);
    final totalIncome =
        incomes.fold<double>(0, (total, income) => total + income.amount);
    final allocation = totalIncome * confirmedPercentage / 100;
    final billReserve = math
        .min(
          state.openBasicNeedsBillNeed,
          math.max(0, totalIncome - allocation),
        )
        .toDouble();
    try {
      await state.depositPendingIncomeToEssentialFund(
        incomes: incomes,
        percentage: confirmedPercentage,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            billReserve > 0
                ? '${money(allocation)} transferred to Essential Expense Fund. ${money(billReserve)} reserved for unpaid bills.'
                : '${money(allocation)} transferred to Essential Expense Fund.',
          ),
        ),
      );
    } on FakeMayaException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error, stackTrace) {
      debugPrint('Essential Expense Fund transfer failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transfer failed: ${_friendlyTransferError(error)}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String _friendlyTransferError(Object error) {
    final message = error.toString().trim();
    if (message.isEmpty) return 'Please try again.';
    return message
        .replaceFirst(RegExp(r'^(Exception|FirebaseException):\s*'), '')
        .replaceFirst(RegExp(r'^\[[^\]]+\]\s*'), '');
  }

  Future<double?> _confirmDeposit(
    AppState state,
    List<FakeMayaTransaction> incomes,
    double percentage,
  ) {
    final totalIncome =
        incomes.fold<double>(0, (total, income) => total + income.amount);
    final allocation = totalIncome * percentage / 100;
    final billReserve = math
        .min(
          state.openBasicNeedsBillNeed,
          math.max(0, totalIncome - allocation),
        )
        .toDouble();
    final remainingWallet =
        state.unallocatedFakeMayaWallet - allocation - billReserve;
    return showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        title: const Text(
          'Transfer to fund?',
          style: TextStyle(color: _title, fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TransactionDetailLine(
              label: 'Included income',
              value: money(totalIncome),
            ),
            _TransactionDetailLine(
              label: 'Allocation',
              value: '${percentage.toStringAsFixed(0)}% = ${money(allocation)}',
            ),
            if (billReserve > 0)
              _TransactionDetailLine(
                label: 'Unpaid bills',
                value: money(billReserve),
              ),
            _TransactionDetailLine(
              label: 'Wallet after plan',
              value: money(math.max(0, remainingWallet)),
            ),
            if (remainingWallet < 0) ...[
              const SizedBox(height: 8),
              const Text(
                'The unallocated wallet balance is too low for this transfer.',
                style: TextStyle(color: _red, fontWeight: FontWeight.w800),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final adjusted = await _adjustPercentage(percentage);
              if (adjusted == null || !dialogContext.mounted) return;
              Navigator.of(dialogContext).pop(adjusted);
            },
            child: const Text('Adjust'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: remainingWallet < 0
                ? null
                : () => Navigator.of(dialogContext).pop(percentage),
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }

  Future<double?> _adjustPercentage(double currentPercentage) {
    var percentage = currentPercentage.clamp(0, 100).toDouble();
    final controller = TextEditingController(
      text: percentage.toStringAsFixed(0),
    );
    return showDialog<double>(
      context: context,
      builder: (dialogContext) {
        void syncController(double value) {
          final text = value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
          controller.value = TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        }

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: _surface,
            title: const Text(
              'Adjust allocation',
              style: TextStyle(color: _title, fontWeight: FontWeight.w900),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Percentage to transfer',
                        style: TextStyle(
                          color: _title,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(percentage % 1 == 0 ? 0 : 1)}%',
                        style: TextStyle(
                          color: widget.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Slider(
                  value: percentage,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: '${percentage.round()}%',
                  activeColor: widget.color,
                  onChanged: (value) {
                    setDialogState(() {
                      percentage = value;
                      syncController(value);
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d{0,3}(\.\d{0,1})?$'),
                    ),
                  ],
                  decoration: inputDecoration('50').copyWith(suffixText: '%'),
                  onChanged: (text) {
                    final value =
                        double.tryParse(text.replaceAll(',', '').trim());
                    if (value == null) return;
                    setDialogState(() {
                      percentage = value.clamp(0, 100).toDouble();
                    });
                  },
                  onEditingComplete: () {
                    final value =
                        double.tryParse(controller.text.replaceAll(',', '')) ??
                            percentage;
                    setDialogState(() {
                      percentage = value.clamp(0, 100).toDouble();
                      syncController(percentage);
                    });
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Drag the slider or type a percentage from 0 to 100.',
                  style: TextStyle(
                    color: _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final typed =
                      double.tryParse(controller.text.replaceAll(',', ''));
                  final value = (typed ?? percentage).clamp(0, 100).toDouble();
                  Navigator.of(dialogContext).pop(value);
                },
                child: const Text('Use percentage'),
              ),
            ],
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _showIncomeBreakdown(
    List<FakeMayaTransaction> incomes,
    MaterialLocalizations localizations,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          children: [
            const Text(
              'Included income',
              style: TextStyle(
                color: _title,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'These labeled income transactions have not been allocated to the fund yet.',
              style: TextStyle(color: _body, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final income in incomes)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.payments_rounded, color: _sage),
                title: Text(income.title),
                subtitle: Text(
                  income.createdAt == null
                      ? income.category ?? 'Income'
                      : '${income.category ?? 'Income'} · ${localizations.formatShortDate(income.createdAt!)}',
                ),
                trailing: Text(
                  money(income.amount),
                  style: const TextStyle(
                    color: _sage,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final incomes = state.pendingEssentialIncomeTransactions;
    final totalIncome =
        incomes.fold<double>(0, (total, income) => total + income.amount);
    final percentage = widget.percentage;
    final allocation = totalIncome * percentage / 100;
    final hasEnoughCash = allocation <= state.unallocatedFakeMayaWallet;
    final remainingWallet = state.unallocatedFakeMayaWallet - allocation;
    final localizations = MaterialLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('A1',
                    style: TextStyle(
                        color: widget.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    'Set aside ${percentage.toStringAsFixed(0)}% of each income received into an Essential Expenses Fund.',
                    style: const TextStyle(
                        color: _title,
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: _brand.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _brand.withValues(alpha: .18))),
            child: Row(
              children: [
                const Icon(Icons.home_work_rounded, color: _brand),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Essential Expenses Fund',
                          style: TextStyle(
                              color: _title, fontWeight: FontWeight.w900)),
                      Text('Earmarked inside Wallet',
                          style: TextStyle(
                              color: _body,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Text(money(state.essentialExpensesBalance),
                    style: const TextStyle(
                        color: _brand, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (incomes.isEmpty)
            const Text(
                'No unallocated labeled income found for the current income day. When salary, racket income, gifts, or received income are labeled, they will appear here.',
                style: TextStyle(
                    color: _body, height: 1.35, fontWeight: FontWeight.w700))
          else ...[
            Row(
              children: [
                const Expanded(
                  child: Text('UNALLOCATED INCOME',
                      style: TextStyle(
                          color: _body,
                          fontSize: 10,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w900)),
                ),
                IconButton(
                  tooltip: 'View included incomes',
                  icon: const Icon(Icons.list_alt_rounded, color: _purple),
                  onPressed: () => _showIncomeBreakdown(
                    incomes,
                    localizations,
                  ),
                ),
              ],
            ),
            _ActionMetricTile(
              icon: Icons.payments_rounded,
              label:
                  '${incomes.length} income transaction${incomes.length == 1 ? '' : 's'} today',
              value: money(totalIncome),
              color: _sage,
            ),
            const SizedBox(height: 10),
            _ActionMetricTile(
              icon: Icons.savings_rounded,
              label: '${percentage.toStringAsFixed(0)}% allocation',
              value: money(allocation),
              color: _brand,
            ),
            const SizedBox(height: 10),
            _ActionMetricTile(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Wallet after transfer',
              value: money(math.max(0, remainingWallet)),
              color: remainingWallet < 0 ? _red : _purple,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: busy
                  ? 'Transferring...'
                  : 'Transfer ${percentage.toStringAsFixed(0)}% (${money(allocation)})',
              icon: Icons.savings_rounded,
              enabled: !busy && hasEnoughCash,
              onPressed: () => _deposit(state, incomes, percentage: percentage),
            ),
            if (!hasEnoughCash) ...[
              const SizedBox(height: 7),
              Text(
                  'The unallocated FakeMaya wallet balance is too low for this transfer.',
                  style: TextStyle(
                      color: _red, fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ],
        ],
      ),
    );
  }
}

class _InvestmentIncomeActionPanel extends StatefulWidget {
  const _InvestmentIncomeActionPanel({
    required this.color,
    required this.percentage,
  });
  final Color color;
  final double percentage;

  @override
  State<_InvestmentIncomeActionPanel> createState() =>
      _InvestmentIncomeActionPanelState();
}

class _InvestmentIncomeActionPanelState
    extends State<_InvestmentIncomeActionPanel> {
  bool busy = false;

  Future<void> _deposit(AppState state, FakeMayaTransaction? income) async {
    if (busy || income == null || income.createdAt == null) return;
    setState(() => busy = true);
    await state.depositIncomeToInvestment(
      transactionId: income.transactionId,
      incomeAmount: income.amount,
      incomeDate: income.createdAt!,
      percentage: widget.percentage,
    );
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final income = _latestIncomeTransaction(state);
    final percentage = widget.percentage;
    final contribution = (income?.amount ?? 0) * percentage / 100;
    final deposited = income != null &&
        state.hasInvestmentAllocationForIncome(income.transactionId);
    final canDeposit = contribution <= state.unallocatedFakeMayaWallet;
    return _ActionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionPanelHeader(
            id: 'A12',
            color: widget.color,
            text:
                'Allocate ${percentage.toStringAsFixed(0)}% of each income to the Investment Portfolio.',
          ),
          const SizedBox(height: 14),
          _ActionMetricTile(
            icon: Icons.payments_rounded,
            label: 'Latest income',
            value: income == null ? 'None' : money(income.amount),
            color: _sage,
          ),
          const SizedBox(height: 10),
          _ActionMetricTile(
            icon: Icons.trending_up_rounded,
            label: 'Investment amount',
            value: money(contribution),
            color: widget.color,
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: deposited
                ? '${percentage.toStringAsFixed(0)}% invested'
                : busy
                    ? 'Investing...'
                    : 'Invest ${percentage.toStringAsFixed(0)}% (${money(contribution)})',
            icon: deposited
                ? Icons.check_circle_rounded
                : Icons.show_chart_rounded,
            enabled:
                !busy && !deposited && canDeposit && income?.createdAt != null,
            onPressed: () => _deposit(state, income),
          ),
          if (!canDeposit) ...[
            const SizedBox(height: 7),
            const Text(
              'The unallocated FakeMaya wallet balance is too low for this investment.',
              style: TextStyle(
                  color: _red, fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ],
        ],
      ),
    );
  }
}

class _InvestmentPortfolioTargetActionPanel extends StatefulWidget {
  const _InvestmentPortfolioTargetActionPanel({required this.color});
  final Color color;

  @override
  State<_InvestmentPortfolioTargetActionPanel> createState() =>
      _InvestmentPortfolioTargetActionPanelState();
}

class _InvestmentPortfolioTargetActionPanelState
    extends State<_InvestmentPortfolioTargetActionPanel> {
  bool busy = false;

  Future<void> _addInvestment(AppState state, double remaining) async {
    if (busy || remaining <= 0) return;
    final amount = await _showMoneyTargetDialog(
      context: context,
      title: 'Add to Investment Portfolio',
      label: 'Amount to invest',
      initialAmount:
          math.max(100, math.min(remaining, state.investmentMonthlyTarget)),
      color: widget.color,
    );
    if (amount == null || amount <= 0) return;
    setState(() => busy = true);
    await state.depositMonthlyInvestment(amount);
    if (mounted) setState(() => busy = false);
  }

  Future<void> _editTarget(AppState state, double current) async {
    final updated = await _showMoneyTargetDialog(
      context: context,
      title: 'Set portfolio value target',
      label: 'Portfolio value target',
      initialAmount: current,
      color: widget.color,
    );
    if (updated == null) return;
    state.actionFieldValues['A23'] = {'amt': updated.toStringAsFixed(0)};
    await state.saveProfile();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final target =
        _configuredActionAmount(state, 'A23', state.investmentPortfolioTarget);
    final balance = state.investmentPortfolioValue;
    final progress = target <= 0 ? 0.0 : (balance / target).clamp(0.0, 1.0);
    final remaining = math.max(0.0, target - balance);
    final complete = balance >= target && target > 0;
    return _ActionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionPanelHeader(
            id: 'A23',
            color: widget.color,
            text: 'Build the Investment Portfolio to ${money(target)}.',
          ),
          const SizedBox(height: 14),
          _ActionMetricTile(
            icon: Icons.trending_up_rounded,
            label: 'Portfolio balance',
            value: money(balance),
            color: complete ? _sage : widget.color,
          ),
          const SizedBox(height: 10),
          _ActionMetricTile(
            icon: Icons.flag_rounded,
            label: 'Portfolio target',
            value: money(target),
            color: widget.color,
          ),
          const SizedBox(height: 14),
          _LabeledProgressBar(
            value: progress,
            color: complete ? _sage : widget.color,
            leadingLabel: money(balance),
            trailingLabel: money(target),
          ),
          const SizedBox(height: 8),
          Text(
            complete
                ? 'The portfolio value target has been reached.'
                : '${money(remaining)} more is needed to reach the portfolio target.',
            style: TextStyle(
              color: complete ? _sage : _body,
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: busy ? 'Adding...' : 'Add investment',
                  icon: Icons.show_chart_rounded,
                  enabled: !busy && !complete,
                  onPressed: () => _addInvestment(state, remaining),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Edit portfolio target',
                onPressed: () => _editTarget(state, target),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvestmentAnnualReturnActionPanel extends StatefulWidget {
  const _InvestmentAnnualReturnActionPanel({required this.color});
  final Color color;

  @override
  State<_InvestmentAnnualReturnActionPanel> createState() =>
      _InvestmentAnnualReturnActionPanelState();
}

class _InvestmentAnnualReturnActionPanelState
    extends State<_InvestmentAnnualReturnActionPanel> {
  bool busy = false;

  Future<void> _editTarget(AppState state, double current) async {
    final updated = await _showPercentTargetDialog(
      context: context,
      title: 'Set target annual return',
      label: 'Target annual return',
      initialPercent: current,
      color: widget.color,
    );
    if (updated == null) return;
    state.actionFieldValues['A30'] = {'pct': updated.toStringAsFixed(0)};
    await state.saveProfile();
    if (mounted) setState(() {});
  }

  Future<void> _startTracking(AppState state) async {
    if (busy) return;
    setState(() => busy = true);
    await state.startInvestmentReturnTracking();
    if (mounted) setState(() => busy = false);
  }

  Future<void> _restartTracking(AppState state) async {
    if (busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('Restart tracking?',
            style: TextStyle(color: _title, fontWeight: FontWeight.w900)),
        content: const Text(
          "This resets the annual return calculation to start from today's "
          "portfolio balance. Past performance won't count toward the new "
          'tracking window.',
          style: TextStyle(color: _body, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Restart'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => busy = true);
    await state.startInvestmentReturnTracking();
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final target = double.tryParse(
          (_configuredActionValues(state, 'A30')['pct'] ?? '')
              .replaceAll(',', ''),
        ) ??
        state.investmentTargetAnnualReturnPercent;
    final tracking = state.investmentReturnBaselineDate != null;
    final actual = state.investmentAnnualizedReturnPercent;
    final onTrack = state.isInvestmentAnnualReturnOnTrack;
    final progress = target <= 0 ? 0.0 : (actual / target).clamp(0.0, 1.0);
    final statusColor = tracking ? (onTrack ? _sage : _red) : widget.color;
    return _ActionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionPanelHeader(
            id: 'A30',
            color: widget.color,
            text: 'Keep your investment portfolio on track to meet your '
                'target annual return on investment of '
                '${target.toStringAsFixed(0)}%.',
          ),
          const SizedBox(height: 14),
          _ActionMetricTile(
            icon: actual >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            label: 'Annualized return',
            value:
                tracking ? '${actual.toStringAsFixed(1)}%' : 'Not tracking yet',
            color: statusColor,
          ),
          const SizedBox(height: 10),
          _ActionMetricTile(
            icon: Icons.flag_rounded,
            label: 'Target annual return',
            value: '${target.toStringAsFixed(0)}%',
            color: widget.color,
          ),
          const SizedBox(height: 14),
          if (tracking) ...[
            _LabeledProgressBar(
              value: progress,
              color: statusColor,
              leadingLabel: '${actual.toStringAsFixed(1)}%',
              trailingLabel: '${target.toStringAsFixed(0)}% target',
            ),
            const SizedBox(height: 8),
            Text(
              onTrack
                  ? "The portfolio's annualized return is ahead of the "
                      '${target.toStringAsFixed(0)}% target.'
                  : "The portfolio's annualized return is behind the "
                      '${target.toStringAsFixed(0)}% target.',
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ] else
            const Text(
              'Start tracking to compare portfolio performance with this '
              'target over time.',
              style: TextStyle(
                color: _body,
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: busy
                      ? 'Saving...'
                      : tracking
                          ? 'Restart tracking'
                          : 'Start tracking',
                  icon: Icons.timeline_rounded,
                  enabled: !busy,
                  onPressed: () => tracking
                      ? _restartTracking(state)
                      : _startTracking(state),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Edit target annual return',
                onPressed: () => _editTarget(state, target),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LifestyleSubscriptionsActionPanel extends StatefulWidget {
  const _LifestyleSubscriptionsActionPanel({required this.color});
  final Color color;

  @override
  State<_LifestyleSubscriptionsActionPanel> createState() =>
      _LifestyleSubscriptionsActionPanelState();
}

class _LifestyleSubscriptionsActionPanelState
    extends State<_LifestyleSubscriptionsActionPanel> {
  bool busy = false;

  Future<void> _reserve(AppState state, double amount) async {
    if (busy || amount <= 0) return;
    setState(() => busy = true);
    await state.depositLifestyleSubscriptionReserve(amount);
    if (mounted) setState(() => busy = false);
  }

  Future<void> _editTarget(AppState state, double current) async {
    final updated = await _showMoneyTargetDialog(
      context: context,
      title: 'Set recurring lifestyle costs',
      label: 'Monthly subscriptions and memberships',
      initialAmount: current,
      color: widget.color,
    );
    if (updated == null) return;
    state.actionFieldValues['A26'] = {'amt': updated.toStringAsFixed(0)};
    await state.saveProfile();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final target = _configuredActionAmount(
      state,
      'A26',
      _monthlySubscriptionBase(state),
    );
    final reserved = state.lifestyleReservedThisMonth;
    final remaining = math.max(0.0, target - reserved);
    final progress = target <= 0 ? 0.0 : (reserved / target).clamp(0.0, 1.0);
    final complete = reserved >= target && target > 0;
    final canReserve = state.fakeMayaLink == null ||
        remaining <= state.unallocatedFakeMayaWallet;
    return _ActionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionPanelHeader(
            id: 'A26',
            color: widget.color,
            text:
                'Set aside ${money(target)} each month for subscriptions and memberships.',
          ),
          const SizedBox(height: 14),
          _ActionMetricTile(
            icon: Icons.subscriptions_rounded,
            label: 'Reserved this month',
            value: money(reserved),
            color: complete ? _sage : widget.color,
          ),
          const SizedBox(height: 10),
          _ActionMetricTile(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Lifestyle Fund available',
            value: money(state.lifestyleFundBalance),
            color: widget.color,
          ),
          const SizedBox(height: 14),
          _LabeledProgressBar(
            value: progress,
            color: complete ? _sage : widget.color,
            leadingLabel: money(reserved),
            trailingLabel: money(target),
          ),
          const SizedBox(height: 8),
          Text(
            complete
                ? 'Subscriptions and memberships are covered for this month.'
                : '${money(remaining)} still needs to be reserved this month.',
            style: TextStyle(
              color: complete ? _sage : _body,
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: busy ? 'Reserving...' : 'Reserve ${money(remaining)}',
                  icon: Icons.subscriptions_rounded,
                  enabled: !busy && !complete && canReserve,
                  onPressed: () => _reserve(state, remaining),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Edit monthly target',
                onPressed: () => _editTarget(state, target),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LifestylePaydayActionPanel extends StatefulWidget {
  const _LifestylePaydayActionPanel({required this.color});
  final Color color;

  @override
  State<_LifestylePaydayActionPanel> createState() =>
      _LifestylePaydayActionPanelState();
}

class _LifestylePaydayActionPanelState
    extends State<_LifestylePaydayActionPanel> {
  bool busy = false;

  Future<void> _deposit(
    AppState state,
    FakeMayaTransaction? income,
    double amount,
  ) async {
    if (busy || income?.createdAt == null) return;
    setState(() => busy = true);
    await state.depositLifestylePayday(
      transactionId: income!.transactionId,
      amount: amount,
      incomeDate: income.createdAt!,
    );
    if (mounted) setState(() => busy = false);
  }

  Future<void> _editAmount(AppState state, double current) async {
    final updated = await _showMoneyTargetDialog(
      context: context,
      title: 'Set payday enjoyment amount',
      label: 'Amount to add every payday',
      initialAmount: current,
      color: widget.color,
    );
    if (updated == null) return;
    state.actionFieldValues['A27'] = {'amt': updated.toStringAsFixed(0)};
    await state.saveProfile();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final amount = _configuredActionAmount(state, 'A27', 1000);
    final income = _latestIncomeTransaction(state);
    final deposited = income != null &&
        state.hasLifestylePaydayAllocation(income.transactionId);
    final canDeposit =
        state.fakeMayaLink == null || amount <= state.unallocatedFakeMayaWallet;
    return _ActionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionPanelHeader(
            id: 'A27',
            color: widget.color,
            text:
                'Add ${money(amount)} to the Personal Lifestyle Fund every payday.',
          ),
          const SizedBox(height: 14),
          _ActionMetricTile(
            icon: Icons.payments_rounded,
            label: 'Latest payday',
            value: income == null ? 'None detected' : money(income.amount),
            color: _sage,
          ),
          const SizedBox(height: 10),
          _ActionMetricTile(
            icon: Icons.celebration_rounded,
            label: 'Enjoyment available',
            value: money(state.lifestyleFundBalance),
            color: widget.color,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: deposited
                      ? 'Latest payday funded'
                      : busy
                          ? 'Adding...'
                          : 'Add ${money(amount)}',
                  icon: deposited
                      ? Icons.check_circle_rounded
                      : Icons.savings_rounded,
                  enabled: !busy &&
                      !deposited &&
                      canDeposit &&
                      income?.createdAt != null,
                  onPressed: () => _deposit(state, income, amount),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Edit payday amount',
                onPressed: () => _editAmount(state, amount),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LifestyleWeeklyLimitActionPanel extends StatefulWidget {
  const _LifestyleWeeklyLimitActionPanel({required this.color});
  final Color color;

  @override
  State<_LifestyleWeeklyLimitActionPanel> createState() =>
      _LifestyleWeeklyLimitActionPanelState();
}

class _LifestyleWeeklyLimitActionPanelState
    extends State<_LifestyleWeeklyLimitActionPanel> {
  Future<void> _editLimit(AppState state, double current) async {
    final updated = await _showMoneyTargetDialog(
      context: context,
      title: 'Set weekly enjoyment limit',
      label: 'Weekly enjoyment spending limit',
      initialAmount: current,
      color: widget.color,
    );
    if (updated == null) return;
    state.actionFieldValues['A28'] = {'amt': updated.toStringAsFixed(0)};
    await state.saveProfile();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final limit = _configuredActionAmount(state, 'A28', 1500);
    final spent = _currentWeekLifestyleSpend(state);
    final remaining = math.max(0.0, limit - spent);
    final over = spent > limit;
    final progress = limit <= 0 ? 1.0 : (spent / limit).clamp(0.0, 1.0);
    return _ActionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionPanelHeader(
            id: 'A28',
            color: widget.color,
            text:
                'Keep everyday enjoyment spending within ${money(limit)} each week.',
          ),
          const SizedBox(height: 14),
          _ActionMetricTile(
            icon: Icons.receipt_long_rounded,
            label: 'Spent this week',
            value: money(spent),
            color: over ? _red : widget.color,
          ),
          const SizedBox(height: 10),
          _ActionMetricTile(
            icon: Icons.calendar_today_rounded,
            label: 'Time remaining',
            value: _daysRemainingThisWeekLabel(),
            color: over ? _red : _sage,
          ),
          const SizedBox(height: 14),
          _LabeledProgressBar(
            value: progress,
            color: over ? _red : widget.color,
            leadingLabel: money(spent),
            trailingLabel: '${money(limit)} limit',
          ),
          const SizedBox(height: 8),
          Text(
            over
                ? 'Weekly enjoyment spending is ${money(spent - limit)} over the limit.'
                : '${money(remaining)} remains for everyday enjoyment this week.',
            style: TextStyle(
              color: over ? _red : _body,
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Edit weekly limit',
              onPressed: () => _editLimit(state, limit),
              icon: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _LifestyleHobbyActionPanel extends StatefulWidget {
  const _LifestyleHobbyActionPanel({required this.color});
  final Color color;

  @override
  State<_LifestyleHobbyActionPanel> createState() =>
      _LifestyleHobbyActionPanelState();
}

class _LifestyleHobbyActionPanelState
    extends State<_LifestyleHobbyActionPanel> {
  String? busyHobbyId;

  Future<void> _addHobby(AppState state) async {
    final draft = await _showHobbyDialog(
      context: context,
      title: 'Add a hobby or activity',
      color: widget.color,
    );
    if (draft == null) return;
    await state.addLifestyleHobby(
      name: draft.name,
      target: draft.target,
      months: draft.months,
    );
  }

  Future<void> _editHobby(AppState state, Map<String, dynamic> hobby) async {
    final draft = await _showHobbyDialog(
      context: context,
      title: 'Edit hobby or activity',
      color: widget.color,
      initialName: (hobby['name'] ?? '').toString(),
      initialTarget: (hobby['target'] as num?)?.toDouble() ?? 10000,
      initialMonths: (hobby['months'] as num?)?.toInt() ?? 6,
    );
    if (draft == null) return;
    await state.editLifestyleHobby(
      hobby['id'].toString(),
      name: draft.name,
      target: draft.target,
      months: draft.months,
    );
  }

  Future<void> _removeHobby(AppState state, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('Remove this hobby?',
            style: TextStyle(color: _title, fontWeight: FontWeight.w900)),
        content: const Text(
          'This stops tracking its target. Past contributions stay in your activity history.',
          style: TextStyle(color: _body, fontSize: 12, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) await state.removeLifestyleHobby(id);
  }

  Future<void> _addSavings(
    AppState state,
    Map<String, dynamic> hobby,
    double remaining,
  ) async {
    if (busyHobbyId != null || remaining <= 0) return;
    final id = hobby['id'].toString();
    final amount = await _showMoneyTargetDialog(
      context: context,
      title: 'Add savings',
      label: '${hobby['name']} savings',
      initialAmount: math.max(100, math.min(remaining, 1000)),
      color: widget.color,
    );
    if (amount == null) return;
    setState(() => busyHobbyId = id);
    await state.depositLifestyleHobby(hobbyId: id, amount: amount);
    if (mounted) setState(() => busyHobbyId = null);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final hobbies = state.lifestyleHobbies;
    final canAddMore = hobbies.length < AppState.lifestyleHobbyLimit;
    return _ActionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionPanelHeader(
            id: 'A29',
            color: widget.color,
            text: hobbies.isEmpty
                ? 'Save toward a hobby or activity within a set number of months.'
                : 'Save toward up to 3 hobbies or activities, each with its own target.',
          ),
          const SizedBox(height: 14),
          if (hobbies.isEmpty)
            Text(
              'No hobby or activity targets yet. Add up to 3, each with its own amount and timeline.',
              style: TextStyle(
                color: _body,
                fontSize: 11.5,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            for (final hobby in hobbies) ...[
              _LifestyleHobbyTile(
                hobby: hobby,
                color: widget.color,
                busy: busyHobbyId == hobby['id'],
                onAddSavings: (remaining) =>
                    _addSavings(state, hobby, remaining),
                onEdit: () => _editHobby(state, hobby),
                onRemove: () => _removeHobby(state, hobby['id'].toString()),
              ),
              const SizedBox(height: 12),
            ],
          if (canAddMore)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _addHobby(state),
                icon: const Icon(Icons.add_rounded),
                label: Text(hobbies.isEmpty
                    ? 'Add a hobby or activity'
                    : 'Add another (${hobbies.length}/${AppState.lifestyleHobbyLimit})'),
              ),
            ),
        ],
      ),
    );
  }
}

class _LifestyleHobbyTile extends StatelessWidget {
  const _LifestyleHobbyTile({
    required this.hobby,
    required this.color,
    required this.busy,
    required this.onAddSavings,
    required this.onEdit,
    required this.onRemove,
  });
  final Map<String, dynamic> hobby;
  final Color color;
  final bool busy;
  final ValueChanged<double> onAddSavings;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final id = hobby['id'].toString();
    final name = (hobby['name'] ?? 'Hobby').toString();
    final target = (hobby['target'] as num?)?.toDouble() ?? 10000;
    final months = (hobby['months'] as num?)?.toInt() ?? 6;
    final saved = state.lifestyleHobbyBalance(id);
    final remaining = math.max(0.0, target - saved);
    final progress = target <= 0 ? 0.0 : (saved / target).clamp(0.0, 1.0);
    final complete = saved >= target && target > 0;
    final started = state.lifestyleHobbyStartedAt(id) ?? DateTime.now();
    final due = DateTime(started.year, started.month + months, started.day);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit',
                visualDensity: VisualDensity.compact,
                onPressed: onEdit,
                icon: const Icon(Icons.tune_rounded, size: 18),
              ),
              IconButton(
                tooltip: 'Remove',
                visualDensity: VisualDensity.compact,
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Target date: ${_shortDate(due)}',
            style: const TextStyle(
              color: _body,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _LabeledProgressBar(
            value: progress,
            color: complete ? _sage : color,
            leadingLabel: money(saved),
            trailingLabel: money(target),
          ),
          const SizedBox(height: 8),
          Text(
            complete
                ? '"$name" is fully funded.'
                : '${money(remaining)} still needs to be saved.',
            style: TextStyle(
              color: complete ? _sage : _body,
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: busy ? 'Adding...' : 'Add savings',
              icon: Icons.savings_rounded,
              enabled: !busy && !complete,
              onPressed: () => onAddSavings(remaining),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyMonthlyDepositActionPanel extends StatefulWidget {
  const _EmergencyMonthlyDepositActionPanel({required this.color});
  final Color color;

  @override
  State<_EmergencyMonthlyDepositActionPanel> createState() =>
      _EmergencyMonthlyDepositActionPanelState();
}

class _EmergencyMonthlyDepositActionPanelState
    extends State<_EmergencyMonthlyDepositActionPanel> {
  bool busy = false;

  Future<void> _deposit(AppState state, double amount) async {
    if (busy || amount <= 0) return;
    setState(() => busy = true);
    await state.depositMonthlyEmergencyFund(amount);
    if (mounted) setState(() => busy = false);
  }

  Future<void> _editTarget(AppState state, double current) async {
    final updated = await _showMoneyTargetDialog(
      context: context,
      title: 'Set monthly Emergency Fund deposit',
      label: 'Monthly deposit target',
      initialAmount: current,
      color: widget.color,
    );
    if (updated == null) return;
    state.actionFieldValues['A9'] = {'amt': updated.toStringAsFixed(0)};
    await state.saveProfile();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final target = _configuredActionAmount(
      state,
      'A9',
      _emergencyMonthlyDepositBase(state),
    );
    final deposited = _currentMonthEmergencyDeposits(state);
    final progress = target <= 0 ? 0.0 : (deposited / target).clamp(0.0, 1.0);
    final remaining = math.max(0.0, target - deposited);
    final complete = deposited >= target && target > 0;
    final canDeposit =
        state.fakeMayaLink == null || target <= state.unallocatedFakeMayaWallet;
    return _ActionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionPanelHeader(
            id: 'A9',
            color: widget.color,
            text:
                'Deposit at least ${money(target)} into the Emergency Fund each month.',
          ),
          const SizedBox(height: 14),
          _ActionMetricTile(
            icon: Icons.savings_rounded,
            label: 'Deposited this month',
            value: money(deposited),
            color: complete ? _sage : widget.color,
          ),
          const SizedBox(height: 10),
          _ActionMetricTile(
            icon: Icons.flag_rounded,
            label: 'Monthly target',
            value: money(target),
            color: widget.color,
          ),
          const SizedBox(height: 14),
          _LabeledProgressBar(
            value: progress,
            color: complete ? _sage : widget.color,
            leadingLabel: money(deposited),
            trailingLabel: money(target),
          ),
          const SizedBox(height: 8),
          Text(
            complete
                ? "This month's Emergency Fund deposit target is complete."
                : "${money(remaining)} still needed to complete this month's Emergency Fund deposit target.",
            style: TextStyle(
              color: complete ? _sage : _body,
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: busy ? 'Depositing...' : 'Deposit ${money(target)}',
                  icon: Icons.shield_rounded,
                  enabled: !busy && !complete && canDeposit,
                  onPressed: () => _deposit(state, target),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Edit monthly deposit',
                onPressed: () => _editTarget(state, target),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          if (!canDeposit) ...[
            const SizedBox(height: 7),
            const Text(
              'The unallocated FakeMaya wallet balance is too low for this deposit.',
              style: TextStyle(
                  color: _red, fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmergencyFundCoverageActionPanel extends StatefulWidget {
  const _EmergencyFundCoverageActionPanel({required this.color});
  final Color color;

  @override
  State<_EmergencyFundCoverageActionPanel> createState() =>
      _EmergencyFundCoverageActionPanelState();
}

class _EmergencyFundCoverageActionPanelState
    extends State<_EmergencyFundCoverageActionPanel> {
  Future<void> _editMonths(AppState state, double current) async {
    final updated = await _showMonthsTargetDialog(
      context: context,
      title: 'Set Emergency Fund coverage',
      initialMonths: current,
      color: widget.color,
    );
    if (updated == null) return;
    state.actionFieldValues['A22'] = {'months': updated.toStringAsFixed(0)};
    await state.saveProfile();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final monthlyEssentials = math.max(1.0, state.monthlyEssentialExpenseTotal);
    final months = _configuredEmergencyCoverageMonths(state);
    final target = _configuredEmergencyCoverageTarget(state);
    final current = state.displayedEmergencyFundBalance;
    final covered = current / monthlyEssentials;
    final progress = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    final gap = math.max(0.0, target - current);
    final complete = current >= target && target > 0;
    return _ActionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionPanelHeader(
            id: 'A22',
            color: widget.color,
            text:
                'Build your Emergency Fund to cover ${months.toStringAsFixed(0)} months of essential expenses.',
          ),
          const SizedBox(height: 14),
          _ActionMetricTile(
            icon: Icons.shield_rounded,
            label: 'Emergency Fund',
            value: money(current),
            color: complete ? _sage : widget.color,
          ),
          const SizedBox(height: 10),
          _ActionMetricTile(
            icon: Icons.flag_rounded,
            label: '${months.toStringAsFixed(0)} month target',
            value: money(target),
            color: widget.color,
          ),
          const SizedBox(height: 14),
          _LabeledProgressBar(
            value: progress,
            color: complete ? _sage : widget.color,
            leadingLabel: '${covered.toStringAsFixed(1)} months',
            trailingLabel: '${months.toStringAsFixed(0)} months',
          ),
          const SizedBox(height: 8),
          Text(
            complete
                ? 'Your Emergency Fund has reached this coverage target.'
                : '${money(gap)} more is needed to reach ${months.toStringAsFixed(0)} months of essential expenses.',
            style: TextStyle(
              color: complete ? _sage : _body,
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _editMonths(state, months),
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Edit coverage target'),
          ),
        ],
      ),
    );
  }
}

class _EmergencyFundIncomeActionPanel extends StatefulWidget {
  const _EmergencyFundIncomeActionPanel({
    required this.color,
    required this.percentage,
  });
  final Color color;
  final double percentage;

  @override
  State<_EmergencyFundIncomeActionPanel> createState() =>
      _EmergencyFundIncomeActionPanelState();
}

class _EmergencyFundIncomeActionPanelState
    extends State<_EmergencyFundIncomeActionPanel> {
  bool busy = false;

  Future<void> _deposit(AppState state, FakeMayaTransaction income) async {
    if (busy || income.createdAt == null) return;
    setState(() => busy = true);
    await state.depositIncomeToEmergencyFund(
      transactionId: income.transactionId,
      incomeAmount: income.amount,
      incomeDate: income.createdAt!,
      percentage: widget.percentage,
    );
    if (mounted) setState(() => busy = false);
  }

  Future<void> _useFunds(AppState state) async {
    final controller = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('Use Emergency Fund',
            style: TextStyle(color: _title, fontWeight: FontWeight.w900)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: inputDecoration('Amount used').copyWith(
              prefixText: '₱ ',
              helperText:
                  'Available: ${money(state.displayedEmergencyFundBalance)}'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final value =
                  double.tryParse(controller.text.replaceAll(',', '')) ?? 0;
              Navigator.of(dialogContext).pop(
                  value > 0 && value <= state.displayedEmergencyFundBalance
                      ? value
                      : null);
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
    final percentage = widget.percentage;
    final allocation = (income?.amount ?? 0) * percentage / 100;
    final deposited = income != null &&
        state.hasEmergencyAllocationForIncome(income.transactionId);
    final canDeposit = allocation <= state.unallocatedFakeMayaWallet;
    final date = income?.createdAt;
    final localizations = MaterialLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('A8',
                    style: TextStyle(
                        color: widget.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                      'Set aside ${percentage.toStringAsFixed(0)}% of each income for the Emergency Fund.',
                      style: const TextStyle(
                          color: _title,
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: _red.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _red.withValues(alpha: .16))),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: _red),
                const SizedBox(width: 9),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Emergency Fund',
                          style: TextStyle(
                              color: _title, fontWeight: FontWeight.w900)),
                      Text('Earmarked inside Savings',
                          style: TextStyle(
                              color: _body,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Text(money(state.displayedEmergencyFundBalance),
                    style: const TextStyle(
                        color: _red, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (income == null)
            const Text('No qualifying income transaction found yet.',
                style: TextStyle(color: _body, fontWeight: FontWeight.w700))
          else ...[
            const Text('LATEST INCOME',
                style: TextStyle(
                    color: _body,
                    fontSize: 10,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(Icons.payments_rounded, color: _sage, size: 20),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(income.title,
                          style: const TextStyle(
                              color: _title, fontWeight: FontWeight.w900)),
                      if (date != null)
                        Text(
                            '${localizations.formatShortDate(date)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date))}',
                            style: const TextStyle(
                                color: _body,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Text(money(income.amount),
                    style: const TextStyle(
                        color: _sage, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: deposited
                  ? '${percentage.toStringAsFixed(0)}% deposited to fund'
                  : busy
                      ? 'Depositing...'
                      : 'Deposit ${percentage.toStringAsFixed(0)}% (${money(allocation)})',
              icon:
                  deposited ? Icons.check_circle_rounded : Icons.shield_rounded,
              enabled: !busy && !deposited && canDeposit && date != null,
              onPressed: () => _deposit(state, income),
            ),
          ],
          if (state.displayedEmergencyFundBalance > 0) ...[
            const SizedBox(height: 9),
            TextButton.icon(
                onPressed: () => _useFunds(state),
                icon: const Icon(Icons.outbox_rounded),
                label: const Text('Use emergency funds')),
          ],
        ],
      ),
    );
  }
}

class _EmergencyReplenishmentActionPanel extends StatefulWidget {
  const _EmergencyReplenishmentActionPanel({
    required this.color,
    required this.days,
  });
  final Color color;
  final double days;

  @override
  State<_EmergencyReplenishmentActionPanel> createState() =>
      _EmergencyReplenishmentActionPanelState();
}

class _EmergencyReplenishmentActionPanelState
    extends State<_EmergencyReplenishmentActionPanel> {
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
    final incomeAfterWithdrawal = withdrawalDate != null &&
        incomeDate != null &&
        incomeDate.isAfter(withdrawalDate);
    final configuredDays = widget.days.round();
    final deadline = incomeAfterWithdrawal
        ? incomeDate.add(Duration(days: configuredDays))
        : null;
    final hoursLeft = deadline?.difference(DateTime.now()).inHours ?? 0;
    final daysLeft = math.max(0, (hoursLeft / 24).ceil());
    final overdue = deadline != null && deadline.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('A10',
                    style: TextStyle(
                        color: widget.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                      'Replenish withdrawn Emergency Fund amounts within $configuredDays days after receiving income.',
                      style: const TextStyle(
                          color: _title,
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 14),
          if (pending <= 0)
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                  color: _sage.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14)),
              child: const Row(children: [
                Icon(Icons.check_circle_rounded, color: _sage),
                SizedBox(width: 9),
                Expanded(
                    child: Text(
                        'Your Emergency Fund has no amount waiting to be replenished.',
                        style: TextStyle(
                            color: _title, fontWeight: FontWeight.w800)))
              ]),
            )
          else ...[
            _ActionMetricTile(
                icon: Icons.outbox_rounded,
                label: 'Amount used',
                value: money(pending),
                color: _red),
            const SizedBox(height: 10),
            if (!incomeAfterWithdrawal)
              Text(
                  'Waiting for your next income. The $configuredDays-day replenishment countdown starts when that income arrives.',
                  style: const TextStyle(
                      color: _body, height: 1.35, fontWeight: FontWeight.w700))
            else ...[
              _ActionMetricTile(
                icon: overdue ? Icons.warning_rounded : Icons.timer_rounded,
                label: overdue ? 'Replenishment overdue' : 'Time remaining',
                value: overdue
                    ? 'Due now'
                    : '$daysLeft day${daysLeft == 1 ? '' : 's'}',
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
                const Text(
                    'The unallocated FakeMaya wallet balance is too low to replenish the full amount.',
                    style: TextStyle(
                        color: _red,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
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
  State<_CategoryBudgetActionPanel> createState() =>
      _CategoryBudgetActionPanelState();
}

class _CategoryBudgetActionPanelState
    extends State<_CategoryBudgetActionPanel> {
  static const _budgetCategories = [
    'Food & drink',
    'Transport',
    'Bills & utilities',
    'Housing',
    'Groceries',
    'Shopping',
    'Education',
    'Health',
    'Insurance',
    'Debt payment',
    'Entertainment',
    'Travel',
    'Personal goal',
    'Gifts & giving',
    'Subscriptions',
    'Dining',
    'Other expense',
  ];

  double _spentFor(AppState state, String budgetCategory) {
    final now = DateTime.now();
    return (state.fakeMayaLink?.summary.transactions ??
            const <FakeMayaTransaction>[])
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
    }).fold(0.0, (total, transaction) => total + transaction.amount.abs());
  }

  Future<void> _configure(AppState state) async {
    final categories = <String>{..._budgetCategories};
    for (final transaction in state.fakeMayaLink?.summary.transactions ??
        const <FakeMayaTransaction>[]) {
      final category = transaction.category?.trim() ?? '';
      if (category.isNotEmpty && category.toLowerCase() != 'transfer') {
        categories.add(category);
      }
    }
    categories.addAll(state.categorySpendingBudgets.keys);
    final ordered = categories.toList()..sort();
    final rows = state.categorySpendingBudgets.entries
        .map((entry) => (
              category: entry.key,
              customController: TextEditingController(
                text: ordered.contains(entry.key) ? '' : entry.key,
              ),
              controller: TextEditingController(
                text: entry.value.toStringAsFixed(0),
              ),
            ))
        .toList();
    if (rows.isEmpty) {
      rows.addAll([
        (
          category: 'Food & drink',
          customController: TextEditingController(),
          controller: TextEditingController(text: '5000'),
        ),
        (
          category: 'Shopping',
          customController: TextEditingController(),
          controller: TextEditingController(text: '2500'),
        ),
      ]);
    }

    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          String rowCategory(int index) {
            final row = rows[index];
            if (row.category == 'Other expense') {
              final custom = row.customController.text.trim();
              if (custom.isNotEmpty) return custom;
            }
            return row.category.trim();
          }

          final chosen = [
            for (var i = 0; i < rows.length; i++) rowCategory(i),
          ];
          final hasDuplicates = chosen.toSet().length != chosen.length;
          final valid = rows.isNotEmpty &&
              !hasDuplicates &&
              rows.indexed.every((item) {
                final row = item.$2;
                final category = rowCategory(item.$1);
                final amount =
                    double.tryParse(row.controller.text.replaceAll(',', '')) ??
                        0;
                return category.isNotEmpty && amount > 0 && amount <= 1000000;
              });
          void addRow() {
            final used = rows.map((row) => row.category).toSet();
            final category = ordered.firstWhere(
              (category) => !used.contains(category),
              orElse: () => 'Other expense',
            );
            rows.add((
              category: category,
              customController: TextEditingController(),
              controller: TextEditingController(),
            ));
            setDialogState(() {});
          }

          return AlertDialog(
            backgroundColor: _surface,
            title: const Text('Category budget ledger',
                style: TextStyle(color: _title, fontWeight: FontWeight.w900)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add one monthly cap per spending category.',
                      style: TextStyle(
                        color: _body,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (var index = 0; index < rows.length; index++) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  value: rows[index].category,
                                  isExpanded: true,
                                  decoration:
                                      inputDecoration('Category').copyWith(
                                    isDense: true,
                                  ),
                                  items: [
                                    for (final category in ordered)
                                      DropdownMenuItem(
                                        value: category,
                                        child: Text(category),
                                      ),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) return;
                                    rows[index] = (
                                      category: value,
                                      customController:
                                          rows[index].customController,
                                      controller: rows[index].controller,
                                    );
                                    setDialogState(() {});
                                  },
                                ),
                                if (rows[index].category ==
                                    'Other expense') ...[
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: rows[index].customController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration:
                                        inputDecoration('Custom category')
                                            .copyWith(isDense: true),
                                    onChanged: (_) => setDialogState(() {}),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: rows[index].controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration:
                                  inputDecoration('Monthly cap').copyWith(
                                prefixText: '₱ ',
                                isDense: true,
                              ),
                              onChanged: (_) => setDialogState(() {}),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove budget',
                            visualDensity: VisualDensity.compact,
                            onPressed: rows.length == 1
                                ? null
                                : () {
                                    final row = rows.removeAt(index);
                                    row.controller.dispose();
                                    row.customController.dispose();
                                    setDialogState(() {});
                                  },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      if (index < rows.length - 1) const SizedBox(height: 10),
                    ],
                    if (hasDuplicates) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Each budget needs a different category.',
                        style: TextStyle(
                          color: _red,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: addRow,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add another budget'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel')),
              FilledButton(
                onPressed: valid
                    ? () => Navigator.of(dialogContext).pop({
                          for (final row in rows)
                            (row.category == 'Other expense' &&
                                    row.customController.text.trim().isNotEmpty
                                ? row.customController.text.trim()
                                : row.category): double.parse(
                              row.controller.text.replaceAll(',', ''),
                            ),
                        })
                    : null,
                child: const Text('Save budgets'),
              ),
            ],
          );
        },
      ),
    );
    for (final row in rows) {
      row.controller.dispose();
      row.customController.dispose();
    }
    if (result == null) return;
    await state.updateCategorySpendingBudgets(result);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final budgets = state.categorySpendingBudgets;
    final budgetRows = budgets.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final totalCap = budgetRows.fold<double>(
      0,
      (total, entry) => total + entry.value,
    );
    final totalSpent = budgetRows.fold<double>(
      0,
      (total, entry) => total + _spentFor(state, entry.key),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('A3',
                    style: TextStyle(
                        color: widget.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                  child: Text(
                      'Limit spending in selected categories to a monthly maximum.',
                      style: TextStyle(
                          color: _title,
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 14),
          if (budgets.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _MiniLedgerStat(
                      label: 'Total cap',
                      value: money(totalCap),
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniLedgerStat(
                      label: 'Spent',
                      value: money(totalSpent),
                      color: totalSpent > totalCap ? _red : _body,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniLedgerStat(
                      label: 'Remaining',
                      value: money(math.max(0, totalCap - totalSpent)),
                      color: totalSpent > totalCap ? _red : _sage,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Category',
                            style: TextStyle(
                              color: _body,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .6,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Budget',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: _body,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .6,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Spent',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: _body,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (var index = 0; index < budgetRows.length; index++) ...[
                    if (index > 0) const Divider(height: 1, color: _border),
                    _CategoryBudgetLedgerRow(
                      category: budgetRows[index].key,
                      spent: _spentFor(state, budgetRows[index].key),
                      budget: budgetRows[index].value,
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _configure(state),
            icon:
                Icon(budgets.isEmpty ? Icons.add_rounded : Icons.edit_rounded),
            label: Text(budgets.isEmpty
                ? 'Add category budgets'
                : 'Edit budget ledger'),
          ),
        ],
      ),
    );
  }
}

class _MiniLedgerStat extends StatelessWidget {
  const _MiniLedgerStat({
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
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _CategoryBudgetLedgerRow extends StatelessWidget {
  const _CategoryBudgetLedgerRow({
    required this.category,
    required this.spent,
    required this.budget,
  });

  final String category;
  final double spent;
  final double budget;

  @override
  Widget build(BuildContext context) {
    final progress = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);
    final remaining = math.max(0.0, budget - spent);
    final color = progress >= 1
        ? _red
        : progress >= .8
            ? _amber
            : _brand;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  category,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  money(budget),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  money(spent),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: color,
              backgroundColor: color.withValues(alpha: .12),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${(progress * 100).round()}% used',
                style: const TextStyle(
                  color: _body,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${money(remaining)} remaining',
                style: const TextStyle(
                  color: _body,
                  fontSize: 10.5,
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

class _CategoryBudgetProgress extends StatelessWidget {
  const _CategoryBudgetProgress(
      {required this.category, required this.spent, required this.budget});
  final String category;
  final double spent;
  final double budget;

  @override
  Widget build(BuildContext context) {
    final progress = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);
    final color = progress >= 1
        ? _red
        : progress >= .8
            ? _amber
            : _brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Text(category,
                    style: const TextStyle(
                        color: _title, fontWeight: FontWeight.w900))),
            Text('${money(spent)} / ${money(budget)}',
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: .12)),
        ),
        const SizedBox(height: 4),
        Text(
            '${(progress * 100).round()}% used · ${money(math.max(0, budget - spent))} remaining',
            style: const TextStyle(
                color: _body, fontSize: 10.5, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _MonthlyCashInActionPanel extends StatefulWidget {
  const _MonthlyCashInActionPanel({required this.color});
  final Color color;

  @override
  State<_MonthlyCashInActionPanel> createState() =>
      _MonthlyCashInActionPanelState();
}

class _MonthlyCashInActionPanelState extends State<_MonthlyCashInActionPanel> {
  Future<void> _editTarget(AppState state, double current) async {
    final updated = await _showMoneyTargetDialog(
      context: context,
      title: 'Set monthly cash-in target',
      label: 'Monthly cash-in target',
      initialAmount: current,
      color: widget.color,
    );
    if (updated == null) return;
    state.actionFieldValues['A20'] = {'amt': updated.toStringAsFixed(0)};
    await state.saveProfile();
    if (mounted) setState(() {});
  }

  void _showIncludedCashIn(List<FakeMayaTransaction> transactions) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final localizations = MaterialLocalizations.of(context);
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Cash-in counted this month',
                style: TextStyle(
                    color: _title, fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Income, side gigs, transfers received, and other positive cash-in count toward this action.',
                style: TextStyle(color: _body, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (transactions.isEmpty)
                const Text(
                  'No cash-in transactions are recorded for this month yet.',
                  style: TextStyle(color: _body, fontWeight: FontWeight.w700),
                )
              else
                for (final transaction in transactions)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.payments_rounded, color: _sage),
                    title: Text(transaction.title),
                    subtitle: Text(transaction.createdAt == null
                        ? transaction.category ?? 'Cash-in'
                        : '${transaction.category ?? 'Cash-in'} · ${localizations.formatShortDate(transaction.createdAt!)}'),
                    trailing: Text(
                      money(transaction.amount),
                      style: const TextStyle(
                          color: _sage, fontWeight: FontWeight.w900),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final recommended = _recommendedMonthlyEarnings(state);
    final target = _configuredActionAmount(state, 'A20', recommended);
    final cashInTransactions = _currentMonthPositiveTransactions(state);
    final cashIn = cashInTransactions.fold<double>(
      0,
      (total, transaction) => total + transaction.amount,
    );
    final progress = target <= 0 ? 0.0 : (cashIn / target).clamp(0.0, 1.0);
    final remaining = math.max(0.0, target - cashIn);
    final complete = cashIn >= target && target > 0;
    final barColor = complete ? _sage : widget.color;

    return _ActionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionPanelHeader(
            id: 'A20',
            color: widget.color,
            text:
                'Bring in at least ${money(target)} this month from income, side gigs, or other cash-in.',
          ),
          const SizedBox(height: 14),
          _ActionMetricTile(
            icon: Icons.payments_rounded,
            label: 'Cash-in this month',
            value: money(cashIn),
            color: _sage,
          ),
          const SizedBox(height: 10),
          _ActionMetricTile(
            icon: Icons.flag_rounded,
            label: 'Monthly target',
            value: money(target),
            color: widget.color,
          ),
          const SizedBox(height: 14),
          _LabeledProgressBar(
            value: progress,
            color: barColor,
            leadingLabel: money(cashIn),
            trailingLabel: money(target),
          ),
          const SizedBox(height: 8),
          Text(
            complete
                ? 'Target reached. Extra cash-in gives this month more breathing room.'
                : '${money(remaining)} more cash-in needed to reach this month\'s target.',
            style: TextStyle(
              color: complete ? _sage : _body,
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editTarget(state, target),
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Edit target'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showIncludedCashIn(cashInTransactions),
                  icon: const Icon(Icons.list_alt_rounded),
                  label: const Text('View cash-in'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EverydayFundFloorActionPanel extends StatefulWidget {
  const _EverydayFundFloorActionPanel({required this.color});
  final Color color;

  @override
  State<_EverydayFundFloorActionPanel> createState() =>
      _EverydayFundFloorActionPanelState();
}

class _EverydayFundFloorActionPanelState
    extends State<_EverydayFundFloorActionPanel> {
  Future<void> _editFloor(AppState state, double current) async {
    final updated = await _showMoneyTargetDialog(
      context: context,
      title: 'Set Essential Expenses Fund minimum',
      label: 'Essential Expenses Fund minimum',
      initialAmount: current,
      color: widget.color,
    );
    if (updated == null) return;
    state.actionFieldValues['A19'] = {'amt': updated.toStringAsFixed(0)};
    await state.saveProfile();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final recommended = _recommendedEssentialFundFloor(state);
    final floor = _configuredActionAmount(state, 'A19', recommended);
    final essentialFund = state.essentialExpensesBalance;
    final monthlyExpenses = math.max(1.0, _monthlyExpenseBase(state));
    final floorMonths = floor / monthlyExpenses;
    final currentMonths = essentialFund / monthlyExpenses;
    final shortfall = math.max(0.0, floor - essentialFund);
    final safe = essentialFund >= floor && floor > 0;
    final trackMax = math.max(floor * 1.25, essentialFund);
    final progress = trackMax <= 0 ? 0.0 : (essentialFund / trackMax);
    final marker = trackMax <= 0 ? 0.0 : (floor / trackMax);
    final barColor = safe ? _sage : _amber;

    return _ActionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionPanelHeader(
            id: 'A19',
            color: widget.color,
            text:
                'Keep at least ${money(floor)} in your Essential Expenses Fund before spending below your essentials floor.',
          ),
          const SizedBox(height: 14),
          _ActionMetricTile(
            icon: Icons.savings_rounded,
            label: 'Essential Expenses Fund now',
            value: money(essentialFund),
            color: barColor,
          ),
          const SizedBox(height: 10),
          _ActionMetricTile(
            icon: Icons.horizontal_rule_rounded,
            label: 'Minimum floor',
            value: money(floor),
            color: widget.color,
          ),
          const SizedBox(height: 14),
          _ThresholdProgressBar(
            value: progress.clamp(0.0, 1.0),
            marker: marker.clamp(0.0, 1.0),
            color: barColor,
            markerColor: widget.color,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${currentMonths.toStringAsFixed(1)} months covered',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'Floor: ${floorMonths.toStringAsFixed(1)} months',
                style: TextStyle(
                  color: widget.color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            safe
                ? 'Your Essential Expenses Fund is above the minimum line.'
                : '${money(shortfall)} more is needed to get back above the minimum line.',
            style: TextStyle(
              color: safe ? _sage : _amber,
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _editFloor(state, floor),
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Edit floor'),
          ),
        ],
      ),
    );
  }
}

class _ActionCardShell extends StatelessWidget {
  const _ActionCardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }
}

class _ActionPanelHeader extends StatelessWidget {
  const _ActionPanelHeader({
    required this.id,
    required this.color,
    required this.text,
  });
  final String id;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(8)),
          child: Text(id,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                color: _title,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _LabeledProgressBar extends StatelessWidget {
  const _LabeledProgressBar({
    required this.value,
    required this.color,
    required this.leadingLabel,
    required this.trailingLabel,
  });
  final double value;
  final Color color;
  final String leadingLabel;
  final String trailingLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 10,
            color: color,
            backgroundColor: color.withValues(alpha: .12),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(leadingLabel,
                style: const TextStyle(
                    color: _body, fontSize: 10.5, fontWeight: FontWeight.w800)),
            const Spacer(),
            Text(trailingLabel,
                style: const TextStyle(
                    color: _title,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ],
    );
  }
}

class _ThresholdProgressBar extends StatelessWidget {
  const _ThresholdProgressBar({
    required this.value,
    required this.marker,
    required this.color,
    required this.markerColor,
  });
  final double value;
  final double marker;
  final Color color;
  final Color markerColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final markerLeft = (constraints.maxWidth * marker.clamp(0.0, 1.0) - 2)
              .clamp(0.0, math.max(0.0, constraints.maxWidth - 4))
              .toDouble();
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  minHeight: 10,
                  color: color,
                  backgroundColor: _border.withValues(alpha: .8),
                ),
              ),
              Positioned(
                left: markerLeft,
                top: 1,
                bottom: 1,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: markerColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: .12),
                          blurRadius: 4,
                          offset: const Offset(0, 1)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<double?> _showMoneyTargetDialog({
  required BuildContext context,
  required String title,
  required String label,
  required double initialAmount,
  required Color color,
}) {
  final controller =
      TextEditingController(text: initialAmount.toStringAsFixed(0));
  return showDialog<double>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        final amount =
            double.tryParse(controller.text.replaceAll(',', '').trim()) ?? 0;
        final valid = amount >= 100 && amount <= 1000000;
        return AlertDialog(
          backgroundColor: _surface,
          title: Text(title,
              style:
                  const TextStyle(color: _title, fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: _title,
                      fontSize: 12,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,7}$')),
                ],
                decoration: inputDecoration('0').copyWith(prefixText: '₱ '),
                onChanged: (_) => setDialogState(() {}),
              ),
              const SizedBox(height: 8),
              Text(
                valid
                    ? 'Shellby will use ${money(amount)} for this action.'
                    : 'Use an amount from ₱100 to ₱1,000,000.',
                style: TextStyle(
                  color: valid ? color : _red,
                  fontSize: 11,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed:
                  valid ? () => Navigator.of(dialogContext).pop(amount) : null,
              child: const Text('Save'),
            ),
          ],
        );
      },
    ),
  ).whenComplete(controller.dispose);
}

Future<double?> _showMonthsTargetDialog({
  required BuildContext context,
  required String title,
  required double initialMonths,
  required Color color,
  String fieldLabel = 'Months of essential expenses',
  String? validDescription,
}) {
  final controller =
      TextEditingController(text: initialMonths.toStringAsFixed(0));
  return showDialog<double>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        final months =
            double.tryParse(controller.text.replaceAll(',', '').trim()) ?? 0;
        final valid =
            months >= 1 && months <= 12 && months == months.roundToDouble();
        return AlertDialog(
          backgroundColor: _surface,
          title: Text(title,
              style:
                  const TextStyle(color: _title, fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fieldLabel,
                  style: const TextStyle(
                      color: _title,
                      fontSize: 12,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: inputDecoration('3').copyWith(suffixText: 'months'),
                onChanged: (_) => setDialogState(() {}),
              ),
              const SizedBox(height: 8),
              Text(
                valid
                    ? validDescription ??
                        'Shellby will target ${months.toStringAsFixed(0)} months of essential expenses.'
                    : 'Use a whole number from 1 to 12 months.',
                style: TextStyle(
                  color: valid ? color : _red,
                  fontSize: 11,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed:
                  valid ? () => Navigator.of(dialogContext).pop(months) : null,
              child: const Text('Save'),
            ),
          ],
        );
      },
    ),
  ).whenComplete(controller.dispose);
}

typedef _HobbyDraft = ({String name, double target, int months});

Future<_HobbyDraft?> _showHobbyDialog({
  required BuildContext context,
  required String title,
  required Color color,
  String initialName = '',
  double initialTarget = 10000,
  int initialMonths = 6,
}) {
  final nameController = TextEditingController(text: initialName);
  final amountController =
      TextEditingController(text: initialTarget.toStringAsFixed(0));
  final monthsController =
      TextEditingController(text: initialMonths.toString());
  return showDialog<_HobbyDraft>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        final name = nameController.text.trim();
        final target =
            double.tryParse(amountController.text.replaceAll(',', '').trim()) ??
                0;
        final months =
            int.tryParse(monthsController.text.replaceAll(',', '').trim()) ?? 0;
        final valid = name.isNotEmpty &&
            target >= 100 &&
            target <= 1000000 &&
            months >= 1 &&
            months <= 24;
        return AlertDialog(
          backgroundColor: _surface,
          title: Text(title,
              style:
                  const TextStyle(color: _title, fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hobby or activity name',
                  style: TextStyle(
                      color: _title,
                      fontSize: 12,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                autofocus: true,
                maxLength: 30,
                decoration: inputDecoration('e.g. Photography')
                    .copyWith(counterText: ''),
                onChanged: (_) => setDialogState(() {}),
              ),
              const SizedBox(height: 10),
              const Text('Target amount',
                  style: TextStyle(
                      color: _title,
                      fontSize: 12,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,7}$')),
                ],
                decoration: inputDecoration('0').copyWith(prefixText: '₱ '),
                onChanged: (_) => setDialogState(() {}),
              ),
              const SizedBox(height: 10),
              const Text('Target window',
                  style: TextStyle(
                      color: _title,
                      fontSize: 12,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              TextField(
                controller: monthsController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: inputDecoration('6').copyWith(suffixText: 'months'),
                onChanged: (_) => setDialogState(() {}),
              ),
              const SizedBox(height: 8),
              Text(
                valid
                    ? 'Save ${money(target)} for "$name" within $months months.'
                    : 'Enter a name, an amount from ₱100 to ₱1,000,000, and 1-24 months.',
                style: TextStyle(
                  color: valid ? color : _red,
                  fontSize: 11,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: valid
                  ? () => Navigator.of(dialogContext).pop(
                        (name: name, target: target, months: months),
                      )
                  : null,
              child: const Text('Save'),
            ),
          ],
        );
      },
    ),
  ).whenComplete(() {
    nameController.dispose();
    amountController.dispose();
    monthsController.dispose();
  });
}

Future<double?> _showPercentTargetDialog({
  required BuildContext context,
  required String title,
  required String label,
  required double initialPercent,
  required Color color,
}) {
  final controller =
      TextEditingController(text: initialPercent.toStringAsFixed(0));
  return showDialog<double>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        final percent =
            double.tryParse(controller.text.replaceAll(',', '').trim()) ?? 0;
        final valid = percent >= 1 && percent <= 100;
        return AlertDialog(
          backgroundColor: _surface,
          title: Text(title,
              style:
                  const TextStyle(color: _title, fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: _title,
                      fontSize: 12,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: inputDecoration('8').copyWith(suffixText: '%'),
                onChanged: (_) => setDialogState(() {}),
              ),
              const SizedBox(height: 8),
              Text(
                valid
                    ? 'Shellby will use ${percent.toStringAsFixed(0)}% for this action.'
                    : 'Use a percentage from 1% to 100%.',
                style: TextStyle(
                  color: valid ? color : _red,
                  fontSize: 11,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed:
                  valid ? () => Navigator.of(dialogContext).pop(percent) : null,
              child: const Text('Save'),
            ),
          ],
        );
      },
    ),
  ).whenComplete(controller.dispose);
}

double _configuredActionAmount(
  AppState state,
  String actionId,
  double fallback,
) {
  final raw = _configuredActionValues(state, actionId)['amt'];
  return double.tryParse((raw ?? '').replaceAll(',', '').trim()) ?? fallback;
}

Map<String, String> _configuredActionValues(AppState state, String actionId) {
  final existing = state.actionFieldValues[actionId];
  if (existing != null) return existing;
  final action = _d2Actions[actionId];
  if (action == null) return const <String, String>{};
  return _initialActionFieldValues(state, action);
}

DateTime _currentMonthStart() {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
}

bool _isInCurrentMonth(DateTime? date) {
  if (date == null) return false;
  final start = _currentMonthStart();
  return date.year == start.year && date.month == start.month;
}

List<FakeMayaTransaction> _currentMonthPositiveTransactions(AppState state) {
  return state.allTransactions.where((transaction) {
    if (transaction.amount <= 0 ||
        transaction.isInternalFakeMayaTransfer ||
        !_isInCurrentMonth(transaction.createdAt)) {
      return false;
    }
    final text = '${transaction.title} ${transaction.detail}'.toLowerCase();
    return !text.contains('account opened');
  }).toList()
    ..sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
}

double _currentMonthEmergencyDeposits(AppState state) {
  return state.d1Ledger.where((entry) {
    if (entry['type'] != 'emergency_deposit') return false;
    final date = DateTime.tryParse(entry['date']?.toString() ?? '');
    return _isInCurrentMonth(date);
  }).fold<double>(
    0,
    (total, entry) => total + ((entry['amount'] as num?)?.toDouble() ?? 0),
  );
}

double _currentEverydayFundAmount(AppState state) {
  return math.max(
    state.essentialExpensesBalance,
    math.max(state.needsBalance, state.accountBalance('Wallet')),
  );
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
                  style: const TextStyle(
                      color: _body, fontSize: 9.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: _title, fontSize: 12, fontWeight: FontWeight.w900),
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
            decoration:
                BoxDecoration(color: amountColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                      color: _body, fontSize: 10, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 1),
                Text(
                  event,
                  style: const TextStyle(
                      color: _title,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: TextStyle(
                color: amountColor, fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _DataPointRow extends StatelessWidget {
  const _DataPointRow(
      {required this.label, required this.type, required this.value});
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
              style: TextStyle(
                  color: _typeColor, fontSize: 9, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  color: _body, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
                color: _title, fontSize: 12, fontWeight: FontWeight.w800),
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
    final authEmail = FirebaseProfileService.currentUser?.email?.trim() ?? '';
    final profileEmail = authEmail.isNotEmpty ? authEmail : state.email;
    final settings = [
      _SettingData(
        'User Selections',
        Icons.fact_check_outlined,
        'View',
        () => _push(context, const UserSelectionsScreen()),
      ),
      _SettingData(
        'Notifications',
        Icons.notifications_outlined,
        state.notificationsAllowed
            ? '${state.notificationReminderMinutes.length} daily'
            : 'Off',
        () => _push(context, const NotificationSettingsScreen()),
      ),
      const _SettingData('Privacy & security', Icons.shield_outlined, ''),
      _SettingData(
        'Accounts',
        Icons.credit_card_outlined,
        state.fakeMayaSyncedAccounts.isEmpty
            ? 'Manual'
            : '${state.fakeMayaSyncedAccounts.length} synced',
        () => _push(context, const LinkedAccountsScreen()),
      ),
      const _SettingData('Appearance', Icons.palette_outlined, 'Light'),
    ];
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _SelectionsHeader(
              title: 'You',
              subtitle: 'PROFILE',
              onBack: () => Navigator.maybePop(context),
            ),
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
                          profileEmail.isEmpty
                              ? 'Profile saved securely'
                              : profileEmail,
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
                                emoji: '⏰',
                                value: state.notificationReminderMinutes.isEmpty
                                    ? '--'
                                    : _formatReminderMinutes(state
                                        .notificationReminderMinutes.first),
                                label: 'reminder',
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
                  if (state.canOverwriteWithMockData) ...[
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
                      ),
                      child: SwitchListTile.adaptive(
                        value: state.mockDataEnabled,
                        activeColor: _purple,
                        secondary: const Icon(
                          Icons.science_rounded,
                          color: _purple,
                        ),
                        title: const Text(
                          'Overwrite with mock data',
                          style: TextStyle(
                            color: _title,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        onChanged: (enabled) async {
                          if (enabled) {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                backgroundColor: _surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                title: const Text('Overwrite mock data?'),
                                content: const Text(
                                  'This will replace this account with a realistic four-month Emergency Fund scenario.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _purple,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: const Text('Overwrite'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed != true || !context.mounted) return;
                          }
                          try {
                            await AppScope.of(context)
                                .setMockDataEnabled(enabled);
                            if (!context.mounted) return;
                            showAppNotice(
                              context,
                              message: enabled
                                  ? 'Mock Emergency Fund data loaded.'
                                  : 'Mock data mode turned off.',
                              icon: enabled
                                  ? Icons.check_circle_rounded
                                  : Icons.science_outlined,
                            );
                          } on StateError catch (error) {
                            if (!context.mounted) return;
                            showAppNotice(
                              context,
                              message: error.message,
                              icon: Icons.warning_amber_rounded,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final times = state.notificationReminderMinutes;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: GoogleFonts.fredoka(
                        color: _title,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _border),
                    ),
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: state.notificationsAllowed,
                      activeColor: _brand,
                      title: const Text(
                        'Transaction reminders',
                        style: TextStyle(
                          color: _title,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: const Text(
                        'Shelby will remind you to log cash or sync connected accounts.',
                        style: TextStyle(
                          color: _body,
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onChanged: (enabled) async {
                        await state.setTransactionRemindersEnabled(enabled);
                        if (!context.mounted) return;
                        if (enabled && !state.notificationsAllowed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Notifications are disabled in iPhone Settings.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'DAILY TIMES',
                          style: TextStyle(
                            color: _body,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Add reminder time',
                        onPressed: times.length >= 8
                            ? null
                            : () => _addReminderTime(context, state),
                        icon: const Icon(Icons.add_alarm_rounded),
                        color: _purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (times.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _border),
                      ),
                      child: const Text(
                        'No reminder times yet. Add a time that fits your routine.',
                        style: TextStyle(
                          color: _body,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        children: [
                          for (var index = 0;
                              index < times.length;
                              index++) ...[
                            ListTile(
                              leading: const Icon(
                                Icons.schedule_rounded,
                                color: _purple,
                              ),
                              title: Text(
                                _formatReminderMinutes(times[index]),
                                style: const TextStyle(
                                  color: _title,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              subtitle: const Text(
                                'Every day',
                                style: TextStyle(
                                  color: _body,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onTap: () =>
                                  _editReminderTime(context, state, index),
                              trailing: IconButton(
                                tooltip: 'Remove time',
                                onPressed: () {
                                  final updated = List<int>.of(times)
                                    ..removeAt(index);
                                  state.setNotificationReminderTimes(updated);
                                },
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ),
                            if (index < times.length - 1)
                              const Divider(height: 1, color: _border),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showTestNotification(context, state),
                      icon: const Icon(Icons.notifications_active_rounded),
                      label: const Text('Send test notification'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Times follow this iPhone’s timezone. iOS may group banners according to your notification and Focus settings.',
                    style: TextStyle(
                      color: _body,
                      fontSize: 11,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addReminderTime(
    BuildContext context,
    AppState state,
  ) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
    );
    if (selected == null) return;
    await state.setNotificationReminderTimes([
      ...state.notificationReminderMinutes,
      selected.hour * 60 + selected.minute,
    ]);
  }

  Future<void> _editReminderTime(
    BuildContext context,
    AppState state,
    int index,
  ) async {
    final current = state.notificationReminderMinutes[index];
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (selected == null) return;
    final updated = List<int>.of(state.notificationReminderMinutes);
    updated[index] = selected.hour * 60 + selected.minute;
    await state.setNotificationReminderTimes(updated);
  }

  Future<void> _showTestNotification(
    BuildContext context,
    AppState state,
  ) async {
    if (!state.notificationsAllowed) {
      final granted = await state.enableTransactionReminders();
      if (!granted) return;
    }
    await ShellbyNotificationService.instance.showTestReminder();
  }
}

String _formatReminderMinutes(int value) {
  final hour24 = value ~/ 60;
  final minute = (value % 60).toString().padLeft(2, '0');
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  return '$hour12:$minute ${hour24 < 12 ? 'AM' : 'PM'}';
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

class LinkedAccountsScreen extends StatefulWidget {
  const LinkedAccountsScreen({
    super.key,
    this.openFakeMayaLoginOnStart = false,
  });

  final bool openFakeMayaLoginOnStart;

  @override
  State<LinkedAccountsScreen> createState() => _LinkedAccountsScreenState();
}

class _LinkedAccountsScreenState extends State<LinkedAccountsScreen> {
  bool _openedFakeMayaLogin = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_openedFakeMayaLogin ||
        !widget.openFakeMayaLoginOnStart ||
        AppScope.of(context).fakeMayaLink != null) {
      return;
    }
    _openedFakeMayaLogin = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showFakeMayaLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    const allAccounts = [
      (
        'Cash on Hand',
        Icons.payments_rounded,
        _sage,
        'Cash you enter manually'
      ),
      (
        'Wallet',
        Icons.account_balance_wallet_rounded,
        _brand,
        'Daily spending'
      ),
      ('Savings', Icons.savings_rounded, _amber, 'Savings balance'),
      ('Time Deposit', Icons.lock_clock_rounded, _purple, 'Locked savings'),
      ('Goal Savings', Icons.flag_rounded, Color(0xFF6AA8F0), 'Goal balance'),
    ];
    final accounts = [
      for (final account in allAccounts)
        if (state.accountExistsInFakeMaya(account.$1)) account,
    ];
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _SelectionsHeader(
              title: 'Accounts',
              subtitle:
                  'Keep accounts manual or sync selected balances with FakeMaya.',
              onBack: () => Navigator.maybePop(context),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _bellySoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Manual mode always works. Log transactions from Activity to update a manual account. Sync only the accounts you want automated.',
                      style: TextStyle(
                        color: _body,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final account in accounts) ...[
                    _AccountSourceCard(
                      name: account.$1,
                      icon: account.$2,
                      color: account.$3,
                      description: account.$4,
                      balance: state.accountBalance(account.$1),
                      synced: state.isAccountSynced(account.$1),
                      canSync: account.$1 != 'Cash on Hand',
                      onManual: () =>
                          state.setAccountFakeMayaSync(account.$1, false),
                      onSync: () => _syncAccount(context, account.$1),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (state.fakeMayaLink != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            label: 'Refresh synced',
                            icon: Icons.sync_rounded,
                            onPressed: () => _refreshFakeMaya(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SecondaryButton(
                            label: 'Disconnect',
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
          ],
        ),
      ),
    );
  }

  Future<void> _showFakeMayaLogin({String? syncOnlyAccount}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FakeMayaLoginSheet(syncOnlyAccount: syncOnlyAccount),
    );
  }

  Future<void> _syncAccount(BuildContext context, String account) async {
    final state = AppScope.of(context);
    if (state.fakeMayaLink != null) {
      await state.setAccountFakeMayaSync(account, true);
      return;
    }
    await _showFakeMayaLogin(syncOnlyAccount: account);
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

class _AccountSourceCard extends StatelessWidget {
  const _AccountSourceCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.balance,
    required this.synced,
    required this.canSync,
    required this.onManual,
    required this.onSync,
  });

  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final double balance;
  final bool synced;
  final bool canSync;
  final VoidCallback onManual;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              IconBubble(icon,
                  color: color, background: color.withValues(alpha: .1)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: _title, fontWeight: FontWeight.w900)),
                    Text(description,
                        style: const TextStyle(
                            color: _body,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Text(money(balance),
                  style: const TextStyle(
                      color: _title, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  selected: !synced,
                  label: const Text('Manual'),
                  avatar: const Icon(Icons.edit_rounded, size: 16),
                  onSelected: (_) => onManual(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  selected: synced,
                  label: Text(canSync ? 'Sync' : 'Manual only'),
                  avatar: Icon(
                    canSync ? Icons.sync_rounded : Icons.lock_outline_rounded,
                    size: 16,
                  ),
                  onSelected: canSync ? (_) => onSync() : null,
                ),
              ),
            ],
          ),
          if (synced) ...[
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Automatically updated from FakeMaya',
                style: TextStyle(
                    color: _sage, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FakeMayaLoginSheet extends StatefulWidget {
  const _FakeMayaLoginSheet({this.syncOnlyAccount});

  final String? syncOnlyAccount;

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
        syncedAccounts:
            widget.syncOnlyAccount == null ? null : [widget.syncOnlyAccount!],
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
    final authEmail = FirebaseProfileService.currentUser?.email?.trim() ?? '';
    final profileEmail = authEmail.isNotEmpty ? authEmail : state.email;
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
                      ('Email', _fallback(profileEmail, 'Not provided')),
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
    return amount > 0 && transaction?.isInternalFakeMayaTransfer != true;
  }

  bool get countsAsExpense {
    return amount < 0;
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
    if (filter == 'Money in') return countsAsIncome;
    if (filter == 'Money out') return amount < 0;
    return category.toLowerCase().contains(filter.toLowerCase()) ||
        name.toLowerCase().contains(filter.toLowerCase()) ||
        source.toLowerCase().contains(filter.toLowerCase());
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
                  style: const TextStyle(
                    color: _title,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
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
                  style: const TextStyle(
                    color: _title,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
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
                    : 'Use the Transaction button to log cash manually, or link FakeMaya for synced activity.',
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _title,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (income > 0) ...[
            const SizedBox(width: 8),
            const Text('IN ',
                style: TextStyle(
                    color: _green, fontSize: 12, fontWeight: FontWeight.w900)),
            Text(money(income),
                style: const TextStyle(
                    color: _title, fontSize: 13, fontWeight: FontWeight.w900)),
          ],
          if (income > 0 && expense > 0) const SizedBox(width: 10),
          if (expense > 0) ...[
            if (income <= 0) const SizedBox(width: 8),
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
    final positive = data.countsAsIncome;
    final transaction = data.transaction;
    final needsLabel = transaction != null &&
        !transaction.isInternalFakeMayaTransfer &&
        !transaction.isLabeled &&
        transaction.amount != 0;
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

class _ManualTransactionSheet extends StatefulWidget {
  const _ManualTransactionSheet();

  @override
  State<_ManualTransactionSheet> createState() =>
      _ManualTransactionSheetState();
}

class _ManualTransactionSheetState extends State<_ManualTransactionSheet> {
  static const _incomeCategories = [
    'Salary',
    'Business income',
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
    'Debt payment',
    'Entertainment',
    'Travel',
    'Personal goal',
    'Gifts & giving',
    'Other expense',
  ];
  static const _sources = [
    'Basic Needs Fund',
    'Emergency Fund',
    'Investment',
    'Time Deposit',
  ];

  final _nameController = TextEditingController();
  final _detail = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _moneyIn = false;
  String _account = 'Cash on Hand';
  String? _category;
  String? _source;
  DateTime _occurredAt = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _detail.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final categories = _moneyIn ? _incomeCategories : _expenseCategories;
    final accounts = [
      'Cash on Hand',
      for (final account in const [
        'Wallet',
        'Savings',
        'Time Deposit',
        'Goal Savings',
      ])
        if (!state.isAccountSynced(account)) account,
    ];
    if (!accounts.contains(_account)) _account = accounts.first;
    return _GoalSheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Log transaction',
            style: GoogleFonts.fredoka(
              color: _title,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _account,
            decoration: inputDecoration('Choose an account').copyWith(
              labelText: 'Account',
            ),
            items: accounts
                .map((value) =>
                    DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) => setState(() => _account = value ?? _account),
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                icon: Icon(Icons.north_east_rounded),
                label: Text('Money out'),
              ),
              ButtonSegment(
                value: true,
                icon: Icon(Icons.south_west_rounded),
                label: Text('Money in'),
              ),
            ],
            selected: {_moneyIn},
            onSelectionChanged: (selection) => setState(() {
              _moneyIn = selection.first;
              _category = null;
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            decoration: inputDecoration('e.g. Lunch at campus').copyWith(
              labelText: 'Transaction name',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: inputDecoration('0.00').copyWith(
              labelText: 'Amount',
              prefixText: '₱ ',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: inputDecoration('Choose a category').copyWith(
              labelText: 'Category',
            ),
            items: categories
                .map((value) =>
                    DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _source,
            decoration: inputDecoration('Choose a fund').copyWith(
              labelText: 'Fund source',
            ),
            items: _sources
                .map((value) =>
                    DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) => setState(() => _source = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _detail,
            textCapitalization: TextCapitalization.sentences,
            decoration: inputDecoration('Merchant, person, or context')
                .copyWith(labelText: 'Details (optional)'),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_rounded, color: _purple),
            title: const Text(
              'Transaction date',
              style: TextStyle(color: _title, fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              _manualDateLabel(_occurredAt),
              style: const TextStyle(color: _body, fontWeight: FontWeight.w700),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _pickDate,
          ),
          TextField(
            controller: _note,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: inputDecoration('Anything useful to remember')
                .copyWith(labelText: 'Note (optional)'),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: _saving ? 'Saving…' : 'Save transaction',
            icon: Icons.check_rounded,
            enabled: !_saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (value == null || !mounted) return;
    setState(() {
      _occurredAt = DateTime(
        value.year,
        value.month,
        value.day,
        _occurredAt.hour,
        _occurredAt.minute,
      );
    });
  }

  Future<void> _save() async {
    final title = _nameController.text.trim();
    final amount = double.tryParse(_amount.text.replaceAll(',', ''));
    final category = _category;
    final source = _source;
    if (title.isEmpty ||
        amount == null ||
        amount <= 0 ||
        category == null ||
        source == null) {
      showAppNotice(
        context,
        message: 'Enter a name and amount, then choose a category and fund.',
        icon: Icons.warning_amber_rounded,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await AppScope.of(context).addManualCashTransaction(
        title: title,
        detail: _detail.text,
        amount: _moneyIn ? amount : -amount,
        occurredAt: _occurredAt,
        category: category,
        source: source,
        note: _optionalManualText(_note.text),
        account: _account,
      );
      if (!mounted) return;
      Navigator.pop(context);
      showAppNotice(
        context,
        message: 'Cash transaction saved.',
        icon: Icons.check_circle_rounded,
      );
    } on StateError catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppNotice(
        context,
        message: error.message,
        icon: Icons.warning_amber_rounded,
      );
    }
  }
}

String _manualDateLabel(DateTime value) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[value.month - 1]} ${value.day}, ${value.year}';
}

String? _optionalManualText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

class _TransactionLabelSheet extends StatefulWidget {
  const _TransactionLabelSheet({required this.transaction});

  final FakeMayaTransaction transaction;

  @override
  State<_TransactionLabelSheet> createState() => _TransactionLabelSheetState();
}

class _TransactionCategoryOption {
  const _TransactionCategoryOption.category(String category)
      : value = category,
        label = category,
        enabled = true;

  const _TransactionCategoryOption.header(this.label)
      : value = null,
        enabled = false;

  final String? value;
  final String label;
  final bool enabled;
}

class _TransactionSourceOption {
  const _TransactionSourceOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  final String value;
  final String label;
  final bool enabled;
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
    'Debt payment',
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

  // The financial layer is the top-level choice; it filters which
  // categories are shown and picks the FakeMaya bucket "Get from fund?"
  // pulls from. The Financial Safety layer still uses the Emergency Fund as
  // its money source.
  static const _financialLayers = [
    'Cash Flow & Basic Needs',
    'Financial Safety',
    'Accumulating Wealth',
    'Financial Freedom',
  ];
  static const _financialLayerMotivations = {
    'Cash Flow & Basic Needs': 'Cash Flow & Basic Needs',
    'Financial Safety': 'Financial Safety',
    'Accumulating Wealth': 'Accumulating Wealth',
    'Financial Freedom': 'Financial Freedom',
  };
  static const _financialLayerSources = {
    'Cash Flow & Basic Needs': 'Basic Needs Fund',
    'Financial Safety': 'Emergency Fund',
    'Accumulating Wealth': 'Investment',
    'Financial Freedom': 'Personal Lifestyle Fund',
  };
  static const _eWalletSource = 'E-wallet';
  // Categories not listed here (e.g. "Transfer", "Other expense/income")
  // are generic and stay available under every layer.
  static const _layerCategories = {
    'Cash Flow & Basic Needs': [
      'Food & drink',
      'Transport',
      'Bills & utilities',
      'Housing',
      'Groceries',
      'Salary',
      'Refund',
    ],
    'Financial Safety': ['Health', 'Insurance'],
    'Accumulating Wealth': ['Debt payment', 'Education', 'Business income'],
    'Financial Freedom': [
      'Shopping',
      'Entertainment',
      'Travel',
      'Gifts & giving',
      'Personal goal',
      'Gift',
    ],
  };
  static const _genericCategories = [
    'Transfer',
    'Other expense',
    'Other income'
  ];

  late String? _financialLayer = _initialFinancialLayer(widget.transaction);
  late String? _category = widget.transaction.category;
  late String? _source = _initialSource(widget.transaction);
  late final TextEditingController _subcategory = TextEditingController(
    text: widget.transaction.subcategory ?? '',
  );
  late String? _tag = widget.transaction.tag;
  late final TextEditingController _note = TextEditingController(
    text: widget.transaction.note ?? '',
  );
  late bool _excluded = widget.transaction.excludedFromInsights;
  bool _saving = false;
  // null = not answered yet for the current layer+category pair.
  bool? _pullFromBucket;

  @override
  void dispose() {
    _subcategory.dispose();
    _note.dispose();
    super.dispose();
  }

  List<_TransactionCategoryOption> _categoryOptionsForLayer(
    AppState state,
    bool isIncome,
  ) {
    final base = isIncome ? _incomeCategories : _expenseCategories;
    if (isIncome) {
      return [
        for (final category in base)
          _TransactionCategoryOption.category(category),
      ];
    }
    final layer = _financialLayer;
    if (layer == null) return const [];
    if (layer == _pyramidCashFlowLayer) {
      final pyramidOptions = _cashFlowBasicNeedsCategoryOptions(state);
      if (pyramidOptions.isNotEmpty) return pyramidOptions;
    }
    final allowed = {..._genericCategories, ...?_layerCategories[layer]};
    final filtered = base.where(allowed.contains).toList();
    return [
      for (final category in (filtered.isEmpty ? base : filtered))
        _TransactionCategoryOption.category(category),
    ];
  }

  List<String> _enabledCategoryValuesForLayer(
    AppState state,
    bool isIncome,
  ) {
    return [
      for (final option in _categoryOptionsForLayer(state, isIncome))
        if (option.enabled && option.value != null) option.value!,
    ];
  }

  List<_TransactionCategoryOption> _cashFlowBasicNeedsCategoryOptions(
    AppState state,
  ) {
    final entries = _onboardingEntriesForLayer(state, _pyramidCashFlowLayer)
        .where((entry) => !entry.isIncome && entry.amount > 0)
        .toList();
    final withDueDate = _uniqueCategoryEntries(
      entries.where((entry) => entry.hasDueDate),
    );
    final withoutDueDate = _uniqueCategoryEntries(
      entries.where((entry) => !entry.hasDueDate),
    );
    return [
      if (withDueDate.isNotEmpty) ...[
        const _TransactionCategoryOption.header('With due date'),
        for (final entry in withDueDate)
          _TransactionCategoryOption.category(entry.name),
      ],
      if (withoutDueDate.isNotEmpty) ...[
        const _TransactionCategoryOption.header('Without due date'),
        for (final entry in withoutDueDate)
          _TransactionCategoryOption.category(entry.name),
      ],
    ];
  }

  List<_PyramidBaselineEntry> _uniqueCategoryEntries(
    Iterable<_PyramidBaselineEntry> entries,
  ) {
    final seen = <String>{};
    return [
      for (final entry in entries)
        if (seen.add(entry.name.trim().toLowerCase())) entry,
    ];
  }

  List<_TransactionSourceOption> _sourcesForLayer(
    AppState state,
    bool isIncome,
  ) {
    if (isIncome) return const [];
    final layer = _financialLayer;
    final fund = layer == null ? null : _financialLayerSources[layer];
    final fundEnabled = layer != null && _fundSourceIsAvailable(state, layer);
    return [
      const _TransactionSourceOption(
        value: _eWalletSource,
        label: _eWalletSource,
      ),
      if (fund != null)
        _TransactionSourceOption(
          value: fund,
          label: fundEnabled ? fund : '$fund (not enough)',
          enabled: fundEnabled,
        ),
    ];
  }

  bool _fundSourceIsAvailable(AppState state, String layer) {
    final motivation = _financialLayerMotivations[layer];
    final bucketId =
        motivation == null ? null : fakeMayaBucketIdForMotivation(motivation);
    final bucket = bucketId == null
        ? null
        : state.fakeMayaLink?.summary.personalGoalById(bucketId);
    return bucket != null && bucket.balance >= widget.transaction.amount.abs();
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final isIncome = transaction.amount >= 0;
    final state = AppScope.of(context);
    final categoryOptions = _categoryOptionsForLayer(state, isIncome);
    final enabledCategories = [
      for (final option in categoryOptions)
        if (option.enabled && option.value != null) option.value!,
    ];
    final canChooseCategory =
        (isIncome || _financialLayer != null) && enabledCategories.isNotEmpty;
    final categoryHint = canChooseCategory
        ? 'Choose a category'
        : _financialLayer == null && !isIncome
            ? 'Choose a financial layer first'
            : 'Add pyramid expenses first';
    final sourceOptions = _sourcesForLayer(state, isIncome);
    final enabledSourceValues = [
      for (final option in sourceOptions)
        if (option.enabled) option.value,
    ];
    final canChooseSource =
        isIncome || (_financialLayer != null && _category != null);
    final selectedSourceIsEnabled =
        isIncome || enabledSourceValues.contains(_source);
    final automaticDestination = transaction.automaticDestination;
    final bucketId = isIncome || _financialLayer == null
        ? null
        : fakeMayaBucketIdForMotivation(
            _financialLayerMotivations[_financialLayer]!);
    final bucket = bucketId == null
        ? null
        : state.fakeMayaLink?.summary.personalGoalById(bucketId);
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: [
                _LabelFieldRow(
                  label: 'Type',
                  value: transaction.amount >= 0 ? 'Money in' : 'Money out',
                ),
                _LabelFieldRow(
                  label: 'Account',
                  value: transaction.account ?? 'Wallet',
                ),
                _LabelFieldRow(
                  label: transaction.title.toLowerCase().contains('cash in')
                      ? 'Sender'
                      : transaction.title.toLowerCase().contains('sent')
                          ? 'Recipient'
                          : 'Details',
                  value: transaction.detail,
                ),
                _LabelFieldRow(label: 'Time', value: transaction.age),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!isIncome) ...[
            DropdownButtonFormField<String>(
              value: _financialLayers.contains(_financialLayer)
                  ? _financialLayer
                  : null,
              decoration: inputDecoration('Choose a financial layer').copyWith(
                labelText: 'Financial layer',
              ),
              items: _financialLayers
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _financialLayer = value;
                  if (value != null) _source = _eWalletSource;
                  if (!_enabledCategoryValuesForLayer(state, isIncome)
                      .contains(_category)) {
                    _category = null;
                  }
                  _pullFromBucket = null;
                });
                _maybePromptBucketFunding();
              },
            ),
            const SizedBox(height: 12),
          ],
          DropdownButtonFormField<String>(
            value: canChooseCategory && enabledCategories.contains(_category)
                ? _category
                : null,
            decoration: inputDecoration(categoryHint).copyWith(
              labelText: 'Category',
            ),
            items: categoryOptions
                .map((option) => DropdownMenuItem(
                      value: option.value ?? '__${option.label}__',
                      enabled: option.enabled,
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: option.enabled ? _title : _body,
                          fontWeight: option.enabled
                              ? FontWeight.w700
                              : FontWeight.w900,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: canChooseCategory
                ? (value) {
                    setState(() {
                      _category = value;
                      _pullFromBucket = null;
                    });
                    _maybePromptBucketFunding();
                  }
                : null,
          ),
          const SizedBox(height: 12),
          if (automaticDestination == null)
            if (isIncome)
              _TransactionDetailLine(
                label: 'Source',
                value: _source ?? transaction.account ?? 'Wallet',
              )
            else
              DropdownButtonFormField<String>(
                value: enabledSourceValues.contains(_source) ? _source : null,
                decoration: inputDecoration(canChooseSource
                        ? 'Choose a source'
                        : _financialLayer == null
                            ? 'Choose a financial layer first'
                            : 'Choose a category first')
                    .copyWith(
                  labelText: 'Source',
                ),
                items: sourceOptions
                    .map((option) => DropdownMenuItem(
                          value: option.value,
                          enabled: option.enabled,
                          child: Text(
                            option.label,
                            style: TextStyle(
                              color: option.enabled ? _title : _body,
                              fontWeight: option.enabled
                                  ? FontWeight.w700
                                  : FontWeight.w900,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: canChooseSource
                    ? (value) {
                        if (value == null) return;
                        _selectSource(value);
                      }
                    : null,
              )
          else
            _TransactionDetailLine(
              label: 'Destination',
              value: automaticDestination,
            ),
          if (bucket != null && _pullFromBucket == true) ...[
            const SizedBox(height: 10),
            _BucketFundingPreview(
              bucketName: bucket.name,
              currentBalance: bucket.balance,
              amount: transaction.amount.abs(),
            ),
          ],
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
            enabled: _category != null &&
                (isIncome || _financialLayer != null) &&
                _source != null &&
                selectedSourceIsEnabled &&
                !_saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  /// Once both the financial layer and category are chosen for an expense,
  /// ask whether this expense should be pulled from that layer's FakeMaya
  /// bucket — showing exactly how much would come out and letting the user
  /// accept or reject. No-ops for income, for layers without a bucket
  /// mapping, or if that bucket hasn't been created yet.
  Future<void> _maybePromptBucketFunding() async {
    final transaction = widget.transaction;
    if (transaction.amount >= 0) return;
    final layer = _financialLayer;
    if (layer == null || _category == null || _pullFromBucket != null) return;
    await _confirmBucketSource(layer);
  }

  Future<void> _selectSource(String source) async {
    final layer = _financialLayer;
    final state = AppScope.of(context);
    if (layer == null || _category == null) {
      setState(() {
        _source = _eWalletSource;
        _pullFromBucket = false;
      });
      return;
    }
    final fundSource = _financialLayerSources[layer];
    if (source == fundSource) {
      if (!_fundSourceIsAvailable(state, layer)) {
        setState(() {
          _source = _eWalletSource;
          _pullFromBucket = false;
        });
        return;
      }
      await _confirmBucketSource(layer);
      return;
    }
    setState(() {
      _source = source;
      if (source == _eWalletSource) _pullFromBucket = false;
    });
  }

  Future<void> _confirmBucketSource(String layer) async {
    final motivation = _financialLayerMotivations[layer]!;
    final bucketId = fakeMayaBucketIdForMotivation(motivation);
    if (bucketId == null || !mounted) {
      if (mounted) {
        setState(() {
          _pullFromBucket = false;
          _source = _eWalletSource;
        });
      }
      return;
    }
    final state = AppScope.of(context);
    final bucket = state.fakeMayaLink?.summary.personalGoalById(bucketId);
    if (bucket == null) {
      setState(() {
        _pullFromBucket = false;
        _source = _eWalletSource;
      });
      return;
    }
    final amount = widget.transaction.amount.abs();
    final sufficient = bucket.balance >= amount;
    final agreed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Get from ${bucket.name}?',
          style: GoogleFonts.fredoka(
            color: _title,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          sufficient
              ? 'This will take ${money(amount)} from your ${bucket.name} '
                  '(currently ${money(bucket.balance)}) to cover this expense.'
              : '${bucket.name} only has ${money(bucket.balance)}, which '
                  "isn't enough to cover this ${money(amount)} expense.",
          style: const TextStyle(color: _body, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No thanks'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _purple),
            onPressed:
                sufficient ? () => Navigator.pop(dialogContext, true) : null,
            child: const Text('Yes, use fund'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() {
      _pullFromBucket = agreed == true;
      _source = agreed == true ? _financialLayerSources[layer] : _eWalletSource;
    });
  }

  Future<void> _save() async {
    final category = _category;
    final financialLayer = _financialLayer;
    final isIncome = widget.transaction.amount >= 0;
    final source = widget.transaction.automaticDestination ??
        _source ??
        (isIncome ? widget.transaction.account ?? 'Wallet' : null);
    final fundSource =
        financialLayer == null ? null : _financialLayerSources[financialLayer];
    if (category == null ||
        (!isIncome && financialLayer == null) ||
        source == null ||
        (!isIncome &&
            source == fundSource &&
            !_fundSourceIsAvailable(AppScope.of(context), financialLayer!)) ||
        _saving) {
      return;
    }
    setState(() => _saving = true);
    final state = AppScope.of(context);
    if (_pullFromBucket == true) {
      if (financialLayer == null) return;
      try {
        await state.fundTransactionFromBucket(
          motivation: _financialLayerMotivations[financialLayer]!,
          amount: widget.transaction.amount.abs(),
        );
      } on FakeMayaException catch (error) {
        if (!mounted) return;
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Couldn't pull from the fund: $error")),
        );
        return;
      }
    }
    await state.labelFakeMayaTransaction(
      transactionId: widget.transaction.transactionId,
      category: category,
      source: source,
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

  static String? _initialFinancialLayer(FakeMayaTransaction transaction) {
    if (transaction.amount >= 0) return null;
    return switch (transaction.source?.trim().toLowerCase()) {
      'basic needs fund' => 'Cash Flow & Basic Needs',
      'emergency fund' => 'Financial Safety',
      'investment' => 'Accumulating Wealth',
      'personal lifestyle fund' => 'Financial Freedom',
      _ => null,
    };
  }

  static String? _initialSource(FakeMayaTransaction transaction) {
    final automaticDestination = transaction.automaticDestination;
    if (automaticDestination != null) return automaticDestination;
    if (transaction.source != null) return transaction.source;
    if (transaction.amount >= 0) return transaction.account ?? 'Wallet';
    final layer = _initialFinancialLayer(transaction);
    if (layer != null) return _eWalletSource;
    return switch (transaction.category?.trim().toLowerCase()) {
      'basic needs' => 'Basic Needs Fund',
      'emergency fund' => 'Emergency Fund',
      'investment' => 'Investment',
      'time deposit' => 'Time Deposit',
      _ => null,
    };
  }
}

/// Shows what a bucket's balance will look like immediately after this
/// expense pulls [amount] out of it.
class _BucketFundingPreview extends StatelessWidget {
  const _BucketFundingPreview({
    required this.bucketName,
    required this.currentBalance,
    required this.amount,
  });

  final String bucketName;
  final double currentBalance;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final updated = math.max(0.0, currentBalance - amount);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _purple.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _purple.withValues(alpha: .18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FUNDING FROM $bucketName'.toUpperCase(),
            style: const TextStyle(
              color: _purple,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${money(currentBalance)} → ${money(updated)} after this expense',
            style: const TextStyle(
              color: _title,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
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

/// A label/value row for the Label Transaction sheet's summary block. Unlike
/// [_TransactionDetailLine], the label sits in a fixed-width column and the
/// value fills the rest via [Expanded], so the value's right edge is always
/// flush with the row's right edge regardless of how short or long either
/// the label or the value text is.
class _LabelFieldRow extends StatelessWidget {
  const _LabelFieldRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(color: _body, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
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
