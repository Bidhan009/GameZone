import 'package:gamezone_flutter/features/Dashboard/domain/entities/profile_entity.dart';
import 'package:gamezone_flutter/core/api/api_endpoints.dart';

class ProfileApiModel {
  final String? profileId;
  final String fullName;
  final String email;
  final String? phone;
  String? profileImage;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileApiModel({
    this.profileId,
    required this.fullName,
    required this.email,
    this.phone,
    this.profileImage,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  // toJson
  Map<String, dynamic> toJson() {
    return {
      "_id": profileId,
      "fullName": fullName,
      "email": email,
      "phone": phone,
      if (profileImage != null) "profileImage": profileImage,
      if (role != null) "role": role,
    };
  }

  // fromJson
  factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
    String? profileImageUrl = json['profileImage'] as String?;
    
    // Convert relative path to full URL if needed
    if (profileImageUrl != null && 
        profileImageUrl.isNotEmpty && 
        !profileImageUrl.startsWith('http')) {
      // Remove '/api/' from baseUrl and add the image path
      final baseUrl = ApiEndpoints.baseUrl.replaceFirst('/api/', '');
      profileImageUrl = '$baseUrl$profileImageUrl';
      print('Converted image URL: $profileImageUrl'); // Debug log
    }
    
    return ProfileApiModel(
      profileId: json['_id'] as String?,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      profileImage: profileImageUrl,
      role: json['role'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  // toEntity
  ProfileEntity toEntity() {
    return ProfileEntity(
      id: profileId,
      fullName: fullName,
      email: email,
      phone: phone,
      profileImage: profileImage,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // fromEntity
  factory ProfileApiModel.fromEntity(ProfileEntity entity) {
    return ProfileApiModel(
      profileId: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      phone: entity.phone,
      profileImage: entity.profileImage,
      role: entity.role,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // toEntityList
  static List<ProfileEntity> toEntityList(List<ProfileApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

  // fromEntityList
  static List<ProfileApiModel> fromEntityList(List<ProfileEntity> entities) {
    return entities.map((entity) => ProfileApiModel.fromEntity(entity)).toList();
  }
}