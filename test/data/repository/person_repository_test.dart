import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/model/user.dart';
import 'package:health_asistants/data/repository/auth_repository.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/person_repository.dart';

class _ErrorResponse {
  final String message;
  _ErrorResponse(this.message);
}

class FakeApiClient extends ApiClient {
  final List<dynamic> queuedGetResponses = [];
  final List<dynamic> queuedPostResponses = [];
  final List<dynamic> queuedPutResponses = [];

  int getCallCount = 0;
  int postCallCount = 0;
  int putCallCount = 0;

  String? lastGetEndpoint;
  String? lastPostEndpoint;
  String? lastPutEndpoint;
  Map<String, dynamic>? lastPostBody;
  Map<String, dynamic>? lastPutBody;

  FakeApiClient() : super();

  @override
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    getCallCount++;
    lastGetEndpoint = endpoint;
    if (queuedGetResponses.isEmpty) {
      return ApiResponse.error('No queued GET response');
    }
    final next = queuedGetResponses.removeAt(0);
    return _buildResponse(next, fromJson);
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Object? body,
    T Function(dynamic)? fromJson,
  }) async {
    postCallCount++;
    lastPostEndpoint = endpoint;
    lastPostBody = body as Map<String, dynamic>?;
    if (queuedPostResponses.isEmpty) {
      return ApiResponse.error('No queued POST response');
    }
    final next = queuedPostResponses.removeAt(0);
    return _buildResponse(next, fromJson);
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Object? body,
    T Function(dynamic)? fromJson,
  }) async {
    putCallCount++;
    lastPutEndpoint = endpoint;
    lastPutBody = body as Map<String, dynamic>?;
    if (queuedPutResponses.isEmpty) {
      return ApiResponse.error('No queued PUT response');
    }
    final next = queuedPutResponses.removeAt(0);
    return _buildResponse(next, fromJson);
  }

  ApiResponse<T> _buildResponse<T>(
    dynamic payload,
    T Function(dynamic)? fromJson,
  ) {
    if (payload is _ErrorResponse) {
      return ApiResponse.error(payload.message);
    }

    final parsed = fromJson != null ? fromJson(payload) : payload as T;
    return ApiResponse.success(parsed);
  }
}

class FakeAuthRepository extends AuthRepository {
  int loadSavedTokensCalls = 0;
  int refreshCalls = 0;
  bool refreshShouldSucceed;

  FakeAuthRepository({
    required ApiClient apiClient,
    this.refreshShouldSucceed = true,
  }) : super(apiClient: apiClient);

  @override
  Future<void> loadSavedTokens() async {
    loadSavedTokensCalls++;
  }

  @override
  Future<Result<User>> refreshAuthToken() async {
    refreshCalls++;
    if (refreshShouldSucceed) {
      return Result.success(
        User(
          id: 'user_1',
          name: 'Test',
          surname: 'User',
          email: 'test@example.com',
          createdAt: DateTime(2026, 3, 5),
        ),
      );
    }
    return Result.failure('Refresh failed');
  }
}

