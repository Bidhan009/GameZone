import 'package:equatable/equatable.dart';

// We use Equatable to easily compare two User objects
class UserEntity extends Equatable {
  final String? id;
  final String fullName;
  final String email;
  final String? phone;
  final String? password;
  final String confirmPassword;

  const UserEntity({
    this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [id, fullName, email, phone, password, confirmPassword];
}