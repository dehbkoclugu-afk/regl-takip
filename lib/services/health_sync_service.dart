import 'health_sync_batch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import '../models/daily_log.dart';
import '../models/enums.dart';
import '../core/utils/calendar_days.dart';
import 'hive_service.dart';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../core/utils/date_only.dart';
import '../models/period_record.dart';

enum HealthSyncResult { partial, success, permissionDenied, unavailable, error }

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
class HealthSyncReport {
  final HealthSyncResult status;
  final HealthSyncCounts counts;
  const HealthSyncReport(this.status, [this.counts = const HealthSyncCounts()]);
}

class HealthSyncService {
  static Future<HealthSyncReport>? _syncInFlight;
  Future<HealthSyncReport> syncPeriods(
    List<PeriodRecord> records, {
    List<DailyLog> logs = const [],
  }) {
    return _syncInFlight ??= _syncPeriods(
      records,
      logs: logs,
    ).whenComplete(() => _syncInFlight = null);
  }

  final Health _health = Health();

  static const _types = [HealthDataType.MENSTRUATION_FLOW];
  static const _permissions = [HealthDataAccess.WRITE];
  static const _readPermissions = [HealthDataAccess.READ];
  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Kayıtların kapsadığı günler (süren kayıt bugüne kadar), gün başına
  /// ve dönemin ilk günü mü bilgisiyle.
  static Map<String, ({DateTime day, bool isStart})> periodDays(
    List<PeriodRecord> records, {
    DateTime? now,
  }) {
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
    int? legacyEpochMs,
    Map<String, ({DateTime day, bool isStart})> days,
  ) {
    if (legacyEpochMs == null) return <String>{};
    final watermark = dateOnly(
      DateTime.fromMillisecondsSinceEpoch(legacyEpochMs),
    );
    return {
      for (final entry in days.entries)
        if (!entry.value.day.isAfter(watermark)) entry.key,
    };
  }

  static const legacyLastSyncedKey = 'health_last_synced_day';
  static const syncedDaysKey = 'health_synced_days';
  static Future<void> resetSyncState() async {
    await HiveService().writeMetadata(_ledgerKey, '{}');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(legacyLastSyncedKey);
    await prefs.remove(syncedDaysKey);
  }

  static const _ledgerKey = 'health_sync_ledger_v2';

  /// İçe aktarmada geriye kaç ay bakılacağı. Daha eskisi kullanıcının
  /// zaten girdiği geçmişle çakışıyor ve okuma maliyetini büyütüyor.
  static const int importMonths = 12;

  Future<HealthSyncReport> _syncPeriods(
    List<PeriodRecord> records, {
    List<DailyLog> logs = const [],
  }) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return const HealthSyncReport(HealthSyncResult.unavailable);
    }

    try {
      await _health.configure();

      final granted = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      if (!granted)
        return const HealthSyncReport(HealthSyncResult.permissionDenied);

      final store = HiveService();
      final ledger = Map<String, dynamic>.from(
        jsonDecode(store.readMetadata(_ledgerKey) ?? '{}') as Map,
      );
      final plan = buildSyncPlan(records, logs);
      final counts = await runHealthSyncBatch(
        plan: plan,
        ledger: ledger,
        delete: (key) {
          final day = DateTime.parse(key);
          return _health.delete(
            type: HealthDataType.MENSTRUATION_FLOW,
            startTime: DateTime(day.year, day.month, day.day),
            endTime: DateTime(day.year, day.month, day.day + 1),
          );
        },
        write: (key, value) {
          final day = DateTime.parse(key);
          final parts = value.split(':');
          return _health.writeMenstruationFlow(
            flow: MenstrualFlow.values.byName(parts[0]),
            startTime: DateTime(day.year, day.month, day.day, 12),
            endTime: DateTime(day.year, day.month, day.day, 12, 1),
            isStartOfCycle: parts[1] == '1',
            recordingMethod: RecordingMethod.manual,
          );
        },
        persist: (next) => store.writeMetadata(_ledgerKey, jsonEncode(next)),
      );
      return HealthSyncReport(
        counts.complete
            ? HealthSyncResult.success
            : counts.written + counts.deleted > 0
            ? HealthSyncResult.partial
            : HealthSyncResult.error,
        counts,
      );
    } catch (e) {
      debugPrint('[HEALTH] sync failed: $e');
      return const HealthSyncReport(HealthSyncResult.error);
    }
  }

  static MenstrualFlow flowFor(FlowIntensity? value) => switch (value) {
    FlowIntensity.light => MenstrualFlow.light,
    FlowIntensity.normal => MenstrualFlow.medium,
    FlowIntensity.heavy || FlowIntensity.veryHeavy => MenstrualFlow.heavy,
    _ => MenstrualFlow.unspecified,
  };

  static Map<String, String> buildSyncPlan(
    List<PeriodRecord> records,
    List<DailyLog> logs, {
    DateTime? now,
  }) {
    final flows = {
      for (final log in logs) log.dateKey: flowFor(log.flowIntensity),
    };
    final result = <String, String>{};
    final today = now ?? DateTime.now();
    for (final record in records) {
      final start = DateTime(
        record.startDate.year,
        record.startDate.month,
        record.startDate.day,
      );
      final rawEnd = record.endDate ?? today;
      final end = rawEnd.isAfter(today) ? today : rawEnd;
      for (var day = start; !day.isAfter(end); day = CalendarDays.add(day, 1)) {
        final key = day.toIso8601String().substring(0, 10);
        result[key] =
            '${(flows[key] ?? MenstrualFlow.unspecified).name}:${day == start ? '1' : '0'}';
      }
    }
    return result;
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
  Future<HealthImportResult> readPeriods(List<PeriodRecord> existing) async {
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
          .map(
            (p) => DateTime(p.dateFrom.year, p.dateFrom.month, p.dateFrom.day),
          )
          .toList();

      final ranges = groupConsecutiveDays(
        days,
      ).where((r) => !overlapsExisting(r, existing)).toList();
      return HealthImportResult(HealthSyncResult.success, ranges);
    } catch (e) {
      debugPrint('[HEALTH] read failed: $e');
      return const HealthImportResult(HealthSyncResult.error);
    }
  }

  /// Gün listesini bitişik bloklara ayırır. Tekrarlar elenir, sıra
  /// garanti edilmez (Health Connect sırayı garanti etmiyor).
  static List<(DateTime, DateTime)> groupConsecutiveDays(List<DateTime> days) {
    if (days.isEmpty) return const [];

    final unique = <DateTime>{
      for (final d in days) DateTime(d.year, d.month, d.day),
    }.toList()..sort();

    final ranges = <(DateTime, DateTime)>[];
    var start = unique.first;
    var prev = unique.first;
    for (final day in unique.skip(1)) {
      final isNext = CalendarDays.between(day, prev) == 1;
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
    (DateTime, DateTime) range,
    List<PeriodRecord> existing,
  ) {
    for (final record in existing) {
      final rStart = DateTime(
        record.startDate.year,
        record.startDate.month,
        record.startDate.day,
      );
      final endSource = record.endDate ?? DateTime.now();
      final rEnd = DateTime(endSource.year, endSource.month, endSource.day);
      // Kesişim: biri diğerinin tamamen dışında değilse
      if (!range.$2.isBefore(rStart) && !range.$1.isAfter(rEnd)) {
        return true;
      }
    }
    return false;
  }
}
