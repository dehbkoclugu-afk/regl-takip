import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/theme/app_colors.dart';
import 'package:regl_takip/core/utils/cycle_prediction.dart';
import 'package:regl_takip/core/utils/unit_conversion.dart';
import 'package:regl_takip/core/utils/cycle_utils.dart';
import 'package:regl_takip/models/daily_log.dart';
import 'package:regl_takip/models/enums.dart';
import 'package:regl_takip/models/user_profile.dart';
import 'package:regl_takip/services/backup_service.dart';
import 'package:regl_takip/services/health_sync_batch.dart';
import 'package:regl_takip/services/hive_service.dart';

void main() {
  test('primary action white text clears 4.5:1 contrast', () {
    final dark = AppColors.primaryDeep.computeLuminance();
    final white = Colors.white.computeLuminance();
    expect((white + 0.05) / (dark + 0.05), greaterThanOrEqualTo(4.5));
  });
  test('temperature preference formats Turkish Fahrenheit consistently', () {
    expect(
      UnitConversion.formatTemperature(37, fahrenheit: true, locale: 'tr'),
      '98,6 °F',
    );
  });
  test(
    'invalid backup never enters replacement, including zero and negative cycles',
    () {
      final service = BackupService(HiveService());
      for (final length in [0, -1, 500]) {
        final payload = jsonEncode({
          'app': 'regl_takip',
          'version': 1,
          'profile': UserProfile(averageCycleLength: length).toJson(),
          'periodRecords': [],
          'dailyLogs': [],
        });
        expect(
          () => service.parseBackup(payload),
          throwsA(isA<BackupException>()),
        );
        expect(
          () => CycleUtils.nextFuturePeriod(DateTime(2026, 1), length),
          throwsArgumentError,
        );
      }
    },
  );
  test('LH attribution and future dates retain one reference', () {
    final start = DateTime(2026, 10, 1);
    final lh = DailyLog(
      id: 'lh',
      date: DateTime(2026, 10, 12),
      ovulationTestPositive: true,
    );
    final p = CyclePrediction.calculate(
      start: start,
      length: 28,
      mode: TrackingMode.period,
      logs: [lh],
      now: DateTime(2026, 10, 16),
    )!;
    expect(p.source, PredictionSource.lh);
    expect(p.ovulation, DateTime(2026, 10, 13));
    expect(p.fertileStart, DateTime(2026, 10, 8));
    final later = CyclePrediction.calculate(
      start: start,
      length: 28,
      mode: TrackingMode.period,
      now: DateTime(2026, 11, 30),
    )!;
    expect(later.source, PredictionSource.calendar);
    expect(later.fertileStart, DateTime(2026, 12, 5));
    expect(later.fertileEnd, DateTime(2026, 12, 11));
  });
  test(
    'failed second day stays pending and retry does not repeat acknowledged day',
    () async {
      final durable = <String, dynamic>{};
      final calls = <String>[];
      var fail = true;
      Future<HealthSyncCounts> run() => runHealthSyncBatch(
        plan: {'a': 'medium:1', 'b': 'light:0'},
        ledger: durable,
        delete: (key) async {
          calls.add(key);
          return true;
        },
        write: (key, value) async => key != 'b' || !fail,
        persist: (data) async {
          durable
            ..clear()
            ..addAll(data);
        },
      );
      expect((await run()).pending, 1);
      expect(durable.keys, ['a']);
      fail = false;
      expect((await run()).pending, 0);
      expect(calls, ['a', 'b', 'b']);
    },
  );
}
