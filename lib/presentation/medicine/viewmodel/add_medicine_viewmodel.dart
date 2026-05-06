import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:health_asistants/data/model/medicine.dart';
import 'package:health_asistants/data/repository/medicine_repository.dart';

enum AddMedicineStatus { initial, saving, saved, error }

class AddMedicineViewModel extends ChangeNotifier {
  final MedicineRepository _medicineRepository;

  AddMedicineViewModel({required MedicineRepository medicineRepository})
      : _medicineRepository = medicineRepository;

  AddMedicineStatus _status = AddMedicineStatus.initial;
  String? _errorMessage;

  // Form alanları
  String _name = '';
  FrequencyType _frequencyType = FrequencyType.daily;
  TimeOfDay? _selectedTime;
  String _notes = '';

  // Getters
  AddMedicineStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get name => _name;
  FrequencyType get frequencyType => _frequencyType;
  TimeOfDay? get selectedTime => _selectedTime;
  String get notes => _notes;

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

  void reset() {
    _status = AddMedicineStatus.initial;
    _errorMessage = null;
    _name = '';
    _frequencyType = FrequencyType.daily;
    _selectedTime = null;
    _notes = '';
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

      final medicine = Medicine(
        id: const Uuid().v4(),
        name: _name.trim(),
        frequencyType: _frequencyType,
        timesPerDay: 1,
        reminderTimes: reminderTime != null ? [reminderTime] : [],
        startDate: now,
        notes: _notes.trim().isNotEmpty ? _notes.trim() : null,
      );

      // Repository'ye kaydet
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
