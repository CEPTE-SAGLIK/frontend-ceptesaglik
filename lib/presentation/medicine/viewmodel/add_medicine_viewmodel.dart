import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:health_asistants/data/model/medicine.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/repository/medicine_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

enum AddMedicineStatus { initial, saving, saved, error }

class AddMedicineViewModel extends ChangeNotifier {
  final MedicineRepository _medicineRepository;
  final UserRepository? _userRepository;

  AddMedicineViewModel({
    required MedicineRepository medicineRepository,
    UserRepository? userRepository,
  })  : _medicineRepository = medicineRepository,
        _userRepository = userRepository;

  AddMedicineStatus _status = AddMedicineStatus.initial;
  String? _errorMessage;

  // Form alanları
  String _name = '';
  FrequencyType _frequencyType = FrequencyType.daily;
  TimeOfDay? _selectedTime;
  String _notes = '';

  // Kişi seçimi
  List<Person> _persons = [];
  Person? _selectedPerson;
  Person? _selfPerson;

  // Getters
  AddMedicineStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get name => _name;
  FrequencyType get frequencyType => _frequencyType;
  TimeOfDay? get selectedTime => _selectedTime;
  String get notes => _notes;
  List<Person> get persons => _persons;
  Person? get selectedPerson => _selectedPerson;
  Person? get selfPerson => _selfPerson;

  List<FrequencyType> get frequencyOptions => FrequencyType.values;

  bool get isFormValid => _name.trim().isNotEmpty;

  String get selectedTimeText {
    if (_selectedTime == null) return '--:--';
    return '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
  }

  // Setters
  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateFrequency(FrequencyType value) {
    _frequencyType = value;
    notifyListeners();
  }

  void updateTime(TimeOfDay value) {
    _selectedTime = value;
    notifyListeners();
  }

  void updateNotes(String value) {
    _notes = value;
    notifyListeners();
  }

  void selectPerson(Person person) {
    if (_selectedPerson?.id != person.id) {
      _selectedPerson = person;
      notifyListeners();
    }
  }

  Future<void> loadPersons() async {
    if (_userRepository == null) return;
    _persons = [];
    _selfPerson = null;
    _selectedPerson = null;
    try {
      final selfResult = await _userRepository.getCurrentPerson();
      final familyResult = await _userRepository.getFamilyMembers();
      if (selfResult.isSuccess && selfResult.data != null) {
        _selfPerson = selfResult.data!;
        _persons.add(selfResult.data!);
      }
      if (familyResult.isSuccess && familyResult.data != null) {
        _persons.addAll(familyResult.data!);
      }
      _selectedPerson = _selfPerson;
      notifyListeners();
    } catch (_) {
      notifyListeners();
    }
  }

  Future<Person?> addPerson(String name) async {
    if (_userRepository == null) return null;
    final parts = name.trim().split(' ');
    final person = Person(
      id: '', userId: '', name: parts.first,
      surname: parts.length > 1 ? parts.skip(1).join(' ') : '',
      birthDate: DateTime(1990, 1, 1), gender: Gender.male,
    );
    final result = await _userRepository.addFamilyMember(person);
    if (result.isSuccess && result.data != null) {
      await loadPersons();
      final found = _persons.firstWhere(
        (p) => p.id == result.data!.id,
        orElse: () => result.data!,
      );
      _selectedPerson = found;
      notifyListeners();
      return found;
    }
    return null;
  }

  void reset() {
    _status = AddMedicineStatus.initial;
    _errorMessage = null;
    _name = '';
    _frequencyType = FrequencyType.daily;
    _selectedTime = null;
    _notes = '';
    _selectedPerson = _selfPerson;
    notifyListeners();
  }

  Future<Medicine?> saveMedicine() async {
    if (!isFormValid) {
      _errorMessage = 'Lütfen ilaç adını giriniz';
      _status = AddMedicineStatus.error;
      notifyListeners();
      return null;
    }

    _status = AddMedicineStatus.saving;
    notifyListeners();

    try {
      final now = DateTime.now();
      final reminderTime = _selectedTime != null
          ? DateTime(
              now.year,
              now.month,
              now.day,
              _selectedTime!.hour,
              _selectedTime!.minute,
            )
          : null;

      // Seçili kişi self değilse ilaç adına isim ön-eki ekle
      final isSelf = _selectedPerson == null ||
          _selectedPerson!.id == _selfPerson?.id;
      final String finalName;
      if (!isSelf) {
        final personName =
            '${_selectedPerson!.name} ${_selectedPerson!.surname}'.trim();
        finalName =
            personName.isNotEmpty ? '$personName — ${_name.trim()}' : _name.trim();
      } else {
        finalName = _name.trim();
      }

      final medicine = Medicine(
        id: const Uuid().v4(),
        name: finalName,
        frequencyType: _frequencyType,
        timesPerDay: 1,
        reminderTimes: reminderTime != null ? [reminderTime] : [],
        startDate: now,
        notes: _notes.trim().isNotEmpty ? _notes.trim() : null,
        personId: _selectedPerson?.id,
      );

      final result = await _medicineRepository.create(medicine);
      if (!result.isSuccess) {
        _status = AddMedicineStatus.error;
        _errorMessage = result.error ?? 'İlaç kaydedilemedi';
        notifyListeners();
        return null;
      }

      _status = AddMedicineStatus.saved;
      notifyListeners();

      return result.data;
    } catch (e) {
      _status = AddMedicineStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
