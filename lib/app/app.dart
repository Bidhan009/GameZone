import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gamezone_flutter/app/theme/app_theme.dart';
import '../features/splash/presentation/view/splash_screen.dart';
import '../features/onboarding/presentation/view/onboarding_screen.dart';
import '../features/auth/presentation/view/login_screen.dart';
import '../features/auth/presentation/view/register_screen.dart';
import '../features/Dashboard/presentation/view/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/service/sensor_service.dart';
import 'package:gamezone_flutter/core/service/storage/token_service.dart';
import 'package:gamezone_flutter/core/service/storage/token_service.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  StreamSubscription<void>? _shakeSubscription;
  bool _isDialogShown = false;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startShakeDetection();
    });
  }

  void _startShakeDetection() {
    final sensorService = ref.read(sensorServiceProvider);
    sensorService.startAccelerometer();
    _shakeSubscription = sensorService.shakeStream.listen((_) {
      debugPrint('Shake event received, showing dialog...');
      _showLogoutDialog();
    });
  }

  void _showLogoutDialog() {
    debugPrint('showLogoutDialog called - mounted: $mounted, _isDialogShown: $_isDialogShown');
    if (!mounted) {
      debugPrint('Not mounted, returning');
      return;
    }
    if (_isDialogShown) {
      debugPrint('Dialog already shown, returning');
      return;
    }
    _isDialogShown = true;
    debugPrint('About to show dialog');
    showDialog(
      context: _navigatorKey.currentContext!,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              _isDialogShown = false;
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              _isDialogShown = false;
              final tokenService = ref.read(tokenServiceProvider);
              await tokenService.removeToken();
              _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    ).then((_) => _isDialogShown = false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shakeSubscription?.cancel();
    ref.read(sensorServiceProvider).stopAccelerometer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
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

final sensorServiceProvider = Provider<SensorService>((ref) {
  final service = SensorService();
  ref.onDispose(() => service.dispose());
  return service;
});
