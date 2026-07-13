import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/user_profile.dart';
import '../models/period_record.dart';
import '../models/daily_log.dart';
import '../models/enums.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  late Box<UserProfile> _userProfileBox;
  late Box<PeriodRecord> _periodRecordsBox;
  late Box<DailyLog> _dailyLogsBox;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PeriodRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SymptomEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(MoodEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(SexualActivityEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(MedicationEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(DailyLogAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(FlowIntensityAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(FlowColorAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(SymptomTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(MoodTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(ProtectionMethodAdapter());
    }
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(SymptomCategoryAdapter());
    }

    // Open boxes
    _userProfileBox =
        await Hive.openBox<UserProfile>(AppConstants.userProfileBox);
    _periodRecordsBox =
        await Hive.openBox<PeriodRecord>(AppConstants.periodRecordsBox);
    _dailyLogsBox = await Hive.openBox<DailyLog>(AppConstants.dailyLogsBox);

    _isInitialized = true;
  }

  // ─── UserProfile CRUD ───────────────────────────────────────────────

  UserProfile? getUserProfile() {
    return _userProfileBox.get(AppConstants.currentUserKey);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _userProfileBox.put(AppConstants.currentUserKey, profile);
  }

  bool isOnboardingCompleted() {
    final profile = getUserProfile();
    return profile?.onboardingCompleted ?? false;
  }

  // ─── PeriodRecord CRUD ──────────────────────────────────────────────

  List<PeriodRecord> getAllPeriodRecords() {
    final records = _periodRecordsBox.values.toList();
    records.sort((a, b) => b.startDate.compareTo(a.startDate));
    return records;
  }

  PeriodRecord? getOngoingPeriod() {
    try {
      return _periodRecordsBox.values.firstWhere(
        (record) => record.isOngoing,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> savePeriodRecord(PeriodRecord record) async {
    await _periodRecordsBox.put(record.id, record);
  }

  Future<void> deletePeriodRecord(String id) async {
    await _periodRecordsBox.delete(id);
  }

  // ─── DailyLog CRUD ─────────────────────────────────────────────────

  DailyLog? getDailyLogByDate(DateTime date) {
    // Box key'i zaten dateKey — O(1) erişim
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _dailyLogsBox.get(dateKey);
  }

  List<DailyLog> getAllDailyLogs() {
    return _dailyLogsBox.values.toList();
  }

  List<DailyLog> getDailyLogsInRange(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);

    return _dailyLogsBox.values.where((log) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      return !logDate.isBefore(normalizedStart) &&
          !logDate.isAfter(normalizedEnd);
    }).toList();
  }

  Future<void> saveDailyLog(DailyLog log) async {
    await _dailyLogsBox.put(log.dateKey, log);
  }

  Future<void> deleteDailyLog(String dateKey) async {
    await _dailyLogsBox.delete(dateKey);
  }

  // ─── Clear all data ─────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _userProfileBox.clear();
    await _periodRecordsBox.clear();
    await _dailyLogsBox.clear();
  }
}
