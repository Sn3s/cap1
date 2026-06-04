import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';

part 'core/app_scope.dart';
part 'core/app_state.dart';
part 'features/auth/auth_screens.dart';
part 'features/home/home_screens.dart';
part 'features/preparation/legacy_onboarding_screens.dart';
part 'features/preparation/preparation_screens.dart';
part 'services/firebase_profile_service.dart';
part 'services/shellby_ai_coach.dart';
part 'shared/widgets/shared_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ShellbyApp());
}

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
const _aiProvider = String.fromEnvironment(
  'AI_PROVIDER',
  defaultValue: 'ollama',
);
const _ollamaUrl = String.fromEnvironment(
  'OLLAMA_URL',
  defaultValue: 'http://10.0.2.2:11434',
);
const _ollamaModel = String.fromEnvironment(
  'OLLAMA_MODEL',
  defaultValue: 'qwen3.6:latest',
);
const _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
const _geminiModel = String.fromEnvironment(
  'GEMINI_MODEL',
  defaultValue: 'gemini-2.5-flash',
);
const _onboardingPhaseTotal = 15;

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
            overlayColor: _brand.withOpacity(.12),
          ),
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected) ? _brand : null,
            ),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? _brand.withOpacity(.4)
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
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: _surface,
            indicatorColor: _brand.withOpacity(.12),
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
        home: const AuthGate(),
      ),
    );
  }
}
