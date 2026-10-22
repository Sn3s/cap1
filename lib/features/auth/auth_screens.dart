part of '../../main.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<bool>? _restoreFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isWebQa) return;
    _restoreFuture ??= AppScope.of(context).restoreSignedInUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_isWebQa) return const _WebQaProfileScreen();
    return FutureBuilder<bool>(
      future: _restoreFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: _bg,
            body: Center(child: CircularProgressIndicator(color: _brand)),
          );
        }
        if (snapshot.data == true) return const MainShell();
        return const WelcomeScreen();
      },
    );
  }
}

/// Development-only entrypoint for browser QA. It calls the application's
/// existing AppState seed methods, so all balances and scores are calculated
/// by the normal production business logic.
class _WebQaProfileScreen extends StatelessWidget {
  const _WebQaProfileScreen();

  Future<void> _openDemo(
    BuildContext context,
    void Function(AppState state) seed,
  ) async {
    final state = AppScope.of(context);
    seed(state);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
    );
  }

  Future<void> _startFresh(BuildContext context) async {
    final state = AppScope.of(context);
    await state.beginFreshOnboardingDraft();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const PreparationContextScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profiles =
        <({String label, String description, void Function(AppState) seed})>[
      (
        label: 'Cash Flow',
        description: 'Available cash and essential-expense actions.',
        seed: (state) => state.seedCashFlowMockDataForTesting(),
      ),
      (
        label: 'Emergency Fund',
        description: 'Emergency Fund allocations and recovery actions.',
        seed: (state) => state.seedEmergencyFundMockDataForTesting(),
      ),
      (
        label: 'Investments',
        description: 'Accumulating Wealth investment actions and scores.',
        seed: (state) => state.seedAccumulatingWealthMockDataForTesting(),
      ),
      (
        label: 'Lifestyle',
        description: 'Financial Freedom lifestyle and hobby actions.',
        seed: (state) => state.seedFinancialFreedomMockDataForTesting(),
      ),
      (
        label: 'Combined Goals',
        description: 'The complete multi-goal demonstration profile.',
        seed: (state) => state.seedMainMockDataForTesting(),
      ),
    ];

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 24),
                Semantics(
                  header: true,
                  child: Text(
                    'Shellby Web QA',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choose isolated demo data. No account, Firebase profile, or live FakeMaya connection is used in this mode.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _body, height: 1.4),
                ),
                const SizedBox(height: 28),
                for (final profile in profiles) ...[
                  Semantics(
                    button: true,
                    label: 'Open ${profile.label} demo profile',
                    child: FilledButton(
                      onPressed: () => _openDemo(context, profile.seed),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Text(profile.label),
                            const SizedBox(height: 3),
                            Text(
                              profile.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: () => _startFresh(context),
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('Fresh Onboarding'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SizedBox(
                width: 220,
                height: 285,
                child: Transform.translate(
                  offset: const Offset(-5, 0),
                  child: Image.asset(
                    'assets/images/shellby_wave.webp',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Shelby',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: 48,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your Finance friend',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _body,
                  fontSize: 20,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Create an account',
                icon: Icons.person_add_alt_1_rounded,
                onPressed: () async {
                  final state = AppScope.of(context);
                  await state.beginFreshOnboardingDraft();
                  if (!context.mounted) return;
                  _push(context, const PreparationContextScreen());
                },
              ),
              const SizedBox(height: 14),
              SecondaryButton(
                label: 'Login',
                icon: Icons.login_rounded,
                onPressed: () => _push(context, const LoginScreen()),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  static const _presetAccounts = [
    (email: 'main@gmail.com', password: 'mainaccount'),
    (email: 'cashflow@gmail.com', password: 'cashflow'),
    (email: 'emergency@gmail.com', password: 'emergency'),
    (email: 'accumulating@gmail.com', password: 'accumulating'),
    (email: 'freedom@gmail.com', password: 'freedom'),
  ];

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? selectedPresetEmail;
  bool busy = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _runAuth(
    Future<void> Function(AppState state) action, {
    bool validateForm = true,
  }) async {
    if (busy ||
        (validateForm && !(formKey.currentState?.validate() ?? false))) {
      return;
    }
    setState(() => busy = true);
    try {
      final state = AppScope.of(context);
      await action(state);
      if (!mounted) return;
      _pushReplacement(context, const MainShell());
    } catch (error) {
      if (!mounted) return;
      _showAuthError(context, error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  color: _brand,
                  icon: const Icon(Icons.chevron_left_rounded, size: 34),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset(
                    'assets/images/shellby_wave.webp',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Welcome back',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Log in and keep your money check-in rolling.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _body,
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _title.withOpacity(.08),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: inputDecoration('Email address').copyWith(
                          prefixIcon: const Icon(
                            Icons.mail_rounded,
                            color: _body,
                          ),
                        ),
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        decoration: inputDecoration('Password').copyWith(
                          prefixIcon: const Icon(
                            Icons.lock_rounded,
                            color: _body,
                          ),
                        ),
                        validator: validatePassword,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: _purple,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: 'Login',
                        icon: Icons.arrow_forward_rounded,
                        enabled: !busy,
                        onPressed: () => _runAuth(
                          (state) => state.signInWithEmail(
                            email: emailController.text,
                            password: passwordController.text,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _LoginDivider(),
                      const SizedBox(height: 16),
                      GoogleSignInButton(
                        busy: busy,
                        onPressed: () => _runAuth(
                          (state) => state.signInWithGoogle(
                            requireCompletedProfile: true,
                          ),
                          validateForm: false,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SecondaryButton(
                        label: 'Seed Reflection Demo User',
                        icon: Icons.auto_awesome_rounded,
                        onPressed: () => _runAuth(
                          (state) => state.seedReflectionDemoUser(),
                          validateForm: false,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedPresetEmail,
                        isExpanded: true,
                        decoration:
                            inputDecoration('Login saved account').copyWith(
                          prefixIcon: const Icon(
                            Icons.account_circle_rounded,
                            color: _body,
                          ),
                        ),
                        items: _presetAccounts
                            .map(
                              (account) => DropdownMenuItem(
                                value: account.email,
                                child: Text(account.email),
                              ),
                            )
                            .toList(),
                        onChanged: busy
                            ? null
                            : (email) {
                                if (email == null) return;
                                final account = _presetAccounts.firstWhere(
                                  (account) => account.email == email,
                                );
                                setState(() {
                                  selectedPresetEmail = account.email;
                                  emailController.text = account.email;
                                  passwordController.text = account.password;
                                });
                                _runAuth(
                                  (state) => state.signInWithEmail(
                                    email: account.email,
                                    password: account.password,
                                  ),
                                );
                              },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'New to Shelby?',
                    style: TextStyle(
                      color: _body,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final state = AppScope.of(context);
                      await state.beginFreshOnboardingDraft();
                      if (!context.mounted) return;
                      _push(context, const PreparationContextScreen());
                    },
                    child: const Text(
                      'Create an account',
                      style: TextStyle(
                        color: _purple,
                        fontWeight: FontWeight.w900,
                      ),
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

class _LoginDivider extends StatelessWidget {
  const _LoginDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: _border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
              color: _body,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(child: Divider(color: _border, thickness: 1)),
      ],
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.busy = false,
  });

  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: busy ? null : onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (busy)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _purple,
                ),
              )
            else
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _bellySoft,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  'G',
                  style: GoogleFonts.nunito(
                    color: _purple,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Text(
              busy ? 'Signing in...' : 'Sign in with Google',
              style: TextStyle(
                color: _title,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showAuthError(BuildContext context, Object error) {
  final message = switch (error) {
    FirebaseAuthException(:final message?) => message,
    GoogleSignInException(:final description?) => description,
    FirebaseException(:final message?) => message,
    _ => error.toString().isEmpty
        ? 'Sign-in failed. Please try again.'
        : error.toString(),
  };
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// Preparation stage map:
// Pre-onboarding: PreparationContextScreen, LifeContextScreen,
// LifeRhythmScreen.
// Orient: PreparationOrientScreen.
// Invite: FinancialConcernScreen.
// Surface: MotivationSurfaceScreen.
// Specify: PsychBaselineScreen through PreparationCommitmentScreen.
