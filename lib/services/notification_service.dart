import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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

/// Bildirimden seçilen aksiyon: id + varsa taşıdığı veri.
class NotificationAction {
  final String id;
  final String? payload;
  const NotificationAction(this.id, {this.payload});
}

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
  // Gecikme kontrolü: tahmini tarihten birkaç gün sonra
  static const int _delayReminderBaseId = 50;
  // TTC modunda verimli pencerenin açıldığı gün
  static const int _fertileReminderBaseId = 60;
  // Planlanan zincirin sonunda tek bir "uygulamayı aç" hatırlatması
  static const int _chainEndReminderId = 5;

  /// Tahmini tarihten kaç gün sonra gecikme hatırlatması gönderileceği.
  /// Ertesi gün sormak erken (bir günlük sapma olağan), bir hafta geç.
  static const int _delayCheckAfterDays = 3;

  /// Kaç döngü ileriye hatırlatma planlanacağı
  static const int _cyclesToSchedule = 3;

  // Bildirim aksiyonları. Hatırlatma "reglin başlayabilir" diyordu ama
  // üzerinden hiçbir şey yapılamıyordu: kullanıcı uygulamayı açıp aynı işi
  // elle yapmak zorundaydı.
  static const String actionPeriodStarted = 'period_started';
  static const String actionMedicationTaken = 'medication_taken';

  /// Kullanıcının bildirimden seçtiği, henüz uygulanmamış aksiyon.
  ///
  /// Servis Hive'a kendi yazmıyor: yazma provider'lar üzerinden yapılmalı,
  /// yoksa ekrandaki durum yazılan veriyle ayrışır. `showsUserInterface`
  /// true olduğu için aksiyon her zaman uygulamayı açar ve iş ana
  /// isolate'te yapılır — arka plan isolate'inde şifreli kutulara yazmak
  /// gibi bir yola hiç girilmiyor.
  final ValueNotifier<NotificationAction?> pendingAction =
      ValueNotifier(null);

  void _onNotificationResponse(NotificationResponse response) {
    final actionId = response.actionId;
    if (actionId == null) return;
    pendingAction.value =
        NotificationAction(actionId, payload: response.payload);
  }

  /// Bildirim metinleri arayüzle aynı kaynaktan gelir (6 dil). Eskiden
  /// servisin içinde yalnız tr/en içeren ayrı bir tablo vardı: Almanca,
  /// İspanyolca, Fransızca ve Rusça kullanan kullanıcı arayüzü kendi
  /// dilinde görürken bildirimi İngilizce alıyordu.
  AppLocalizations _l10n(String locale) =>
      lookupAppLocalizations(Locale(locale));

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    // initializeTimeZones yalnız saat dilimi veritabanını yükler; tz.local
    // ayrıca bağlanmazsa UTC kalır ve zonedSchedule'a verilen her saat UTC
    // olarak yorumlanır (TSİ'de 09:00 hatırlatması 12:00'de düşerdi).
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (e) {
      // Cihaz saat dilimi okunamadı: UTC ile devam etmek saatleri kaydırır,
      // bu yüzden en azından görünür bir iz bırak
      debugPrint('[NOTIF] local timezone resolution failed, using UTC: $e');
    }

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

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Soğuk açılış: uygulama kapalıyken aksiyona basıldıysa yanıt geri
    // çağrısı çalışmadan başlatılmış olabilir
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final response = launch?.notificationResponse;
    if (launch?.didNotificationLaunchApp == true && response != null) {
      _onNotificationResponse(response);
    }

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

  /// "Reglim başladı" aksiyonu. `showsUserInterface: true` bilinçli:
  /// aksiyon uygulamayı açar ve yazma ana isolate'te provider üzerinden
  /// yapılır. Arka planda yazmak, şifreli Hive kutularını arka plan
  /// isolate'inde açmayı gerektirirdi.
  List<AndroidNotificationAction> _periodActions(AppLocalizations l10n) => [
        AndroidNotificationAction(
          actionPeriodStarted,
          l10n.actionPeriodStarted,
          showsUserInterface: true,
        ),
      ];

  /// "Aldım" aksiyonu; hangi ilaç olduğu payload'da taşınır.
  List<AndroidNotificationAction> _medicationActions(
          AppLocalizations l10n) =>
      [
        AndroidNotificationAction(
          actionMedicationTaken,
          l10n.actionMedicationTaken,
          showsUserInterface: true,
        ),
      ];

  /// Verilen tarih + saat için TZDateTime üretir.
  /// Geçmişte kaldıysa null döner (geçmişe bildirim planlanamaz).
  tz.TZDateTime? _scheduleFor(DateTime date, int hour, int minute) {
    final location = tz.local;
    final scheduled =
        tz.TZDateTime(location, date.year, date.month, date.day, hour, minute);
    if (scheduled.isBefore(tz.TZDateTime.now(location))) return null;
    return scheduled;
  }

  /// Regl hatırlatmasının gövdesi: zamanlama cümlesi + dönüşümlü ipucu.
  ///
  /// İki ayrı sorunu birlikte çözer. Gövde "yarın başlayabilir" diye
  /// sabitlenmişti; hatırlatma penceresi ayarlanabilir olunca (madde 68)
  /// 3 gün önce gelen bildirim yanlış gün söylüyordu. İkincisi, her ay
  /// harfi harfine aynı cümle gelmesi bildirimi görünmez kılıyor
  /// (madde 74) — ikinci cümle [variant] ile dönüyor.
  String _periodBody(AppLocalizations l10n, int leadDays, int variant) {
    final timing = leadDays <= 0
        ? l10n.notificationPeriodTimingToday
        : leadDays == 1
            ? l10n.notificationPeriodTimingTomorrow
            : l10n.notificationPeriodTimingInDays(leadDays);
    final tips = [
      l10n.notificationPeriodTip1,
      l10n.notificationPeriodTip2,
      l10n.notificationPeriodTip3,
    ];
    return '$timing ${tips[variant.abs() % tips.length]}';
  }

  /// Gecikme hatırlatmasının dönüşümlü gövdesi (madde 74).
  String _delayBody(AppLocalizations l10n, int variant) {
    final bodies = [
      l10n.notificationDelayBody,
      l10n.notificationDelayBodyAlt1,
      l10n.notificationDelayBodyAlt2,
    ];
    return bodies[variant.abs() % bodies.length];
  }

  /// Tahmini regl tarihinden [leadDays] gün önce hatırlatma kurar.
  ///
  /// [leadDays] sabit 1'di; hazırlanmak için daha erken haber almak isteyen
  /// kullanıcının seçeneği yoktu.
  /// [discreet]: gizli moddayken kilit ekranına düşen metin döngü bilgisi
  /// sızdırmamalı — nötr başlık/gövde kullanılır.
  /// [variant]: gövde havuzundan hangi ipucunun seçileceği.
  Future<void> schedulePeriodReminder(
    DateTime nextPeriodDate,
    int hour,
    int minute,
    String locale, {
    int id = _periodReminderBaseId,
    int leadDays = 1,
    bool discreet = false,
    int variant = 0,
  }) async {
    final l10n = _l10n(locale);
    // Metin ile tarih AYNI değeri kullanmalı: kırpılmamış leadDays ile
    // yazılan gövde, kırpılmış tarihten farklı bir gün söylerdi.
    final lead = leadDays.clamp(0, 7);
    final reminderDate = nextPeriodDate.subtract(Duration(days: lead));

    await _plugin.cancel(id);

    // Saat dahil karşılaştır: hatırlatma günü bugünse ve saat henüz
    // gelmediyse bildirim yine de kurulmalı.
    final scheduledDate = _scheduleFor(reminderDate, hour, minute);
    if (scheduledDate == null) return;

    await _plugin.zonedSchedule(
      id,
      discreet ? l10n.notificationDiscreetTitle : l10n.notificationPeriodTitle,
      discreet
          ? l10n.notificationDiscreetBody
          : _periodBody(l10n, lead, variant),
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'period_reminder',
          l10n.notificationPeriodChannel,
          channelDescription: l10n.notificationPeriodChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          // Gizli modda aksiyon konmaz: etiketin kendisi kılığı deşifre eder
          actions: discreet ? const [] : _periodActions(l10n),
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
    final l10n = _l10n(locale);
    await _plugin.cancel(id);

    final scheduledDate = _scheduleFor(ovulationDate, hour, minute);
    if (scheduledDate == null) return;

    await _plugin.zonedSchedule(
      id,
      discreet ? l10n.notificationDiscreetTitle : l10n.notificationOvulationTitle,
      discreet ? l10n.notificationDiscreetBody : l10n.notificationOvulationBody,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'ovulation_reminder',
          l10n.notificationOvulationChannel,
          channelDescription: l10n.notificationOvulationChannelDesc,
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

  /// TTC modunda verimli pencerenin AÇILDIĞI gün gönderilir.
  ///
  /// Ovülasyon günü bildirimi hamile kalmaya çalışan kullanıcı için geç
  /// kalıyor: sperm ömrü nedeniyle asıl fırsat ovülasyondan önceki
  /// günlerde. Aynı metnin hem takip hem TTC kullanıcısına gitmesi de
  /// yanlıştı — TTC'nin sorusu "hangi gün" değil, "ne zaman başlıyor".
  Future<void> scheduleFertileWindowReminder(
    DateTime windowStart,
    int hour,
    int minute,
    String locale, {
    required int id,
    bool discreet = false,
  }) async {
    final l10n = _l10n(locale);
    await _plugin.cancel(id);

    final scheduledDate = _scheduleFor(windowStart, hour, minute);
    if (scheduledDate == null) return;

    await _plugin.zonedSchedule(
      id,
      discreet ? l10n.notificationDiscreetTitle : l10n.notificationFertileTitle,
      discreet ? l10n.notificationDiscreetBody : l10n.notificationFertileBody,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'ovulation_reminder',
          l10n.notificationOvulationChannel,
          channelDescription: l10n.notificationOvulationChannelDesc,
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

  /// Planlanan zincirin bittiğini haber verir.
  ///
  /// Hatırlatmalar yalnız [_cyclesToSchedule] döngü ileriye kurulabiliyor
  /// (platform sınırı: uygulama açılmadan yeni bildirim planlanamaz).
  /// Uygulama o süre boyunca açılmazsa zincir SESSİZCE kopuyordu; kullanıcı
  /// hatırlatmaların durduğunu ancak bir gününü kaçırınca fark ediyordu.
  ///
  /// Metin gizli modda da nötrlenmez: "hatırlatmalar bitti, uygulamayı aç"
  /// cümlesi bir not defteri için de aynen geçerli, döngü bilgisi taşımıyor.
  Future<void> scheduleChainEndReminder(
    DateTime date,
    int hour,
    int minute,
    String locale, {
    int id = _chainEndReminderId,
  }) async {
    final l10n = _l10n(locale);
    await _plugin.cancel(id);

    final scheduledDate = _scheduleFor(date, hour, minute);
    if (scheduledDate == null) return;

    await _plugin.zonedSchedule(
      id,
      l10n.notificationChainEndTitle,
      l10n.notificationChainEndBody,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'chain_end',
          l10n.notificationChainEndTitle,
          channelDescription: l10n.notificationChainEndBody,
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

  /// Tahmini tarih geçtiği hâlde kayıt gelmediyse gönderilen hatırlatma.
  ///
  /// Metin bilinçli olarak tanı koymaz ve gebelikten söz etmez: sapma çok
  /// yaygın, uygulamanın işi kaygı üretmek değil kaydı güncel tutmak.
  Future<void> scheduleDelayReminder(
    DateTime checkDate,
    int hour,
    int minute,
    String locale, {
    required int id,
    bool discreet = false,
    int variant = 0,
  }) async {
    final l10n = _l10n(locale);
    await _plugin.cancel(id);

    final scheduledDate = _scheduleFor(checkDate, hour, minute);
    if (scheduledDate == null) return;

    await _plugin.zonedSchedule(
      id,
      discreet ? l10n.notificationDiscreetTitle : l10n.notificationDelayTitle,
      discreet
          ? l10n.notificationDiscreetBody
          : _delayBody(l10n, variant),
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'period_delay',
          l10n.notificationDelayChannel,
          channelDescription: l10n.notificationDelayChannelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          actions: discreet ? const [] : _periodActions(l10n),
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

  /// Schedules a daily medication reminder.
  Future<void> scheduleMedicationReminder(
    int hour,
    int minute,
    String locale, {
    bool discreet = false,
  }) async {
    final l10n = _l10n(locale);
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
      discreet ? l10n.notificationDiscreetTitle : l10n.notificationMedicationTitle,
      discreet ? l10n.notificationDiscreetBody : l10n.notificationMedicationBody,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminder',
          l10n.notificationMedicationChannel,
          channelDescription: l10n.notificationMedicationChannelDesc,
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
    final l10n = _l10n(locale);
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
          ? l10n.notificationDiscreetBody
          : (med.dose.isEmpty ? med.name : '${med.name} — ${med.dose}');

      await _plugin.zonedSchedule(
        _medicationReminderBaseId + i,
        discreet ? l10n.notificationDiscreetTitle : l10n.notificationMedicationTitle,
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminder',
            l10n.notificationMedicationChannel,
            channelDescription: l10n.notificationMedicationChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            actions: discreet ? const [] : _medicationActions(l10n),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        // Hangi ilacın işaretleneceği aksiyonla birlikte taşınmalı
        payload: med.name,
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

      // Tek saat tüm hatırlatmaları yönetiyordu: ilacını sabah alan ama
      // regl uyarısını akşam isteyen kullanıcı birinden vazgeçiyordu.
      // Özel saat yoksa ikisi de genel saate düşer (eski davranış).
      final cycleHour = profile.effectiveCycleHour;
      final cycleMinute = profile.effectiveCycleMinute;
      final medHour = profile.effectiveMedicationHour;
      final medMinute = profile.effectiveMedicationMinute;
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
              cycleHour,
              cycleMinute,
              locale,
              id: _periodReminderBaseId + i,
              leadDays: profile.periodReminderLeadDays,
              discreet: discreet,
              // Ay numarası: hangi anda planlandığından bağımsız olarak
              // ardışık aylara farklı ipucu düşer. Döngü indeksi (i)
              // kullanılsaydı her yeniden planlamada havuz başa dönerdi.
              variant: periodDate.month,
            );
          }

          if (profile.ovulationReminderEnabled) {
            final ovulation = periodDate.subtract(
                const Duration(days: AppConstants.ovulationDayBeforePeriod));
            await scheduleOvulationReminder(
              ovulation,
              cycleHour,
              cycleMinute,
              locale,
              id: _ovulationReminderBaseId + i,
              discreet: discreet,
            );

            // TTC modunda pencerenin açılışı ovülasyon gününden daha
            // kritik; takip modunda böyle bir bildirim gereksiz gürültü.
            if (profile.trackingMode == TrackingMode.ttc) {
              await scheduleFertileWindowReminder(
                ovulation.subtract(const Duration(
                    days: AppConstants.fertileWindowStartBeforeOvulation)),
                cycleHour,
                cycleMinute,
                locale,
                id: _fertileReminderBaseId + i,
                discreet: discreet,
              );
            }
          }

          // Gecikme kontrolü: tahmini tarih geçtiği hâlde kayıt gelmediyse
          // uygulamanın söyleyecek sözü yoktu. Regl başlatıldığında
          // rescheduleAll yeniden çalıştığı için bu hatırlatma iptal olur.
          if (profile.periodReminderEnabled) {
            await scheduleDelayReminder(
              periodDate.add(const Duration(days: _delayCheckAfterDays)),
              cycleHour,
              cycleMinute,
              locale,
              id: _delayReminderBaseId + i,
              discreet: discreet,
              variant: periodDate.month,
            );
          }
        }

        // Zincirin sonu: son planlanan döngüden bir döngü sonrası. O tarihe
        // gelindiğinde kurulu tek bildirim bu olur; kullanıcı uygulamayı
        // açınca rescheduleAll yeniden çalışır ve zincir uzar.
        if (profile.periodReminderEnabled ||
            profile.ovulationReminderEnabled) {
          await scheduleChainEndReminder(
            nextPeriod.add(Duration(days: cycleLen * _cyclesToSchedule)),
            cycleHour,
            cycleMinute,
            locale,
          );
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
            final l10n = _l10n(locale);
            final symptomName =
                EnumLabels.symptom(lutealInsight.symptom, l10n);
            // Luteal başlangıcı ~ ovülasyon + 2 gün = adet - 12 gün
            for (int i = 0; i < _cyclesToSchedule; i++) {
              final periodDate =
                  nextPeriod.add(Duration(days: cycleLen * i));
              final lutealStart = periodDate.subtract(const Duration(
                  days: AppConstants.ovulationDayBeforePeriod - 2));
              final scheduled = _scheduleFor(lutealStart, cycleHour, cycleMinute);
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
          fallbackHour: medHour,
          fallbackMinute: medMinute,
          discreet: discreet,
        );
      }
    } catch (e) {
      // Bildirim planlaması başarısız — uygulamayı kilitlememek için yutulur
      debugPrint('[NOTIF] rescheduleAll failed: $e');
    }
  }
}
