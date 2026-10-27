import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:regl_takip/core/constants/app_constants.dart';
import 'package:regl_takip/core/utils/cycle_utils.dart';
import 'package:regl_takip/core/utils/date_only.dart';
import 'package:regl_takip/core/utils/pin_lockout.dart';
import 'package:regl_takip/models/period_record.dart';
import 'package:regl_takip/models/user_profile.dart';
import 'package:regl_takip/providers/providers.dart';
import 'package:regl_takip/services/backup_service.dart';
import 'package:regl_takip/services/export_service.dart';
import 'package:regl_takip/services/health_sync_service.dart';
import 'package:regl_takip/services/hive_service.dart';

/// Denetimde bulunan hataların regresyonları.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late HiveService service;
  final key = List<int>.generate(32, (i) => i);
  final today = dateOnly(DateTime.now());

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('audit_regressions');
    Hive.init(tempDir.path);
    HiveService().resetForTesting();
    service = HiveService();
    await service.init(
        encryptionKey: key, manageHivePath: false, assumeEncrypted: true);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('startPeriod geçmişe ekleme', () {
    test('daha yeni bir kaydın öncesine eklenen kayıt kapalı ve taşmaz',
        () async {
      final notifier = PeriodRecordsNotifier(service);
      await notifier.addRecord(PeriodRecord(
        id: 'recent',
        startDate: addDays(today, -10),
        endDate: addDays(today, -6),
      ));

      final record = await notifier.startPeriod(addDays(today, -40));

      expect(record.isOngoing, isFalse);
      expect(record.startDate, addDays(today, -40));
      expect(record.endDate,
          addDays(today, -40 + AppConstants.defaultPeriodLength - 1));
      expect(notifier.state.where((r) => r.isOngoing), isEmpty);
    });

    test('sonraki kayda yakın başlangıç onun bir gün öncesinde biter',
        () async {
      final notifier = PeriodRecordsNotifier(service);
      await notifier.addRecord(PeriodRecord(
        id: 'next',
        startDate: addDays(today, -10),
        endDate: addDays(today, -6),
      ));
      final record =
          await notifier.startPeriod(addDays(today, -12), periodLength: 5);
      expect(record.endDate, addDays(today, -11));
    });

    test('süren kaydın öncesine ekleme süren kaydı bozmaz', () async {
      final notifier = PeriodRecordsNotifier(service);
      final ongoing = await notifier.startPeriod(addDays(today, -2));
      final old = await notifier.startPeriod(addDays(today, -40));

      expect(old.id, isNot(ongoing.id));
      final current = notifier.state.firstWhere((r) => r.id == ongoing.id);
      expect(current.isOngoing, isTrue);
      expect(current.startDate, addDays(today, -2));
    });

    test('kapalı kaydın içindeki gün yeni kayıt açmaz', () async {
      final notifier = PeriodRecordsNotifier(service);
      await notifier.addRecord(PeriodRecord(
        id: 'r',
        startDate: addDays(today, -20),
        endDate: addDays(today, -16),
      ));
      final record = await notifier.startPeriod(addDays(today, -18));
      expect(record.id, 'r');
      expect(notifier.state.length, 1);
    });

    test('periodLength verilirse süresi dolmuş geçmiş başlangıç kapanır',
        () async {
      final notifier = PeriodRecordsNotifier(service);
      final record =
          await notifier.startPeriod(addDays(today, -40), periodLength: 5);
      expect(record.endDate, addDays(today, -36));
    });

    test('periodLength verilirse hâlâ sürebilecek kayıt açık kalır', () async {
      final notifier = PeriodRecordsNotifier(service);
      final record =
          await notifier.startPeriod(addDays(today, -2), periodLength: 5);
      expect(record.isOngoing, isTrue);
    });
  });

  test('Health içe aktarma süren kaydı bozmaz, aralığı ekler', () async {
    final notifier = PeriodRecordsNotifier(service);
    final ongoing = await notifier.startPeriod(addDays(today, -2));

    // settings_screen._importFromHealth'in kullandığı yol
    final added = await notifier.addCompletedPeriodRanges([
      (start: addDays(today, -60), end: addDays(today, -56)),
    ]);

    expect(added, isNotNull);
    final current = notifier.state.firstWhere((r) => r.id == ongoing.id);
    expect(current.isOngoing, isTrue);
    expect(notifier.state.length, 2);
  });

  group('syncLastPeriodStart', () {
    late ProviderContainer container;
    setUp(() {
      container = ProviderContainer(
          overrides: [hiveServiceProvider.overrideWithValue(service)]);
    });
    tearDown(() => container.dispose());

    test('geçmişe eklenen kayıt son regl tarihini geri taşımaz', () async {
      final profile = container.read(userProfileProvider.notifier);
      final records = container.read(periodRecordsProvider.notifier);
      await profile.updateProfile(UserProfile(
          onboardingCompleted: true, lastPeriodStart: addDays(today, -5)));
      await records.addRecord(
          PeriodRecord(id: 'new', startDate: addDays(today, -5)));

      await records.startPeriod(addDays(today, -40));
      await profile.syncLastPeriodStart(container.read(periodRecordsProvider));

      expect(container.read(userProfileProvider)?.lastPeriodStart,
          addDays(today, -5));
    });

    test('son kayıt silinince tarih temizlenir', () async {
      final profile = container.read(userProfileProvider.notifier);
      final records = container.read(periodRecordsProvider.notifier);
      await profile.updateProfile(UserProfile(
          onboardingCompleted: true, lastPeriodStart: addDays(today, -5)));
      await records.addRecord(
          PeriodRecord(id: 'only', startDate: addDays(today, -5)));

      await records.deleteRecord('only');
      await profile.syncLastPeriodStart(container.read(periodRecordsProvider));

      expect(container.read(userProfileProvider)?.lastPeriodStart, isNull);
    });

    test('regl bitiş günü hâlâ menstrüel fazdır', () async {
      final profile = container.read(userProfileProvider.notifier);
      final records = container.read(periodRecordsProvider.notifier);
      final start = addDays(today, -4);
      await records.addRecord(
          PeriodRecord(id: 'r', startDate: start, endDate: today));
      await profile.updateProfile(UserProfile(
        onboardingCompleted: true,
        lastPeriodStart: start,
        averagePeriodLength: 3,
      ));
      expect(container.read(currentCyclePhaseProvider), CyclePhase.menstrual);
    });
  });

  group('takvim günü aritmetiği', () {
    // Yaz saati olan bir saat diliminde de doğru kalmalı:
    //   TZ=Europe/Berlin flutter test test/audit_regressions_test.dart
    test('tahmini tarih yaz saati geçişinde kaymaz', () {
      expect(CycleUtils.predictNextPeriod(DateTime(2026, 10, 1), 28),
          DateTime(2026, 10, 29));
      expect(CycleUtils.predictNextPeriod(DateTime(2026, 3, 20), 28),
          DateTime(2026, 4, 17));
    });

    test('gün farkı yaz saati geçişinde eksik çıkmaz', () {
      expect(daysBetween(DateTime(2026, 3, 28), DateTime(2026, 3, 30)), 2);
      expect(daysBetween(DateTime(2026, 10, 24), DateTime(2026, 10, 26)), 2);
      expect(
          CycleUtils.currentCycleDay(DateTime(2026, 3, 28),
              now: DateTime(2026, 3, 30, 9)),
          3);
    });

    test('regl süresi yaz saati geçişinde doğru', () {
      final record = PeriodRecord(
        id: 'x',
        startDate: DateTime(2026, 3, 27),
        endDate: DateTime(2026, 3, 31),
      );
      expect(record.durationDays, 5);
    });

    test('Health günleri geçişte son günü atlamaz', () {
      final days = HealthSyncService.periodDays([
        PeriodRecord(
          id: 'x',
          startDate: DateTime(2026, 3, 28),
          endDate: DateTime(2026, 3, 30),
        ),
      ]);
      expect(days.keys, ['2026-03-28', '2026-03-29', '2026-03-30']);
      expect(days['2026-03-28']!.isStart, isTrue);
      expect(days['2026-03-30']!.isStart, isFalse);
    });
  });

  group('Health senkron kümesi', () {
    test('eski eşikten geçişte eşiğe kadarki günler aktarılmış sayılır', () {
      final days = HealthSyncService.periodDays([
        PeriodRecord(
          id: 'a',
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 5, 3),
        ),
        PeriodRecord(
          id: 'b',
          startDate: DateTime(2026, 6, 1),
          endDate: DateTime(2026, 6, 2),
        ),
      ]);
      final synced = HealthSyncService.migrateLegacySynced(
          DateTime(2026, 5, 3).millisecondsSinceEpoch, days);
      expect(synced, {'2026-05-01', '2026-05-02', '2026-05-03'});
      expect(HealthSyncService.migrateLegacySynced(null, days), isEmpty);
    });
  });

  group('gecikme', () {
    test('gecikmede gösterilen gün başa sarılmaz', () {
      final start = DateTime(2026, 9, 1);
      final now = DateTime(2026, 10, 1); // 31. gün, 28 günlük döngü
      expect(CycleUtils.periodDelayDays(start, 28, now: now), 2);
      expect(CycleUtils.displayCycleDay(start, 28, now: now), 31);
      expect(CycleUtils.getCurrentPhase(start, 28, 5, now: now),
          CyclePhase.luteal);
    });
  });

  group('PinLockout', () {
    test('5. yanlış denemeden sonra artan bekleme', () async {
      final store = _MemoryStore();
      var now = DateTime(2026, 1, 1, 12);
      final lockout = PinLockout(store: store, clock: () => now);

      for (var i = 0; i < 4; i++) {
        expect(await lockout.registerFailure(), 0);
      }
      expect(await lockout.registerFailure(), 30);
      expect(await lockout.remainingSeconds(), 30);
      expect(await lockout.registerFailure(), 60);

      now = now.add(const Duration(seconds: 61));
      expect(await lockout.remainingSeconds(), 0);

      await lockout.clear();
      expect(await lockout.registerFailure(), 0);
    });

    test('bekleme 5 dakikada sınırlanır', () {
      expect(PinLockout.lockoutSecondsFor(100), 300);
    });
  });

  group('yedek', () {
    test('deneme başlangıcı yedeğe girer ve geri okunur', () {
      final backup = BackupService(service);
      final trial = DateTime(2026, 1, 15, 10);
      final parsed =
          backup.parseBackup(backup.buildBackupJson(trialStart: trial));
      expect(parsed.trialStart, trial);
    });

    test('eski yedekte deneme başlangıcı yoktur', () {
      final backup = BackupService(service);
      expect(backup.parseBackup(backup.buildBackupJson()).trialStart, isNull);
    });
  });

  test('dışa aktarma dosyaları tanınır', () {
    expect(ExportService.isExportFileName('period_tracker_20261026.csv'),
        isTrue);
    expect(
        ExportService.isExportFileName('regl_takip_backup_1.rtbackup'), isTrue);
    expect(ExportService.isExportFileName('cycle_widget_ring_0.png'), isFalse);
  });

  test('ayarlardaki sürüm pubspec ile aynı', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match =
        RegExp(r'^version:\s*([^+\s]+)', multiLine: true).firstMatch(pubspec);
    expect(match?.group(1), AppConstants.appVersion);
  });
}

class _MemoryStore implements PinAttemptStore {
  final _values = <String, String>{};
  @override
  Future<String?> read(String key) async => _values[key];
  @override
  Future<void> write(String key, String value) async => _values[key] = value;
  @override
  Future<void> delete(String key) async => _values.remove(key);
}
