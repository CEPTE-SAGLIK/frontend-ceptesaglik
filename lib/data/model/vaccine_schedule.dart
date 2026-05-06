import 'package:health_asistants/data/model/vaccine.dart';

class VaccineSchedule {
  final String id;
  final String period;
  final int monthIndex;
  final DateTime scheduledDate;
  final List<Vaccine> vaccines;
  final bool isAllCompleted;
  final int completedCount;
  final int pendingCount;

  VaccineSchedule({
    required this.id,
    required this.period,
    required this.monthIndex,
    required this.scheduledDate,
    required this.vaccines,
    required this.isAllCompleted,
    required this.completedCount,
    required this.pendingCount,
  });

  factory VaccineSchedule.fromJson(Map<String, dynamic> json) {
    final rawDate = json['scheduledDate'] ?? json['ScheduledDate'];
    return VaccineSchedule(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      period: (json['period'] ?? json['Period'] ?? 'Bilinmeyen Dönem').toString(),
      monthIndex:
          int.tryParse((json['monthIndex'] ?? json['MonthIndex'] ?? 0).toString()) ?? 0,
      scheduledDate:
          rawDate != null ? DateTime.parse(rawDate.toString()) : DateTime.now(),
      vaccines: ((json['vaccines'] ?? json['Vaccines']) as List?)
              ?.map((v) => Vaccine.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      isAllCompleted:
          (json['isAllCompleted'] ?? json['IsAllCompleted']) as bool? ?? false,
      completedCount: int.tryParse(
              (json['completedCount'] ?? json['CompletedCount'] ?? 0)
                  .toString()) ??
          0,
      pendingCount: int.tryParse(
              (json['pendingCount'] ?? json['PendingCount'] ?? 0).toString()) ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period,
      'monthIndex': monthIndex,
      'scheduledDate': scheduledDate.toIso8601String(),
      'vaccines': vaccines.map((v) => v.toJson()).toList(),
      'isAllCompleted': isAllCompleted,
      'completedCount': completedCount,
      'pendingCount': pendingCount,
    };
  }
}
