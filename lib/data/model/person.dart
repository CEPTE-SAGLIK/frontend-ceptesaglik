import 'package:health_asistants/data/model/allergy.dart';
import 'package:health_asistants/data/model/illness.dart';
import 'package:health_asistants/data/model/medicine.dart';
import 'package:health_asistants/data/model/vaccine.dart';

enum Gender { male, female }

Gender _genderFromApiValue(String? value) {
  switch (value?.toLowerCase()) {
    case 'female':
      return Gender.female;
    case 'male':
      return Gender.male;
    default:
      return Gender.male;
  }
}

String _genderToApiValue(Gender gender) {
  switch (gender) {
    case Gender.female:
      return 'Female';
    case Gender.male:
      return 'Male';
  }
}

class Person {
  final String id;
  final String userId;
  final String name;
  final String surname;
  final String? relationship;
  final DateTime birthDate;
  final Gender gender;
  final double? height;
  final double? weight;
  final DateTime? createdAt;
  final List<Illness> illnesses;
  final List<Allergy> allergies;
  final List<Medicine> medicines;
  final List<Vaccine> vaccines;
  final bool isChild;

  Person({
    required this.id,
    required this.userId,
    required this.name,
    required this.surname,
    this.relationship,
    required this.birthDate,
    required this.gender,
    this.height,
    this.weight,
    this.createdAt,
    this.illnesses = const [],
    this.allergies = const [],
    this.medicines = const [],
    this.vaccines = const [],
    this.isChild = false,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      relationship: json['relationship'] as String?,
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: _genderFromApiValue(json['gender'] as String?),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,

      illnesses:
          ((json['illnesses'] ?? json['chronicDiseases']) as List<dynamic>?)
              ?.map((e) {
                if (e is Map<String, dynamic>) {
                  return Illness.fromJson(e);
                } else if (e is String) {
                  return Illness(
                    id: '',
                    name: e,
                    diagnosisDate: DateTime.now(),
                    status: IllnessStatus.active,
                  );
                }
                return null;
              })
              .whereType<Illness>()
              .toList() ??
          [],
      allergies:
          (json['allergies'] as List<dynamic>?)
              ?.map((e) {
                if (e is Map<String, dynamic>) {
                  return Allergy.fromJson(e);
                } else if (e is String) {
                  return Allergy(id: '', name: e, createdDate: DateTime.now());
                }
                return null;
              })
              .whereType<Allergy>()
              .toList() ??
          [],

      medicines:
          (json['medicines'] as List<dynamic>?)
              ?.map((e) {
                if (e is Map<String, dynamic>) return Medicine.fromJson(e);
                return null;
              })
              .whereType<Medicine>()
              .toList() ??
          [],
      vaccines:
          (json['vaccines'] as List<dynamic>?)
              ?.map((e) {
                if (e is Map<String, dynamic>) return Vaccine.fromJson(e);
                return null;
              })
              .whereType<Vaccine>()
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'surname': surname,
      'birthDate': birthDate.toIso8601String(),
      'gender': _genderToApiValue(gender),
      'height': height,
      'weight': weight,
      if (relationship != null) 'relationship': relationship,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      'illnesses': illnesses.map((e) => e.toJson()).toList(),
      'allergies': allergies.map((e) => e.toJson()).toList(),
      'medicines': medicines.map((e) => e.toJson()).toList(),
      'vaccines': vaccines.map((e) => e.toJson()).toList(),
    };
  }
}
