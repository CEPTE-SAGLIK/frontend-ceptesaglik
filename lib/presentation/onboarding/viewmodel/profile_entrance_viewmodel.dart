import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/model/allergy.dart';
import 'package:health_asistants/data/model/illness.dart';
import 'package:health_asistants/data/repository/auth_repository.dart';
import 'package:health_asistants/data/repository/person_repository.dart';

/// Profil oluşturma durumu
enum ProfileEntranceStatus { initial, saving, saved, error }

/// Kronik hastalık türleri
enum ChronicDiseaseType {
  diabetes("Diyabet"),
  hypertension("Hipertansiyon"),
  asthma("Astım"),
  heartDisease("Kalp Hastalığı");

  final String label;
  const ChronicDiseaseType(this.label);
}

/// Alerji türleri
enum AllergyType {
  penicillin("Penisilin"),
  pollen("Polen"),
  dust("Toz"),
  mites("Akarları"),
  nuts("Kuruyemiş");

  final String label;
  const AllergyType(this.label);
}

class ProfileEntranceViewModel extends ChangeNotifier {
  final PersonRepository _personRepository;
  final AuthRepository _authRepository;
  final _uuid = const Uuid();

  // Controllers
  final heightController = TextEditingController(text: '158');
  final weightController = TextEditingController(text: '50');

  ProfileEntranceStatus _status = ProfileEntranceStatus.initial;
  String? _errorMessage;

  ProfileEntranceViewModel({
    PersonRepository? personRepository,
    AuthRepository? authRepository,
  }) : _personRepository = personRepository ?? PersonRepository(),
       _authRepository = authRepository ?? AuthRepository();

  // Kişisel bilgiler
  DateTime? _birthDate;
  Gender _gender = Gender.female;
  int _height = 158;
  int _weight = 50;

  // Sağlık bilgileri
  List<String> _availableDiseases = ChronicDiseaseType.values
      .map((e) => e.label)
      .toList();
  List<String> _availableAllergies = AllergyType.values
      .map((e) => e.label)
      .toList();
  final List<String> _selectedDiseases = [];
  final List<String> _selectedAllergies = [];

  // Getters
  ProfileEntranceStatus get status => _status;
  bool get isLoading => _status == ProfileEntranceStatus.saving;
  String? get errorMessage => _errorMessage;

  DateTime? get birthDate => _birthDate;
  String get birthDateText => _birthDate != null
      ? "${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}"
      : "Tarih Seçin";

  Gender get gender => _gender;
  bool get isFemale => _gender == Gender.female;
  bool get isMale => _gender == Gender.male;

  int get height => _height;
  int get weight => _weight;

  List<String> get availableDiseases => _availableDiseases;
  List<String> get availableAllergies => _availableAllergies;
  List<String> get selectedDiseases => List.unmodifiable(_selectedDiseases);
  List<String> get selectedAllergies => List.unmodifiable(_selectedAllergies);

  // --- ACTIONS ---

  void setBirthDate(DateTime? date) {
    if (_birthDate != date) {
      _birthDate = date;
      notifyListeners();
    }
  }

  // EKLENEN METOD: Dropdown menü bunu kullanıyor
  void setGender(Gender gender) {
    if (_gender != gender) {
      _gender = gender;
      notifyListeners();
    }
  }

  // Chip kullanımı için (İstersen kaldırabilirsin ama dursun zararı yok)
  void setGenderFromString(String genderStr) {
    final newGender = genderStr == "Kadın" ? Gender.female : Gender.male;
    setGender(newGender);
  }

  void setHeight(int value) {
    if (_height != value && value > 0) {
      _height = value;
      heightController.text = value.toString();
      notifyListeners();
    }
  }

  void setWeight(int value) {
    if (_weight != value && value > 0) {
      _weight = value;
      weightController.text = value.toString();
      notifyListeners();
    }
  }

  void toggleDisease(String disease) {
    if (_selectedDiseases.contains(disease)) {
      _selectedDiseases.remove(disease);
    } else {
      _selectedDiseases.add(disease);
    }
    notifyListeners();
  }

  void toggleAllergy(String allergy) {
    if (_selectedAllergies.contains(allergy)) {
      _selectedAllergies.remove(allergy);
    } else {
      _selectedAllergies.add(allergy);
    }
    notifyListeners();
  }

  void addNewDisease(String disease) {
    if (disease.isNotEmpty && !_availableDiseases.contains(disease)) {
      _availableDiseases = [..._availableDiseases, disease];
      _selectedDiseases.add(disease);
      notifyListeners();
    }
  }

  void addNewAllergy(String allergy) {
    if (allergy.isNotEmpty && !_availableAllergies.contains(allergy)) {
      _availableAllergies = [..._availableAllergies, allergy];
      _selectedAllergies.add(allergy);
      notifyListeners();
    }
  }

  Future<bool> saveProfile() async {
    if (_status == ProfileEntranceStatus.saving) {
      return false;
    }

    if (_birthDate == null) {
      _status = ProfileEntranceStatus.error;
      _errorMessage = 'Lütfen doğum tarihi seçin';
      notifyListeners();
      return false;
    }

    _status = ProfileEntranceStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) {
        _status = ProfileEntranceStatus.error;
        _errorMessage =
            'Kullanıcı bilgisi bulunamadı, lütfen tekrar giriş yapın';
        notifyListeners();
        return false;
      }

      final result = await _personRepository.createPerson(
        name: currentUser.name,
        surname: currentUser.surname,
        birthDate: _birthDate!,
        gender: _gender,
        height: _height.toDouble(),
        weight: _weight.toDouble(),
        chronicDiseases: _selectedDiseases.toList(),
        allergies: _selectedAllergies.toList(),
      );

      if (result.isSuccess) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('profile_completed_${currentUser.id}', true);

        _status = ProfileEntranceStatus.saved;
        notifyListeners();
        return true;
      } else {
        _status = ProfileEntranceStatus.error;
        _errorMessage = result.error ?? 'Profil oluşturulamadı';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = ProfileEntranceStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }
}
