import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/constants/hive_constant_table.dart';
import 'package:gamezone_flutter/features/auth/data/model/auth_hive_model.dart';
import 'package:gamezone_flutter/features/Dashboard/data/models/profile_hive_model.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  // Initialize Hive
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);

    // Register Adapters
    _registerAdapter();
    
    // Open necessary boxes
    await _openBoxes();
  }

  // Adapter registration
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.profileTypeId)) {
      Hive.registerAdapter(ProfileHiveModelAdapter());
    }
    // Add additional adapters here as you create more features
  }

  // Open Boxes
  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    await Hive.openBox<ProfileHiveModel>(HiveTableConstant.profileTable);
  }

  // Helper getter for Auth Box
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  // Helper getter for Profile Box
  Box<ProfileHiveModel> get _profileBox =>
      Hive.box<ProfileHiveModel>(HiveTableConstant.profileTable);

  // ======================== AUTH QUERIES ========================== //

  /// Register a new user
  Future<void> register(AuthHiveModel user) async {
    await _authBox.put(user.userId, user);
  }

  /// Login - find user by email and password
  /// Returns AuthHiveModel if found, null otherwise
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      return _authBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if an email is already registered (Validation)
  Future<bool> isEmailRegistered(String email) async {
    return _authBox.values.any((user) => user.email == email);
  }

  /// Get user by their Unique ID (authId)
  Future<AuthHiveModel?> getUserById(String authId) async {
    return _authBox.get(authId);
  }

  /// Get user by email address
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  /// Update existing user information
  Future<bool> updateUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.userId)) {
      await _authBox.put(user.userId, user);
      return true;
    }
    return false;
  }

  /// Delete user from local database
  Future<void> deleteUser(String authId) async {
    await _authBox.delete(authId);
  }

  /// Clear all auth data (Useful for full logout/factory reset)
  Future<void> clearAllData() async {
    await _authBox.clear();
  }

  // Box close
  Future<void> close() async {
    await Hive.close();
  }

  // Generic openBox method for dynamic box access
  Future<Box<T>> openBox<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<T>(boxName);
    }
    return Hive.box<T>(boxName);
  }
}