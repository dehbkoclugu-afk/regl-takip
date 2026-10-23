import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../models/user_profile.dart';
import '../models/period_record.dart';
import '../models/daily_log.dart';
import '../models/enums.dart';
import '../core/utils/medication_plan.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const _aesKeyStorageKey = 'hive_aes_key';
  static const _encryptedFlagKey = 'hive_encrypted';

  late Box<UserProfile> _userProfileBox;
  late Box<PeriodRecord> _periodRecordsBox;
  late Box<DailyLog> _dailyLogsBox;

  Box<String>? _catalog;
  HiveAesCipher? _cipher;
  String _generation = '';
  Future<void> _replacement = Future.value();
  @visibleForTesting
  Future<void> Function(String stage)? transactionCheckpoint;

  String _name(String base) =>
      _generation.isEmpty ? base : '${base}_$_generation';
  bool _isInitialized = false;
  bool _dataResetPerformed = false;

  bool get isInitialized => _isInitialized;
  String? readMetadata(String key) => _catalog?.get(key);
  Future<void> writeMetadata(String key, String value) async {
    if (_catalog == null) throw StateError('Storage not initialized');
    await _catalog!.put(key, value);
    await _catalog!.flush();
  }

  @visibleForTesting
  String? get profileStoragePath => _userProfileBox.path;

  /// Açılışta kutular çözülemeyip karantinaya alındıysa ve sıfırdan
  /// başlandıysa true — UI tek seferlik açıklama göstermek için okur.
  bool get dataResetPerformed => _dataResetPerformed;

  /// [encryptionKey] testlerde enjekte edilir; prod'da secure storage'dan
  /// okunur/üretilir. [manageHivePath] false ise Hive.init çağıranın
  /// sorumluluğundadır (testler temp dizinle kendileri init eder).
  /// [assumeEncrypted] yalnız test yolunda: prod'daki secure-storage
  /// bayrağının yerini tutar.
  Future<void> init({
    List<int>? encryptionKey,
    bool manageHivePath = true,
    bool? assumeEncrypted,
  }) async {
    if (_isInitialized) return;

    if (manageHivePath) {
      await Hive.initFlutter();
    }

    _registerAdapters();

    final storage = const FlutterSecureStorage();
    final List<int> key;
    final bool alreadyEncrypted;

    if (encryptionKey != null) {
      key = encryptionKey;
      alreadyEncrypted = assumeEncrypted ?? false;
    } else {
      final storedKey = await storage.read(key: _aesKeyStorageKey);
      if (storedKey != null) {
        key = base64Decode(storedKey);
      } else {
        key = Hive.generateSecureKey();
        await storage.write(key: _aesKeyStorageKey, value: base64Encode(key));
      }
      alreadyEncrypted = await storage.read(key: _encryptedFlagKey) == 'true';
    }

    final cipher = HiveAesCipher(key);
    _cipher = cipher;
    // A single flushed catalog record commits a complete generation. Original
    // boxes remain untouched until all replacement boxes are durable.
    _catalog = await Hive.openBox<String>('storage_catalog',
        encryptionCipher: cipher, crashRecovery: false);
    _generation = _catalog!.get('active') ?? '';
    if (_generation.isNotEmpty ||
        alreadyEncrypted ||
        !await _plainBoxesExistOnDisk()) {
      await _openEncryptedBoxes(cipher);
    } else {
      var openedPlain = false;
      try {
        await _openPlainBoxes();
        openedPlain = true;
      } catch (_) {
        await _closeDataBoxes();
        // A lost legacy flag must not cause destructive recovery.
        await _openEncryptedBoxes(cipher);
      }
      if (openedPlain) {
        await replaceAll(
          profile: getUserProfile(),
          records: getAllPeriodRecords(),
          logs: getAllDailyLogs(),
        );
      }
    }
    if (encryptionKey == null) {
      await storage.write(key: _encryptedFlagKey, value: 'true');
    }
    if (manageHivePath) await deleteLegacyPlaintextSnapshot();

    await ensureMedicationPlanMigrated();
    _isInitialized = true;
  }

  /// Şifreleme migrasyonundan kalan düz metin `pre_encryption_backup.json`
  /// dosyasını siler (varsa). Başarılı şifreli açılışta ve "tüm verileri
  /// sil"de çağrılır.
  Future<void> deleteLegacyPlaintextSnapshot() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/pre_encryption_backup.json');
      if (await file.exists()) {
        await file.delete();
        debugPrint('[HIVE] legacy plaintext snapshot deleted');
      }
    } catch (e) {
      debugPrint('[HIVE] snapshot cleanup failed: $e');
    }
  }

  // crashRecovery: false — Hive'ın varsayılan "kurtarması", çözülemeyen
  // frame'lerde kutuyu sessizce BOŞALTIP açar (yanlış anahtarda tüm veri
  // iz bırakmadan gider). Kapalıyken hata fırlar; init'teki catch dosyayı
  // budanmadan karantinaya alır ve kullanıcıya haber verir.
  Future<void> _openPlainBoxes() async {
    _userProfileBox = await Hive.openBox<UserProfile>(
        AppConstants.userProfileBox,
        crashRecovery: false);
    _periodRecordsBox = await Hive.openBox<PeriodRecord>(
        AppConstants.periodRecordsBox,
        crashRecovery: false);
    _dailyLogsBox = await Hive.openBox<DailyLog>(AppConstants.dailyLogsBox,
        crashRecovery: false);
  }

  void _registerAdapters() {
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
    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter(TrackingModeAdapter());
    }
  }

  Future<bool> _plainBoxesExistOnDisk() async {
    // Şifreli açılış bayrağı yoksa ve diskte kutu varsa eski kurulumdur.
    // Kutu hiç yoksa temiz kurulum: doğrudan şifreli açılır.
    return await Hive.boxExists(AppConstants.userProfileBox) ||
        await Hive.boxExists(AppConstants.periodRecordsBox) ||
        await Hive.boxExists(AppConstants.dailyLogsBox);
  }

  Future<void> _openEncryptedBoxes(HiveAesCipher cipher,
      {bool crashRecovery = false}) async {
    _userProfileBox = await Hive.openBox<UserProfile>(
        _name(AppConstants.userProfileBox),
        encryptionCipher: cipher,
        crashRecovery: crashRecovery);
    _periodRecordsBox = await Hive.openBox<PeriodRecord>(
        _name(AppConstants.periodRecordsBox),
        encryptionCipher: cipher,
        crashRecovery: crashRecovery);
    _dailyLogsBox = await Hive.openBox<DailyLog>(
        _name(AppConstants.dailyLogsBox),
        encryptionCipher: cipher,
        crashRecovery: crashRecovery);
  }

  Future<void> _closeDataBoxes() async {
    for (final base in [
      AppConstants.userProfileBox,
      AppConstants.periodRecordsBox,
      AppConstants.dailyLogsBox
    ]) {
      if (Hive.isBoxOpen(_name(base))) await Hive.box(_name(base)).close();
    }
  }

  /// Atomic generation replacement for migration and backup restore. Failed
  /// staging never changes the catalog; process death reopens the old or fully
  /// committed generation, never a partly restored mixture.
  Future<void> replaceAll(
      {required UserProfile? profile,
      required List<PeriodRecord> records,
      required List<DailyLog> logs}) {
    return _write(() => _replaceAll(profile, records, logs));
  }

  Future<void> _write(Future<void> Function() action) {
    final operation = _replacement.then((_) => action());
    _replacement = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> _replaceAll(UserProfile? profile, List<PeriodRecord> records,
      List<DailyLog> logs) async {
    final generation = const Uuid().v4().replaceAll('-', '');
    final bases = [
      AppConstants.userProfileBox,
      AppConstants.periodRecordsBox,
      AppConstants.dailyLogsBox
    ];
    String staged(String base) => '${base}_$generation';
    Box<UserProfile>? profiles;
    Box<PeriodRecord>? periods;
    Box<DailyLog>? daily;
    var committed = false;
    try {
      profiles = await Hive.openBox<UserProfile>(staged(bases[0]),
          encryptionCipher: _cipher!, crashRecovery: false);
      periods = await Hive.openBox<PeriodRecord>(staged(bases[1]),
          encryptionCipher: _cipher!, crashRecovery: false);
      daily = await Hive.openBox<DailyLog>(staged(bases[2]),
          encryptionCipher: _cipher!, crashRecovery: false);
      if (profile != null) {
        await profiles.put(AppConstants.currentUserKey,
            UserProfile.fromJson(profile.toJson()));
      }
      await transactionCheckpoint?.call('profile');
      for (final record in records) {
        await periods.put(record.id, PeriodRecord.fromJson(record.toJson()));
      }
      await transactionCheckpoint?.call('periods');
      for (final log in logs) {
        await daily.put(log.dateKey, DailyLog.fromJson(log.toJson()));
      }
      await Future.wait([profiles.flush(), periods.flush(), daily.flush()]);
      if (periods.length != records.length || daily.length != logs.length) {
        throw StateError('Duplicate keys in replacement data');
      }
      await transactionCheckpoint?.call('beforeCommit');
      final oldNames = bases.map(_name).toList();
      final oldBoxes = [_userProfileBox, _periodRecordsBox, _dailyLogsBox];
      await _catalog!.put('active', generation);
      await _catalog!.flush();
      committed = true;
      _generation = generation;
      _userProfileBox = profiles;
      _periodRecordsBox = periods;
      _dailyLogsBox = daily;
      // Cleanup is post-commit only. Never roll back a published generation.
      for (var i = 0; i < oldBoxes.length; i++) {
        try {
          await oldBoxes[i].close();
          await Hive.deleteBoxFromDisk(oldNames[i]);
        } catch (e) {
          debugPrint('[HIVE] old generation cleanup deferred: $e');
        }
      }
    } finally {
      if (!committed) {
        await profiles?.close();
        await periods?.close();
        await daily?.close();
        // Preserve staged ciphertext if commit durability is uncertain.
      }
    }
  }

  /// Testler için: singleton durumunu sıfırlar (kutular kapatılmaz).
  @visibleForTesting
  void resetForTesting() {
    _isInitialized = false;
    _dataResetPerformed = false;
    _catalog = null;
    _cipher = null;
    _generation = '';
    _replacement = Future.value();
    transactionCheckpoint = null;
  }

  // ─── UserProfile CRUD ───────────────────────────────────────────────

  UserProfile? getUserProfile() {
    return _userProfileBox.get(AppConstants.currentUserKey);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _write(
        () => _userProfileBox.put(AppConstants.currentUserKey, profile));
  }

  /// Eski sürümde ilaç tanımları günlük kayıttaydı. En yeni listeyi profile
  /// yalnız bir kez taşır; işaret boş planı da kapsar ki kullanıcı planı
  /// sildikten sonra tarihsel kayıtlar yeniden canlanmasın.
  Future<void> ensureMedicationPlanMigrated() async {
    final profile = getUserProfile();
    if (profile == null || profile.medicationPlanMigrated) return;
    final updated = profile.copyWith(
      medicationPlan: medicationPlanFromLogs(getAllDailyLogs()),
      medicationPlanMigrated: true,
    );
    await saveUserProfile(updated);
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
    await _write(() => _periodRecordsBox.put(record.id, record));
  }

  Future<void> deletePeriodRecord(String id) async {
    await _write(() => _periodRecordsBox.delete(id));
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
    await _write(() => _dailyLogsBox.put(log.dateKey, log));
  }

  Future<void> deleteDailyLog(String dateKey) async {
    await _write(() => _dailyLogsBox.delete(dateKey));
  }

  // ─── Clear all data ─────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _write(() async {
      await _userProfileBox.clear();
      await _periodRecordsBox.clear();
      await _dailyLogsBox.clear();
    });
  }
}
