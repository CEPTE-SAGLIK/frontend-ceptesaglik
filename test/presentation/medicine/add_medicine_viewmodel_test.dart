import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/medicine.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/medicine_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';
import 'package:health_asistants/presentation/medicine/viewmodel/add_medicine_viewmodel.dart';

class _StubMedicineRepository extends MedicineRepository {
  final List<Medicine> _medicines = [];
  int _counter = 0;

  _StubMedicineRepository() : super(userRepository: _DummyUserRepository());

  @override
  Future<Result<Medicine>> create(Medicine medicine) async {
    _counter++;
    final created = medicine.id.isEmpty
        ? medicine.copyWith(id: 'med_$_counter')
        : medicine;
    _medicines.add(created);
    return Result.success(created);
  }

  @override
  Future<Result<Medicine>> update(Medicine medicine) async {
    final index = _medicines.indexWhere((m) => m.id == medicine.id);
    if (index != -1) _medicines[index] = medicine;
    return Result.success(medicine);
  }

  @override
  Future<Result<List<Medicine>>> getAll() async {
    return Result.success(List.from(_medicines));
  }

  @override
  Future<Result<bool>> delete(String id) async {
    _medicines.removeWhere((m) => m.id == id);
    return Result.success(true);
  }
}

class _DummyUserRepository extends UserRepository {}

void main() {
  group('AddMedicineViewModel', () {
    late AddMedicineViewModel viewModel;

    setUp(() {
      viewModel = AddMedicineViewModel(
        medicineRepository: _StubMedicineRepository(),
      );
    });

    test('should start with initial status', () {
      expect(viewModel.status, AddMedicineStatus.initial);
      expect(viewModel.name, '');
      expect(viewModel.frequencyType, FrequencyType.daily);
      expect(viewModel.selectedTime, isNull);
      expect(viewModel.notes, '');
      expect(viewModel.errorMessage, isNull);
    });

    group('isFormValid', () {
      test('should be false when name is empty', () {
        expect(viewModel.isFormValid, false);
      });

      test('should be false when name is only whitespace', () {
        viewModel.updateName('   ');
        expect(viewModel.isFormValid, false);
      });

      test('should be true when name is provided', () {
        viewModel.updateName('Aspirin');
        expect(viewModel.isFormValid, true);
      });
    });

    group('updateName', () {
      test('should update name', () {
        viewModel.updateName('Parol');
        expect(viewModel.name, 'Parol');
      });

      test('should notify listeners', () {
        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        viewModel.updateName('Test');

        expect(notifyCount, 1);
      });
    });

    group('updateFrequency', () {
      test('should update frequency type', () {
        viewModel.updateFrequency(FrequencyType.weekly);
        expect(viewModel.frequencyType, FrequencyType.weekly);
      });
    });

    group('updateTime', () {
      test('should update selected time', () {
        const time = TimeOfDay(hour: 8, minute: 30);
        viewModel.updateTime(time);
        expect(viewModel.selectedTime, time);
      });
    });

    group('updateNotes', () {
      test('should update notes', () {
        viewModel.updateNotes('Test note');
        expect(viewModel.notes, 'Test note');
      });
    });

    group('selectedTimeText', () {
      test('should return --:-- when no time selected', () {
        expect(viewModel.selectedTimeText, '--:--');
      });

      test('should return formatted time', () {
        viewModel.updateTime(const TimeOfDay(hour: 8, minute: 5));
        expect(viewModel.selectedTimeText, '08:05');
      });

      test('should pad single digit hours and minutes', () {
        viewModel.updateTime(const TimeOfDay(hour: 1, minute: 2));
        expect(viewModel.selectedTimeText, '01:02');
      });
    });

    group('frequencyOptions', () {
      test('should return all frequency types', () {
        expect(viewModel.frequencyOptions, FrequencyType.values);
      });
    });

    group('saveMedicine', () {
      test('should return null and set error when form is invalid', () async {
        final result = await viewModel.saveMedicine();

        expect(result, isNull);
        expect(viewModel.status, AddMedicineStatus.error);
        expect(viewModel.errorMessage, isNotNull);
      });

      test('should return medicine when form is valid', () async {
        viewModel.updateName('Aspirin');
        viewModel.updateFrequency(FrequencyType.daily);
        viewModel.updateTime(const TimeOfDay(hour: 8, minute: 0));

        final result = await viewModel.saveMedicine();

        expect(result, isNotNull);
        expect(result!.name, 'Aspirin');
        expect(result.frequencyType, FrequencyType.daily);
        expect(result.id, isNotEmpty);
        expect(viewModel.status, AddMedicineStatus.saved);
      });

      test('should include notes when provided', () async {
        viewModel.updateName('Parol');
        viewModel.updateNotes('After breakfast');

        final result = await viewModel.saveMedicine();

        expect(result, isNotNull);
        expect(result!.notes, 'After breakfast');
      });

      test('should set null notes when empty', () async {
        viewModel.updateName('Parol');
        viewModel.updateNotes('');

        final result = await viewModel.saveMedicine();

        expect(result, isNotNull);
        expect(result!.notes, isNull);
      });

      test('should include reminder time when set', () async {
        viewModel.updateName('Aspirin');
        viewModel.updateTime(const TimeOfDay(hour: 14, minute: 30));

        final result = await viewModel.saveMedicine();

        expect(result!.reminderTimes, isNotEmpty);
        expect(result.reminderTimes.first.hour, 14);
        expect(result.reminderTimes.first.minute, 30);
      });
    });

    group('reset', () {
      test('should reset all fields', () {
        viewModel.updateName('Aspirin');
        viewModel.updateFrequency(FrequencyType.weekly);
        viewModel.updateTime(const TimeOfDay(hour: 8, minute: 0));
        viewModel.updateNotes('Test');

        viewModel.reset();

        expect(viewModel.status, AddMedicineStatus.initial);
        expect(viewModel.name, '');
        expect(viewModel.frequencyType, FrequencyType.daily);
        expect(viewModel.selectedTime, isNull);
        expect(viewModel.notes, '');
        expect(viewModel.errorMessage, isNull);
      });
    });
  });
}
