import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/error/failure.dart';
import 'package:gamezone_flutter/core/usecase.dart';
import 'package:gamezone_flutter/features/auth/data/repositories/auth_repositories.dart';
import 'package:gamezone_flutter/features/auth/domain/entities/user_entity.dart';
import 'package:gamezone_flutter/features/auth/domain/repository/auth_repository.dart';

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  // Accessing the Repository interface
  final authRepository = ref.read(authRepositoryProvider);
  return GetCurrentUserUsecase(authRepository: authRepository);
});

// 2. Define the Usecase Class
class GetCurrentUserUsecase implements UsecaseWithoutParams<UserEntity> {
  final IAuthRepository _authRepository;

  GetCurrentUserUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, UserEntity>> call() async {
    // This calls the repository, which fetches the AuthHiveModel 
    // and converts it into an AuthEntity for the UI to use
    return await _authRepository.getCurrentUser();
  }
}