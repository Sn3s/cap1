import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'firebase_options.dart';
import 'platform/io_adapter.dart'
    if (dart.library.html) 'platform/io_adapter_web.dart';
import 'platform/isolate_adapter.dart'
    if (dart.library.html) 'platform/isolate_adapter_web.dart';
import 'platform/llama_adapter.dart'
    if (dart.library.html) 'platform/llama_adapter_web.dart';

part 'core/app_clock.dart';
part 'core/app_scope.dart';
part 'core/app_state.dart';
part 'core/community_state.dart';
part 'features/auth/auth_screens.dart';
part 'features/community/achievements.dart';
part 'features/community/community_screens.dart';
part 'features/home/add_goal_screen.dart';
part 'features/home/health_score.dart';
part 'features/home/home_screens.dart';
part 'features/home/recent_activity_page.dart';
part 'features/home/time_travel_screen.dart';
part 'features/home/wallet_screen.dart';
part 'features/preparation/legacy_onboarding_screens.dart';
part 'features/preparation/preparation_screens.dart';
part 'services/community_service.dart';
part 'services/cooperative_service.dart';
part 'services/fakemaya_service.dart';
part 'services/firebase_profile_service.dart';
part 'services/integration_service.dart';
part 'services/notification_service.dart';
part 'services/shellby_ai_coach.dart';
part 'shared/data_entry_presets.dart';
part 'shared/merchant_category_rules.dart';
part 'shared/recurring_transaction_suggestions.dart';
part 'shared/widgets/shared_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _runtimeConfig = await _RuntimeConfig.load();
  await AppClock.load();
  if (!_isWebQa) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await ShellbyNotificationService.instance.initialize();
  }
  runApp(const ShellbyApp());
}

/// A browser build must also be debug and explicitly opt in before it can
/// bypass Firebase authentication and persistence.
const _webQaFlag = bool.fromEnvironment('SHELLBY_WEB_QA', defaultValue: false);
bool get _isWebQa => kIsWeb && kDebugMode && _webQaFlag;

// Shelby design system — primary = mint green, secondary = shell purple
const _brand = Color(0xFF57BE8C); // Shellby's body, primary actions
const _purple = Color(0xFF7C5CCB); // shell rim, secondary actions
const _sage = Color(0xFF3FA875); // green-500, money-up / positive hover
const _belly = Color(0xFFE3CBF8); // shell lavender
const _bellySoft = Color(0xFFF4EFFD); // purple-50, icon bg / tinted fills
const _bg = Color(0xFFFBF8F3); // warm cream canvas
const _surface = Color(0xFFFFFFFF); // card surface
const _title = Color(0xFF2E1B47); // plum ink, headings & body
const _body = Color(0xFF786C8B); // ink-500, secondary text
const _border = Color(0xFFECE8F1); // ink-100, hairlines
const _green = _sage; // money-up alias
const _red = Color(0xFFE0483D); // coral danger
const _amber = Color(0xFFE89A12); // warning
const _pressGreen = Color(0xFF2F8A5E); // button ledge (green-600)
const _localModelAsset = String.fromEnvironment(
  'LOCAL_MODEL_ASSET',
  defaultValue: 'assets/models/qwen3-1.7b-instruct-q4_k_m.gguf',
);
const _localModelContextSize = int.fromEnvironment(
  'LOCAL_MODEL_CONTEXT_SIZE',
  defaultValue: 2048,
);
const _defaultGeminiProxyUrl =
    'https://us-central1-shelby-1b1d8.cloudfunctions.net/geminiGenerateContent';
const _dartDefineGeminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
const _dartDefineGeminiProxyUrl = String.fromEnvironment('GEMINI_PROXY_URL');
const _hasDartDefineGeminiProxyUrl = bool.hasEnvironment('GEMINI_PROXY_URL');
const _dartDefineGeminiModel = String.fromEnvironment(
  'GEMINI_MODEL',
  defaultValue: 'gemini-3.1-flash-lite',
);
const _geminiRequestTimeoutSeconds = int.fromEnvironment(
  'GEMINI_REQUEST_TIMEOUT_SECONDS',
  defaultValue: 30,
);
const _geminiMaxRetries = int.fromEnvironment(
  'GEMINI_MAX_RETRIES',
  defaultValue: 2,
);
const _onboardingPhaseTotal = 15;

late final _RuntimeConfig _runtimeConfig;

String get _geminiApiKey => _runtimeConfig.geminiApiKey;
String get _geminiProxyUrl => _runtimeConfig.geminiProxyUrl;
String get _geminiModel => _runtimeConfig.geminiModel;

class _RuntimeConfig {
  const _RuntimeConfig({
    required this.geminiApiKey,
    required this.geminiProxyUrl,
    required this.geminiModel,
  });

  final String geminiApiKey;
  final String geminiProxyUrl;
  final String geminiModel;

  static Future<_RuntimeConfig> load() async {
    // Browser bundles are public. Never load the local dotenv asset there,
    // even outside QA mode; Web can use only an explicitly configured proxy.
    if (kIsWeb) {
      return _RuntimeConfig(
        geminiApiKey: '',
        geminiProxyUrl:
            _hasDartDefineGeminiProxyUrl ? _dartDefineGeminiProxyUrl : '',
        geminiModel: _dartDefineGeminiModel,
      );
    }
    final env = await _loadDotEnvAsset();
    final envApiKey = env['GEMINI_API_KEY'] ?? '';
    final apiKey = _dartDefineGeminiApiKey.isNotEmpty
        ? _dartDefineGeminiApiKey
        : envApiKey;
    final proxyUrl = _resolveGeminiProxyUrl(env, apiKey);
    final envModel = env['GEMINI_MODEL'] ?? '';
    final model = _dartDefineGeminiModel.isNotEmpty
        ? _dartDefineGeminiModel
        : envModel.isNotEmpty
            ? envModel
            : 'gemini-3.1-flash-lite';
    return _RuntimeConfig(
      geminiApiKey: apiKey,
      geminiProxyUrl: proxyUrl,
      geminiModel: model,
    );
  }

