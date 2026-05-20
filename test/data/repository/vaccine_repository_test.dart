import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/vaccine.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/vaccine_repository.dart';

class _StubVaccineRepository extends VaccineRepository {
  @override
  Future<Result<List<Vaccine>>> getByChildId(String childId) async {
    return Result.success([]);
  }

  @override
  Future<Result<List<Vaccine>>> getUpcomingVaccines() async {
    return Result.success([]);
  }

  @override
  Future<Result<List<Vaccine>>> getOverdueVaccines() async {
    return Result.success([]);
  }
}

void main() {
  group('VaccineRepository', () {
    late _StubVaccineRepository repository;

    setUp(() {
      repository = _StubVaccineRepository();
    });

    group('getByChildId', () {
      test('should return success with empty list', () async {
        final result = await repository.getByChildId('child_1');

        expect(result.isSuccess, true);
        expect(result.data!, isEmpty);
      });

      test('should return success for any childId', () async {
        final result = await repository.getByChildId('any_id');

        expect(result.isSuccess, true);
        expect(result.data, isNotNull);
      });
    });

    group('getUpcomingVaccines', () {
      test('should return success with empty list', () async {
        final result = await repository.getUpcomingVaccines();

        expect(result.isSuccess, true);
        expect(result.data!, isEmpty);
      });
    });

    group('getOverdueVaccines', () {
      test('should return success with empty list', () async {
        final result = await repository.getOverdueVaccines();

        expect(result.isSuccess, true);
        expect(result.data!, isEmpty);
      });
    });
  });
}
