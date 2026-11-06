import '../core/utils/cycle_prediction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/backup_service.dart';
import '../services/usage_metrics.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import '../services/premium_service.dart';
import '../services/widget_service.dart';
import '../models/user_profile.dart';
import '../models/period_record.dart';
import '../models/daily_log.dart';
import '../models/enums.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/cycle_utils.dart';
import '../core/utils/date_only.dart';
import '../core/utils/phase_insights.dart';
import '../core/utils/statistics_summary.dart';
import 'package:uuid/uuid.dart';

// ─── Service Providers ────────────────────────────────────────────────

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

// ─── Simple State Providers ───────────────────────────────────────────

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// null = sistem dili (MaterialApp cihaz dilini kendisi çözer);
/// somut Locale = kullanıcının elle seçtiği dil
final localeProvider = StateProvider<Locale?>((ref) {
  return null;
});

/// Profildeki tema tercihini ThemeMode'a çevirir.
/// '' = themePreference alanı eklenmeden önceki kayıt: kullanıcının o
/// günkü açık/koyu seçimi (darkModeEnabled) korunur. Yeni kullanıcı ve
/// profili olmayan açılış sistem temasını izler.
ThemeMode themeModeFromProfile(UserProfile? profile) {
  if (profile == null) return ThemeMode.system;
  return switch (profile.themePreference) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    'system' => ThemeMode.system,
    _ => profile.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
  };
}

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

/// Renk körü dostu doku modu: faz bantlarına renk + desen çift kodlama.
/// Kalıcılığı SharedPreferences 'phase_pattern' — main.dart açılışta
/// override eder, ayarlar değiştirince yazar.
final phasePatternProvider = StateProvider<bool>((ref) => false);

enum HomePriority {
  cycle,
  today;

  static HomePriority fromStorage(String? value) =>
      value == today.name ? today : cycle;
}

const String homePriorityKey = 'home_priority';

final homePriorityProvider = StateProvider<HomePriority>(
  (ref) => HomePriority.cycle,
);

/// "Farklı bir gün için uzun bas" ipucu hâlâ gösterilmeli mi?
/// Kullanıcı hareketi bir kez kullanınca kalıcı olarak kapanır — keşfi
/// olmayan bir hareket, olmayan bir özelliktir.
/// Kalıcılığı SharedPreferences 'backdate_hint_needed'.
final backdateHintProvider = StateProvider<bool>((ref) => true);

/// Son başarılı yedeğin zamanı; hiç yedek alınmadıysa null.
/// Yedekleme tamamen kullanıcıya bırakılmıştı ve hatırlatan hiçbir şey
/// yoktu: telefon kaybında yılların verisi gidiyordu.
final lastBackupProvider = FutureProvider<DateTime?>(
  (ref) => BackupService.lastBackupAt(),
);

// ─── Erişim (deneme / premium / ücretsiz) ─────────────────────────────

/// 30 gün tam deneme → abonelik yoksa yalnız regl takibi.
enum AccessLevel {
  /// Aktif abonelik (veya eski tek seferlik premium): her şey açık.
  premium,

  /// Ücretsiz deneme penceresi: her şey açık.
  trial,

  /// Deneme bitti, abonelik yok: yalnız regl takibi + takvim.
  free,
}

/// Çalışma zamanı premium durumu. Başlangıç değeri main'de önbellekten
/// override edilir; satın alma olayları app.dart köprüsüyle günceller.
final isPremiumProvider = StateProvider<bool>((ref) => false);

/// Deneme başlangıcı (main'de SharedPreferences'tan override edilir).
/// null = henüz çözülmedi: kullanıcıyı yanlışlıkla kısıtlamamak için
/// deneme sayılır.
final trialStartProvider = StateProvider<DateTime?>((ref) => null);

final accessProvider = Provider<AccessLevel>((ref) {
  if (ref.watch(isPremiumProvider)) return AccessLevel.premium;
  final start = ref.watch(trialStartProvider);
  if (start == null) return AccessLevel.trial;
  final elapsed = DateTime.now().difference(start).inDays;
  return elapsed < PremiumService.trialDays
      ? AccessLevel.trial
      : AccessLevel.free;
});

final trialDaysLeftProvider = Provider<int>((ref) {
  final start = ref.watch(trialStartProvider);
  if (start == null) return PremiumService.trialDays;
  final left =
      PremiumService.trialDays - DateTime.now().difference(start).inDays;
  return left < 0 ? 0 : left;
});

