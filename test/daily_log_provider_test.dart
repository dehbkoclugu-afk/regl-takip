import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:regl_takip/models/enums.dart';
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
}
