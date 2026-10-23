import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'purchase_verifier.dart';

/// Keep products separate: an expired subscription must not revoke a lifetime
/// purchase or another still-active subscription restored in the same batch.
class EntitlementCache {
  static const _key = 'premium_entitlements_v1';

  static Map<String, dynamic> _read(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static bool active(SharedPreferences prefs, DateTime now) {
    if (!prefs.containsKey(_key)) {
      final expiry = prefs.getInt('premium_verified_expiry');
      return (prefs.getBool('premium_active') ?? false) &&
          (expiry == null || now.millisecondsSinceEpoch < expiry);
    }
    return _read(prefs).values.any((value) {
      final entry = value as Map<String, dynamic>;
      final expiry = entry['expiresAt'] as int?;
      return entry['active'] == true &&
          (expiry == null || now.millisecondsSinceEpoch < expiry);
    });
  }

  static Future<bool> save(SharedPreferences prefs,
      VerifiedEntitlement entitlement, DateTime now) async {
    final entries = _read(prefs);
    entries[entitlement.productId] = {
      'active': entitlement.active,
      'expiresAt': entitlement.expiresAt?.millisecondsSinceEpoch,
    };
    await prefs.setString(_key, jsonEncode(entries));
    return active(prefs, now);
  }
}
