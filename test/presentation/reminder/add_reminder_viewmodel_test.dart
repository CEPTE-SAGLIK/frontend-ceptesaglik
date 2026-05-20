import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/data/model/user.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/reminder_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';
import 'package:health_asistants/presentation/reminder/viewmodel/add_reminder_viewmodel.dart';

class _StubUserRepository extends UserRepository {
  @override
  Future<Result<User>> getCurrentUser() async => Result.success(User(
        id: 'test-user-id',
        name: 'Test',
        surname: 'User',
        email: 'test@example.com',
        createdAt: DateTime(2026, 1, 1)));
}

class _StubReminderRepository extends ReminderRepository {
  @override
  Future<Result<Reminder>> create(Reminder reminder) async {
    return Result.success(reminder);
  }
}

void main() {
  group('AddReminderViewModel', () {
    late AddReminderViewModel viewModel;

    setUp(() {
      viewModel = AddReminderViewModel(
        reminderRepository: _StubReminderRepository(),
        userRepository: _StubUserRepository(),
      );
    });

    test('should start with initial status', () {
      expect(viewModel.status, AddReminderStatus.initial);
      expect(viewModel.title, '');
      expect(viewModel.description, isNull);
      expect(viewModel.selectedTime, isNull);
      expect(viewModel.repeatType, RepeatType.none);
      expect(viewModel.selectedTypeIndex, 0);
      expect(viewModel.personId, isNull);
    });

    group('reminderTypes', () {
      test('should have 6 types', () {
        expect(viewModel.reminderTypes.length, 6);
      });

      test('first type should be medicine', () {
        expect(viewModel.reminderTypes.first.type, ReminderType.medicine);
        expect(viewModel.reminderTypes.first.label, 'İlaç');
      });
    });

    group('isFormValid', () {
      test('should be false when title is empty', () {
        expect(viewModel.isFormValid, false);
      });

      test('should be false when time is not selected', () {
        viewModel.setTitle('Test');
        expect(viewModel.isFormValid, false);
      });

      test('should be true when title and time are set', () {
        viewModel.setTitle('Test');
        viewModel.setSelectedTime(const TimeOfDay(hour: 8, minute: 0));
        expect(viewModel.isFormValid, true);
      });
    });

    group('setters', () {
      test('setTitle should update title', () {
        viewModel.setTitle('Hello');
        expect(viewModel.title, 'Hello');
      });

      test('setTitle should not notify if same value', () {
        viewModel.setTitle('Hello');
        int count = 0;
        viewModel.addListener(() => count++);
        viewModel.setTitle('Hello');
        expect(count, 0);
      });

      test('setDescription should update description', () {
        viewModel.setDescription('Desc');
        expect(viewModel.description, 'Desc');
      });

      test('setSelectedTime should update time', () {
        const time = TimeOfDay(hour: 14, minute: 30);
        viewModel.setSelectedTime(time);
        expect(viewModel.selectedTime, time);
      });

      test('setRepeatType should update repeat type', () {
        viewModel.setRepeatType(RepeatType.daily);
        expect(viewModel.repeatType, RepeatType.daily);
      });

      test('setSelectedTypeIndex should update index', () {
        viewModel.setSelectedTypeIndex(2);
        expect(viewModel.selectedTypeIndex, 2);
      });

      test('setSelectedTypeIndex should ignore invalid index', () {
        viewModel.setSelectedTypeIndex(-1);
        expect(viewModel.selectedTypeIndex, 0);

        viewModel.setSelectedTypeIndex(99);
        expect(viewModel.selectedTypeIndex, 0);
      });

      test('setPersonId should update personId', () {
        viewModel.setPersonId('person_1');
        expect(viewModel.personId, 'person_1');
      });
    });

    group('repeatTypeLabel', () {
      test('should return correct labels', () {
        viewModel.setRepeatType(RepeatType.none);
        expect(viewModel.repeatTypeLabel, 'Bir Kez');

        viewModel.setRepeatType(RepeatType.daily);
        expect(viewModel.repeatTypeLabel, 'Her Gün');

        viewModel.setRepeatType(RepeatType.weekly);
        expect(viewModel.repeatTypeLabel, 'Haftalık');

        viewModel.setRepeatType(RepeatType.monthly);
        expect(viewModel.repeatTypeLabel, 'Aylık');
      });
    });

    group('setRepeatTypeFromFrequency', () {
      test('should map daily frequencies', () {
        viewModel.setRepeatTypeFromFrequency('Günde 1 kere');
        expect(viewModel.repeatType, RepeatType.daily);

        viewModel.setRepeatTypeFromFrequency('Günde 2 kere');
        expect(viewModel.repeatType, RepeatType.daily);
      });

      test('should map weekly frequencies', () {
        viewModel.setRepeatTypeFromFrequency('Haftada 1 kere');
        expect(viewModel.repeatType, RepeatType.weekly);
      });

      test('should map monthly frequencies', () {
        viewModel.setRepeatTypeFromFrequency('Ayda 1 kere');
        expect(viewModel.repeatType, RepeatType.monthly);
      });

      test('should default to none for unknown', () {
        viewModel.setRepeatTypeFromFrequency('Unknown');
        expect(viewModel.repeatType, RepeatType.none);
      });

      test('should ignore null', () {
        viewModel.setRepeatType(RepeatType.daily);
        viewModel.setRepeatTypeFromFrequency(null);
        expect(viewModel.repeatType, RepeatType.daily);
      });
    });

    group('selectedReminderType', () {
      test('should return correct type for selected index', () {
        viewModel.setSelectedTypeIndex(0);
        expect(viewModel.selectedReminderType.type, ReminderType.medicine);

        viewModel.setSelectedTypeIndex(1);
        expect(viewModel.selectedReminderType.type, ReminderType.vaccine);

        viewModel.setSelectedTypeIndex(2);
        expect(viewModel.selectedReminderType.type, ReminderType.appointment);
      });
    });

    group('saveReminder', () {
      test('should return null when form is invalid', () async {
        final result = await viewModel.saveReminder();
        expect(result, isNull);
        expect(viewModel.errorMessage, isNotNull);
      });

      test('should return reminder when form is valid', () async {
        viewModel.setTitle('Test Hatırlatma');
        viewModel.setSelectedTime(const TimeOfDay(hour: 10, minute: 0));

        final result = await viewModel.saveReminder();

        expect(result, isNotNull);
        expect(result!.title, 'Test Hatırlatma');
        expect(result.type, ReminderType.medicine); // default index 0
        expect(result.id, isNotEmpty);
        expect(viewModel.status, AddReminderStatus.saved);
      });

      test('should include description when set', () async {
        viewModel.setTitle('Test');
        viewModel.setSelectedTime(const TimeOfDay(hour: 8, minute: 0));
        viewModel.setDescription('Some description');

        final result = await viewModel.saveReminder();

        expect(result!.description, 'Some description');
      });

      test('should use selected repeat type', () async {
        viewModel.setTitle('Daily Reminder');
        viewModel.setSelectedTime(const TimeOfDay(hour: 9, minute: 0));
        viewModel.setRepeatType(RepeatType.daily);

        final result = await viewModel.saveReminder();

        expect(result!.repeatType, RepeatType.daily);
      });
    });

    group('reset', () {
      test('should reset all fields', () {
        viewModel.setTitle('Test');
        viewModel.setDescription('Desc');
        viewModel.setSelectedTime(const TimeOfDay(hour: 8, minute: 0));
        viewModel.setRepeatType(RepeatType.daily);
        viewModel.setSelectedTypeIndex(2);
        viewModel.setPersonId('person_1');

        viewModel.reset();

        expect(viewModel.status, AddReminderStatus.initial);
        expect(viewModel.title, '');
        expect(viewModel.description, isNull);
        expect(viewModel.selectedTime, isNull);
        expect(viewModel.repeatType, RepeatType.none);
        expect(viewModel.selectedTypeIndex, 0);
        expect(viewModel.personId, isNull);
        expect(viewModel.errorMessage, isNull);
      });
    });
  });
}
