import 'package:flutter/material.dart';
import 'package:health_asistants/data/model/allergy.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/model/reminder.dart' show AudienceGroup;
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/core/utils/audience_helper.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

/// Bir alerji kaydı + kime ait olduğu.
class AllergyEntry {
  final Allergy allergy;
  final Person owner;
  const AllergyEntry(this.allergy, this.owner);
}

class AllergyViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final UserRepository _userRepository;

  List<AllergyEntry> _entries = [];
  bool _isLoading = false;
  bool _isPersonsLoading = false;
  String? _errorMessage;
  String? _personId;

  List<Person> _persons = [];
  Person? _selfPerson;

  /// Seçili yaş grubu filtresi. `null` => Tümü.
  AudienceGroup? _audienceFilter;

  AllergyViewModel({
    required ApiClient apiClient,
    required UserRepository userRepository,
  })  : _apiClient = apiClient,
        _userRepository = userRepository;

  List<AllergyEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get isPersonsLoading => _isPersonsLoading;
  String? get errorMessage => _errorMessage;
  List<Person> get persons => _persons;
  Person? get selfPerson => _selfPerson;
  AudienceGroup? get audienceFilter => _audienceFilter;

  /// Seçili yaş grubu filtresine uyan kişiler (filtre yoksa hepsi).
  List<Person> get _targetPersons {
    if (_audienceFilter == null) return _persons;
    return _persons
        .where((p) => audienceForPerson(p) == _audienceFilter)
        .toList();
  }

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
      notifyListeners();
    } catch (_) {
      notifyListeners();
    }

    _isPersonsLoading = false;
    await fetchAllergies();
  }

  /// Yaş grubu filtresini değiştirir ve listeyi yeniler.
  Future<void> setAudienceFilter(AudienceGroup? group) async {
    if (_audienceFilter == group) return;
    _audienceFilter = group;
    notifyListeners();
    await fetchAllergies();
  }

  Future<void> fetchAllergies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final targets = _targetPersons;

    // Kişi listesi henüz yüklenmediyse, en azından kendi kaydını çek.
    if (targets.isEmpty && _audienceFilter == null) {
      await _ensurePersonId();
      if (_personId != null) {
        await _fetchForPersonId(_personId!, owner: _selfPerson);
        return;
      }
      _entries = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    final List<AllergyEntry> collected = [];
    for (final person in targets) {
      final response = await _apiClient.get<List<Allergy>>(
        ApiEndpoints.allergiesByPerson(person.id),
        fromJson: (data) =>
            (data as List).map((e) => Allergy.fromJson(e)).toList(),
      );
      if (response.isSuccess) {
        for (final allergy in response.data ?? <Allergy>[]) {
          collected.add(AllergyEntry(allergy, person));
        }
      } else {
        _errorMessage = response.errorMessage;
      }
    }

    collected.sort(
        (a, b) => b.allergy.createdDate.compareTo(a.allergy.createdDate));
    _entries = collected;
    _isLoading = false;
    notifyListeners();
  }

  /// Kişi listesi yokken tek bir kişi için kayıt çeker.
  Future<void> _fetchForPersonId(String pid, {Person? owner}) async {
    final response = await _apiClient.get<List<Allergy>>(
      ApiEndpoints.allergiesByPerson(pid),
      fromJson: (data) =>
          (data as List).map((e) => Allergy.fromJson(e)).toList(),
    );
    final List<AllergyEntry> collected = [];
    if (response.isSuccess) {
      for (final allergy in response.data ?? <Allergy>[]) {
        if (owner != null) collected.add(AllergyEntry(allergy, owner));
      }
    } else {
      _errorMessage = response.errorMessage;
    }
    _entries = collected;
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

  Future<bool> deleteAllergy(dynamic id) async {
    final response =
        await _apiClient.delete(ApiEndpoints.allergy(id.toString()));

    if (response.isSuccess) {
      _entries.removeWhere((e) => e.allergy.id == id);
      notifyListeners();
      return true;
    }
    _errorMessage = response.errorMessage;
    notifyListeners();
    return false;
  }
}
