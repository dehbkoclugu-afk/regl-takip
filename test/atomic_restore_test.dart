import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:regl_takip/models/user_profile.dart';
import 'package:regl_takip/models/daily_log.dart';
import 'package:regl_takip/models/period_record.dart';
import 'package:regl_takip/services/hive_service.dart';
import 'package:regl_takip/services/backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  final key = List<int>.generate(32, (i) => i);
  final store = HiveService();
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('atomic-restore-');
    Hive.init(dir.path);
    store.resetForTesting();
    await store.init(
        encryptionKey: key, manageHivePath: false, assumeEncrypted: true);
    await store.saveUserProfile(UserProfile(name: 'Original'));
    await store.saveDailyLog(
        DailyLog(id: 'old', date: DateTime(2026, 1, 1), waterIntake: 4));
  });
  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });
  BackupData replacement() =>
      BackupData(profile: UserProfile(name: 'Replacement'), periodRecords: [
        PeriodRecord(id: 'new-period', startDate: DateTime(2026, 2, 1))
      ], dailyLogs: [
        DailyLog(id: 'new', date: DateTime(2026, 2, 1), waterIntake: 8)
      ]);

  for (final stage in ['profile', 'periods', 'beforeCommit']) {
    test('failure at $stage keeps original after restart', () async {
      store.transactionCheckpoint = (at) async {
        if (at == stage) throw FileSystemException('Injected failure');
      };
      await expectLater(BackupService(store).restoreBackup(replacement()),
          throwsA(isA<FileSystemException>()));
      expect(store.getUserProfile()!.name, 'Original');
      await Hive.close();
      store.resetForTesting();
      await store.init(
          encryptionKey: key, manageHivePath: false, assumeEncrypted: true);
      expect(store.getUserProfile()!.name, 'Original');
      expect(store.getAllDailyLogs().single.waterIntake, 4);
    });
  }
  test('committed replacement is complete after restart', () async {
    await BackupService(store).restoreBackup(replacement());
    await Hive.close();
    store.resetForTesting();
    await store.init(
        encryptionKey: key, manageHivePath: false, assumeEncrypted: true);
    expect(store.getUserProfile()!.name, 'Replacement');
    expect(store.getAllDailyLogs().single.id, 'new');
    expect(store.getAllPeriodRecords().single.id, 'new-period');
  });
  test('invalid replacement cannot erase existing data', () async {
    final bad = replacement();
    bad.profile!.averageCycleLength = 0;
    await expectLater(BackupService(store).restoreBackup(bad),
        throwsA(isA<BackupException>()));
    expect(store.getUserProfile()!.name, 'Original');
  });
  test('concurrent write waits for replacement and survives restart', () async {
    final restoring = BackupService(store).restoreBackup(replacement());
    final writing = store.saveDailyLog(
        DailyLog(id: 'concurrent', date: DateTime(2026, 3, 1), waterIntake: 3));
    await Future.wait([restoring, writing]);
    await Hive.close();
    store.resetForTesting();
    await store.init(
        encryptionKey: key, manageHivePath: false, assumeEncrypted: true);
    expect(store.getDailyLogByDate(DateTime(2026, 3, 1))!.waterIntake, 3);
    expect(store.getDailyLogByDate(DateTime(2026, 2, 1))!.id, 'new');
  });
  test('duplicate ids and overlapping records cannot silently overwrite',
      () async {
    final bad = replacement();
    bad.dailyLogs.add(bad.dailyLogs.first);
    await expectLater(BackupService(store).restoreBackup(bad),
        throwsA(isA<BackupException>()));
    expect(store.getAllDailyLogs().single.id, 'old');
  });
}
