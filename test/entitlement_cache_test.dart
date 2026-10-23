import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:regl_takip/services/entitlement_cache.dart';
import 'package:regl_takip/services/purchase_verifier.dart';

void main() {
  final now = DateTime.utc(2026, 10, 23);
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('expired subscription cannot revoke restored lifetime entitlement',
      () async {
    final prefs = await SharedPreferences.getInstance();
    await EntitlementCache.save(
        prefs, const VerifiedEntitlement(true, 'premium_no_ads', null), now);
    expect(
        await EntitlementCache.save(
            prefs, VerifiedEntitlement(false, 'premium_monthly', now), now),
        isTrue);
    expect(EntitlementCache.active(prefs, now.add(const Duration(days: 400))),
        isTrue);
    expect(
        await EntitlementCache.save(prefs,
            const VerifiedEntitlement(false, 'premium_no_ads', null), now),
        isFalse);
  });
  test('expiry is honored offline and independent subscriptions survive',
      () async {
    final prefs = await SharedPreferences.getInstance();
    await EntitlementCache.save(
        prefs,
        VerifiedEntitlement(
            true, 'premium_monthly', now.add(const Duration(days: 1))),
        now);
    expect(EntitlementCache.active(prefs, now.add(const Duration(days: 2))),
        isFalse);
    await EntitlementCache.save(
        prefs,
        VerifiedEntitlement(
            true, 'premium_yearly', now.add(const Duration(days: 365))),
        now);
    expect(
        await EntitlementCache.save(
            prefs, VerifiedEntitlement(false, 'premium_monthly', now), now),
        isTrue);
  });
  test('legacy paid cache is retained until authoritative migration', () async {
    SharedPreferences.setMockInitialValues({'premium_active': true});
    final prefs = await SharedPreferences.getInstance();
    expect(EntitlementCache.active(prefs, now), isTrue);
  });
}
