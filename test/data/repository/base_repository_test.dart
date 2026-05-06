import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/repository/base_repository.dart';

void main() {
  group('Result', () {
    test('Result.success should create successful result', () {
      final result = Result.success('test data');

      expect(result.isSuccess, true);
      expect(result.data, 'test data');
      expect(result.error, isNull);
    });

    test('Result.failure should create failed result', () {
      final result = Result<String>.failure('Error message');

      expect(result.isSuccess, false);
      expect(result.data, isNull);
      expect(result.error, 'Error message');
    });

    test('dataOrThrow should return data for success', () {
      final result = Result.success(42);

      expect(result.dataOrThrow, 42);
    });

    test('dataOrThrow should throw for failure', () {
      final result = Result<int>.failure('Something went wrong');

      expect(() => result.dataOrThrow, throwsException);
    });

    test('map should transform data for success', () {
      final result = Result.success(5);
      final mapped = result.map((value) => value * 2);

      expect(mapped.isSuccess, true);
      expect(mapped.data, 10);
    });

    test('map should preserve error for failure', () {
      final result = Result<int>.failure('Error');
      final mapped = result.map((value) => value * 2);

      expect(mapped.isSuccess, false);
      expect(mapped.error, 'Error');
    });

    test('map should convert types', () {
      final result = Result.success(42);
      final mapped = result.map((value) => 'Number: $value');

      expect(mapped.isSuccess, true);
      expect(mapped.data, 'Number: 42');
    });
  });
}
