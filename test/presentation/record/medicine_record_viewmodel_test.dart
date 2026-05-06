import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/medicine.dart';
import 'package:health_asistants/data/model/user.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/medicine_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';
import 'package:health_asistants/presentation/record/viewmodel/medicine_record_viewmodel.dart';

class _StubUserRepository extends UserRepository {
  _StubUserRepository() : super(apiClient: ApiClient());
  @override
  Future<Result<User>> getCurrentUser() async => Result.success(User(
        id: 'test-user-id', name: 'Test', surname: 'User',
        email: 'test@example.com', createdAt: DateTime.now()));
}

void main() {
  group('MedicineRecordViewModel', () {
    late MedicineRecordViewModel viewModel;

    setUp(() {
      viewModel = MedicineRecordViewModel(
        medicineRepository: MedicineRepository(userRepository: _StubUserRepository()),
      );
    });

    test('should start with initial status', () {
      expect(viewModel.status, MedicineRecordStatus.initial);
      expect(viewModel.name, '');
      expect(viewModel.usageInstructions, isNull);
      expect(viewModel.frequencyType, FrequencyType.daily);
      expect(viewModel.timesPerDay, 1);
      expect(viewModel.reminderTimes, isEmpty);
      expect(viewModel.endDate, isNull);
      expect(viewModel.notes, isNull);
      expect(viewModel.personId, isNull);
    });

    group('isFormValid', () {
      test('should be false when name is empty', () {
        expect(viewModel.isFormValid, false);
      });

      test('should be true when name is set', () {
        viewModel.setName('Aspirin');
        expect(viewModel.isFormValid, true);
      });
    });

    group('setters', () {
      test('setName should update name', () {
        viewModel.setName('Parol');
        expect(viewModel.name, 'Parol');
      });

      test('setName should not notify if same value', () {
        viewModel.setName('Test');
        int count = 0;
        viewModel.addListener(() => count++);
        viewModel.setName('Test');
        expect(count, 0);
      });

      test('setUsageInstructions should update', () {
        viewModel.setUsageInstructions('After meal');
        expect(viewModel.usageInstructions, 'After meal');
      });

      test('setFrequencyType should update', () {
        viewModel.setFrequencyType(FrequencyType.weekly);
        expect(viewModel.frequencyType, FrequencyType.weekly);
      });

      test('setTimesPerDay should update', () {
        viewModel.setTimesPerDay(3);
        expect(viewModel.timesPerDay, 3);
      });

      test('setTimesPerDay should ignore zero or negative', () {
        viewModel.setTimesPerDay(0);
        expect(viewModel.timesPerDay, 1);

        viewModel.setTimesPerDay(-1);
        expect(viewModel.timesPerDay, 1);
      });

      test('setStartDate should update', () {
        final date = DateTime(2025, 6, 1);
        viewModel.setStartDate(date);
        expect(viewModel.startDate, date);
      });

      test('setEndDate should update', () {
        final date = DateTime(2025, 12, 1);
        viewModel.setEndDate(date);
        expect(viewModel.endDate, date);
      });

      test('setNotes should update', () {
        viewModel.setNotes('Important note');
        expect(viewModel.notes, 'Important note');
      });

      test('setPersonId should update', () {
        viewModel.setPersonId('person_123');
        expect(viewModel.personId, 'person_123');
      });
    });

    group('reminderTimes', () {
      test('addReminderTime should add time', () {
        final time = DateTime(2025, 1, 1, 8, 0);
        viewModel.addReminderTime(time);

        expect(viewModel.reminderTimes.length, 1);
        expect(viewModel.reminderTimes.first, time);
      });

      test('addReminderTime should add multiple times', () {
        viewModel.addReminderTime(DateTime(2025, 1, 1, 8, 0));
        viewModel.addReminderTime(DateTime(2025, 1, 1, 14, 0));
        viewModel.addReminderTime(DateTime(2025, 1, 1, 20, 0));

        expect(viewModel.reminderTimes.length, 3);
      });

      test('removeReminderTime should remove by index', () {
        viewModel.addReminderTime(DateTime(2025, 1, 1, 8, 0));
        viewModel.addReminderTime(DateTime(2025, 1, 1, 14, 0));

        viewModel.removeReminderTime(0);

        expect(viewModel.reminderTimes.length, 1);
      });

      test('removeReminderTime should ignore invalid index', () {
        viewModel.addReminderTime(DateTime(2025, 1, 1, 8, 0));

        viewModel.removeReminderTime(-1);
        viewModel.removeReminderTime(5);

        expect(viewModel.reminderTimes.length, 1);
      });

      test('reminderTimes should be unmodifiable', () {
        viewModel.addReminderTime(DateTime(2025, 1, 1, 8, 0));

        expect(
          () => viewModel.reminderTimes.add(DateTime.now()),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('date text properties', () {
      test('startDateText should format correctly', () {
        viewModel.setStartDate(DateTime(2025, 6, 15));
        expect(viewModel.startDateText, '15/6/2025');
      });

      test('endDateText should show "Belirtilmedi" when null', () {
        expect(viewModel.endDateText, 'Belirtilmedi');
      });

      test('endDateText should format correctly when set', () {
        viewModel.setEndDate(DateTime(2025, 12, 1));
        expect(viewModel.endDateText, '1/12/2025');
      });
    });

    group('frequencyOptions', () {
      test('should return all frequency types', () {
        expect(viewModel.frequencyOptions, FrequencyType.values);
      });
    });

    group('saveMedicine', () {
      test('should return null when form is invalid', () async {
        final result = await viewModel.saveMedicine();

        expect(result, isNull);
        expect(viewModel.errorMessage, isNotNull);
      });

      test('should return medicine when form is valid', () async {
        viewModel.setName('Aspirin');
        viewModel.setFrequencyType(FrequencyType.daily);
        viewModel.setTimesPerDay(2);

        final result = await viewModel.saveMedicine();

        expect(result, isNotNull);
        expect(result!.name, 'Aspirin');
        expect(result.frequencyType, FrequencyType.daily);
        expect(result.timesPerDay, 2);
        expect(result.id, isNotEmpty);
        expect(viewModel.status, MedicineRecordStatus.saved);
      });

      test('should include all fields', () async {
        viewModel.setName('Full Medicine');
        viewModel.setUsageInstructions('After meal');
        viewModel.setFrequencyType(FrequencyType.weekly);
        viewModel.setTimesPerDay(1);
        viewModel.addReminderTime(DateTime(2025, 1, 1, 8, 0));
        viewModel.setEndDate(DateTime(2025, 12, 31));
        viewModel.setNotes('Important');
        viewModel.setPersonId('person_1');

        final result = await viewModel.saveMedicine();

        expect(result!.usageInstructions, 'After meal');
        expect(result.frequencyType, FrequencyType.weekly);
        expect(result.reminderTimes.length, 1);
        expect(result.endDate, isNotNull);
        expect(result.notes, 'Important');
        expect(result.personId, 'person_1');
      });
    });

    group('reset', () {
      test('should reset all fields', () {
        viewModel.setName('Test');
        viewModel.setFrequencyType(FrequencyType.weekly);
        viewModel.setTimesPerDay(3);
        viewModel.addReminderTime(DateTime(2025, 1, 1, 8, 0));
        viewModel.setEndDate(DateTime(2025, 12, 1));
        viewModel.setNotes('Note');
        viewModel.setPersonId('person_1');

        viewModel.reset();

        expect(viewModel.status, MedicineRecordStatus.initial);
        expect(viewModel.name, '');
        expect(viewModel.usageInstructions, isNull);
        expect(viewModel.frequencyType, FrequencyType.daily);
        expect(viewModel.timesPerDay, 1);
        expect(viewModel.reminderTimes, isEmpty);
        expect(viewModel.endDate, isNull);
        expect(viewModel.notes, isNull);
        expect(viewModel.personId, isNull);
      });
    });
  });
}
