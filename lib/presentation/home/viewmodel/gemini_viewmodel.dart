import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:health_asistants/data/model/gemini_analysis.dart';
import 'package:health_asistants/data/model/medicine.dart';
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/data/repository/gemini_repository.dart';
import 'package:health_asistants/data/repository/medicine_repository.dart';
import 'package:health_asistants/data/repository/reminder_repository.dart';

enum GeminiStatus { initial, analyzing, success, saving, saved, error }

class GeminiViewModel extends ChangeNotifier {
  final GeminiRepository _geminiRepository;
  final MedicineRepository _medicineRepository;
  final ReminderRepository _reminderRepository;

  GeminiViewModel({
    required GeminiRepository geminiRepository,
    required MedicineRepository medicineRepository,
    required ReminderRepository reminderRepository,
  })  : _geminiRepository = geminiRepository,
        _medicineRepository = medicineRepository,
        _reminderRepository = reminderRepository;

  GeminiStatus _status = GeminiStatus.initial;
  String? _errorMessage;
  GeminiAnalysisResponse? _analysisResponse;

  // Getters
  GeminiStatus get status => _status;
  String? get errorMessage => _errorMessage;
  GeminiAnalysisResponse? get analysisResponse => _analysisResponse;

  Future<void> analyzeText(String text) async {
    if (text.trim().isEmpty) return;
    
    _status = GeminiStatus.analyzing;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _geminiRepository.analyzeText(text);
      if (result.isSuccess) {
        _analysisResponse = result.data;
        _status = GeminiStatus.success;
      } else {
        _errorMessage = result.error ?? 'Analiz başarısız oldu';
        _status = GeminiStatus.error;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = GeminiStatus.error;
    }
    notifyListeners();
  }

  Future<bool> saveParsedResults(String personId) async {
    if (_analysisResponse == null) return false;

    _status = GeminiStatus.saving;
    notifyListeners();

    bool hasError = false;

    try {
      // İlaçları Kaydet
      for (final extractedMedicine in _analysisResponse!.medicines) {
        final frequency = FrequencyType.fromLabel(extractedMedicine.frequencyType);

        final medicine = Medicine(
          id: const Uuid().v4(),
          name: extractedMedicine.name,
          frequencyType: frequency,
          timesPerDay: extractedMedicine.timesPerDay,
          usageInstructions: extractedMedicine.usageInstructions,
          startDate: DateTime.now(),
          personId: personId,
        );

        final result = await _medicineRepository.create(medicine);
        if (!result.isSuccess) hasError = true;
      }

      // Hatırlatıcıları Kaydet
      for (final extractedReminder in _analysisResponse!.reminders) {
        final type = ReminderType.values.firstWhere(
          (e) => e.name == extractedReminder.type,
          orElse: () => ReminderType.custom,
        );

        final reminder = Reminder(
          id: const Uuid().v4(),
          personId: personId,
          title: extractedReminder.title,
          type: type,
          dateTime: extractedReminder.dateTime,
          createdAt: DateTime.now(),
        );

        final result = await _reminderRepository.create(reminder);
        if (!result.isSuccess) hasError = true;
      }

      if (hasError) {
         _errorMessage = 'Bazı kayıtlar eklenirken hata oluştu.';
         _status = GeminiStatus.error;
         notifyListeners();
         return false;
      }

      _status = GeminiStatus.saved;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = GeminiStatus.error;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = GeminiStatus.initial;
    _analysisResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
}
