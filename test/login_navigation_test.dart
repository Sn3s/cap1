import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _AuthState extends AppState {
  bool rejectLogin = false;
  int loginCalls = 0;

  Future<void> _completeLogin() async {
    loginCalls++;
    if (rejectLogin) throw StateError('Login failed');
    onboardingComplete = true;
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _completeLogin();

  @override
  Future<void> signInWithGoogle({
    bool requireCompletedProfile = false,
    bool saveAfterSignIn = true,
    bool forceFreshGoogleSession = false,
  }) =>
      _completeLogin();

  @override
  Future<void> recordAppOpen() async {}

  @override
  Future<void> connectCommunity() async {}
}

Future<GlobalKey<NavigatorState>> _openLogin(
  WidgetTester tester,
  _AuthState state,
) async {
  tester.view.physicalSize = const Size(1000, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final navigator = GlobalKey<NavigatorState>();
  await tester.pumpWidget(AppScope(
    state: state,
    child: MaterialApp(
      navigatorKey: navigator,
      theme: ThemeData(platform: TargetPlatform.iOS),
      home: const Scaffold(body: Text('Welcome history')),
    ),
  ));
  navigator.currentState!.push(MaterialPageRoute<void>(
    builder: (_) => const Scaffold(body: Text('Account creation history')),
  ));
  await tester.pumpAndSettle();
  navigator.currentState!.push(MaterialPageRoute<void>(
    builder: (_) => const LoginScreen(),
  ));
  await tester.pumpAndSettle();
  return navigator;
}

Future<void> _emailLogin(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'user@example.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'password123');
  final login = find.widgetWithText(PrimaryButton, 'Login');
  await tester.ensureVisible(login);
  await tester.tap(login);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final google in [false, true]) {
    testWidgets('${google ? 'Google' : 'email'} login makes Home the root',
        (tester) async {
      final state = _AuthState();
      final navigator = await _openLogin(tester, state);
      expect(navigator.currentState!.canPop(), isTrue);

      if (google) {
        final button = find.byType(GoogleSignInButton);
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
      } else {
        await _emailLogin(tester);
      }

      expect(state.loginCalls, 1);
      expect(find.byType(MainShell), findsOneWidget);
      expect(find.byType(LoginScreen, skipOffstage: false), findsNothing);
      expect(find.text('Welcome history', skipOffstage: false), findsNothing);
      expect(find.text('Account creation history', skipOffstage: false),
          findsNothing);
      expect(navigator.currentState!.canPop(), isFalse);

      await tester.dragFrom(const Offset(1, 300), const Offset(700, 0));
      await tester.pumpAndSettle();
      expect(find.byType(MainShell), findsOneWidget);
      expect(await navigator.currentState!.maybePop(), isFalse);

      // Clearing authentication history must not block back navigation
      // from pages opened within the signed-in app.
      navigator.currentState!.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Signed-in detail')),
      ));
      await tester.pumpAndSettle();
      expect(navigator.currentState!.canPop(), isTrue);
      await tester.dragFrom(const Offset(1, 300), const Offset(700, 0));
      await tester.pumpAndSettle();
      expect(find.text('Signed-in detail'), findsNothing);
      expect(find.byType(MainShell), findsOneWidget);
      expect(navigator.currentState!.canPop(), isFalse);
    });
  }

  testWidgets('failed login keeps the user on Login with its back history',
      (tester) async {
    final state = _AuthState()..rejectLogin = true;
    final navigator = await _openLogin(tester, state);
    await _emailLogin(tester);
    expect(state.loginCalls, 1);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
    expect(navigator.currentState!.canPop(), isTrue);
  });
}
