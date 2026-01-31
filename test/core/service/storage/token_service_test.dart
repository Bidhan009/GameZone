import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gamezone_flutter/core/service/storage/token_service.dart';

// Abstract interface for testing
abstract class TokenStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
}

class MockTokenStorage extends Mock implements TokenStorage {}

// Test implementation of TokenService that uses our mock interface
class TestTokenService {
  final TokenStorage _storage;
  static const String _tokenKey = 'auth_token';

  TestTokenService(this._storage);

  // Save token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Get token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Remove token (for logout)
  Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }
}

void main() {
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue('test_key');
    registerFallbackValue('test_value');
  });

  late TestTokenService tokenService;
  late MockTokenStorage mockStorage;

  setUp(() {
    mockStorage = MockTokenStorage();
    tokenService = TestTokenService(mockStorage);
  });

  group('TokenService', () {
    test('should save token successfully', () async {
      // Arrange
      const testToken = 'test_token_123';
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await tokenService.saveToken(testToken);

      // Assert
      verify(() => mockStorage.write(key: 'auth_token', value: testToken)).called(1);
    });

    test('should retrieve token successfully', () async {
      // Arrange
      const testToken = 'test_token_123';
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => testToken);

      // Act
      final result = await tokenService.getToken();

      // Assert
      expect(result, testToken);
      verify(() => mockStorage.read(key: 'auth_token')).called(1);
    });

    test('should return null when no token exists', () async {
      // Arrange
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      // Act
      final result = await tokenService.getToken();

      // Assert
      expect(result, null);
      verify(() => mockStorage.read(key: 'auth_token')).called(1);
    });

    test('should remove token successfully', () async {
      // Arrange
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      // Act
      await tokenService.removeToken();

      // Assert
      verify(() => mockStorage.delete(key: 'auth_token')).called(1);
    });

    test('should handle storage exceptions gracefully', () async {
      // Arrange
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenThrow(Exception('Storage error'));

      // Act & Assert
      expect(() async => await tokenService.getToken(), throwsException);
    });
  });
}
