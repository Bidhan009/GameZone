import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/error/failure.dart';
import 'package:gamezone_flutter/core/service/connections/network_info.dart';
import 'package:gamezone_flutter/features/auth/data/data_source/auth_datasource.dart';
import 'package:gamezone_flutter/features/auth/data/data_source/local_data_source/auth_local_data_source.dart';
import 'package:gamezone_flutter/features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';
import 'package:gamezone_flutter/features/auth/data/model/auth_api_model.dart';
import 'package:gamezone_flutter/features/auth/data/model/auth_hive_model.dart';
import 'package:gamezone_flutter/features/auth/domain/entities/user_entity.dart';
import 'package:gamezone_flutter/features/auth/domain/repository/auth_repository.dart';

// Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authLocal = ref.read(authLocalDatasourceProvider);
  final authRemote = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
    authDatasource: authLocal,
    authRemoteDataSource: authRemote,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authDatasource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authDatasource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
  })  : _authDatasource = authDatasource,
        _authRemoteDataSource = authRemoteDataSource,
        _networkInfo = networkInfo;

  // ------------------- Get Current User -------------------
  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await _authDatasource.getCurrentUser();
      if (user != null) {
        return Right(user.toEntity());
      }
      return Left(LocalDatabaseFailure(message: "No user logged in"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ------------------- Login -------------------
  @override
  Future<Either<Failure, UserEntity>> loginUser(String email, String password) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(email, password);
        if (apiModel != null) return Right(apiModel.toEntity());
        return const Left(ApiFailure(message: "Invalid Credentials"));
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? 'Login Failed',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _authDatasource.login(email, password);
        if (user != null) return Right(user.toEntity());
        return Left(LocalDatabaseFailure(message: 'Invalid email or password'));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  // ------------------- Logout -------------------
  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final success = await _authDatasource.logout();
      if (success) return Right(true);
      return Left(LocalDatabaseFailure(message: "Failed to logout user"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ------------------- Register -------------------
  @override
  Future<Either<Failure, bool>> registerUser(UserEntity user) async {
    if (await _networkInfo.isConnected) {
      // Remote registration
      try {
        final apiModel = AuthApiModel.fromEntity(user);

        // Await remote register (void)
        await _authRemoteDataSource.register(apiModel);

        // If no exception, registration is successful
        return const Right(true);
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? 'Registration Failed',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Local registration
      try {
        final model = AuthHiveModel.fromEntity(user);

        // Await local register (return bool)
        await _authDatasource.register(model);

        return const Right(true); // Return true if no exception
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
