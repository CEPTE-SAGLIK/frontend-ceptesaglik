import 'package:flutter/material.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/repository/user_repository.dart';
import 'package:health_asistants/data/repository/vaccine_repository.dart';

enum FamilyStatus { initial, loading, loaded, error, saving }

class FamilyViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final VaccineRepository _vaccineRepository;

  FamilyStatus _status = FamilyStatus.initial;
  List<Person> _children = [];
  String? _errorMessage;

  FamilyViewModel({
    required UserRepository userRepository,
    required VaccineRepository vaccineRepository,
  })  : _userRepository = userRepository,
        _vaccineRepository = vaccineRepository;

  FamilyStatus get status => _status;
  List<Person> get children => _children;
  String? get errorMessage => _errorMessage;

  Future<void> loadChildren() async {
    _status = FamilyStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _userRepository.getFamilyMembers();
    if (result.isSuccess) {
      _children = result.data ?? [];
      _status = FamilyStatus.loaded;
    } else {
      _status = FamilyStatus.error;
      _errorMessage = result.error;
    }
    notifyListeners();
  }

  Future<bool> deleteVaccineRecord(String vaccineId) async {
    _status = FamilyStatus.saving;
    notifyListeners();
    final result = await _vaccineRepository.deleteVaccine(vaccineId);
    if (result.isSuccess) {
      await loadChildren();
      return true;
    }
    _status = FamilyStatus.error;
    notifyListeners();
    return false;
  }

  Future<bool> addVaccineRecord(
      String childId, String name, DateTime date) async {
    _status = FamilyStatus.saving;
    notifyListeners();
    final result = await _vaccineRepository.addVaccine(
      targetId: childId,
      name: name,
      date: date,
      isChild: true,
    );
    if (result.isSuccess) {
      await loadChildren();
      return true;
    }
    _status = FamilyStatus.error;
    notifyListeners();
    return false;
  }

  Future<bool> deleteChild(String id) async {
    _status = FamilyStatus.saving;
    _errorMessage = null;
    notifyListeners();

    final result = await _userRepository.deleteChild(id);
    if (result.isSuccess) {
      await loadChildren();
      return true;
    }
    _status = FamilyStatus.error;
    _errorMessage = result.error ?? 'Silme işlemi başarısız oldu';
    notifyListeners();
    return false;
  }

  Future<bool> updatePhysicalInfo(
      String id, double h, double w, Gender g) async {
    _status = FamilyStatus.saving;
    _errorMessage = null;
    notifyListeners();

    final result = await _userRepository.updatePhysicalInfo(id, h, w, g);
    if (result.isSuccess) {
      await loadChildren();
      return true;
    }
    _status = FamilyStatus.error;
    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> addChild(String name, DateTime birthDate) async {
    _status = FamilyStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      final userResult = await _userRepository.getCurrentUser();
      if (!userResult.isSuccess) throw Exception('Kullanıcı bilgisi alınamadı');

      final result = await _userRepository.addChild({
        'Name': name,
        'BirthDate': birthDate.toIso8601String().split('.')[0],
        'Gender': 0,
        'UserId': userResult.data!.id,
      });

      if (result.isSuccess) {
        await loadChildren();
        return true;
      }
      _status = FamilyStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _status = FamilyStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
