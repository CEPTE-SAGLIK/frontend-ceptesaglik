import 'package:flutter/foundation.dart';
import 'package:health_asistants/core/services/notification_service.dart';
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/data/repository/reminder_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

enum ReminderListStatus { initial, loading, loaded, error }

class ReminderListViewModel extends ChangeNotifier {
  final ReminderRepository _repository;
  final UserRepository _userRepository;

  ReminderListStatus _status = ReminderListStatus.initial;
  String? _errorMessage;
  List<Reminder> _reminders = [];
  ReminderType? _selectedFilter;
  String? _userId;

  ReminderListViewModel({
    required ReminderRepository repository,
    required UserRepository userRepository,
  }) : _repository = repository,
       _userRepository = userRepository;

  ReminderListStatus get status => _status;
  String? get errorMessage => _errorMessage;
  ReminderType? get selectedFilter => _selectedFilter;

  List<Reminder> get reminders {
    if (_selectedFilter == null) return _reminders;
    return _reminders.where((r) => r.type == _selectedFilter).toList();
  }

  List<Reminder> get activeReminders =>
      reminders.where((r) => r.isActive).toList();

  List<Reminder> get completedReminders =>
      reminders.where((r) => !r.isActive).toList();

  Future<void> loadReminders() async {
    _status = ReminderListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Get current user id once
    if (_userId == null) {
      final userResult = await _userRepository.getCurrentUser();
      if (userResult.isSuccess && userResult.data != null) {
        _userId = userResult.data!.id;
      }
    }

    if (_userId == null) {
      _status = ReminderListStatus.error;
      _errorMessage = 'Kullanıcı bilgisi alınamadı';
      notifyListeners();
      return;
    }

    final result = await _repository.getAll(_userId!);

    if (result.isSuccess) {
      _reminders = result.data!;
      _reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      _status = ReminderListStatus.loaded;
    } else {
      _status = ReminderListStatus.error;
      _errorMessage = result.error;
    }

    notifyListeners();
  }

  Future<void> refresh() async => loadReminders();

  void setFilter(ReminderType? type) {
    _selectedFilter = type;
    notifyListeners();
  }

  Future<bool> addReminder(Reminder reminder) async {
    final result = await _repository.create(reminder);
    if (result.isSuccess) {
      await loadReminders();
      return true;
    }
    _errorMessage = result.error;
    return false;
  }

  Future<bool> updateReminder(Reminder reminder) async {
    final result = await _repository.update(reminder);
    if (result.isSuccess) {
      await loadReminders();
      return true;
    }
    _errorMessage = result.error;
    return false;
  }

  Future<bool> deleteReminder(String id) async {
    await NotificationService().cancelReminderNotifications(id);
    final result = await _repository.delete(id);
    if (result.isSuccess) {
      await loadReminders();
      return true;
    }
    _errorMessage = result.error;
    return false;
  }

  Future<void> toggleComplete(String id) async {
    final reminder = _reminders.firstWhere(
      (r) => r.id == id,
      orElse: () => throw Exception('Hatırlatma bulunamadı'),
    );
    final result = await _repository.toggleComplete(reminder);
    if (result.isSuccess) {
      if (reminder.isActive) {
        // aktif → pasif: bildirimleri iptal et
        await NotificationService().cancelReminderNotifications(id);
      } else {
        // pasif → aktif: bildirimleri yeniden planla
        await NotificationService().scheduleReminderNotifications(result.data!);
      }
      await loadReminders();
    }
  }
}
