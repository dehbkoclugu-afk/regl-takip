import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/period_record.dart';

enum HealthSyncResult { success, permissionDenied, unavailable, error }

/// İçe aktarma sonucu: durum + bulunan aralıklar.
/// [ranges] yalnız [HealthSyncResult.success] durumunda anlamlı.
class HealthImportResult {
  final HealthSyncResult status;

  /// Health Connect'te bulunan, uygulamada karşılığı olmayan adet
  /// aralıkları (başlangıç, bitiş) — ikisi de gün başına normalize.
  final List<(DateTime, DateTime)> ranges;

  const HealthImportResult(this.status, [this.ranges = const []]);
}

/// Adet kayıtlarını Health Connect (Android) / HealthKit (iOS) ile
/// alışverişe sokar: yazma ve okuma, ikisi de kullanıcı tetiklemeli.
///
/// Yazma tarafında son aktarılan gün saklanır; tekrarlanan sync aynı
/// günleri yeniden yazmaz (duplicate önleme).
class HealthSyncService {
  final Health _health = Health();

  static const _types = [HealthDataType.MENSTRUATION_FLOW];
  static const _permissions = [HealthDataAccess.WRITE];
  static const _readPermissions = [HealthDataAccess.READ];
  static const _lastSyncedKey = 'health_last_synced_day';

  /// İçe aktarmada geriye kaç ay bakılacağı. Daha eskisi kullanıcının
  /// zaten girdiği geçmişle çakışıyor ve okuma maliyetini büyütüyor.
  static const int importMonths = 12;

  Future<HealthSyncResult> syncPeriods(List<PeriodRecord> records) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return HealthSyncResult.unavailable;
    }

    try {
      await _health.configure();

      final granted = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      if (!granted) return HealthSyncResult.permissionDenied;

      final prefs = await SharedPreferences.getInstance();
      final lastSyncedMs = prefs.getInt(_lastSyncedKey);
      final lastSynced = lastSyncedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastSyncedMs)
          : null;

      final now = DateTime.now();
      DateTime? newestWritten;

      for (final record in records) {
        final start = DateTime(record.startDate.year, record.startDate.month,
            record.startDate.day);
        final endSource = record.endDate ?? now;
        final end =
            DateTime(endSource.year, endSource.month, endSource.day);

        for (var day = start;
            !day.isAfter(end);
            day = day.add(const Duration(days: 1))) {
          // Daha önce aktarılan günleri atla
          if (lastSynced != null && !day.isAfter(lastSynced)) continue;

          await _health.writeMenstruationFlow(
            flow: MenstrualFlow.medium,
            startTime: day.add(const Duration(hours: 12)),
            endTime: day.add(const Duration(hours: 12, minutes: 1)),
            isStartOfCycle: day == start,
            recordingMethod: RecordingMethod.manual,
          );
          if (newestWritten == null || day.isAfter(newestWritten)) {
            newestWritten = day;
          }
        }
      }

      if (newestWritten != null) {
        await prefs.setInt(
            _lastSyncedKey, newestWritten.millisecondsSinceEpoch);
      }
      return HealthSyncResult.success;
    } catch (e) {
      debugPrint('[HEALTH] sync failed: $e');
      return HealthSyncResult.error;
    }
  }

  /// Health Connect / HealthKit'ten adet günlerini okur ve uygulamada
  /// karşılığı olmayan aralıkları döndürür.
  ///
  /// Entegrasyon tek yönlüydü: uygulama yazıyordu ama okumuyordu. Başka
  /// bir uygulamadan geçen kullanıcının geçmişi Health Connect'te duruyor
  /// olabilir ve elle yeniden girmek zorunda kalıyordu.
  ///
  /// Yazma değil öneri üretir: kayıtları oluşturmak çağıranın işi, böylece
  /// kullanıcı onaylamadan hiçbir şey yazılmaz.
  Future<HealthImportResult> readPeriods(
      List<PeriodRecord> existing) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return const HealthImportResult(HealthSyncResult.unavailable);
    }

    try {
      await _health.configure();

      final granted = await _health.requestAuthorization(
        _types,
        permissions: _readPermissions,
      );
      if (!granted) {
        return const HealthImportResult(HealthSyncResult.permissionDenied);
      }

      final now = DateTime.now();
      final points = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: DateTime(now.year, now.month - importMonths, now.day),
        endTime: now,
      );

      // Yalnız gün bilgisi kullanılıyor: akış şiddetinin karşılığı
      // platformdan platforma değişiyor, tarih ise sabit
      final days = points
          .map((p) => DateTime(p.dateFrom.year, p.dateFrom.month, p.dateFrom.day))
          .toList();

      final ranges = groupConsecutiveDays(days)
          .where((r) => !overlapsExisting(r, existing))
          .toList();
      return HealthImportResult(HealthSyncResult.success, ranges);
    } catch (e) {
      debugPrint('[HEALTH] read failed: $e');
      return const HealthImportResult(HealthSyncResult.error);
    }
  }

  /// Gün listesini bitişik bloklara ayırır. Tekrarlar elenir, sıra
  /// garanti edilmez (Health Connect sırayı garanti etmiyor).
  static List<(DateTime, DateTime)> groupConsecutiveDays(
      List<DateTime> days) {
    if (days.isEmpty) return const [];

    final unique = <DateTime>{
      for (final d in days) DateTime(d.year, d.month, d.day),
    }.toList()
      ..sort();

    final ranges = <(DateTime, DateTime)>[];
    var start = unique.first;
    var prev = unique.first;
    for (final day in unique.skip(1)) {
      final isNext = day.difference(prev).inDays == 1;
      if (!isNext) {
        ranges.add((start, prev));
        start = day;
      }
      prev = day;
    }
    ranges.add((start, prev));
    return ranges;
  }

  /// Aralık mevcut kayıtlardan biriyle kesişiyor mu?
  /// Kesişen aralık içe aktarılmaz: kullanıcının kendi kaydı esastır.
  static bool overlapsExisting(
      (DateTime, DateTime) range, List<PeriodRecord> existing) {
    for (final record in existing) {
      final rStart = DateTime(record.startDate.year, record.startDate.month,
          record.startDate.day);
      final endSource = record.endDate ?? DateTime.now();
      final rEnd =
          DateTime(endSource.year, endSource.month, endSource.day);
      // Kesişim: biri diğerinin tamamen dışında değilse
      if (!range.$2.isBefore(rStart) && !range.$1.isAfter(rEnd)) {
        return true;
      }
    }
    return false;
  }
}
