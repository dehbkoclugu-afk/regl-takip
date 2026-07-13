import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../core/utils/cycle_utils.dart';
import '../models/enums.dart';
import '../models/period_record.dart';
import '../models/user_profile.dart';

/// Android ana ekran widget'ını besler. Metinler Dart tarafında
/// lokalize edilip SharedPreferences üzerinden native provider'a geçer
/// (native tarafta l10n altyapısı yok).
class WidgetService {
  static const _androidProvider = 'CycleWidgetProvider';

  static const _strings = {
    'tr': {
      'day': 'Gün',
      'daysLeft': 'gün kaldı',
      'today': 'Bugün!',
      'week': 'hafta',
      'pill': 'Hap',
      'breakWeek': 'Ara hafta',
    },
    'en': {
      'day': 'Day',
      'daysLeft': 'days left',
      'today': 'Today!',
      'week': 'Week',
      'pill': 'Pill',
      'breakWeek': 'Break week',
    },
  };

  static String _t(String locale, String key) =>
      _strings[locale]?[key] ?? _strings['en']![key]!;

  /// Widget verisini günceller. Android dışında no-op.
  static Future<void> update(
    UserProfile? profile,
    List<PeriodRecord> records,
  ) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      final locale = profile?.language ?? 'tr';
      String line1 = 'Regl Takip';
      String line2 = '';

      if (profile != null) {
        switch (profile.trackingMode) {
          case TrackingMode.pregnancy:
            if (profile.pregnancyStartDate != null) {
              final week =
                  CycleUtils.pregnancyWeek(profile.pregnancyStartDate!);
              line1 = locale == 'tr'
                  ? '$week. ${_t(locale, 'week')}'
                  : '${_t(locale, 'week')} $week';
            }
            break;
          case TrackingMode.pill:
            if (profile.pillPackStartDate != null) {
              final day =
                  CycleUtils.pillDayInPack(profile.pillPackStartDate!);
              line1 = day > 21
                  ? '${_t(locale, 'breakWeek')} ${day - 21}/7'
                  : '${_t(locale, 'pill')} $day/21';
            }
            break;
          case TrackingMode.ttc:
          case TrackingMode.period:
            if (profile.lastPeriodStart != null) {
              final cycleLen = CycleUtils.effectiveCycleLength(
                profile.averageCycleLength,
                records,
                smartEnabled: profile.smartPredictionEnabled,
              );
              final day = CycleUtils.wrappedCycleDay(
                CycleUtils.currentCycleDay(profile.lastPeriodStart!),
                cycleLen,
              );
              final daysLeft = CycleUtils.daysUntilNextPeriod(
                  profile.lastPeriodStart!, cycleLen);
              line1 = '${_t(locale, 'day')} $day';
              line2 = daysLeft > 0
                  ? '$daysLeft ${_t(locale, 'daysLeft')}'
                  : _t(locale, 'today');
            }
            break;
        }
      }

      await HomeWidget.saveWidgetData<String>('line1', line1);
      await HomeWidget.saveWidgetData<String>('line2', line2);
      await HomeWidget.updateWidget(androidName: _androidProvider);
    } catch (e) {
      // Widget güncellemesi asla akışı bozmasın
      debugPrint('[WIDGET] update failed: $e');
    }
  }
}
