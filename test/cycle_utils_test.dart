import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/constants/app_constants.dart';
import 'package:regl_takip/core/utils/cycle_utils.dart';
import 'package:regl_takip/models/period_record.dart';

void main() {
  group('predictNextPeriod', () {
    test('adds cycle length to last period start', () {
      final last = DateTime(2026, 1, 1);
      expect(
        CycleUtils.predictNextPeriod(last, 28),
        DateTime(2026, 1, 29),
      );
    });
  });

  group('predictOvulation', () {
    test('is 14 days before next period', () {
      final last = DateTime(2026, 1, 1);
      expect(
        CycleUtils.predictOvulation(last, 28),
        DateTime(2026, 1, 15),
      );
    });

    test('shifts with cycle length', () {
      final last = DateTime(2026, 1, 1);
      expect(
        CycleUtils.predictOvulation(last, 35),
        DateTime(2026, 1, 22),
      );
    });
  });

  group('fertile window', () {
    test('starts 5 days before and ends 1 day after ovulation', () {
      final last = DateTime(2026, 1, 1);
      final ovulation = CycleUtils.predictOvulation(last, 28);
      expect(
        CycleUtils.fertileWindowStart(last, 28),
        ovulation.subtract(const Duration(days: 5)),
      );
      expect(
        CycleUtils.fertileWindowEnd(last, 28),
        ovulation.add(const Duration(days: 1)),
      );
    });

    test('isInFertileWindow includes boundaries', () {
      final last = DateTime(2026, 1, 1);
      final start = CycleUtils.fertileWindowStart(last, 28);
      final end = CycleUtils.fertileWindowEnd(last, 28);
      expect(CycleUtils.isInFertileWindow(start, last, 28), isTrue);
      expect(CycleUtils.isInFertileWindow(end, last, 28), isTrue);
      expect(
        CycleUtils.isInFertileWindow(
            start.subtract(const Duration(days: 1)), last, 28),
        isFalse,
      );
      expect(
        CycleUtils.isInFertileWindow(
            end.add(const Duration(days: 1)), last, 28),
        isFalse,
      );
    });
  });

  group('wrappedCycleDay', () {
    test('returns raw day within cycle', () {
      expect(CycleUtils.wrappedCycleDay(1, 28), 1);
      expect(CycleUtils.wrappedCycleDay(28, 28), 28);
    });

    test('wraps past cycle length', () {
      expect(CycleUtils.wrappedCycleDay(29, 28), 1);
      expect(CycleUtils.wrappedCycleDay(30, 28), 2);
      expect(CycleUtils.wrappedCycleDay(56, 28), 28);
      expect(CycleUtils.wrappedCycleDay(57, 28), 1);
    });
  });

  group('phaseForDay', () {
    test('menstrual during period days', () {
      expect(CycleUtils.phaseForDay(1, 28, 5), CyclePhase.menstrual);
      expect(CycleUtils.phaseForDay(5, 28, 5), CyclePhase.menstrual);
    });

    test('zero period length never returns menstrual', () {
      expect(CycleUtils.phaseForDay(1, 28, 0), CyclePhase.follicular);
    });

    test('follicular between period and fertile window', () {
      // ovulationDay = 28 - 14 + 1 = 15 (predictOvulation ile aynı gün),
      // fertileStart = 10
      expect(CycleUtils.phaseForDay(6, 28, 5), CyclePhase.follicular);
      expect(CycleUtils.phaseForDay(9, 28, 5), CyclePhase.follicular);
    });

    test('ovulation phase covers fertile window', () {
      expect(CycleUtils.phaseForDay(10, 28, 5), CyclePhase.ovulation);
      expect(CycleUtils.phaseForDay(15, 28, 5), CyclePhase.ovulation);
      expect(CycleUtils.phaseForDay(16, 28, 5), CyclePhase.ovulation);
    });

    test('luteal after ovulation window', () {
      expect(CycleUtils.phaseForDay(17, 28, 5), CyclePhase.luteal);
      expect(CycleUtils.phaseForDay(28, 28, 5), CyclePhase.luteal);
    });

    test('phase day math agrees with date-based ovulation prediction', () {
      final last = DateTime(2026, 1, 1);
      final ovulationDate = CycleUtils.predictOvulation(last, 28);
      final dayOfOvulation =
          ovulationDate.difference(last).inDays + 1; // 15
      expect(dayOfOvulation, CycleUtils.ovulationDayNumber(28));
    });
  });

  group('getCurrentPhase consistency', () {
    test('overdue cycle wraps instead of sticking to luteal', () {
      // 30 gün önce başlamış, 28 günlük döngü → sarılmış gün 3 → menstrual
      // (currentCycleDayProvider ile aynı gün gösterilir)
      final lastStart = DateTime.now().subtract(const Duration(days: 29));
      final phase = CycleUtils.getCurrentPhase(lastStart, 28, 5);
      final wrappedDay = CycleUtils.wrappedCycleDay(
        CycleUtils.currentCycleDay(lastStart),
        28,
      );
      expect(phase, CycleUtils.phaseForDay(wrappedDay, 28, 5));
    });
  });

  group('calculateAverageCycleLength', () {
    PeriodRecord record(DateTime start) =>
        PeriodRecord(id: start.toIso8601String(), startDate: start);

    test('returns default with fewer than 2 records', () {
      expect(
        CycleUtils.calculateAverageCycleLength([]),
        AppConstants.defaultCycleLength.toDouble(),
      );
      expect(
        CycleUtils.calculateAverageCycleLength([record(DateTime(2026, 1, 1))]),
        AppConstants.defaultCycleLength.toDouble(),
      );
    });

    test('averages gaps between starts', () {
      final records = [
        record(DateTime(2026, 1, 1)),
        record(DateTime(2026, 1, 29)), // 28
        record(DateTime(2026, 2, 28)), // 30
      ];
      expect(CycleUtils.calculateAverageCycleLength(records), 29.0);
    });

    test('ignores outlier gaps outside min/max', () {
      final records = [
        record(DateTime(2026, 1, 1)),
        record(DateTime(2026, 1, 3)), // 2 gün — atlanır
        record(DateTime(2026, 1, 31)), // 28 gün
      ];
      expect(CycleUtils.calculateAverageCycleLength(records), 28.0);
    });
  });

  group('nextFuturePeriod / daysUntilNextPeriod', () {
    test('prediction in future stays unchanged', () {
      final lastStart = DateTime.now().subtract(const Duration(days: 10));
      final next = CycleUtils.nextFuturePeriod(lastStart, 28);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(next.isBefore(today), isFalse);
      expect(CycleUtils.daysUntilNextPeriod(lastStart, 28), 18);
    });

    test('overdue prediction rolls forward to next cycle', () {
      // 30 gün önce başladı, 28 günlük döngü → tahmin 2 gün önceydi,
      // bir döngü ileri sarılır → 26 gün sonra
      final lastStart = DateTime.now().subtract(const Duration(days: 30));
      expect(CycleUtils.daysUntilNextPeriod(lastStart, 28), 26);
      final next = CycleUtils.nextFuturePeriod(lastStart, 28);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(next.isBefore(today), isFalse);
    });
  });

  group('averagePeriodDuration (istatistik)', () {
    test('bitmiş kayıtların ortalaması alınır', () {
      final records = [
        PeriodRecord(
            id: '1',
            startDate: DateTime(2026, 5, 1),
            endDate: DateTime(2026, 5, 5)), // 5 gün
        PeriodRecord(
            id: '2',
            startDate: DateTime(2026, 6, 1),
            endDate: DateTime(2026, 6, 3)), // 3 gün
      ];
      expect(CycleUtils.averagePeriodDuration(records, 7), 4.0);
    });

    test('tüm kayıtlar devam ediyorsa profil değeri döner (0 değil)', () {
      final records = [
        PeriodRecord(id: '1', startDate: DateTime(2026, 6, 1)),
      ];
      expect(CycleUtils.averagePeriodDuration(records, 6), 6.0);
    });

    test('kayıt yoksa profil değeri döner', () {
      expect(CycleUtils.averagePeriodDuration(const [], 5), 5.0);
    });
  });

  group('completedPeriodEnd (onboarding kaydı)', () {
    test('geçmiş regl kapalı kayıt olur', () {
      final start = DateTime(2026, 6, 1);
      final today = DateTime(2026, 6, 20);
      expect(CycleUtils.completedPeriodEnd(start, 5, today),
          DateTime(2026, 6, 5));
    });

    test('regl bugün hâlâ sürüyorsa kayıt açık kalır', () {
      final start = DateTime(2026, 6, 18);
      final today = DateTime(2026, 6, 20);
      expect(CycleUtils.completedPeriodEnd(start, 5, today), isNull);
    });

    test('bitiş bugüne denk gelirse kapalı sayılır', () {
      final start = DateTime(2026, 6, 16);
      final today = DateTime(2026, 6, 20);
      expect(CycleUtils.completedPeriodEnd(start, 5, today),
          DateTime(2026, 6, 20));
    });

    test('saat bileşeni sonucu bozmaz', () {
      final start = DateTime(2026, 6, 1, 23, 30);
      final today = DateTime(2026, 6, 5, 0, 10);
      expect(CycleUtils.completedPeriodEnd(start, 5, today),
          DateTime(2026, 6, 5));
    });
  });
}
