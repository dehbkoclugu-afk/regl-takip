import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:regl_takip/models/period_record.dart';
import 'package:regl_takip/providers/providers.dart';
import 'package:regl_takip/services/hive_service.dart';

/// B-8 regresyonları: profildeki son regl tarihinin düzenlenmesi kayıtları
/// kırpmamalı/çiftlememeli; kayıt düzenleyici primitifleri tutarlı olmalı.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late HiveService service;
  final key = List<int>.generate(32, (i) => i);

  setUp(() async {
    tempDir =
        await Directory.systemTemp.createTemp('period_records_provider_test');
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

  group('syncProfilePeriodRecord', () {
    test('geriye tarih düzeltmesi kaydı taşır, kırpıp çiftlemez', () async {
      final notifier = PeriodRecordsNotifier(service);
      // Yanlış girilmiş tarih: ayın 5'i, süren kayıt
      final wrong = await notifier.startPeriod(DateTime(2026, 7, 5));
      expect(notifier.state.length, 1);

      // Kullanıcı gerçeğe çekiyor: ayın 1'i
      await notifier.syncProfilePeriodRecord(
        previousStart: DateTime(2026, 7, 5),
        newStart: DateTime(2026, 7, 1),
        periodLength: 5,
      );

      // Tek kayıt kaldı ve taşındı — eski davranış kaydı 5-5'e kırpıyordu
      expect(notifier.state.length, 1);
      final record = notifier.state.single;
      expect(record.id, wrong.id);
      expect(record.startDate, DateTime(2026, 7, 1));
      // 1 Tem + 5 gün regl bugünden önce bitti: kayıt kapanmış olmalı
      expect(record.endDate, DateTime(2026, 7, 5));
    });

    test('kapalı kayıt varken düzeltme çakışan çift kayıt üretmez', () async {
      final notifier = PeriodRecordsNotifier(service);
      await notifier.addRecord(PeriodRecord(
        id: 'r1',
        startDate: DateTime(2026, 7, 5),
        endDate: DateTime(2026, 7, 9),
      ));

      await notifier.syncProfilePeriodRecord(
        previousStart: DateTime(2026, 7, 5),
        newStart: DateTime(2026, 7, 1),
        periodLength: 5,
      );

      expect(notifier.state.length, 1);
      expect(notifier.state.single.startDate, DateTime(2026, 7, 1));
    });

    test('eski tarihe ait kayıt yoksa bağımsız kayıt açılır', () async {
      final notifier = PeriodRecordsNotifier(service);
      await notifier.syncProfilePeriodRecord(
        previousStart: null,
        newStart: DateTime(2026, 6, 10),
        periodLength: 5,
      );
      expect(notifier.state.length, 1);
      expect(notifier.state.single.startDate, DateTime(2026, 6, 10));
      expect(notifier.state.single.endDate, DateTime(2026, 6, 14));
    });

    test('yeni tarih zaten kayıtlıysa dokunulmaz', () async {
      final notifier = PeriodRecordsNotifier(service);
      await notifier.addRecord(PeriodRecord(
        id: 'r1',
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 7, 5),
      ));
      await notifier.syncProfilePeriodRecord(
        previousStart: DateTime(2026, 6, 1),
        newStart: DateTime(2026, 7, 1),
        periodLength: 5,
      );
      expect(notifier.state.length, 1);
      expect(notifier.state.single.id, 'r1');
    });
  });

  group('kayıt düzenleyici primitifleri', () {
    test('updateRecordDates tarihleri normalize eder, bitişi kelepçeler',
        () async {
      final notifier = PeriodRecordsNotifier(service);
      await notifier.addRecord(PeriodRecord(
        id: 'r1',
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 7, 5),
      ));

      await notifier.updateRecordDates(
          'r1', DateTime(2026, 7, 10, 14, 30), DateTime(2026, 7, 8));

      final record = notifier.state.single;
      expect(record.startDate, DateTime(2026, 7, 10));
      // Bitiş başlangıçtan önce verilemez — başlangıca kelepçelenir
      expect(record.endDate, DateTime(2026, 7, 10));
    });

    test('updateRecordDates null bitiş kaydı yeniden açar', () async {
      final notifier = PeriodRecordsNotifier(service);
      await notifier.addRecord(PeriodRecord(
        id: 'r1',
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 7, 5),
      ));
      await notifier.updateRecordDates('r1', DateTime(2026, 7, 1), null);
      expect(notifier.state.single.isOngoing, isTrue);
    });

    test('reopenRecord "reglim bitti"yi geri alır', () async {
      final notifier = PeriodRecordsNotifier(service);
      final record = await notifier.startPeriod(DateTime(2026, 7, 10));
      await notifier.endPeriod(record.id, DateTime(2026, 7, 14));
      expect(notifier.state.single.isOngoing, isFalse);

      await notifier.reopenRecord(record.id);
      expect(notifier.state.single.isOngoing, isTrue);
    });
  });
}
