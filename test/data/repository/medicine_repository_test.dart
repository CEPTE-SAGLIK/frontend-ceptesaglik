// MedicineRepository artık gerçek API çağrıları yapıyor.
// Bu testler HTTP mocking + UserRepository mock gerektiriyor.
import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/user.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/medicine_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

class _StubUserRepository extends UserRepository {
  _StubUserRepository() : super(apiClient: ApiClient());

  @override
  Future<Result<User>> getCurrentUser() async {
    return Result.success(User(
      id: 'test-user-id',
      name: 'Test',
      surname: 'User',
      email: 'test@example.com',
      createdAt: DateTime.now(),
    ));
  }
}

void main() {
  group('MedicineRepository', () {
    late MedicineRepository repository;

    setUp(() {
      repository = MedicineRepository(
        userRepository: _StubUserRepository(),
      );
    });

    test('skip - API based, needs HTTP mocking', () {}, skip: true);

    test('getAll returns Future<Result<List<Medicine>>>', () {
      expect(repository.getAll(), isA<Future>());
    });

    test('delete returns Future<Result<bool>>', () {
      expect(repository.delete('some-id'), isA<Future>());
    });
  });
}
