import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/data/repository/reminder_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';

/// Hatırlatma ekleme durumu
enum AddReminderStatus { initial, saving, saved, error }

/// Hatırlatma türü UI modeli
class ReminderTypeItem {
  final String label;
  final IconData icon;
  final Color color;
  final ReminderType type;

  const ReminderTypeItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class AddReminderViewModel extends ChangeNotifier {
  final ReminderRepository _reminderRepository;
  final UserRepository? _userRepository;
  final _uuid = const Uuid();

  AddReminderViewModel({
    ReminderRepository? reminderRepository,
    UserRepository? userRepository,
  })  : _reminderRepository = reminderRepository ?? ReminderRepository(),
        _userRepository = userRepository;

  AddReminderStatus _status = AddReminderStatus.initial;
  String? _errorMessage;

  // Form alanları
  String _title = '';
  String? _description;
  TimeOfDay? _selectedTime;
  RepeatType _repeatType = RepeatType.none;
  int _selectedTypeIndex = 0;
  String? _personId;

  // Hatırlatma türleri
  final List<ReminderTypeItem> reminderTypes = const [
    ReminderTypeItem(
      label: "İlaç",
      icon: Icons.medication,
      color: AppColors.catMedicine,
      type: ReminderType.medicine,
    ),
    ReminderTypeItem(
      label: "Aşı",
      icon: Icons.vaccines,
      color: AppColors.catHealth,
      type: ReminderType.vaccine,
    ),
    ReminderTypeItem(
      label: "Randevu",
      icon: Icons.medical_services,
      color: AppColors.catTeeth,
      type: ReminderType.appointment,
    ),
    ReminderTypeItem(
      label: "Egzersiz",
      icon: Icons.fitness_center,
      color: AppColors.catExercise,
      type: ReminderType.custom,
    ),
    ReminderTypeItem(
      label: "Toplantı",
      icon: Icons.calendar_month,
      color: AppColors.catMeeting,
      type: ReminderType.custom,
    ),
    ReminderTypeItem(
      label: "Genel",
      icon: Icons.notifications,
      color: AppColors.catGeneral,
      type: ReminderType.custom,
    ),
  ];

  // Getters
  AddReminderStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get title => _title;
  String? get description => _description;
  TimeOfDay? get selectedTime => _selectedTime;
  RepeatType get repeatType => _repeatType;
  int get selectedTypeIndex => _selectedTypeIndex;
  ReminderTypeItem get selectedReminderType =>
      reminderTypes[_selectedTypeIndex];
  String? get personId => _personId;

  /// Form geçerli mi
  bool get isFormValid => _title.isNotEmpty && _selectedTime != null;

  /// Sıklık label'ı
  String get repeatTypeLabel {
    switch (_repeatType) {
      case RepeatType.none:
        return 'Bir Kez';
      case RepeatType.daily:
        return 'Her Gün';
      case RepeatType.weekly:
        return 'Haftalık';
      case RepeatType.monthly:
        return 'Aylık';
    }
  }

  // Setters / Actions

  void setTitle(String value) {
    if (_title != value) {
      _title = value;
      notifyListeners();
    }
  }

  void setDescription(String? value) {
    if (_description != value) {
      _description = value;
      notifyListeners();
    }
  }

  void setSelectedTime(TimeOfDay? time) {
    if (_selectedTime != time) {
      _selectedTime = time;
      notifyListeners();
    }
  }

  void setRepeatType(RepeatType type) {
    if (_repeatType != type) {
      _repeatType = type;
      notifyListeners();
    }
  }

  void setRepeatTypeFromFrequency(String? frequency) {
    if (frequency == null) return;

    RepeatType newType;
    switch (frequency) {
      case 'Günde 1 kere':
      case 'Günde 2 kere':
        newType = RepeatType.daily;
        break;
      case 'Haftada 1 kere':
      case 'Haftada 2 kere':
        newType = RepeatType.weekly;
        break;
      case 'Ayda 1 kere':
        newType = RepeatType.monthly;
        break;
      default:
        newType = RepeatType.none;
    }
    setRepeatType(newType);
  }

  void setSelectedTypeIndex(int index) {
    if (_selectedTypeIndex != index &&
        index >= 0 &&
        index < reminderTypes.length) {
      _selectedTypeIndex = index;
      notifyListeners();
    }
  }

  void setPersonId(String? id) {
    if (_personId != id) {
      _personId = id;
      notifyListeners();
    }
  }

  /// Hatırlatmayı kaydet
  Future<Reminder?> saveReminder() async {
    if (!isFormValid) {
      _errorMessage = 'Lütfen tüm alanları doldurun';
      notifyListeners();
      return null;
    }

    _status = AddReminderStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_personId == null && _userRepository != null) {
        final userResult = await _userRepository.getCurrentUser();
        if (userResult.isSuccess && userResult.data != null) {
          _personId = userResult.data!.id;
        }
      }

      if (_personId == null || _personId!.isEmpty) {
        _status = AddReminderStatus.error;
        _errorMessage = 'Kullanıcı bilgisi alınamadı';
        notifyListeners();
        return null;
      }

      final now = DateTime.now();
      final reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final reminder = Reminder(
        id: _uuid.v4(),
        personId: _personId!,
        title: _title,
        description: _description,
        type: selectedReminderType.type,
        dateTime: reminderDateTime,
        repeatType: _repeatType,
        isActive: true,
        createdAt: now,
      );

      // Repository'ye kaydet
      final result = await _reminderRepository.create(reminder);
      if (!result.isSuccess) {
        _status = AddReminderStatus.error;
        _errorMessage = result.error ?? 'Hatırlatma kaydedilemedi';
        notifyListeners();
        return null;
      }

      _status = AddReminderStatus.saved;
      notifyListeners();

      return result.data;
    } catch (e) {
      _status = AddReminderStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Formu sıfırla
  void reset() {
    _status = AddReminderStatus.initial;
    _errorMessage = null;
    _title = '';
    _description = null;
    _selectedTime = null;
    _repeatType = RepeatType.none;
    _selectedTypeIndex = 0;
    _personId = null;
    notifyListeners();
  }
}
