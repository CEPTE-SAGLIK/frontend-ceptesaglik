import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/auth_response.dart';
import 'package:health_asistants/data/model/user.dart';
import 'package:health_asistants/data/repository/base_repository.dart';

class AuthRepository extends BaseRepository {
  String? _authToken;
  String? _refreshToken;
  User? _currentUser;

  AuthRepository({super.apiClient});

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

    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        body: {'email': email, 'password': password},
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data!);
        await _saveTokens(authResponse);
        return Result.success(authResponse.user);
      }
      return Result.failure(response.errorMessage ?? 'Giriş başarısız');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

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
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return Result.failure('Geçerli bir e-posta adresi girin');
    }
    if (password.length < 6) {
      return Result.failure('Şifre en az 6 karakter olmalıdır');
    }
    final confirm = confirmPassword ?? password;
    if (password != confirm) {
      return Result.failure('Şifreler eşleşmiyor');
    }

    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        body: {
          'name': name,
          'surname': surname,
          'email': email,
          'password': password,
          'confirmPassword': confirm,
        },
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data!);
        await _saveTokens(authResponse);
        return Result.success(authResponse.user);
      }
      return Result.failure(response.errorMessage ?? 'Kayıt başarısız');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<User>> refreshAuthToken() async {
    try {
      if (_refreshToken == null) {
        return Result.failure('Refresh token bulunamadı');
      }

      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        body: {'refreshToken': _refreshToken},
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data!);
        await _saveTokens(authResponse);
        return Result.success(authResponse.user);
      }
      await logout();
      return Result.failure(
          response.errorMessage ?? 'Oturum süresi doldu, tekrar giriş yapın');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<bool>> forgotPassword({required String email}) async {
    if (email.isEmpty) return Result.failure('E-posta gereklidir');
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return Result.failure('Geçerli bir e-posta adresi girin');
    }
    return Result.failure('Şifremi unuttum özelliği henüz aktif değil');
  }

  Future<Result<bool>> logout() async {
    try {
      _authToken = null;
      _refreshToken = null;
      _currentUser = null;
      apiClient.setAuthToken(null);
      apiClient.setRefreshToken(null);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_surname');
      await prefs.remove('user_email');

      return Result.success(true);
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<void> loadSavedTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    _refreshToken = prefs.getString('refresh_token');

    final userId = prefs.getString('user_id');
    final userName = prefs.getString('user_name');
    final userEmail = prefs.getString('user_email');

    if (userId != null && userName != null && userEmail != null) {
      _currentUser = User(
        id: userId,
        name: userName,
        surname: prefs.getString('user_surname') ?? '',
        email: userEmail,
        createdAt: DateTime.now(),
      );
    }

    if (_authToken != null) {
      apiClient.setAuthToken(_authToken);
    }
    if (_refreshToken != null) {
      apiClient.setRefreshToken(_refreshToken);
    }
  }

  Future<void> _saveTokens(AuthResponse authResponse) async {
    _authToken = authResponse.token;
    _refreshToken = authResponse.refreshToken;
    _currentUser = authResponse.user;
    apiClient.setAuthToken(_authToken);
    apiClient.setRefreshToken(_refreshToken);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', _authToken!);
    await prefs.setString('refresh_token', _refreshToken!);
    await prefs.setString('user_id', _currentUser!.id);
    await prefs.setString('user_name', _currentUser!.name);
    await prefs.setString('user_surname', _currentUser!.surname);
    await prefs.setString('user_email', _currentUser!.email);
  }

  bool get isAuthenticated => _authToken != null;
  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  String? get refreshToken => _refreshToken;
}
