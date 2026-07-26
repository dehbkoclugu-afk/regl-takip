import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/services/ad_service.dart';

void main() {
  final now = DateTime(2026, 7, 24, 12);
  final longAgo = now.subtract(const Duration(days: 90));

  group('kayıt sonrası reklam sıklığı', () {
    test('kurulumdan hemen sonra gösterilmez', () {
      expect(
        AdService.shouldShowOpenAd(
          now: now,
          installedAt: now.subtract(const Duration(hours: 2)),
          lastShownAt: null,
        ),
        isFalse,
      );
    });

    test('bekleme süresi dolduysa ve hiç gösterilmediyse gösterilir', () {
      expect(
        AdService.shouldShowOpenAd(
          now: now,
          installedAt: longAgo,
          lastShownAt: null,
        ),
        isTrue,
      );
    });

    test('aynı gün ikinci kayıtta gösterilmez', () {
      expect(
        AdService.shouldShowOpenAd(
          now: now,
          installedAt: longAgo,
          lastShownAt: now.subtract(const Duration(hours: 3)),
        ),
        isFalse,
      );
    });

    test('aralığın bir dakika altı hâlâ engelli', () {
      expect(
        AdService.shouldShowOpenAd(
          now: now,
          installedAt: longAgo,
          lastShownAt: now
              .subtract(AdService.openAdInterval)
              .add(const Duration(minutes: 1)),
        ),
        isFalse,
      );
    });

    test('aralık dolduğunda yeniden gösterilir', () {
      expect(
        AdService.shouldShowOpenAd(
          now: now,
          installedAt: longAgo,
          lastShownAt: now.subtract(AdService.openAdInterval),
        ),
        isTrue,
      );
    });

    test('bekleme süresi, geçmiş gösterimden bağımsız olarak engeller', () {
      // Yeniden kurulum: eski damga duruyor ama kurulum yeni
      expect(
        AdService.shouldShowOpenAd(
          now: now,
          installedAt: now.subtract(const Duration(hours: 1)),
          lastShownAt: longAgo,
        ),
        isFalse,
      );
    });
  });

  test('başarılı kayıt olayı uygulama köküne ulaşır', () {
    final before = AdService.recordSavedRevision.value;
    AdService.notifyRecordSaved();
    expect(AdService.recordSavedRevision.value, before + 1);
  });
}
