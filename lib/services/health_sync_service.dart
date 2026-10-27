import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/date_only.dart';
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
/// Yazma tarafında aktarılan günlerin KÜMESİ saklanır. Eskiden yalnız
/// "aktarılan en son gün" eşiği tutuluyordu: sonradan eklenen eski bir
/// dönem hiç aktarılmıyor, silinen ya da kısaltılan kayıtların günleri
/// Health Connect'te kalıyordu.
class HealthSyncService {
  final Health _health = Health();

  static const _types = [HealthDataType.MENSTRUATION_FLOW];
  static const _permissions = [HealthDataAccess.WRITE];
  static const _readPermissions = [HealthDataAccess.READ];

  /// Eski sürümün eşiği (son aktarılan gün, epoch ms). Yalnız geçiş için
  /// okunur ve silinir.
  static const legacyLastSyncedKey = 'health_last_synced_day';

  /// Aktarılmış günler (yyyy-MM-dd listesi).
  static const syncedDaysKey = 'health_synced_days';

  /// İçe aktarmada geriye kaç ay bakılacağı. Daha eskisi kullanıcının
  /// zaten girdiği geçmişle çakışıyor ve okuma maliyetini büyütüyor.
  static const int importMonths = 12;

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Kayıtların kapsadığı günler (süren kayıt bugüne kadar), gün başına
  /// ve dönemin ilk günü mü bilgisiyle.
  static Map<String, ({DateTime day, bool isStart})> periodDays(
      List<PeriodRecord> records,
      {DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    final out = <String, ({DateTime day, bool isStart})>{};
    for (final record in records) {
      final start = dateOnly(record.startDate);
      final end = dateOnly(record.endDate ?? today);
      for (var day = start; !day.isAfter(end); day = addDays(day, 1)) {
        out[dayKey(day)] = (day: day, isStart: day == start);
      }
    }
    return out;
  }

  /// Eski eşikten geçiş: eşiğe kadarki kayıt günleri zaten aktarılmış
  /// sayılır (yeniden yazılıp çiftlenmesin).
  static Set<String> migrateLegacySynced(
      int? legacyEpochMs, Map<String, ({DateTime day, bool isStart})> days) {
    if (legacyEpochMs == null) return <String>{};
    final watermark = dateOnly(
        DateTime.fromMillisecondsSinceEpoch(legacyEpochMs));
    return {
      for (final entry in days.entries)
        if (!entry.value.day.isAfter(watermark)) entry.key,
    };
  }

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
      final wanted = periodDays(records);
      final synced = prefs.getStringList(syncedDaysKey)?.toSet() ??
          migrateLegacySynced(prefs.getInt(legacyLastSyncedKey), wanted);

      // Artık regl günü olmayan (silinen/kısaltılan kayıt) aktarılmış
      // günler geri alınır. Platform yalnız bu uygulamanın yazdıklarını
      // siler; başka uygulamaların verisine dokunulmaz.
      for (final key in synced.difference(wanted.keys.toSet()).toList()) {
        final day = DateTime.parse(key);
        final deleted = await _health.delete(
          type: HealthDataType.MENSTRUATION_FLOW,
          startTime: day,
          endTime: addDays(day, 1),
        );
        if (deleted) synced.remove(key);
      }

      for (final entry in wanted.entries) {
        if (synced.contains(entry.key)) continue;
        final day = entry.value.day;
        final ok = await _health.writeMenstruationFlow(
          flow: MenstrualFlow.medium,
          startTime: DateTime(day.year, day.month, day.day, 12),
          endTime: DateTime(day.year, day.month, day.day, 12, 1),
          isStartOfCycle: entry.value.isStart,
          recordingMethod: RecordingMethod.manual,
        );
        if (ok) synced.add(entry.key);
      }

      await prefs.setStringList(syncedDaysKey, synced.toList()..sort());
      await prefs.remove(legacyLastSyncedKey);
      return HealthSyncResult.success;
    } catch (e) {
      debugPrint('[HEALTH] sync failed: $e');
      return HealthSyncResult.error;
    }
  }

  /// "Tüm verileri sil" sonrası: senkron geçmişi de sıfırlanmalı, yoksa
  /// yeniden girilen günler "zaten aktarıldı" sanılıp atlanır.
  static Future<void> resetSyncState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(syncedDaysKey);
    await prefs.remove(legacyLastSyncedKey);
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
      final isNext = daysBetween(prev, day) == 1;
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
