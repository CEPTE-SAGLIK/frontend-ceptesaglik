import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/illness.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

class IllnessRepository extends BaseRepository {
  final UserRepository _userRepository;

  IllnessRepository({
    required ApiClient apiClient,
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(apiClient: apiClient);

  Future<Result<({Person self, List<Person> all})>> getPersons() async {
    final selfResult = await _userRepository.getCurrentPerson();
    if (!selfResult.isSuccess || selfResult.data == null) {
      return Result.failure('Profil bilgisi alınamadı');
    }
    final self = selfResult.data!;
    final familyResult = await _userRepository.getFamilyMembers();
    final family = (familyResult.isSuccess ? familyResult.data : null) ?? [];
    return Result.success((self: self, all: [self, ...family]));
  }

  Future<Result<List<Illness>>> getIllnessesByPerson(String personId) async {
    final response = await apiClient.get<List<Illness>>(
      ApiEndpoints.illnessesByPerson(personId),
      fromJson: (data) =>
          (data as List).map((e) => Illness.fromJson(e)).toList(),
    );
    if (response.isSuccess) return Result.success(response.data ?? []);
    return Result.failure(response.errorMessage ?? 'Hastalıklar alınamadı');
  }

  Future<Result<bool>> addIllness({
    required String personId,
    required String name,
    required String status,
    String? doctorNotes,
  }) async {
    final body = {
      'personId': personId,
      'name': name,
      'diagnosisDate': DateTime.now().toIso8601String(),
      'status': status,
      'doctorNotes': doctorNotes,
    };
    final response = await apiClient.post(ApiEndpoints.addIllness, body: body);
    if (response.isSuccess) return Result.success(true);
    return Result.failure(response.errorMessage ?? 'Eklenemedi');
  }

  Future<Result<bool>> updateIllness({
    required String id,
    required String name,
    required String status,
    String? doctorNotes,
  }) async {
    final body = {'name': name, 'status': status, 'doctorNotes': doctorNotes};
    final response = await apiClient.put(ApiEndpoints.illness(id), body: body);
    if (response.isSuccess) return Result.success(true);
    return Result.failure(response.errorMessage ?? 'Güncellenemedi');
  }

  Future<Result<bool>> deleteIllness(String id) async {
    final response = await apiClient.delete(ApiEndpoints.illness(id));
    if (response.isSuccess) return Result.success(true);
    return Result.failure(response.errorMessage ?? 'Silinemedi');
  }
}
