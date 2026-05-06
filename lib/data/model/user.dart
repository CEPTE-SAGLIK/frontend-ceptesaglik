

class User {
  final String id;
  final String name;
  final String surname;
  final String email;

  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
  
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'] ?? json['created_at'];
    final parsedCreatedAt = createdAtRaw is String
        ? DateTime.tryParse(createdAtRaw)
        : null;

    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      email: json['email'] as String,

      createdAt: parsedCreatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,

      'createdAt': createdAt.toIso8601String(),
    };
  }
}