// ─── UserProfile Provider ─────────────────────────────────────────────

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
      final hiveService = ref.watch(hiveServiceProvider);
      return UserProfileNotifier(hiveService);
    });

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final HiveService _hiveService;

  UserProfileNotifier(this._hiveService) : super(null) {
    _load();
  }

  void _load() {
    try {
      state = _hiveService.getUserProfile();
    } catch (e) {
      debugPrint('[HIVE] getUserProfile failed: $e');
      state = null;
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    final firstSetup =
        state?.onboardingCompleted != true && profile.onboardingCompleted;
    await _hiveService.saveUserProfile(profile);
    if (firstSetup) await UsageMetrics.record(UsageEvent.onboardingCompleted);
    state = profile;

    // Onboarding bu yoldan geliyor: bildirimler ve widget ilk kayıtta da
    // kurulmalı, yoksa uygulama yeniden başlatılana dek hatırlatma yok
    try {
      await NotificationService().rescheduleAll(
        profile,
        records: _hiveService.getAllPeriodRecords(),
        medications: profile.medicationPlan,
        logs: _hiveService.getAllDailyLogs(),
      );
    } catch (e) {
      debugPrint('[NOTIF] rescheduleAll failed: $e');
    }
    await WidgetService.update(profile, _hiveService.getAllPeriodRecords());
  }

  Future<void> saveProfile({
    String? name,
    DateTime? birthDate,
    int? averageCycleLength,
    int? averagePeriodLength,
    bool? pinEnabled,
    bool? biometricEnabled,
    bool? onboardingCompleted,
    String? language,
    DateTime? lastPeriodStart,
    bool? periodReminderEnabled,
    bool? ovulationReminderEnabled,
    bool? medicationReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? darkModeEnabled,
    int? waterGoal,
    bool? smartPredictionEnabled,
    TrackingMode? trackingMode,
    DateTime? pregnancyStartDate,
    DateTime? pillPackStartDate,
    String? themePreference,
    int? medicationReminderHour,
    int? medicationReminderMinute,
    int? cycleReminderHour,
    int? cycleReminderMinute,
    int? periodReminderLeadDays,
    bool? quietNotifications,
    bool? usePounds,
    bool? useFahrenheit,
    List<MedicationEntry>? medicationPlan,
    bool? medicationPlanMigrated,
    int? cycleNotificationFrequency,
    bool clearLastPeriodStart = false,
    int? pillActiveDays,
    int? pillBreakDays,
  }) async {
    final current = state ?? UserProfile();
    final updated = current.copyWith(
      pillActiveDays: pillActiveDays,
      pillBreakDays: pillBreakDays,
      name: name,
      birthDate: birthDate,
      averageCycleLength: averageCycleLength,
      averagePeriodLength: averagePeriodLength,
      pinEnabled: pinEnabled,
      biometricEnabled: biometricEnabled,
      onboardingCompleted: onboardingCompleted,
      language: language,
      lastPeriodStart: lastPeriodStart,
      periodReminderEnabled: periodReminderEnabled,
      ovulationReminderEnabled: ovulationReminderEnabled,
      medicationReminderEnabled: medicationReminderEnabled,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      // Tema tercihi değişince eski bool da senkron tutulur: eski sürüme
      // taşınan yedek kullanıcının açık/koyu seçimini kaybetmesin
      darkModeEnabled:
          darkModeEnabled ??
          (themePreference == null ? null : themePreference == 'dark'),
      waterGoal: waterGoal,
      smartPredictionEnabled: smartPredictionEnabled,
      trackingMode: trackingMode,
      pregnancyStartDate: pregnancyStartDate,
      pillPackStartDate: pillPackStartDate,
      themePreference: themePreference,
      medicationReminderHour: medicationReminderHour,
      medicationReminderMinute: medicationReminderMinute,
      cycleReminderHour: cycleReminderHour,
      cycleReminderMinute: cycleReminderMinute,
      periodReminderLeadDays: periodReminderLeadDays,
      quietNotifications: quietNotifications,
      usePounds: usePounds,
      useFahrenheit: useFahrenheit,
      medicationPlan: medicationPlan,
      medicationPlanMigrated: medicationPlanMigrated,
      cycleNotificationFrequency: cycleNotificationFrequency,
      clearLastPeriodStart: clearLastPeriodStart,
    );

    await _hiveService.saveUserProfile(updated);
    state = updated;

    // Reschedule notifications when relevant settings change
    if (periodReminderEnabled != null ||
        language != null ||
        ovulationReminderEnabled != null ||
        medicationReminderEnabled != null ||
        reminderHour != null ||
        reminderMinute != null ||
        lastPeriodStart != null ||
        clearLastPeriodStart ||
        smartPredictionEnabled != null ||
        trackingMode != null ||
        // Döngü/regl süresi tahmin tarihlerini kaydırır — bildirimler
        // yeniden planlanmazsa eski tarihlerde kalır
        averageCycleLength != null ||
        averagePeriodLength != null ||
        // Saat ve pencere değişince planlar eski değerlerde kalırdı
        medicationReminderHour != null ||
        medicationReminderMinute != null ||
        cycleReminderHour != null ||
        cycleReminderMinute != null ||
        periodReminderLeadDays != null ||
        // Sessizlik tercihi kanal kimliğini değiştiriyor: kurulu
        // bildirimler yeniden planlanmazsa eski kanalda kalır
        quietNotifications != null ||
        cycleNotificationFrequency != null ||
        medicationPlan != null) {
      try {
        await NotificationService().rescheduleAll(
          updated,
          records: _hiveService.getAllPeriodRecords(),
          medications: updated.medicationPlan,
          // Günlük kayıtlar verilmezse kişisel semptom (faz ipucu)
          // bildirimleri her ayar değişikliğinde sessizce düşüyordu
          logs: _hiveService.getAllDailyLogs(),
        );
      } catch (e) {
        debugPrint('[NOTIF] rescheduleAll failed: $e');
      }
    }

    await WidgetService.update(updated, _hiveService.getAllPeriodRecords());
  }

  /// Profildeki "son regl tarihi"ni kayıtlardan türetir: en yeni kaydın
  /// başlangıcı. Kayıt kalmadıysa tarih temizlenir.
  ///
  /// Akışlar profil tarihini elle `record.startDate`'e çekiyordu; geçmişe
  /// eklenen bir kayıt bu yüzden son regl tarihini GERİYE taşıyıp tüm
  /// tahminleri bozuyordu. Son kayıt silindiğinde de profil silinmiş tarihe
  /// dayanarak tahmin üretmeye devam ediyordu.
  Future<void> syncLastPeriodStart(List<PeriodRecord> records) async {
    final current = state?.lastPeriodStart;
    if (records.isEmpty) {
      if (current != null) await saveProfile(clearLastPeriodStart: true);
      return;
    }
    final newest = records
        .map((r) => r.startDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    if (current == null || !isSameDay(current, newest)) {
      await saveProfile(lastPeriodStart: dateOnly(newest));
    }
  }

  void refresh() {
    _load();
  }
}

// ─── PeriodRecords Provider ───────────────────────────────────────────

final periodRecordsProvider =
    StateNotifierProvider<PeriodRecordsNotifier, List<PeriodRecord>>((ref) {
      final hiveService = ref.watch(hiveServiceProvider);
      return PeriodRecordsNotifier(hiveService);
    });

class PeriodRecordsNotifier extends StateNotifier<List<PeriodRecord>> {
  final HiveService _hiveService;
  static const _uuid = Uuid();

  PeriodRecordsNotifier(this._hiveService) : super([]) {
    _load();
  }

  void _load() {
    try {
      state = _hiveService.getAllPeriodRecords();
    } catch (e) {
      debugPrint('[HIVE] getAllPeriodRecords failed: $e');
      state = [];
    }
  }

  bool _overlapsOther(String? ignoredId, DateTime start, DateTime? end) =>
      state.any((other) {
        if (other.id == ignoredId) return false;
        final otherStart = dateOnly(other.startDate);
        final otherEnd = other.endDate == null ? null : dateOnly(other.endDate!);
        return !(end?.isBefore(otherStart) ?? false) &&
            !(otherEnd?.isBefore(start) ?? false);
      });

  Future<void> addRecord(PeriodRecord record) async {
    await _hiveService.savePeriodRecord(record);
    _load();
  }

  /// Takvimde seçilen kapsayıcı aralığı tek kapalı regl kaydı olarak ekler.
  /// Mevcut bir kayıtla kesişirse veri çiftlenmesin diye null döner.
  Future<PeriodRecord?> addCompletedPeriodRange(
    DateTime start,
    DateTime end,
  ) async {
    final records = await addCompletedPeriodRanges([(start: start, end: end)]);
    return records?.single;
  }

  /// En fazla birkaç geçmiş döngüyü doğrulayıp tek işlem olarak ekler.
  /// Mevcut kayıtlarla veya kendi içinde çakışan paket hiç yazılmaz.
  Future<List<PeriodRecord>?> addCompletedPeriodRanges(
    List<({DateTime start, DateTime end})> ranges,
  ) async {
    final normalized = ranges.map((range) {
      final start = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
      );
      final rawEnd = DateTime(range.end.year, range.end.month, range.end.day);
      return (start: start, end: rawEnd.isBefore(start) ? start : rawEnd);
    }).toList();

    final occupied = state.map((record) {
      final start = DateTime(
        record.startDate.year,
        record.startDate.month,
        record.startDate.day,
      );
      final rawEnd = record.endDate ?? DateTime.now();
      return (
        start: start,
        end: DateTime(rawEnd.year, rawEnd.month, rawEnd.day),
      );
    }).toList();
    bool overlaps(
      ({DateTime start, DateTime end}) a,
      ({DateTime start, DateTime end}) b,
    ) => !a.end.isBefore(b.start) && !a.start.isAfter(b.end);

    for (var index = 0; index < normalized.length; index++) {
      if (occupied.any((range) => overlaps(normalized[index], range))) {
        return null;
      }
      for (var other = index + 1; other < normalized.length; other++) {
        if (overlaps(normalized[index], normalized[other])) return null;
      }
    }

    final records = normalized
        .map(
          (range) => PeriodRecord(
            id: _uuid.v4(),
            startDate: range.start,
            endDate: range.end,
          ),
        )
        .toList();
    for (final record in records) {
      await _hiveService.savePeriodRecord(record);
    }
    _load();
    return records;
  }

  Future<void> updateRecord(PeriodRecord record) async {
    await _hiveService.savePeriodRecord(record);
    _load();
  }

  Future<void> deleteRecord(String id) async {
    await _hiveService.deletePeriodRecord(id);
    _load();
  }

  /// [date] gününde regl başlatır.
  ///
  /// - Gün mevcut kapalı bir kaydın içindeyse ya da süren kaydın başlangıç
  ///   günüyse yeni kayıt açılmaz, o kayıt döner.
  /// - Gün süren bir kaydın başlangıcından sonraysa süren kayıt bir gün
  ///   öncesiyle kapatılır ve yeni (süren) kayıt açılır.
  /// - Gün daha yeni bir kaydın ÖNCESİNDEYSE (geçmişe ekleme) kayıt kapalı
  ///   açılır ve sonraki kayda taşmaz. Eskiden bitişsiz açılıyordu: takvimde
  ///   40 gün önceye "regl bu gün başladı" demek 41 gün süren, sonraki
  ///   kayıtlarla çakışan bir kayıt üretiyordu.
  /// - [periodLength] verilirse ve o süre bugünden önce dolmuşsa kayıt yine
  ///   kapalı açılır (geçmiş bir başlangıç bugün hâlâ sürüyor sayılmaz).
  Future<PeriodRecord> startPeriod(DateTime date, {int? periodLength}) async {
    final day = dateOnly(date);
    final today = dateOnly(DateTime.now());
    final length = periodLength ?? AppConstants.defaultPeriodLength;

    for (final record in state) {
      if (!record.isOngoing && record.containsDate(day)) return record;
      if (record.isOngoing && isSameDay(record.startDate, day)) return record;
    }

    // Bu günden önce başlamış süren kayıtlar bir gün öncesiyle kapanır
    for (final record in state.where((r) => r.isOngoing).toList()) {
      if (day.isAfter(dateOnly(record.startDate))) {
        record.endDate = addDays(day, -1);
        await _hiveService.savePeriodRecord(record);
      }
    }

    DateTime? nextStart;
    for (final record in state) {
      final start = dateOnly(record.startDate);
      if (start.isAfter(day) &&
          (nextStart == null || start.isBefore(nextStart))) {
        nextStart = start;
      }
    }

    DateTime? end;
    if (nextStart != null) {
      final natural = addDays(day, length - 1);
      final beforeNext = addDays(nextStart, -1);
      end = natural.isBefore(beforeNext) ? natural : beforeNext;
    } else if (periodLength != null) {
      end = CycleUtils.completedPeriodEnd(day, periodLength, today);
    }

    final record = PeriodRecord(id: _uuid.v4(), startDate: day, endDate: end);
    await _hiveService.savePeriodRecord(record);
    _load();
    // Widget güncellemesi burada değil: çağıran akış hemen ardından
    // profili (syncLastPeriodStart) günceller, widget orada kurulur
    return record;
  }

  /// Kayıt düzenleyici: başlangıç/bitiş tarihlerini doğrudan atar.
  /// Tarihler güne indirgenir; bitiş başlangıçtan önce olamaz.
  /// [end] null = kayıt devam ediyor.
  Future<void> updateRecordDates(
    String recordId,
    DateTime start,
    DateTime? end,
  ) async {
    PeriodRecord? record;
    for (final r in state) {
      if (r.id == recordId) {
        record = r;
        break;
      }
    }
    if (record == null) return;
    final normalizedStart = DateTime(start.year, start.month, start.day);
    DateTime? normalizedEnd;
    if (end != null) {
      normalizedEnd = DateTime(end.year, end.month, end.day);
      if (normalizedEnd.isBefore(normalizedStart)) {
        normalizedEnd = normalizedStart;
      }
    }
    if (_overlapsOther(recordId, normalizedStart, normalizedEnd)) {
      throw ArgumentError('Period range overlaps another record');
    }
    // Hive nesnesini diske yazmadan önce değiştirme: yazma hatasında ekran
    // eski kayıt varmış gibi görünmeye devam edebilmeli.
    await _hiveService.savePeriodRecord(PeriodRecord(
      id: record.id,
      startDate: normalizedStart,
      endDate: normalizedEnd,
      notes: record.notes,
    ));
    _load();
    await WidgetService.update(_hiveService.getUserProfile(), state);
  }

  /// "Reglim bitti"nin geri alınması: kaydı yeniden açık hale getirir.
  Future<void> reopenRecord(String recordId) async {
    for (final r in state) {
      if (r.id == recordId) {
        r.endDate = null;
        await _hiveService.savePeriodRecord(r);
        break;
      }
    }
    _load();
    await WidgetService.update(_hiveService.getUserProfile(), state);
  }

  /// Profildeki "son regl tarihi" düzenlendiğinde kayıtları eşitler.
  ///
  /// [startPeriod] bu iş için yanlış araç: yeni tarih süren kaydın
  /// başlangıcından önceyse kayıt açmaz, üstelik mevcut kaydı kırpar —
  /// profil ile kayıtlar ayrışır (geriye-tarih tuzağı). Burada eski
  /// profil tarihine karşılık gelen kayıt bulunur ve YERİNDE taşınır;
  /// yoksa bağımsız yeni bir kayıt açılır. Bitiş, regl bugün hâlâ
  /// sürüyor olmalı mı sorusuna göre yeniden türetilir.
  Future<void> syncProfilePeriodRecord({
    DateTime? previousStart,
    required DateTime newStart,
    required int periodLength,
  }) async {
    final normalizedNew = DateTime(newStart.year, newStart.month, newStart.day);

    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    // Yeni tarih zaten kayıtlıysa dokunma
    if (state.any((r) => sameDay(r.startDate, normalizedNew))) return;

    final end = CycleUtils.completedPeriodEnd(
      normalizedNew,
      periodLength,
      DateTime.now(),
    );

    PeriodRecord? target;
    if (previousStart != null) {
      for (final r in state) {
        if (sameDay(r.startDate, previousStart)) {
          target = r;
          break;
        }
      }
    }

    if (target != null) {
      // Düzeltme: aynı kaydı taşı, çift kayıt üretme
      await updateRecordDates(target.id, normalizedNew, end);
    } else {
      if (_overlapsOther(null, normalizedNew, end)) {
        throw ArgumentError('Period range overlaps another record');
      }
      await addRecord(
        PeriodRecord(id: _uuid.v4(), startDate: normalizedNew, endDate: end),
      );
    }
  }

  Future<void> endPeriod(String recordId, DateTime date) async {
    try {
      final record = state.firstWhere((r) => r.id == recordId);
      // Bitiş tarihi başlangıçtan önce olamaz
      final day = dateOnly(date);
      record.endDate = day.isBefore(dateOnly(record.startDate))
          ? record.startDate
          : day;
      await _hiveService.savePeriodRecord(record);
      _load();
      await WidgetService.update(_hiveService.getUserProfile(), state);
    } catch (_) {
      // Record not found
    }
  }

  void refresh() {
    _load();
  }
}

