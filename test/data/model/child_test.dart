import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/child.dart';
import 'package:health_asistants/data/model/vaccine.dart';

void main() {
  group('ChildGender Enum', () {
    test('should have correct labels', () {
      expect(ChildGender.male.label, 'Erkek');
      expect(ChildGender.female.label, 'Kız');
    });

    test('fromString should return correct gender', () {
      expect(ChildGender.fromString('male'), ChildGender.male);
      expect(ChildGender.fromString('female'), ChildGender.female);
    });

    test('fromString should return male for unknown value', () {
      expect(ChildGender.fromString('unknown'), ChildGender.male);
    });
  });

  group('Child Model', () {
    late Child child;

    setUp(() {
      child = Child(
        id: 'child_1',
        name: 'Elif',
        birthDate: DateTime(2023, 6, 15),
        gender: ChildGender.female,
        vaccineSchedule: [
          BabyVaccineSchedule(
            id: 'sched_1',
            period: 'Doğumda',
            monthIndex: 0,
            scheduledDate: DateTime(2023, 6, 15),
            vaccines: [
              Vaccine(
                id: 'vac_1',
                name: 'Hepatit B',
                date: DateTime(2023, 6, 15),
                dose: '1. Doz',
                status: VaccineStatus.completed,
                childId: 'child_1',
              ),
            ],
          ),
        ],
      );
    });

    test('should create Child with all fields', () {
      expect(child.id, 'child_1');
      expect(child.name, 'Elif');
      expect(child.birthDate, DateTime(2023, 6, 15));
      expect(child.gender, ChildGender.female);
      expect(child.vaccineSchedule.length, 1);
    });

    test('should have empty vaccineSchedule by default', () {
      final simpleChild = Child(
        id: 'child_2',
        name: 'Test',
        birthDate: DateTime(2024, 1, 1),
        gender: ChildGender.male,
      );

      expect(simpleChild.vaccineSchedule, isEmpty);
    });

    test('ageInMonths should return correct value', () {
      final now = DateTime.now();
      final recentChild = Child(
        id: 'child_3',
        name: 'Baby',
        birthDate: DateTime(now.year, now.month - 3, now.day),
        gender: ChildGender.male,
      );

      expect(recentChild.ageInMonths, 3);
    });

    test('ageText should return Yenidoğan for newborn', () {
      final now = DateTime.now();
      final newborn = Child(
        id: 'child_4',
        name: 'Newborn',
        birthDate: DateTime(now.year, now.month, now.day),
        gender: ChildGender.female,
      );

      expect(newborn.ageText, 'Yenidoğan');
    });

    test('ageText should return months for babies under 1 year', () {
      final now = DateTime.now();
      final baby = Child(
        id: 'child_5',
        name: 'Baby',
        birthDate: DateTime(now.year, now.month - 6, now.day),
        gender: ChildGender.male,
      );

      expect(baby.ageText, '6 aylık');
    });

    test('ageText should return years for older children', () {
      final now = DateTime.now();
      final olderChild = Child(
        id: 'child_6',
        name: 'Older',
        birthDate: DateTime(now.year - 2, now.month, now.day),
        gender: ChildGender.female,
      );

      expect(olderChild.ageText, '2 yaşında');
    });

    test('ageText should return years and months', () {
      final now = DateTime.now();
      final child = Child(
        id: 'child_7',
        name: 'Test',
        birthDate: DateTime(now.year - 1, now.month - 3, now.day),
        gender: ChildGender.male,
      );

      expect(child.ageText, '1 yıl 3 ay');
    });

    test('copyWith should return new instance with updated fields', () {
      final updated = child.copyWith(
        name: 'Updated Name',
        gender: ChildGender.male,
      );

      expect(updated.name, 'Updated Name');
      expect(updated.gender, ChildGender.male);
      expect(updated.id, child.id);
      expect(updated.birthDate, child.birthDate);
    });

    test('should create Child from JSON', () {
      final json = {
        'id': 'child_1',
        'name': 'Elif',
        'birthDate': '2023-06-15T00:00:00.000',
        'gender': 'female',
        'vaccineSchedule': [
          {
            'id': 'sched_1',
            'period': 'Doğumda',
            'monthIndex': 0,
            'scheduledDate': '2023-06-15T00:00:00.000',
            'vaccines': [
              {
                'id': 'vac_1',
                'name': 'Hepatit B',
                'date': '2023-06-15T00:00:00.000',
                'dose': '1. Doz',
                'status': 'completed',
              },
            ],
          },
        ],
      };

      final fromJson = Child.fromJson(json);

      expect(fromJson.id, 'child_1');
      expect(fromJson.name, 'Elif');
      expect(fromJson.gender, ChildGender.female);
      expect(fromJson.vaccineSchedule.length, 1);
      expect(fromJson.vaccineSchedule.first.vaccines.length, 1);
    });

    test('should handle missing vaccineSchedule in JSON', () {
      final json = {
        'id': 'child_2',
        'name': 'Test',
        'birthDate': '2024-01-01T00:00:00.000',
        'gender': 'male',
      };

      final fromJson = Child.fromJson(json);
      expect(fromJson.vaccineSchedule, isEmpty);
    });

    test('should convert Child to JSON', () {
      final json = child.toJson();

      expect(json['id'], 'child_1');
      expect(json['name'], 'Elif');
      expect(json['gender'], 'female');
      expect(json['vaccineSchedule'], isList);
    });

    test('should roundtrip JSON conversion', () {
      final json = child.toJson();
      final fromJson = Child.fromJson(json);

      expect(fromJson.id, child.id);
      expect(fromJson.name, child.name);
      expect(fromJson.gender, child.gender);
      expect(fromJson.vaccineSchedule.length, child.vaccineSchedule.length);
    });
  });
}
