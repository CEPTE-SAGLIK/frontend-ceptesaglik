import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/repository/vaccine_repository.dart';

void main() {
  group('VaccineRepository', () {
    late VaccineRepository repository;

    setUp(() {
      repository = VaccineRepository();
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
