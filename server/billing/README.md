# Store verification service

This service is prepared, not deployed. Never ship the mobile update until its
HTTPS endpoint is configured and sandbox purchases have passed.

1. Deploy the Docker image behind HTTPS with rate limits, request timeouts and
   a small instance cap. Disable request-body logging at the proxy and host.
2. Set `GOOGLE_PACKAGE_NAME`. Grant the runtime Google service account access
   in Play Console to read purchases. Use workload identity / Application Default
   Credentials; never embed service account JSON in Flutter.
3. For Apple, set `APPLE_PRIVATE_KEY` (P8), `APPLE_KEY_ID`, `APPLE_ISSUER_ID`,
   `APPLE_BUNDLE_ID`, `APPLE_APP_ID` and `APPLE_ENVIRONMENT` (`Sandbox` for testing).
   Keep the key in the host's secret manager. The Apple library checks the signed
   transaction certificate chain, bundle, environment and revocation/expiry.
4. Build Flutter with `--dart-define=PURCHASE_VERIFY_URL=https://YOUR_HOST/verify`.
5. Test pending, canceled, active, grace, expired, revoked/refunded, yearly and
   lifetime purchases, reinstall and device change. Do not activate production
   while either platform still uses sandbox credentials.

Unverified new purchases do not grant access or get acknowledged. Existing legacy
paid caches are retained during migration; they are not newly verified rights.
Server verification is required before this migration is production-complete.
The endpoint reads current store state on purchase/restore; RTDN and App Store
Server Notifications should be integrated with an account entitlement database
when the app introduces user accounts. Store tokens are bearer secrets.
