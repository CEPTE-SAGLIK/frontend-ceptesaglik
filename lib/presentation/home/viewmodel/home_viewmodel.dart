import 'package:flutter/foundation.dart';
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/model/user.dart';
import 'package:health_asistants/data/model/vaccine.dart';
import 'package:health_asistants/data/repository/person_repository.dart';
import 'package:health_asistants/data/repository/reminder_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';
import 'package:health_asistants/data/repository/vaccine_repository.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  final ReminderRepository _reminderRepository;
  final PersonRepository _personRepository;
  final UserRepository _userRepository;
  final VaccineRepository _vaccineRepository;

  HomeStatus _status = HomeStatus.initial;
  List<Reminder> _upcomingReminders = [];
  List<Vaccine> _vaccines = [];
  Person? _currentPerson;
  User? _currentUser;
  String? _errorMessage;

  HomeViewModel({
    ReminderRepository? reminderRepository,
    PersonRepository? personRepository,
    UserRepository? userRepository,
    VaccineRepository? vaccineRepository,
  })  : _reminderRepository = reminderRepository ?? ReminderRepository(),
        _personRepository = personRepository ?? PersonRepository(),
        _userRepository = userRepository ?? UserRepository(),
        _vaccineRepository = vaccineRepository ?? VaccineRepository();

  HomeStatus get status => _status;
  List<Reminder> get upcomingReminders => _upcomingReminders;
  List<Vaccine> get vaccines => _vaccines;
  Person? get currentPerson => _currentPerson;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  String get personName {
    if (_currentPerson != null && _currentPerson!.name.isNotEmpty) {
      if (_currentPerson!.surname.isNotEmpty) {
        return '${_currentPerson!.name} ${_currentPerson!.surname}';
      }
      return _currentPerson!.name;
    }
    if (_currentUser != null && _currentUser!.name.isNotEmpty) {
      if (_currentUser!.surname.isNotEmpty) {
        return '${_currentUser!.name} ${_currentUser!.surname}';
      }
      return _currentUser!.name;
    }
    return 'Kullanıcı';
  }

  int get pendingRemindersCount =>
      _upcomingReminders.where((r) => r.isActive).length;

  int get completedRemindersCount =>
      _upcomingReminders.where((r) => !r.isActive).length;

  /// Sonraki hatırlatma veya aşıyı döndürür (hangisi önce ise).
  /// Vaccine tipi hatırlatıcılarda deduplication uygulanır.
  dynamic get absoluteNextReminder {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final Map<String, Reminder> uniqueReminders = {};
    for (final r in _upcomingReminders) {
      if (r.isActive &&
          (r.dateTime.isAfter(now) ||
              DateTime(r.dateTime.year, r.dateTime.month, r.dateTime.day)
                  .isAtSameMomentAs(today))) {
        if (r.type == ReminderType.vaccine) {
          final key = 'VACCINE_${r.dateTime.hour}_${r.dateTime.minute}';
          if (!uniqueReminders.containsKey(key) || r.title.contains('Doz')) {
            uniqueReminders[key] = r;
          }
        } else {
          uniqueReminders[r.id] = r;
        }
      }
    }

    final sorted = uniqueReminders.values.toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final nextR = sorted.isNotEmpty ? sorted.first : null;
    final nextV = getNextVaccine();

    if (nextR != null && nextV != null) {
      return nextR.dateTime.isBefore(nextV.date) ? nextR : nextV;
    }
    return nextR ?? nextV;
  }

  Reminder? getNextReminder() {
    final now = DateTime.now();
    final active = _upcomingReminders
        .where((r) => r.isActive && r.dateTime.isAfter(now))
        .toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return active.first;
  }

  Vaccine? getNextVaccine() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pending = _vaccines
        .where((v) =>
            v.status == VaccineStatus.pending &&
            (v.date.isAfter(now) ||
                DateTime(v.date.year, v.date.month, v.date.day)
                    .isAtSameMomentAs(today)))
        .toList();
    if (pending.isEmpty) return null;
    pending.sort((a, b) => a.date.compareTo(b.date));
    return pending.first;
  }

  List<Reminder> getRemindersByType(ReminderType type) {
    return _upcomingReminders.where((r) => r.type == type).toList();
  }

  Future<void> loadHomeData() async {
    _status = HomeStatus.loading;
    _upcomingReminders = [];
    _vaccines = [];
    _errorMessage = null;
    notifyListeners();

    try {
      final userResult = await _userRepository.getCurrentUser();
      if (userResult.isSuccess && userResult.data != null) {
        _currentUser = userResult.data;
      }

      if (_currentUser == null) {
        _status = HomeStatus.error;
        _errorMessage = 'Kullanıcı bilgisi alınamadı. Lütfen tekrar giriş yapın.';
        notifyListeners();
        return;
      }

      final remindersResult =
          await _reminderRepository.getAll(_currentUser!.id);
      if (remindersResult.isSuccess) {
        _upcomingReminders = remindersResult.data!;
      } else {
        _errorMessage = remindersResult.error;
      }

      final personsResult = await _personRepository.getMyPersons();
      if (personsResult.isSuccess &&
          personsResult.data != null &&
          personsResult.data!.isNotEmpty) {
        _currentPerson = personsResult.data!.first;

        final vaccinesResult =
            await _vaccineRepository.getByChildId(_currentPerson!.id);
        if (vaccinesResult.isSuccess && vaccinesResult.data != null) {
          _vaccines = vaccinesResult.data!;
        }
      }

      _status = HomeStatus.loaded;
    } catch (e) {
      _status = HomeStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> refreshData() async => loadHomeData();

  Future<void> toggleReminderComplete(String id) async {
    final reminder = _upcomingReminders.firstWhere(
      (r) => r.id == id,
      orElse: () => throw Exception('Hatırlatma bulunamadı'),
    );
    final result = await _reminderRepository.toggleComplete(reminder);
    if (result.isSuccess) await loadHomeData();
  }

  Future<void> restoreReminder(Reminder reminder) async {
    final result = await _reminderRepository.create(reminder);
    if (result.isSuccess) await loadHomeData();
  }

  Future<bool> updateReminder(Reminder reminder) async {
    final result = await _reminderRepository.update(reminder);
    if (result.isSuccess) {
      await loadHomeData();
      return true;
    }
    return false;
  }

  Future<bool> deleteReminder(String id) async {
    final result = await _reminderRepository.delete(id);
    if (result.isSuccess) {
      await loadHomeData();
      return true;
    }
    return false;
  }
}
