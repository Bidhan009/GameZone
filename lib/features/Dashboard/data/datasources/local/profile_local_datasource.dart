import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gamezone_flutter/core/service/hive/hive_service.dart';
import 'package:gamezone_flutter/features/Dashboard/data/datasources/profile_datasource.dart';
import 'package:gamezone_flutter/features/Dashboard/data/models/profile_hive_model.dart';

// Provider for local data source
final profileLocalDatasourceProvider = Provider<IProfileLocalDataSource>((ref) {
  return ProfileLocalDataSource(
    hiveService: ref.read(hiveServiceProvider),
  );
});

class ProfileLocalDataSource implements IProfileLocalDataSource {
  final HiveService _hiveService;
  static const String _profileBoxName = 'profile_box';
  static const String _profileKey = 'user_profile';
  static const String _profileImageKey = 'profile_image_path';

  ProfileLocalDataSource({
    required HiveService hiveService,
  }) : _hiveService = hiveService;

  @override
  Future<ProfileHiveModel> cacheProfile(ProfileHiveModel model) async {
    try {
      final box = await _hiveService.openBox<ProfileHiveModel>(_profileBoxName);
      await box.put(_profileKey, model);
      return model;
    } catch (e) {
      throw Exception('Failed to cache profile: $e');
    }
  }

  @override
  Future<ProfileHiveModel?> getCachedProfile() async {
    try {
      final box = await _hiveService.openBox<ProfileHiveModel>(_profileBoxName);
      return box.get(_profileKey);
    } catch (e) {
      throw Exception('Failed to get cached profile: $e');
    }
  }

  @override
  Future<ProfileHiveModel> updateCachedProfile(ProfileHiveModel model) async {
    try {
      final box = await _hiveService.openBox<ProfileHiveModel>(_profileBoxName);
      await box.put(_profileKey, model);
      return model;
    } catch (e) {
      throw Exception('Failed to update cached profile: $e');
    }
  }

  @override
  Future<bool> clearCachedProfile() async {
    try {
      final box = await _hiveService.openBox<ProfileHiveModel>(_profileBoxName);
      await box.delete(_profileKey);
      await box.delete(_profileImageKey);
      return true;
    } catch (e) {
      throw Exception('Failed to clear cached profile: $e');
    }
  }

  @override
  Future<bool> isProfileCached() async {
    try {
      final box = await _hiveService.openBox<ProfileHiveModel>(_profileBoxName);
      return box.containsKey(_profileKey);
    } catch (e) {
      throw Exception('Failed to check if profile is cached: $e');
    }
  }

  @override
  Future<bool> cacheProfileImagePath(String imagePath) async {
    try {
      final box = await _hiveService.openBox<String>(_profileBoxName);
      await box.put(_profileImageKey, imagePath);
      return true;
    } catch (e) {
      throw Exception('Failed to cache profile image path: $e');
    }
  }

  @override
  Future<String?> getCachedProfileImagePath() async {
    try {
      final box = await _hiveService.openBox<String>(_profileBoxName);
      return box.get(_profileImageKey);
    } catch (e) {
      throw Exception('Failed to get cached profile image path: $e');
    }
  }

  // Additional helper methods
  Future<void> clearAllProfileData() async {
    try {
      final box = await _hiveService.openBox(_profileBoxName);
      await box.clear();
    } catch (e) {
      throw Exception('Failed to clear all profile data: $e');
    }
  }

  Future<Map<String, dynamic>?> getAllProfileData() async {
    try {
      final box = await _hiveService.openBox(_profileBoxName);
      final profile = box.get(_profileKey);
      final imagePath = box.get(_profileImageKey);
      
      return {
        'profile': profile,
        'imagePath': imagePath,
      };
    } catch (e) {
      throw Exception('Failed to get all profile data: $e');
    }
  }
}