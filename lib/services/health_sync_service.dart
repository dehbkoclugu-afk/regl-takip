import 'dart:io' show Platform;
import 'dart:convert';
import '../models/daily_log.dart';
import '../models/enums.dart';
import '../core/utils/calendar_days.dart';
import 'hive_service.dart';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

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
  static const _ledgerKey = 'health_sync_ledger_v2';

  /// İçe aktarmada geriye kaç ay bakılacağı. Daha eskisi kullanıcının
  /// zaten girdiği geçmişle çakışıyor ve okuma maliyetini büyütüyor.
  static const int importMonths = 12;

  Future<HealthSyncResult> syncPeriods(
    List<PeriodRecord> records, {
    List<DailyLog> logs = const [],
  }) async {
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

      final store = HiveService();
      final ledger = Map<String, dynamic>.from(
          jsonDecode(store.readMetadata(_ledgerKey) ?? '{}') as Map);
      final plan = buildSyncPlan(records, logs);
      final keys = {...ledger.keys, ...plan.keys}.toList()..sort();
      for (final key in keys) {
        final next = plan[key];
        if (next == ledger[key]) continue;
        final day = DateTime.parse(key);
        final start = DateTime(day.year, day.month, day.day, 12);
        final end = DateTime(day.year, day.month, day.day, 12, 1);
        // Health APIs only permit deleting records written by this app.
        // Delete/rewrite makes retry after a crash idempotent.
        if (!await _health.delete(
            type: HealthDataType.MENSTRUATION_FLOW,
            startTime: start,
            endTime: end)) {
          return HealthSyncResult.error;
        }
        ledger.remove(key);
        await store.writeMetadata(_ledgerKey, jsonEncode(ledger));
        if (next != null) {
          final parts = next.split(':');
          final written = await _health.writeMenstruationFlow(
            flow: MenstrualFlow.values.byName(parts[0]),
            startTime: start,
            endTime: end,
            isStartOfCycle: parts[1] == '1',
            recordingMethod: RecordingMethod.manual,
          );
          if (!written) return HealthSyncResult.error;
          ledger[key] = next;
          await store.writeMetadata(_ledgerKey, jsonEncode(ledger));
        }
      }
      return HealthSyncResult.success;
    } catch (e) {
      debugPrint('[HEALTH] sync failed: $e');
      return HealthSyncResult.error;
    }
  }

  static MenstrualFlow flowFor(FlowIntensity? value) => switch (value) {
        FlowIntensity.light => MenstrualFlow.light,
        FlowIntensity.normal => MenstrualFlow.medium,
        FlowIntensity.heavy || FlowIntensity.veryHeavy => MenstrualFlow.heavy,
        _ => MenstrualFlow.unspecified,
      };

  static Map<String, String> buildSyncPlan(
      List<PeriodRecord> records, List<DailyLog> logs,
      {DateTime? now}) {
    final flows = {
      for (final log in logs) log.dateKey: flowFor(log.flowIntensity)
    };
    final result = <String, String>{};
    final today = now ?? DateTime.now();
    for (final record in records) {
      final start = DateTime(
          record.startDate.year, record.startDate.month, record.startDate.day);
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
          .map((p) =>
              DateTime(p.dateFrom.year, p.dateFrom.month, p.dateFrom.day))
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
  static List<(DateTime, DateTime)> groupConsecutiveDays(List<DateTime> days) {
    if (days.isEmpty) return const [];

    final unique = <DateTime>{
      for (final d in days) DateTime(d.year, d.month, d.day),
    }.toList()
      ..sort();

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
      (DateTime, DateTime) range, List<PeriodRecord> existing) {
    for (final record in existing) {
      final rStart = DateTime(
          record.startDate.year, record.startDate.month, record.startDate.day);
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
