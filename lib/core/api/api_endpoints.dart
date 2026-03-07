class ApiEndpoints {
  ApiEndpoints._();

  // Choose based on your testing device
  static const String _emulator = '10.0.2.2'; // Android Emulator
  // static const String _physical = '192.168.137.1'; // Update this to your IP!

  // Backend runs on port 5050 (from your server output)
  static const String baseUrl = 'http://$_emulator:5000/api/';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // These match your backend routes exactly
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';

  // Profile endpoints (matches backend: /auth/whoami and /auth/update-profile)
  static const String userProfile = '/auth/whoami';
  static const String updateProfile = '/auth/update-profile';
}
