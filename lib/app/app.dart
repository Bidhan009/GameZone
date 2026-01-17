import 'package:flutter/material.dart';
import 'package:gamezone_flutter/app/theme/app_theme.dart';
import '../features/splash/presentation/view/splash_screen.dart';
import '../features/onboarding/presentation/view/onboarding_screen.dart';
import '../features/auth/presentation/view/login_screen.dart';
import '../features/auth/presentation/view/register_screen.dart';
import '../features/home/presentation/view/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        "/register": (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
