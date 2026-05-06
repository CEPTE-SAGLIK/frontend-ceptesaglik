import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/model/allergy.dart';
import 'package:health_asistants/data/model/illness.dart';
import 'package:health_asistants/data/model/medicine.dart';
import 'package:health_asistants/data/model/vaccine.dart';

void main() {
  group('Gender Enum', () {
    test('should have male and female values', () {
      expect(Gender.values.length, 2);
      expect(Gender.values, contains(Gender.male));
      expect(Gender.values, contains(Gender.female));
    });
  });

  group('Person Model', () {
    late Person person;

    setUp(() {
      person = Person(
        id: 'person_1',
        userId: 'user_1',
        name: 'Beyza',
        surname: 'Selvi',
        birthDate: DateTime(1995, 5, 20),
        gender: Gender.female,
        height: 165.0,
        weight: 58.0,
      );
    });

    test('should create Person with required fields', () {
      expect(person.id, 'person_1');
      expect(person.userId, 'user_1');
      expect(person.name, 'Beyza');
      expect(person.surname, 'Selvi');
      expect(person.relationship, isNull);
      expect(person.birthDate, DateTime(1995, 5, 20));
      expect(person.gender, Gender.female);
      expect(person.height, 165.0);
      expect(person.weight, 58.0);
    });

    test('should have empty lists by default', () {
      expect(person.illnesses, isEmpty);
      expect(person.allergies, isEmpty);
      expect(person.medicines, isEmpty);
      expect(person.vaccines, isEmpty);
    });

    test('should create Person with lists', () {
      final personWithData = Person(
        id: 'person_2',
        userId: 'user_1',
        name: 'Test',
        surname: 'User',
        birthDate: DateTime(2020, 1, 1),
        gender: Gender.male,
        illnesses: [
          Illness(
            id: 'ill_1',
            name: 'Diyabet',
            diagnosisDate: DateTime(2023, 1, 1),
            status: IllnessStatus.active,
          ),
        ],
        allergies: [
          Allergy(
            id: 'all_1',
            name: 'Polen',
            createdDate: DateTime(2023, 1, 1),
          ),
        ],
      );

      expect(personWithData.illnesses.length, 1);
      expect(personWithData.allergies.length, 1);
      expect(personWithData.illnesses.first.name, 'Diyabet');
      expect(personWithData.allergies.first.name, 'Polen');
    });

    test('should create Person from JSON', () {
      final json = {
        'id': 'person_1',
        'userId': 'user_1',
        'name': 'Beyza',
        'surname': 'Selvi',
        'birthDate': '1995-05-20T00:00:00.000',
        'gender': 'Female',
        'height': 165.0,
        'weight': 58.0,
        'createdAt': '2026-03-05T10:00:00.000Z',
        'illnesses': [],
        'allergies': [],
        'medicines': [],
        'vaccines': [],
      };

      final fromJson = Person.fromJson(json);

      expect(fromJson.id, 'person_1');
      expect(fromJson.name, 'Beyza');
      expect(fromJson.gender, Gender.female);
      expect(fromJson.height, 165.0);
      expect(fromJson.weight, 58.0);
      expect(fromJson.createdAt, DateTime.parse('2026-03-05T10:00:00.000Z'));
    });

    test('should handle null optional fields in JSON', () {
      final json = {
        'id': 'person_2',
        'userId': 'user_1',
        'name': 'Test',
        'surname': 'User',
        'birthDate': '2020-01-01T00:00:00.000',
        'gender': 'Male',
      };

      final fromJson = Person.fromJson(json);

      expect(fromJson.height, isNull);
      expect(fromJson.weight, isNull);
      expect(fromJson.illnesses, isEmpty);
      expect(fromJson.allergies, isEmpty);
      expect(fromJson.medicines, isEmpty);
      expect(fromJson.vaccines, isEmpty);
    });

    test('should handle unknown gender in JSON', () {
      final json = {
        'id': 'person_3',
        'userId': 'user_1',
        'name': 'Test',
        'surname': 'User',
        'birthDate': '2000-01-01T00:00:00.000',
        'gender': 'unknown',
      };

      final fromJson = Person.fromJson(json);
      expect(fromJson.gender, Gender.male);
    });

    test('should convert Person to JSON', () {
      final json = person.toJson();

      expect(json['id'], 'person_1');
      expect(json['userId'], 'user_1');
      expect(json['name'], 'Beyza');
      expect(json['surname'], 'Selvi');
      expect(json.containsKey('relationship'), false);
      expect(json['gender'], 'Female');
      expect(json['height'], 165.0);
      expect(json['weight'], 58.0);
      expect(json['illnesses'], isList);
      expect(json['allergies'], isList);
    });

    test('should roundtrip JSON conversion', () {
      final json = person.toJson();
      final fromJson = Person.fromJson(json);

      expect(fromJson.id, person.id);
      expect(fromJson.name, person.name);
      expect(fromJson.surname, person.surname);
      expect(fromJson.gender, person.gender);
      expect(fromJson.height, person.height);
      expect(fromJson.weight, person.weight);
    });

    test('should serialize nested illnesses and allergies', () {
      final personWithNested = Person(
        id: 'p1',
        userId: 'u1',
        name: 'Test',
        surname: 'User',
        birthDate: DateTime(2000, 1, 1),
        gender: Gender.male,
        illnesses: [
          Illness(
            id: 'ill_1',
            name: 'Astım',
            diagnosisDate: DateTime(2022, 6, 1),
            status: IllnessStatus.active,
          ),
        ],
        allergies: [
          Allergy(id: 'all_1', name: 'Toz', createdDate: DateTime(2022, 6, 1)),
        ],
      );

      final json = personWithNested.toJson();
      final fromJson = Person.fromJson(json);

      expect(fromJson.illnesses.length, 1);
      expect(fromJson.illnesses.first.name, 'Astım');
      expect(fromJson.allergies.length, 1);
      expect(fromJson.allergies.first.name, 'Toz');
    });
  });
}
