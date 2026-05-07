import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/data/repository/base_repository.dart';

class ReminderRepository extends BaseRepository {
  ReminderRepository({super.apiClient});

  /// Kullanıcıya ait tüm hatırlatmaları getirir (gerçek + sanal ilaç/aşı hatırlatmaları)
  Future<Result<List<Reminder>>> getAll(String userId) async {
    try {
      final response = await apiClient.get<List<Reminder>>(
        ApiEndpoints.reminder(userId),
        fromJson: (json) {
          final list = json is List ? json : <dynamic>[];
          return list
              .map((j) => Reminder.fromJson(j as Map<String, dynamic>))
              .toList();
        },
      );
      if (response.isSuccess) {
        final reminders = response.data ?? [];
        reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        return Result.success(reminders);
      }
      return Result.failure(response.errorMessage ?? 'Hatırlatmalar yüklenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// Belirli bir tarihe ait hatırlatmaları getirir
  Future<Result<List<Reminder>>> getByDate(DateTime date, String userId) async {
    final allResult = await getAll(userId);
    if (!allResult.isSuccess) return Result.failure(allResult.error!);
    final filtered = allResult.data!.where((r) =>
        r.dateTime.year == date.year &&
        r.dateTime.month == date.month &&
        r.dateTime.day == date.day).toList();
    return Result.success(filtered);
  }

  /// Yeni hatırlatma ekle
  Future<Result<Reminder>> create(Reminder reminder) async {
    try {
      final body = {
        'UserId': reminder.personId,
        'Title': reminder.title,
        'Description': reminder.description,
        'ReminderDate': reminder.dateTime.toIso8601String(),
        'Type': _typeToInt(reminder.type),
        'RepeatType': _repeatToInt(reminder.repeatType),
        'IsActive': reminder.isActive,
        'RelatedItemId': reminder.relatedItemId,
        'MedicineId': reminder.type == ReminderType.medicine ? reminder.relatedItemId : null,
        'VaccineId': reminder.type == ReminderType.vaccine ? reminder.relatedItemId : null,
      };
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.reminders,
        body: body,
        fromJson: (json) => json,
      );
      if (response.isSuccess && response.data != null) {
        return Result.success(Reminder.fromJson(response.data!));
      }
      return Result.failure(response.errorMessage ?? 'Hatırlatma eklenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// Hatırlatma güncelle
  Future<Result<Reminder>> update(Reminder reminder) async {
    try {
      final body = {
        'UserId': reminder.personId,
        'Title': reminder.title,
        'Description': reminder.description,
        'ReminderDate': reminder.dateTime.toIso8601String(),
        'Type': _typeToInt(reminder.type),
        'RepeatType': _repeatToInt(reminder.repeatType),
        'IsActive': reminder.isActive,
        'RelatedItemId': reminder.relatedItemId,
      };
      final response = await apiClient.put<Map<String, dynamic>>(
        ApiEndpoints.reminder(reminder.id),
        body: body,
        fromJson: (json) => json,
      );
      if (response.isSuccess && response.data != null) {
        return Result.success(Reminder.fromJson(response.data!));
      }
      return Result.failure(response.errorMessage ?? 'Hatırlatma güncellenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// Hatırlatma sil
  Future<Result<bool>> delete(String id) async {
    try {
      final response = await apiClient.delete<dynamic>(
        ApiEndpoints.reminder(id),
        fromJson: (json) => json,
      );
      return response.isSuccess
          ? Result.success(true)
          : Result.failure(response.errorMessage ?? 'Silinemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// Tamamlandı durumunu değiştir (local update + backend sync)
  Future<Result<Reminder>> toggleComplete(Reminder reminder) async {
    final updated = Reminder(
      id: reminder.id,
      personId: reminder.personId,
      title: reminder.title,
      description: reminder.description,
      type: reminder.type,
      dateTime: reminder.dateTime,
      repeatType: reminder.repeatType,
      isActive: !reminder.isActive,
      relatedItemId: reminder.relatedItemId,
      createdAt: reminder.createdAt,
    );
    return update(updated);
  }

  int _typeToInt(ReminderType type) {
    switch (type) {
      case ReminderType.medicine:
        return 0;
      case ReminderType.vaccine:
        return 1;
      case ReminderType.appointment:
        return 2;
      case ReminderType.custom:
        return 3;
    }
  }

  int _repeatToInt(RepeatType repeat) {
    switch (repeat) {
      case RepeatType.none:
        return 0;
      case RepeatType.daily:
        return 1;
      case RepeatType.weekly:
        return 2;
      case RepeatType.monthly:
        return 3;
    }
  }
}
