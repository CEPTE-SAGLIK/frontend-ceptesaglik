import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/repository/auth_repository.dart';
import 'package:health_asistants/data/repository/base_repository.dart';

/// Person repository - backend API entegrasyonu
class PersonRepository extends BaseRepository {
  static const String _unauthorizedMessage = 'Oturum süresi doldu';

  late final AuthRepository _authRepository;

  PersonRepository({ApiClient? apiClient, AuthRepository? authRepository})
    : super(apiClient: apiClient ?? authRepository?.apiClient) {
    _authRepository =
        authRepository ?? AuthRepository(apiClient: this.apiClient);
  }

  /// İlk profil oluşturma (Kullanıcı kayıt sonrası - ProfileEntrance)
  Future<Result<Person>> createInitialProfile({
    DateTime? birthDate,
    required Gender gender,
    required double height,
    required double weight,
    required List<String> illnesses,
    required List<String> allergies,
  }) async {
    try {
      final body = <String, dynamic>{
        if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
        'gender': _genderToApiValue(gender),
        'height': height,
        'weight': weight,
        'illnesses': illnesses,
        'allergies': allergies,
      };

      final response = await _requestWithRefresh(
        () => apiClient.post<Map<String, dynamic>>(
          ApiEndpoints.personsProfile,
          body: body,
          fromJson: (json) {
            final payload = _extractMapPayload(json);
            if (payload == null) {
              throw Exception('Profil verisi çözümlenemedi');
            }
            return payload;
          },
        ),
      );

      if (response.isSuccess && response.data != null) {
        return Result.success(Person.fromJson(response.data!));
      }

      return Result.failure(response.errorMessage ?? 'Profil oluşturulamadı');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// Person oluştur
  Future<Result<Person>> createPerson({
    required String name,
    required String surname,
    required DateTime birthDate,
    required Gender gender,
    double? height,
    double? weight,
    List<String>? chronicDiseases,
    List<String>? allergies,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'surname': surname,
        'birthDate': birthDate.toIso8601String(),
        'gender': _genderToApiValue(gender),
        if (height != null) 'height': height,
        if (weight != null) 'weight': weight,
        if (chronicDiseases != null) 'chronicDiseases': chronicDiseases,
        if (allergies != null) 'allergies': allergies,
      };

      final response = await _requestWithRefresh(
        () => apiClient.post<Map<String, dynamic>>(
          ApiEndpoints.persons,
          body: body,
          fromJson: (json) {
            final payload = _extractMapPayload(json);
            if (payload == null) {
              throw Exception('Person verisi çözümlenemedi');
            }
            return payload;
          },
        ),
      );

      if (response.isSuccess && response.data != null) {
        return Result.success(Person.fromJson(response.data!));
      }

      return Result.failure(response.errorMessage ?? 'Person oluşturulamadı');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// Giriş yapan kullanıcının person listesi
  Future<Result<List<Person>>> getMyPersons() async {
    try {
      final response = await _requestWithRefresh(
        () => apiClient.get<List<Person>>(
          ApiEndpoints.persons,
          fromJson: (json) {
            final list = _extractListPayload(json);
            if (list == null) {
              throw Exception('Person listesi çözümlenemedi');
            }
            return list
                .map((item) => Person.fromJson(item as Map<String, dynamic>))
                .toList();
          },
        ),
      );

      if (response.isSuccess && response.data != null) {
        return Result.success(response.data!);
      }

      return Result.failure(
        response.errorMessage ?? 'Person listesi alınamadı',
      );
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// Tek person getir
  Future<Result<Person>> getPersonById(String id) async {
    try {
      final response = await _requestWithRefresh(
        () => apiClient.get<Map<String, dynamic>>(
          ApiEndpoints.person(id),
          fromJson: (json) {
            final payload = _extractMapPayload(json);
            if (payload == null) {
              throw Exception('Person verisi çözümlenemedi');
            }
            return payload;
          },
        ),
      );

      if (response.isSuccess && response.data != null) {
        return Result.success(Person.fromJson(response.data!));
      }

      return Result.failure(response.errorMessage ?? 'Person bulunamadı');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// Person güncelle (partial update)
  Future<Result<Person>> updatePerson(
    String id, {
    String? name,
    String? surname,
    DateTime? birthDate,
    Gender? gender,
    double? height,
    double? weight,
  }) async {
    try {
      final body = <String, dynamic>{
        if (name != null) 'name': name,
        if (surname != null) 'surname': surname,
        if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
        if (gender != null) 'gender': _genderToApiValue(gender),
        if (height != null) 'height': height,
        if (weight != null) 'weight': weight,
      };

      if (body.isEmpty) {
        return Result.failure('Güncellenecek en az bir alan gönderilmelidir');
      }

      final response = await _requestWithRefresh(
        () => apiClient.put<Map<String, dynamic>>(
          ApiEndpoints.person(id),
          body: body,
          fromJson: (json) {
            final payload = _extractMapPayload(json);
            if (payload == null) {
              throw Exception('Person verisi çözümlenemedi');
            }
            return payload;
          },
        ),
      );

      if (response.isSuccess && response.data != null) {
        return Result.success(Person.fromJson(response.data!));
      }

      return Result.failure(response.errorMessage ?? 'Person güncellenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<ApiResponse<T>> _requestWithRefresh<T>(
    Future<ApiResponse<T>> Function() request,
  ) async {
    final firstResponse = await request();
    if (!_isUnauthorized(firstResponse)) {
      return firstResponse;
    }

    await _authRepository.loadSavedTokens();
    final refreshResult = await _authRepository.refreshAuthToken();
    if (!refreshResult.isSuccess) {
      return firstResponse;
    }

    return request();
  }

  bool _isUnauthorized(ApiResponse<dynamic> response) {
    return !response.isSuccess && response.errorMessage == _unauthorizedMessage;
  }

  String _genderToApiValue(Gender gender) {
    switch (gender) {
      case Gender.female:
        return 'Female';
      case Gender.male:
        return 'Male';
    }
  }

  Map<String, dynamic>? _extractMapPayload(dynamic json) {
    dynamic payload = json;

    if (payload is Map<String, dynamic> &&
        payload['data'] is Map<String, dynamic>) {
      payload = payload['data'];
    }

    if (payload is Map<String, dynamic> &&
        payload['person'] is Map<String, dynamic>) {
      payload = payload['person'];
    }

    if (payload is! Map<String, dynamic>) {
      return null;
    }

    return payload;
  }

  List<dynamic>? _extractListPayload(dynamic json) {
    dynamic payload = json;

    if (payload is Map<String, dynamic>) {
      if (payload['data'] is List<dynamic>) {
        payload = payload['data'];
      } else if (payload['items'] is List<dynamic>) {
        payload = payload['items'];
      }
    }

    if (payload is! List<dynamic>) {
      return null;
    }

    return payload;
  }
}
