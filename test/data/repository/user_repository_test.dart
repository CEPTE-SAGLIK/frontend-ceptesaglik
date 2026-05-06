import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/user.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/person_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

class _ErrorResponse {
  final String message;

  _ErrorResponse(this.message);
}

class FakeUserApiClient extends ApiClient {
  final List<dynamic> queuedGetResponses = [];
  final List<dynamic> queuedPutResponses = [];

  FakeUserApiClient() : super();

  @override
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    if (queuedGetResponses.isEmpty) {
      return ApiResponse.error('No queued GET response');
    }

    final next = queuedGetResponses.removeAt(0);
    if (next is _ErrorResponse) {
      return ApiResponse.error(next.message);
    }

    final parsed = fromJson != null ? fromJson(next) : next as T;
    return ApiResponse.success(parsed);
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Object? body,
    T Function(dynamic)? fromJson,
  }) async {
    if (queuedPutResponses.isEmpty) {
      return ApiResponse.error('No queued PUT response');
    }

    final next = queuedPutResponses.removeAt(0);
    if (next is _ErrorResponse) {
      return ApiResponse.error(next.message);
    }

    final parsed = fromJson != null ? fromJson(next) : next as T;
    return ApiResponse.success(parsed);
  }
}

class FakePersonRepository extends PersonRepository {
  final List<Person> _persons = [
    Person(
      id: 'person_1',
      userId: 'user_123',
      name: 'Beyza Nur',
      surname: 'Selvi',
      relationship: 'self',
      birthDate: DateTime(1995, 5, 20),
      gender: Gender.female,
      height: 165,
      weight: 58,
    ),
    Person(
      id: 'person_2',
      userId: 'user_123',
      name: 'Elif',
      surname: 'Selvi',
      relationship: 'child',
      birthDate: DateTime(2020, 3, 10),
      gender: Gender.female,
    ),
    Person(
      id: 'person_3',
      userId: 'user_123',
      name: 'Ayşe',
      surname: 'Selvi',
      relationship: 'parent',
      birthDate: DateTime(1960, 8, 5),
      gender: Gender.female,
    ),
  ];

  int _counter = 3;

  @override
  Future<Result<List<Person>>> getMyPersons() async {
    return Result.success(List.from(_persons));
  }

  @override
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
    _counter++;
    final created = Person(
      id: 'person_$_counter',
      userId: 'user_123',
      name: name,
      surname: surname,
      birthDate: birthDate,
      gender: gender,
      height: height,
      weight: weight,
    );
    _persons.add(created);
    return Result.success(created);
  }

  @override
  Future<Result<Person>> updatePerson(
    String id, {
    String? name,
    String? surname,
    DateTime? birthDate,
    Gender? gender,
    double? height,
    double? weight,
  }) async {
    final index = _persons.indexWhere((p) => p.id == id);
    if (index == -1) {
      return Result.failure('Person bulunamadı');
    }

    final current = _persons[index];
    final updated = Person(
      id: current.id,
      userId: current.userId,
      name: name ?? current.name,
      surname: surname ?? current.surname,
      relationship: current.relationship,
      birthDate: birthDate ?? current.birthDate,
      gender: gender ?? current.gender,
      height: height ?? current.height,
      weight: weight ?? current.weight,
      createdAt: current.createdAt,
      illnesses: current.illnesses,
      allergies: current.allergies,
      medicines: current.medicines,
      vaccines: current.vaccines,
    );

    _persons[index] = updated;
    return Result.success(updated);
  }
}

