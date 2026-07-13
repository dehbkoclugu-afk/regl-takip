import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:regl_takip/core/constants/app_constants.dart';
import 'package:regl_takip/models/daily_log.dart';
import 'package:regl_takip/models/enums.dart';
import 'package:regl_takip/models/period_record.dart';
import 'package:regl_takip/models/user_profile.dart';
import 'package:regl_takip/services/hive_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  final key = List<int>.generate(32, (i) => i);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_migration_test');
    Hive.init(tempDir.path);
    HiveService().resetForTesting();
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('plain boxes migrate to encrypted without data loss', () async {
    // 1) Eski kurulum simülasyonu: şifresiz kutulara veri yaz
    final service = HiveService();
    // Adapter kaydı için init edilmemiş servis kullanılamaz — adapterlar
    // migrasyon yolunda da kayıtlı olmalı; init bunu kendisi yapar.
    // Önce düz kutuları elle oluştur:
    // (adapter kaydı gerektiği için önce geçici bir init yapılamaz;
    // adapterları Hive'a kaydetmek için servis private metodu yerine
    // düz open öncesi manuel kayıt gerekir — init içindeki kayıt idempotent)
    // Çözüm: adapterları kaydettirmek için bir kez init edip kutuları
    // kapatmak yerine, burada adapterları Hive API'siyle kaydediyoruz.
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(PeriodRecordAdapter());
    Hive.registerAdapter(SymptomEntryAdapter());
    Hive.registerAdapter(MoodEntryAdapter());
    Hive.registerAdapter(SexualActivityEntryAdapter());
    Hive.registerAdapter(MedicationEntryAdapter());
    Hive.registerAdapter(DailyLogAdapter());
    Hive.registerAdapter(FlowIntensityAdapter());
    Hive.registerAdapter(FlowColorAdapter());
    Hive.registerAdapter(SymptomTypeAdapter());
    Hive.registerAdapter(MoodTypeAdapter());
    Hive.registerAdapter(ProtectionMethodAdapter());
    Hive.registerAdapter(SymptomCategoryAdapter());

    final plainProfile =
        await Hive.openBox<UserProfile>(AppConstants.userProfileBox);
    await plainProfile.put(
        AppConstants.currentUserKey,
        UserProfile(name: 'Migrasyon', lastPeriodStart: DateTime(2026, 7, 1)));

    final plainRecords =
        await Hive.openBox<PeriodRecord>(AppConstants.periodRecordsBox);
    await plainRecords.put(
        'r1', PeriodRecord(id: 'r1', startDate: DateTime(2026, 7, 1)));

    final plainLogs = await Hive.openBox<DailyLog>(AppConstants.dailyLogsBox);
    final log = DailyLog(
      id: 'l1',
      date: DateTime(2026, 7, 2),
      symptoms: [SymptomEntry(type: SymptomType.cramp, severity: 2)],
      waterIntake: 5,
    );
    await plainLogs.put(log.dateKey, log);

    await plainProfile.close();
    await plainRecords.close();
    await plainLogs.close();

    // 2) Şifreli init: migrasyon tetiklenmeli
    await service.init(
        encryptionKey: key, manageHivePath: false, assumeEncrypted: false);

    expect(service.getUserProfile()?.name, 'Migrasyon');
    expect(service.getAllPeriodRecords().single.id, 'r1');
    final restored = service.getAllDailyLogs().single;
    expect(restored.symptoms.single.type, SymptomType.cramp);
    expect(restored.waterIntake, 5);

    // 3) Kutu dosyası artık şifreli: ham baytlarda düz metin olmamalı
    // (düz kutuda "Migrasyon" adı dosyada ASCII olarak görünürdü)
    final boxFile =
        File('${tempDir.path}/${AppConstants.userProfileBox}.hive');
    expect(boxFile.existsSync(), isTrue);
    final raw = String.fromCharCodes(await boxFile.readAsBytes());
    expect(raw.contains('Migrasyon'), isFalse,
        reason: 'kutu dosyası düz metin içeriyor — şifreleme çalışmamış');
  });

  test('second init with encrypted boxes is idempotent', () async {
    final service = HiveService();
    await service.init(
        encryptionKey: key, manageHivePath: false, assumeEncrypted: false);
    await service.saveUserProfile(UserProfile(name: 'Kalıcı'));

    // Uygulama yeniden başlatıldı: kutular kapandı, servis sıfırlandı
    await Hive.close();
    service.resetForTesting();

    await service.init(
        encryptionKey: key, manageHivePath: false, assumeEncrypted: true);
    expect(service.getUserProfile()?.name, 'Kalıcı');
  });
}
