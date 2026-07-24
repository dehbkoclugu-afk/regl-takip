import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import '../services/premium_service.dart';
import '../services/widget_service.dart';
import '../models/user_profile.dart';
import '../models/period_record.dart';
import '../models/daily_log.dart';
import '../models/enums.dart';
import '../core/utils/cycle_utils.dart';
import '../core/utils/phase_insights.dart';
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

/// "Farklı bir gün için uzun bas" ipucu hâlâ gösterilmeli mi?
/// Kullanıcı hareketi bir kez kullanınca kalıcı olarak kapanır — keşfi
/// olmayan bir hareket, olmayan bir özelliktir.
/// Kalıcılığı SharedPreferences 'backdate_hint_needed'.
final backdateHintProvider = StateProvider<bool>((ref) => true);

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

/// Bildirimler için "güncel ilaç listesi": en son ilaç girilen günün kaydı.
/// İlaçlar güne yazılıyor ama hatırlatma tekrar eden bir kurulum — en yeni
/// liste esas alınır.
List<MedicationEntry> _latestMedications(HiveService hive) {
  final logs = hive.getAllDailyLogs()
      .where((l) => l.medications.isNotEmpty)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  return logs.isEmpty ? const [] : logs.first.medications;
}

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
    await _hiveService.saveUserProfile(profile);
    state = profile;

    // Onboarding bu yoldan geliyor: bildirimler ve widget ilk kayıtta da
    // kurulmalı, yoksa uygulama yeniden başlatılana dek hatırlatma yok
    try {
      await NotificationService().rescheduleAll(
        profile,
        records: _hiveService.getAllPeriodRecords(),
        medications: _latestMedications(_hiveService),
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
  }) async {
    final current = state ?? UserProfile();
    final updated = current.copyWith(
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
      darkModeEnabled: darkModeEnabled ??
          (themePreference == null ? null : themePreference == 'dark'),
      waterGoal: waterGoal,
      smartPredictionEnabled: smartPredictionEnabled,
      trackingMode: trackingMode,
      pregnancyStartDate: pregnancyStartDate,
      pillPackStartDate: pillPackStartDate,
      themePreference: themePreference,
    );

    await _hiveService.saveUserProfile(updated);
    state = updated;

    // Reschedule notifications when relevant settings change
    if (periodReminderEnabled != null ||
        ovulationReminderEnabled != null ||
        medicationReminderEnabled != null ||
        reminderHour != null ||
        reminderMinute != null ||
        lastPeriodStart != null ||
        smartPredictionEnabled != null ||
        trackingMode != null ||
        // Döngü/regl süresi tahmin tarihlerini kaydırır — bildirimler
        // yeniden planlanmazsa eski tarihlerde kalır
        averageCycleLength != null ||
        averagePeriodLength != null) {
      try {
        await NotificationService().rescheduleAll(
          updated,
          records: _hiveService.getAllPeriodRecords(),
          medications: _latestMedications(_hiveService),
        );
      } catch (e) {
        debugPrint('[NOTIF] rescheduleAll failed: $e');
      }
    }

    await WidgetService.update(
        updated, _hiveService.getAllPeriodRecords());
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

  Future<void> addRecord(PeriodRecord record) async {
    await _hiveService.savePeriodRecord(record);
    _load();
  }

  Future<void> updateRecord(PeriodRecord record) async {
    await _hiveService.savePeriodRecord(record);
    _load();
  }

  Future<void> deleteRecord(String id) async {
    await _hiveService.deletePeriodRecord(id);
    _load();
  }

  Future<PeriodRecord> startPeriod(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // End any ongoing period first
    final ongoing = state.where((r) => r.isOngoing).toList();
    for (final record in ongoing) {
      final start = DateTime(record.startDate.year, record.startDate.month,
          record.startDate.day);
      // Aynı gün (veya öncesi) tekrar başlatılırsa mevcut kayıt aktif kalır;
      // yoksa endDate < startDate olur ve süre hesapları bozulur.
      if (!normalizedDate.isAfter(start)) {
        return record;
      }
      record.endDate = date.subtract(const Duration(days: 1));
      await _hiveService.savePeriodRecord(record);
    }

    final record = PeriodRecord(
      id: _uuid.v4(),
      startDate: date,
    );
    await _hiveService.savePeriodRecord(record);
    _load();
    // Widget güncellemesi burada değil: çağıran akış hemen ardından
    // saveProfile(lastPeriodStart) çağırır, widget orada güncel veriyle kurulur
    return record;
  }

  /// Kayıt düzenleyici: başlangıç/bitiş tarihlerini doğrudan atar.
  /// Tarihler güne indirgenir; bitiş başlangıçtan önce olamaz.
  /// [end] null = kayıt devam ediyor.
  Future<void> updateRecordDates(
      String recordId, DateTime start, DateTime? end) async {
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
    record.startDate = normalizedStart;
    record.endDate = normalizedEnd;
    await _hiveService.savePeriodRecord(record);
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
        normalizedNew, periodLength, DateTime.now());

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
      target.startDate = normalizedNew;
      target.endDate = end;
      await _hiveService.savePeriodRecord(target);
      _load();
    } else {
      await addRecord(PeriodRecord(
        id: _uuid.v4(),
        startDate: normalizedNew,
        endDate: end,
      ));
    }
  }

  Future<void> endPeriod(String recordId, DateTime date) async {
    try {
      final record = state.firstWhere((r) => r.id == recordId);
      // Bitiş tarihi başlangıçtan önce olamaz
      record.endDate =
          date.isBefore(record.startDate) ? record.startDate : date;
      await _hiveService.savePeriodRecord(record);
      _load();
      await WidgetService.update(
          _hiveService.getUserProfile(), state);
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

  DailyLog _getOrCreateLog(DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return state[dateKey] ??
        DailyLog(
          id: _uuid.v4(),
          date: date,
        );
  }

  Future<void> updateSymptoms(
      DateTime date, List<SymptomEntry> symptoms) async {
    final log = _getOrCreateLog(date);
    log.symptoms = symptoms;
    await saveDailyLog(log);
  }

  Future<void> updateMood(DateTime date, MoodEntry? mood) async {
    final log = _getOrCreateLog(date);
    log.mood = mood;
    await saveDailyLog(log);
  }

  Future<void> updateWater(DateTime date, int waterIntake) async {
    final log = _getOrCreateLog(date);
    log.waterIntake = waterIntake;
    await saveDailyLog(log);
  }

  Future<void> updateTemperature(DateTime date, double? temperature, {String? temperatureTime}) async {
    final log = _getOrCreateLog(date);
    log.temperature = temperature;
    if (temperatureTime != null) log.temperatureTime = temperatureTime;
    await saveDailyLog(log);
  }

  Future<void> updateWeight(DateTime date, double? weight) async {
    final log = _getOrCreateLog(date);
    log.weight = weight;
    await saveDailyLog(log);
  }

  Future<void> updateSleep(
    DateTime date, {
    String? sleepStart,
    String? sleepEnd,
    int? sleepQuality,
  }) async {
    final log = _getOrCreateLog(date);
    if (sleepStart != null) log.sleepStart = sleepStart;
    if (sleepEnd != null) log.sleepEnd = sleepEnd;
    if (sleepQuality != null) log.sleepQuality = sleepQuality;
    await saveDailyLog(log);
  }

  Future<void> updateSexualActivity(
      DateTime date, SexualActivityEntry? entry) async {
    final log = _getOrCreateLog(date);
    log.sexualActivity = entry;
    await saveDailyLog(log);
  }

  Future<void> updateMedications(
      DateTime date, List<MedicationEntry> medications) async {
    final log = _getOrCreateLog(date);
    log.medications = medications;
    await saveDailyLog(log);

    // İlaç saatleri hatırlatmaları belirliyor: liste değişince yeniden kur
    final profile = _hiveService.getUserProfile();
    if (profile != null && profile.medicationReminderEnabled) {
      try {
        await NotificationService().rescheduleAll(
          profile,
          records: _hiveService.getAllPeriodRecords(),
          medications: _latestMedications(_hiveService),
        );
      } catch (e) {
        debugPrint('[NOTIF] medication reschedule failed: $e');
      }
    }
  }

  Future<void> updateOvulationTest(DateTime date, bool? positive) async {
    final log = _getOrCreateLog(date);
    log.ovulationTestPositive = positive;
    await saveDailyLog(log);
  }

  Future<void> updateNotes(DateTime date, String? notes) async {
    final log = _getOrCreateLog(date);
    log.notes = notes;
    await saveDailyLog(log);
  }

  /// Kısmi güncelleme: null verilen alanlar dokunulmadan kalır.
  Future<void> updateFlow(
    DateTime date, {
    FlowIntensity? flowIntensity,
    FlowColor? flowColor,
    bool? hasClots,
    int? padChangeCount,
  }) async {
    final log = _getOrCreateLog(date);
    if (flowIntensity != null) log.flowIntensity = flowIntensity;
    if (flowColor != null) log.flowColor = flowColor;
    if (hasClots != null) log.hasClots = hasClots;
    if (padChangeCount != null) log.padChangeCount = padChangeCount;
    await saveDailyLog(log);
  }

  /// Akış şiddetini doğrudan atar — null geçmek kaydı **siler**.
  /// [updateFlow] null'ı "dokunma" diye yorumladığı için, kullanıcının
  /// seçimi kaldırdığı akışlarda (hızlı kayıt) bu kullanılmalı.
  Future<void> setFlowIntensity(DateTime date, FlowIntensity? intensity) async {
    final log = _getOrCreateLog(date);
    log.flowIntensity = intensity;
    await saveDailyLog(log);
  }

  /// Akış ekranının kaydı: dört alan da olduğu gibi yazılır, null olanlar
  /// temizlenir (kullanıcı seçimi kaldırmış demektir).
  Future<void> setFlowDetails(
    DateTime date, {
    required FlowIntensity? intensity,
    required FlowColor? color,
    required bool hasClots,
    required int padChangeCount,
  }) async {
    final log = _getOrCreateLog(date);
    log.flowIntensity = intensity;
    log.flowColor = color;
    log.hasClots = hasClots;
    log.padChangeCount = padChangeCount;
    await saveDailyLog(log);
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
  final cycleLength = ref.watch(effectiveCycleLengthProvider);
  // Döngü uzunluğunu aşarsa yeni döngü başlamış demektir
  return CycleUtils.wrappedCycleDay(rawDay, cycleLength);
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
      .where((r) => !r.isOngoing &&
          r.startDate.year == lps.year &&
          r.startDate.month == lps.month &&
          r.startDate.day == lps.day)
      .toList();
  if (lastCompleted.isNotEmpty && lastCompleted.first.endDate != null) {
    // Period has ended - check if we're past the end date
    final endDate = lastCompleted.first.endDate!;
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    if (normalizedNow.compareTo(normalizedEnd) >= 0) {
      // Period is over, skip menstrual phase - use 0 as period length
      // so getCurrentPhase won't return menstrual
      return CycleUtils.getCurrentPhase(
        profile.lastPeriodStart!,
        ref.watch(effectiveCycleLengthProvider),
        0,
      );
    }
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
final confirmedOvulationProvider = Provider<DateTime?>((ref) {
  final profile = ref.watch(userProfileProvider);
  final lastStart = profile?.lastPeriodStart;
  if (lastStart == null) return null;

  final logs = ref.watch(dailyLogProvider);
  final cycleStart =
      DateTime(lastStart.year, lastStart.month, lastStart.day);

  final temps = <MapEntry<DateTime, double>>[];
  DateTime? latestPositiveLh;
  for (final log in logs.values) {
    final day = DateTime(log.date.year, log.date.month, log.date.day);
    if (day.isBefore(cycleStart)) continue;
    if (log.temperature != null) {
      temps.add(MapEntry(day, log.temperature!));
    }
    if (log.ovulationTestPositive == true &&
        (latestPositiveLh == null || day.isAfter(latestPositiveLh))) {
      latestPositiveLh = day;
    }
  }

  final fromBbt = CycleUtils.detectOvulationFromBBT(temps);
  if (fromBbt != null) return fromBbt;
  if (latestPositiveLh != null) {
    return latestPositiveLh.add(const Duration(days: 1));
  }
  return null;
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
