import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/constants/app_constants.dart';
import 'package:regl_takip/core/utils/cycle_utils.dart';

void main() {
  group('hap paketi', () {
    test('etkin dönemin ilk günü ara sayılmaz', () {
      expect(CycleUtils.pillIsBreak(1), isFalse);
    });

    test('etkin dönemin son günü ara sayılmaz', () {
      expect(CycleUtils.pillIsBreak(AppConstants.pillActiveDays), isFalse);
    });

    test('22. gün ara dönemin ilk günü', () {
      expect(
          CycleUtils.pillIsBreak(AppConstants.pillActiveDays + 1), isTrue);
    });

    test('paketin son günü ara sayılır', () {
      expect(CycleUtils.pillIsBreak(AppConstants.pillPackDays), isTrue);
    });

    test('ilk günde araya 21 gün var', () {
      expect(CycleUtils.pillDaysUntilBreak(1), AppConstants.pillActiveDays);
    });

    test('21. günde araya 1 gün var', () {
      expect(CycleUtils.pillDaysUntilBreak(AppConstants.pillActiveDays), 1);
    });

    test('ara dönemde "araya kalan" sorulmaz', () {
      expect(CycleUtils.pillDaysUntilBreak(25), 0);
    });

    test('ara dönemin ilk gününde yeni pakete 7 gün var', () {
      expect(
        CycleUtils.pillDaysUntilNewPack(AppConstants.pillActiveDays + 1),
        7,
      );
    });

    test('paketin son gününde yeni pakete 1 gün var', () {
      expect(
        CycleUtils.pillDaysUntilNewPack(AppConstants.pillPackDays),
        1,
      );
    });

    test('etkin dönemde "yeni pakete kalan" sorulmaz', () {
      expect(CycleUtils.pillDaysUntilNewPack(10), 0);
    });
  });

  group('gebelik testi günü', () {
    test('ovülasyondan 12 gün sonra', () {
      expect(
        CycleUtils.earliestPregnancyTestDay(DateTime(2026, 3, 10)),
        DateTime(2026, 3, 22),
      );
    });

    test('ay sınırını aşar', () {
      expect(
        CycleUtils.earliestPregnancyTestDay(DateTime(2026, 3, 25)),
        DateTime(2026, 4, 6),
      );
    });

    test('yıl sınırını aşar', () {
      expect(
        CycleUtils.earliestPregnancyTestDay(DateTime(2026, 12, 25)),
        DateTime(2027, 1, 6),
      );
    });

    test('saat bileşeni günü kaydırmaz', () {
      final result =
          CycleUtils.earliestPregnancyTestDay(DateTime(2026, 3, 10, 23, 45));
      expect(result.year, 2026);
      expect(result.month, 3);
      expect(result.day, 22);
    });
  });
}
