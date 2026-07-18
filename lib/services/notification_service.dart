import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/daily_log.dart';
import '../models/enums.dart';
import '../models/period_record.dart';
import '../models/user_profile.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/cycle_utils.dart';
import '../core/utils/enum_labels.dart';
import '../core/utils/language_utils.dart';
import '../core/utils/phase_insights.dart';
import 'disguise_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Notification IDs
  // Regl/ovülasyon hatırlatmaları birkaç döngü ileriye planlanır;
  // uygulama açılmazsa bile zincir kopmasın diye taban ID + döngü indeksi.
  static const int _periodReminderBaseId = 10;
  static const int _ovulationReminderBaseId = 20;
  static const int _medicationReminderId = 3;
  // İlaç başına ayrı hatırlatma: ID çakışmasın diye ayrı aralık
  static const int _medicationReminderBaseId = 40;
  static const int _maxMedicationReminders = 10;
  // Faz ipucu (kişisel semptom tahmini): luteal başlangıcında
  static const int _insightReminderBaseId = 30;

  /// Kaç döngü ileriye hatırlatma planlanacağı
  static const int _cyclesToSchedule = 3;

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
      'discreetTitle': 'Hatırlatma',
      'discreetBody': 'Bugün için bir hatırlatman var',
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
      'discreetTitle': 'Reminder',
      'discreetBody': 'You have a reminder for today',
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

  /// Verilen tarih + saat için TZDateTime üretir.
  /// Geçmişte kaldıysa null döner (geçmişe bildirim planlanamaz).
  tz.TZDateTime? _scheduleFor(DateTime date, int hour, int minute) {
    final location = tz.local;
    final scheduled =
        tz.TZDateTime(location, date.year, date.month, date.day, hour, minute);
    if (scheduled.isBefore(tz.TZDateTime.now(location))) return null;
    return scheduled;
  }

  /// Schedules a period reminder 1 day before the predicted next period.
  /// [discreet]: gizli moddayken kilit ekranına düşen metin döngü bilgisi
  /// sızdırmamalı — nötr başlık/gövde kullanılır.
  Future<void> schedulePeriodReminder(
    DateTime nextPeriodDate,
    int hour,
    int minute,
    String locale, {
    int id = _periodReminderBaseId,
    bool discreet = false,
  }) async {
    final reminderDate = nextPeriodDate.subtract(const Duration(days: 1));

    await _plugin.cancel(id);

    // Saat dahil karşılaştır: hatırlatma günü bugünse ve saat henüz
    // gelmediyse bildirim yine de kurulmalı.
    final scheduledDate = _scheduleFor(reminderDate, hour, minute);
    if (scheduledDate == null) return;

    await _plugin.zonedSchedule(
      id,
      _t(locale, discreet ? 'discreetTitle' : 'periodTitle'),
      _t(locale, discreet ? 'discreetBody' : 'periodBody'),
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
    String locale, {
    int id = _ovulationReminderBaseId,
    bool discreet = false,
  }) async {
    await _plugin.cancel(id);

    final scheduledDate = _scheduleFor(ovulationDate, hour, minute);
    if (scheduledDate == null) return;

    await _plugin.zonedSchedule(
      id,
      _t(locale, discreet ? 'discreetTitle' : 'ovulationTitle'),
      _t(locale, discreet ? 'discreetBody' : 'ovulationBody'),
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
    String locale, {
    bool discreet = false,
  }) async {
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
      _t(locale, discreet ? 'discreetTitle' : 'medicationTitle'),
      _t(locale, discreet ? 'discreetBody' : 'medicationBody'),
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

  /// Her ilaç kendi saatinde hatırlatılır.
  ///
  /// Önceden yalnız profildeki genel hatırlatma saatinde tek bir bildirim
  /// atılıyordu: kullanıcı 08:00 ve 20:00 için iki ilaç girse bile ikisi de
  /// aynı genel saatte tek satır olarak geliyordu, `reminderTime` alanı
  /// hiç kullanılmıyordu.
  Future<void> scheduleMedicationReminders(
    List<MedicationEntry> medications,
    String locale, {
    required int fallbackHour,
    required int fallbackMinute,
    bool discreet = false,
  }) async {
    final named =
        medications.where((m) => m.name.trim().isNotEmpty).toList();
    final withTime = named
        .where((m) => m.reminderTime != null)
        .take(_maxMedicationReminders)
        .toList();
    // Saati olmayan ilaçlar saatlilerin gölgesinde kalmamalı: onlar için
    // genel saatte tek bir hatırlatma da kurulur (liste boşken eski
    // davranış zaten buydu)
    final hasUntimed = named.any((m) => m.reminderTime == null);

    if (withTime.isEmpty || hasUntimed) {
      await scheduleMedicationReminder(fallbackHour, fallbackMinute, locale,
          discreet: discreet);
      if (withTime.isEmpty) return;
    }

    for (var i = 0; i < withTime.length; i++) {
      final med = withTime[i];
      final parts = med.reminderTime!.split(':');
      final hour = int.tryParse(parts.first);
      final minute = parts.length > 1 ? int.tryParse(parts[1]) : null;
      if (hour == null || minute == null) continue;

      final now = DateTime.now();
      var scheduledDate =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Gizli modda ilaç adı da kilit ekranına düşmemeli
      final body = discreet
          ? _t(locale, 'discreetBody')
          : (med.dose.isEmpty ? med.name : '${med.name} — ${med.dose}');

      await _plugin.zonedSchedule(
        _medicationReminderBaseId + i,
        _t(locale, discreet ? 'discreetTitle' : 'medicationTitle'),
        body,
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
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Reschedules all notifications based on profile preferences and cycle data.
  /// [records] verilirse akıllı tahminle öğrenilen döngü uzunluğu kullanılır.
  Future<void> rescheduleAll(
    UserProfile profile, {
    List<PeriodRecord> records = const [],
    List<MedicationEntry> medications = const [],
    List<DailyLog> logs = const [],
  }) async {
    if (!_isInitialized) return;

    try {
      await cancelAll();

      // Gizli mod: launcher "Notlar" kılığındayken bildirim metni döngü
      // bilgisi deşifre etmemeli — tüm hatırlatmalar nötr metinle kurulur
      final discreet = await DisguiseService.isDisguised();

      final hour = profile.reminderHour;
      final minute = profile.reminderMinute;
      // 'system' tercihi somut dile çözülür (bildirim metinleri için)
      final locale = resolveLanguageCode(profile.language);

      // Hamilelik ve hap modunda regl/ovülasyon tahmin bildirimleri anlamsız;
      // TTC modu regl gibi döngü bildirimi alır
      final cyclePredictionsActive =
          profile.trackingMode == TrackingMode.period ||
              profile.trackingMode == TrackingMode.ttc;

      if (cyclePredictionsActive && profile.lastPeriodStart != null) {
        final cycleLen = CycleUtils.effectiveCycleLength(
          profile.averageCycleLength,
          records,
          smartEnabled: profile.smartPredictionEnabled,
        );
        final lastStart = profile.lastPeriodStart!;
        // Geçmişte kalan tahminleri ileri sar, sonra birkaç döngü planla
        final nextPeriod = CycleUtils.nextFuturePeriod(lastStart, cycleLen);

        for (int i = 0; i < _cyclesToSchedule; i++) {
          final periodDate = nextPeriod.add(Duration(days: cycleLen * i));

          if (profile.periodReminderEnabled) {
            await schedulePeriodReminder(
              periodDate,
              hour,
              minute,
              locale,
              id: _periodReminderBaseId + i,
              discreet: discreet,
            );
          }

          if (profile.ovulationReminderEnabled) {
            final ovulation = periodDate.subtract(
                const Duration(days: AppConstants.ovulationDayBeforePeriod));
            await scheduleOvulationReminder(
              ovulation,
              hour,
              minute,
              locale,
              id: _ovulationReminderBaseId + i,
              discreet: discreet,
            );
          }
        }

        // Kişisel semptom tahmini: kullanıcının kayıtları luteal fazda
        // belirgin bir semptom gösteriyorsa, luteal başlarken haber ver.
        // Gizli modda kurulmaz (nötrlenince bilgi değeri kalmıyor).
        if (profile.periodReminderEnabled && !discreet && logs.isNotEmpty) {
          final insights = topPhaseSymptoms(
            logs: logs,
            periodStarts: records.map((r) => r.startDate).toList(),
            cycleLength: cycleLen,
            periodLength: profile.averagePeriodLength,
          );
          final lutealInsight =
              topInsightForPhase(insights, CyclePhase.luteal);
          if (lutealInsight != null) {
            final l10n = lookupAppLocalizations(Locale(locale));
            final symptomName =
                EnumLabels.symptom(lutealInsight.symptom, l10n);
            // Luteal başlangıcı ~ ovülasyon + 2 gün = adet - 12 gün
            for (int i = 0; i < _cyclesToSchedule; i++) {
              final periodDate =
                  nextPeriod.add(Duration(days: cycleLen * i));
              final lutealStart = periodDate.subtract(const Duration(
                  days: AppConstants.ovulationDayBeforePeriod - 2));
              final scheduled = _scheduleFor(lutealStart, hour, minute);
              if (scheduled == null) continue;
              await _plugin.zonedSchedule(
                _insightReminderBaseId + i,
                l10n.notificationInsightTitle,
                l10n.notificationInsightBody(symptomName),
                scheduled,
                NotificationDetails(
                  android: AndroidNotificationDetails(
                    'phase_insight',
                    l10n.notificationInsightTitle,
                    channelDescription: l10n.notificationInsightTitle,
                    importance: Importance.defaultImportance,
                    priority: Priority.defaultPriority,
                    icon: '@mipmap/ic_launcher',
                  ),
                  iOS: const DarwinNotificationDetails(
                    presentAlert: true,
                    presentBadge: false,
                    presentSound: false,
                  ),
                ),
                androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime,
              );
            }
          }
        }
      }

      if (profile.medicationReminderEnabled) {
        await scheduleMedicationReminders(
          medications,
          locale,
          fallbackHour: hour,
          fallbackMinute: minute,
          discreet: discreet,
        );
      }
    } catch (e) {
      // Bildirim planlaması başarısız — uygulamayı kilitlememek için yutulur
      debugPrint('[NOTIF] rescheduleAll failed: $e');
    }
  }
}
