import 'package:gamezone_flutter/features/auth/presentation/view/login_screen.dart';
import 'package:gamezone_flutter/features/auth/presentation/view/register_screen.dart';
import 'package:gamezone_flutter/features/Dashboard/presentation/view/home_screen.dart';
import 'package:gamezone_flutter/features/splash/presentation/view/splash_screen.dart';

class AppRoutes {
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';

  static getApplicationRoute() {
    return {
      splashRoute: (context) => const SplashScreen(),
      loginRoute: (context) => const LoginScreen(),
      signupRoute: (context) => const RegisterScreen(),
      homeRoute: (context) => const HomeScreen(),
    };
  }
}
