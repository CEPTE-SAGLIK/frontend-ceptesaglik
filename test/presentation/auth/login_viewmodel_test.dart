import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_asistants/data/model/user.dart';
import 'package:health_asistants/data/repository/auth_repository.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/presentation/auth/login/viewmodel/login_viewmodel.dart';

class _FakeAuthRepository extends AuthRepository {
  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return Result.failure('E-posta ve şifre gereklidir');
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return Result.failure('Geçerli bir e-posta adresi girin');
    }
    if (password.length < 6) {
      return Result.failure('Şifre en az 6 karakter olmalıdır');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'fake_token');

    return Result.success(
      User(
        id: 'user_1',
        name: 'Beyza',
        surname: 'Selvi',
        email: email,
        createdAt: DateTime(2024, 1, 1),
      ),
    );
  }

  @override
  Future<Result<bool>> forgotPassword({required String email}) async {
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return Result.failure('Geçerli bir e-posta adresi girin');
    }
    return Result.failure('Şifremi unuttum özelliği henüz aktif değil');
  }
}

void main() {
  group('LoginViewModel', () {
    late LoginViewModel viewModel;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      viewModel = LoginViewModel(authRepository: _FakeAuthRepository());
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('should start with initial values', () {
      expect(viewModel.status, LoginStatus.initial);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.obscurePassword, true);
      expect(viewModel.rememberMe, false);
      expect(viewModel.email, isEmpty);
      expect(viewModel.password, isEmpty);
      expect(viewModel.isFormValid, false);
    });

    group('isFormValid', () {
      test('should be false when email is empty', () {
        viewModel.passwordController.text = 'password123';
        expect(viewModel.isFormValid, false);
      });

      test('should be false when email has no @', () {
        viewModel.emailController.text = 'invalidemail';
        viewModel.passwordController.text = 'password123';
        expect(viewModel.isFormValid, false);
      });

      test('should be false when password is less than 6 chars', () {
        viewModel.emailController.text = 'test@test.com';
        viewModel.passwordController.text = '12345';
        expect(viewModel.isFormValid, false);
      });

      test('should be true when email and password are valid', () {
        viewModel.emailController.text = 'test@test.com';
        viewModel.passwordController.text = 'password123';
        expect(viewModel.isFormValid, true);
      });

      test('should trim email whitespace', () {
        viewModel.emailController.text = '  test@test.com  ';
        viewModel.passwordController.text = 'password123';
        expect(viewModel.isFormValid, true);
        expect(viewModel.email, 'test@test.com');
      });
    });

    group('togglePasswordVisibility', () {
      test('should toggle obscurePassword', () {
        expect(viewModel.obscurePassword, true);

        viewModel.togglePasswordVisibility();
        expect(viewModel.obscurePassword, false);

        viewModel.togglePasswordVisibility();
        expect(viewModel.obscurePassword, true);
      });

      test('should notify listeners', () {
        int callCount = 0;
        viewModel.addListener(() => callCount++);

        viewModel.togglePasswordVisibility();
        expect(callCount, 1);
      });
    });

    group('toggleRememberMe', () {
      test('should toggle rememberMe', () {
        expect(viewModel.rememberMe, false);

        viewModel.toggleRememberMe();
        expect(viewModel.rememberMe, true);

        viewModel.toggleRememberMe();
        expect(viewModel.rememberMe, false);
      });

      test('should notify listeners', () {
        int callCount = 0;
        viewModel.addListener(() => callCount++);

        viewModel.toggleRememberMe();
        expect(callCount, 1);
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        // Force an error by logging in with invalid data
        await viewModel.login();
        expect(viewModel.errorMessage, isNotNull);

        viewModel.clearError();
        expect(viewModel.errorMessage, isNull);
      });
    });

    group('login', () {
      test('should return false and set error if form is invalid', () async {
        final result = await viewModel.login();

        expect(result, false);
        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.errorMessage, contains('geçerli'));
      });

      test('should succeed with valid credentials', () async {
        viewModel.emailController.text = 'beyza.selvi@gmail.com';
        viewModel.passwordController.text = 'password123';

        final result = await viewModel.login();

        expect(result, true);
        expect(viewModel.status, LoginStatus.success);
        expect(viewModel.errorMessage, isNull);
      });

      test('should fail with invalid email format', () async {
        viewModel.emailController.text = 'invalidemail';
        viewModel.passwordController.text = 'password123';

        final result = await viewModel.login();

        expect(result, false);
        expect(viewModel.errorMessage, isNotNull);
      });

      test('should set loading status during login', () async {
        viewModel.emailController.text = 'beyza.selvi@gmail.com';
        viewModel.passwordController.text = 'password123';

        LoginStatus? capturedStatus;
        viewModel.addListener(() {
          if (viewModel.status == LoginStatus.loading) {
            capturedStatus = viewModel.status;
          }
        });

        await viewModel.login();

        expect(capturedStatus, LoginStatus.loading);
      });

      test('should save auth_token on success', () async {
        viewModel.emailController.text = 'beyza.selvi@gmail.com';
        viewModel.passwordController.text = 'password123';

        await viewModel.login();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('auth_token'), isNotNull);
      });
    });

    group('forgotPassword', () {
      test(
        'should return false for valid email when endpoint inactive',
        () async {
          final result = await viewModel.forgotPassword(
            'beyza.selvi@gmail.com',
          );
          expect(result, false);
        },
      );

      test('should return false for invalid email', () async {
        final result = await viewModel.forgotPassword('invalidemail');
        expect(result, false);
      });
    });

    group('reset', () {
      test('should reset all state', () async {
        viewModel.emailController.text = 'test@test.com';
        viewModel.passwordController.text = 'password123';
        viewModel.togglePasswordVisibility();
        viewModel.toggleRememberMe();
        await viewModel.login();

        viewModel.reset();

        expect(viewModel.email, isEmpty);
        expect(viewModel.password, isEmpty);
        expect(viewModel.status, LoginStatus.initial);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.obscurePassword, true);
        expect(viewModel.rememberMe, false);
      });
    });
  });
}
