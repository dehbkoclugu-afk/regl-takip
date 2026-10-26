import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_log.dart';
import '../models/period_record.dart';
import '../models/user_profile.dart';
import 'encrypted_backup_codec.dart';
import 'hive_service.dart';
import 'premium_service.dart';

/// Yedek dosyası içeriği — parse ve restore arasındaki taşıyıcı.
class BackupData {
  final UserProfile? profile;
  final List<PeriodRecord> periodRecords;
  final List<DailyLog> dailyLogs;

  /// Yedeği alan kurulumun deneme başlangıcı (eski yedeklerde yok).
  final DateTime? trialStart;

  BackupData({
    required this.profile,
    required this.periodRecords,
    required this.dailyLogs,
    this.trialStart,
  });

  int get totalRecordCount => periodRecords.length + dailyLogs.length;
}

class BackupException implements Exception {
  final String message;
  BackupException(this.message);
  @override
  String toString() => 'BackupException: $message';
}

class BackupService {
  static const int backupVersion = 1;

  /// Son başarılı yedeğin zamanı (SharedPreferences).
  /// Hive'da değil: "tüm verileri sil" yedek geçmişini de silmemeli,
  /// aksi halde kullanıcı sıfırdan başlarken "hiç yedek almadın" uyarısı
  /// doğru olur ama ona söylenmesi gereken şey bu değildir.
  static const String lastBackupKey = 'last_backup_epoch';

  /// Kaç gün sonra "yedek alman iyi olur" denecek.
  static const int backupStaleDays = 30;

  final HiveService _hiveService;

  BackupService(this._hiveService);

