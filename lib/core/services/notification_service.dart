import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/data/repository/reminder_repository.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'reminder_notifications';
  static const _channelName = 'Hatırlatmalar';
  static const _channelDesc = 'Sağlık hatırlatma bildirimleri';

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    if (!kIsWeb) {
      try {
        final timezoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
        tz.setLocalLocation(tz.getLocation(timezoneName));
      } catch (e) {
        debugPrint("Timezone ayarlanırken hata oluştu: $e");
        tz.setLocalLocation(tz.UTC);
      }
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    if (kIsWeb || !_initialized) return;

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();
    await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleReminderNotifications(Reminder reminder) async {
    if (kIsWeb) return;
    if (!_initialized) await initialize();

    await cancelReminderNotifications(reminder.id);
    await requestPermissions();

    if (reminder.repeatType == RepeatType.none) {
      await _scheduleOneTime(reminder);
    } else {
      await _scheduleRepeating(reminder);
    }
  }

  // Tek seferlik: hatırlatma zamanından 24 dakika öncesinden başlayarak
  // her 2 dakikada bir bildirim planlar.
  Future<void> _scheduleOneTime(Reminder reminder) async {
    final now = DateTime.now();
    int index = 0;
    for (int minutesBefore = 24; minutesBefore >= 0; minutesBefore -= 2) {
      final notifTime = reminder.dateTime.subtract(Duration(minutes: minutesBefore));
      if (notifTime.isAfter(now)) {
        await _scheduleOne(
          id: _notifId(reminder.id, index),
          title: _buildTitle(reminder.title, minutesBefore),
          body: _buildBody(minutesBefore),
          scheduledTime: notifTime,
        );
      }
      index++;
    }
  }

  // Tekrarlayan: her gün/hafta/ay için tek bir tekrarlayan bildirim planlar.
  Future<void> _scheduleRepeating(Reminder reminder) async {
    final DateTimeComponents components;
    switch (reminder.repeatType) {
      case RepeatType.daily:
        components = DateTimeComponents.time;
      case RepeatType.weekly:
        components = DateTimeComponents.dayOfWeekAndTime;
      case RepeatType.monthly:
        components = DateTimeComponents.dayOfMonthAndTime;
      case RepeatType.none:
        return;
    }

    final now = DateTime.now();
    var scheduledTime = reminder.dateTime;

    if (scheduledTime.isBefore(now)) {
      switch (reminder.repeatType) {
        case RepeatType.daily:
          // Kaç gün geride olduğunu hesapla ve tek seferde atla
          final daysDiff = now.difference(scheduledTime).inDays + 1;
          scheduledTime = scheduledTime.add(Duration(days: daysDiff));
          // Hâlâ gerideyse (saat farkı nedeniyle) bir gün daha ekle
          if (scheduledTime.isBefore(now)) {
            scheduledTime = scheduledTime.add(const Duration(days: 1));
          }
        case RepeatType.weekly:
          final weeksDiff = (now.difference(scheduledTime).inDays ~/ 7) + 1;
          scheduledTime = scheduledTime.add(Duration(days: weeksDiff * 7));
          if (scheduledTime.isBefore(now)) {
            scheduledTime = scheduledTime.add(const Duration(days: 7));
          }
        case RepeatType.monthly:
          // Gün taşmasından kaçınmak için orijinal günü koru
          final originalDay = reminder.dateTime.day;
          final monthsDiff =
              (now.year - scheduledTime.year) * 12 +
              (now.month - scheduledTime.month) +
              1;
          var targetYear = scheduledTime.year + (scheduledTime.month + monthsDiff - 1) ~/ 12;
          var targetMonth = (scheduledTime.month + monthsDiff - 1) % 12 + 1;
          // Hedef ayda o gün yoksa (örn. Şubat 31), ayın son gününü kullan
          final daysInMonth = DateTime(targetYear, targetMonth + 1, 0).day;
          final targetDay = originalDay.clamp(1, daysInMonth);
          scheduledTime = DateTime(targetYear, targetMonth, targetDay,
              reminder.dateTime.hour, reminder.dateTime.minute);
          if (scheduledTime.isBefore(now)) {
            targetMonth++;
            if (targetMonth > 12) { targetMonth = 1; targetYear++; }
            final daysInNext = DateTime(targetYear, targetMonth + 1, 0).day;
            scheduledTime = DateTime(targetYear, targetMonth,
                originalDay.clamp(1, daysInNext),
                reminder.dateTime.hour, reminder.dateTime.minute);
          }
        case RepeatType.none:
          break;
      }
    }

    await _scheduleOne(
      id: _notifId(reminder.id, 0),
      title: '⏰ Hatırlatma: ${reminder.title}',
      body: 'Hatırlatmanız geldi!',
      scheduledTime: scheduledTime,
      matchDateTimeComponents: components,
    );
  }

  Future<void> cancelReminderNotifications(String reminderId) async {
    if (kIsWeb) return;
    if (!_initialized) await initialize();
    for (int i = 0; i <= 12; i++) {
      await _plugin.cancel(_notifId(reminderId, i));
    }
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    if (!_initialized) await initialize();
    await _plugin.cancelAll();
  }

  Future<void> rescheduleAllNotifications(
    String userId,
    ReminderRepository reminderRepository,
  ) async {
    if (kIsWeb) return;
    if (!_initialized) await initialize();

    await _plugin.cancelAll();

    final result = await reminderRepository.getAll(userId);
    if (!result.isSuccess || result.data == null) return;

    final now = DateTime.now();
    for (final reminder in result.data!) {
      if (!reminder.isActive) continue;
      if (reminder.dateTime.isBefore(now) &&
          reminder.repeatType == RepeatType.none) {
        continue;
      }
      await scheduleReminderNotifications(reminder);
    }
  }

  Future<void> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
      );
      debugPrint('Bildirim planlandı [$id]: $tzTime');
    } catch (e) {
      debugPrint('Bildirim planlanamadı [$id]: $e');
    }
  }

  String _buildTitle(String reminderTitle, int minutesBefore) {
    if (minutesBefore == 0) return '⏰ Hatırlatma: $reminderTitle';
    if (minutesBefore == 24) return '📅 Az Sonra: $reminderTitle';
    return '🔔 $reminderTitle';
  }

  String _buildBody(int minutesBefore) {
    if (minutesBefore == 0) return 'Hatırlatmanız geldi!';
    if (minutesBefore == 24) return '24 dakika sonra hatırlatmanız var.';
    return '$minutesBefore dakika sonra hatırlatmanız var.';
  }

  int _notifId(String reminderId, int index) {
    return (reminderId.hashCode.abs() % 100000) * 13 + index;
  }
}
