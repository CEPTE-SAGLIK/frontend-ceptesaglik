import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/data/repository/reminder_repository.dart';
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
  final UserRepository _userRepository;
  final _uuid = const Uuid();

  CalendarStatus _status = CalendarStatus.initial;
  String? _errorMessage;
  String? _userId;

  // Seçilen tarih
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Tüm etkinlikler
  final Map<DateTime, List<Reminder>> _events = {};

  CalendarViewModel({
    required ReminderRepository reminderRepository,
    required UserRepository userRepository,
  })  : _reminderRepository = reminderRepository,
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
  Map<DateTime, List<Reminder>> get events => _events;

  /// Seçilen güne ait etkinlikleri döndürür
  List<Reminder> get selectedDayEvents {
    return _getEventsForDay(_selectedDay);
  }

  /// Belirli bir güne ait etkinlikleri döndürür
  List<Reminder> _getEventsForDay(DateTime day) {
    final normalizedDay = _normalizeDate(day);
    return _events[normalizedDay] ?? [];
  }

  /// Belirli bir günde etkinlik var mı kontrol eder
  List<Reminder> getEventsForDay(DateTime day) {
    return _getEventsForDay(day);
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

    final result = await _reminderRepository.create(reminder);
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
    final reminder = _events.values
        .expand((list) => list)
        .firstWhere((r) => r.id == eventId, orElse: () => throw Exception('Hatırlatma bulunamadı'));
    final result = await _reminderRepository.toggleComplete(reminder);

    if (result.isSuccess) {
      for (var dayEvents in _events.values) {
        for (int i = 0; i < dayEvents.length; i++) {
          if (dayEvents[i].id == eventId) {
            final event = dayEvents[i];
            dayEvents[i] = Reminder(
              id: event.id,
              personId: event.personId,
              title: event.title,
              description: event.description,
              type: event.type,
              dateTime: event.dateTime,
              repeatType: event.repeatType,
              isActive: !event.isActive,
              relatedItemId: event.relatedItemId,
              createdAt: event.createdAt,
            );
            notifyListeners();
            return true;
          }
        }
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
      for (var normalizedDay in _events.keys) {
        _events[normalizedDay]?.removeWhere((event) => event.id == eventId);
      }
      _events.removeWhere((key, value) => value.isEmpty);
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
      _events.clear();
      for (var reminder in result.data!) {
        final normalizedDay = _normalizeDate(reminder.dateTime);
        if (_events.containsKey(normalizedDay)) {
          _events[normalizedDay]!.add(reminder);
        } else {
          _events[normalizedDay] = [reminder];
        }
      }
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
