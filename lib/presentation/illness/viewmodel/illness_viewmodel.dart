import 'package:flutter/material.dart';
import 'package:health_asistants/data/model/illness.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/repository/illness_repository.dart';

class IllnessViewModel extends ChangeNotifier {
  final IllnessRepository _repository;

  List<Illness> _illnesses = [];
  List<Person> _persons = [];
  Person? _selectedPerson;
  bool _isLoading = false;
  bool _isPersonsLoading = false;
  String? _errorMessage;

  IllnessViewModel({required IllnessRepository repository})
      : _repository = repository;

  List<Illness> get illnesses => _illnesses;
  List<Person> get persons => _persons;
  Person? get selectedPerson => _selectedPerson;
  bool get isLoading => _isLoading;
  bool get isPersonsLoading => _isPersonsLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPersons() async {
    _isPersonsLoading = true;
    notifyListeners();

    final result = await _repository.getPersons();
    if (result.isSuccess && result.data != null) {
      _persons = result.data!.all;
      _selectedPerson ??= result.data!.self;
    }

    _isPersonsLoading = false;
    notifyListeners();

    await fetchIllnesses();
  }

  Future<void> selectPerson(Person person) async {
    _selectedPerson = person;
    notifyListeners();
    await fetchIllnesses();
  }

  Future<void> fetchIllnesses() async {
    if (_selectedPerson == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result =
        await _repository.getIllnessesByPerson(_selectedPerson!.id);
    if (result.isSuccess) {
      _illnesses = result.data ?? [];
    } else {
      _errorMessage = result.error;
    }

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

  Future<bool> updateIllness(
      String id, String name, String status, String? doctorNotes) async {
    final result = await _repository.updateIllness(
        id: id, name: name, status: status, doctorNotes: doctorNotes);
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
      _illnesses.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    }
    _errorMessage = result.error;
    notifyListeners();
    return false;
  }
}
