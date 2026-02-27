import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../services/cycle_service.dart';
import '../services/notification_service.dart';
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

final cycleServiceProvider = Provider<CycleService>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return CycleService(hiveService);
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
    } catch (_) {
      state = null;
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _hiveService.saveUserProfile(profile);
    state = profile;
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
  }) async {
    final current = state ?? UserProfile();
    if (name != null) current.name = name;
    if (birthDate != null) current.birthDate = birthDate;
    if (averageCycleLength != null) {
      current.averageCycleLength = averageCycleLength;
    }
    if (averagePeriodLength != null) {
      current.averagePeriodLength = averagePeriodLength;
    }
    if (pinEnabled != null) current.pinEnabled = pinEnabled;
    if (biometricEnabled != null) current.biometricEnabled = biometricEnabled;
    if (onboardingCompleted != null) {
      current.onboardingCompleted = onboardingCompleted;
    }
    if (language != null) current.language = language;
    if (lastPeriodStart != null) current.lastPeriodStart = lastPeriodStart;
    if (periodReminderEnabled != null) {
      current.periodReminderEnabled = periodReminderEnabled;
    }
    if (ovulationReminderEnabled != null) {
      current.ovulationReminderEnabled = ovulationReminderEnabled;
    }
    if (medicationReminderEnabled != null) {
      current.medicationReminderEnabled = medicationReminderEnabled;
    }
    if (reminderHour != null) current.reminderHour = reminderHour;
    if (reminderMinute != null) current.reminderMinute = reminderMinute;
    if (darkModeEnabled != null) current.darkModeEnabled = darkModeEnabled;
    if (waterGoal != null) current.waterGoal = waterGoal;

    await _hiveService.saveUserProfile(current);
    // Force Riverpod to detect change by emitting a different reference
    // Using a dummy profile briefly (not null, to avoid null-related issues in watchers)
    final dummy = UserProfile();
    state = dummy;
    state = current;

    // Reschedule notifications when relevant settings change
    if (periodReminderEnabled != null ||
        ovulationReminderEnabled != null ||
        medicationReminderEnabled != null ||
        reminderHour != null ||
        reminderMinute != null ||
        lastPeriodStart != null) {
      try {
        await NotificationService().rescheduleAll(current);
      } catch (_) {
        // Notification scheduling failed - ignore
      }
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
    } catch (_) {
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
    // End any ongoing period first
    final ongoing = state.where((r) => r.isOngoing).toList();
    for (final record in ongoing) {
      record.endDate = date.subtract(const Duration(days: 1));
      await _hiveService.savePeriodRecord(record);
    }

    final record = PeriodRecord(
      id: _uuid.v4(),
      startDate: date,
    );
    await _hiveService.savePeriodRecord(record);
    _load();
    return record;
  }

  Future<void> endPeriod(String recordId, DateTime date) async {
    try {
      final record = state.firstWhere((r) => r.id == recordId);
      record.endDate = date;
      await _hiveService.savePeriodRecord(record);
      _load();
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

final currentCycleDayProvider = Provider<int>((ref) {
  final profile = ref.watch(userProfileProvider);
  if (profile == null || profile.lastPeriodStart == null) return 0;
  final rawDay = CycleUtils.currentCycleDay(profile.lastPeriodStart!);
  final cycleLength = profile.averageCycleLength;
  // Döngü uzunluğunu aşarsa yeni döngü başlamış demektir, modulo ile sıfırla
  if (rawDay > cycleLength) {
    final mod = rawDay % cycleLength;
    return mod == 0 ? cycleLength : mod;
  }
  return rawDay;
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
        profile.averageCycleLength,
        0,
      );
    }
  }
  return CycleUtils.getCurrentPhase(
    profile.lastPeriodStart!,
    profile.averageCycleLength,
    profile.averagePeriodLength,
  );
});

final daysUntilNextPeriodProvider = Provider<int>((ref) {
  final profile = ref.watch(userProfileProvider);
  if (profile == null || profile.lastPeriodStart == null) return 0;
  return CycleUtils.daysUntilNextPeriod(
    profile.lastPeriodStart!,
    profile.averageCycleLength,
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
