import 'dart:io';
import 'dart:ui';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:regl_takip/models/daily_log.dart';
import 'package:regl_takip/models/period_record.dart';
import 'package:regl_takip/models/user_profile.dart';
import 'package:regl_takip/services/export_service.dart';
import 'package:regl_takip/services/export_cleanup.dart';
import 'package:regl_takip/services/usage_metrics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('export-audit-');
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => dir.path);
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await dir.delete(recursive: true);
  });
  final l10n = lookupAppLocalizations(const Locale('en'));
  test(
      'CSV contains period-only records, explicit units and protected full notes',
      () async {
    final note = '=SUM(1,2)\nFull note: 📝, quoted "text"';
    final path = await ExportService().exportCsv([
      PeriodRecord(
          id: 'period',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 5)),
    ], {
      'log': DailyLog(id: 'log', date: DateTime(2026, 1, 2), notes: note)
    }, l10n);
    final content = await File(path).readAsString();
    expect((await File(path).readAsBytes()).take(3), [0xef, 0xbb, 0xbf]);
    final rows = const CsvToListConverter().convert(content);
    expect(rows.length, 3);
    expect(rows.every((r) => r.length == 13), isTrue);
    expect(rows.first, contains('${l10n.temperature} (°C)'));
    expect(rows.first, contains('${l10n.weight} (kg)'));
    expect(rows[1][1], '2026-01-01');
    expect(rows.last.last, "'$note");
  });
  test('ten years of daily records and a long note export to PDF', () async {
    final start = DateTime(2016, 1, 1);
    final logs = {
      for (var i = 0; i < 3653; i++)
        '$i': DailyLog(
            id: '$i',
            date: DateTime(start.year, start.month, start.day + i),
            notes:
                i == 0 ? List.filled(1000, 'Full medical note. ').join() : null)
    };
    final path = await ExportService().exportPdf(
        UserProfile(name: 'Test'), [], logs, l10n,
        includeAllLogs: true);
    final bytes = await File(path).readAsBytes();
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(10000));
  });
  test('cleanup removes only old owned exports', () async {
    final now = DateTime.now();
    final old = File('${dir.path}/period_tracker_20260101_000000.csv');
    final fresh = File('${dir.path}/period_tracker_20261023_000000.pdf');
    final other = File('${dir.path}/personal.csv');
    for (final f in [old, fresh, other]) {
      await f.writeAsString('test');
    }
    await old.setLastModified(now.subtract(const Duration(days: 3)));
    await other.setLastModified(now.subtract(const Duration(days: 3)));
    await ExportCleanup.run(directory: dir, now: now);
    expect(await old.exists(), isFalse);
    expect(await fresh.exists(), isTrue);
    expect(await other.exists(), isTrue);
  });
  test('metrics require opt-in, serialize increments and erase on opt-out',
      () async {
    await UsageMetrics.record(UsageEvent.paywallView);
    expect(await UsageMetrics.counts(), isEmpty);
    await UsageMetrics.setEnabled(true);
    await Future.wait(
        List.generate(10, (_) => UsageMetrics.record(UsageEvent.paywallView)));
    expect((await UsageMetrics.counts())['paywallView'], 10);
    await UsageMetrics.setEnabled(false);
    expect(await UsageMetrics.counts(), isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys().where((k) => k.startsWith('usage_count_')), isEmpty);
  });
}
