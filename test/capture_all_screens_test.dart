import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:cap1/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final output = Directory('/tmp/cap1-captures/all');
  final screens = <({String name, Widget widget})>[
    (name: '01_welcome', widget: const WelcomeScreen()),
    (name: '02_login', widget: const _LoginPreviewScreen()),
    (name: '03_preparation_context', widget: const PreparationContextScreen()),
    (
      name: '04_preparation_credentials',
      widget: const PreparationCredentialsScreen(),
    ),
    (name: '05_life_context', widget: const LifeContextScreen()),
    (name: '06_life_rhythm', widget: const LifeRhythmScreen()),
    (name: '07_monthly_income', widget: const MonthlyIncomeScreen()),
    (name: '08_monthly_expenses', widget: const InitialBaselineScreen()),
    (name: '09_preparation_orient', widget: const PreparationOrientScreen()),
    (name: '10_financial_concern', widget: const FinancialConcernScreen()),
    (name: '11_motivation_surface', widget: const MotivationSurfaceScreen()),
    (name: '12_goal_questionnaire', widget: const GoalQuestionnaireScreen()),
    (name: '13_recommended_plan', widget: const RecommendedPlanScreen()),
    (name: '14_fake_maya', widget: const FakeMayaOnboardingScreen()),
    (name: '15_app_permission', widget: const AppPermissionScreen()),
    (
      name: '16_personal_data_consent',
      widget: const PersonalDataConsentScreen(),
    ),
    (
      name: '17_data_retention_consent',
      widget: const DataRetentionConsentScreen(),
    ),
    (name: '18_financial_baseline', widget: const FinancialBaselineScreen()),
    (name: '19_tracking_variables', widget: const TrackingVariablesScreen()),
    (name: '20_goal_feasibility', widget: const GoalFeasibilityScreen()),
    (name: '21_pyramid_preview', widget: const PyramidPreviewScreen()),
    (name: '22_consent_privacy', widget: const ConsentPrivacyScreen()),
    (name: '23_social_structure', widget: const SocialStructureScreen()),
    (
      name: '24_preparation_commitment',
      widget: const PreparationCommitmentScreen(),
    ),
    (
      name: '25_first_collection_handoff',
      widget: const FirstCollectionHandoffScreen(),
    ),
    (name: '26_home_dashboard', widget: const DashboardPage()),
    (name: '27_home_insights', widget: const InsightsPage()),
    (name: '28_home_goals', widget: const GoalsPage()),
    (name: '29_home_activity', widget: const ActivityPage()),
    (name: '30_home_you', widget: const ProfilePage()),
    (name: '31_user_selections', widget: const UserSelectionsScreen()),
    (name: '32_legacy_discovery', widget: const DiscoveryScreen()),
    (name: '33_legacy_quantitative', widget: const QuantitativeScreen()),
    (name: '34_legacy_feasibility', widget: const FeasibilityScreen()),
  ];
  final requestedScreen = Platform.environment['CAPTURE_SCREEN'];
  final selectedScreens = requestedScreen == null
      ? screens
      : screens.where((screen) => screen.name == requestedScreen).toList();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    PathProviderPlatform.instance =
        _CapturePathProvider('/tmp/cap1-google-fonts');
    if ((requestedScreen == null || requestedScreen == screens.first.name) &&
        output.existsSync()) {
      output.deleteSync(recursive: true);
    }
    output.createSync(recursive: true);
  });

  for (final screen in selectedScreens) {
    testWidgets('capture ${screen.name}', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final message = details.exceptionAsString();
        if (message.contains('A RenderFlex overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      final view = tester.view;
      view.physicalSize = const Size(1179, 2556);
      view.devicePixelRatio = 3;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      stdout.writeln('rendering ${screen.name}');
      await tester.pumpWidget(
        RepaintBoundary(
          key: ValueKey(screen.name),
          child: AppScope(
            state: _seededState(),
            child: MaterialApp(
              theme: _captureTheme(),
              home: screen.widget,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      stdout.writeln('capturing ${screen.name}');
      await _capture(tester, screen.name, output);
      stdout.writeln('captured ${screen.name}');
      if (requestedScreen != null) exit(0);
    });
  }
}

class _LoginPreviewScreen extends StatelessWidget {
  const _LoginPreviewScreen();

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFBF8F3);
    const brand = Color(0xFF57BE8C);
    const purple = Color(0xFF7C5CCB);
    const surface = Color(0xFFFFFFFF);
    const title = Color(0xFF2E1B47);
    const body = Color(0xFF786C8B);
    const border = Color(0xFFE8DEF7);
    const bellySoft = Color(0xFFF4EFFD);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 34,
                  color: brand,
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
                  color: body,
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: title.withOpacity(.08),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PreviewField(
                      label: 'Email address',
                      icon: Icons.mail_rounded,
                    ),
                    const SizedBox(height: 14),
                    _PreviewField(label: 'Password', icon: Icons.lock_rounded),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: purple,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    _PreviewButton(
                      label: 'Login',
                      icon: Icons.arrow_forward_rounded,
                      background: brand,
                      foreground: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: border, thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: body,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: border, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: border, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: bellySoft,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Text(
                              'G',
                              style: TextStyle(
                                color: purple,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Sign in with Google',
                            style: TextStyle(
                              color: title,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to Shelby?',
                    style: TextStyle(color: body, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Create an account',
                    style: TextStyle(
                      color: purple,
                      fontWeight: FontWeight.w900,
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

class _PreviewField extends StatelessWidget {
  const _PreviewField({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DEF7), width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF786C8B)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF786C8B),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  const _PreviewButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: foreground),
        ],
      ),
    );
  }
}

class _CapturePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _CapturePathProvider(this.path);

  final String path;

  @override
  Future<String?> getApplicationSupportPath() async => path;
}

ThemeData _captureTheme() {
  const brand = Color(0xFF57BE8C);
  const purple = Color(0xFF7C5CCB);
  const belly = Color(0xFFE3CBF8);
  const bellySoft = Color(0xFFF4EFFD);
  const bg = Color(0xFFFBF8F3);
  const surface = Color(0xFFFFFFFF);
  const title = Color(0xFF2E1B47);
  const body = Color(0xFF786C8B);
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: brand,
      primary: brand,
      secondary: purple,
      surface: surface,
      onSurface: title,
    ),
    fontFamily: GoogleFonts.nunito().fontFamily,
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.fredoka(
        fontSize: 34,
        height: 1.05,
        fontWeight: FontWeight.w700,
        color: title,
      ),
      headlineMedium: GoogleFonts.fredoka(
        fontSize: 26,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: title,
      ),
      titleLarge: GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: title,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: body,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: body,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: brand,
      inactiveTrackColor: bellySoft,
      thumbColor: brand,
      overlayColor: brand.withOpacity(.12),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: bellySoft,
      labelStyle: GoogleFonts.nunito(
        fontWeight: FontWeight.w700,
        color: purple,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(color: belly),
      ),
    ),
  );
}

