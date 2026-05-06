import 'package:flutter/material.dart';
import 'package:health_asistants/data/model/allergy.dart';
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

class AllergyViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final UserRepository _userRepository;

  List<Allergy> _allergies = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _personId;

  AllergyViewModel({
    required ApiClient apiClient,
    required UserRepository userRepository,
  })  : _apiClient = apiClient,
        _userRepository = userRepository;

  List<Allergy> get allergies => _allergies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _ensurePersonId() async {
    if (_personId != null) return;
    final result = await _userRepository.getCurrentPerson();
    if (result.isSuccess && result.data != null) {
      _personId = result.data!.id;
    }
  }

  Future<void> fetchAllergies() async {
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

    final response = await _apiClient.get<List<Allergy>>(
      ApiEndpoints.allergiesByPerson(_personId!),
      fromJson: (data) =>
          (data as List).map((e) => Allergy.fromJson(e)).toList(),
    );

    if (response.isSuccess) {
      _allergies = response.data ?? [];
    } else {
      _errorMessage = response.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addAllergy(String name, {AllergyLevel? level, String? description}) async {
    await _ensurePersonId();
    if (_personId == null) return false;

    final body = {
      'personId': _personId,
      'name': name,
      'createdDate': DateTime.now().toIso8601String(),
      if (level != null) 'level': level.name,
      if (description != null) 'description': description,
    };

    final response = await _apiClient.post(ApiEndpoints.addAllergy, body: body);

    if (response.isSuccess) {
      await fetchAllergies();
      return true;
    }
    _errorMessage = response.errorMessage;
    notifyListeners();
    return false;
  }

  Future<bool> deleteAllergy(dynamic id) async {
    final response =
        await _apiClient.delete(ApiEndpoints.allergy(id.toString()));

    if (response.isSuccess) {
      _allergies.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    }
    _errorMessage = response.errorMessage;
    notifyListeners();
    return false;
  }
}
