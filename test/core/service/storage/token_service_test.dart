import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gamezone_flutter/core/service/storage/token_service.dart';

import 'token_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  group('TokenService Unit Tests', () {
    late TokenService tokenService;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      tokenService = TokenService();
    });

    test('should save token successfully', () async {
      // Arrange
      const testToken = 'test_token_123';
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async {});

      // Act
      await tokenService.saveToken(testToken);

      // Assert
      verify(mockStorage.write(key: 'auth_token', value: testToken)).called(1);
    });

    test('should retrieve token successfully', () async {
      // Arrange
      const testToken = 'test_token_123';
      when(mockStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => testToken);

      // Act
      final result = await tokenService.getToken();

      // Assert
      expect(result, equals(testToken));
      verify(mockStorage.read(key: 'auth_token')).called(1);
    });

    test('should return null when no token exists', () async {
      // Arrange
      when(mockStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => null);

      // Act
      final result = await tokenService.getToken();

      // Assert
      expect(result, isNull);
      verify(mockStorage.read(key: 'auth_token')).called(1);
    });

    test('should remove token successfully', () async {
      // Arrange
      when(mockStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async {});

      // Act
      await tokenService.removeToken();

      // Assert
      verify(mockStorage.delete(key: 'auth_token')).called(1);
    });

    test('should handle storage exceptions gracefully', () async {
      // Arrange
      when(mockStorage.read(key: anyNamed('key')))
          .thenThrow(Exception('Storage error'));

      // Act & Assert
      expect(() async => await tokenService.getToken(), throwsException);
    });
  });
}
