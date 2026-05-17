import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/reminder.dart';

void main() {
  group('ReminderType Enum', () {
    test('should have all expected values', () {
      expect(ReminderType.values.length, 4);
      expect(ReminderType.values, contains(ReminderType.medicine));
      expect(ReminderType.values, contains(ReminderType.vaccine));
      expect(ReminderType.values, contains(ReminderType.appointment));
      expect(ReminderType.values, contains(ReminderType.custom));
    });
  });

  group('RepeatType Enum', () {
    test('should have all expected values', () {
      expect(RepeatType.values.length, 4);
      expect(RepeatType.values, contains(RepeatType.none));
      expect(RepeatType.values, contains(RepeatType.daily));
      expect(RepeatType.values, contains(RepeatType.weekly));
      expect(RepeatType.values, contains(RepeatType.monthly));
    });
  });

  group('AudienceGroup Enum', () {
    test('should have all expected values', () {
      expect(AudienceGroup.values.length, 3);
      expect(AudienceGroup.values, contains(AudienceGroup.adult));
      expect(AudienceGroup.values, contains(AudienceGroup.elderly));
      expect(AudienceGroup.values, contains(AudienceGroup.child));
    });

    test('should default to adult when not provided', () {
      final reminder = Reminder(
        id: 'r',
        personId: 'p',
        title: 't',
        type: ReminderType.custom,
        dateTime: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
      );
      expect(reminder.audienceGroup, AudienceGroup.adult);
    });

    test('should parse audienceGroup from JSON', () {
      final json = {
        'id': 'r',
        'personId': 'p',
        'title': 't',
        'type': 'custom',
        'dateTime': '2024-06-15T10:30:00.000',
        'createdAt': '2024-01-01T00:00:00.000',
        'audienceGroup': 'elderly',
      };
      expect(Reminder.fromJson(json).audienceGroup, AudienceGroup.elderly);
    });

    test('should default to adult for missing/unknown audienceGroup', () {
      final json = {
        'id': 'r',
        'personId': 'p',
        'title': 't',
        'type': 'custom',
        'dateTime': '2024-06-15T10:30:00.000',
        'createdAt': '2024-01-01T00:00:00.000',
      };
      expect(Reminder.fromJson(json).audienceGroup, AudienceGroup.adult);
    });

    test('should roundtrip audienceGroup through JSON', () {
      final reminder = Reminder(
        id: 'r',
        personId: 'p',
        title: 't',
        type: ReminderType.custom,
        dateTime: DateTime(2024, 1, 1),
        audienceGroup: AudienceGroup.child,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(
        Reminder.fromJson(reminder.toJson()).audienceGroup,
        AudienceGroup.child,
      );
    });
  });

  group('Reminder Model', () {
    late Reminder reminder;
    late DateTime reminderDateTime;
    late DateTime createdAt;

    setUp(() {
      reminderDateTime = DateTime(2024, 6, 15, 10, 30);
      createdAt = DateTime(2024, 1, 1);
      reminder = Reminder(
        id: 'rem_1',
        personId: 'person_1',
        title: 'Aspirin',
        description: 'Sabah kahvaltıdan sonra',
        type: ReminderType.medicine,
        dateTime: reminderDateTime,
        repeatType: RepeatType.daily,
        isActive: true,
        relatedItemId: 'med_1',
        createdAt: createdAt,
      );
    });

    test('should create Reminder with all fields', () {
      expect(reminder.id, 'rem_1');
      expect(reminder.personId, 'person_1');
      expect(reminder.title, 'Aspirin');
      expect(reminder.description, 'Sabah kahvaltıdan sonra');
      expect(reminder.type, ReminderType.medicine);
      expect(reminder.dateTime, reminderDateTime);
      expect(reminder.repeatType, RepeatType.daily);
      expect(reminder.isActive, true);
      expect(reminder.relatedItemId, 'med_1');
      expect(reminder.createdAt, createdAt);
    });

    test('should create Reminder with default values', () {
      final simpleReminder = Reminder(
        id: 'rem_2',
        personId: 'person_1',
        title: 'Test',
        type: ReminderType.custom,
        dateTime: reminderDateTime,
        createdAt: createdAt,
      );

      expect(simpleReminder.description, isNull);
      expect(simpleReminder.repeatType, RepeatType.none);
      expect(simpleReminder.isActive, true);
      expect(simpleReminder.relatedItemId, isNull);
    });

    test('should create Reminder from JSON', () {
      final json = {
        'id': 'rem_1',
        'personId': 'person_1',
        'title': 'Aspirin',
        'description': 'Sabah kahvaltıdan sonra',
        'type': 'medicine',
        'dateTime': '2024-06-15T10:30:00.000',
        'repeatType': 'daily',
        'isActive': true,
        'relatedItemId': 'med_1',
        'createdAt': '2024-01-01T00:00:00.000',
      };

      final fromJson = Reminder.fromJson(json);

      expect(fromJson.id, 'rem_1');
      expect(fromJson.personId, 'person_1');
      expect(fromJson.title, 'Aspirin');
      expect(fromJson.description, 'Sabah kahvaltıdan sonra');
      expect(fromJson.type, ReminderType.medicine);
      expect(fromJson.dateTime, reminderDateTime);
      expect(fromJson.repeatType, RepeatType.daily);
      expect(fromJson.isActive, true);
      expect(fromJson.relatedItemId, 'med_1');
    });

    test('should handle null optional fields in JSON', () {
      final json = {
        'id': 'rem_2',
        'personId': 'person_1',
        'title': 'Test',
        'type': 'custom',
        'dateTime': '2024-06-15T10:30:00.000',
        'createdAt': '2024-01-01T00:00:00.000',
      };

      final fromJson = Reminder.fromJson(json);

      expect(fromJson.description, isNull);
      expect(fromJson.repeatType, RepeatType.none);
      expect(fromJson.isActive, true);
      expect(fromJson.relatedItemId, isNull);
    });

    test('should handle unknown type in JSON', () {
      final json = {
        'id': 'rem_3',
        'personId': 'person_1',
        'title': 'Test',
        'type': 'unknown_type',
        'dateTime': '2024-06-15T10:30:00.000',
        'repeatType': 'unknown_repeat',
        'createdAt': '2024-01-01T00:00:00.000',
      };

      final fromJson = Reminder.fromJson(json);
      expect(fromJson.type, ReminderType.custom);
      expect(fromJson.repeatType, RepeatType.none);
    });

    test('should convert Reminder to JSON', () {
      final json = reminder.toJson();

      expect(json['id'], 'rem_1');
      expect(json['personId'], 'person_1');
      expect(json['title'], 'Aspirin');
      expect(json['description'], 'Sabah kahvaltıdan sonra');
      expect(json['type'], 'medicine');
      expect(json['dateTime'], '2024-06-15T10:30:00.000');
      expect(json['repeatType'], 'daily');
      expect(json['isActive'], true);
      expect(json['relatedItemId'], 'med_1');
    });

    test('should roundtrip JSON conversion', () {
      final json = reminder.toJson();
      final fromJson = Reminder.fromJson(json);

      expect(fromJson.id, reminder.id);
      expect(fromJson.personId, reminder.personId);
      expect(fromJson.title, reminder.title);
      expect(fromJson.description, reminder.description);
      expect(fromJson.type, reminder.type);
      expect(fromJson.dateTime, reminder.dateTime);
      expect(fromJson.repeatType, reminder.repeatType);
      expect(fromJson.isActive, reminder.isActive);
      expect(fromJson.relatedItemId, reminder.relatedItemId);
    });
  });
}