// ─── DailyLog Provider ───────────────────────────────────────────────

final dailyLogProvider =
    StateNotifierProvider<DailyLogNotifier, Map<String, DailyLog>>((ref) {
      final hiveService = ref.watch(hiveServiceProvider);
      return DailyLogNotifier(hiveService);
    });

class DailyLogNotifier extends StateNotifier<Map<String, DailyLog>> {
  final HiveService _hiveService;
  static const _uuid = Uuid();
  final Map<String, Future<void>> _writes = {};
  Future<void> _serial(DateTime day, Future<void> Function() write) {
    final key = DateTime(day.year, day.month, day.day).toIso8601String();
    final next = (_writes[key] ?? Future.value()).then((_) => write());
    final barrier = next.catchError((Object _) {});
    _writes[key] = barrier;
    barrier.then((_) {
      if (identical(_writes[key], barrier)) _writes.remove(key);
    });
    return next;
  }

  DailyLogNotifier(this._hiveService) : super({}) {
    _load();
  }

  void _load() {
    try {
      final logs = _hiveService.getAllDailyLogs();
      final map = <String, DailyLog>{};
      for (final log in logs) {
        map[log.dateKey] = log;
      }
      state = map;
    } catch (_) {
      state = {};
    }
  }

  DailyLog? getDailyLog(DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return state[dateKey];
  }

