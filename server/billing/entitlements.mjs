export const products = new Set(['premium_monthly', 'premium_yearly', 'premium_no_ads']);
export function googleEntitlement(data, productId, now = Date.now()) {
  if (!products.has(productId)) throw Error('Unknown product');
  if (productId === 'premium_no_ads') {
    return { productId, active: data.purchaseState === 0, expiresAt: null };
  }
  const states = new Set(['SUBSCRIPTION_STATE_ACTIVE', 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD', 'SUBSCRIPTION_STATE_CANCELED']);
  const lines = (data.lineItems ?? []).filter(x => x.productId === productId);
  const expiry = Math.max(0, ...lines.map(x => Date.parse(x.expiryTime) || 0));
  return { productId, active: states.has(data.subscriptionState) && expiry > now,
    expiresAt: expiry ? new Date(expiry).toISOString() : null };
}
export function appleEntitlement(transaction, productId, now = Date.now()) {
  if (!products.has(productId) || transaction.productId !== productId) throw Error('Wrong product');
  const expires = transaction.expiresDate;
  return { productId, active: !transaction.revocationDate &&
    (productId === 'premium_no_ads' || (Number.isFinite(expires) && expires > now)),
    expiresAt: expires ? new Date(expires).toISOString() : null };
}
