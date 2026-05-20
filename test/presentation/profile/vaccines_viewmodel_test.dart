import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/child.dart';
import 'package:health_asistants/data/model/vaccine.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/child_repository.dart';
import 'package:health_asistants/presentation/profile/viewmodel/vaccines_viewmodel.dart';

class _StubChildRepository extends ChildRepository {
  final List<Child> _children = [];
  int _idCounter = 0;

  @override
  Future<Result<List<Child>>> getAll() async {
    return Result.success(List.from(_children));
  }

  @override
  Future<Result<Child>> getById(String id) async {
    try {
      return Result.success(_children.firstWhere((c) => c.id == id));
    } catch (_) {
      return Result.failure('Çocuk bulunamadı');
    }
  }

  @override
  Future<Result<Child>> create({
    required String name,
    required DateTime birthDate,
    required ChildGender gender,
  }) async {
    _idCounter++;
    final childId = 'child_$_idCounter';
    final scheduleId = 'sched_$_idCounter';
    final vaccineId = 'vacc_$_idCounter';

    final child = Child(
      id: childId,
      name: name,
      birthDate: birthDate,
      gender: gender,
      vaccineSchedule: [
        BabyVaccineSchedule(
          id: scheduleId,
          period: '0. Ay',
          monthIndex: 0,
          scheduledDate: birthDate,
          vaccines: [
            Vaccine(
              id: vaccineId,
              name: 'Hepatit B',
              date: birthDate,
              dose: '1. Doz',
              status: VaccineStatus.pending,
              childId: childId,
            ),
          ],
        ),
      ],
    );
    _children.add(child);
    return Result.success(child);
  }

  @override
  Future<Result<bool>> delete(String id) async {
    _children.removeWhere((c) => c.id == id);
    return Result.success(true);
  }

  @override
  Future<Result<Child>> updateVaccineStatus(
    String childId,
    String scheduleId,
    String vaccineId,
    VaccineStatus status,
  ) async {
    final childIndex = _children.indexWhere((c) => c.id == childId);
    if (childIndex == -1) return Result.failure('Çocuk bulunamadı');

    final child = _children[childIndex];
    final updatedSchedules = child.vaccineSchedule.map((s) {
      if (s.id != scheduleId) return s;
      return BabyVaccineSchedule(
        id: s.id,
        period: s.period,
        monthIndex: s.monthIndex,
        scheduledDate: s.scheduledDate,
        vaccines: s.vaccines
            .map((v) => v.id == vaccineId ? v.copyWith(status: status) : v)
            .toList(),
      );
    }).toList();

    final updated = child.copyWith(vaccineSchedule: updatedSchedules);
    _children[childIndex] = updated;
    return Result.success(updated);
  }

  @override
  Future<Result<Child>> addManualVaccine(
    String childId,
    String scheduleId,
    Vaccine vaccine,
  ) async {
    final childIndex = _children.indexWhere((c) => c.id == childId);
    if (childIndex == -1) return Result.failure('Çocuk bulunamadı');

    final child = _children[childIndex];
    final newVaccineId = 'vacc_manual_${DateTime.now().microsecondsSinceEpoch}';
    final updatedSchedules = child.vaccineSchedule.map((s) {
      if (s.id != scheduleId) return s;
      return BabyVaccineSchedule(
        id: s.id,
        period: s.period,
        monthIndex: s.monthIndex,
        scheduledDate: s.scheduledDate,
        vaccines: [...s.vaccines, vaccine.copyWith(id: newVaccineId)],
      );
    }).toList();

    final updated = child.copyWith(vaccineSchedule: updatedSchedules);
    _children[childIndex] = updated;
    return Result.success(updated);
  }

  @override
  Future<Result<Child>> deleteVaccine(
    String childId,
    String scheduleId,
    String vaccineId,
  ) async {
    final childIndex = _children.indexWhere((c) => c.id == childId);
    if (childIndex == -1) return Result.failure('Çocuk bulunamadı');

    final child = _children[childIndex];
    final updatedSchedules = child.vaccineSchedule.map((s) {
      if (s.id != scheduleId) return s;
      return BabyVaccineSchedule(
        id: s.id,
        period: s.period,
        monthIndex: s.monthIndex,
        scheduledDate: s.scheduledDate,
        vaccines: s.vaccines.where((v) => v.id != vaccineId).toList(),
      );
    }).toList();

    final updated = child.copyWith(vaccineSchedule: updatedSchedules);
    _children[childIndex] = updated;
    return Result.success(updated);
  }
}

