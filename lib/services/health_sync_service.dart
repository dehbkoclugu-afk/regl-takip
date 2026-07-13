import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/period_record.dart';

enum HealthSyncResult { success, permissionDenied, unavailable, error }

/// Adet kayıtlarını Health Connect'e (Android) / HealthKit'e (iOS) yazar.
/// Tek yönlü, kullanıcı tetiklemeli aktarım. Son aktarılan gün saklanır;
/// tekrarlanan sync aynı günleri yeniden yazmaz (duplicate önleme).
class HealthSyncService {
  final Health _health = Health();

  static const _types = [HealthDataType.MENSTRUATION_FLOW];
  static const _permissions = [HealthDataAccess.WRITE];
  static const _lastSyncedKey = 'health_last_synced_day';

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
}
