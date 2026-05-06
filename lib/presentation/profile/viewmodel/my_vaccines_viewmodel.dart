import 'package:flutter/material.dart';
import 'package:health_asistants/data/model/vaccine_schedule.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/repository/vaccine_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

enum MyVaccinesStatus { initial, loading, loaded, error }

class MyVaccinesViewModel extends ChangeNotifier {
  final VaccineRepository _vaccineRepository;
  final UserRepository _userRepository;

  MyVaccinesStatus _status = MyVaccinesStatus.initial;
  final List<Person> _peopleWithVaccines = [];
  List<VaccineSchedule> _standardSchedule = [];
  DateTime? _selectedSimDate;
  String? _errorMessage;

  MyVaccinesViewModel({
    required VaccineRepository vaccineRepository,
    required UserRepository userRepository,
  })  : _vaccineRepository = vaccineRepository,
        _userRepository = userRepository;

  MyVaccinesStatus get status => _status;
  List<Person> get peopleWithVaccines => _peopleWithVaccines;
  List<VaccineSchedule> get standardSchedule => _standardSchedule;
  DateTime? get selectedSimDate => _selectedSimDate;
  String? get errorMessage => _errorMessage;

  Future<void> updateStandardSchedule(DateTime date) async {
    _selectedSimDate = date;
    _status = MyVaccinesStatus.loading;
    notifyListeners();

    try {
      final result =
          await _vaccineRepository.getStandardSchedule(birthDate: date);
      if (result.isSuccess) {
        _standardSchedule = result.data ?? [];
        _status = MyVaccinesStatus.loaded;
      } else {
        _status = MyVaccinesStatus.error;
        _errorMessage = result.error;
      }
    } catch (e) {
      _status = MyVaccinesStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadVaccines() async {
    _status = MyVaccinesStatus.loading;
    notifyListeners();

    try {
      _peopleWithVaccines.clear();
      final selfResult = await _userRepository.getCurrentPerson();
      final familyResult = await _userRepository.getFamilyMembers();
      final childrenResult = await _userRepository.getChildren();

      final allPeopleData = <Map<String, dynamic>>[];

      if (selfResult.isSuccess && selfResult.data != null) {
        allPeopleData.add({'person': selfResult.data!, 'isChild': false});
      }
      if (familyResult.isSuccess && familyResult.data != null) {
        for (final p in familyResult.data!) {
          final isChild =
              p.relationship?.toLowerCase().contains('çocuk') ?? false;
          allPeopleData.add({'person': p, 'isChild': isChild});
        }
      }
      if (childrenResult.isSuccess && childrenResult.data != null) {
        for (final p in childrenResult.data!) {
          allPeopleData.add({'person': p, 'isChild': true});
        }
      }

      for (final data in allPeopleData) {
        final Person person = data['person'] as Person;
        final bool isChild = data['isChild'] as bool;

        final vaccineResult =
            await _vaccineRepository.getVaccinesForTarget(person.id, isChild);

        _peopleWithVaccines.add(Person(
          id: person.id,
          userId: person.userId,
          name: person.name,
          surname: person.surname,
          relationship: person.relationship,
          birthDate: person.birthDate,
          gender: person.gender,
          vaccines: vaccineResult.isSuccess
              ? (vaccineResult.data ?? [])
              : person.vaccines,
          illnesses: person.illnesses,
          allergies: person.allergies,
          medicines: person.medicines,
        ));
      }
      _status = MyVaccinesStatus.loaded;
    } catch (e) {
      _status = MyVaccinesStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> addNewVaccine({
    required String targetId,
    required bool isChild,
    required String name,
    required DateTime date,
    String? frequency,
    String? description,
  }) async {
    _status = MyVaccinesStatus.loading;
    notifyListeners();

    final result = await _vaccineRepository.addVaccine(
      targetId: targetId,
      isChild: isChild,
      name: name,
      date: date,
      frequency: frequency,
      description: description,
    );

    if (result.isSuccess) {
      await loadVaccines();
      return true;
    }
    _status = MyVaccinesStatus.error;
    notifyListeners();
    return false;
  }

  Future<bool> deleteVaccine(String vaccineId) async {
    _status = MyVaccinesStatus.loading;
    notifyListeners();

    final result = await _vaccineRepository.deleteVaccine(vaccineId);
    if (result.isSuccess) {
      await loadVaccines();
      return true;
    }
    _status = MyVaccinesStatus.loaded;
    _errorMessage = result.error;
    notifyListeners();
    return false;
  }
}