void main() {
  group('VaccinesViewModel', () {
    late VaccinesViewModel viewModel;
    late _StubChildRepository childRepository;

    setUp(() {
      childRepository = _StubChildRepository();
      viewModel = VaccinesViewModel(childRepository: childRepository);
    });

    test('should start with initial status', () {
      expect(viewModel.status, VaccineScreenStatus.initial);
      expect(viewModel.children, isEmpty);
      expect(viewModel.hasChildren, false);
      expect(viewModel.selectedChild, isNull);
      expect(viewModel.schedule, isEmpty);
      expect(viewModel.errorMessage, isNull);
    });

    group('loadChildren', () {
      test('should load empty list initially', () async {
        await viewModel.loadChildren();

        expect(viewModel.status, VaccineScreenStatus.loaded);
        expect(viewModel.children, isEmpty);
        expect(viewModel.hasChildren, false);
      });

      test('should load children after adding', () async {
        await childRepository.create(
          name: 'Ali',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
        );

        await viewModel.loadChildren();

        expect(viewModel.children.length, 1);
        expect(viewModel.hasChildren, true);
        expect(viewModel.selectedChild, isNotNull);
      });
    });

    group('addChild', () {
      test('should add child and select it', () async {
        final result = await viewModel.addChild(
          name: 'Ali',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
        );

        expect(result, true);
        expect(viewModel.children.length, 1);
        expect(viewModel.selectedChild, isNotNull);
        expect(viewModel.selectedChild!.name, 'Ali');
      });

      test('should auto-generate vaccine schedule', () async {
        await viewModel.addChild(
          name: 'Ayşe',
          birthDate: DateTime(2024, 6, 1),
          gender: ChildGender.female,
        );

        expect(viewModel.schedule, isNotEmpty);
      });
    });

    group('selectChild', () {
      test('should select correct child', () async {
        await viewModel.addChild(
          name: 'Child 1',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
        );
        await viewModel.addChild(
          name: 'Child 2',
          birthDate: DateTime(2023, 6, 1),
          gender: ChildGender.female,
        );

        final child1 = viewModel.children.firstWhere(
          (c) => c.name == 'Child 1',
        );
        viewModel.selectChild(child1.id);

        expect(viewModel.selectedChild!.name, 'Child 1');
      });
    });

    group('deleteChild', () {
      test('should delete child', () async {
        await viewModel.addChild(
          name: 'To Delete',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
        );
        final childId = viewModel.children.first.id;

        final result = await viewModel.deleteChild(childId);

        expect(result, true);
        expect(viewModel.children, isEmpty);
      });

      test('should clear selectedChild when deleting selected', () async {
        await viewModel.addChild(
          name: 'Test',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
        );
        final childId = viewModel.selectedChild!.id;

        await viewModel.deleteChild(childId);

        expect(viewModel.selectedChild, isNull);
      });
    });

    group('scheduleProgress', () {
      test('should return 0 when no child selected', () {
        expect(viewModel.scheduleProgress, 0);
      });

      test('should return 0 when no vaccines completed', () async {
        await viewModel.addChild(
          name: 'Test',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
        );

        expect(viewModel.scheduleProgress, 0);
      });
    });

    group('toggleVaccineStatus', () {
      test('should toggle vaccine status', () async {
        await viewModel.addChild(
          name: 'Test',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
        );

        final scheduleId = viewModel.schedule.first.id;
        final vaccineId = viewModel.schedule.first.vaccines.first.id;

        final result = await viewModel.toggleVaccineStatus(
          scheduleId,
          vaccineId,
        );

        expect(result, true);

        final updatedSchedule = viewModel.schedule.firstWhere(
          (s) => s.id == scheduleId,
        );
        final updatedVaccine = updatedSchedule.vaccines.firstWhere(
          (v) => v.id == vaccineId,
        );
        expect(updatedVaccine.status, VaccineStatus.completed);
      });

      test('should return false when no child selected', () async {
        final result = await viewModel.toggleVaccineStatus(
          'schedule_id',
          'vaccine_id',
        );

        expect(result, false);
      });
    });

    group('addManualVaccine', () {
      test('should add vaccine to schedule', () async {
        await viewModel.addChild(
          name: 'Test',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
        );

        final scheduleId = viewModel.schedule.first.id;
        final initialCount = viewModel.schedule.first.vaccines.length;

        final vaccine = Vaccine(
          id: '',
          childId: viewModel.selectedChild!.id,
          name: 'Manuel Aşı',
          dose: '1. Doz',
          date: DateTime.now(),
          status: VaccineStatus.pending,
        );

        final result = await viewModel.addManualVaccine(scheduleId, vaccine);

        expect(result, true);

        final updatedSchedule = viewModel.schedule.firstWhere(
          (s) => s.id == scheduleId,
        );
        expect(updatedSchedule.vaccines.length, initialCount + 1);
      });
    });

    group('deleteVaccine', () {
      test('should delete vaccine from schedule', () async {
        await viewModel.addChild(
          name: 'Test',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
        );

        final scheduleId = viewModel.schedule.first.id;
        final vaccineId = viewModel.schedule.first.vaccines.first.id;
        final initialCount = viewModel.schedule.first.vaccines.length;

        final result = await viewModel.deleteVaccine(scheduleId, vaccineId);

        expect(result, true);

        final updatedSchedule = viewModel.schedule.firstWhere(
          (s) => s.id == scheduleId,
        );
        expect(updatedSchedule.vaccines.length, initialCount - 1);
      });
    });

    group('clearError', () {
      test('should clear error message', () {
        viewModel.clearError();
        expect(viewModel.errorMessage, isNull);
      });
    });

    group('reset', () {
      test('should reset all state', () async {
        await viewModel.addChild(
          name: 'Test',
          birthDate: DateTime(2024, 1, 1),
          gender: ChildGender.male,
        );

        viewModel.reset();

        expect(viewModel.status, VaccineScreenStatus.initial);
        expect(viewModel.children, isEmpty);
        expect(viewModel.selectedChild, isNull);
        expect(viewModel.errorMessage, isNull);
      });
    });
  });
}
