import 'dart:convert';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';

class VerifiedEntitlement {
  final bool active;
  final String productId;
  final DateTime? expiresAt;
  const VerifiedEntitlement(this.active, this.productId, this.expiresAt);
}

/// The endpoint must verify with Play/App Store; a store callback alone never
/// grants a new entitlement. No store secrets belong in the mobile binary.
class PurchaseVerifier {
  static const endpoint = String.fromEnvironment('PURCHASE_VERIFY_URL');
  static bool get configured => Uri.tryParse(endpoint)?.scheme == 'https';

  Future<VerifiedEntitlement> verify(PurchaseDetails purchase) async {
    if (!configured) {
      throw StateError('Purchase verification is not configured');
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.postUrl(Uri.parse(endpoint));
      request.headers.contentType = ContentType.json;
      request.followRedirects = false;
      request.write(jsonEncode({
        'platform': Platform.isIOS ? 'ios' : 'android',
        'productId': purchase.productID,
        'purchaseId': purchase.purchaseID,
        'verificationData': purchase.verificationData.serverVerificationData,
      }));
      final response =
          await request.close().timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw StateError('Verification unavailable');
      }
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 10));
      if (body.length > 8192) throw const FormatException('Oversized response');
      final data = jsonDecode(body) as Map<String, dynamic>;
      if (data['productId'] != purchase.productID || data['active'] is! bool) {
        throw const FormatException('Invalid entitlement');
      }
      final expiry = data['expiresAt'] == null
          ? null
          : DateTime.parse(data['expiresAt'] as String).toUtc();
      final lifetime = purchase.productID == 'premium_no_ads';
      if (data['active'] == true &&
          !lifetime &&
          (expiry == null || !expiry.isAfter(DateTime.now().toUtc()))) {
        throw const FormatException('Invalid subscription expiry');
      }
      return VerifiedEntitlement(
          data['active'] as bool, purchase.productID, expiry);
    } finally {
      client.close(force: true);
    }
  }
}
