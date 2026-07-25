import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/services/privacy_screen_service.dart';

void main() {
  final now = DateTime(2026, 7, 24, 12);

  group('kilit gecikmesi', () {
    test('soğuk açılışta her zaman kilitlenir', () {
      // backgroundedAt null: uygulama hiç açık kalmadı, gecikme tanınmamalı
      expect(
        LockTimeout.shouldLock(
          now: now,
          backgroundedAt: null,
          timeoutSeconds: 900,
        ),
        isTrue,
      );
    });

    test('gecikme kapalıyken hemen kilitlenir (eski davranış)', () {
      expect(
        LockTimeout.shouldLock(
          now: now,
          backgroundedAt: now.subtract(const Duration(seconds: 1)),
          timeoutSeconds: 0,
        ),
        isTrue,
      );
    });

    test('gecikme dolmadan kilitlenmez', () {
      expect(
        LockTimeout.shouldLock(
          now: now,
          backgroundedAt: now.subtract(const Duration(seconds: 30)),
          timeoutSeconds: 60,
        ),
        isFalse,
      );
    });

    test('gecikme tam dolduğunda kilitlenir', () {
      expect(
        LockTimeout.shouldLock(
          now: now,
          backgroundedAt: now.subtract(const Duration(seconds: 60)),
          timeoutSeconds: 60,
        ),
        isTrue,
      );
    });

    test('uzun aradan sonra kilitlenir', () {
      expect(
        LockTimeout.shouldLock(
          now: now,
          backgroundedAt: now.subtract(const Duration(hours: 3)),
          timeoutSeconds: 900,
        ),
        isTrue,
      );
    });

    test('negatif gecikme hemen kilitlemek sayılır', () {
      // Bozuk bir tercih güvenliği gevşetmemeli
      expect(
        LockTimeout.shouldLock(
          now: now,
          backgroundedAt: now,
          timeoutSeconds: -5,
        ),
        isTrue,
      );
    });
  });

  group('seçenekler', () {
    test('varsayılan hemen kilitle', () {
      expect(LockTimeout.defaultSeconds, 0);
    });

    test('sunulan seçenekler arasında varsayılan da var', () {
      expect(LockTimeout.options, contains(LockTimeout.defaultSeconds));
    });
  });
}
