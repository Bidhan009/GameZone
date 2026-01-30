import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gamezone_flutter/core/api/api_client.dart';
import 'package:gamezone_flutter/core/api/api_endpoints.dart';
import 'package:gamezone_flutter/core/service/storage/token_service.dart';
import 'package:gamezone_flutter/core/utils/image_picker_helper.dart';
import 'package:gamezone_flutter/features/Dashboard/data/datasources/local/profile_local_datasource.dart';
import 'package:gamezone_flutter/features/Dashboard/data/datasources/profile_datasource.dart';
import 'package:gamezone_flutter/features/Dashboard/data/datasources/remote/profile_remote_datasource.dart';
import 'package:gamezone_flutter/features/Dashboard/data/models/profile_api_model.dart';
import 'package:gamezone_flutter/features/Dashboard/data/models/profile_hive_model.dart';
import 'package:gamezone_flutter/features/Dashboard/domain/entities/profile_entity.dart';

// Providers
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier(
    remoteDataSource: ref.read(profileRemoteDatasourceProvider),
    localDataSource: ref.read(profileLocalDatasourceProvider),
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

// Temporary providers for backward compatibility
final profileUsernameProvider = StateProvider<String>((ref) => 'Bidhan');
final profileEmailProvider = StateProvider<String>(
  (ref) => 'bidhan@gamezone.com',
);

// Profile State
class ProfileState {
  final ProfileEntity? profile;
  final bool isLoading;
  final String? error;
  final bool isUploading;

  ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.isUploading = false,
  });

  ProfileState copyWith({
    ProfileEntity? profile,
    bool? isLoading,
    String? error,
    bool? isUploading,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

// Profile Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final IProfileRemoteDataSource _remoteDataSource;
  final IProfileLocalDataSource _localDataSource;
  final ApiClient _apiClient;
  final TokenService _tokenService;

  ProfileNotifier({
    required IProfileRemoteDataSource remoteDataSource,
    required IProfileLocalDataSource localDataSource,
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _apiClient = apiClient,
       _tokenService = tokenService,
       super(ProfileState());

  // Load profile from cache first, then from remote
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Check if user is authenticated
      final token = await _tokenService.getToken();
      if (token == null || token.isEmpty) {
        state = state.copyWith(
          error: 'User not authenticated. Please login first.',
          isLoading: false,
        );
        return;
      }

      // Try to get from cache first
      final cachedProfile = await _localDataSource.getCachedProfile();
      if (cachedProfile != null) {
        state = state.copyWith(profile: cachedProfile.toEntity());
      }

      // Then fetch from remote
      final remoteProfile = await _remoteDataSource.getProfile();

      // Cache the remote profile
      final hiveModel = ProfileHiveModel.fromEntity(remoteProfile.toEntity());
      await _localDataSource.cacheProfile(hiveModel);

      state = state.copyWith(profile: remoteProfile.toEntity());
    } catch (e) {
      String errorMessage = e.toString();
      
      // Handle 401 errors specifically
      if (errorMessage.contains('401') || errorMessage.contains('Unauthorized')) {
        await _tokenService.removeToken();
        errorMessage = 'Session expired. Please login again.';
      }
      
      state = state.copyWith(error: errorMessage);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Upload profile image
  Future<bool> uploadProfileImage(File imageFile) async {
    state = state.copyWith(isUploading: true, error: null);

    try {
      // Check if user is authenticated
      final token = await _tokenService.getToken();
      if (token == null || token.isEmpty) {
        state = state.copyWith(
          error: 'User not authenticated. Please login first.',
          isUploading: false,
        );
        return false;
      }

      // Validate and compress image
      if (!ImagePickerHelper.isValidImageFile(imageFile)) {
        state = state.copyWith(error: 'Invalid image file', isUploading: false);
        return false;
      }

      final compressedFile = await ImagePickerHelper.compressImageIfNeeded(
        imageFile,
        maxSizeMB: 2.0,
        quality: 85,
      );

      if (compressedFile == null) {
        state = state.copyWith(error: 'Failed to compress image', isUploading: false);
        return false;
      }

      // Upload to remote
      final updatedProfile = await _remoteDataSource.uploadProfileImage(
        compressedFile.path,
      );

      print('Upload successful. Updated profile: ${updatedProfile.profileImage}'); // Debug log

      // Update cache
      final hiveModel = ProfileHiveModel.fromEntity(updatedProfile.toEntity());
      await _localDataSource.cacheProfile(hiveModel);

      state = state.copyWith(
        profile: updatedProfile.toEntity(),
        isUploading: false,
      );

      print('Profile state updated with new image URL: ${state.profile?.profileImage}'); // Debug log

      return true;
    } catch (e) {
      String errorMessage = e.toString();
      
      // Handle 401 errors specifically
      if (errorMessage.contains('401') || errorMessage.contains('Unauthorized')) {
        await _tokenService.removeToken();
        errorMessage = 'Session expired. Please login again.';
      }
      
      state = state.copyWith(
        error: 'Failed to upload image: $errorMessage',
        isUploading: false,
      );
      return false;
    }
  }

  // Update profile information
  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      if (state.profile == null) {
        state = state.copyWith(error: 'No profile loaded');
        return false;
      }

      // Create updated profile
      final currentProfile = state.profile!;
      final updatedEntity = currentProfile.copyWith(
        fullName: fullName ?? currentProfile.fullName,
        email: email ?? currentProfile.email,
        phone: phone ?? currentProfile.phone,
        updatedAt: DateTime.now(),
      );

      final apiModel = ProfileApiModel.fromEntity(updatedEntity);

      // Update on remote
      final updatedProfile = await _remoteDataSource.updateProfile(apiModel);

      // Update cache
      final hiveModel = ProfileHiveModel.fromEntity(updatedProfile.toEntity());
      await _localDataSource.cacheProfile(hiveModel);

      state = state.copyWith(
        profile: updatedProfile.toEntity(),
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update profile: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Delete profile image
  Future<bool> deleteProfileImage() async {
    state = state.copyWith(isUploading: true, error: null);

    try {
      final updatedProfile = await _remoteDataSource.deleteProfileImage();

      // Update cache
      final hiveModel = ProfileHiveModel.fromEntity(updatedProfile.toEntity());
      await _localDataSource.cacheProfile(hiveModel);

      state = state.copyWith(
        profile: updatedProfile.toEntity(),
        isUploading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete image: $e',
        isUploading: false,
      );
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Logout and clear profile
  Future<void> logout() async {
    try {
      // Clear token
      await _tokenService.removeToken();

      // Clear cached profile
      await _localDataSource.clearCachedProfile();

      // Reset state
      state = ProfileState();
    } catch (e) {
      state = state.copyWith(error: 'Logout failed: $e');
    }
  }
}

// Example future provider (when you connect real backend)
final profileFutureProvider = FutureProvider.autoDispose((ref) async {
  // await Future.delayed(const Duration(seconds: 1));
  return {
    'username': 'BidhanGamer',
    'email': 'bidhan@example.com',
    'avatarUrl': null,
  };
});
