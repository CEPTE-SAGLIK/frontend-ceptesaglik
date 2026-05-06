import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/medicine.dart';
import 'package:health_asistants/data/model/user.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/medicine_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';
import 'package:health_asistants/presentation/medicine/viewmodel/medicine_list_viewmodel.dart';

class _StubUserRepository extends UserRepository {
  _StubUserRepository() : super(apiClient: ApiClient());
  @override
  Future<Result<User>> getCurrentUser() async => Result.success(User(
        id: 'test-user-id', name: 'Test', surname: 'User',
        email: 'test@example.com', createdAt: DateTime.now()));
}

void main() {
  group('MedicineListViewModel', () {
    late MedicineListViewModel viewModel;
    late MedicineRepository repository;

    setUp(() {
      repository = MedicineRepository(userRepository: _StubUserRepository());
      viewModel = MedicineListViewModel(repository: repository);
    });

    test('should start with initial status', () {
      expect(viewModel.status, MedicineListStatus.initial);
      expect(viewModel.medicines, isEmpty);
      expect(viewModel.searchQuery, '');
      expect(viewModel.errorMessage, isNull);
    });

    group('loadMedicines', () {
      test('should load medicines from repository', () async {
        await viewModel.loadMedicines();

        expect(viewModel.status, MedicineListStatus.loaded);
        expect(viewModel.medicines, isNotEmpty);
      });

      test('should sort medicines by name', () async {
        await viewModel.loadMedicines();

        final names = viewModel.medicines.map((m) => m.name).toList();
        final sortedNames = List<String>.from(names)..sort();
        expect(names, sortedNames);
      });
    });

    group('search', () {
      test('should filter medicines by name', () async {
        await viewModel.loadMedicines();
        final firstMedicine = viewModel.medicines.first;

        viewModel.search(firstMedicine.name.substring(0, 3));

        expect(viewModel.medicines, isNotEmpty);
        for (final m in viewModel.medicines) {
          expect(
            m.name.toLowerCase().contains(
              firstMedicine.name.substring(0, 3).toLowerCase(),
            ),
            true,
          );
        }
      });

      test('should return all when search query is empty', () async {
        await viewModel.loadMedicines();
        final totalCount = viewModel.medicines.length;

        viewModel.search('Test');
        viewModel.search('');

        expect(viewModel.medicines.length, totalCount);
      });

      test('should return empty for non-matching query', () async {
        await viewModel.loadMedicines();

        viewModel.search('zzzzzzz_nonexistent');

        expect(viewModel.medicines, isEmpty);
      });
    });

    group('activeMedicines / inactiveMedicines', () {
      test('activeMedicines should filter by endDate', () async {
        await viewModel.loadMedicines();

        final active = viewModel.activeMedicines;
        final now = DateTime.now();

        for (final m in active) {
          expect(m.endDate == null || m.endDate!.isAfter(now), true);
        }
      });

      test('inactiveMedicines should filter expired ones', () async {
        await viewModel.loadMedicines();

        final inactive = viewModel.inactiveMedicines;
        final now = DateTime.now();

        for (final m in inactive) {
          expect(m.endDate, isNotNull);
          expect(m.endDate!.isBefore(now), true);
        }
      });
    });

    group('addMedicine', () {
      test('should add medicine and reload', () async {
        await viewModel.loadMedicines();
        final initialCount = viewModel.medicines.length;

        final medicine = Medicine(
          id: '',
          name: 'Yeni İlaç',
          startDate: DateTime.now(),
        );

        final result = await viewModel.addMedicine(medicine);

        expect(result, true);
        expect(viewModel.medicines.length, initialCount + 1);
      });
    });

    group('updateMedicine', () {
      test('should update medicine and reload', () async {
        await viewModel.loadMedicines();
        final first = viewModel.medicines.first;

        final updated = first.copyWith(name: 'Updated');
        final result = await viewModel.updateMedicine(updated);

        expect(result, true);
        expect(viewModel.medicines.any((m) => m.name == 'Updated'), true);
      });
    });

    group('deleteMedicine', () {
      test('should delete medicine and reload', () async {
        await viewModel.loadMedicines();
        final initialCount = viewModel.medicines.length;
        final firstId = viewModel.medicines.first.id;

        final result = await viewModel.deleteMedicine(firstId);

        expect(result, true);
        expect(viewModel.medicines.length, initialCount - 1);
      });
    });

    group('refresh', () {
      test('should reload data', () async {
        await viewModel.loadMedicines();
        await viewModel.refresh();

        expect(viewModel.status, MedicineListStatus.loaded);
      });
    });
  });
}
