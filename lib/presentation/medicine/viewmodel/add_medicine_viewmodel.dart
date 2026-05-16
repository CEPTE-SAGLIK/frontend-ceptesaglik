import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:health_asistants/core/utils/audience_helper.dart';
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

  // Düzenleme modu: null ise yeni ilaç, dolu ise mevcut ilacın id'si
  String? _editingId;

  // Form alanları
  String _name = '';
  FrequencyType _frequencyType = FrequencyType.daily;
  TimeOfDay? _selectedTime;
  int _timesPerDay = 1;
  String _notes = '';
  AudienceGroup _audienceGroup = AudienceGroup.adult;

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
  int get timesPerDay => _timesPerDay;
  String get notes => _notes;
  List<Person> get persons => _persons;
  Person? get selectedPerson => _selectedPerson;
  Person? get selfPerson => _selfPerson;
  AudienceGroup get audienceGroup => _audienceGroup;
  bool get isEditMode => _editingId != null;

  /// Seçili yaş grubuna uyan kişiler
  List<Person> get filteredPersons =>
      _persons.where((p) => audienceForPerson(p) == _audienceGroup).toList();

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

  void updateTimesPerDay(int value) {
    _timesPerDay = value;
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

  /// Yaş grubunu değiştirir; seçili kişi yeni gruba uymuyorsa uygun kişiye geçer.
  void setAudienceGroup(AudienceGroup group) {
    if (_audienceGroup == group) return;
    _audienceGroup = group;
    if (_selectedPerson != null &&
        audienceForPerson(_selectedPerson!) != group) {
      final matches = filteredPersons;
      _selectedPerson = matches.isNotEmpty ? matches.first : null;
    }
    notifyListeners();
  }

  Future<void> loadPersons() async {
    if (_userRepository == null) return;
    _persons = [];
    _selfPerson = null;
    _selectedPerson = null;
    try {
      final selfResult = await _userRepository.getCurrentPerson();
      final familyResult = await _userRepository.getFamilyMembers();
      final childrenResult = await _userRepository.getChildren();
      if (selfResult.isSuccess && selfResult.data != null) {
        _selfPerson = selfResult.data!;
        _persons.add(selfResult.data!);
      }
      if (familyResult.isSuccess && familyResult.data != null) {
        _persons.addAll(familyResult.data!);
      }
      if (childrenResult.isSuccess && childrenResult.data != null) {
        _persons.addAll(childrenResult.data!);
      }
      _selectedPerson = _selfPerson;
      if (_selfPerson != null) {
        _audienceGroup = audienceForPerson(_selfPerson!);
      }
      notifyListeners();
    } catch (_) {
      notifyListeners();
    }
  }

  /// Düzenleme modunu başlatır: kişi listesini yükler ve formu mevcut ilaçla doldurur.
  Future<void> loadForEdit(Medicine medicine) async {
    _editingId = medicine.id;
    _name = medicine.name;
    _frequencyType = medicine.frequencyType;
    _timesPerDay = medicine.timesPerDay;
    _notes = medicine.notes ?? '';
    _audienceGroup = medicine.audienceGroup;
    _status = AddMedicineStatus.initial;
    _errorMessage = null;

    if (medicine.reminderTimes.isNotEmpty) {
      final t = medicine.reminderTimes.first;
      _selectedTime = TimeOfDay(hour: t.hour, minute: t.minute);
    } else {
      _selectedTime = null;
    }

    notifyListeners();

    // Kişi listesini yükle ve ilaç sahibini seç
    await loadPersons();
    if (medicine.personId != null && medicine.personId!.isNotEmpty) {
      final match = _persons.where((p) => p.id == medicine.personId).firstOrNull;
      if (match != null) {
        _audienceGroup = audienceForPerson(match);
        _selectedPerson = match;
        notifyListeners();
      }
    }
  }

  /// [draft] AddPersonSheet'ten gelen kişi (id/userId boş, doğum tarihi dolu).
  Future<Person?> addPerson(Person draft) async {
    if (_userRepository == null) return null;
    final result = await _userRepository.addFamilyMember(draft);
    if (result.isSuccess && result.data != null) {
      await loadPersons();
      final found = _persons.firstWhere(
        (p) => p.id == result.data!.id,
        orElse: () => result.data!,
      );
      _audienceGroup = audienceForPerson(found);
      _selectedPerson = found;
      notifyListeners();
      return found;
    }
    return null;
  }

  void reset() {
    _editingId = null;
    _status = AddMedicineStatus.initial;
    _errorMessage = null;
    _name = '';
    _frequencyType = FrequencyType.daily;
    _selectedTime = null;
    _timesPerDay = 1;
    _notes = '';
    _selectedPerson = _selfPerson;
    _audienceGroup = _selfPerson != null
        ? audienceForPerson(_selfPerson!)
        : AudienceGroup.adult;
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

      if (isEditMode) {
        // Düzenleme: isim ön-eki uygulanmaz, kullanıcı formdaki adı doğrudan kaydeder
        final medicine = Medicine(
          id: _editingId!,
          name: _name.trim(),
          frequencyType: _frequencyType,
          timesPerDay: _timesPerDay,
          reminderTimes: reminderTime != null ? [reminderTime] : [],
          startDate: now,
          notes: _notes.trim().isNotEmpty ? _notes.trim() : null,
          personId: _selectedPerson?.id,
          audienceGroup: _audienceGroup,
          audienceBirthDate: (_selectedPerson ?? _selfPerson)?.birthDate,
        );

        final result = await _medicineRepository.update(medicine);
        if (!result.isSuccess) {
          _status = AddMedicineStatus.error;
          _errorMessage = result.error ?? 'İlaç güncellenemedi';
          notifyListeners();
          return null;
        }
        _status = AddMedicineStatus.saved;
        notifyListeners();
        return result.data;
      }

      // Yeni ilaç: self değilse isim ön-eki ekle
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
        audienceGroup: _audienceGroup,
        audienceBirthDate: (_selectedPerson ?? _selfPerson)?.birthDate,
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
