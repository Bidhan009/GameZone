import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gamezone_flutter/core/error/failure.dart';
import 'package:gamezone_flutter/features/auth/domain/entities/user_entity.dart';
import 'package:gamezone_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:gamezone_flutter/features/auth/domain/use_case/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockRepository);
  });

  final tUserEntity = UserEntity(
    id: 'test_user_id',
    email: 'test@example.com',
    phone: '9812345678',
    fullName: 'Test User',
    confirmPassword: 'password123',
  );

  group('LoginUsecase', () {
    test('should return UserEntity when login is successful', () async {
      // Arrange
      const tEmail = 'test@example.com';
      const tPassword = 'password123';
      when(
        () => mockRepository.loginUser(tEmail, tPassword),
      ).thenAnswer((_) async => Right(tUserEntity));

      // Act
      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, Right(tUserEntity));
      verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return ApiFailure when login fails with invalid credentials',
      () async {
        // Arrange
        const tEmail = 'test@example.com';
        const tPassword = 'wrong_password';
        const tFailure = ApiFailure(message: 'Invalid credentials');
        when(
          () => mockRepository.loginUser(tEmail, tPassword),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await usecase(
          const LoginUsecaseParams(email: tEmail, password: tPassword),
        );

        // Assert
        expect(result, const Left(tFailure));
        verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
      },
    );

    test(
      'should return LocalDatabaseFailure when there is a database error',
      () async {
        // Arrange
        const tEmail = 'test@example.com';
        const tPassword = 'password123';
        const tFailure = LocalDatabaseFailure(
          message: 'Database error occurred',
        );
        when(
          () => mockRepository.loginUser(tEmail, tPassword),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await usecase(
          const LoginUsecaseParams(email: tEmail, password: tPassword),
        );

        // Assert
        expect(result, const Left(tFailure));
        verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
      },
    );

    test('should return ApiFailure when email format is invalid', () async {
      // Arrange
      const tEmail = 'invalid-email';
      const tPassword = 'password123';
      const tFailure = ApiFailure(message: 'Invalid email format');
      when(
        () => mockRepository.loginUser(tEmail, tPassword),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
    });

    test('should return ApiFailure when password is too short', () async {
      // Arrange
      const tEmail = 'test@example.com';
      const tPassword = '123';
      const tFailure = ApiFailure(
        message: 'Password must be at least 6 characters',
      );
      when(
        () => mockRepository.loginUser(tEmail, tPassword),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
    });
  });
}
