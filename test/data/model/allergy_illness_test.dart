import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/allergy.dart';
import 'package:health_asistants/data/model/illness.dart';

void main() {
  group('Allergy Model', () {
    late Allergy allergy;

    setUp(() {
      allergy = Allergy(
        id: 'all_1',
        name: 'Polen',
        createdDate: DateTime(2023, 3, 15),
      );
    });

    test('should create Allergy with all fields', () {
      expect(allergy.id, 'all_1');
      expect(allergy.name, 'Polen');
      expect(allergy.createdDate, DateTime(2023, 3, 15));
    });

    test('should create Allergy', () {
      final simpleAllergy = Allergy(
        id: 'all_2',
        name: 'Toz',
        createdDate: DateTime(2023, 1, 1),
      );

      expect(simpleAllergy.name, 'Toz');
    });

    test('should create Allergy from JSON', () {
      final json = {
        'id': 'all_1',
        'name': 'Polen',
        'createdDate': '2023-03-15T00:00:00.000',
      };

      final fromJson = Allergy.fromJson(json);

      expect(fromJson.id, 'all_1');
      expect(fromJson.name, 'Polen');
    });

    test('should convert Allergy to JSON', () {
      final json = allergy.toJson();

      expect(json['id'], 'all_1');
      expect(json['name'], 'Polen');
      expect(json['createdDate'], '2023-03-15T00:00:00.000');
    });

    test('should roundtrip JSON conversion', () {
      final json = allergy.toJson();
      final fromJson = Allergy.fromJson(json);

      expect(fromJson.id, allergy.id);
      expect(fromJson.name, allergy.name);
    });
  });

  group('IllnessStatus Enum', () {
    test('should have all expected values', () {
      expect(IllnessStatus.values.length, 3);
      expect(IllnessStatus.values, contains(IllnessStatus.active));
      expect(IllnessStatus.values, contains(IllnessStatus.recovered));
      expect(IllnessStatus.values, contains(IllnessStatus.monitoring));
    });
  });

  group('Illness Model', () {
    late Illness illness;

    setUp(() {
      illness = Illness(
        id: 'ill_1',
        name: 'Diyabet',
        diagnosisDate: DateTime(2022, 6, 1),
        status: IllnessStatus.active,
        doctorNotes: 'Tip 2 diyabet',
      );
    });

    test('should create Illness with all fields', () {
      expect(illness.id, 'ill_1');
      expect(illness.name, 'Diyabet');
      expect(illness.diagnosisDate, DateTime(2022, 6, 1));
      expect(illness.status, IllnessStatus.active);
      expect(illness.doctorNotes, 'Tip 2 diyabet');
    });

    test('should create Illness without doctorNotes', () {
      final simpleIllness = Illness(
        id: 'ill_2',
        name: 'Astım',
        diagnosisDate: DateTime(2023, 1, 1),
        status: IllnessStatus.monitoring,
      );

      expect(simpleIllness.doctorNotes, isNull);
    });

    test('should create Illness from JSON', () {
      final json = {
        'id': 'ill_1',
        'name': 'Diyabet',
        'diagnosisDate': '2022-06-01T00:00:00.000',
        'status': 'active',
        'doctorNotes': 'Tip 2 diyabet',
      };

      final fromJson = Illness.fromJson(json);

      expect(fromJson.id, 'ill_1');
      expect(fromJson.name, 'Diyabet');
      expect(fromJson.status, IllnessStatus.active);
      expect(fromJson.doctorNotes, 'Tip 2 diyabet');
    });

    test('should handle unknown status in JSON', () {
      final json = {
        'id': 'ill_2',
        'name': 'Test',
        'diagnosisDate': '2023-01-01T00:00:00.000',
        'status': 'unknown',
      };

      final fromJson = Illness.fromJson(json);
      expect(fromJson.status, IllnessStatus.active);
    });

    test('should convert Illness to JSON', () {
      final json = illness.toJson();

      expect(json['id'], 'ill_1');
      expect(json['name'], 'Diyabet');
      expect(json['status'], 'active');
      expect(json['doctorNotes'], 'Tip 2 diyabet');
    });

    test('should roundtrip JSON conversion', () {
      final json = illness.toJson();
      final fromJson = Illness.fromJson(json);

      expect(fromJson.id, illness.id);
      expect(fromJson.name, illness.name);
      expect(fromJson.status, illness.status);
      expect(fromJson.doctorNotes, illness.doctorNotes);
    });
  });
}
