import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/user.dart';

void main() {
  group('User Model', () {
    late User user;
    late Map<String, dynamic> userJson;

    setUp(() {
      user = User(
        id: 'user_1',
        name: 'Beyza',
        surname: 'Selvi',
        email: 'beyza@test.com',
        createdAt: DateTime(2024, 1, 15),
      );

      userJson = {
        'id': 'user_1',
        'name': 'Beyza',
        'surname': 'Selvi',
        'email': 'beyza@test.com',
        'createdAt': '2024-01-15T00:00:00.000',
      };
    });

    test('should create User with required fields', () {
      expect(user.id, 'user_1');
      expect(user.name, 'Beyza');
      expect(user.surname, 'Selvi');
      expect(user.email, 'beyza@test.com');
      expect(user.createdAt, DateTime(2024, 1, 15));
    });

    test('should create User from JSON', () {
      final fromJson = User.fromJson(userJson);

      expect(fromJson.id, 'user_1');
      expect(fromJson.name, 'Beyza');
      expect(fromJson.surname, 'Selvi');
      expect(fromJson.email, 'beyza@test.com');
      expect(fromJson.createdAt, DateTime(2024, 1, 15));
    });

    test('should convert User to JSON', () {
      final json = user.toJson();

      expect(json['id'], 'user_1');
      expect(json['name'], 'Beyza');
      expect(json['surname'], 'Selvi');
      expect(json['email'], 'beyza@test.com');
      expect(json['createdAt'], '2024-01-15T00:00:00.000');
    });

    test('should roundtrip JSON conversion', () {
      final json = user.toJson();
      final fromJson = User.fromJson(json);

      expect(fromJson.id, user.id);
      expect(fromJson.name, user.name);
      expect(fromJson.surname, user.surname);
      expect(fromJson.email, user.email);
      expect(fromJson.createdAt, user.createdAt);
    });
  });
}
