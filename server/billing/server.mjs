import { createServer } from 'node:http';
import { readFileSync } from 'node:fs';
import { GoogleAuth } from 'google-auth-library';
import { AppStoreServerAPIClient, SignedDataVerifier, Environment } from '@apple/app-store-server-library';
import { products, googleEntitlement, appleEntitlement } from './entitlements.mjs';

const env = process.env;
const google = new GoogleAuth({ scopes: ['https://www.googleapis.com/auth/androidpublisher'] });
let apple;
function appleClient() {
  if (apple) return apple;
  const environment = env.APPLE_ENVIRONMENT === 'Sandbox' ? Environment.SANDBOX : Environment.PRODUCTION;
  const roots = [readFileSync(env.APPLE_ROOT_CERT ?? new URL('./AppleRootCA-G3.cer', import.meta.url))];
  apple = {
    client: new AppStoreServerAPIClient(env.APPLE_PRIVATE_KEY, env.APPLE_KEY_ID,
      env.APPLE_ISSUER_ID, env.APPLE_BUNDLE_ID, environment),
    verifier: new SignedDataVerifier(roots, true, environment, env.APPLE_BUNDLE_ID,
      environment === Environment.PRODUCTION ? Number(env.APPLE_APP_ID) : undefined),
  };
  return apple;
}
async function verify(input) {
  if (!products.has(input.productId)) throw Error('Unknown product');
  if (input.platform === 'android') {
    if (!env.GOOGLE_PACKAGE_NAME || typeof input.verificationData !== 'string' ||
        input.verificationData.length > 16000) throw Error('Invalid request');
    const auth = await google.getClient();
    const prefix = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/' +
      encodeURIComponent(env.GOOGLE_PACKAGE_NAME) + '/purchases/';
    const token = encodeURIComponent(input.verificationData);
    const url = input.productId === 'premium_no_ads'
      ? prefix + 'products/' + encodeURIComponent(input.productId) + '/tokens/' + token
      : prefix + 'subscriptionsv2/tokens/' + token;
    const result = await auth.request({ url, timeout: 15000 });
    return googleEntitlement(result.data, input.productId);
  }
  if (input.platform === 'ios') {
    if (!/^\d{1,40}$/.test(input.purchaseId ?? '')) throw Error('Invalid transaction');
    const { client, verifier } = appleClient();
    const response = await client.getTransactionInfo(input.purchaseId);
    const transaction = await verifier.verifyAndDecodeTransaction(response.signedTransactionInfo);
    if (transaction.bundleId !== env.APPLE_BUNDLE_ID) throw Error('Wrong bundle');
    if (input.productId === 'premium_no_ads') return appleEntitlement(transaction, input.productId);
    const status = await client.getAllSubscriptionStatuses(transaction.originalTransactionId);
    const matches = [];
    for (const group of status.data ?? []) {
      for (const item of group.lastTransactions ?? []) {
        if (![1, 4].includes(item.status)) continue;
        const current = await verifier.verifyAndDecodeTransaction(item.signedTransactionInfo);
        if (current.productId !== input.productId || current.bundleId !== env.APPLE_BUNDLE_ID) continue;
        let entitlement = appleEntitlement(current, input.productId);
        if (item.status === 4 && item.signedRenewalInfo) {
          const renewal = await verifier.verifyAndDecodeRenewalInfo(item.signedRenewalInfo);
          if (renewal.gracePeriodExpiresDate > Date.now() && !current.revocationDate) {
            entitlement = { productId: input.productId, active: true,
              expiresAt: new Date(renewal.gracePeriodExpiresDate).toISOString() };
          }
        }
        matches.push(entitlement);
      }
    }
    return matches.find(x => x.active) ?? { productId: input.productId, active: false, expiresAt: null };
  }
  throw Error('Invalid platform');
}
createServer(async (request, response) => {
  response.setHeader('Content-Type', 'application/json');
  response.setHeader('Cache-Control', 'no-store');
  if (request.url !== '/verify' || request.method !== 'POST') {
    response.writeHead(404).end('{}'); return;
  }
  try {
    let size = 0; const chunks = [];
    for await (const chunk of request) {
      size += chunk.length;
      if (size > 256 * 1024) { response.writeHead(413).end('{}'); return; }
      chunks.push(chunk);
    }
    const result = await verify(JSON.parse(Buffer.concat(chunks).toString('utf8')));
    response.writeHead(200).end(JSON.stringify(result));
  } catch (_) {
    // Never log tokens, receipts, credentials or store response bodies.
    response.writeHead(503).end(JSON.stringify({ error: 'verification_unavailable' }));
  }
}).listen(Number(env.PORT ?? 8080));
