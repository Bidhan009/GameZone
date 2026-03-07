import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/api/api_client.dart';
import 'package:gamezone_flutter/core/api/api_endpoints.dart';
import 'package:gamezone_flutter/core/service/storage/token_service.dart';
import 'package:gamezone_flutter/core/service/storage/user_session_service.dart';
import 'package:gamezone_flutter/features/auth/data/data_source/auth_datasource.dart';
import 'package:gamezone_flutter/features/auth/data/model/auth_api_model.dart';

// Create provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    // Check success
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      // ✅ Extract token safely
      final token = response.data['token'] as String?;

      if (token == null || token.isEmpty) {
        throw Exception("Token not found in response");
      }

      // ✅ Save token to secure storage
      await _tokenService.saveToken(token);

      // ✅ Save user session
      await _userSessionService.saveUserSession(
        userId: user.authId ?? '',
        email: user.email,
        fullName: user.fullName,
        phone: user.phone ?? '',
      );

      return user;
    }

    throw Exception(response.data['message'] ?? "Login failed");
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
}
