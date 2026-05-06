enum AllergyLevel {
  mild('Hafif'),
  moderate('Orta'),
  severe('Ağır');

  final String label;
  const AllergyLevel(this.label);

  static AllergyLevel fromString(String value) {
    return AllergyLevel.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AllergyLevel.mild,
    );
  }
}

class Allergy {
  final String id;
  final String name;
  final AllergyLevel level;
  final String? description;
  final DateTime createdDate;

  Allergy({
    required this.id,
    required this.name,
    this.level = AllergyLevel.mild,
    this.description,
    required this.createdDate,
  });

  Allergy copyWith({
    String? id,
    String? name,
    AllergyLevel? level,
    String? description,
    DateTime? createdDate,
  }) {
    return Allergy(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      level: AllergyLevel.fromString(
          (json['level'] ?? json['Level'] ?? 'mild').toString()),
      description: (json['description'] ?? json['Description']) as String?,
      createdDate: DateTime.parse(
          (json['createdDate'] ?? json['CreatedDate']) as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level.name,
      'description': description,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}
