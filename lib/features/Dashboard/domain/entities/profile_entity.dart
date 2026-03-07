import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String? id;
  final String fullName;
  final String email;
  final String? phone;
  final String? profileImage;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileEntity({
    this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.profileImage,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    phone,
    profileImage,
    role,
    createdAt,
    updatedAt,
  ];

  ProfileEntity copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
