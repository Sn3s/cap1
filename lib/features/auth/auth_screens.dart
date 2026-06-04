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
    _restoreFuture ??= AppScope.of(context).restoreSignedInUser();
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: () =>
                    _push(context, const PreparationContextScreen()),
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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _runAuth(Future<void> Function(AppState state) action) async {
    if (busy) return;
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
                      ),
                    ),
                  ],
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
                    onPressed: () =>
                        _push(context, const PreparationContextScreen()),
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
