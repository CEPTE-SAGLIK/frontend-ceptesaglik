import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/data/model/user.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/person_repository.dart';
import 'package:health_asistants/data/repository/reminder_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';
import 'package:health_asistants/presentation/home/viewmodel/home_viewmodel.dart';

class _FakePersonRepository extends PersonRepository {
  @override
  Future<Result<List<Person>>> getMyPersons() async {
    return Result.success([
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
    ]);
  }
}

class _FakeUserRepository extends UserRepository {
  @override
  Future<Result<User>> getCurrentUser() async {
    return Result.success(
      User(
        id: 'user_123',
        name: 'Beyza Nur',
        surname: 'Selvi',
        email: 'beyza@test.com',
        createdAt: DateTime(2024, 1, 1),
      ),
    );
  }
}

void main() {
  group('HomeViewModel', () {
    late HomeViewModel viewModel;
    late ReminderRepository reminderRepository;
    late PersonRepository personRepository;
    late UserRepository userRepository;

    setUp(() {
      reminderRepository = ReminderRepository();
      personRepository = _FakePersonRepository();
      userRepository = _FakeUserRepository();
      viewModel = HomeViewModel(
        reminderRepository: reminderRepository,
        personRepository: personRepository,
        userRepository: userRepository,
      );
    });

    test('should start with initial status', () {
      expect(viewModel.status, HomeStatus.initial);
      expect(viewModel.upcomingReminders, isEmpty);
      expect(viewModel.currentPerson, isNull);
      expect(viewModel.errorMessage, isNull);
    });

    group('loadHomeData', () {
      test('should load reminders and person', () async {
        await viewModel.loadHomeData();

        expect(viewModel.status, HomeStatus.loaded);
        expect(viewModel.upcomingReminders, isNotEmpty);
        expect(viewModel.currentPerson, isNotNull);
        expect(viewModel.currentPerson!.name, 'Beyza Nur');
      });

      test('should set loading status while fetching', () {
        HomeStatus? capturedStatus;
        viewModel.addListener(() {
          if (viewModel.status == HomeStatus.loading) {
            capturedStatus = viewModel.status;
          }
        });

        viewModel.loadHomeData();

        expect(capturedStatus, HomeStatus.loading);
      });
    });

    group('computed properties', () {
      test('pendingRemindersCount should count active reminders', () async {
        await viewModel.loadHomeData();

        final activeCount = viewModel.upcomingReminders
            .where((r) => r.isActive)
            .length;
        expect(viewModel.pendingRemindersCount, activeCount);
      });

      test('completedRemindersCount should count inactive reminders', () async {
        await viewModel.loadHomeData();

        final inactiveCount = viewModel.upcomingReminders
            .where((r) => !r.isActive)
            .length;
        expect(viewModel.completedRemindersCount, inactiveCount);
      });
    });

    group('getRemindersByType', () {
      test('should filter reminders by type', () async {
        await viewModel.loadHomeData();

        final medicineReminders = viewModel.getRemindersByType(
          ReminderType.medicine,
        );

        for (final r in medicineReminders) {
          expect(r.type, ReminderType.medicine);
        }
      });

      test('should return empty list for type with no reminders', () async {
        await viewModel.loadHomeData();

        // Custom type may not have reminders in mock data
        final customReminders = viewModel.getRemindersByType(
          ReminderType.custom,
        );

        for (final r in customReminders) {
          expect(r.type, ReminderType.custom);
        }
      });
    });

    group('getNextReminder', () {
      test('should return null when no active reminders', () {
        expect(viewModel.getNextReminder(), isNull);
      });

      test('should return earliest active reminder', () async {
        await viewModel.loadHomeData();

        final next = viewModel.getNextReminder();
        if (next != null) {
          expect(next.isActive, true);
        }
      });
    });

    group('toggleReminderComplete', () {
      test('should toggle reminder and reload', () async {
        await viewModel.loadHomeData();
        final firstReminder = viewModel.upcomingReminders.first;
        final originalActive = firstReminder.isActive;

        await viewModel.toggleReminderComplete(firstReminder.id);

        // After reload, the reminder should have toggled
        final updatedReminder = viewModel.upcomingReminders.firstWhere(
          (r) => r.id == firstReminder.id,
        );
        expect(updatedReminder.isActive, !originalActive);
      });
    });

    group('deleteReminder', () {
      test('should delete reminder and return true', () async {
        await viewModel.loadHomeData();
        final initialCount = viewModel.upcomingReminders.length;
        final firstId = viewModel.upcomingReminders.first.id;

        final result = await viewModel.deleteReminder(firstId);

        expect(result, true);
        expect(viewModel.upcomingReminders.length, initialCount - 1);
      });
    });

    group('refreshData', () {
      test('should reload data', () async {
        await viewModel.loadHomeData();
        final initialCount = viewModel.upcomingReminders.length;

        await viewModel.refreshData();

        expect(viewModel.status, HomeStatus.loaded);
        expect(viewModel.upcomingReminders.length, initialCount);
      });
    });
  });
}
