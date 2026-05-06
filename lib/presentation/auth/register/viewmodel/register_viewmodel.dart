import 'package:flutter/material.dart';
import 'package:health_asistants/data/repository/auth_repository.dart';

enum RegisterStatus { initial, loading, success, error }

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  RegisterViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  // Controllers - View'dan erişilebilir
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State
  RegisterStatus _status = RegisterStatus.initial;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  // Getters
  RegisterStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get acceptedTerms => _acceptedTerms;

  String get name => nameController.text.trim();
  String get email => emailController.text.trim();
  String get password => passwordController.text;
  String get confirmPassword => confirmPasswordController.text;

  List<String> get _nameParts =>
      name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();

  bool get _hasSurname => _nameParts.length >= 2;

  bool get isFormValid =>
      name.isNotEmpty &&
      _hasSurname &&
      email.isNotEmpty &&
      email.contains('@') &&
      password.length >= 6 &&
      password == confirmPassword &&
      _acceptedTerms;

  // Validation
  String? get passwordMatchError {
    if (confirmPassword.isEmpty) return null;
    if (password != confirmPassword) return 'Şifreler eşleşmiyor';
    return null;
  }

  // Actions
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void toggleAcceptedTerms() {
    _acceptedTerms = !_acceptedTerms;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> register() async {
    if (!isFormValid) {
      if (!_acceptedTerms) {
        _errorMessage = 'Kullanım koşullarını kabul etmelisiniz';
      } else if (!_hasSurname) {
        _errorMessage = 'Lütfen ad ve soyad girin';
      } else if (password != confirmPassword) {
        _errorMessage = 'Şifreler eşleşmiyor';
      } else {
        _errorMessage = 'Lütfen tüm alanları doldurun';
      }
      notifyListeners();
      return false;
    }

    _status = RegisterStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // İsim ve soyisimi ayır
      final firstName = _nameParts.first;
      final lastName = _nameParts.sublist(1).join(' ');

      final result = await _authRepository.register(
        name: firstName,
        surname: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (result.isSuccess) {
        _status = RegisterStatus.success;
        notifyListeners();
        return true;
      } else {
        _status = RegisterStatus.error;
        _errorMessage = result.error ?? 'Kayıt başarısız';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = RegisterStatus.error;
      _errorMessage = 'Bir hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    _status = RegisterStatus.initial;
    _errorMessage = null;
    _obscurePassword = true;
    _obscureConfirmPassword = true;
    _acceptedTerms = false;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
