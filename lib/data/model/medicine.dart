enum FrequencyType {
  daily('Her Gün'),
  everyOtherDay('Gün Aşırı'),
  weekly('Haftada Bir'),
  custom('Özel');

  final String label;
  const FrequencyType(this.label);

  static FrequencyType fromLabel(String label) {
    return FrequencyType.values.firstWhere(
      (e) => e.label == label,
      orElse: () => FrequencyType.daily,
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

    // Backend returns Frequency as string label; frontend uses enum
    final freqRaw = json['frequencyType'] ?? json['frequency'] ?? json['Frequency'];
    FrequencyType freqType;
    if (freqRaw != null) {
      freqType = FrequencyType.values.firstWhere(
        (e) => e.name == freqRaw || e.label == freqRaw,
        orElse: () => FrequencyType.daily,
      );
    } else {
      freqType = FrequencyType.daily;
    }

    // startDate / StartDate
    final startRaw = json['startDate'] ?? json['StartDate'];
    final startDate = startRaw != null ? DateTime.parse(startRaw as String) : DateTime.now();

    final endRaw = json['endDate'] ?? json['EndDate'];
    final endDate = endRaw != null ? DateTime.parse(endRaw as String) : null;

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
    };
  }
}
