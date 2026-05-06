import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/medicine.dart';

void main() {
  group('FrequencyType', () {
    test('should have correct labels', () {
      expect(FrequencyType.daily.label, 'Her Gün');
      expect(FrequencyType.everyOtherDay.label, 'Gün Aşırı');
      expect(FrequencyType.weekly.label, 'Haftada Bir');
      expect(FrequencyType.custom.label, 'Özel');
    });

    test('fromLabel should return correct type', () {
      expect(FrequencyType.fromLabel('Her Gün'), FrequencyType.daily);
      expect(FrequencyType.fromLabel('Gün Aşırı'), FrequencyType.everyOtherDay);
      expect(FrequencyType.fromLabel('Haftada Bir'), FrequencyType.weekly);
      expect(FrequencyType.fromLabel('Özel'), FrequencyType.custom);
    });

    test('fromLabel should return daily for unknown label', () {
      expect(FrequencyType.fromLabel('bilinmeyen'), FrequencyType.daily);
    });
  });

  group('Medicine Model', () {
    late Medicine medicine;
    late DateTime startDate;

    setUp(() {
      startDate = DateTime(2024, 6, 1);
      medicine = Medicine(
        id: 'med_1',
        name: 'Parol 500mg',
        usageInstructions: 'Ağrı durumunda',
        frequencyType: FrequencyType.daily,
        timesPerDay: 2,
        reminderTimes: [
          DateTime(2024, 6, 1, 8, 0),
          DateTime(2024, 6, 1, 20, 0),
        ],
        startDate: startDate,
        endDate: DateTime(2024, 7, 1),
        notes: 'Yemeklerden sonra',
        personId: 'person_1',
      );
    });

    test('should create Medicine with all fields', () {
      expect(medicine.id, 'med_1');
      expect(medicine.name, 'Parol 500mg');
      expect(medicine.usageInstructions, 'Ağrı durumunda');
      expect(medicine.frequencyType, FrequencyType.daily);
      expect(medicine.timesPerDay, 2);
      expect(medicine.reminderTimes.length, 2);
      expect(medicine.startDate, startDate);
      expect(medicine.endDate, DateTime(2024, 7, 1));
      expect(medicine.notes, 'Yemeklerden sonra');
      expect(medicine.personId, 'person_1');
    });

    test('should create Medicine with default values', () {
      final simpleMedicine = Medicine(
        id: 'med_2',
        name: 'Aspirin',
        startDate: startDate,
      );

      expect(simpleMedicine.usageInstructions, isNull);
      expect(simpleMedicine.frequencyType, FrequencyType.daily);
      expect(simpleMedicine.timesPerDay, 1);
      expect(simpleMedicine.reminderTimes, isEmpty);
      expect(simpleMedicine.endDate, isNull);
      expect(simpleMedicine.notes, isNull);
      expect(simpleMedicine.personId, isNull);
    });

    test('copyWith should return new instance with updated fields', () {
      final updated = medicine.copyWith(name: 'Parol 1000mg', timesPerDay: 3);

      expect(updated.name, 'Parol 1000mg');
      expect(updated.timesPerDay, 3);
      // Unchanged fields
      expect(updated.id, medicine.id);
      expect(updated.usageInstructions, medicine.usageInstructions);
      expect(updated.frequencyType, medicine.frequencyType);
      expect(updated.personId, medicine.personId);
    });

    test('copyWith without parameters should return identical copy', () {
      final copy = medicine.copyWith();

      expect(copy.id, medicine.id);
      expect(copy.name, medicine.name);
      expect(copy.usageInstructions, medicine.usageInstructions);
      expect(copy.frequencyType, medicine.frequencyType);
      expect(copy.timesPerDay, medicine.timesPerDay);
      expect(copy.startDate, medicine.startDate);
    });

    test('should create Medicine from JSON', () {
      final json = {
        'id': 'med_1',
        'name': 'Parol 500mg',
        'usageInstructions': 'Ağrı durumunda',
        'frequencyType': 'daily',
        'timesPerDay': 2,
        'reminderTimes': ['2024-06-01T08:00:00.000', '2024-06-01T20:00:00.000'],
        'startDate': '2024-06-01T00:00:00.000',
        'endDate': '2024-07-01T00:00:00.000',
        'notes': 'Yemeklerden sonra',
        'personId': 'person_1',
      };

      final fromJson = Medicine.fromJson(json);

      expect(fromJson.id, 'med_1');
      expect(fromJson.name, 'Parol 500mg');
      expect(fromJson.frequencyType, FrequencyType.daily);
      expect(fromJson.timesPerDay, 2);
      expect(fromJson.reminderTimes.length, 2);
      expect(fromJson.endDate, DateTime(2024, 7, 1));
    });

    test('should handle null optional fields in JSON', () {
      final json = {
        'id': 'med_2',
        'name': 'Aspirin',
        'startDate': '2024-06-01T00:00:00.000',
      };

      final fromJson = Medicine.fromJson(json);

      expect(fromJson.usageInstructions, isNull);
      expect(fromJson.frequencyType, FrequencyType.daily);
      expect(fromJson.timesPerDay, 1);
      expect(fromJson.reminderTimes, isEmpty);
      expect(fromJson.endDate, isNull);
      expect(fromJson.notes, isNull);
      expect(fromJson.personId, isNull);
    });

    test('should convert Medicine to JSON', () {
      final json = medicine.toJson();

      expect(json['id'], 'med_1');
      expect(json['name'], 'Parol 500mg');
      expect(json['frequencyType'], 'daily');
      expect(json['timesPerDay'], 2);
      expect(json['reminderTimes'], isList);
      expect((json['reminderTimes'] as List).length, 2);
      expect(json['notes'], 'Yemeklerden sonra');
    });

    test('should roundtrip JSON conversion', () {
      final json = medicine.toJson();
      final fromJson = Medicine.fromJson(json);

      expect(fromJson.id, medicine.id);
      expect(fromJson.name, medicine.name);
      expect(fromJson.frequencyType, medicine.frequencyType);
      expect(fromJson.timesPerDay, medicine.timesPerDay);
      expect(fromJson.reminderTimes.length, medicine.reminderTimes.length);
      expect(fromJson.personId, medicine.personId);
    });

    test('should handle unknown frequencyType in JSON', () {
      final json = {
        'id': 'med_3',
        'name': 'Test',
        'frequencyType': 'unknown_type',
        'startDate': '2024-06-01T00:00:00.000',
      };

      final fromJson = Medicine.fromJson(json);
      expect(fromJson.frequencyType, FrequencyType.daily);
    });
  });
}