  Future<void> saveDailyLog(DailyLog log) async {
    await _hiveService.saveDailyLog(log);
    state = {...state, log.dateKey: log};
  }

  /// Silinen son alan boş bir günlük ve takvim işareti bırakmasın.
  /// Seri günlük kuyruğunun içinden çağrılır; diğer alanlar korunur.
  Future<void> _saveOrDeleteDailyLog(DailyLog log) async {
    if (hasMeaningfulDailyData(log)) {
      await saveDailyLog(log);
    } else {
      await deleteDailyLog(log.dateKey);
    }
  }

  DailyLog _getOrCreateLog(DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final current = state[dateKey];
    return current == null
        ? DailyLog(id: _uuid.v4(), date: date)
        : DailyLog.fromJson(current.toJson());
  }

  Future<void> updateSymptoms(DateTime date, List<SymptomEntry> symptoms) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      log.symptoms = symptoms;
      await _saveOrDeleteDailyLog(log);
    });
  }

  Future<void> updateMood(DateTime date, MoodEntry? mood) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      log.mood = mood;
      await _saveOrDeleteDailyLog(log);
    });
  }

  static String _appendNote(String? existingNote, String note) {
    final existing = existingNote?.trim() ?? '';
    final text = note.trim();
    if (existing.isEmpty) return text;
    if (text.isEmpty || existing == text || existing.endsWith('\n$text')) {
      return existing;
    }
    return '$existing\n$text';
  }

  /// Ruh hali kaldırılırken formdaki notu bağımsız günlük notuna taşır.
  /// Her iki alan tek Hive yazımında değişir; mevcut günlük notu korunur.
  Future<void> removeMoodKeepingNote(DateTime date, String note) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      final text = note.trim();
      if (text.isNotEmpty) {
        log.notes = _appendNote(log.notes, text);
      }
      log.mood = null;
      await _saveOrDeleteDailyLog(log);
    });
  }

  /// Hızlı formun dört alanını tek günlük yazımıyla kaydeder. Eşzamanlı
  /// ayrıntılı kayıtlar aynı gün kuyruğunda sıraya girer.
  Future<void> updateQuickLog(
    DateTime date, {
    required FlowIntensity? flow,
    required MoodType? mood,
    required List<SymptomEntry> symptoms,
    required String? notes,
  }) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      log.flowIntensity = flow;
      final previousMood = log.mood;
      log.mood = mood == null
          ? null
          : MoodEntry(
              type: mood,
              note: previousMood?.type == mood ? previousMood?.note : null,
            );
      log.symptoms = symptoms;
      log.notes = notes;
      if (mood == null && previousMood?.note?.trim().isNotEmpty == true) {
        log.notes = _appendNote(log.notes, previousMood!.note!);
      }
      await _saveOrDeleteDailyLog(log);
    });
  }

  Future<void> updateWater(DateTime date, int waterIntake) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      log.waterIntake = waterIntake;
      await _saveOrDeleteDailyLog(log);
    });
  }

  Future<void> updateTemperature(
    DateTime date,
    double? temperature, {
    String? temperatureTime,
  }) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      log.temperature = temperature;
      if (temperature == null || temperatureTime != null) log.temperatureTime = temperatureTime;
      await _saveOrDeleteDailyLog(log);
    });
  }

  Future<void> updateWeight(DateTime date, double? weight) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      log.weight = weight;
      await _saveOrDeleteDailyLog(log);
    });
  }

  Future<void> updateSleep(
    DateTime date, {
    String? sleepStart,
    String? sleepEnd,
    int? sleepQuality,
  }) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      if (sleepStart != null) log.sleepStart = sleepStart;
      if (sleepEnd != null) log.sleepEnd = sleepEnd;
      if (sleepQuality != null) log.sleepQuality = sleepQuality;
      await saveDailyLog(log);
    });
  }

  Future<void> clearSleep(DateTime date) {
    return _serial(date, () async {
      final existing = getDailyLog(date);
      if (existing == null) return;
      final log = DailyLog.fromJson(existing.toJson());
      log.sleepStart = null;
      log.sleepEnd = null;
      log.sleepQuality = null;
      await _saveOrDeleteDailyLog(log);
    });
  }

  /// Birleşik günlük ölçümler ekranını tek Hive yazımıyla kaydeder.
  ///
  /// Nullable alanlar bilerek doğrudan atanır: kullanıcı birleşik ekrandan
  /// bir ölçümü temizlediğinde eski değer geride kalmamalı.
  Future<void> updateMeasurements(
    DateTime date, {
    Set<String>? changedFields,
    required int waterIntake,
    required double? temperature,
    required String? temperatureTime,
    required double? weight,
    required String? sleepStart,
    required String? sleepEnd,
    required int? sleepQuality,
  }) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      bool changed(String field) => changedFields == null || changedFields.contains(field);
      if (changed('water')) log.waterIntake = waterIntake;
      if (changed('temperature')) {
        log.temperature = temperature;
        log.temperatureTime = temperature == null ? null : temperatureTime;
      }
      if (changed('weight')) log.weight = weight;
      if (changed('sleep')) {
        log.sleepStart = sleepStart;
        log.sleepEnd = sleepEnd;
        log.sleepQuality = sleepQuality;
      }
      await _saveOrDeleteDailyLog(log);
    });
  }

  Future<void> updateSexualActivity(DateTime date, SexualActivityEntry? entry) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      log.sexualActivity = entry;
      await _saveOrDeleteDailyLog(log);
    });
  }

  Future<void> updateMedications(
    DateTime date,
    List<MedicationEntry> medications,
  ) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      log.medications = medications;
      await _saveOrDeleteDailyLog(log);
    });
  }

  Future<void> updateOvulationTest(DateTime date, bool? positive) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      log.ovulationTestPositive = positive;
      await _saveOrDeleteDailyLog(log);
    });
  }

  Future<void> updateNotes(DateTime date, String? notes) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      log.notes = notes;
      await _saveOrDeleteDailyLog(log);
    });
  }

  /// Kısmi güncelleme: null verilen alanlar dokunulmadan kalır.
  Future<void> updateFlow(
    DateTime date, {
    FlowIntensity? flowIntensity,
    FlowColor? flowColor,
    bool? hasClots,
    int? padChangeCount,
  }) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      if (flowIntensity != null) log.flowIntensity = flowIntensity;
      if (flowColor != null) log.flowColor = flowColor;
      if (hasClots != null) log.hasClots = hasClots;
      if (padChangeCount != null) log.padChangeCount = padChangeCount;
      await saveDailyLog(log);
    });
  }

  /// Akış şiddetini doğrudan atar — null geçmek kaydı **siler**.
  /// [updateFlow] null'ı "dokunma" diye yorumladığı için, kullanıcının
  /// seçimi kaldırdığı akışlarda (hızlı kayıt) bu kullanılmalı.
  Future<void> setFlowIntensity(DateTime date, FlowIntensity? intensity) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      log.flowIntensity = intensity;
      await _saveOrDeleteDailyLog(log);
    });
  }

  /// Akış ekranının kaydı: dört alan da olduğu gibi yazılır, null olanlar
  /// temizlenir (kullanıcı seçimi kaldırmış demektir).
  Future<void> setFlowDetails(
    DateTime date, {
    required FlowIntensity? intensity,
    required FlowColor? color,
    required bool hasClots,
    required int padChangeCount,
  }) {
    return _serial(date, () async {
      final log = _getOrCreateLog(date);
      log.flowIntensity = intensity;
      log.flowColor = color;
      log.hasClots = hasClots ? true : null;
      log.padChangeCount = padChangeCount > 0 ? padChangeCount : null;
      await _saveOrDeleteDailyLog(log);
    });
  }

  Future<void> deleteDailyLog(String dateKey) async {
    await _hiveService.deleteDailyLog(dateKey);
    final newState = Map<String, DailyLog>.from(state);
    newState.remove(dateKey);
    state = newState;
  }

  void refresh() {
    _load();
  }
}