void main() {
  group('UserRepository', () {
    late UserRepository repository;
    late FakePersonRepository fakePersonRepository;
    late FakeUserApiClient fakeUserApiClient;

    setUp(() {
      fakePersonRepository = FakePersonRepository();
      fakeUserApiClient = FakeUserApiClient();
      fakeUserApiClient.queuedGetResponses.add({
        'id': 'user_123',
        'name': 'Beyza Nur',
        'surname': 'Selvi',
        'email': 'beyza.selvi@gmail.com',
        'createdAt': '2024-01-15T00:00:00.000Z',
      });
      fakeUserApiClient.queuedGetResponses.add({
        'id': 'user_123',
        'name': 'Beyza Nur',
        'surname': 'Selvi',
        'email': 'beyza.selvi@gmail.com',
        'createdAt': '2024-01-15T00:00:00.000Z',
      });

      repository = UserRepository(
        apiClient: fakeUserApiClient,
        personRepository: fakePersonRepository,
      );
    });

    group('getCurrentUser', () {
      test('should return user from API on first call', () async {
        final result = await repository.getCurrentUser();

        expect(result.isSuccess, true);
        expect(result.data!.name, 'Beyza Nur');
        expect(result.data!.surname, 'Selvi');
        expect(result.data!.email, 'beyza.selvi@gmail.com');
      });

      test('should return same user on repeated calls', () async {
        final first = await repository.getCurrentUser();
        final second = await repository.getCurrentUser();

        expect(first.data!.id, second.data!.id);
      });
    });

    group('getCurrentPerson', () {
      test('should return mock person on first call', () async {
        final result = await repository.getCurrentPerson();

        expect(result.isSuccess, true);
        expect(result.data!.name, 'Beyza Nur');
        expect(result.data!.gender, Gender.female);
        expect(result.data!.height, 165);
        expect(result.data!.weight, 58);
      });
    });

    group('getFamilyMembers', () {
      test('should return mock family members', () async {
        final result = await repository.getFamilyMembers();

        expect(result.isSuccess, true);
        expect(result.data!.length, 2);
      });

      test('should contain expected family members', () async {
        final result = await repository.getFamilyMembers();
        final names = result.data!.map((p) => p.name).toList();

        expect(names, contains('Elif'));
        expect(names, contains('Ayşe'));
      });
    });

    group('updateUser', () {
      test('should update current user', () async {
        final currentUser = (await repository.getCurrentUser()).data!;
        fakeUserApiClient.queuedPutResponses.add({
          'id': currentUser.id,
          'name': 'Updated Name',
          'surname': currentUser.surname,
          'email': currentUser.email,
          'createdAt': currentUser.createdAt.toIso8601String(),
        });
        fakeUserApiClient.queuedGetResponses.add({
          'id': currentUser.id,
          'name': 'Updated Name',
          'surname': currentUser.surname,
          'email': currentUser.email,
          'createdAt': currentUser.createdAt.toIso8601String(),
        });

        final updated = User(
          id: currentUser.id,
          name: 'Updated Name',
          surname: currentUser.surname,
          email: currentUser.email,
          createdAt: currentUser.createdAt,
        );

        final result = await repository.updateUser(updated);

        expect(result.isSuccess, true);
        expect(result.data!.name, 'Updated Name');

        // Verify persistence
        fakeUserApiClient.queuedGetResponses
          ..clear()
          ..add({
            'id': currentUser.id,
            'name': 'Updated Name',
            'surname': currentUser.surname,
            'email': currentUser.email,
            'createdAt': currentUser.createdAt.toIso8601String(),
          });
        final current = await repository.getCurrentUser();
        expect(current.data!.name, 'Updated Name');
      });
    });

    group('updatePerson', () {
      test('should update current person', () async {
        final currentPerson = (await repository.getCurrentPerson()).data!;
        final updated = Person(
          id: currentPerson.id,
          userId: currentPerson.userId,
          name: currentPerson.name,
          surname: currentPerson.surname,
          relationship: currentPerson.relationship,
          birthDate: currentPerson.birthDate,
          gender: currentPerson.gender,
          height: 170,
          weight: 60,
        );

        final result = await repository.updatePerson(updated);

        expect(result.isSuccess, true);
        expect(result.data!.height, 170);
        expect(result.data!.weight, 60);
      });
    });

    group('addFamilyMember', () {
      test('should add new family member', () async {
        final initialResult = await repository.getFamilyMembers();
        final initialCount = initialResult.data!.length;

        final newMember = Person(
          id: '',
          userId: 'user_123',
          name: 'Yeni Üye',
          surname: 'Selvi',
          relationship: 'sibling',
          birthDate: DateTime(2000, 1, 1),
          gender: Gender.male,
        );

        final result = await repository.addFamilyMember(newMember);

        expect(result.isSuccess, true);
        expect(result.data!.name, 'Yeni Üye');
        expect(result.data!.id, isNotEmpty);

        final afterResult = await repository.getFamilyMembers();
        expect(afterResult.data!.length, initialCount + 1);
      });

      test('should generate id if empty', () async {
        final member = Person(
          id: '',
          userId: 'user_123',
          name: 'No ID',
          surname: 'Test',
          relationship: 'other',
          birthDate: DateTime(1990, 1, 1),
          gender: Gender.female,
        );

        final result = await repository.addFamilyMember(member);

        expect(result.data!.id, isNot(''));
      });

      test('should return backend generated id', () async {
        final member = Person(
          id: 'custom_person_id',
          userId: 'user_123',
          name: 'Custom ID',
          surname: 'Test',
          relationship: 'other',
          birthDate: DateTime(1990, 1, 1),
          gender: Gender.male,
        );

        final result = await repository.addFamilyMember(member);

        expect(result.data!.id, isNot('custom_person_id'));
        expect(result.data!.id, isNotEmpty);
      });
    });

    group('deleteFamilyMember', () {
      test('should fail because delete endpoint is not available', () async {
        final result = await repository.deleteFamilyMember('person_2');

        expect(result.isSuccess, false);
        expect(result.error, 'Person silme endpointi mevcut değil');
      });
    });

    group('logout', () {
      test('should clear all data', () async {
        // Initialize first
        await repository.getCurrentUser();

        final result = await repository.logout();

        expect(result.isSuccess, true);
      });

      test('should reinitialize mock data after logout and re-fetch', () async {
        fakeUserApiClient.queuedGetResponses.add({
          'id': 'user_123',
          'name': 'Beyza Nur',
          'surname': 'Selvi',
          'email': 'beyza.selvi@gmail.com',
          'createdAt': '2024-01-15T00:00:00.000Z',
        });

        await repository.getCurrentUser();
        await repository.logout();

        // After logout, user is fetched from API again
        final result = await repository.getCurrentUser();
        expect(result.isSuccess, true);
        expect(result.data!.name, 'Beyza Nur');
      });
    });
  });
}
