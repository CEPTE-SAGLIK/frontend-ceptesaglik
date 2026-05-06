import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/medicine.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

class MedicineRepository extends BaseRepository {
  final UserRepository _userRepository;
  String? _userId;

  MedicineRepository({
    super.apiClient,
    required UserRepository userRepository,
  }) : _userRepository = userRepository;

  Future<void> _ensureUserId() async {
    if (_userId != null) return;
    final result = await _userRepository.getCurrentUser();
    if (result.isSuccess && result.data != null) {
      _userId = result.data!.id;
    }
  }

  /// Kullanıcıya ait ilaçları getir
  Future<Result<List<Medicine>>> getAll() async {
    try {
      await _ensureUserId();
      if (_userId == null) return Result.failure('Kullanıcı bilgisi alınamadı');

      final response = await apiClient.get<List<Medicine>>(
        '/api/medicines/user/$_userId',
        fromJson: (json) {
          final list = json is List ? json : <dynamic>[];
          return list
              .map((j) => Medicine.fromJson(j as Map<String, dynamic>))
              .toList();
        },
      );
      if (response.isSuccess) return Result.success(response.data ?? []);
      return Result.failure(response.errorMessage ?? 'İlaçlar yüklenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// Tek ilaç getir
  Future<Result<Medicine>> getById(String id) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.medicine(id),
        fromJson: (json) => json,
      );
      if (response.isSuccess && response.data != null) {
        return Result.success(Medicine.fromJson(response.data!));
      }
      return Result.failure(response.errorMessage ?? 'İlaç bulunamadı');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// Yeni ilaç ekle
  Future<Result<Medicine>> create(Medicine medicine) async {
    try {
      await _ensureUserId();
      if (_userId == null) return Result.failure('Kullanıcı bilgisi alınamadı');

      final body = _toCreateDto(medicine, _userId!);
      final response = await apiClient.post<dynamic>(
        ApiEndpoints.medicines,
        body: body,
        fromJson: (json) => json,
      );
      if (response.isSuccess && response.data != null) {
        final data = response.data;
        final String createdId;
        if (data is Map) {
          createdId = data['id']?.toString() ?? data['Id']?.toString() ?? medicine.id;
        } else {
          createdId = data.toString();
        }
        return Result.success(medicine.copyWith(id: createdId));
      }
      return Result.failure(response.errorMessage ?? 'İlaç eklenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// İlaç güncelle
  Future<Result<Medicine>> update(Medicine medicine) async {
    try {
      await _ensureUserId();
      if (_userId == null) return Result.failure('Kullanıcı bilgisi alınamadı');
      final body = _toCreateDto(medicine, _userId!);
      final response = await apiClient.put<Map<String, dynamic>>(
        ApiEndpoints.medicine(medicine.id),
        body: body,
        fromJson: (json) => json,
      );
      if (response.isSuccess) return Result.success(medicine);
      return Result.failure(response.errorMessage ?? 'İlaç güncellenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// İlaç sil
  Future<Result<bool>> delete(String id) async {
    try {
      final response = await apiClient.delete<dynamic>(
        ApiEndpoints.medicine(id),
        fromJson: (json) => json,
      );
      return response.isSuccess
          ? Result.success(true)
          : Result.failure(response.errorMessage ?? 'Silinemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// Backend RepeatType: None=0, Daily=1, Weekly=2, Monthly=3
  int _frequencyToRepeatType(FrequencyType type) {
    switch (type) {
      case FrequencyType.daily:
      case FrequencyType.everyOtherDay:
        return 1;
      case FrequencyType.weekly:
        return 2;
      case FrequencyType.monthly:
        return 3;
      case FrequencyType.custom:
        return 0;
    }
  }

  Map<String, dynamic> _toCreateDto(Medicine medicine, String userId) {
    return {
      'UserId': userId,
      'Name': medicine.name,
      'Frequency': medicine.frequencyType.label,
      'Time': medicine.reminderTimes.isNotEmpty
          ? '${medicine.reminderTimes.first.hour.toString().padLeft(2, '0')}:${medicine.reminderTimes.first.minute.toString().padLeft(2, '0')}'
          : '08:00',
      'Notes': medicine.notes,
      'UsageInstructions': medicine.usageInstructions,
      'TimesPerDay': medicine.timesPerDay,
      'StartDate': medicine.startDate.toIso8601String(),
      'EndDate': medicine.endDate?.toIso8601String(),
      'RepeatType': _frequencyToRepeatType(medicine.frequencyType),
    };
  }
}
