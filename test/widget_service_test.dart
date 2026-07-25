import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/models/enums.dart';
import 'package:regl_takip/services/widget_service.dart';

void main() {
  WidgetPeriodActionDestination resolve({
    String? action = WidgetService.periodStartAction,
    bool disguiseResolved = true,
    bool disguised = false,
    bool onboardingCompleted = true,
    TrackingMode trackingMode = TrackingMode.period,
    bool hasOngoingPeriod = false,
    bool hasRecordToday = false,
    bool locked = false,
    bool appResumed = true,
    bool navigatorReady = true,
  }) =>
      resolveWidgetPeriodAction(
        action: action,
        disguiseResolved: disguiseResolved,
        disguised: disguised,
        onboardingCompleted: onboardingCompleted,
        trackingMode: trackingMode,
        hasOngoingPeriod: hasOngoingPeriod,
        hasRecordToday: hasRecordToday,
        locked: locked,
        appResumed: appResumed,
        navigatorReady: navigatorReady,
      );

  test('widget eylemi yalnız uygun regl ve TTC durumlarında görünür', () {
    expect(
      shouldShowWidgetPeriodAction(
        onboardingCompleted: true,
        disguised: false,
        trackingMode: TrackingMode.period,
        hasOngoingPeriod: false,
      ),
      isTrue,
    );
    expect(
      shouldShowWidgetPeriodAction(
        onboardingCompleted: true,
        disguised: false,
        trackingMode: TrackingMode.ttc,
        hasOngoingPeriod: false,
      ),
      isTrue,
    );
    for (final mode in [TrackingMode.pregnancy, TrackingMode.pill]) {
      expect(
        shouldShowWidgetPeriodAction(
          onboardingCompleted: true,
          disguised: false,
          trackingMode: mode,
          hasOngoingPeriod: false,
        ),
        isFalse,
      );
    }
    expect(
      shouldShowWidgetPeriodAction(
        onboardingCompleted: false,
        disguised: false,
        trackingMode: TrackingMode.period,
        hasOngoingPeriod: false,
      ),
      isFalse,
    );
    expect(
      shouldShowWidgetPeriodAction(
        onboardingCompleted: true,
        disguised: true,
        trackingMode: TrackingMode.period,
        hasOngoingPeriod: false,
      ),
      isFalse,
    );
    expect(
      shouldShowWidgetPeriodAction(
        onboardingCompleted: true,
        disguised: false,
        trackingMode: TrackingMode.period,
        hasOngoingPeriod: true,
      ),
      isFalse,
    );
  });

  test('yalnız regl başlangıç URIsi eyleme dönüşür', () {
    expect(
      widgetActionFromUri(Uri.parse('regltakip://widget/period-start')),
      WidgetService.periodStartAction,
    );
    expect(widgetActionFromUri(Uri.parse('regltakip://widget/open')), isNull);
    expect(widgetActionFromUri(Uri.parse('https://example.com')), isNull);
    expect(widgetActionFromUri(null), isNull);
  });

  test('kilit ve arayüz hazır değilken eylem bekler', () {
    expect(resolve(disguiseResolved: false),
        WidgetPeriodActionDestination.wait);
    expect(resolve(locked: true), WidgetPeriodActionDestination.wait);
    expect(resolve(appResumed: false), WidgetPeriodActionDestination.wait);
    expect(resolve(navigatorReady: false), WidgetPeriodActionDestination.wait);
  });

  test('güncel durum geçersizse eylem veri yazmadan reddedilir', () {
    expect(resolve(disguised: true), WidgetPeriodActionDestination.discard);
    expect(resolve(onboardingCompleted: false),
        WidgetPeriodActionDestination.discard);
    expect(
      resolve(trackingMode: TrackingMode.pregnancy),
      WidgetPeriodActionDestination.discard,
    );
    expect(resolve(hasOngoingPeriod: true),
        WidgetPeriodActionDestination.discard);
    expect(
      resolve(hasRecordToday: true),
      WidgetPeriodActionDestination.discard,
    );
    expect(resolve(action: 'unknown'), WidgetPeriodActionDestination.discard);
  });

  test('uygun regl başlangıç eylemi kayda gider', () {
    expect(resolve(), WidgetPeriodActionDestination.startPeriod);
    expect(
      resolve(trackingMode: TrackingMode.ttc),
      WidgetPeriodActionDestination.startPeriod,
    );
  });
}
