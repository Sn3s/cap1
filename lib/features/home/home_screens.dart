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

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(eyebrow: 'GOOD MORNING', title: 'Hi, Felix! 👋'),
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
                                      text: '₱ 24,840',
                                      style: GoogleFonts.nunito(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        color: _title,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '.55',
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
                      value: '₱ 1,240',
                      delta: '↑ ₱80 this week',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStatCard(
                      icon: Icons.savings_rounded,
                      iconColor: _purple,
                      label: 'Saved',
                      value: '₱ 320',
                      delta: '64% of goal',
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

  static const _categories = [
    ('Food & drink', Icons.restaurant_rounded, _brand, 182.0),
    ('Transport', Icons.directions_bus_rounded, _purple, 96.0),
    ('Shopping', Icons.shopping_bag_rounded, Color(0xFFEE7E9C), 88.0),
    ('Bills', Icons.bolt_rounded, _amber, 74.0),
    ('Fun', Icons.sports_esports_rounded, Color(0xFF6AA8F0), 38.0),
  ];

  @override
  Widget build(BuildContext context) {
    final total = _categories.fold(0.0, (s, c) => s + c.$4);
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
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '₱478',
                            style: GoogleFonts.nunito(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: _title,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: '.20',
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: _body,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Multicolor breakdown bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Row(
                        children: _categories.map((c) {
                          return Expanded(
                            flex: (c.$4 / total * 100).round(),
                            child: Container(height: 10, color: c.$3),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'By category',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _title,
                ),
              ),
              const SizedBox(height: 14),
              ..._categories.map(
                (c) => _CategoryRow(
                  icon: c.$2,
                  color: c.$3,
                  label: c.$1,
                  amount: c.$4,
                  max: _categories.first.$4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  static const _allGoals = [
    ('Trip to Lisbon', '✈️', 640.0, 2000.0, 32, _purple),
    ('New laptop', '💻', 900.0, 1500.0, 60, _brand),
    ('Emergency fund', '🚨', 1200.0, 3000.0, 40, _red),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(eyebrow: "WHAT YOU'RE SAVING FOR", title: 'Goals'),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Featured goal card
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 100, 20),
                decoration: BoxDecoration(
                  color: _purple,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ALMOST THERE!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('☕ ', style: TextStyle(fontSize: 20)),
                            Text(
                              'Coffee fund',
                              style: GoogleFonts.fredoka(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '₱205',
                                style: GoogleFonts.nunito(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextSpan(
                                text: ' / ₱250',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: .82,
                            minHeight: 8,
                            color: Colors.white,
                            backgroundColor: Colors.white.withOpacity(.25),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '₱45 to go · 🐢 you got this',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // Shellby mascot on the right
                    Positioned(
                      right: -80,
                      bottom: -12,
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: Image.asset(
                          'assets/images/shellby_wave.webp',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'All goals',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _title,
                ),
              ),
              const SizedBox(height: 12),
              ..._allGoals.map(
                (g) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              g.$2,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                g.$1,
                                style: const TextStyle(
                                  color: _title,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              '${g.$5}%',
                              style: TextStyle(
                                color: g.$6,
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
                            value: g.$5 / 100,
                            minHeight: 8,
                            color: g.$6,
                            backgroundColor: g.$6.withOpacity(.12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '₱${g.$3.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: _title,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'of ₱${g.$4.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: _body,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
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
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _settings = [
    ('Notifications', Icons.notifications_outlined, 'On'),
    ('Privacy & security', Icons.shield_outlined, ''),
    ('Linked accounts', Icons.credit_card_outlined, '3'),
    ('Appearance', Icons.palette_outlined, 'Light'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
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
                  children: _settings.asMap().entries.map((e) {
                    final s = e.value;
                    final isLast = e.key == _settings.length - 1;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _bellySoft,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(s.$2, color: _purple, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  s.$1,
                                  style: const TextStyle(
                                    color: _title,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (s.$3.isNotEmpty)
                                Text(
                                  s.$3,
                                  style: const TextStyle(
                                    color: _body,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: _body,
                                size: 20,
                              ),
                            ],
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

// ─── Activity page ────────────────────────────────────────────────────────────

class _TxData {
  const _TxData(this.name, this.category, this.amount, this.icon, this.color);
  final String name;
  final String category;
  final double amount;
  final IconData icon;
  final Color color;
}

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String _filter = 'All';

  static const _filters = ['All', 'Income', 'Food', 'Bills', 'Fun'];

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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(eyebrow: 'EVERY MOVE', title: 'Activity'),
        const SizedBox(height: 16),
        // Filter chips
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
                onTap: () => setState(() => _filter = _filters[i]),
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: _groups.map((group) {
              final rows = group.$2;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.$1,
                    style: const TextStyle(
                      color: _body,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: rows.asMap().entries.map((e) {
                        final tx = e.value;
                        final isLast = e.key == rows.length - 1;
                        return Column(
                          children: [
                            _ActivityRow(data: tx),
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
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.data});
  final _TxData data;

  @override
  Widget build(BuildContext context) {
    final positive = data.amount > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
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
                Text(
                  data.category,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${positive ? '+' : ''}₱${data.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: positive ? _green : _red,
              fontWeight: FontWeight.w800,
              fontSize: 15,
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
