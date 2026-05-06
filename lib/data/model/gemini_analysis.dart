class GeminiAnalysisResponse {
  final List<ExtractedMedicine> medicines;
  final List<ExtractedReminder> reminders;

  GeminiAnalysisResponse({
    required this.medicines,
    required this.reminders,
  });

  factory GeminiAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return GeminiAnalysisResponse(
      medicines: List<ExtractedMedicine>.from(
          (json["medicines"] ?? []).map((x) => ExtractedMedicine.fromJson(x))),
      reminders: List<ExtractedReminder>.from(
          (json["reminders"] ?? []).map((x) => ExtractedReminder.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "medicines": medicines.map((x) => x.toJson()).toList(),
      "reminders": reminders.map((x) => x.toJson()).toList(),
    };
  }
}

class ExtractedMedicine {
  final String name;
  final String frequencyType;
  final int timesPerDay;
  final String? usageInstructions;

  ExtractedMedicine({
    required this.name,
    required this.frequencyType,
    required this.timesPerDay,
    this.usageInstructions,
  });

  factory ExtractedMedicine.fromJson(Map<String, dynamic> json) {
    return ExtractedMedicine(
      name: json["name"] ?? '',
      frequencyType: json["frequencyType"] ?? 'Her Gün',
      timesPerDay: json["timesPerDay"] ?? 1,
      usageInstructions: json["usageInstructions"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "frequencyType": frequencyType,
      "timesPerDay": timesPerDay,
      "usageInstructions": usageInstructions,
    };
  }
}

class ExtractedReminder {
  final String title;
  final String type;
  final DateTime dateTime;

  ExtractedReminder({
    required this.title,
    required this.type,
    required this.dateTime,
  });

  factory ExtractedReminder.fromJson(Map<String, dynamic> json) {
    return ExtractedReminder(
      title: json["title"] ?? '',
      type: json["type"] ?? '',
      dateTime: json["dateTime"] != null 
          ? DateTime.parse(json["dateTime"]) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "type": type,
      "dateTime": dateTime.toIso8601String(),
    };
  }
}
