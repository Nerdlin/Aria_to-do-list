import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'screens/add_task_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/subscription_screen.dart';
import 'services/app_controller.dart';
import 'widgets/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keep local AI config optional so fresh checkouts still boot with
  // deterministic fallback recommendations. AiService also reads
  // --dart-define values directly.
  await dotenv.load(fileName: ".env", isOptional: true);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppController.instance.init();
  runApp(const AriaApp());
}

class AriaApp extends StatelessWidget {
  const AriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppController.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Aria',
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: AppController.instance.themeMode,
          locale: Locale(AppController.instance.languageCode),
          supportedLocales: const [
            Locale('en'),
            Locale('ru'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: const SplashScreen(),
          routes: {
            '/onboarding': (_) => const OnboardingScreen(),
            '/auth': (_) => const AuthScreen(),
            '/register': (_) => const RegistrationScreen(),
            '/shell': (_) => const AppShell(),
            '/home': (_) => const AppShell(initialIndex: 0),
            '/tasks': (_) => const AppShell(initialIndex: 1),
            '/ai': (_) => const AppShell(initialIndex: 2),
            '/analytics': (_) => const AppShell(initialIndex: 3),
            '/settings': (_) => const AppShell(initialIndex: 4),
            '/add-task': (_) => const AddTaskScreen(),
            '/subscription': (_) => const SubscriptionScreen(),
          },
        );
      },
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final baseScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF7C3AED),
    brightness: brightness,
  );

  final colorScheme = baseScheme.copyWith(
    primary: const Color(0xFF7C3AED),
    secondary: const Color(0xFF6366F1),
    surface: isDark ? const Color(0xFF111827) : Colors.white,
    onSurface: isDark ? Colors.white : const Color(0xFF0F172A),
    onPrimary: Colors.white,
    outline: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor:
        isDark ? const Color(0xFF0B1120) : const Color(0xFFF8F7FF),
    cardColor: isDark ? const Color(0xFF111827) : Colors.white,
    dividerColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor:
          isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF172033) : Colors.white,
      hintStyle: TextStyle(
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF),
      ),
      labelStyle: TextStyle(
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
    ),
  );
}
