import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamezone_flutter/core/error/failure.dart';
import 'package:gamezone_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:gamezone_flutter/features/auth/domain/use_case/logout_usecase.dart';
import 'package:mocktail/mocktail.dart';

// Mock repository
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LogoutUsecase logoutUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    logoutUsecase = LogoutUsecase(authRepository: mockAuthRepository);
  });

  group('LogoutUsecase', () {
    test('should return Right(true) when logout is successful', () async {
      // Arrange
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await logoutUsecase();

      // Assert
      expect(result, const Right(true));
      verify(() => mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ApiFailure when logout API call fails', () async {
      // Arrange
      final tFailure = ApiFailure(message: 'Logout failed from server');
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await logoutUsecase();

      // Assert
      expect(result, Left(tFailure));
      verify(() => mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test(
      'should return LocalDatabaseFailure when clearing local data fails',
      () async {
        // Arrange
        final tFailure = LocalDatabaseFailure(
          message: 'Failed to clear local data',
        );
        when(
          () => mockAuthRepository.logout(),
        ).thenAnswer((_) async => Left(tFailure));

        // Act
        final result = await logoutUsecase();

        // Assert
        expect(result, Left(tFailure));
        verify(() => mockAuthRepository.logout()).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test('should call repository logout method exactly once', () async {
      // Arrange
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) async => const Right(true));

      // Act
      await logoutUsecase();

      // Assert
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('should propagate repository exceptions correctly', () async {
      // Arrange
      final tFailure = ApiFailure(message: 'Session expired', statusCode: 401);
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await logoutUsecase();

      // Assert
      expect(result, isA<Left>());
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('should handle logout with network errors', () async {
      // Arrange
      final tFailure = LocalDatabaseFailure(message: 'Network connection lost');
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await logoutUsecase();

      // Assert
      expect(result, Left(tFailure));
      expect(result.isLeft(), true);
    });
  });
}
