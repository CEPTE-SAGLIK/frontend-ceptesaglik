import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_asistants/data/model/user.dart';
import 'package:health_asistants/data/repository/auth_repository.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/presentation/auth/register/viewmodel/register_viewmodel.dart';

class _FakeAuthRepository extends AuthRepository {
  @override
  Future<Result<User>> register({
    required String name,
    required String surname,
    required String email,
    required String password,
    String? confirmPassword,
  }) async {
    if (name.isEmpty || surname.isEmpty || email.isEmpty || password.isEmpty) {
      return Result.failure('Tüm alanlar gereklidir');
    }
    if (password != confirmPassword) {
      return Result.failure('Şifreler eşleşmiyor');
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
        id: 'user_2',
        name: name,
        surname: surname,
        email: email,
        createdAt: DateTime(2024, 1, 1),
      ),
    );
  }
}

void main() {
  group('RegisterViewModel', () {
    late RegisterViewModel viewModel;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      viewModel = RegisterViewModel(authRepository: _FakeAuthRepository());
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('should start with initial values', () {
      expect(viewModel.status, RegisterStatus.initial);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.obscurePassword, true);
      expect(viewModel.obscureConfirmPassword, true);
      expect(viewModel.acceptedTerms, false);
      expect(viewModel.name, isEmpty);
      expect(viewModel.email, isEmpty);
      expect(viewModel.password, isEmpty);
      expect(viewModel.confirmPassword, isEmpty);
      expect(viewModel.isFormValid, false);
    });

    group('isFormValid', () {
      void fillValidForm() {
        viewModel.nameController.text = 'Beyza Selvi';
        viewModel.emailController.text = 'test@test.com';
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password123';
        viewModel.toggleAcceptedTerms(); // true
      }

      test('should be false when name is empty', () {
        viewModel.emailController.text = 'test@test.com';
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password123';
        viewModel.toggleAcceptedTerms();
        expect(viewModel.isFormValid, false);
      });

      test('should be false when email is empty', () {
        viewModel.nameController.text = 'Test User';
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password123';
        viewModel.toggleAcceptedTerms();
        expect(viewModel.isFormValid, false);
      });

      test('should be false when email has no @', () {
        viewModel.nameController.text = 'Test User';
        viewModel.emailController.text = 'invalidemail';
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password123';
        viewModel.toggleAcceptedTerms();
        expect(viewModel.isFormValid, false);
      });

      test('should be false when password < 6 chars', () {
        viewModel.nameController.text = 'Test User';
        viewModel.emailController.text = 'test@test.com';
        viewModel.passwordController.text = '12345';
        viewModel.confirmPasswordController.text = '12345';
        viewModel.toggleAcceptedTerms();
        expect(viewModel.isFormValid, false);
      });

      test('should be false when passwords dont match', () {
        viewModel.nameController.text = 'Test User';
        viewModel.emailController.text = 'test@test.com';
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password456';
        viewModel.toggleAcceptedTerms();
        expect(viewModel.isFormValid, false);
      });

      test('should be false when terms not accepted', () {
        viewModel.nameController.text = 'Test User';
        viewModel.emailController.text = 'test@test.com';
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password123';
        // not toggling terms
        expect(viewModel.isFormValid, false);
      });

      test('should be true when all fields valid and terms accepted', () {
        fillValidForm();
        expect(viewModel.isFormValid, true);
      });

      test('should trim name and email whitespace', () {
        viewModel.nameController.text = '  Beyza Selvi  ';
        viewModel.emailController.text = '  test@test.com  ';
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password123';
        viewModel.toggleAcceptedTerms();

        expect(viewModel.name, 'Beyza Selvi');
        expect(viewModel.email, 'test@test.com');
        expect(viewModel.isFormValid, true);
      });
    });

    group('passwordMatchError', () {
      test('should be null when confirmPassword is empty', () {
        viewModel.passwordController.text = 'password123';
        expect(viewModel.passwordMatchError, isNull);
      });

      test('should return error when passwords dont match', () {
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password456';
        expect(viewModel.passwordMatchError, 'Şifreler eşleşmiyor');
      });

      test('should be null when passwords match', () {
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password123';
        expect(viewModel.passwordMatchError, isNull);
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

    group('toggleConfirmPasswordVisibility', () {
      test('should toggle obscureConfirmPassword', () {
        expect(viewModel.obscureConfirmPassword, true);

        viewModel.toggleConfirmPasswordVisibility();
        expect(viewModel.obscureConfirmPassword, false);

        viewModel.toggleConfirmPasswordVisibility();
        expect(viewModel.obscureConfirmPassword, true);
      });

      test('should notify listeners', () {
        int callCount = 0;
        viewModel.addListener(() => callCount++);

        viewModel.toggleConfirmPasswordVisibility();
        expect(callCount, 1);
      });
    });

    group('toggleAcceptedTerms', () {
      test('should toggle acceptedTerms', () {
        expect(viewModel.acceptedTerms, false);

        viewModel.toggleAcceptedTerms();
        expect(viewModel.acceptedTerms, true);

        viewModel.toggleAcceptedTerms();
        expect(viewModel.acceptedTerms, false);
      });

      test('should notify listeners', () {
        int callCount = 0;
        viewModel.addListener(() => callCount++);

        viewModel.toggleAcceptedTerms();
        expect(callCount, 1);
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        // Force an error by registering with invalid form
        await viewModel.register();
        expect(viewModel.errorMessage, isNotNull);

        viewModel.clearError();
        expect(viewModel.errorMessage, isNull);
      });
    });

    group('register', () {
      test('should fail when form is invalid', () async {
        final result = await viewModel.register();

        expect(result, false);
        expect(viewModel.errorMessage, isNotNull);
      });

      test('should show terms error when terms not accepted', () async {
        viewModel.nameController.text = 'Test User';
        viewModel.emailController.text = 'test@test.com';
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password123';

        final result = await viewModel.register();

        expect(result, false);
        expect(viewModel.errorMessage, contains('koşullar'));
      });

      test('should show password mismatch error', () async {
        viewModel.nameController.text = 'Test User';
        viewModel.emailController.text = 'test@test.com';
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'different';
        viewModel.toggleAcceptedTerms();

        final result = await viewModel.register();

        expect(result, false);
        expect(viewModel.errorMessage, contains('eşleşmiyor'));
      });

      test('should show generic error when fields are empty', () async {
        viewModel.toggleAcceptedTerms(); // accept terms but fields empty

        final result = await viewModel.register();

        expect(result, false);
        expect(viewModel.errorMessage, contains('ad ve soyad'));
      });

      test('should succeed with valid form', () async {
        viewModel.nameController.text = 'Beyza Selvi';
        viewModel.emailController.text = 'new_user@test.com';
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password123';
        viewModel.toggleAcceptedTerms();

        final result = await viewModel.register();

        expect(result, true);
        expect(viewModel.status, RegisterStatus.success);
        expect(viewModel.errorMessage, isNull);
      });

      test('should set loading status during register', () async {
        viewModel.nameController.text = 'Beyza Selvi';
        viewModel.emailController.text = 'new_user@test.com';
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password123';
        viewModel.toggleAcceptedTerms();

        RegisterStatus? capturedStatus;
        viewModel.addListener(() {
          if (viewModel.status == RegisterStatus.loading) {
            capturedStatus = viewModel.status;
          }
        });

        await viewModel.register();

        expect(capturedStatus, RegisterStatus.loading);
      });

      test('should save auth_token on success', () async {
        viewModel.nameController.text = 'Beyza Selvi';
        viewModel.emailController.text = 'new_user@test.com';
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password123';
        viewModel.toggleAcceptedTerms();

        await viewModel.register();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('auth_token'), isNotNull);
      });

      test('should split name into first and last name', () async {
        viewModel.nameController.text = 'Beyza Nur Selvi';
        viewModel.emailController.text = 'new_user2@test.com';
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password123';
        viewModel.toggleAcceptedTerms();

        final result = await viewModel.register();
        // Should succeed even with multi-word name
        expect(result, true);
      });

      test('should handle single word name', () async {
        viewModel.nameController.text = 'Beyza';
        viewModel.emailController.text = 'new_user3@test.com';
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password123';
        viewModel.toggleAcceptedTerms();

        final result = await viewModel.register();
        expect(result, false);
        expect(viewModel.errorMessage, contains('ad ve soyad'));
      });
    });

    group('reset', () {
      test('should reset all state', () async {
        viewModel.nameController.text = 'Test';
        viewModel.emailController.text = 'test@test.com';
        viewModel.passwordController.text = 'password123';
        viewModel.confirmPasswordController.text = 'password123';
        viewModel.togglePasswordVisibility();
        viewModel.toggleConfirmPasswordVisibility();
        viewModel.toggleAcceptedTerms();

        viewModel.reset();

        expect(viewModel.name, isEmpty);
        expect(viewModel.email, isEmpty);
        expect(viewModel.password, isEmpty);
        expect(viewModel.confirmPassword, isEmpty);
        expect(viewModel.status, RegisterStatus.initial);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.obscurePassword, true);
        expect(viewModel.obscureConfirmPassword, true);
        expect(viewModel.acceptedTerms, false);
      });
    });
  });
}
