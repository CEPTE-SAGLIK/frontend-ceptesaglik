import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/data/model/user.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/reminder_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';
import 'package:health_asistants/presentation/reminder/viewmodel/reminder_list_viewmodel.dart';

class _StubUserRepository extends UserRepository {
  _StubUserRepository() : super(apiClient: ApiClient());
  @override
  Future<Result<User>> getCurrentUser() async => Result.success(User(
        id: 'test-user-id', name: 'Test', surname: 'User',
        email: 'test@example.com', createdAt: DateTime.now()));
}

void main() {
  group('ReminderListViewModel', () {
    late ReminderListViewModel viewModel;
    late ReminderRepository repository;

    setUp(() {
      repository = ReminderRepository();
      viewModel = ReminderListViewModel(
        repository: repository,
        userRepository: _StubUserRepository(),
      );
    });

    test('should start with initial status', () {
      expect(viewModel.status, ReminderListStatus.initial);
      expect(viewModel.reminders, isEmpty);
      expect(viewModel.selectedFilter, isNull);
      expect(viewModel.errorMessage, isNull);
    });

    group('loadReminders', () {
      test('should load reminders from repository', () async {
        await viewModel.loadReminders();

        expect(viewModel.status, ReminderListStatus.loaded);
        expect(viewModel.reminders, isNotEmpty);
      });

      test('should sort reminders by dateTime', () async {
        await viewModel.loadReminders();

        final dates = viewModel.reminders.map((r) => r.dateTime).toList();
        for (int i = 0; i < dates.length - 1; i++) {
          expect(dates[i].compareTo(dates[i + 1]), lessThanOrEqualTo(0));
        }
      });
    });

    group('setFilter', () {
      test('should filter by type', () async {
        await viewModel.loadReminders();

        viewModel.setFilter(ReminderType.medicine);

        for (final r in viewModel.reminders) {
          expect(r.type, ReminderType.medicine);
        }
      });

      test('should show all when filter is null', () async {
        await viewModel.loadReminders();
        final totalCount = viewModel.reminders.length;

        viewModel.setFilter(ReminderType.medicine);
        viewModel.setFilter(null);

        expect(viewModel.reminders.length, totalCount);
      });
    });

    group('activeReminders / completedReminders', () {
      test('activeReminders should return only active', () async {
        await viewModel.loadReminders();

        for (final r in viewModel.activeReminders) {
          expect(r.isActive, true);
        }
      });

      test('completedReminders should return only inactive', () async {
        await viewModel.loadReminders();

        for (final r in viewModel.completedReminders) {
          expect(r.isActive, false);
        }
      });

      test('active + completed should equal total', () async {
        await viewModel.loadReminders();

        expect(
          viewModel.activeReminders.length +
              viewModel.completedReminders.length,
          viewModel.reminders.length,
        );
      });
    });

    group('addReminder', () {
      test('should add reminder and reload', () async {
        await viewModel.loadReminders();
        final initialCount = viewModel.reminders.length;

        final reminder = Reminder(
          id: '',
          personId: 'test',
          title: 'Test Reminder',
          type: ReminderType.custom,
          dateTime: DateTime.now(),
          repeatType: RepeatType.none,
          isActive: true,
          createdAt: DateTime.now(),
        );

        final result = await viewModel.addReminder(reminder);

        expect(result, true);
        expect(viewModel.reminders.length, initialCount + 1);
      });
    });

    group('deleteReminder', () {
      test('should delete reminder and reload', () async {
        await viewModel.loadReminders();
        final initialCount = viewModel.reminders.length;
        final firstId = viewModel.reminders.first.id;

        final result = await viewModel.deleteReminder(firstId);

        expect(result, true);
        expect(viewModel.reminders.length, initialCount - 1);
      });
    });

    group('toggleComplete', () {
      test('should toggle reminder active status', () async {
        await viewModel.loadReminders();
        final first = viewModel.reminders.first;
        final originalActive = first.isActive;

        await viewModel.toggleComplete(first.id);

        final updated = viewModel.reminders.firstWhere((r) => r.id == first.id);
        expect(updated.isActive, !originalActive);
      });
    });

    group('refresh', () {
      test('should reload data', () async {
        await viewModel.loadReminders();
        await viewModel.refresh();

        expect(viewModel.status, ReminderListStatus.loaded);
      });
    });
  });
}
