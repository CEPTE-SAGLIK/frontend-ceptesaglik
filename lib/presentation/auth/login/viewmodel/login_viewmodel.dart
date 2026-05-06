import 'package:flutter/material.dart';
import 'package:health_asistants/data/repository/auth_repository.dart';

enum LoginStatus { initial, loading, success, error }

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // Controllers - View'dan erişilebilir
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // State
  LoginStatus _status = LoginStatus.initial;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Getters
  LoginStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;

  String get email => emailController.text.trim();
  String get password => passwordController.text;

  bool get isFormValid =>
      email.isNotEmpty && email.contains('@') && password.length >= 6;

  // Actions
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login() async {
    if (!isFormValid) {
      _errorMessage = 'Lütfen geçerli e-posta ve şifre girin';
      notifyListeners();
      return false;
    }

    _status = LoginStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      if (result.isSuccess) {
        _status = LoginStatus.success;
        notifyListeners();
        return true;
      } else {
        _status = LoginStatus.error;
        _errorMessage = result.error ?? 'Giriş başarısız';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = LoginStatus.error;
      _errorMessage = 'Bir hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      _errorMessage = null;
      final result = await _authRepository.forgotPassword(email: email);
      if (!result.isSuccess) {
        _errorMessage = result.error;
        notifyListeners();
      }
      return result.isSuccess;
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    emailController.clear();
    passwordController.clear();
    _status = LoginStatus.initial;
    _errorMessage = null;
    _obscurePassword = true;
    _rememberMe = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