// ─── Computed Providers ───────────────────────────────────────────────

/// Tahminlerde kullanılan tek döngü uzunluğu kaynağı:
/// akıllı tahmin açık + yeterli kayıt varsa öğrenilen, yoksa elle girilen.
final effectiveCycleLengthProvider = Provider<int>((ref) {
  final profile = ref.watch(userProfileProvider);
  final records = ref.watch(periodRecordsProvider);
  if (profile == null) return 28;
  return CycleUtils.effectiveCycleLength(
    profile.averageCycleLength,
    records,
    smartEnabled: profile.smartPredictionEnabled,
  );
});

final currentCycleDayProvider = Provider<int>((ref) {
  final profile = ref.watch(userProfileProvider);
  if (profile == null || profile.lastPeriodStart == null) return 0;
  final rawDay = CycleUtils.currentCycleDay(profile.lastPeriodStart!);
  // A new cycle requires a recorded period, never elapsed time alone.
  return rawDay < 1 ? 1 : rawDay;
});

final currentCyclePhaseProvider = Provider<CyclePhase>((ref) {
  final profile = ref.watch(userProfileProvider);
  if (profile == null || profile.lastPeriodStart == null) {
    return CyclePhase.follicular;
  }
  // If there's an ongoing period, always show menstrual phase
  final ongoingPeriod = ref.watch(ongoingPeriodProvider);
  if (ongoingPeriod != null) {
    return CyclePhase.menstrual;
  }
  // If period ended, use actual end date to determine real period length
  final records = ref.watch(periodRecordsProvider);
  final lps = profile.lastPeriodStart!;
  final lastCompleted = records
      .where(
        (r) =>
            !r.isOngoing &&
            r.startDate.year == lps.year &&
            r.startDate.month == lps.month &&
            r.startDate.day == lps.day,
      )
      .toList();
  if (lastCompleted.isNotEmpty && lastCompleted.first.endDate != null) {
    // Period has ended - check if we're past the end date
    final endDate = lastCompleted.first.endDate!;
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    // Bitiş günü (ve öncesi) hâlâ regl günüdür: kayıt bugünü kapsıyorsa
    // faz menstrüeldir — ortalama süre daha kısa olsa bile. Eskiden
    // bitiş günü "regl bitti" sayılıyordu.
    if (!normalizedNow.isAfter(normalizedEnd)) return CyclePhase.menstrual;
    // Period is over, skip menstrual phase - use 0 as period length
    // so getCurrentPhase won't return menstrual
    return CycleUtils.getCurrentPhase(
      profile.lastPeriodStart!,
      ref.watch(effectiveCycleLengthProvider),
      0,
    );
  }
  return CycleUtils.getCurrentPhase(
    profile.lastPeriodStart!,
    ref.watch(effectiveCycleLengthProvider),
    profile.averagePeriodLength,
  );
});

