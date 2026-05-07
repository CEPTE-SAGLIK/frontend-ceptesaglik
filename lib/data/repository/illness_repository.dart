import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/illness.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

class IllnessRepository extends BaseRepository {
  final UserRepository _userRepository;
  String? _personId;

  IllnessRepository({
    required ApiClient apiClient,
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(apiClient: apiClient);

  Future<void> _ensurePersonId() async {
    if (_personId != null) return;
    final result = await _userRepository.getCurrentPerson();
    if (result.isSuccess && result.data != null) {
      _personId = result.data!.id;
    }
  }

  Future<Result<List<Illness>>> getIllnesses() async {
    await _ensurePersonId();
    if (_personId == null) return Result.failure('Profil bilgisi alınamadı');

    final response = await apiClient.get<List<Illness>>(
      ApiEndpoints.illnessesByPerson(_personId!),
      fromJson: (data) =>
          (data as List).map((e) => Illness.fromJson(e)).toList(),
    );

    if (response.isSuccess) return Result.success(response.data ?? []);
    return Result.failure(response.errorMessage ?? 'Hastalıklar alınamadı');
  }

  Future<Result<bool>> addIllness(
      String name, String status, String? doctorNotes) async {
    await _ensurePersonId();
    if (_personId == null) return Result.failure('Profil bilgisi alınamadı');

    final body = {
      'personId': _personId,
      'name': name,
      'diagnosisDate': DateTime.now().toIso8601String(),
      'status': status,
      'doctorNotes': doctorNotes,
    };

    final response = await apiClient.post(ApiEndpoints.addIllness, body: body);
    if (response.isSuccess) return Result.success(true);
    return Result.failure(response.errorMessage ?? 'Eklenemedi');
  }

  Future<Result<bool>> deleteIllness(String id) async {
    final response = await apiClient.delete(ApiEndpoints.illness(id));
    if (response.isSuccess) return Result.success(true);
    return Result.failure(response.errorMessage ?? 'Silinemedi');
  }
}
