import 'dart:convert';
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

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const _aesKeyStorageKey = 'hive_aes_key';
  static const _encryptedFlagKey = 'hive_encrypted';

  late Box<UserProfile> _userProfileBox;
  late Box<PeriodRecord> _periodRecordsBox;
  late Box<DailyLog> _dailyLogsBox;

  bool _isInitialized = false;
  bool _dataResetPerformed = false;

  bool get isInitialized => _isInitialized;

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
    var encryptionSucceeded = true;

    try {
      if (!alreadyEncrypted && await _plainBoxesExistOnDisk()) {
        // Eski kurulum: şifresiz kutular var — verileri şifreli kutulara taşı.
        // Migrasyon patlarsa uygulama açılmaz olur; düz kutulara düşüp
        // veriyi erişilebilir tutmak şifrelemeden daha öncelikli.
        try {
          await _migrateToEncrypted(cipher);
        } catch (e) {
          debugPrint('[HIVE] encryption migration failed, '
              'falling back to plain boxes: $e');
          encryptionSucceeded = false;
          await _openPlainBoxes();
        }
      } else {
        await _openEncryptedBoxes(cipher);
      }
    } catch (e) {
      // Kutular hiçbir yolla açılamıyor. En yaygın senaryo cihaz/yedek
      // geçişi: Hive dosyaları geri gelir ama AES anahtarı Keystore'a
      // bağlıdır ve yeni cihaza taşınmaz — eldeki şifreli dosya artık
      // hiçbir anahtarla çözülemez. Çökme döngüsü yerine kutular
      // karantinaya alınır, temiz başlanır ve UI'a tek seferlik bir
      // açıklama bayrağı bırakılır.
      debugPrint('[HIVE] boxes unreadable, quarantining and '
          'starting fresh: $e');
      _dataResetPerformed = true;
      await Hive.close();
      await _quarantineBoxes();
      try {
        await _openEncryptedBoxes(cipher);
      } catch (e2) {
        // Karantina dosyayı taşıyamadıysa (ör. açık dosya tanıtıcısı) son
        // çare Hive'ın yerinde budayarak açması: dosya zaten çözülemiyordu,
        // önemli olan uygulamanın açılması ve kullanıcının bilgilenmesi.
        debugPrint('[HIVE] fresh open failed, forcing crash recovery: $e2');
        await _openEncryptedBoxes(cipher, crashRecovery: true);
      }
      encryptionSucceeded = true;
    }

    // Bayrak yalnız şifreli açılış gerçekten başarılıysa yazılır;
    // yoksa sonraki açılışta migrasyon yeniden denenir
    if (encryptionKey == null && encryptionSucceeded) {
      await storage.write(key: _encryptedFlagKey, value: 'true');
    }

    _isInitialized = true;
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

  /// Açılamayan kutu dosyalarını silmek yerine yeniden adlandırır:
  /// içerik anahtarsız çözülemez ama en azından yok edilmemiş olur.
  /// Yol bilinmiyorsa (test ortamı) Hive'ın kendi silme yoluna düşer.
  Future<void> _quarantineBoxes() async {
    const names = [
      AppConstants.userProfileBox,
      AppConstants.periodRecordsBox,
      AppConstants.dailyLogsBox,
    ];
    final stamp = DateTime.now().millisecondsSinceEpoch;
    for (final name in names) {
      var renamed = false;
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$name.hive');
        if (await file.exists()) {
          await file.rename('${file.path}.corrupt-$stamp');
          renamed = true;
        }
        final lock = File('${dir.path}/$name.lock');
        if (await lock.exists()) await lock.delete();
      } catch (e) {
        debugPrint('[HIVE] quarantine failed for $name: $e');
      }
      if (!renamed) {
        try {
          await Hive.deleteBoxFromDisk(name);
        } catch (e) {
          debugPrint('[HIVE] deleteBoxFromDisk failed for $name: $e');
        }
      }
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
        AppConstants.userProfileBox,
        encryptionCipher: cipher,
        crashRecovery: crashRecovery);
    _periodRecordsBox = await Hive.openBox<PeriodRecord>(
        AppConstants.periodRecordsBox,
        encryptionCipher: cipher,
        crashRecovery: crashRecovery);
    _dailyLogsBox = await Hive.openBox<DailyLog>(AppConstants.dailyLogsBox,
        encryptionCipher: cipher,
        crashRecovery: crashRecovery);
  }

  /// Şifresiz kutulardaki veriyi JSON üzerinden şifreli kutulara taşır.
  /// JSON ara katmanı HiveObject'lerin eski kutuya bağlılığı sorununu
  /// ortadan kaldırır (aynı nesne iki kutuya konamaz).
  Future<void> _migrateToEncrypted(HiveAesCipher cipher) async {
    // crashRecovery: false — bkz. _openPlainBoxes. Yedekten dönen şifreli
    // dosyayı düz sanıp "kurtarmak" veriyi sessizce boşaltır.
    final plainProfileBox = await Hive.openBox<UserProfile>(
        AppConstants.userProfileBox,
        crashRecovery: false);
    final plainRecordsBox = await Hive.openBox<PeriodRecord>(
        AppConstants.periodRecordsBox,
        crashRecovery: false);
    final plainLogsBox = await Hive.openBox<DailyLog>(
        AppConstants.dailyLogsBox,
        crashRecovery: false);

    final profileJson =
        plainProfileBox.get(AppConstants.currentUserKey)?.toJson();
    final recordsJson =
        plainRecordsBox.values.map((r) => r.toJson()).toList();
    final logsJson = plainLogsBox.values.map((l) => l.toJson()).toList();

    // Güvenlik anlık görüntüsü: migrasyon yarıda kalırsa veri kurtarılabilir
    await _writeSafetySnapshot(profileJson, recordsJson, logsJson);

    await plainProfileBox.close();
    await plainRecordsBox.close();
    await plainLogsBox.close();
    await Hive.deleteBoxFromDisk(AppConstants.userProfileBox);
    await Hive.deleteBoxFromDisk(AppConstants.periodRecordsBox);
    await Hive.deleteBoxFromDisk(AppConstants.dailyLogsBox);

    await _openEncryptedBoxes(cipher);

    if (profileJson != null) {
      await _userProfileBox.put(
          AppConstants.currentUserKey, UserProfile.fromJson(profileJson));
    }
    for (final json in recordsJson) {
      final record = PeriodRecord.fromJson(json);
      await _periodRecordsBox.put(record.id, record);
    }
    for (final json in logsJson) {
      final log = DailyLog.fromJson(json);
      await _dailyLogsBox.put(log.dateKey, log);
    }
  }

  Future<void> _writeSafetySnapshot(
    Map<String, dynamic>? profileJson,
    List<Map<String, dynamic>> recordsJson,
    List<Map<String, dynamic>> logsJson,
  ) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/pre_encryption_backup.json');
      await file.writeAsString(jsonEncode({
        'app': 'regl_takip',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'profile': profileJson,
        'periodRecords': recordsJson,
        'dailyLogs': logsJson,
      }));
    } catch (e) {
      // Snapshot best-effort: testte path_provider yok, prod'da disk dolu
      // olabilir — migrasyonu engellemesin
      debugPrint('[HIVE] safety snapshot failed: $e');
    }
  }

  /// Testler için: singleton durumunu sıfırlar (kutular kapatılmaz).
  @visibleForTesting
  void resetForTesting() {
    _isInitialized = false;
    _dataResetPerformed = false;
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
