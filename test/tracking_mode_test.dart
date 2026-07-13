import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/utils/cycle_utils.dart';
import 'package:regl_takip/models/enums.dart';
import 'package:regl_takip/models/user_profile.dart';

void main() {
  group('pregnancyWeek', () {
    test('week 1 on start day and within first 6 days', () {
      final today = DateTime.now();
      expect(CycleUtils.pregnancyWeek(today), 1);
      expect(
        CycleUtils.pregnancyWeek(
            today.subtract(const Duration(days: 6))),
        1,
      );
    });

    test('week increments every 7 days', () {
      final today = DateTime.now();
      expect(
        CycleUtils.pregnancyWeek(
            today.subtract(const Duration(days: 7))),
        2,
      );
      expect(
        CycleUtils.pregnancyWeek(
            today.subtract(const Duration(days: 70))),
        11,
      );
    });

    test('future date clamps to week 1, long past clamps to 42', () {
      final today = DateTime.now();
      expect(
        CycleUtils.pregnancyWeek(today.add(const Duration(days: 10))),
        1,
      );
      expect(
        CycleUtils.pregnancyWeek(
            today.subtract(const Duration(days: 500))),
        42,
      );
    });
  });

  group('pillDayInPack', () {
    test('day 1 on pack start', () {
      expect(CycleUtils.pillDayInPack(DateTime.now()), 1);
    });

    test('active days 1-21, break days 22-28, wraps to next pack', () {
      final today = DateTime.now();
      // 20 gün önce başladı → gün 21 (son aktif hap)
      final day21Start = today.subtract(const Duration(days: 20));
      expect(CycleUtils.pillDayInPack(day21Start), 21);
      expect(CycleUtils.isPillBreakDay(day21Start), isFalse);

      // 21 gün önce → gün 22 (ara haftanın ilki)
      final day22Start = today.subtract(const Duration(days: 21));
      expect(CycleUtils.pillDayInPack(day22Start), 22);
      expect(CycleUtils.isPillBreakDay(day22Start), isTrue);

      // 27 gün önce → gün 28 (ara haftanın sonu)
      final day28Start = today.subtract(const Duration(days: 27));
      expect(CycleUtils.pillDayInPack(day28Start), 28);
      expect(CycleUtils.isPillBreakDay(day28Start), isTrue);

      // 28 gün önce → yeni paket, gün 1
      final newPackStart = today.subtract(const Duration(days: 28));
      expect(CycleUtils.pillDayInPack(newPackStart), 1);
      expect(CycleUtils.isPillBreakDay(newPackStart), isFalse);
    });
  });

  group('fertilityLevelForDay', () {
    // Döngü 28: ovülasyon günü 15, pencere 10-16
    test('high on ovulation day and 2 days before', () {
      expect(CycleUtils.fertilityLevelForDay(13, 28), FertilityLevel.high);
      expect(CycleUtils.fertilityLevelForDay(14, 28), FertilityLevel.high);
      expect(CycleUtils.fertilityLevelForDay(15, 28), FertilityLevel.high);
    });

    test('medium on remaining fertile window days', () {
      expect(CycleUtils.fertilityLevelForDay(10, 28), FertilityLevel.medium);
      expect(CycleUtils.fertilityLevelForDay(12, 28), FertilityLevel.medium);
      expect(CycleUtils.fertilityLevelForDay(16, 28), FertilityLevel.medium);
    });

    test('low outside the window', () {
      expect(CycleUtils.fertilityLevelForDay(1, 28), FertilityLevel.low);
      expect(CycleUtils.fertilityLevelForDay(9, 28), FertilityLevel.low);
      expect(CycleUtils.fertilityLevelForDay(17, 28), FertilityLevel.low);
      expect(CycleUtils.fertilityLevelForDay(28, 28), FertilityLevel.low);
    });
  });

  group('UserProfile tracking mode JSON', () {
    test('round-trips mode and mode dates', () {
      final profile = UserProfile(
        trackingMode: TrackingMode.pregnancy,
        pregnancyStartDate: DateTime(2026, 5, 1),
        pillPackStartDate: DateTime(2026, 7, 1),
      );
      final restored = UserProfile.fromJson(profile.toJson());
      expect(restored.trackingMode, TrackingMode.pregnancy);
      expect(restored.pregnancyStartDate, DateTime(2026, 5, 1));
      expect(restored.pillPackStartDate, DateTime(2026, 7, 1));
    });

    test('unknown mode from future backup falls back to period', () {
      final restored = UserProfile.fromJson({'trackingMode': 'menopause'});
      expect(restored.trackingMode, TrackingMode.period);
    });

    test('old backups without mode default to period', () {
      final restored = UserProfile.fromJson({'name': 'eski'});
      expect(restored.trackingMode, TrackingMode.period);
    });
  });
}
