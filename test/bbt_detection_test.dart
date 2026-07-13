import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/utils/cycle_utils.dart';

MapEntry<DateTime, double> t(int day, double temp) =>
    MapEntry(DateTime(2026, 7, day), temp);

void main() {
  group('detectOvulationFromBBT', () {
    test('too few readings returns null', () {
      final temps = [for (int d = 1; d <= 8; d++) t(d, 36.4)];
      expect(CycleUtils.detectOvulationFromBBT(temps), isNull);
    });

    test('flat curve returns null', () {
      final temps = [for (int d = 1; d <= 14; d++) t(d, 36.4)];
      expect(CycleUtils.detectOvulationFromBBT(temps), isNull);
    });

    test('classic biphasic shift is detected, ovulation = day before rise',
        () {
      // 1-8 Tem düşük faz (~36.3-36.4), 9 Tem'den itibaren yüksek faz
      final temps = [
        t(1, 36.35), t(2, 36.40), t(3, 36.32), t(4, 36.38),
        t(5, 36.36), t(6, 36.41), t(7, 36.37), t(8, 36.39),
        t(9, 36.55), t(10, 36.60), t(11, 36.65), t(12, 36.62),
      ];
      expect(
        CycleUtils.detectOvulationFromBBT(temps),
        DateTime(2026, 7, 8),
      );
    });

    test('rise smaller than 0.2 above coverline is not confirmed', () {
      final temps = [
        t(1, 36.40), t(2, 36.40), t(3, 36.40), t(4, 36.40),
        t(5, 36.40), t(6, 36.40), t(7, 36.40), t(8, 36.40),
        // yükseliş var ama üçüncü gün coverline+0.2'ye ulaşmıyor
        t(9, 36.45), t(10, 36.48), t(11, 36.55),
      ];
      expect(CycleUtils.detectOvulationFromBBT(temps), isNull);
    });

    test('single spike does not trigger (needs 3 consecutive)', () {
      final temps = [
        t(1, 36.40), t(2, 36.40), t(3, 36.40), t(4, 36.40),
        t(5, 36.40), t(6, 36.40), t(7, 36.90), t(8, 36.40),
        t(9, 36.40), t(10, 36.40), t(11, 36.40), t(12, 36.40),
      ];
      expect(CycleUtils.detectOvulationFromBBT(temps), isNull);
    });

    test('unsorted input is handled', () {
      final temps = [
        t(10, 36.60), t(2, 36.40), t(8, 36.39), t(1, 36.35),
        t(9, 36.55), t(4, 36.38), t(3, 36.32), t(6, 36.41),
        t(5, 36.36), t(7, 36.37), t(11, 36.65), t(12, 36.62),
      ];
      expect(
        CycleUtils.detectOvulationFromBBT(temps),
        DateTime(2026, 7, 8),
      );
    });
  });
}
