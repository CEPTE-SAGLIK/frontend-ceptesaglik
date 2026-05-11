import 'package:flutter/material.dart';
import 'package:health_asistants/data/model/allergy.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

class AllergyViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final UserRepository _userRepository;

  List<Allergy> _allergies = [];
  bool _isLoading = false;
  bool _isPersonsLoading = false;
  String? _errorMessage;
  String? _personId;

  List<Person> _persons = [];
  Person? _selfPerson;
  Person? _selectedPerson;

  AllergyViewModel({
    required ApiClient apiClient,
    required UserRepository userRepository,
  })  : _apiClient = apiClient,
        _userRepository = userRepository;

  List<Allergy> get allergies => _allergies;
  bool get isLoading => _isLoading;
  bool get isPersonsLoading => _isPersonsLoading;
  String? get errorMessage => _errorMessage;
  List<Person> get persons => _persons;
  Person? get selfPerson => _selfPerson;
  Person? get selectedPerson => _selectedPerson;

  Future<void> _ensurePersonId() async {
    if (_personId != null) return;
    final result = await _userRepository.getCurrentPerson();
    if (result.isSuccess && result.data != null) {
      _personId = result.data!.id;
    }
  }

  Future<void> loadPersons() async {
    _isPersonsLoading = true;
    _persons = [];
    _selfPerson = null;
    notifyListeners();

    try {
      final selfResult = await _userRepository.getCurrentPerson();
      final familyResult = await _userRepository.getFamilyMembers();
      final childrenResult = await _userRepository.getChildren();

      if (selfResult.isSuccess && selfResult.data != null) {
        _selfPerson = selfResult.data!;
        _persons.add(selfResult.data!);
        _personId ??= selfResult.data!.id;
      }
      if (familyResult.isSuccess && familyResult.data != null) {
        _persons.addAll(familyResult.data!);
      }
      if (childrenResult.isSuccess && childrenResult.data != null) {
        _persons.addAll(childrenResult.data!);
      }
      _selectedPerson ??= _selfPerson;
      notifyListeners();
    } catch (_) {
      notifyListeners();
    }

    _isPersonsLoading = false;
    await fetchAllergies();
  }

  Future<void> selectPerson(Person person) async {
    _selectedPerson = person;
    notifyListeners();
    await fetchAllergies();
  }

  Future<void> fetchAllergies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    String? pid = _selectedPerson?.id;
    if (pid == null) {
      await _ensurePersonId();
      pid = _personId;
    }
    if (pid == null) {
      _isLoading = false;
      _errorMessage = 'Profil bilgisi alınamadı';
      notifyListeners();
      return;
    }

    final response = await _apiClient.get<List<Allergy>>(
      ApiEndpoints.allergiesByPerson(pid),
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

  Future<bool> addAllergy(String name,
      {AllergyLevel? level,
      String? description,
      String? targetPersonId}) async {
    String? pid = targetPersonId;
    if (pid == null) {
      await _ensurePersonId();
      pid = _personId;
    }
    if (pid == null) return false;

    final body = {
      'personId': pid,
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

  Future<bool> updateAllergy(
    String id,
    String name, {
    AllergyLevel? level,
    String? description,
  }) async {
    final body = {
      'name': name,
      if (level != null) 'level': level.name,
      if (description != null && description.isNotEmpty)
        'description': description,
    };

    final response = await _apiClient.put(
      ApiEndpoints.allergy(id),
      body: body,
    );

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
