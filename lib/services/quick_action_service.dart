import 'package:flutter/foundation.dart';
import 'package:quick_actions/quick_actions.dart';

enum QuickActionDestination {
  wait,
  discard,
  today,
  quickLog,
  paywall,
}

List<ShortcutItem> shortcutItemsFor({
  required bool disguised,
  required String quickLogTitle,
  required String todayTitle,
}) =>
    disguised
        ? const []
        : [
            ShortcutItem(
              type: QuickActionService.actionQuickLog,
              localizedTitle: quickLogTitle,
            ),
            ShortcutItem(
              type: QuickActionService.actionToday,
              localizedTitle: todayTitle,
            ),
          ];

QuickActionDestination resolveQuickAction({
  required String? type,
  required bool disguiseResolved,
  required bool disguised,
  required bool onboardingCompleted,
  required bool locked,
  required bool appResumed,
  required bool navigatorReady,
  required bool hasDailyAccess,
}) {
  if (type == null) return QuickActionDestination.discard;
  if (!disguiseResolved || locked || !appResumed || !navigatorReady) {
    return QuickActionDestination.wait;
  }
  if (disguised || !onboardingCompleted) {
    return QuickActionDestination.discard;
  }
  return switch (type) {
    QuickActionService.actionToday => QuickActionDestination.today,
    QuickActionService.actionQuickLog => hasDailyAccess
        ? QuickActionDestination.quickLog
        : QuickActionDestination.paywall,
    _ => QuickActionDestination.discard,
  };
}

class QuickActionService {
  static final QuickActionService _instance = QuickActionService._internal();
  factory QuickActionService() => _instance;
  QuickActionService._internal();

  static const String actionQuickLog = 'quick_log';
  static const String actionToday = 'today';

  final QuickActions _plugin = const QuickActions();
  final ValueNotifier<String?> pendingAction = ValueNotifier(null);
  bool _initialized = false;

  bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> init() async {
    if (_initialized || !_isSupported) return;
    try {
      await _plugin.initialize((type) => pendingAction.value = type);
      _initialized = true;
    } catch (e) {
      debugPrint('[QUICK_ACTION] init failed: $e');
    }
  }

  Future<void> sync({
    required bool disguised,
    required String quickLogTitle,
    required String todayTitle,
  }) async {
    if (!_isSupported) return;
    try {
      final items = shortcutItemsFor(
        disguised: disguised,
        quickLogTitle: quickLogTitle,
        todayTitle: todayTitle,
      );
      if (items.isEmpty) {
        await _plugin.clearShortcutItems();
        return;
      }
      await _plugin.setShortcutItems(items);
    } catch (e) {
      debugPrint('[QUICK_ACTION] sync failed: $e');
    }
  }
}
