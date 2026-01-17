import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/service/hive/hive_service.dart';
import 'package:gamezone_flutter/core/service/storage/user_session_service.dart';
import 'package:gamezone_flutter/features/auth/data/data_source/auth_datasource.dart';
import 'package:gamezone_flutter/features/auth/data/model/auth_hive_model.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);

  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDatasource implements IAuthLocalDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  })  : _hiveService = hiveService,
        _userSessionService = userSessionService;

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      // HiveService login returns the model or null
      final user = await _hiveService.login(email, password);
      if (user != null) {
        await _userSessionService.saveUserSession(
          userId: user.userId!, // Removed null check as it's required for login
          email: user.email,
          fullName: user.fullName,
          phone: user.phone,
        );
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    try {
      await _hiveService.register(user);
      return user;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      if (!_userSessionService.isLoggedIn()) {
        return null;
      }

      final userId = _userSessionService.getUserId();
      if (userId == null) return null;

      return await _hiveService.getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _userSessionService.clearUserSession();
      // Optionally: await _hiveService.close(); if you want to close DB on logout
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isEmailExists(String email) async {
    try {
      // Calling the updated HiveService method
      return await _hiveService.isEmailRegistered(email);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> getUserById(String authId) async {
    try {
      return await _hiveService.getUserById(authId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    try {
      return await _hiveService.getUserByEmail(email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateUser(AuthHiveModel user) async {
    try {
      return await _hiveService.updateUser(user);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteUser(String authId) async {
    try {
      await _hiveService.deleteUser(authId);
      return true;
    } catch (e) {
      return false;
    }
  }
}