import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/daily_log.dart';
import '../models/period_record.dart';
import '../models/user_profile.dart';
import 'hive_service.dart';

/// Yedek dosyası içeriği — parse ve restore arasındaki taşıyıcı.
class BackupData {
  final UserProfile? profile;
  final List<PeriodRecord> periodRecords;
  final List<DailyLog> dailyLogs;

  BackupData({
    required this.profile,
    required this.periodRecords,
    required this.dailyLogs,
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

  final HiveService _hiveService;

  BackupService(this._hiveService);

  /// Mevcut tüm veriyi JSON string'e serileştirir.
  String buildBackupJson() {
    final profile = _hiveService.getUserProfile();
    final records = _hiveService.getAllPeriodRecords();
    final logs = _hiveService.getAllDailyLogs();

    final payload = {
      'app': 'regl_takip',
      'version': backupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': profile?.toJson(),
      'periodRecords': records.map((r) => r.toJson()).toList(),
      'dailyLogs': logs.map((l) => l.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Yedeği geçici dizine dosya olarak yazar; paylaşım için yolu döndürür.
  Future<String> exportBackup() async {
    final json = buildBackupJson();
    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/regl_takip_backup_$timestamp.json');
    await file.writeAsString(json);
    return file.path;
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
      return BackupData(
          profile: profile, periodRecords: records, dailyLogs: logs);
    } catch (e) {
      if (e is BackupException) rethrow;
      throw BackupException('Yedek verisi çözümlenemedi: $e');
    }
  }

  /// Mevcut veriyi siler ve yedekteki veriyi geri yükler.
  /// UI tarafı bu çağrıdan önce kullanıcı onayı almalı, sonrasında
  /// provider'ları tazelemeli (refresh()).
  Future<void> restoreBackup(BackupData data) async {
    await _hiveService.clearAll();

    if (data.profile != null) {
      // PIN hash'i ve biyometrik kayıt cihaza özgüdür, yedeğe girmez.
      // pinEnabled=true geri yüklenirse ve bu cihazda hash yoksa kullanıcı
      // kilit ekranından asla geçemez — kilit ayarları sıfırlanır.
      final profile = data.profile!.copyWith(
        pinEnabled: false,
        biometricEnabled: false,
      );
      await _hiveService.saveUserProfile(profile);
    }
    for (final record in data.periodRecords) {
      await _hiveService.savePeriodRecord(record);
    }
    for (final log in data.dailyLogs) {
      await _hiveService.saveDailyLog(log);
    }
  }
}
