import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/api/api_client.dart';
import 'package:gamezone_flutter/core/api/api_endpoints.dart';
import 'package:gamezone_flutter/core/service/storage/user_session_service.dart';
import 'package:gamezone_flutter/features/auth/data/data_source/auth_datasource.dart';
import 'package:gamezone_flutter/features/auth/data/model/auth_api_model.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
  final data = response.data['data'] as Map<String, dynamic>;
  final user = AuthApiModel.fromJson(data);

  // Save to session using YOUR model's fields
  await _userSessionService.saveUserSession(
    // Use ?? '' instead of ! to prevent the "null check" crash
    userId: user.authId ?? '', 
    email: user.email,
    fullName: user.fullName,
    // Add other fields only if your UserSessionService supports them
    phone: user.phone ?? '', 
  );
  
  return user;
}

    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }

    return user;
  }

  @override
  Future<AuthApiModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }
}