import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/vaccine.dart';

void main() {
  group('VaccineStatus Enum', () {
    test('should have correct labels', () {
      expect(VaccineStatus.pending.label, 'Bekliyor');
      expect(VaccineStatus.completed.label, 'Tamamlandı');
      expect(VaccineStatus.overdue.label, 'Gecikmiş');
      expect(VaccineStatus.skipped.label, 'Atlandı');
    });

    test('fromString should return correct status', () {
      expect(VaccineStatus.fromString('pending'), VaccineStatus.pending);
      expect(VaccineStatus.fromString('completed'), VaccineStatus.completed);
      expect(VaccineStatus.fromString('overdue'), VaccineStatus.overdue);
      expect(VaccineStatus.fromString('skipped'), VaccineStatus.skipped);
    });

    test('fromString should return pending for unknown value', () {
      expect(VaccineStatus.fromString('unknown'), VaccineStatus.pending);
    });
  });

  group('Vaccine Model', () {
    late Vaccine vaccine;

    setUp(() {
      vaccine = Vaccine(
        id: 'vac_1',
        name: 'Hepatit B',
        date: DateTime(2024, 6, 1),
        dose: '1. Doz',
        status: VaccineStatus.completed,
        description: 'İlk doz',
        nextDoseDate: DateTime(2024, 7, 1),
        completedDate: DateTime(2024, 6, 1),
        childId: 'child_1',
      );
    });

    test('should create Vaccine with all fields', () {
      expect(vaccine.id, 'vac_1');
      expect(vaccine.name, 'Hepatit B');
      expect(vaccine.dose, '1. Doz');
      expect(vaccine.status, VaccineStatus.completed);
      expect(vaccine.description, 'İlk doz');
      expect(vaccine.childId, 'child_1');
    });

    test('should have default status as pending', () {
      final simpleVaccine = Vaccine(
        id: 'vac_2',
        name: 'BCG',
        date: DateTime(2024, 6, 1),
        dose: '1. Doz',
      );

      expect(simpleVaccine.status, VaccineStatus.pending);
      expect(simpleVaccine.description, isNull);
      expect(simpleVaccine.nextDoseDate, isNull);
      expect(simpleVaccine.completedDate, isNull);
      expect(simpleVaccine.childId, isNull);
    });

    test('isCompleted should return true for completed vaccines', () {
      expect(vaccine.isCompleted, true);

      final pendingVaccine = Vaccine(
        id: 'vac_3',
        name: 'Test',
        date: DateTime(2024, 6, 1),
        dose: '1. Doz',
        status: VaccineStatus.pending,
      );
      expect(pendingVaccine.isCompleted, false);
    });

    test('isOverdue should return true for past pending vaccines', () {
      final overdueVaccine = Vaccine(
        id: 'vac_4',
        name: 'Test',
        date: DateTime(2020, 1, 1), // Past date
        dose: '1. Doz',
        status: VaccineStatus.pending,
      );
      expect(overdueVaccine.isOverdue, true);

      // Completed vaccines should not be overdue
      final completedVaccine = Vaccine(
        id: 'vac_5',
        name: 'Test',
        date: DateTime(2020, 1, 1),
        dose: '1. Doz',
        status: VaccineStatus.completed,
      );
      expect(completedVaccine.isOverdue, false);
    });

    test('copyWith should return new instance with updated fields', () {
      final updated = vaccine.copyWith(
        name: 'Hepatit A',
        status: VaccineStatus.pending,
      );

      expect(updated.name, 'Hepatit A');
      expect(updated.status, VaccineStatus.pending);
      expect(updated.id, vaccine.id);
      expect(updated.dose, vaccine.dose);
      expect(updated.childId, vaccine.childId);
    });

    test('should create Vaccine from JSON', () {
      final json = {
        'id': 'vac_1',
        'name': 'Hepatit B',
        'date': '2024-06-01T00:00:00.000',
        'dose': '1. Doz',
        'status': 'completed',
        'description': 'İlk doz',
        'nextDoseDate': '2024-07-01T00:00:00.000',
        'completedDate': '2024-06-01T00:00:00.000',
        'childId': 'child_1',
      };

      final fromJson = Vaccine.fromJson(json);

      expect(fromJson.id, 'vac_1');
      expect(fromJson.name, 'Hepatit B');
      expect(fromJson.status, VaccineStatus.completed);
      expect(fromJson.nextDoseDate, DateTime(2024, 7, 1));
      expect(fromJson.childId, 'child_1');
    });

    test('should handle null optional fields in JSON', () {
      final json = {
        'id': 'vac_2',
        'name': 'BCG',
        'date': '2024-06-01T00:00:00.000',
        'dose': '1. Doz',
      };

      final fromJson = Vaccine.fromJson(json);

      expect(fromJson.status, VaccineStatus.pending);
      expect(fromJson.description, isNull);
      expect(fromJson.nextDoseDate, isNull);
      expect(fromJson.completedDate, isNull);
      expect(fromJson.childId, isNull);
    });

    test('should convert Vaccine to JSON', () {
      final json = vaccine.toJson();

      expect(json['id'], 'vac_1');
      expect(json['name'], 'Hepatit B');
      expect(json['dose'], '1. Doz');
      expect(json['status'], 'completed');
      expect(json['description'], 'İlk doz');
      expect(json['childId'], 'child_1');
    });

    test('should roundtrip JSON conversion', () {
      final json = vaccine.toJson();
      final fromJson = Vaccine.fromJson(json);

      expect(fromJson.id, vaccine.id);
      expect(fromJson.name, vaccine.name);
      expect(fromJson.dose, vaccine.dose);
      expect(fromJson.status, vaccine.status);
      expect(fromJson.childId, vaccine.childId);
    });
  });

  group('BabyVaccineSchedule Model', () {
    late BabyVaccineSchedule schedule;

    setUp(() {
      schedule = BabyVaccineSchedule(
        id: 'sched_1',
        period: 'Doğumda',
        monthIndex: 0,
        scheduledDate: DateTime(2024, 1, 1),
        vaccines: [
          Vaccine(
            id: 'vac_1',
            name: 'Hepatit B',
            date: DateTime(2024, 1, 1),
            dose: '1. Doz',
            status: VaccineStatus.completed,
          ),
          Vaccine(
            id: 'vac_2',
            name: 'BCG',
            date: DateTime(2024, 1, 1),
            dose: '1. Doz',
            status: VaccineStatus.pending,
          ),
        ],
      );
    });

    test('should create BabyVaccineSchedule', () {
      expect(schedule.id, 'sched_1');
      expect(schedule.period, 'Doğumda');
      expect(schedule.monthIndex, 0);
      expect(schedule.vaccines.length, 2);
    });

    test('isAllCompleted should return false when not all completed', () {
      expect(schedule.isAllCompleted, false);
    });

    test('isAllCompleted should return true when all completed', () {
      final allCompletedSchedule = BabyVaccineSchedule(
        id: 'sched_2',
        period: 'Test',
        monthIndex: 0,
        scheduledDate: DateTime(2024, 1, 1),
        vaccines: [
          Vaccine(
            id: 'vac_1',
            name: 'Test1',
            date: DateTime(2024, 1, 1),
            dose: '1. Doz',
            status: VaccineStatus.completed,
          ),
          Vaccine(
            id: 'vac_2',
            name: 'Test2',
            date: DateTime(2024, 1, 1),
            dose: '1. Doz',
            status: VaccineStatus.completed,
          ),
        ],
      );

      expect(allCompletedSchedule.isAllCompleted, true);
    });

    test('completedCount should return correct count', () {
      expect(schedule.completedCount, 1);
    });

    test('pendingCount should return correct count', () {
      expect(schedule.pendingCount, 1);
    });

    test('isPast should return true for past schedules', () {
      final pastSchedule = BabyVaccineSchedule(
        id: 'sched_3',
        period: 'Past',
        monthIndex: 0,
        scheduledDate: DateTime(2020, 1, 1),
        vaccines: [],
      );
      expect(pastSchedule.isPast, true);
    });

    test('should create from JSON', () {
      final json = {
        'id': 'sched_1',
        'period': 'Doğumda',
        'monthIndex': 0,
        'scheduledDate': '2024-01-01T00:00:00.000',
        'vaccines': [
          {
            'id': 'vac_1',
            'name': 'Hepatit B',
            'date': '2024-01-01T00:00:00.000',
            'dose': '1. Doz',
            'status': 'completed',
          },
        ],
      };

      final fromJson = BabyVaccineSchedule.fromJson(json);

      expect(fromJson.id, 'sched_1');
      expect(fromJson.period, 'Doğumda');
      expect(fromJson.vaccines.length, 1);
      expect(fromJson.vaccines.first.name, 'Hepatit B');
    });

    test('should convert to JSON', () {
      final json = schedule.toJson();

      expect(json['id'], 'sched_1');
      expect(json['period'], 'Doğumda');
      expect(json['monthIndex'], 0);
      expect(json['vaccines'], isList);
      expect((json['vaccines'] as List).length, 2);
    });
  });
}
