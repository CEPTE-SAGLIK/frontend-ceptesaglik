import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:health_asistants/data/model/medicine.dart';
import 'package:health_asistants/data/repository/medicine_repository.dart';

/// İlaç kaydı durumu
enum MedicineRecordStatus { initial, saving, saved, error }

class MedicineRecordViewModel extends ChangeNotifier {
  final MedicineRepository _medicineRepository;
  final _uuid = const Uuid();

  MedicineRecordViewModel({required MedicineRepository medicineRepository})
      : _medicineRepository = medicineRepository;

  MedicineRecordStatus _status = MedicineRecordStatus.initial;
  String? _errorMessage;

  // Form alanları
  String _name = '';
  String? _usageInstructions;
  FrequencyType _frequencyType = FrequencyType.daily;
  int _timesPerDay = 1;
  List<DateTime> _reminderTimes = [];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String? _notes;
  String? _personId;

  // Getters
  MedicineRecordStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get name => _name;
  String? get usageInstructions => _usageInstructions;
  FrequencyType get frequencyType => _frequencyType;
  int get timesPerDay => _timesPerDay;
  List<DateTime> get reminderTimes => List.unmodifiable(_reminderTimes);
  DateTime get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get notes => _notes;
  String? get personId => _personId;

  /// Form geçerli mi
  bool get isFormValid => _name.isNotEmpty;

  /// Başlangıç tarihi formatı
  String get startDateText =>
      "${_startDate.day}/${_startDate.month}/${_startDate.year}";

  /// Bitiş tarihi formatı
  String get endDateText => _endDate != null
      ? "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}"
      : "Belirtilmedi";

  /// Sıklık seçenekleri
  List<FrequencyType> get frequencyOptions => FrequencyType.values;

  // Setters / Actions

  void setName(String value) {
    if (_name != value) {
      _name = value;
      notifyListeners();
    }
  }

  void setUsageInstructions(String? value) {
    if (_usageInstructions != value) {
      _usageInstructions = value;
      notifyListeners();
    }
  }

  void setFrequencyType(FrequencyType type) {
    if (_frequencyType != type) {
      _frequencyType = type;
      notifyListeners();
    }
  }

  void setTimesPerDay(int value) {
    if (_timesPerDay != value && value > 0) {
      _timesPerDay = value;
      notifyListeners();
    }
  }

  void addReminderTime(DateTime time) {
    _reminderTimes = [..._reminderTimes, time];
    notifyListeners();
  }

  void removeReminderTime(int index) {
    if (index >= 0 && index < _reminderTimes.length) {
      _reminderTimes = List.from(_reminderTimes)..removeAt(index);
      notifyListeners();
    }
  }

  void setStartDate(DateTime date) {
    if (_startDate != date) {
      _startDate = date;
      notifyListeners();
    }
  }

  void setEndDate(DateTime? date) {
    if (_endDate != date) {
      _endDate = date;
      notifyListeners();
    }
  }

  void setNotes(String? value) {
    if (_notes != value) {
      _notes = value;
      notifyListeners();
    }
  }

  void setPersonId(String? id) {
    if (_personId != id) {
      _personId = id;
      notifyListeners();
    }
  }

  /// İlacı kaydet
  Future<Medicine?> saveMedicine() async {
    if (!isFormValid) {
      _errorMessage = 'Lütfen ilaç adını girin';
      notifyListeners();
      return null;
    }

    _status = MedicineRecordStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      final medicine = Medicine(
        id: _uuid.v4(),
        name: _name,
        usageInstructions: _usageInstructions,
        frequencyType: _frequencyType,
        timesPerDay: _timesPerDay,
        reminderTimes: _reminderTimes,
        startDate: _startDate,
        endDate: _endDate,
        notes: _notes,
        personId: _personId,
      );

      // Repository'ye kaydet
      final result = await _medicineRepository.create(medicine);
      if (!result.isSuccess) {
        _status = MedicineRecordStatus.error;
        _errorMessage = result.error ?? 'İlaç kaydedilemedi';
        notifyListeners();
        return null;
      }

      _status = MedicineRecordStatus.saved;
      notifyListeners();

      return result.data;
    } catch (e) {
      _status = MedicineRecordStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Formu sıfırla
  void reset() {
    _status = MedicineRecordStatus.initial;
    _errorMessage = null;
    _name = '';
    _usageInstructions = null;
    _frequencyType = FrequencyType.daily;
    _timesPerDay = 1;
    _reminderTimes = [];
    _startDate = DateTime.now();
    _endDate = null;
    _notes = null;
    _personId = null;
    notifyListeners();
  }
}
