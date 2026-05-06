import 'package:health_asistants/data/model/vaccine.dart';

/// Cinsiyet
enum ChildGender {
  male('Erkek'),
  female('Kız');

  final String label;
  const ChildGender(this.label);

  static ChildGender fromString(String value) {
    return ChildGender.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ChildGender.male,
    );
  }
}

/// Çocuk modeli — aşı takvimi her çocuğa özeldir.
class Child {
  final String id;
  final String name;
  final DateTime birthDate;
  final ChildGender gender;
  final List<BabyVaccineSchedule> vaccineSchedule;

  const Child({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    this.vaccineSchedule = const [],
  });

  Child copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    ChildGender? gender,
    List<BabyVaccineSchedule>? vaccineSchedule,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      vaccineSchedule: vaccineSchedule ?? this.vaccineSchedule,
    );
  }

  /// Çocuğun ay cinsinden yaşı
  int get ageInMonths {
    final now = DateTime.now();
    return (now.year - birthDate.year) * 12 + now.month - birthDate.month;
  }

  /// Okunabilir yaş metni
  String get ageText {
    final months = ageInMonths;
    if (months < 1) return 'Yenidoğan';
    if (months < 12) return '$months aylık';
    final years = months ~/ 12;
    final remaining = months % 12;
    if (remaining == 0) return '$years yaşında';
    return '$years yıl $remaining ay';
  }

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: ChildGender.fromString(json['gender'] as String? ?? 'male'),
      vaccineSchedule:
          (json['vaccineSchedule'] as List<dynamic>?)
              ?.map(
                (e) => BabyVaccineSchedule.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender.name,
      'vaccineSchedule': vaccineSchedule.map((e) => e.toJson()).toList(),
    };
  }
}
