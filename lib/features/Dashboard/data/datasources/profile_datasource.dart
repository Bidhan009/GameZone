import 'package:gamezone_flutter/features/Dashboard/data/models/profile_api_model.dart';
import 'package:gamezone_flutter/features/Dashboard/data/models/profile_hive_model.dart';

abstract interface class IProfileLocalDataSource {
  // Cache profile data locally
  Future<ProfileHiveModel> cacheProfile(ProfileHiveModel model);

  // Get cached profile
  Future<ProfileHiveModel?> getCachedProfile();

  // Update cached profile
  Future<ProfileHiveModel> updateCachedProfile(ProfileHiveModel model);

  // Clear cached profile (for logout)
  Future<bool> clearCachedProfile();

  // Check if profile is cached
  Future<bool> isProfileCached();

  // Cache profile image path
  Future<bool> cacheProfileImagePath(String imagePath);

  // Get cached profile image path
  Future<String?> getCachedProfileImagePath();
}

abstract interface class IProfileRemoteDataSource {
  // Get user profile from server
  Future<ProfileApiModel> getProfile();

  // Update user profile on server
  Future<ProfileApiModel> updateProfile(ProfileApiModel profile);

  // Upload profile image to server
  Future<ProfileApiModel> uploadProfileImage(String imagePath);

  // Delete profile image from server
  Future<ProfileApiModel> deleteProfileImage();

  // Get profile by ID (admin functionality)
  Future<ProfileApiModel?> getProfileById(String profileId);
}
