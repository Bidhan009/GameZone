import 'package:gamezone_flutter/features/auth/data/model/auth_api_model.dart';
import 'package:gamezone_flutter/features/auth/data/model/auth_hive_model.dart';

abstract interface class IAuthLocalDataSource {
  Future<AuthHiveModel> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  
  // Added to support Repository methods
  Future<AuthHiveModel?> getUserById(String authId);
  Future<AuthHiveModel?> getUserByEmail(String email);
  Future<bool> updateUser(AuthHiveModel model);
  Future<bool> deleteUser(String authId);

  // Email check
  Future<bool> isEmailExists(String email);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> getUserById(String authId);
}