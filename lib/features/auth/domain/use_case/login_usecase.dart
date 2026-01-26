import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/error/failure.dart';
import 'package:gamezone_flutter/core/usecase.dart';
import 'package:gamezone_flutter/features/auth/data/repositories/auth_repositories.dart';
import 'package:gamezone_flutter/features/auth/domain/entities/user_entity.dart';
import 'package:gamezone_flutter/features/auth/domain/repository/auth_repository.dart';


class LoginUsecaseParams extends Equatable {
  final String email;
  final String password;

  const LoginUsecaseParams({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

//provider for loginusecase

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LoginUsecase(authRepository: authRepository);
});

class LoginUsecase implements UsecaseWithParams<UserEntity, LoginUsecaseParams> {
  final IAuthRepository _authRepository;

  LoginUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;
  @override
  Future<Either<Failure, UserEntity>> call(LoginUsecaseParams params) {
    return _authRepository.loginUser(params.email, params.password);
  }
}

