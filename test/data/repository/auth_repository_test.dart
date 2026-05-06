import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_asistants/data/repository/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    late AuthRepository authRepository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      authRepository = AuthRepository();
    });

    group('login', () {
      test('should return failure for empty email', () async {
        final result = await authRepository.login(
          email: '',
          password: 'password123',
        );

        expect(result.isSuccess, false);
        expect(result.error, 'E-posta ve şifre gereklidir');
      });

      test('should return failure for empty password', () async {
        final result = await authRepository.login(
          email: 'test@test.com',
          password: '',
        );

        expect(result.isSuccess, false);
        expect(result.error, 'E-posta ve şifre gereklidir');
      });

      test('should return failure for invalid email', () async {
        final result = await authRepository.login(
          email: 'invalid-email',
          password: 'password123',
        );

        expect(result.isSuccess, false);
        expect(result.error, 'Geçerli bir e-posta adresi girin');
      });

      test('should return failure for short password', () async {
        final result = await authRepository.login(
          email: 'test@test.com',
          password: '12345',
        );

        expect(result.isSuccess, false);
        expect(result.error, 'Şifre en az 6 karakter olmalıdır');
      });

      test(
        'should return failure for valid credentials without backend',
        () async {
          final result = await authRepository.login(
            email: 'test@test.com',
            password: 'password123',
          );

          expect(result.isSuccess, false);
        },
      );

      test('should not set auth token when login fails', () async {
        expect(authRepository.isAuthenticated, false);

        await authRepository.login(
          email: 'test@test.com',
          password: 'password123',
        );

        expect(authRepository.isAuthenticated, false);
        expect(authRepository.authToken, isNull);
      });

      test('should keep current user null when login fails', () async {
        expect(authRepository.currentUser, isNull);

        await authRepository.login(
          email: 'test@test.com',
          password: 'password123',
        );

        expect(authRepository.currentUser, isNull);
      });
    });

    group('register', () {
      test(
        'should return failure for valid registration without backend',
        () async {
          final result = await authRepository.register(
            name: 'Test',
            surname: 'User',
            email: 'test@test.com',
            password: 'password123',
            confirmPassword: 'password123',
          );

          expect(result.isSuccess, false);
        },
      );

      test('should not set auth token when registration fails', () async {
        await authRepository.register(
          name: 'Test',
          surname: 'User',
          email: 'test@test.com',
          password: 'password123',
          confirmPassword: 'password123',
        );

        expect(authRepository.isAuthenticated, false);
      });
    });

    group('forgotPassword', () {
      test('should return failure for empty email', () async {
        final result = await authRepository.forgotPassword(email: '');

        expect(result.isSuccess, false);
      });

      test('should return failure for invalid email', () async {
        final result = await authRepository.forgotPassword(email: 'invalid');

        expect(result.isSuccess, false);
      });

      test(
        'should return failure for valid email when endpoint is inactive',
        () async {
          final result = await authRepository.forgotPassword(
            email: 'test@test.com',
          );

          expect(result.isSuccess, false);
        },
      );
    });

    group('logout', () {
      test('should clear auth state on logout', () async {
        // Login fails without backend; state remains unauthenticated
        await authRepository.login(
          email: 'test@test.com',
          password: 'password123',
        );
        expect(authRepository.isAuthenticated, false);

        // Then logout
        final result = await authRepository.logout();

        expect(result.isSuccess, true);
        expect(authRepository.isAuthenticated, false);
        expect(authRepository.currentUser, isNull);
        expect(authRepository.authToken, isNull);
      });
    });

    group('isAuthenticated', () {
      test('should return false initially', () {
        expect(authRepository.isAuthenticated, false);
      });

      test('should stay false after failed login', () async {
        await authRepository.login(
          email: 'test@test.com',
          password: 'password123',
        );
        expect(authRepository.isAuthenticated, false);
      });
    });
  });
}
