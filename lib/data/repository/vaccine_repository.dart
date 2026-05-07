import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/vaccine.dart';
import 'package:health_asistants/data/model/vaccine_schedule.dart';
import 'package:health_asistants/data/repository/base_repository.dart';

class VaccineRepository extends BaseRepository {
  VaccineRepository({super.apiClient});

  /// /api/children/{childId}/vaccines → `ApiResponse<List<VaccineScheduleDto>>`
  /// Schedules içinden tüm Vaccine'leri flat olarak döner.
  Future<Result<List<Vaccine>>> getByChildId(String childId) async {
    try {
      final response = await apiClient.get<dynamic>(
        ApiEndpoints.childVaccines(childId),
        fromJson: (json) => json,
      );
      if (response.isSuccess && response.data != null) {
        final schedules = _extractList(response.data);
        final vaccines = <Vaccine>[];
        for (final s in schedules) {
          final vList = s['vaccines'] ?? s['Vaccines'];
          if (vList is List) {
            for (final v in vList) {
              try {
                vaccines.add(Vaccine.fromJson(v as Map<String, dynamic>));
              } catch (_) {}
            }
          }
        }
        return Result.success(vaccines);
      }
      return Result.failure(response.errorMessage ?? 'Aşılar çekilemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// /api/Vaccines/child/{id}  → raw `List<VaccineScheduleDto>` (not wrapped)
  /// /api/Vaccines/person/{id} → raw `List<VaccineDto>`         (not wrapped)
  Future<Result<List<Vaccine>>> getVaccinesForTarget(
      String id, bool isChild) async {
    try {
      final endpoint =
          isChild ? '/api/Vaccines/child/$id' : '/api/Vaccines/person/$id';
      final response = await apiClient.get<dynamic>(
        endpoint,
        fromJson: (json) => json,
      );
      if (response.isSuccess && response.data != null) {
        final raw = _extractList(response.data);
        final vaccines = <Vaccine>[];
        for (final item in raw) {
          // Child: VaccineScheduleDto — içinde 'vaccines' listesi var
          final vList = item['vaccines'] ?? item['Vaccines'];
          if (vList is List) {
            for (final v in vList) {
              try {
                vaccines.add(Vaccine.fromJson(v as Map<String, dynamic>));
              } catch (_) {}
            }
          } else {
            // Person: VaccineDto — doğrudan Vaccine
            try {
              vaccines.add(Vaccine.fromJson(item as Map<String, dynamic>));
            } catch (_) {}
          }
        }
        return Result.success(vaccines);
      }
      return Result.failure(response.errorMessage ?? 'Aşılar çekilemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<String>> addVaccine({
    required String targetId,
    required bool isChild,
    required String name,
    required DateTime date,
    String? dose,
    String? frequency,
    String? description,
  }) async {
    try {
      final body = <String, dynamic>{
        'Name': name,
        'Date': date.toIso8601String(),
        if (dose != null && dose.isNotEmpty) 'Dose': dose,
        if (frequency != null) 'Frequency': frequency,
        if (description != null) 'Description': description,
        'Status': 0,
        if (isChild) 'ChildId': targetId else 'PersonId': targetId,
      };

      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.vaccines,
        body: body,
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final id = response.data!['id']?.toString() ??
            response.data!['Id']?.toString() ??
            '';
        return Result.success(id);
      }
      return Result.failure(response.errorMessage ?? 'Aşı eklenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<bool>> updateStatus(String vaccineId, bool completed) async {
    try {
      final response = await apiClient.post<dynamic>(
        '/api/vaccines/$vaccineId/status',
        body: completed ? 'completed' : 'pending',
        fromJson: (json) => json,
      );
      return response.isSuccess
          ? Result.success(true)
          : Result.failure(response.errorMessage ?? 'Durum güncellenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<bool>> deleteVaccine(String vaccineId) async {
    try {
      final response = await apiClient.delete<Map<String, dynamic>>(
        ApiEndpoints.vaccine(vaccineId),
        fromJson: (json) => json,
      );
      return response.isSuccess
          ? Result.success(true)
          : Result.failure(response.errorMessage ?? 'Silme başarısız');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// /api/children/standard-schedule → `ApiResponse<List<VaccineScheduleDto>>`
  Future<Result<List<VaccineSchedule>>> getStandardSchedule(
      {DateTime? birthDate}) async {
    try {
      String endpoint = '${ApiEndpoints.children}/standard-schedule';
      if (birthDate != null) {
        endpoint += '?birthDate=${birthDate.toIso8601String()}';
      }
      final response = await apiClient.get<dynamic>(
        endpoint,
        fromJson: (json) => json,
      );
      if (response.isSuccess && response.data != null) {
        final raw = _extractList(response.data);
        return Result.success(
            raw.map((s) => VaccineSchedule.fromJson(s as Map<String, dynamic>)).toList());
      }
      return Result.failure(response.errorMessage ?? 'Standart takvim çekilemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<List<Vaccine>>> getOverdueVaccines() async {
    try {
      final response = await apiClient.get<dynamic>(
        '${ApiEndpoints.vaccines}/overdue',
        fromJson: (json) => json,
      );
      if (response.isSuccess && response.data != null) {
        final raw = _extractList(response.data);
        return Result.success(
            raw.map((v) => Vaccine.fromJson(v as Map<String, dynamic>)).toList());
      }
      return Result.failure(response.errorMessage ?? 'Gecikmiş aşılar alınamadı');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<List<Vaccine>>> getUpcomingVaccines() async {
    try {
      final response = await apiClient.get<dynamic>(
        '${ApiEndpoints.vaccines}/upcoming',
        fromJson: (json) => json,
      );
      if (response.isSuccess && response.data != null) {
        final raw = _extractList(response.data);
        return Result.success(
            raw.map((v) => Vaccine.fromJson(v as Map<String, dynamic>)).toList());
      }
      return Result.success([]);
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  /// JSON response'u düz listeye çevirir.
  /// Backend ya raw list döner ya da ApiResponse {data: [...]} wrapper'ı içinde döner.
  List<dynamic> _extractList(dynamic json) {
    if (json is List) return json;
    if (json is Map) {
      final inner = json['data'] ?? json['Data'];
      if (inner is List) return inner;
    }
    return [];
  }
}
