import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/data/model/medicine.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/data/repository/reminder_repository.dart';
import 'package:health_asistants/data/repository/medicine_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

/// Takvim etkinlik durumu
enum CalendarStatus { initial, loading, loaded, error }

/// Etkinlik türü UI modeli
class EventTypeItem {
  final String label;
  final IconData icon;
  final Color color;
  final ReminderType type;

  const EventTypeItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class CalendarViewModel extends ChangeNotifier {
  final ReminderRepository _reminderRepository;
  final MedicineRepository _medicineRepository;
  final UserRepository _userRepository;
  final _uuid = const Uuid();

  CalendarStatus _status = CalendarStatus.initial;
  String? _errorMessage;
  String? _userId;

  // Seçilen tarih
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Tüm etkinlikler (ham liste — tekrar hesabı _occursOnDay ile yapılır)
  final List<Reminder> _allReminders = [];

  CalendarViewModel({
    required ReminderRepository reminderRepository,
    required MedicineRepository medicineRepository,
    required UserRepository userRepository,
  })  : _reminderRepository = reminderRepository,
        _medicineRepository = medicineRepository,
        _userRepository = userRepository;

  // Etkinlik türleri

  // Etkinlik türleri
  final List<EventTypeItem> eventTypes = const [
    EventTypeItem(
      label: "İlaç",
      icon: Icons.medication,
      color: AppColors.catMedicine,
      type: ReminderType.medicine,
    ),
    EventTypeItem(
      label: "Aşı",
      icon: Icons.vaccines,
      color: AppColors.catHealth,
      type: ReminderType.vaccine,
    ),
    EventTypeItem(
      label: "Randevu",
      icon: Icons.medical_services,
      color: AppColors.catTeeth,
      type: ReminderType.appointment,
    ),
    EventTypeItem(
      label: "Genel",
      icon: Icons.notifications,
      color: AppColors.catGeneral,
      type: ReminderType.custom,
    ),
  ];

  // Getters
  CalendarStatus get status => _status;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;
  List<Reminder> get allReminders => _allReminders;

  /// Seçilen güne ait etkinlikleri döndürür
  List<Reminder> get selectedDayEvents {
    return _getEventsForDay(_selectedDay);
  }

  /// Belirli bir güne ait etkinlikleri döndürür (tekrar kuralları dahil)
  List<Reminder> _getEventsForDay(DateTime day) {
    final normalized = _normalizeDate(day);
    return _allReminders.where((r) => _occursOnDay(r, normalized)).toList();
  }

  /// Hatırlatıcının verilen günde gerçekleşip gerçekleşmediğini hesaplar
  bool _occursOnDay(Reminder reminder, DateTime day) {
    final start = _normalizeDate(reminder.dateTime);
    if (day.isBefore(start)) return false;
    switch (reminder.repeatType) {
      case RepeatType.none:
        return day == start;
      case RepeatType.daily:
        return true;
      case RepeatType.weekly:
        return day.difference(start).inDays % 7 == 0;
      case RepeatType.monthly:
        return day.day == start.day;
    }
  }

  /// Belirli bir günde etkinlik var mı kontrol eder
  List<Reminder> getEventsForDay(DateTime day) {
    return _getEventsForDay(day);
  }

  FrequencyType _repeatToFrequency(RepeatType repeat) {
    switch (repeat) {
      case RepeatType.weekly:
        return FrequencyType.weekly;
      case RepeatType.monthly:
        return FrequencyType.monthly;
      case RepeatType.daily:
      case RepeatType.none:
        return FrequencyType.daily;
    }
  }

  /// Tarihi normalize eder (saat bilgisini kaldırır)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Gün seçildiğinde çağrılır
  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    notifyListeners();
  }

