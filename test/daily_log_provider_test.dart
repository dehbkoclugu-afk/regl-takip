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
    test('ruh hali silinince not günlük Notlar alanına taşınır', () async {
      final notifier = DailyLogNotifier(service);
      await notifier.updateNotes(day, 'Existing daily note');
      await notifier.updateMood(
        day,
        MoodEntry(type: MoodType.happy, note: 'Mood note'),
      );
      await notifier.removeMoodKeepingNote(day, 'Mood note');
      final reloaded = DailyLogNotifier(service).getDailyLog(day)!;
      expect(reloaded.mood, isNull);
      expect(reloaded.notes, 'Existing daily note\nMood note');
      await notifier.removeMoodKeepingNote(day, 'Mood note');
      expect(notifier.getDailyLog(day)?.notes, 'Existing daily note\nMood note');
    });
    test('hızlı kayıt ruh hali notunu ve diğer ölçümleri korur', () async {
      final notifier = DailyLogNotifier(service);
      await notifier.updateMood(
        day,
        MoodEntry(type: MoodType.happy, note: 'Keep this note'),
      );
      await notifier.updateWeight(day, 62.5);
      await notifier.updateQuickLog(
        day,
        flow: FlowIntensity.light,
        mood: MoodType.happy,
        symptoms: [SymptomEntry(type: SymptomType.cramp, severity: 2)],
        notes: 'Daily note',
      );
      final reloaded = DailyLogNotifier(service).getDailyLog(day)!;
      expect(reloaded.mood?.note, 'Keep this note');
      expect(reloaded.weight, 62.5);
      expect(reloaded.flowIntensity, FlowIntensity.light);
      expect(reloaded.symptoms.single.severity, 2);
      expect(reloaded.notes, 'Daily note');
    });
    test('hızlı kayıt ruh hali kaldırınca notu günlük Notlar alanına taşır', () async {
      final notifier = DailyLogNotifier(service);
      await notifier.updateMood(
        day,
        MoodEntry(type: MoodType.happy, note: 'Mood note'),
      );
      await notifier.updateQuickLog(
        day,
        flow: null,
        mood: null,
        symptoms: const [],
        notes: 'Daily note',
      );
      final reloaded = DailyLogNotifier(service).getDailyLog(day)!;
      expect(reloaded.mood, isNull);
      expect(reloaded.notes, 'Daily note\nMood note');
    });
    test('simultaneous partial updates retain both fields', () async {
      final notifier = DailyLogNotifier(service);
      await Future.wait([
        notifier.updateWater(day, 6),
        notifier.updateNotes(day, 'Preserved note'),
        notifier.updateWeight(day, 62.5),
      ]);
      final reloaded = DailyLogNotifier(service).getDailyLog(day)!;
      expect(reloaded.waterIntake, 6);
      expect(reloaded.notes, 'Preserved note');
      expect(reloaded.weight, 62.5);
    });
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

    test('uykuyu silmek diğer ölçümleri korur; son alanı silince günü kaldırır', () async {
      final notifier = DailyLogNotifier(service);
      await notifier.updateMeasurements(
        day,
        waterIntake: 0,
        temperature: null,
        temperatureTime: null,
        weight: 64.2,
        sleepStart: '23:10',
        sleepEnd: '07:00',
        sleepQuality: 4,
      );

      await notifier.clearSleep(day);
      final remaining = notifier.getDailyLog(day)!;
      expect(remaining.weight, 64.2);
      expect(remaining.sleepStart, isNull);
      expect(remaining.sleepEnd, isNull);
      expect(remaining.sleepQuality, isNull);
      expect(DailyLogNotifier(service).getDailyLog(day)?.weight, 64.2);

      await notifier.updateMeasurements(
        day,
        changedFields: {'weight'},
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
