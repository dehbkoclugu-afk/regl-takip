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
    // Temizlik adımı testi düşürmemeli. Test edilen kod bozuk kutuları
    // karantinaya alırken dosyaları taşıyor/siliyor; Hive kapanışta kendi
    // kilit dosyasını bulamayınca PathNotFoundException atıyor. Doğrulama o
    // noktada çoktan bitmiş oluyor, yani bu hata testin sonucu hakkında
    // hiçbir şey söylemiyor — CI'da rastgele düşmelere yol açıyordu.
    try {
      await Hive.close();
    } on FileSystemException {
      // karantina dosyaları zaten kaldırmış
    }
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('wrong key preserves all original ciphertext and fails closed',
      () async {
    final service = HiveService();
    await service.init(
        encryptionKey: keyA, manageHivePath: false, assumeEncrypted: true);
    await service.saveUserProfile(UserProfile(name: 'Original'));
    final path = service.profileStoragePath!;
    await Hive.close();
    service.resetForTesting();
    final before = await File(path).readAsBytes();
    final done = Completer<void>();
    runZonedGuarded(() async {
      try {
        await service.init(
            encryptionKey: keyB, manageHivePath: false, assumeEncrypted: true);
        done.completeError(StateError('Wrong key was accepted'));
      } catch (_) {
        done.complete();
      }
    }, (e, stack) {
      if (e is! HiveError && !done.isCompleted) done.completeError(e, stack);
    });
    await done.future;
    expect(service.isInitialized, false);
    expect(await File(path).readAsBytes(), before);
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
