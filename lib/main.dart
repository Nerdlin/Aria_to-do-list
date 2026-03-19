import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/add_task_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AriaApp());
}

class AriaApp extends StatelessWidget {
  const AriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aria',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF7C3AED),
        scaffoldBackgroundColor: const Color(0xFFF8F7FF),
      ),
      home: const SplashScreen(),
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/auth': (_) => const AuthScreen(),
        '/register': (_) => const RegistrationScreen(),
        '/shell': (_) => const AppShell(),
        '/add-task': (_) => const AddTaskScreen(),
      },
    );
  }
}
