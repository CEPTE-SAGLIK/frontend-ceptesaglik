enum ReminderType { medicine, vaccine, appointment, custom }
enum RepeatType { none, daily, weekly, monthly }

class Reminder {
  final String id;
  final String personId;
  final String title;
  final String? description;
  final ReminderType type;
  final DateTime dateTime;
  final RepeatType repeatType;
  final bool isActive;
  final String? relatedItemId; // İlaç veya aşı ID'si
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.personId,
    required this.title,
    this.description,
    required this.type,
    required this.dateTime,
    this.repeatType = RepeatType.none,
    this.isActive = true,
    this.relatedItemId,
    required this.createdAt,
  });

  Reminder copyWith({
    String? id,
    String? personId,
    String? title,
    String? description,
    ReminderType? type,
    DateTime? dateTime,
    RepeatType? repeatType,
    bool? isActive,
    String? relatedItemId,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      repeatType: repeatType ?? this.repeatType,
      isActive: isActive ?? this.isActive,
      relatedItemId: relatedItemId ?? this.relatedItemId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    // Backend returns userId; local model uses personId
    final pId = (json['personId'] ?? json['userId'] ?? json['UserId'] ?? '') as String;
    // Backend returns dateTime or reminderDate
    final rawDate = json['dateTime'] ?? json['reminderDate'] ?? json['ReminderDate'];
    final dt = rawDate != null ? DateTime.parse(rawDate as String) : DateTime.now();
    // createdAt may be missing in virtual reminders
    final rawCreated = json['createdAt'] ?? json['CreatedAt'] ?? json['dateTime'] ?? json['reminderDate'];
    final created = rawCreated != null ? DateTime.parse(rawCreated as String) : DateTime.now();

    return Reminder(
      id: (json['id'] ?? json['Id'] ?? '') as String,
      personId: pId,
      title: (json['title'] ?? json['Title'] ?? '') as String,
      description: (json['description'] ?? json['Description']) as String?,
      type: ReminderType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? '').toLowerCase(),
        orElse: () => ReminderType.custom,
      ),
      dateTime: dt,
      repeatType: RepeatType.values.firstWhere(
        (e) => e.name == (json['repeatType'] as String? ?? '').toLowerCase(),
        orElse: () => RepeatType.none,
      ),
      isActive: json['isActive'] as bool? ?? true,
      relatedItemId: (json['relatedItemId'] ?? json['medicineId'] ?? json['vaccineId']) as String?,
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personId': personId,
      'title': title,
      'description': description,
      'type': type.name,
      'dateTime': dateTime.toIso8601String(),
      'repeatType': repeatType.name,
      'isActive': isActive,
      'relatedItemId': relatedItemId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}