import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamezone_flutter/core/error/failure.dart';
import 'package:gamezone_flutter/features/auth/domain/entities/user_entity.dart';
import 'package:gamezone_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:gamezone_flutter/features/auth/domain/use_case/register_usecase.dart';
import 'package:mocktail/mocktail.dart';

// Mock repository
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase registerUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerUsecase = RegisterUsecase(authRepository: mockAuthRepository);

    // Register fallback values for mocktail
    registerFallbackValue(
      UserEntity(
        fullName: 'Test',
        email: 'test@test.com',
        phone: '1234567890',
        password: 'password',
        confirmPassword: 'password',
      ),
    );
  });

  group('RegisterUsecase', () {
    // Test data
    const testFullName = 'John Doe';
    const testEmail = 'john@example.com';
    const testPhone = '9812345678';
    const testPassword = 'password123';
    const testConfirmPassword = 'password123';

    final tParams = RegisterUsecaseParams(
      fullName: testFullName,
      email: testEmail,
      phone: testPhone,
      password: testPassword,
      confirmPassword: testConfirmPassword,
    );

    final tUserEntity = UserEntity(
      fullName: testFullName,
      email: testEmail,
      phone: testPhone,
      password: testPassword,
      confirmPassword: testConfirmPassword,
    );

    group('call', () {
      test(
        'should call registerUser on repository with correct UserEntity',
        () async {
          // Arrange
          when(
            () => mockAuthRepository.registerUser(any()),
          ).thenAnswer((_) async => const Right(true));

          // Act
          final result = await registerUsecase(tParams);

          // Assert
          expect(result, const Right(true));
          verify(() => mockAuthRepository.registerUser(any())).called(1);
        },
      );

      test(
        'should return Right(true) when registration is successful',
        () async {
          // Arrange
          when(
            () => mockAuthRepository.registerUser(any()),
          ).thenAnswer((_) async => const Right(true));

          // Act
          final result = await registerUsecase(tParams);

          // Assert
          expect(result, const Right(true));
        },
      );

      test('should return Failure when registration fails', () async {
        // Arrange
        final tFailure = LocalDatabaseFailure(message: 'Registration failed');
        when(
          () => mockAuthRepository.registerUser(any()),
        ).thenAnswer((_) async => Left(tFailure));

        // Act
        final result = await registerUsecase(tParams);

        // Assert
        expect(result, Left(tFailure));
      });

      test('should return Failure when email already exists', () async {
        // Arrange
        final tFailure = LocalDatabaseFailure(message: 'Email already exists');
        when(
          () => mockAuthRepository.registerUser(any()),
        ).thenAnswer((_) async => Left(tFailure));

        // Act
        final result = await registerUsecase(tParams);

        // Assert
        expect(result, Left(tFailure));
      });

      test('should return Failure with network error', () async {
        // Arrange
        final tFailure = ApiFailure(message: 'Network error');
        when(
          () => mockAuthRepository.registerUser(any()),
        ).thenAnswer((_) async => Left(tFailure));

        // Act
        final result = await registerUsecase(tParams);

        // Assert
        expect(result, Left(tFailure));
      });

      test('should pass UserEntity with all correct parameters', () async {
        // Arrange
        when(
          () => mockAuthRepository.registerUser(any()),
        ).thenAnswer((_) async => const Right(true));

        // Act
        await registerUsecase(tParams);

        // Assert - Verify the repository was called with UserEntity
        verify(() => mockAuthRepository.registerUser(any())).called(1);
      });

      test('should handle different parameter values correctly', () async {
        // Arrange
        final differentParams = RegisterUsecaseParams(
          fullName: 'Jane Smith',
          email: 'jane@example.com',
          phone: '9876543210',
          password: 'securePass456',
          confirmPassword: 'securePass456',
        );

        when(
          () => mockAuthRepository.registerUser(any()),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await registerUsecase(differentParams);

        // Assert
        expect(result, const Right(true));
        verify(() => mockAuthRepository.registerUser(any())).called(1);
      });
    });

    group('RegisterUsecaseParams', () {
      test('should create instance with all required parameters', () {
        // Act & Assert
        expect(
          tParams,
          RegisterUsecaseParams(
            fullName: testFullName,
            email: testEmail,
            phone: testPhone,
            password: testPassword,
            confirmPassword: testConfirmPassword,
          ),
        );
      });

      test('should be equal when all properties are the same', () {
        // Arrange
        final params1 = RegisterUsecaseParams(
          fullName: testFullName,
          email: testEmail,
          phone: testPhone,
          password: testPassword,
          confirmPassword: testConfirmPassword,
        );

        final params2 = RegisterUsecaseParams(
          fullName: testFullName,
          email: testEmail,
          phone: testPhone,
          password: testPassword,
          confirmPassword: testConfirmPassword,
        );

        // Assert
        expect(params1, params2);
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final params1 = RegisterUsecaseParams(
          fullName: testFullName,
          email: testEmail,
          phone: testPhone,
          password: testPassword,
          confirmPassword: testConfirmPassword,
        );

        final params2 = RegisterUsecaseParams(
          fullName: 'Different Name',
          email: testEmail,
          phone: testPhone,
          password: testPassword,
          confirmPassword: testConfirmPassword,
        );

        // Assert
        expect(params1, isNot(params2));
      });

      test('should include all properties in props list', () {
        // Assert
        expect(tParams.props, [
          testFullName,
          testEmail,
          testPhone,
          testPassword,
          testConfirmPassword,
        ]);
      });

      test('should support value equality', () {
        // Arrange
        final params1 = RegisterUsecaseParams(
          fullName: testFullName,
          email: testEmail,
          phone: testPhone,
          password: testPassword,
          confirmPassword: testConfirmPassword,
        );

        final params2 = RegisterUsecaseParams(
          fullName: testFullName,
          email: testEmail,
          phone: testPhone,
          password: testPassword,
          confirmPassword: testConfirmPassword,
        );

        // Assert
        expect(params1 == params2, true);
      });
    });

    group('Edge cases', () {
      test('should handle special characters in fullName', () async {
        // Arrange
        final specialParams = RegisterUsecaseParams(
          fullName: "O'Brien-Smith",
          email: testEmail,
          phone: testPhone,
          password: testPassword,
          confirmPassword: testConfirmPassword,
        );

        when(
          () => mockAuthRepository.registerUser(any()),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await registerUsecase(specialParams);

        // Assert
        expect(result, const Right(true));
      });

      test('should handle international email addresses', () async {
        // Arrange
        final internationalParams = RegisterUsecaseParams(
          fullName: testFullName,
          email: 'john.doe+tag@example.co.uk',
          phone: testPhone,
          password: testPassword,
          confirmPassword: testConfirmPassword,
        );

        when(
          () => mockAuthRepository.registerUser(any()),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await registerUsecase(internationalParams);

        // Assert
        expect(result, const Right(true));
      });

      test('should handle long passwords', () async {
        // Arrange
        final longPassword = 'a' * 50; // 50 character password
        final longPasswordParams = RegisterUsecaseParams(
          fullName: testFullName,
          email: testEmail,
          phone: testPhone,
          password: longPassword,
          confirmPassword: longPassword,
        );

        when(
          () => mockAuthRepository.registerUser(any()),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await registerUsecase(longPasswordParams);

        // Assert
        expect(result, const Right(true));
      });

      test('should handle different phone number formats', () async {
        // Arrange
        final differentPhoneParams = RegisterUsecaseParams(
          fullName: testFullName,
          email: testEmail,
          phone: '+977-9812345678',
          password: testPassword,
          confirmPassword: testConfirmPassword,
        );

        when(
          () => mockAuthRepository.registerUser(any()),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await registerUsecase(differentPhoneParams);

        // Assert
        expect(result, const Right(true));
      });
    });
  });
}
