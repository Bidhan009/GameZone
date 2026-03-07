import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamezone_flutter/core/error/failure.dart';
import 'package:gamezone_flutter/features/auth/domain/entities/user_entity.dart';
import 'package:gamezone_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:gamezone_flutter/features/auth/domain/use_case/get_current_usecase.dart';
import 'package:mocktail/mocktail.dart';

// Mock repository
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late GetCurrentUserUsecase getCurrentUserUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    getCurrentUserUsecase = GetCurrentUserUsecase(
      authRepository: mockAuthRepository,
    );
  });

  const tUser = UserEntity(
    id: '1',
    fullName: 'Test User',
    email: 'test@example.com',
    phone: '9812345678',
    confirmPassword: 'password123',
  );

  group('GetCurrentUserUsecase', () {
    test('should return UserEntity when user is authenticated', () async {
      // Arrange
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      final result = await getCurrentUserUsecase();

      // Assert
      expect(result, const Right(tUser));
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ApiFailure when user is not authenticated', () async {
      // Arrange
      final tFailure = ApiFailure(message: 'User not authenticated');
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await getCurrentUserUsecase();

      // Assert
      expect(result, Left(tFailure));
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test(
      'should return LocalDatabaseFailure when local storage fails',
      () async {
        // Arrange
        final tFailure = LocalDatabaseFailure(
          message: 'Failed to read user data',
        );
        when(
          () => mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => Left(tFailure));

        // Act
        final result = await getCurrentUserUsecase();

        // Assert
        expect(result, Left(tFailure));
        verify(() => mockAuthRepository.getCurrentUser()).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test(
      'should return LocalDatabaseFailure when fetching from cache fails',
      () async {
        // Arrange
        final tFailure = LocalDatabaseFailure(
          message: 'Cache storage corrupted',
        );
        when(
          () => mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => Left(tFailure));

        // Act
        final result = await getCurrentUserUsecase();

        // Assert
        expect(result, Left(tFailure));
        verify(() => mockAuthRepository.getCurrentUser()).called(1);
      },
    );

    test('should return user with all fields populated', () async {
      // Arrange
      const userWithAllFields = UserEntity(
        id: '123',
        fullName: 'John Doe',
        email: 'john.doe@example.com',
        phone: '9876543210',
        password: 'securePassword',
        confirmPassword: 'securePassword',
      );

      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(userWithAllFields));

      // Act
      final result = await getCurrentUserUsecase();

      // Assert
      result.fold((failure) => fail('Should return user'), (user) {
        expect(user.id, '123');
        expect(user.fullName, 'John Doe');
        expect(user.email, 'john.doe@example.com');
        expect(user.phone, '9876543210');
        expect(user.password, 'securePassword');
        expect(user.confirmPassword, 'securePassword');
      });
    });

    test('should call repository getCurrentUser method exactly once', () async {
      // Arrange
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      await getCurrentUserUsecase();

      // Assert
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
    });

    test('should propagate repository failures correctly', () async {
      // Arrange
      final tFailure = ApiFailure(message: 'Session expired', statusCode: 401);
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await getCurrentUserUsecase();

      // Assert
      expect(result, isA<Left>());
      expect(result.isLeft(), true);
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
    });

    test('should return user with optional fields as null', () async {
      // Arrange
      const userWithoutOptionalFields = UserEntity(
        fullName: 'Minimal User',
        email: 'minimal@example.com',
        confirmPassword: 'password',
      );

      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(userWithoutOptionalFields));

      // Act
      final result = await getCurrentUserUsecase();

      // Assert
      result.fold((failure) => fail('Should return user'), (user) {
        expect(user.id, isNull);
        expect(user.phone, isNull);
        expect(user.password, isNull);
        expect(user.fullName, 'Minimal User');
        expect(user.email, 'minimal@example.com');
      });
    });
  });
}
