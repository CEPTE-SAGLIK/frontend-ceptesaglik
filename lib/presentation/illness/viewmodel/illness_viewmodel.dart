import 'package:flutter/material.dart';
import 'package:health_asistants/data/model/illness.dart';
import 'package:health_asistants/data/repository/illness_repository.dart';

class IllnessViewModel extends ChangeNotifier {
  final IllnessRepository _repository;

  List<Illness> _illnesses = [];
  bool _isLoading = false;
  String? _errorMessage;

  IllnessViewModel({required IllnessRepository repository})
      : _repository = repository;

  List<Illness> get illnesses => _illnesses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchIllnesses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getIllnesses();
    if (result.isSuccess) {
      _illnesses = result.data ?? [];
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addIllness(
      String name, String status, String? doctorNotes) async {
    final result = await _repository.addIllness(name, status, doctorNotes);
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
