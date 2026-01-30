import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/profile_entity.dart';

// This ID must be unique for every model you create
part 'profile_hive_model.g.dart'; // This will be generated later

@HiveType(typeId: 1)
class ProfileHiveModel {
  @HiveField(0)
  final String? profileId;
  @HiveField(1)
  final String fullName;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String? phone;
  @HiveField(4)
  final String? profileImage;
  @HiveField(5)
  final String? role;
  @HiveField(6)
  final DateTime? createdAt;
  @HiveField(7)
  final DateTime? updatedAt;

  ProfileHiveModel({
    String? profileId,
    required this.fullName,
    required this.email,
    this.phone,
    this.profileImage,
    this.role,
    this.createdAt,
    this.updatedAt,
  }) : profileId = profileId ?? const Uuid().v4();

  // Convert Entity to Model (To save to Hive)
  factory ProfileHiveModel.fromEntity(ProfileEntity entity) {
    return ProfileHiveModel(
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

  // Convert Model to Entity (To use in UI/Logic)
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

  // to entity list
  static List<ProfileEntity> toEntityList(List<ProfileHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

  // from entity list
  static List<ProfileHiveModel> fromEntityList(List<ProfileEntity> entities) {
    return entities
        .map((entity) => ProfileHiveModel.fromEntity(entity))
        .toList();
  }

  // toJson for potential backup/export
  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // fromJson for potential import/restore
  factory ProfileHiveModel.fromJson(Map<String, dynamic> json) {
    return ProfileHiveModel(
      profileId: json['profileId'] as String?,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      profileImage: json['profileImage'] as String?,
      role: json['role'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}