void main() {
  group('PersonRepository', () {
    late FakeApiClient fakeApiClient;
    late FakeAuthRepository fakeAuthRepository;
    late PersonRepository repository;

    setUp(() {
      fakeApiClient = FakeApiClient();
      fakeAuthRepository = FakeAuthRepository(apiClient: fakeApiClient);
      repository = PersonRepository(
        apiClient: fakeApiClient,
        authRepository: fakeAuthRepository,
      );
    });

    test(
      'createPerson should call POST /api/Persons with expected payload',
      () async {
        fakeApiClient.queuedPostResponses.add({
          'id': 'person_1',
          'userId': 'user_1',
          'name': 'Rumeysa',
          'surname': 'Semiz',
          'birthDate': '2000-01-01T00:00:00Z',
          'gender': 'Female',
          'height': 165,
          'weight': 55,
          'createdAt': '2026-03-05T10:00:00Z',
        });

        final result = await repository.createPerson(
          name: 'Rumeysa',
          surname: 'Semiz',
          birthDate: DateTime.parse('2000-01-01T00:00:00Z'),
          gender: Gender.female,
          height: 165,
          weight: 55,
        );

        expect(result.isSuccess, true);
        expect(fakeApiClient.lastPostEndpoint, ApiEndpoints.persons);
        expect(fakeApiClient.lastPostBody?['name'], 'Rumeysa');
        expect(fakeApiClient.lastPostBody?['gender'], 'Female');
        expect(result.data?.createdAt, DateTime.parse('2026-03-05T10:00:00Z'));
      },
    );

    test('getMyPersons should parse person list', () async {
      fakeApiClient.queuedGetResponses.add([
        {
          'id': 'person_1',
          'userId': 'user_1',
          'name': 'Rumeysa',
          'surname': 'Semiz',
          'birthDate': '2000-01-01T00:00:00Z',
          'gender': 'Female',
          'height': 165,
          'weight': 55,
          'createdAt': '2026-03-05T10:00:00Z',
        },
      ]);

      final result = await repository.getMyPersons();

      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      expect(result.data!.length, 1);
      expect(result.data!.first.name, 'Rumeysa');
      expect(fakeApiClient.lastGetEndpoint, ApiEndpoints.persons);
    });

    test('getPersonById should call /api/Persons/{id}', () async {
      fakeApiClient.queuedGetResponses.add({
        'id': 'person_22',
        'userId': 'user_1',
        'name': 'Ali',
        'surname': 'Veli',
        'birthDate': '2001-01-01T00:00:00Z',
        'gender': 'Male',
      });

      final result = await repository.getPersonById('person_22');

      expect(result.isSuccess, true);
      expect(fakeApiClient.lastGetEndpoint, ApiEndpoints.person('person_22'));
      expect(result.data?.id, 'person_22');
      expect(result.data?.gender, Gender.male);
    });

    test('updatePerson should send only changed fields', () async {
      fakeApiClient.queuedPutResponses.add({
        'id': 'person_22',
        'userId': 'user_1',
        'name': 'Rumeysa Updated',
        'surname': 'Semiz',
        'birthDate': '2000-01-01T00:00:00Z',
        'gender': 'Female',
        'weight': 56,
      });

      final result = await repository.updatePerson(
        'person_22',
        name: 'Rumeysa Updated',
        weight: 56,
      );

      expect(result.isSuccess, true);
      expect(fakeApiClient.lastPutEndpoint, ApiEndpoints.person('person_22'));
      expect(fakeApiClient.lastPutBody?.length, 2);
      expect(fakeApiClient.lastPutBody?['name'], 'Rumeysa Updated');
      expect(fakeApiClient.lastPutBody?['weight'], 56);
    });

    test('updatePerson should fail when no field provided', () async {
      final result = await repository.updatePerson('person_22');

      expect(result.isSuccess, false);
      expect(result.error, 'Güncellenecek en az bir alan gönderilmelidir');
    });

    test('should refresh token and retry once on 401', () async {
      fakeApiClient.queuedGetResponses.add(
        _ErrorResponse('Oturum süresi doldu'),
      );
      fakeApiClient.queuedGetResponses.add([
        {
          'id': 'person_1',
          'userId': 'user_1',
          'name': 'Rumeysa',
          'surname': 'Semiz',
          'birthDate': '2000-01-01T00:00:00Z',
          'gender': 'Female',
        },
      ]);

      final result = await repository.getMyPersons();

      expect(result.isSuccess, true);
      expect(fakeApiClient.getCallCount, 2);
      expect(fakeAuthRepository.loadSavedTokensCalls, 1);
      expect(fakeAuthRepository.refreshCalls, 1);
    });

    test('should return 401 error when refresh fails', () async {
      fakeAuthRepository.refreshShouldSucceed = false;
      fakeApiClient.queuedGetResponses.add(
        _ErrorResponse('Oturum süresi doldu'),
      );

      final result = await repository.getMyPersons();

      expect(result.isSuccess, false);
      expect(result.error, 'Oturum süresi doldu');
      expect(fakeApiClient.getCallCount, 1);
      expect(fakeAuthRepository.refreshCalls, 1);
    });
  });
}
