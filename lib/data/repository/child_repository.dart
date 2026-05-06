import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/child.dart';
import 'package:health_asistants/data/model/vaccine.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

class ChildRepository extends BaseRepository {
  final UserRepository? _userRepository;

  ChildRepository({
    ApiClient? apiClient,
    UserRepository? userRepository,
  })  : _userRepository = userRepository,
        super(apiClient: apiClient);

  // ─────────────────────────────────────
  // Çocuk CRUD
  // ─────────────────────────────────────

  Future<Result<List<Child>>> getAll() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.children,
        fromJson: (json) => json,
      );
      if (response.isSuccess && response.data != null) {
        final raw =
            response.data!['data'] ?? response.data!['Data'] ?? [];
        if (raw is List) {
          return Result.success(
            raw
                .map((e) => Child.fromJson(e as Map<String, dynamic>))
                .toList(),
          );
        }
      }
      return Result.failure(
          response.errorMessage ?? 'Çocuklar yüklenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<Child>> getById(String id) async {
    final allResult = await getAll();
    if (!allResult.isSuccess) return Result.failure(allResult.error!);
    try {
      final child = allResult.data!.firstWhere((c) => c.id == id);
      return Result.success(child);
    } catch (_) {
      return Result.failure('Çocuk bulunamadı');
    }
  }

  Future<Result<Child>> create({
    required String name,
    required DateTime birthDate,
    required ChildGender gender,
  }) async {
    try {
      final userResult = await _userRepository?.getCurrentUser();
      if (userResult == null || !userResult.isSuccess || userResult.data == null) {
        return Result.failure('Kullanıcı bilgisi alınamadı');
      }

      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.children,
        body: {
          'Name': name,
          'BirthDate': birthDate.toIso8601String(),
          'Gender': gender == ChildGender.female ? 1 : 0,
          'UserId': userResult.data!.id,
        },
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final raw =
            response.data!['data'] ?? response.data!['Data'] ?? response.data!;
        return Result.success(Child.fromJson(raw as Map<String, dynamic>));
      }
      return Result.failure(response.errorMessage ?? 'Çocuk eklenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<Child>> update(Child child) async {
    try {
      final response = await apiClient.put<Map<String, dynamic>>(
        '${ApiEndpoints.child(child.id)}/physical-info',
        body: {
          'gender': child.gender == ChildGender.female ? 'Female' : 'Male',
        },
        fromJson: (json) => json,
      );
      if (response.isSuccess) return Result.success(child);
      return Result.failure(response.errorMessage ?? 'Çocuk güncellenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<bool>> delete(String id) async {
    try {
      final response = await apiClient.delete<Map<String, dynamic>>(
        ApiEndpoints.child(id),
        fromJson: (json) => json,
      );
      return response.isSuccess
          ? Result.success(true)
          : Result.failure(response.errorMessage ?? 'Çocuk silinemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  // ─────────────────────────────────────
  // Aşı İşlemleri
  // ─────────────────────────────────────

  Future<Result<Child>> updateVaccineStatus(
    String childId,
    String scheduleId,
    String vaccineId,
    VaccineStatus status,
  ) async {
    try {
      final statusStr =
          status == VaccineStatus.completed ? 'completed' : 'pending';

      final response = await apiClient.post<dynamic>(
        '/api/vaccines/$vaccineId/status',
        body: statusStr,
        fromJson: (json) => json,
      );

      if (!response.isSuccess) {
        return Result.failure(
            response.errorMessage ?? 'Aşı durumu güncellenemedi');
      }

      return getById(childId);
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<Child>> addManualVaccine(
    String childId,
    String scheduleId,
    Vaccine vaccine,
  ) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '${ApiEndpoints.child(childId)}/vaccines',
        body: {
          'VaccineName': vaccine.name,
          'DateAdministered': vaccine.date.toIso8601String(),
        },
        fromJson: (json) => json,
      );

      if (!response.isSuccess) {
        return Result.failure(response.errorMessage ?? 'Aşı eklenemedi');
      }

      return getById(childId);
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<Child>> deleteVaccine(
    String childId,
    String scheduleId,
    String vaccineId,
  ) async {
    try {
      final response = await apiClient.delete<Map<String, dynamic>>(
        '/api/vaccines/$vaccineId',
        fromJson: (json) => json,
      );

      if (!response.isSuccess) {
        return Result.failure(response.errorMessage ?? 'Aşı silinemedi');
      }

      return getById(childId);
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }
}
