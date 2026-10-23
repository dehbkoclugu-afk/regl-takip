import 'package:shared_preferences/shared_preferences.dart';

enum UsageEvent {
  appOpen,
  onboardingCompleted,
  trackingAction,
  paywallView,
  verifiedPurchase
}

/// Explicit opt-in, aggregate counters only. No date, identity or health payload
/// can enter the API. Counters stay on this device; no analytics SDK is loaded.
class UsageMetrics {
  static const preferenceKey = 'usage_counts_opt_in';
  static Future<void> _queue = Future.value();
  static Future<bool> enabled() async =>
      (await SharedPreferences.getInstance()).getBool(preferenceKey) ?? false;
  static Future<void> setEnabled(bool enabled) => _schedule(() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(preferenceKey, enabled);
        if (!enabled) {
          for (final event in UsageEvent.values) {
            await prefs.remove('usage_count_${event.name}');
          }
        }
      });

  static Future<void> record(UsageEvent event) => _schedule(() async {
        final prefs = await SharedPreferences.getInstance();
        if (!(prefs.getBool(preferenceKey) ?? false)) return;
        final key = 'usage_count_${event.name}';
        await prefs.setInt(key, (prefs.getInt(key) ?? 0) + 1);
      });

  static Future<void> _schedule(Future<void> Function() action) {
    final next = _queue.then((_) => action());
    _queue = next.catchError((Object _) {});
    return next;
  }

  static Future<Map<String, int>> counts() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(preferenceKey) ?? false)) return {};
    return {
      for (final e in UsageEvent.values)
        e.name: prefs.getInt('usage_count_${e.name}') ?? 0
    };
  }
}
