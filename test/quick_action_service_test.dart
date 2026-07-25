import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/services/quick_action_service.dart';

void main() {
  QuickActionDestination resolve({
    String? type = QuickActionService.actionQuickLog,
    bool disguiseResolved = true,
    bool disguised = false,
    bool onboardingCompleted = true,
    bool locked = false,
    bool appResumed = true,
    bool navigatorReady = true,
    bool hasDailyAccess = true,
  }) =>
      resolveQuickAction(
        type: type,
        disguiseResolved: disguiseResolved,
        disguised: disguised,
        onboardingCompleted: onboardingCompleted,
        locked: locked,
        appResumed: appResumed,
        navigatorReady: navigatorReady,
        hasDailyAccess: hasDailyAccess,
      );

  test('kılık kısayol listesini temizler, normal mod iki eylem yayınlar', () {
    expect(
      shortcutItemsFor(
        disguised: true,
        quickLogTitle: 'Hızlı Kayıt',
        todayTitle: 'Bugünü Gör',
      ),
      isEmpty,
    );
    final items = shortcutItemsFor(
      disguised: false,
      quickLogTitle: 'Hızlı Kayıt',
      todayTitle: 'Bugünü Gör',
    );
    expect(
      items.map((item) => item.type),
      [
        QuickActionService.actionQuickLog,
        QuickActionService.actionToday,
      ],
    );
  });

  test('kılık açıkken sağlık kısayolunu reddeder', () {
    expect(resolve(disguised: true), QuickActionDestination.discard);
  });

  test('kilit veya navigator hazır değilken eylemi bekletir', () {
    expect(resolve(locked: true), QuickActionDestination.wait);
    expect(resolve(appResumed: false), QuickActionDestination.wait);
    expect(resolve(navigatorReady: false), QuickActionDestination.wait);
  });

  test('onboarding tamamlanmadan ve bilinmeyen türde eylemi reddeder', () {
    expect(
      resolve(onboardingCompleted: false),
      QuickActionDestination.discard,
    );
    expect(resolve(type: 'unknown'), QuickActionDestination.discard);
  });

  test('bugün ve hızlı kayıt doğru hedefe gider', () {
    expect(
      resolve(type: QuickActionService.actionToday),
      QuickActionDestination.today,
    );
    expect(resolve(), QuickActionDestination.quickLog);
    expect(
      resolve(hasDailyAccess: false),
      QuickActionDestination.paywall,
    );
  });
}
