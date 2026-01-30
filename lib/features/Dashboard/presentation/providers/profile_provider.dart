import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Temporary – later read from auth provider or shared_preferences
final profileUsernameProvider = StateProvider<String>((ref) => 'Bidhan');
final profileEmailProvider = StateProvider<String>(
  (ref) => 'bidhan@gamezone.com',
);

// Example future provider (when you connect real backend)
final profileFutureProvider = FutureProvider.autoDispose((ref) async {
  // await Future.delayed(const Duration(seconds: 1));
  return {
    'username': 'BidhanGamer',
    'email': 'bidhan@example.com',
    'avatarUrl': null,
  };
});