  static Future<DateTime?> lastBackupAt() async {
    final prefs = await SharedPreferences.getInstance();
    final epoch = prefs.getInt(lastBackupKey);
    return epoch == null ? null : DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  /// Yedek gerçekten paylaşıldıktan sonra çağrılır. Dosyayı yazmak yeterli
  /// değil: kullanıcı paylaşım sayfasını iptal etmiş olabilir.
  static Future<void> markBackedUp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        lastBackupKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Yedek bayatladı mı? Hiç alınmadıysa da true — telefon kaybında
  /// yılların verisi gidiyor ve uygulama bunu hiç hatırlatmıyordu.
  static bool isStale(DateTime? last) {
    if (last == null) return true;
    return DateTime.now().difference(last).inDays >= backupStaleDays;
  }

  /// Mevcut tüm veriyi JSON string'e serileştirir.
  ///
  /// [trialStart] yedeğe girer: "yedek al → uygulamayı sil/kur → geri yükle"
  /// her seferinde yeni bir 30 günlük deneme başlatıyordu.
  String buildBackupJson({DateTime? trialStart}) {
    final profile = _hiveService.getUserProfile();
    final records = _hiveService.getAllPeriodRecords();
    final logs = _hiveService.getAllDailyLogs();

    final payload = {
      'app': 'regl_takip',
      'version': backupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      if (trialStart != null) 'trialStart': trialStart.millisecondsSinceEpoch,
      'profile': profile?.toJson(),
      'periodRecords': records.map((r) => r.toJson()).toList(),
      'dailyLogs': logs.map((l) => l.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Yedeği parolayla şifreleyip geçici dizine yazar.
  Future<String> exportBackup(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final trialEpoch = prefs.getInt(PremiumService.trialStartKey);
    final json = buildBackupJson(
      trialStart: trialEpoch == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(trialEpoch),
    );
    final encrypted = await Isolate.run(
      () => EncryptedBackupCodec().encrypt(json, password),
    );
    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/regl_takip_backup_$timestamp.rtbackup');
    await file.writeAsString(encrypted, flush: true);
    return file.path;
  }

  bool isEncryptedBackup(String source) =>
      EncryptedBackupCodec().isEncryptedEnvelope(source);

  Future<String> decryptBackup(String source, String password) =>
      Isolate.run(
        () => EncryptedBackupCodec().decrypt(source, password),
      );

  Future<String> readBackupFile(String path) async {
    final file = File(path);
    if (await file.length() > EncryptedBackupCodec.maxFileBytes) {
      throw BackupException('Yedek dosyası çok büyük');
    }
    return file.readAsString();
  }

  /// JSON string'i doğrular ve BackupData'ya çözer.
  /// Bozuk/yabancı dosyada [BackupException] fırlatır.
  BackupData parseBackup(String jsonString) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      throw BackupException('Geçerli bir JSON dosyası değil');
    }

    if (decoded is! Map<String, dynamic>) {
      throw BackupException('Beklenmeyen yedek biçimi');
    }
    if (decoded['app'] != 'regl_takip') {
      throw BackupException('Bu dosya bir Regl Takip yedeği değil');
    }
    final version = decoded['version'];
    if (version is! int || version < 1 || version > backupVersion) {
      throw BackupException('Desteklenmeyen yedek sürümü: $version');
    }

    try {
      final profile = decoded['profile'] != null
          ? UserProfile.fromJson(decoded['profile'] as Map<String, dynamic>)
          : null;
      final records = (decoded['periodRecords'] as List<dynamic>? ?? [])
          .map((r) => PeriodRecord.fromJson(r as Map<String, dynamic>))
          .toList();
      final logs = (decoded['dailyLogs'] as List<dynamic>? ?? [])
          .map((l) => DailyLog.fromJson(l as Map<String, dynamic>))
          .toList();
      final trialEpoch = decoded['trialStart'];
      return BackupData(
        profile: profile,
        periodRecords: records,
        dailyLogs: logs,
        trialStart: trialEpoch is int
            ? DateTime.fromMillisecondsSinceEpoch(trialEpoch)
            : null,
      );
    } catch (e) {
      if (e is BackupException) rethrow;
      throw BackupException('Yedek verisi çözümlenemedi: $e');
    }
  }

  /// Mevcut veriyi siler ve yedekteki veriyi geri yükler.
  /// UI tarafı bu çağrıdan önce kullanıcı onayı almalı, sonrasında
  /// provider'ları tazelemeli (refresh()).
  ///
  /// Silme ve yazma tek bir işlem değil: yazma yarıda hata verirse
  /// (disk dolu, bozuk kayıt) eskiden kullanıcı hem eski verisini hem
  /// yedeği kaybediyordu. Önce mevcut veri bellekte tutulur, hata olursa
  /// geri yazılır ve hata yukarı iletilir.
  Future<void> restoreBackup(BackupData data) async {
    final previous = BackupData(
      profile: _hiveService.getUserProfile() == null
          ? null
          : UserProfile.fromJson(_hiveService.getUserProfile()!.toJson()),
      periodRecords: _hiveService
          .getAllPeriodRecords()
          .map((r) => PeriodRecord.fromJson(r.toJson()))
          .toList(),
      dailyLogs: _hiveService
          .getAllDailyLogs()
          .map((l) => DailyLog.fromJson(l.toJson()))
          .toList(),
    );

    try {
      await _writeAll(data, resetLock: true);
    } catch (e) {
      try {
        await _writeAll(previous, resetLock: false);
      } catch (rollbackError) {
        throw BackupException(
            'Geri yükleme ve geri alma başarısız: $e / $rollbackError');
      }
      rethrow;
    }
    if (data.trialStart != null) {
      await adoptEarlierTrialStart(data.trialStart);
    }
  }

  Future<void> _writeAll(BackupData data, {required bool resetLock}) async {
    await _hiveService.clearAll();

    if (data.profile != null) {
      // PIN hash'i ve biyometrik kayıt cihaza özgüdür, yedeğe girmez.
      // pinEnabled=true geri yüklenirse ve bu cihazda hash yoksa kullanıcı
      // kilit ekranından asla geçemez — kilit ayarları sıfırlanır.
      final profile = resetLock
          ? data.profile!.copyWith(pinEnabled: false, biometricEnabled: false)
          : data.profile!;
      await _hiveService.saveUserProfile(profile);
    }
    for (final record in data.periodRecords) {
      await _hiveService.savePeriodRecord(record);
    }
    for (final log in data.dailyLogs) {
      await _hiveService.saveDailyLog(log);
    }
    await _hiveService.ensureMedicationPlanMigrated();
  }

  /// Yedekteki deneme başlangıcı bu kurulumunkinden eskiyse onu benimser.
  /// Etkin deneme başlangıcını döndürür (UI provider'ı günceller).
  static Future<DateTime?> adoptEarlierTrialStart(DateTime? fromBackup) async {
    final prefs = await SharedPreferences.getInstance();
    final currentEpoch = prefs.getInt(PremiumService.trialStartKey);
    final current = currentEpoch == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(currentEpoch);
    if (fromBackup == null) return current;
    if (current == null || fromBackup.isBefore(current)) {
      await prefs.setInt(
          PremiumService.trialStartKey, fromBackup.millisecondsSinceEpoch);
      return fromBackup;
    }
    return current;
  }
}
