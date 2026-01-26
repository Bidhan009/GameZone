import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/error/failure.dart';
import 'package:gamezone_flutter/core/usecase.dart';
import 'package:gamezone_flutter/features/auth/data/repositories/auth_repositories.dart';
import 'package:gamezone_flutter/features/auth/domain/entities/user_entity.dart';
import 'package:gamezone_flutter/features/auth/domain/repository/auth_repository.dart';

class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;

  const RegisterUsecaseParams({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props =>
      [fullName, email, phone, password, confirmPassword];
}

//provider
final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = UserEntity(
      fullName: params.fullName,
      email: params.email,
      phone: params.phone,
      password: params.password,
      confirmPassword: params.confirmPassword,
    );

    return _authRepository.registerUser(entity);
  }
}
