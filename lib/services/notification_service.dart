import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/user_profile.dart';
import '../core/utils/cycle_utils.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Notification IDs
  static const int _periodReminderId = 1;
  static const int _ovulationReminderId = 2;
  static const int _medicationReminderId = 3;

  // Localized notification strings
  static const _strings = {
    'tr': {
      'periodTitle': 'Adet Hatırlatması',
      'periodBody': 'Adetiniz yarın başlayabilir. Hazırlıklı olun!',
      'periodChannel': 'Adet Hatırlatması',
      'periodChannelDesc': 'Adet döngüsü hatırlatmaları',
      'ovulationTitle': 'Ovülasyon Hatırlatması',
      'ovulationBody': 'Bugün ovülasyon gününüz. Doğurgan dönemdesiniz!',
      'ovulationChannel': 'Ovülasyon Hatırlatması',
      'ovulationChannelDesc': 'Ovülasyon hatırlatmaları',
      'medicationTitle': 'İlaç Hatırlatması',
      'medicationBody': 'İlacınızı almayı unutmayın!',
      'medicationChannel': 'İlaç Hatırlatması',
      'medicationChannelDesc': 'İlaç hatırlatmaları',
    },
    'en': {
      'periodTitle': 'Period Reminder',
      'periodBody': 'Your period may start tomorrow. Be prepared!',
      'periodChannel': 'Period Reminder',
      'periodChannelDesc': 'Period cycle reminders',
      'ovulationTitle': 'Ovulation Reminder',
      'ovulationBody': 'Today is your ovulation day. You are in your fertile window!',
      'ovulationChannel': 'Ovulation Reminder',
      'ovulationChannelDesc': 'Ovulation reminders',
      'medicationTitle': 'Medication Reminder',
      'medicationBody': 'Don\'t forget to take your medication!',
      'medicationChannel': 'Medication Reminder',
      'medicationChannelDesc': 'Medication reminders',
    },
  };

  String _t(String locale, String key) =>
      _strings[locale]?[key] ?? _strings['en']![key]!;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _isInitialized = true;
  }

  Future<bool> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  tz.TZDateTime _nextInstanceOfDateTime(
      int year, int month, int day, int hour, int minute) {
    final location = tz.local;
    final scheduled =
        tz.TZDateTime(location, year, month, day, hour, minute);
    if (scheduled.isBefore(tz.TZDateTime.now(location))) {
      return scheduled;
    }
    return scheduled;
  }

  /// Schedules a period reminder 1 day before the predicted next period.
  Future<void> schedulePeriodReminder(
    DateTime nextPeriodDate,
    int hour,
    int minute,
    String locale,
  ) async {
    final reminderDate = nextPeriodDate.subtract(const Duration(days: 1));
    final now = DateTime.now();

    if (reminderDate.isBefore(now)) return;

    await _plugin.cancel(_periodReminderId);

    final scheduledDate = _nextInstanceOfDateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      hour,
      minute,
    );

    await _plugin.zonedSchedule(
      _periodReminderId,
      _t(locale, 'periodTitle'),
      _t(locale, 'periodBody'),
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'period_reminder',
          _t(locale, 'periodChannel'),
          channelDescription: _t(locale, 'periodChannelDesc'),
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedules an ovulation reminder on the predicted ovulation date.
  Future<void> scheduleOvulationReminder(
    DateTime ovulationDate,
    int hour,
    int minute,
    String locale,
  ) async {
    final now = DateTime.now();
    if (ovulationDate.isBefore(now)) return;

    await _plugin.cancel(_ovulationReminderId);

    final scheduledDate = _nextInstanceOfDateTime(
      ovulationDate.year,
      ovulationDate.month,
      ovulationDate.day,
      hour,
      minute,
    );

    await _plugin.zonedSchedule(
      _ovulationReminderId,
      _t(locale, 'ovulationTitle'),
      _t(locale, 'ovulationBody'),
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'ovulation_reminder',
          _t(locale, 'ovulationChannel'),
          channelDescription: _t(locale, 'ovulationChannelDesc'),
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedules a daily medication reminder.
  Future<void> scheduleMedicationReminder(
    int hour,
    int minute,
    String locale,
  ) async {
    await _plugin.cancel(_medicationReminderId);

    final now = DateTime.now();
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _medicationReminderId,
      _t(locale, 'medicationTitle'),
      _t(locale, 'medicationBody'),
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminder',
          _t(locale, 'medicationChannel'),
          channelDescription: _t(locale, 'medicationChannelDesc'),
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Reschedules all notifications based on profile preferences and cycle data.
  Future<void> rescheduleAll(UserProfile profile) async {
    if (!_isInitialized) return;

    try {
      await cancelAll();

      final hour = profile.reminderHour;
      final minute = profile.reminderMinute;
      final locale = profile.language;

      if (profile.lastPeriodStart != null) {
        final cycleLen = profile.averageCycleLength;
        final lastStart = profile.lastPeriodStart!;

        if (profile.periodReminderEnabled) {
          final nextPeriod = CycleUtils.predictNextPeriod(lastStart, cycleLen);
          await schedulePeriodReminder(nextPeriod, hour, minute, locale);
        }

        if (profile.ovulationReminderEnabled) {
          final ovulation = CycleUtils.predictOvulation(lastStart, cycleLen);
          await scheduleOvulationReminder(ovulation, hour, minute, locale);
        }
      }

      if (profile.medicationReminderEnabled) {
        await scheduleMedicationReminder(hour, minute, locale);
      }
    } catch (_) {
      // Notification scheduling failed - ignore to prevent app freeze
    }
  }
}
