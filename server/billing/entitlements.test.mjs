import { test } from 'node:test';
import assert from 'node:assert/strict';
import { googleEntitlement as google, appleEntitlement as apple } from './entitlements.mjs';
const now = Date.parse('2026-10-23T00:00:00Z');
const expiryTime = '2026-11-23T00:00:00Z';
for (const state of ['ACTIVE', 'IN_GRACE_PERIOD', 'CANCELED']) {
  test(`Play ${state} unexpired remains entitled`, () => {
    assert.equal(google({ subscriptionState: 'SUBSCRIPTION_STATE_' + state,
      lineItems: [{ productId: 'premium_monthly', expiryTime }] }, 'premium_monthly', now).active, true);
  });
}
for (const state of ['PENDING', 'ON_HOLD', 'PAUSED', 'EXPIRED']) {
  test(`Play ${state} grants no right`, () => {
    assert.equal(google({ subscriptionState: 'SUBSCRIPTION_STATE_' + state,
      lineItems: [{ productId: 'premium_monthly', expiryTime }] }, 'premium_monthly', now).active, false);
  });
}
test('expired, mismatched product and refunded lifetime grants no right', () => {
  assert.equal(google({ subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE', lineItems: [
    { productId: 'premium_yearly', expiryTime }] }, 'premium_monthly', now).active, false);
  assert.equal(google({ subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE', lineItems: [
    { productId: 'premium_monthly', expiryTime: '2020-01-01' }] }, 'premium_monthly', now).active, false);
  assert.equal(google({ purchaseState: 1 }, 'premium_no_ads', now).active, false);
});
test('Apple current, expired, revoked and lifetime', () => {
  const tx = { productId: 'premium_yearly', expiresDate: now + 10000 };
  assert.equal(apple(tx, tx.productId, now).active, true);
  assert.equal(apple({ ...tx, revocationDate: now - 1 }, tx.productId, now).active, false);
  assert.equal(apple({ ...tx, expiresDate: now - 1 }, tx.productId, now).active, false);
  assert.equal(apple({ productId: 'premium_no_ads' }, 'premium_no_ads', now).active, true);
  assert.throws(() => apple(tx, 'premium_monthly', now));
});
