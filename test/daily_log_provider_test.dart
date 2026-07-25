import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:regl_takip/models/enums.dart';
import 'package:regl_takip/models/daily_log.dart';
import 'package:regl_takip/models/period_record.dart';
import 'package:regl_takip/models/user_profile.dart';
import 'package:regl_takip/providers/providers.dart';
import 'package:regl_takip/services/hive_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late HiveService service;
  final key = List<int>.generate(32, (i) => i);
  final day = DateTime(2026, 7, 14);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('daily_log_provider_test');
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

  group('DailyLogNotifier akış alanı', () {
    test('setFlowIntensity(null) kayıtlı akışı siler', () async {
      final notifier = DailyLogNotifier(service);
      await notifier.setFlowIntensity(day, FlowIntensity.heavy);
      expect(notifier.getDailyLog(day)?.flowIntensity, FlowIntensity.heavy);

      // Hızlı kayıt ekranında seçim kaldırıldığında bu yol çağrılır
      await notifier.setFlowIntensity(day, null);
      expect(notifier.getDailyLog(day)?.flowIntensity, isNull);
    });

    test('updateFlow(null) mevcut akışa dokunmaz (kısmi güncelleme)', () async {
      final notifier = DailyLogNotifier(service);
      await notifier.setFlowIntensity(day, FlowIntensity.normal);

      await notifier.updateFlow(day, padChangeCount: 3);
      final log = notifier.getDailyLog(day);
      expect(log?.flowIntensity, FlowIntensity.normal);
      expect(log?.padChangeCount, 3);
    });

    test('diske yazılıyor: yeni notifier aynı değeri okur', () async {
      final notifier = DailyLogNotifier(service);
      await notifier.setFlowIntensity(day, FlowIntensity.light);

      final reloaded = DailyLogNotifier(service);
      expect(reloaded.getDailyLog(day)?.flowIntensity, FlowIntensity.light);
    });
  });

  group('DailyLogNotifier birleşik ölçümler', () {
    test('dört ölçüm grubunu tek günlük kayıtta saklar ve temizler', () async {
      final notifier = DailyLogNotifier(service);
      await notifier.updateMeasurements(
        day,
        waterIntake: 6,
        temperature: 36.6,
        temperatureTime: '07:15',
        weight: 64.2,
        sleepStart: '23:10',
        sleepEnd: '07:00',
        sleepQuality: 4,
      );

      final log = notifier.getDailyLog(day)!;
      expect(log.waterIntake, 6);
      expect(log.temperature, 36.6);
      expect(log.temperatureTime, '07:15');
      expect(log.weight, 64.2);
      expect(log.sleepStart, '23:10');
      expect(log.sleepEnd, '07:00');
      expect(log.sleepQuality, 4);

      await notifier.updateMeasurements(
        day,
        waterIntake: 0,
        temperature: null,
        temperatureTime: null,
        weight: null,
        sleepStart: null,
        sleepEnd: null,
        sleepQuality: null,
      );

      expect(notifier.getDailyLog(day), isNull);
    });
  });

  test('eski ilaç listesi profile yalnız bir kez taşınır', () async {
    await service.saveUserProfile(
      UserProfile(medicationPlanMigrated: false),
    );
    await service.saveDailyLog(
      DailyLog(
        id: 'meds',
        date: day,
        medications: [
          MedicationEntry(name: 'Parol', dose: '500 mg', taken: true),
        ],
      ),
    );

    await service.ensureMedicationPlanMigrated();
    var profile = service.getUserProfile()!;
    expect(profile.medicationPlanMigrated, isTrue);
    expect(profile.medicationPlan.single.name, 'Parol');
    expect(profile.medicationPlan.single.taken, isFalse);

    await service.saveUserProfile(
      profile.copyWith(medicationPlan: const []),
    );
    await service.ensureMedicationPlanMigrated();
    profile = service.getUserProfile()!;
    expect(profile.medicationPlan, isEmpty);
  });
}
