import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/user_entity.dart';

// This ID must be unique for every model you create
part 'auth_hive_model.g.dart'; // This will be generated later

@HiveType(typeId: 0)
class AuthHiveModel {
  @HiveField(0)
  final String? userId;
  @HiveField(1)
  final String fullName;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String? phone;
  @HiveField(5)
  final String? password;
  @HiveField(6)
  final String? confirmPassword;

  AuthHiveModel({
    String? userId,
    required this.fullName,
    required this.email,
    this.phone,
    required this.password,
    required this.confirmPassword,
  }) : userId = userId ?? const Uuid().v4();


  // Convert Entity to Model (To save to Hive)
  factory AuthHiveModel.fromEntity(UserEntity entity) {
    return AuthHiveModel(
      userId: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      phone: entity.phone,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
    );
  }

  // Convert Model to Entity (To use in UI/Logic)
  UserEntity toEntity() {
    return UserEntity(
      id: userId,
      fullName: fullName,
      email: email,
      phone: phone,
      password: password, 
      confirmPassword: confirmPassword??'',
    );
  }

  // to entity list
  static List<UserEntity> toEntityList(List<AuthHiveModel> models){
    return models.map((model)=> model.toEntity()).toList();
  }
}