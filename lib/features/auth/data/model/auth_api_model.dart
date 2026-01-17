import'package:gamezone_flutter/features/auth/domain/entities/user_entity.dart';
class AuthApiModel {
  final String? authId;
  final String fullName;
  final String email;
  final String? phone;
  final String? password;
  final String? confirmPassword;

  AuthApiModel({
    this.authId,
    required this.fullName,
    required this.email,    
    this.phone,    
    this.password,
    this.confirmPassword,
  });

  //to Json

  Map<String, dynamic> toJson() {
    return {
      "fullName":fullName,
      "email": email,
      "phone": phone,
      "password" : password,
      "confirmPassword" : confirmPassword,
    };
  }

  // fromJson

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      authId: json['_id'] as String?,
      fullName: json['fullName'] as String? ??'',
      email: json['email'] as String? ??'',
      phone: json['phone'] as String? ??'',
      password: json['password'] as String?,
      confirmPassword: json['confirmPassword'] as String?
    );
  }

  //toEntity

  UserEntity toEntity() {
    return UserEntity(
      id: authId,
      fullName: fullName,
      email: email,
      phone: phone, 
      password: password,
      confirmPassword: confirmPassword??'',
    );
  }

  //fromEntity
  factory AuthApiModel.fromEntity(UserEntity entity) {
    return AuthApiModel(
      fullName:entity.fullName,
      email: entity.email,
      password: entity.password, 
      phone: entity.phone,
      confirmPassword: entity.confirmPassword
    );
  }

  //toEntityList

  static List<UserEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}