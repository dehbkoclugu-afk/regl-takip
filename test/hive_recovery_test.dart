import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:regl_takip/models/user_profile.dart';
import 'package:regl_takip/services/hive_service.dart';

/// S-1 senaryosu: cihaz/yedek geçişinde Hive dosyaları geri gelir ama
/// AES anahtarı Keystore ile birlikte kaybolur. Yanlış anahtarla açılan
/// kutular çökme döngüsü yerine karantinaya alınıp sıfırdan başlanmalı.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  final keyA = List<int>.generate(32, (i) => i);
  final keyB = List<int>.generate(32, (i) => 255 - i);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_recovery_test');
    Hive.init(tempDir.path);
    HiveService().resetForTesting();
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('yanlış anahtar (yeni cihaz) çökmek yerine temiz başlar', () async {
    final service = HiveService();

    // Eski cihaz: keyA ile şifreli veri yaz
    await service.init(
      encryptionKey: keyA,
      manageHivePath: false,
      assumeEncrypted: true,
    );
    await service.saveUserProfile(
        UserProfile(name: 'Eski Cihaz', onboardingCompleted: true));
    expect(service.getUserProfile()?.name, 'Eski Cihaz');

    // Yeni cihaz: dosyalar duruyor, anahtar farklı (Keystore kayıp).
    // Hive, açılış hatasını hem rethrow eder hem iç completer'ına yazar;
    // completer'ı kimse beklemediği için hata "unhandled async error"
    // olarak zone'a düşer (hive_impl._openBox). Kurtarma init içinde
    // yapıldığından bu sahipsiz kopya guarded zone ile yutulur.
    await Hive.close();
    service.resetForTesting();
    final done = Completer<void>();
    runZonedGuarded(() async {
      await service.init(
        encryptionKey: keyB,
        manageHivePath: false,
        assumeEncrypted: true,
      );
      if (!done.isCompleted) done.complete();
    }, (e, s) {
      if (e is HiveError) return; // beklenen sahipsiz kopya
      if (!done.isCompleted) done.completeError(e, s);
    });
    await done.future;

    // Çökmedi, sıfırdan başladı ve bunu UI'a bildirecek bayrağı bıraktı
    expect(service.dataResetPerformed, isTrue);
    expect(service.getUserProfile(), isNull);
    expect(service.getAllPeriodRecords(), isEmpty);

    // Temiz başlangıç yazılabilir durumda
    await service.saveUserProfile(UserProfile(name: 'Yeni Cihaz'));
    expect(service.getUserProfile()?.name, 'Yeni Cihaz');
  });

  test('bayrak kaybı (anahtar sağlam) veri KAYBETMEZ', () async {
    final service = HiveService();

    // Şifreli kurulum
    await service.init(
      encryptionKey: keyA,
      manageHivePath: false,
      assumeEncrypted: true,
    );
    await service.saveUserProfile(
        UserProfile(name: 'Bayrak Kaybı', onboardingCompleted: true));

    // Secure-storage bayrağı kayıp: init şifresiz kurulum sanıp migrasyon
    // yoluna girer, düz açma patlar — ama anahtar doğru: veri yerinde.
    // (Hive'ın sahipsiz iç completer hatası için guarded zone, bkz. üst test)
    await Hive.close();
    service.resetForTesting();
    final done = Completer<void>();
    runZonedGuarded(() async {
      await service.init(
        encryptionKey: keyA,
        manageHivePath: false,
        assumeEncrypted: false, // bayrak kayıp
      );
      if (!done.isCompleted) done.complete();
    }, (e, s) {
      if (e is HiveError) return;
      if (!done.isCompleted) done.completeError(e, s);
    });
    await done.future;

    expect(service.dataResetPerformed, isFalse);
    expect(service.getUserProfile()?.name, 'Bayrak Kaybı');
  });

  test('doğru anahtarla normal açılış bayrak bırakmaz', () async {
    final service = HiveService();
    await service.init(
      encryptionKey: keyA,
      manageHivePath: false,
      assumeEncrypted: true,
    );
    expect(service.dataResetPerformed, isFalse);
  });
}
