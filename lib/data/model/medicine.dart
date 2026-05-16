import 'package:health_asistants/data/model/reminder.dart' show AudienceGroup;

export 'package:health_asistants/data/model/reminder.dart' show AudienceGroup;

enum FrequencyType {
  none('Tek Seferlik'),
  daily('Her Gün'),
  everyOtherDay('Gün Aşırı'),
  weekly('Haftada Bir'),
  monthly('Aylık'),
  custom('Özel');

  final String label;
  const FrequencyType(this.label);

  static FrequencyType fromLabel(String label) {
    return FrequencyType.values.firstWhere(
      (e) => e.label == label,
      orElse: () => FrequencyType.none,
    );
  }
}

class Medicine {
  final String id;
  final String name;
  final String? usageInstructions;
  final FrequencyType frequencyType;
  final int timesPerDay;
  final List<DateTime> reminderTimes;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final String? personId;
  final AudienceGroup audienceGroup;
  final DateTime? audienceBirthDate; // Hedef kişinin doğum tarihi

  Medicine({
    required this.id,
    required this.name,
    this.usageInstructions,
    this.frequencyType = FrequencyType.daily,
    this.timesPerDay = 1,
    this.reminderTimes = const [],
    required this.startDate,
    this.endDate,
    this.notes,
    this.personId,
    this.audienceGroup = AudienceGroup.adult,
    this.audienceBirthDate,
  });

  Medicine copyWith({
    String? id,
    String? name,
    String? usageInstructions,
    FrequencyType? frequencyType,
    int? timesPerDay,
    List<DateTime>? reminderTimes,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? personId,
    AudienceGroup? audienceGroup,
    DateTime? audienceBirthDate,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      usageInstructions: usageInstructions ?? this.usageInstructions,
      frequencyType: frequencyType ?? this.frequencyType,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      personId: personId ?? this.personId,
      audienceGroup: audienceGroup ?? this.audienceGroup,
      audienceBirthDate: audienceBirthDate ?? this.audienceBirthDate,
    );
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    // Supports both frontend (camelCase) and backend (PascalCase/different fields)
    final id = (json['id'] ?? json['Id'] ?? '') as String;
    final name = (json['name'] ?? json['Name'] ?? '') as String;
    final usageInstructions = (json['usageInstructions'] ?? json['UsageInstructions']) as String?;
    final timesPerDay = (json['timesPerDay'] ?? json['TimesPerDay'] as dynamic) as int? ?? 1;
    final notes = (json['notes'] ?? json['Notes']) as String?;
    final personId = (json['personId'] ?? json['userId'] ?? json['UserId']) as String?;

    // Backend returns Frequency as PascalCase enum name ("Weekly"), label ("Haftada Bir"), or int string ("2")
    final freqRaw = json['frequencyType'] ?? json['frequency'] ?? json['Frequency'];
    FrequencyType freqType;
    if (freqRaw != null) {
      final rawStr = freqRaw.toString();
      final rawLower = rawStr.toLowerCase();
      freqType = FrequencyType.values.firstWhere(
        (e) => e.name == rawLower || e.label == rawStr,
        orElse: () {
          switch (int.tryParse(rawStr)) {
            case 0: return FrequencyType.none;
            case 1: return FrequencyType.daily;
            case 2: return FrequencyType.weekly;
            case 3: return FrequencyType.monthly;
            default: return FrequencyType.none;
          }
        },
      );
    } else {
      freqType = FrequencyType.daily;
    }

    // startDate / StartDate
    final startRaw = json['startDate'] ?? json['StartDate'];
    final startDate = startRaw != null ? DateTime.parse(startRaw as String) : DateTime.now();

    final endRaw = json['endDate'] ?? json['EndDate'];
    final endDate = endRaw != null ? DateTime.parse(endRaw as String) : null;

    // Backend AudienceGroup'u int (0/1/2) ya da string ("adult"...) dönebilir
    final audRaw = json['audienceGroup'] ?? json['AudienceGroup'];
    AudienceGroup audienceGroup = AudienceGroup.adult;
    if (audRaw is int && audRaw >= 0 && audRaw < AudienceGroup.values.length) {
      audienceGroup = AudienceGroup.values[audRaw];
    } else if (audRaw != null) {
      final s = audRaw.toString().toLowerCase();
      audienceGroup = AudienceGroup.values.firstWhere(
        (e) => e.name == s,
        orElse: () => AudienceGroup.adult,
      );
    }

    final audBdRaw = json['audienceBirthDate'] ?? json['AudienceBirthDate'];
    final DateTime? audienceBirthDate =
        audBdRaw is String ? DateTime.tryParse(audBdRaw) : null;

    // Backend has Time field (single time string); frontend has reminderTimes list
    final timeRaw = json['time'] ?? json['Time'];
    List<DateTime> reminderTimes = [];
    if (json['reminderTimes'] is List) {
      reminderTimes = (json['reminderTimes'] as List)
          .map((e) => DateTime.parse(e as String))
          .toList();
    } else if (timeRaw != null && (timeRaw as String).isNotEmpty) {
      final parts = timeRaw.split(':');
      if (parts.length >= 2) {
        final now = DateTime.now();
        reminderTimes = [DateTime(now.year, now.month, now.day,
            int.tryParse(parts[0]) ?? 8, int.tryParse(parts[1]) ?? 0)];
      }
    }

    return Medicine(
      id: id,
      name: name,
      usageInstructions: usageInstructions,
      frequencyType: freqType,
      timesPerDay: timesPerDay,
      reminderTimes: reminderTimes,
      startDate: startDate,
      endDate: endDate,
      notes: notes,
      personId: personId,
      audienceGroup: audienceGroup,
      audienceBirthDate: audienceBirthDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'usageInstructions': usageInstructions,
      'frequencyType': frequencyType.name,
      'timesPerDay': timesPerDay,
      'reminderTimes': reminderTimes.map((e) => e.toIso8601String()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
      'personId': personId,
      'audienceGroup': audienceGroup.name,
      'audienceBirthDate': audienceBirthDate?.toIso8601String(),
    };
  }
}