final daysUntilNextPeriodProvider = Provider<int>((ref) {
  final profile = ref.watch(userProfileProvider);
  if (profile == null || profile.lastPeriodStart == null) return 0;
  return CycleUtils.daysUntilNextPeriod(
    profile.lastPeriodStart!,
    ref.watch(effectiveCycleLengthProvider),
  );
});

/// Tahmini tarihin kaç gün geçtiği; gecikme yoksa 0.
/// Devam eden bir regl varken gecikmeden söz edilemez.
final periodDelayProvider = Provider<int>((ref) {
  final profile = ref.watch(userProfileProvider);
  if (profile == null || profile.lastPeriodStart == null) return 0;
  if (ref.watch(ongoingPeriodProvider) != null) return 0;
  return CycleUtils.periodDelayDays(
    profile.lastPeriodStart!,
    ref.watch(effectiveCycleLengthProvider),
  );
});

/// Mevcut döngüde ölçümle teyit edilmiş ovülasyon günü.
/// Öncelik: BBT yükselişi (kesin teyit) > pozitif LH testi + 1 gün
/// (LH piki ovülasyondan 24-36 saat önce gelir). İkisi de yoksa null.
final cyclePredictionProvider = Provider<CyclePrediction?>((ref) {
  final profile = ref.watch(userProfileProvider);
  return CyclePrediction.calculate(start: profile?.lastPeriodStart,
    length: ref.watch(effectiveCycleLengthProvider),
    mode: profile?.trackingMode ?? TrackingMode.period,
    logs: ref.watch(dailyLogProvider).values);
});
final confirmedOvulationProvider = Provider<DateTime?>((ref) {
  final result = ref.watch(cyclePredictionProvider);
  return result?.source == PredictionSource.calendar ? null : result?.ovulation;
});

/// Faz-semptom içgörüleri (tek motor: topPhaseSymptoms). İstatistik
/// kartı, dashboard koç satırı ve faz-ipucu bildirimi buradan beslenir.
final phaseInsightsProvider = Provider<List<PhaseInsight>>((ref) {
  final profile = ref.watch(userProfileProvider);
  if (profile == null) return const [];
  final records = ref.watch(periodRecordsProvider);
  final logs = ref.watch(dailyLogProvider);
  return topPhaseSymptoms(
    logs: logs.values.toList(),
    periodStarts: records.map((r) => r.startDate).toList(),
    cycleLength: ref.watch(effectiveCycleLengthProvider),
    periodLength: profile.averagePeriodLength,
  );
});

final ongoingPeriodProvider = Provider<PeriodRecord?>((ref) {
  final records = ref.watch(periodRecordsProvider);
  try {
    return records.firstWhere((r) => r.isOngoing);
  } catch (_) {
    return null;
  }
});