  static String _resolveGeminiProxyUrl(
    Map<String, String> env,
    String apiKey,
  ) {
    if (_hasDartDefineGeminiProxyUrl) return _dartDefineGeminiProxyUrl;
    final envProxyUrl = env['GEMINI_PROXY_URL'];
    if (envProxyUrl != null) return envProxyUrl;
    return apiKey.isNotEmpty ? '' : _defaultGeminiProxyUrl;
  }
}

Future<Map<String, String>> _loadDotEnvAsset() async {
  try {
    final raw = await rootBundle.loadString('.env');
    return _parseDotEnv(raw);
  } on FlutterError {
    return const {};
  }
}

Map<String, String> _parseDotEnv(String raw) {
  final values = <String, String>{};
  for (final rawLine in const LineSplitter().convert(raw)) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final equalsIndex = line.indexOf('=');
    if (equalsIndex <= 0) continue;
    final key = line.substring(0, equalsIndex).trim();
    var value = line.substring(equalsIndex + 1).trim();
    if (value.length >= 2) {
      final quote = value[0];
      if ((quote == '"' || quote == "'") && value.endsWith(quote)) {
        value = value.substring(1, value.length - 1);
      }
    }
    values[key] = value;
  }
  return values;
}

class ShellbyApp extends StatefulWidget {
  const ShellbyApp({super.key});

  @override
  State<ShellbyApp> createState() => _ShellbyAppState();
}

class _ShellbyAppState extends State<ShellbyApp> {
  final state = AppState();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Shellby',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: _bg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _brand,
            primary: _brand,
            secondary: _purple,
            surface: _surface,
            onSurface: _title,
          ),
          fontFamily: GoogleFonts.nunito().fontFamily,
          textTheme: TextTheme(
            headlineLarge: GoogleFonts.fredoka(
              fontSize: 34,
              height: 1.05,
              fontWeight: FontWeight.w700,
              color: _title,
              letterSpacing: -0.34,
            ),
            headlineMedium: GoogleFonts.fredoka(
              fontSize: 26,
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: _title,
            ),
            titleLarge: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _title,
            ),
            bodyMedium: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _body,
            ),
            bodyLarge: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _body,
            ),
          ),
          sliderTheme: SliderThemeData(
            activeTrackColor: _brand,
            inactiveTrackColor: _bellySoft,
            thumbColor: _brand,
            overlayColor: _brand.withValues(alpha: .12),
          ),
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected) ? _brand : null,
            ),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? _brand.withValues(alpha: .4)
                  : null,
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: _bellySoft,
            labelStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              color: _purple,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: const BorderSide(color: _belly),
            ),
          ),
          // ── Pop-ups: one Community-style look for every dialog, sheet,
          // snackbar, menu and picker (styling only; no behaviour change).
          dialogTheme: DialogThemeData(
            backgroundColor: _surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            shadowColor: _purple.withValues(alpha: .25),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: const BorderSide(color: _border),
            ),
            titleTextStyle: GoogleFonts.fredoka(
              fontSize: 21,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: _title,
            ),
            contentTextStyle: GoogleFonts.nunito(
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: _body,
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            barrierColor: _title.withValues(alpha: .40),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              textStyle: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              textStyle: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: _bg,
            surfaceTintColor: Colors.transparent,
            modalBackgroundColor: _bg,
            dragHandleColor: _border,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            clipBehavior: Clip.antiAlias,
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            backgroundColor: _title,
            elevation: 0,
            insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            contentTextStyle: GoogleFonts.nunito(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            actionTextColor: const Color(0xFFAEECD5),
          ),
          popupMenuTheme: PopupMenuThemeData(
            color: _surface,
            surfaceTintColor: Colors.transparent,
            elevation: 6,
            shadowColor: _purple.withValues(alpha: .20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: _border),
            ),
            textStyle: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _title,
            ),
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: _surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            dialBackgroundColor: _bellySoft,
            hourMinuteColor: _bellySoft,
            hourMinuteTextColor: _purple,
            dayPeriodColor: _bellySoft,
            dialHandColor: _purple,
            entryModeIconColor: _purple,
            helpTextStyle: GoogleFonts.nunito(
              fontSize: 12,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w900,
              color: _body,
            ),
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: _surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            headerBackgroundColor: _purple,
            headerForegroundColor: Colors.white,
            headerHeadlineStyle: GoogleFonts.fredoka(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
            todayForegroundColor: const WidgetStatePropertyAll(_purple),
            todayBorder: const BorderSide(color: _purple),
            dayStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: _surface,
            indicatorColor: _brand.withValues(alpha: .12),
            labelTextStyle: WidgetStateProperty.all(
              GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _body,
              ),
            ),
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                color: states.contains(WidgetState.selected) ? _brand : _body,
              ),
            ),
          ),
        ),
        builder: (context, child) => ValueListenableBuilder<Duration>(
          valueListenable: AppClock.offset,
          builder: (context, offset, _) => offset == Duration.zero
              ? child!
              : Banner(
                  message: 'TIME TRAVEL',
                  location: BannerLocation.topStart,
                  color: _purple,
                  child: child!,
                ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
