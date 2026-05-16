import 'package:flutter/material.dart';
import 'package:health_asistants/data/model/illness.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/model/reminder.dart' show AudienceGroup;
import 'package:health_asistants/core/utils/audience_helper.dart';
import 'package:health_asistants/data/repository/illness_repository.dart';

/// Bir hastalık kaydı + kime ait olduğu.
class IllnessEntry {
  final Illness illness;
  final Person owner;
  const IllnessEntry(this.illness, this.owner);
}

class IllnessViewModel extends ChangeNotifier {
  final IllnessRepository _repository;

  List<IllnessEntry> _entries = [];
  List<Person> _persons = [];
  Person? _selfPerson;
  bool _isLoading = false;
  bool _isPersonsLoading = false;
  String? _errorMessage;

  /// Seçili yaş grubu filtresi. `null` => Tümü.
  AudienceGroup? _audienceFilter;

  IllnessViewModel({required IllnessRepository repository})
      : _repository = repository;

  List<IllnessEntry> get entries => _entries;
  List<Person> get persons => _persons;
  Person? get selfPerson => _selfPerson;
  bool get isLoading => _isLoading;
  bool get isPersonsLoading => _isPersonsLoading;
  String? get errorMessage => _errorMessage;
  AudienceGroup? get audienceFilter => _audienceFilter;

  /// Seçili yaş grubu filtresine uyan kişiler (filtre yoksa hepsi).
  List<Person> get _targetPersons {
    if (_audienceFilter == null) return _persons;
    return _persons
        .where((p) => audienceForPerson(p) == _audienceFilter)
        .toList();
  }

  Future<void> loadPersons() async {
    _isPersonsLoading = true;
    notifyListeners();

    final result = await _repository.getPersons();
    if (result.isSuccess && result.data != null) {
      _persons = result.data!.all;
      _selfPerson = result.data!.self;
    }

    _isPersonsLoading = false;
    notifyListeners();

    await fetchIllnesses();
  }

  /// Yaş grubu filtresini değiştirir ve listeyi yeniler.
  Future<void> setAudienceFilter(AudienceGroup? group) async {
    if (_audienceFilter == group) return;
    _audienceFilter = group;
    notifyListeners();
    await fetchIllnesses();
  }

  Future<void> fetchIllnesses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final targets = _targetPersons;
    final List<IllnessEntry> collected = [];
    for (final person in targets) {
      final result = await _repository.getIllnessesByPerson(person.id);
      if (result.isSuccess) {
        for (final illness in result.data ?? <Illness>[]) {
          collected.add(IllnessEntry(illness, person));
        }
      } else {
        _errorMessage = result.error;
      }
    }

    collected.sort(
        (a, b) => b.illness.diagnosisDate.compareTo(a.illness.diagnosisDate));
    _entries = collected;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addIllness(
      String name, String status, String? doctorNotes, String personId) async {
    final result = await _repository.addIllness(
      personId: personId,
      name: name,
      status: status,
      doctorNotes: doctorNotes,
    );
    if (result.isSuccess) {
      await fetchIllnesses();
      return true;
    }
    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> deleteIllness(String id) async {
    final result = await _repository.deleteIllness(id);
    if (result.isSuccess) {
      _entries.removeWhere((e) => e.illness.id == id);
      notifyListeners();
      return true;
    }
    _errorMessage = result.error;
    notifyListeners();
    return false;
  }
}
