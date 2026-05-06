import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/child.dart';
import 'package:health_asistants/data/model/vaccine.dart';
import 'package:health_asistants/data/repository/child_repository.dart';

void main() {
  group('ChildRepository', () {
    late ChildRepository repository;

    setUp(() {
      repository = ChildRepository();
    });

    group('getAll', () {
      test('should return empty list initially', () async {
        final result = await repository.getAll();

        expect(result.isSuccess, true);
        expect(result.data!, isEmpty);
      });
    });

    group('create', () {
      test('should create a child with vaccine schedule', () async {
        final result = await repository.create(
          name: 'Ali',
          birthDate: DateTime(2024, 1, 15),
          gender: ChildGender.male,
        );

        expect(result.isSuccess, true);
        expect(result.data!.name, 'Ali');
        expect(result.data!.gender, ChildGender.male);
        expect(result.data!.id, isNotEmpty);
      });

      test('should auto-generate vaccine schedule', () async {
        final result = await repository.create(
          name: 'Ayşe',
          birthDate: DateTime(2024, 6, 1),
          gender: ChildGender.female,
        );

        expect(result.isSuccess, true);
        expect(result.data!.vaccineSchedule, isNotEmpty);
      });

      test('should include child in getAll after creation', () async {
        await repository.create(
          name: 'Mehmet',
          birthDate: DateTime(2023, 1, 1),
          gender: ChildGender.male,
        );

        final allResult = await repository.getAll();
        expect(allResult.data!.length, 1);
        expect(allResult.data!.first.name, 'Mehmet');
      });

      test('should create multiple children', () async {
        await repository.create(
          name: 'Child 1',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
        );
        await repository.create(
          name: 'Child 2',
          birthDate: DateTime(2023, 6, 1),
          gender: ChildGender.female,
        );

        final allResult = await repository.getAll();
        expect(allResult.data!.length, 2);
      });
    });

    group('getById', () {
      test('should return child for valid id', () async {
        final createResult = await repository.create(
          name: 'Test',
          birthDate: DateTime(2024, 3, 1),
          gender: ChildGender.male,
        );
        final childId = createResult.data!.id;

        final result = await repository.getById(childId);

        expect(result.isSuccess, true);
        expect(result.data!.id, childId);
        expect(result.data!.name, 'Test');
      });

      test('should return failure for non-existent id', () async {
        final result = await repository.getById('non_existent');

        expect(result.isSuccess, false);
      });
    });

    group('update', () {
      test('should update existing child', () async {
        final createResult = await repository.create(
          name: 'Original',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
        );
        final child = createResult.data!;

        final updated = child.copyWith(name: 'Updated Name');
        final result = await repository.update(updated);

        expect(result.isSuccess, true);
        expect(result.data!.name, 'Updated Name');
      });

      test('should return failure for non-existent child', () async {
        final child = Child(
          id: 'non_existent',
          name: 'Test',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
          vaccineSchedule: [],
        );

        final result = await repository.update(child);

        expect(result.isSuccess, false);
        expect(result.error, 'Çocuk bulunamadı');
      });
    });

    group('delete', () {
      test('should delete existing child', () async {
        final createResult = await repository.create(
          name: 'To Delete',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.female,
        );
        final childId = createResult.data!.id;

        final result = await repository.delete(childId);

        expect(result.isSuccess, true);

        final allResult = await repository.getAll();
        expect(allResult.data!, isEmpty);
      });

      test('should succeed for non-existent id', () async {
        final result = await repository.delete('non_existent');
        expect(result.isSuccess, true);
      });
    });

    group('updateVaccineStatus', () {
      test('should update vaccine status to completed', () async {
        final createResult = await repository.create(
          name: 'Vaccine Test',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
        );
        final child = createResult.data!;
        final scheduleId = child.vaccineSchedule.first.id;
        final vaccineId = child.vaccineSchedule.first.vaccines.first.id;

        final result = await repository.updateVaccineStatus(
          child.id,
          scheduleId,
          vaccineId,
          VaccineStatus.completed,
        );

        expect(result.isSuccess, true);

        final updatedSchedule = result.data!.vaccineSchedule.firstWhere(
          (s) => s.id == scheduleId,
        );
        final updatedVaccine = updatedSchedule.vaccines.firstWhere(
          (v) => v.id == vaccineId,
        );
        expect(updatedVaccine.status, VaccineStatus.completed);
        expect(updatedVaccine.completedDate, isNotNull);
      });

      test('should return failure for non-existent child', () async {
        final result = await repository.updateVaccineStatus(
          'non_existent',
          'schedule_id',
          'vaccine_id',
          VaccineStatus.completed,
        );

        expect(result.isSuccess, false);
        expect(result.error, 'Çocuk bulunamadı');
      });
    });

    group('addManualVaccine', () {
      test('should add vaccine to existing schedule', () async {
        final createResult = await repository.create(
          name: 'Manual Vaccine Test',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.female,
        );
        final child = createResult.data!;
        final scheduleId = child.vaccineSchedule.first.id;
        final initialVaccineCount = child.vaccineSchedule.first.vaccines.length;

        final newVaccine = Vaccine(
          id: '',
          childId: child.id,
          name: 'Manuel Aşı',
          dose: '1. Doz',
          date: DateTime.now(),
          status: VaccineStatus.pending,
        );

        final result = await repository.addManualVaccine(
          child.id,
          scheduleId,
          newVaccine,
        );

        expect(result.isSuccess, true);
        final updatedSchedule = result.data!.vaccineSchedule.firstWhere(
          (s) => s.id == scheduleId,
        );
        expect(updatedSchedule.vaccines.length, initialVaccineCount + 1);
      });

      test('should return failure for non-existent child', () async {
        final vaccine = Vaccine(
          id: '',
          childId: 'non_existent',
          name: 'Test',
          dose: '1',
          date: DateTime.now(),
          status: VaccineStatus.pending,
        );

        final result = await repository.addManualVaccine(
          'non_existent',
          'schedule_id',
          vaccine,
        );

        expect(result.isSuccess, false);
      });
    });

    group('deleteVaccine', () {
      test('should delete vaccine from schedule', () async {
        final createResult = await repository.create(
          name: 'Delete Vaccine Test',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
        );
        final child = createResult.data!;
        final scheduleId = child.vaccineSchedule.first.id;
        final vaccineId = child.vaccineSchedule.first.vaccines.first.id;
        final initialCount = child.vaccineSchedule.first.vaccines.length;

        final result = await repository.deleteVaccine(
          child.id,
          scheduleId,
          vaccineId,
        );

        expect(result.isSuccess, true);
        final updatedSchedule = result.data!.vaccineSchedule.firstWhere(
          (s) => s.id == scheduleId,
        );
        expect(updatedSchedule.vaccines.length, initialCount - 1);
      });

      test('should return failure for non-existent child', () async {
        final result = await repository.deleteVaccine(
          'non_existent',
          'schedule_id',
          'vaccine_id',
        );

        expect(result.isSuccess, false);
      });
    });

    group('vaccine schedule generation', () {
      test('schedule should contain expected periods', () async {
        final result = await repository.create(
          name: 'Schedule Test',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
        );

        final schedule = result.data!.vaccineSchedule;
        final periods = schedule.map((s) => s.period).toList();

        expect(periods, contains('Doğumda'));
        expect(periods, contains('1. Ay Sonu'));
        expect(periods, contains('2. Ay Sonu'));
      });

      test('first schedule should contain Hepatit B', () async {
        final result = await repository.create(
          name: 'HepB Test',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.female,
        );

        final firstSchedule = result.data!.vaccineSchedule.first;
        final vaccineNames = firstSchedule.vaccines.map((v) => v.name).toList();

        expect(vaccineNames, contains('Hepatit B'));
      });
    });
  });
}