AppState _seededState() {
  final state = AppState()
    ..uid = 'preview-user'
    ..name = 'Mika Santos'
    ..email = 'mika@example.com'
    ..age = 'Early Career'
    ..occupation = 'Software Engineer'
    ..industry = 'Technology'
    ..employmentStatus = 'Full-time'
    ..incomeType = 'Fixed'
    ..incomeRhythm = 'Monthly'
    ..billsRhythm = 'Predictable dates'
    ..responsibility = 'Mostly myself'
    ..checkInRhythm = 'Weekly'
    ..primaryConcern = 'Cash Flow & Basic Needs'
    ..motivation = 'I want money to feel calmer and easier to plan.'
    ..reflectedMotivation = 'You want money to feel calmer and easier to plan.'
    ..chatSurfaceSummary =
        'Checking your spending gets harder when life gets busy'
    ..chatGoalFocusSummary =
        'Remembering to track your spending and keep momentum'
    ..chatTimeframeSummary = '3 months'
    ..chatDifficultySummary = 'A balanced pace'
    ..chatSituationsSummary = 'Payday and Bill Days'
    ..chatChallengesSummary = 'Impulse Buying and Budget Leaks'
    ..selectedGoal = 'Expense Tracking Routine'
    ..selectedGoalDescription =
        'Set up a simple expense tracking routine with reminders matched to your check-in rhythm.'
    ..selectedGoalMonthlyTarget = 0
    ..socialStructure = 'Private only'
    ..personalDataConsent = true
    ..dataRetentionConsent = true
    ..notificationsAllowed = true
    ..thirdPartyDataLinkingAllowed = true
    ..automaticDataGatheringAllowed = true;
  state.configureGoalActions(actionIds: ['ACT3']);
  return state;
}

Future<void> _capture(
  WidgetTester tester,
  String name,
  Directory output,
) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(ValueKey(name)),
  );
  final image = await boundary.toImage(pixelRatio: 3);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  final bytes = byteData!.buffer.asUint8List();
  File('${output.path}/$name.png').writeAsBytesSync(bytes);
}
