import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://192.168.1.151:5105';
  //static const String baseUrl = 'http://10.0.2.2:5105'; // Emülatör
  String? _authToken;
  String? _refreshToken;

  ApiClient({String? authToken, String? refreshToken})
      : _authToken = authToken,
        _refreshToken = refreshToken;

  void setAuthToken(String? token) => _authToken = token;
  void setRefreshToken(String? token) => _refreshToken = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Refresh token ile yeni access token alır. Başarılıysa true döner.
  Future<bool> _tryRefreshToken() async {
    if (_refreshToken == null) return false;
    try {
      final uri = Uri.parse('$baseUrl${ApiEndpoints.refresh}');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final inner = data['data'] ?? data;
        final newToken = inner['token'] ?? inner['Token'] ??
            inner['accessToken'] ?? inner['AccessToken'];
        if (newToken != null) {
          _authToken = newToken.toString();
          final newRefresh = inner['refreshToken'] ?? inner['RefreshToken'];
          if (newRefresh != null) _refreshToken = newRefresh.toString();
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// GET isteği
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint')
          .replace(queryParameters: queryParams);
      var response = await http.get(uri, headers: _headers);
      if (response.statusCode == 401 && await _tryRefreshToken()) {
        response = await http.get(uri, headers: _headers);
      }
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Bağlantı hatası: $e');
    }
  }

  /// POST isteği
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Object? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final encoded = body != null ? jsonEncode(body) : null;
      var response =
          await http.post(uri, headers: _headers, body: encoded);
      if (response.statusCode == 401 && await _tryRefreshToken()) {
        response = await http.post(uri, headers: _headers, body: encoded);
      }
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Bağlantı hatası: $e');
    }
  }

  /// PUT isteği
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Object? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final encoded = body != null ? jsonEncode(body) : null;
      var response =
          await http.put(uri, headers: _headers, body: encoded);
      if (response.statusCode == 401 && await _tryRefreshToken()) {
        response = await http.put(uri, headers: _headers, body: encoded);
      }
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Bağlantı hatası: $e');
    }
  }

  /// DELETE isteği
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      var response = await http.delete(uri, headers: _headers);
      if (response.statusCode == 401 && await _tryRefreshToken()) {
        response = await http.delete(uri, headers: _headers);
      }
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Bağlantı hatası: $e');
    }
  }

  /// Ortak response handler
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        return ApiResponse.success(null as T);
      }
      final data = jsonDecode(response.body);
      return ApiResponse.success(fromJson != null ? fromJson(data) : data as T);
    } else if (response.statusCode == 401) {
      return ApiResponse.error('Oturum süresi doldu. Lütfen yeniden giriş yapın.');
    } else {
      try {
        final body = jsonDecode(response.body);
        return ApiResponse.error(
          body['message'] ?? body['Message'] ??
              body['error'] ?? body['Error'] ??
              'İstek başarısız: ${response.statusCode}',
        );
      } catch (_) {
        return ApiResponse.error('İstek başarısız: ${response.statusCode}');
      }
    }
  }
}

/// API yanıt wrapper'ı
class ApiResponse<T> {
  final T? data;
  final String? errorMessage;
  final bool isSuccess;

  ApiResponse._({this.data, this.errorMessage, required this.isSuccess});

  factory ApiResponse.success(T data) {
    return ApiResponse._(data: data, isSuccess: true);
  }

  factory ApiResponse.error(String message) {
    return ApiResponse._(errorMessage: message, isSuccess: false);
  }
}

/// API endpoint sabitleri
class ApiEndpoints {
  // Auth
  static const String login = '/api/Auth/login';
  static const String register = '/api/Auth/register';
  static const String refresh = '/api/Auth/refresh';

  // User
  static const String users = '/api/users/profile';
  static const String usersLegacy = '/api/User';

  // Persons
  static const String persons = '/api/Persons';
  static const String personsProfile = '/api/persons/profile';
  static String person(String id) => '/api/Persons/$id';

  // Allergies
  static const String addAllergy = '/api/Allergies';
  static String allergiesByPerson(String personId) =>
      '/api/Allergies/person/$personId';
  static String allergy(String id) => '/api/Allergies/$id';

  // Illnesses
  static const String addIllness = '/api/Illnesses';
  static String illnessesByPerson(String personId) =>
      '/api/Illnesses/person/$personId';
  static String illness(String id) => '/api/Illnesses/$id';
  static const String deleteIllness = '/api/Illnesses/';

  // Reminders
  static const String reminders = '/api/reminders';
  static String reminder(String id) => '/api/reminders/$id';

  // Medicines
  static const String medicines = '/api/medicines';
  static String medicine(String id) => '/api/medicines/$id';

  // Vaccines
  static const String vaccines = '/api/vaccines';
  static String vaccine(String id) => '/api/vaccines/$id';

  // Children
  static const String children = '/api/children';
  static String child(String id) => '/api/children/$id';
  static String childVaccines(String childId) =>
      '/api/children/$childId/vaccines';

  // AI Assistant
  static const String aiAnalyze = '/api/ai/analyze';

  // Notifications
  static const String notifications = '/api/Notifications';
  static String notification(String id) => '/api/Notifications/$id';
}
