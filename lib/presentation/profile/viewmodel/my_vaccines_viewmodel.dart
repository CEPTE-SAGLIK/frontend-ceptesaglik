import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/data/model/vaccine_schedule.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/repository/reminder_repository.dart';
import 'package:health_asistants/data/repository/vaccine_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

enum MyVaccinesStatus { initial, loading, loaded, error }

class MyVaccinesViewModel extends ChangeNotifier {
  final VaccineRepository _vaccineRepository;
  final UserRepository _userRepository;
  final ReminderRepository _reminderRepository;
  final _uuid = const Uuid();

  MyVaccinesStatus _status = MyVaccinesStatus.initial;
  final List<Person> _peopleWithVaccines = [];
  final List<Person> _adultPeople = [];
  int _selectedAdultIndex = 0;
  List<VaccineSchedule> _standardSchedule = [];
  DateTime? _selectedSimDate;
  String? _errorMessage;

  MyVaccinesViewModel({
    required VaccineRepository vaccineRepository,
    required UserRepository userRepository,
    required ReminderRepository reminderRepository,
  })  : _vaccineRepository = vaccineRepository,
        _userRepository = userRepository,
        _reminderRepository = reminderRepository;

  MyVaccinesStatus get status => _status;
  List<Person> get peopleWithVaccines => _peopleWithVaccines;
  List<Person> get adultPersons => _adultPeople;
  int get selectedAdultIndex => _selectedAdultIndex;
  Person? get selectedAdult =>
      _adultPeople.isNotEmpty ? _adultPeople[_selectedAdultIndex] : null;
  List<VaccineSchedule> get standardSchedule => _standardSchedule;
  DateTime? get selectedSimDate => _selectedSimDate;
  String? get errorMessage => _errorMessage;

  /// Giriş yapan kullanıcının kendi Person'ı
  Person? get selfPerson =>
      _adultPeople.isNotEmpty ? _adultPeople.first : null;

  void selectAdult(String id) {
    final idx = _adultPeople.indexWhere((p) => p.id == id);
    if (idx != -1 && _selectedAdultIndex != idx) {
      _selectedAdultIndex = idx;
      notifyListeners();
    }
  }

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
      _adultPeople.clear();
      final selfResult = await _userRepository.getCurrentPerson();
      final familyResult = await _userRepository.getFamilyMembers();

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

      for (final data in allPeopleData) {
        final Person person = data['person'] as Person;
        final bool isChild = data['isChild'] as bool;

        final vaccineResult =
            await _vaccineRepository.getVaccinesForTarget(person.id, isChild);

        final personWithVaccines = Person(
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
        );

        _peopleWithVaccines.add(personWithVaccines);
        if (!isChild) _adultPeople.add(personWithVaccines);
      }

      // Seçili index geçerliliğini koru
      if (_selectedAdultIndex >= _adultPeople.length) {
        _selectedAdultIndex = 0;
      }

      _status = MyVaccinesStatus.loaded;
    } catch (e) {
      _status = MyVaccinesStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> addAdultPerson(String name, {String? surname}) async {
    _status = MyVaccinesStatus.loading;
    notifyListeners();

    final parts = name.trim().split(' ');
    final firstName = parts.first;
    final lastName =
        parts.length > 1 ? parts.skip(1).join(' ') : (surname ?? '');

    final person = Person(
      id: '',
      userId: '',
      name: firstName,
      surname: lastName,
      birthDate: DateTime(1990, 1, 1),
      gender: Gender.male,
    );

    final result = await _userRepository.addFamilyMember(person);
    if (result.isSuccess) {
      await loadVaccines();
      return true;
    }
    _status = MyVaccinesStatus.error;
    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> addNewVaccine({
    required String targetId,
    required bool isChild,
    required String name,
    required DateTime date,
    String? dose,
    String? frequency,
    String? description,
  }) async {
    _status = MyVaccinesStatus.loading;
    notifyListeners();

    final vaccineResult = await _vaccineRepository.addVaccine(
      targetId: targetId,
      isChild: isChild,
      name: name,
      date: date,
      dose: dose,
      frequency: frequency,
      description: description,
    );

    if (vaccineResult.isSuccess) {
      if (!isChild) {
        final userResult = await _userRepository.getCurrentUser();
        if (userResult.isSuccess && userResult.data != null) {
          // Kişinin adını bul → Reminder başlığına ekle
          final Person? person = _adultPeople.cast<Person?>().firstWhere(
                (p) => p?.id == targetId,
                orElse: () => null,
              );
          final personName =
              person != null ? '${person.name} ${person.surname}'.trim() : null;
          final reminderTitle = (personName != null && personName.isNotEmpty)
              ? '$personName — $name'
              : name;

          final now = DateTime.now();
          final reminder = Reminder(
            id: _uuid.v4(),
            personId: userResult.data!.id,
            title: reminderTitle,
            description: description,
            type: ReminderType.vaccine,
            dateTime: DateTime(
                date.year, date.month, date.day, now.hour, now.minute),
            repeatType: RepeatType.none,
            isActive: true,
            createdAt: now,
            relatedItemId: vaccineResult.data,
          );
          await _reminderRepository.create(reminder);
        }
      }
      await loadVaccines();
      return true;
    }
    _status = MyVaccinesStatus.error;
    notifyListeners();
    return false;
  }

  Future<bool> toggleVaccine(String vaccineId, bool currentlyCompleted) async {
    final result =
        await _vaccineRepository.updateStatus(vaccineId, !currentlyCompleted);
    if (result.isSuccess) {
      await loadVaccines();
      return true;
    }
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
