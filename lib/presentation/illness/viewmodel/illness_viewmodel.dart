import 'package:flutter/material.dart';
import 'package:health_asistants/data/model/illness.dart';
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

class IllnessViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final UserRepository _userRepository;

  List<Illness> _illnesses = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _personId;

  IllnessViewModel({
    required ApiClient apiClient,
    required UserRepository userRepository,
  })  : _apiClient = apiClient,
        _userRepository = userRepository;

  List<Illness> get illnesses => _illnesses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _ensurePersonId() async {
    if (_personId != null) return;
    final result = await _userRepository.getCurrentPerson();
    if (result.isSuccess && result.data != null) {
      _personId = result.data!.id;
    }
  }

  Future<void> fetchIllnesses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _ensurePersonId();
    if (_personId == null) {
      _isLoading = false;
      _errorMessage = 'Profil bilgisi alınamadı';
      notifyListeners();
      return;
    }

    final response = await _apiClient.get<List<Illness>>(
      ApiEndpoints.illnessesByPerson(_personId!),
      fromJson: (data) =>
          (data as List).map((e) => Illness.fromJson(e)).toList(),
    );

    if (response.isSuccess) {
      _illnesses = response.data ?? [];
    } else {
      _errorMessage = response.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addIllness(String name, String status, String? doctorNotes) async {
    await _ensurePersonId();
    if (_personId == null) return false;

    final body = {
      'personId': _personId,
      'name': name,
      'diagnosisDate': DateTime.now().toIso8601String(),
      'status': status,
      'doctorNotes': doctorNotes,
    };

    final response = await _apiClient.post(ApiEndpoints.addIllness, body: body);

    if (response.isSuccess) {
      await fetchIllnesses();
      return true;
    }
    _errorMessage = response.errorMessage;
    notifyListeners();
    return false;
  }

  Future<bool> deleteIllness(dynamic id) async {
    final response =
        await _apiClient.delete(ApiEndpoints.illness(id.toString()));

    if (response.isSuccess) {
      _illnesses.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    }
    _errorMessage = response.errorMessage;
    notifyListeners();
    return false;
  }
}
