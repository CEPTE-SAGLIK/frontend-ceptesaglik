/// Aşı durumu
enum VaccineStatus {
  pending('Bekliyor'),
  completed('Tamamlandı'),
  overdue('Gecikmiş'),
  skipped('Atlandı');

  final String label;
  const VaccineStatus(this.label);

  static VaccineStatus fromString(String value) {
    return VaccineStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => VaccineStatus.pending,
    );
  }
}

/// Aşı kaydı modeli — çocuğa bağlı aşı takibi
class Vaccine {
  final String id;
  final String name;
  final DateTime date;
  final String dose;
  final VaccineStatus status;
  final String? description;
  final DateTime? nextDoseDate;
  final DateTime? completedDate;
  final String? childId;

  const Vaccine({
    required this.id,
    required this.name,
    required this.date,
    required this.dose,
    this.status = VaccineStatus.pending,
    this.description,
    this.nextDoseDate,
    this.completedDate,
    this.childId,
  });

  Vaccine copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? dose,
    VaccineStatus? status,
    String? description,
    DateTime? nextDoseDate,
    DateTime? completedDate,
    String? childId,
  }) {
    return Vaccine(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      dose: dose ?? this.dose,
      status: status ?? this.status,
      description: description ?? this.description,
      nextDoseDate: nextDoseDate ?? this.nextDoseDate,
      completedDate: completedDate ?? this.completedDate,
      childId: childId ?? this.childId,
    );
  }

  /// Aşı tamamlandı mı?
  bool get isCompleted => status == VaccineStatus.completed;

  /// Aşı gecikmiş mi? (sadece tarihi geçmişse — bugün dahil değil)
  bool get isOverdue {
    if (status != VaccineStatus.pending) return false;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final vaccineDay = DateTime(date.year, date.month, date.day);
    return vaccineDay.isBefore(today);
  }

  /// Yaklaşan aşı mı? (bugün veya 30 gün içinde)
  bool get isUpcoming {
    if (status != VaccineStatus.pending) return false;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final vaccineDay = DateTime(date.year, date.month, date.day);
    return !vaccineDay.isBefore(today) &&
        vaccineDay.isBefore(today.add(const Duration(days: 30)));
  }

  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      dose: json['dose'] as String,
      status: VaccineStatus.fromString(json['status'] as String? ?? 'pending'),
      description: json['description'] as String?,
      nextDoseDate: json['nextDoseDate'] != null
          ? DateTime.parse(json['nextDoseDate'] as String)
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      childId: json['childId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'dose': dose,
      'status': status.name,
      'description': description,
      'nextDoseDate': nextDoseDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'childId': childId,
    };
  }
}

/// Aşı takvimi dönem modeli — çocuğun doğum tarihine göre oluşturulur
class BabyVaccineSchedule {
  final String id;
  final String period;
  final int monthIndex;
  final DateTime scheduledDate;
  final List<Vaccine> vaccines;

  const BabyVaccineSchedule({
    required this.id,
    required this.period,
    required this.monthIndex,
    required this.scheduledDate,
    required this.vaccines,
  });

  /// Dönemdeki tüm aşılar tamamlandı mı?
  bool get isAllCompleted =>
      vaccines.isNotEmpty && vaccines.every((v) => v.isCompleted);

  /// Tamamlanan aşı sayısı
  int get completedCount => vaccines.where((v) => v.isCompleted).length;

  /// Bekleyen aşı sayısı
  int get pendingCount => vaccines.where((v) => !v.isCompleted).length;

  /// Bu dönem geçmiş mi?
  bool get isPast => scheduledDate.isBefore(DateTime.now());

  /// Bu dönem yaklaşıyor mu? (30 gün içinde)
  bool get isUpcoming =>
      scheduledDate.isAfter(DateTime.now()) &&
      scheduledDate.isBefore(DateTime.now().add(const Duration(days: 30)));

  factory BabyVaccineSchedule.fromJson(Map<String, dynamic> json) {
    return BabyVaccineSchedule(
      id: json['id'] as String,
      period: json['period'] as String,
      monthIndex: json['monthIndex'] as int,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      vaccines: (json['vaccines'] as List<dynamic>)
          .map((e) => Vaccine.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period,
      'monthIndex': monthIndex,
      'scheduledDate': scheduledDate.toIso8601String(),
      'vaccines': vaccines.map((v) => v.toJson()).toList(),
    };
  }
}
