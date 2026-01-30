import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/api/api_client.dart';
import 'package:gamezone_flutter/core/api/api_endpoints.dart';
import 'package:gamezone_flutter/core/service/storage/token_service.dart';
import 'package:gamezone_flutter/features/Dashboard/data/datasources/profile_datasource.dart';
import 'package:gamezone_flutter/features/Dashboard/data/models/profile_api_model.dart';

// Provider for remote data source
final profileRemoteDatasourceProvider = Provider<IProfileRemoteDataSource>((
  ref,
) {
  return ProfileRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class ProfileRemoteDataSource implements IProfileRemoteDataSource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  ProfileRemoteDataSource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<ProfileApiModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userProfile);

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ProfileApiModel.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  @override
  Future<ProfileApiModel> updateProfile(ProfileApiModel profile) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.userProfile,
        data: profile.toJson(),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ProfileApiModel.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<ProfileApiModel> uploadProfileImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      final response = await _apiClient.uploadFile(
        ApiEndpoints.profileUpload,
        formData: formData,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ProfileApiModel.fromJson(data);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to upload profile image',
        );
      }
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  @override
  Future<ProfileApiModel> deleteProfileImage() async {
    try {
      final response = await _apiClient.delete(
        '${ApiEndpoints.userProfile}/image',
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ProfileApiModel.fromJson(data);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to delete profile image',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete profile image: $e');
    }
  }

  @override
  Future<ProfileApiModel?> getProfileById(String profileId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.userProfile}/$profileId',
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ProfileApiModel.fromJson(data);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to get profile by ID',
        );
      }
    } catch (e) {
      throw Exception('Failed to get profile by ID: $e');
    }
  }

  // Additional helper methods
  Future<bool> isProfileComplete() async {
    try {
      final profile = await getProfile();
      return profile.fullName.isNotEmpty &&
          profile.email.isNotEmpty &&
          profile.phone != null &&
          profile.phone!.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<ProfileApiModel> updateProfileField(
    String field,
    dynamic value,
  ) async {
    try {
      final response = await _apiClient.patch(
        '${ApiEndpoints.userProfile}/$field',
        data: {field: value},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ProfileApiModel.fromJson(data);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to update profile field',
        );
      }
    } catch (e) {
      throw Exception('Failed to update profile field: $e');
    }
  }

  Future<void> syncProfileWithLocal() async {
    try {
      final remoteProfile = await getProfile();
      // This would typically be handled by the repository layer
      // but keeping it here for completeness
    } catch (e) {
      throw Exception('Failed to sync profile with local: $e');
    }
  }
}