  /// Sayfa değiştiğinde çağrılır
  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }

  /// Yeni etkinlik ekler
  Future<bool> addEvent({
    required String title,
    String? description,
    required ReminderType type,
    required TimeOfDay time,
    RepeatType repeatType = RepeatType.none,
  }) async {
    if (_userId == null) {
      final userResult = await _userRepository.getCurrentUser();
      if (userResult.isSuccess && userResult.data != null) {
        _userId = userResult.data!.id;
      }
    }

    if (_userId == null || _userId!.isEmpty) {
      _errorMessage = 'Kullanıcı bilgisi alınamadı';
      notifyListeners();
      return false;
    }

    final dateTime = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      time.hour,
      time.minute,
    );

    final reminder = Reminder(
      id: _uuid.v4(),
      personId: _userId!,
      title: title,
      description: description,
      type: type,
      dateTime: dateTime,
      repeatType: repeatType,
      isActive: true,
      createdAt: DateTime.now(),
    );

    // İlaç türündeki hatırlatıcılar Medicine tablosuna da kaydedilsin;
    // oluşan Medicine ID'si Reminder'a bağlanır ki backend sanal hatırlatıcı eklemesin.
    String? linkedMedicineId;
    if (type == ReminderType.medicine) {
      final medicine = Medicine(
        id: _uuid.v4(),
        name: title,
        frequencyType: _repeatToFrequency(repeatType),
        timesPerDay: 1,
        reminderTimes: [dateTime],
        startDate: _normalizeDate(_selectedDay),
        notes: description,
      );
      final medResult = await _medicineRepository.create(medicine);
      if (medResult.isSuccess) {
        linkedMedicineId = medResult.data?.id;
      }
    }

    // relatedItemId ile Reminder ↔ Medicine bağlantısını kur
    final linkedReminder = linkedMedicineId != null
        ? reminder.copyWith(relatedItemId: linkedMedicineId)
        : reminder;

    final result = await _reminderRepository.create(linkedReminder);
    if (result.isSuccess) {
      await loadEvents();
      return true;
    }
    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  /// Etkinliği tamamlandı olarak işaretler
  Future<bool> toggleEventCompletion(String eventId) async {
    final reminder = _allReminders
        .firstWhere((r) => r.id == eventId, orElse: () => throw Exception('Hatırlatma bulunamadı'));
    final result = await _reminderRepository.toggleComplete(reminder);

    if (result.isSuccess) {
      final idx = _allReminders.indexWhere((r) => r.id == eventId);
      if (idx != -1) {
        _allReminders[idx] = _allReminders[idx].copyWith(isActive: !_allReminders[idx].isActive);
        notifyListeners();
        return true;
      }
    }
    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  /// Etkinliği siler
  Future<bool> deleteEvent(String eventId) async {
    final result = await _reminderRepository.delete(eventId);

    if (result.isSuccess) {
      _allReminders.removeWhere((r) => r.id == eventId);
      notifyListeners();
      return true;
    }
    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  /// Repository'den etkinlikleri yükler
  Future<void> loadEvents() async {
    _status = CalendarStatus.loading;
    notifyListeners();

    if (_userId == null) {
      final userResult = await _userRepository.getCurrentUser();
      if (userResult.isSuccess && userResult.data != null) {
        _userId = userResult.data!.id;
      }
    }

    if (_userId == null) {
      _status = CalendarStatus.error;
      _errorMessage = 'Kullanıcı bilgisi alınamadı';
      notifyListeners();
      return;
    }

    final result = await _reminderRepository.getAll(_userId!);

    if (result.isSuccess) {
      _allReminders
        ..clear()
        ..addAll(result.data!);
      _status = CalendarStatus.loaded;
    } else {
      _status = CalendarStatus.error;
      _errorMessage = result.error;
    }

    notifyListeners();
  }

  /// Etkinlik türüne göre renk döndürür
  Color getEventColor(ReminderType type) {
    switch (type) {
      case ReminderType.medicine:
        return AppColors.catMedicine;
      case ReminderType.vaccine:
        return AppColors.catHealth;
      case ReminderType.appointment:
        return AppColors.catTeeth;
      case ReminderType.custom:
        return AppColors.catGeneral;
    }
  }

  /// Etkinlik türüne göre ikon döndürür
  IconData getEventIcon(ReminderType type) {
    switch (type) {
      case ReminderType.medicine:
        return Icons.medication;
      case ReminderType.vaccine:
        return Icons.vaccines;
      case ReminderType.appointment:
        return Icons.medical_services;
      case ReminderType.custom:
        return Icons.notifications;
    }
  }

  /// Etkinlik türüne göre etiket döndürür
  String getEventTypeLabel(ReminderType type) {
    switch (type) {
      case ReminderType.medicine:
        return 'İlaç';
      case ReminderType.vaccine:
        return 'Aşı';
      case ReminderType.appointment:
        return 'Randevu';
      case ReminderType.custom:
        return 'Genel';
    }
  }
}
