import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';
import '../models/user_profile.dart';
import '../models/period_record.dart';
import '../models/daily_log.dart';
import '../models/enums.dart';
import '../core/utils/cycle_utils.dart';
import 'package:uuid/uuid.dart';

// ─── Service Providers ────────────────────────────────────────────────

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

// ─── Simple State Providers ───────────────────────────────────────────

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('tr');
});

final darkModeProvider = StateProvider<bool>((ref) {
  return false;
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
    await _hiveService.saveUserProfile(profile);
    state = profile;

    // Onboarding bu yoldan geliyor: bildirimler ve widget ilk kayıtta da
    // kurulmalı, yoksa uygulama yeniden başlatılana dek hatırlatma yok
    try {
      await NotificationService().rescheduleAll(
        profile,
        records: _hiveService.getAllPeriodRecords(),
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
      darkModeEnabled: darkModeEnabled,
      waterGoal: waterGoal,
      smartPredictionEnabled: smartPredictionEnabled,
      trackingMode: trackingMode,
      pregnancyStartDate: pregnancyStartDate,
      pillPackStartDate: pillPackStartDate,
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
  }

  Future<void> updateNotes(DateTime date, String? notes) async {
    final log = _getOrCreateLog(date);
    log.notes = notes;
    await saveDailyLog(log);
  }

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

final ongoingPeriodProvider = Provider<PeriodRecord?>((ref) {
  final records = ref.watch(periodRecordsProvider);
  try {
    return records.firstWhere((r) => r.isOngoing);
  } catch (_) {
    return null;
  }
});
