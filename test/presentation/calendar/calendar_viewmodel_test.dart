import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/data/model/user.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/medicine_repository.dart';
import 'package:health_asistants/data/repository/reminder_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';
import 'package:health_asistants/data/repository/vaccine_repository.dart';
import 'package:health_asistants/presentation/calendar/viewmodel/calendar_viewmodel.dart';

class _StubUserRepository extends UserRepository {
  _StubUserRepository() : super(apiClient: ApiClient());
  @override
  Future<Result<User>> getCurrentUser() async => Result.success(User(
        id: 'test-user-id',
        name: 'Test',
        surname: 'User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      ));
}

class _StubMedicineRepository extends MedicineRepository {
  _StubMedicineRepository()
      : super(userRepository: _StubUserRepository());
}

class _StubVaccineRepository extends VaccineRepository {
  _StubVaccineRepository() : super();
}

void main() {
  group('CalendarViewModel', () {
    late CalendarViewModel viewModel;
    late ReminderRepository repository;

    setUp(() {
      repository = ReminderRepository();
      viewModel = CalendarViewModel(
        reminderRepository: repository,
        medicineRepository: _StubMedicineRepository(),
        userRepository: _StubUserRepository(),
        vaccineRepository: _StubVaccineRepository(),
      );
    });

    test('should start with initial status', () {
      expect(viewModel.status, CalendarStatus.initial);
      expect(viewModel.allReminders, isEmpty);
      expect(viewModel.errorMessage, isNull);
    });

    group('eventTypes', () {
      test('should have 4 event types', () {
        expect(viewModel.eventTypes.length, 4);
      });

      test('should contain expected types', () {
        final types = viewModel.eventTypes.map((e) => e.type).toList();
        expect(types, contains(ReminderType.medicine));
        expect(types, contains(ReminderType.vaccine));
        expect(types, contains(ReminderType.appointment));
        expect(types, contains(ReminderType.custom));
      });
    });

    group('selectDay', () {
      test('should update selected and focused day', () {
        final date = DateTime(2025, 6, 15);
        viewModel.selectDay(date, date);

        expect(viewModel.selectedDay, date);
        expect(viewModel.focusedDay, date);
      });
    });

    group('onPageChanged', () {
      test('should update focused day', () {
        final date = DateTime(2025, 7, 1);
        viewModel.onPageChanged(date);

        expect(viewModel.focusedDay, date);
      });
    });

    group('getEventsForDay', () {
      test('should return empty for day with no events', () {
        final farDate = DateTime(1900, 1, 1);
        final events = viewModel.getEventsForDay(farDate);

        expect(events, isEmpty);
      });
    });

    group('selectedDayEvents', () {
      test('should return empty when no events loaded', () {
        expect(viewModel.selectedDayEvents, isEmpty);
      });
    });

    group('getEventColor', () {
      test('should return correct colors for each type', () {
        final medicineColor = viewModel.getEventColor(ReminderType.medicine);
        final vaccineColor = viewModel.getEventColor(ReminderType.vaccine);
        final appointmentColor = viewModel.getEventColor(
          ReminderType.appointment,
        );
        final customColor = viewModel.getEventColor(ReminderType.custom);

        expect(medicineColor, isNotNull);
        expect(vaccineColor, isNotNull);
        expect(appointmentColor, isNotNull);
        expect(customColor, isNotNull);

        final colors = {
          medicineColor,
          vaccineColor,
          appointmentColor,
          customColor,
        };
        expect(colors.length, 4);
      });
    });

    group('getEventTypeLabel', () {
      test('should return correct Turkish labels', () {
        expect(viewModel.getEventTypeLabel(ReminderType.medicine), 'İlaç');
        expect(viewModel.getEventTypeLabel(ReminderType.vaccine), 'Aşı');
        expect(
          viewModel.getEventTypeLabel(ReminderType.appointment),
          'Randevu',
        );
        expect(viewModel.getEventTypeLabel(ReminderType.custom), 'Genel');
      });
    });
  });
}
