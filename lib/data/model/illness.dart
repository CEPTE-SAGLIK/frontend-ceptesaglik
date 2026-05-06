enum IllnessStatus { active, recovered, monitoring }

class Illness {
  final String id;
  final String name;
  final DateTime diagnosisDate;
  final IllnessStatus status;
  final String? doctorNotes;

  Illness({
    required this.id,
    required this.name,
    required this.diagnosisDate,
    required this.status,
    this.doctorNotes,
  });

  factory Illness.fromJson(Map<String, dynamic> json) {
    return Illness(
      id: json['id'] as String,
      name: json['name'] as String,
      diagnosisDate: DateTime.parse(json['diagnosisDate'] as String),
      status: IllnessStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => IllnessStatus.active,
      ),
      doctorNotes: json['doctorNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'diagnosisDate': diagnosisDate.toIso8601String(),
      'status': status.name,
      'doctorNotes': doctorNotes,
    };
  }
}
