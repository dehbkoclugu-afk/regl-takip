import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/utils/cycle_utils.dart';
import 'package:regl_takip/models/period_record.dart';

PeriodRecord _record(DateTime start) =>
    PeriodRecord(id: start.toIso8601String(), startDate: start);

/// Verilen aralıklarla (gün) ardışık kayıtlar üretir
List<PeriodRecord> _recordsWithGaps(List<int> gaps) {
  var current = DateTime(2026, 1, 1);
  final records = [_record(current)];
  for (final gap in gaps) {
    current = current.add(Duration(days: gap));
    records.add(_record(current));
  }
  return records;
}

void main() {
  group('effectiveCycleLength', () {
    test('falls back to manual with fewer than 3 valid gaps', () {
      expect(
        CycleUtils.effectiveCycleLength(31, _recordsWithGaps([28, 29])),
        31,
      );
      expect(CycleUtils.effectiveCycleLength(31, []), 31);
    });

    test('uses rounded learned average with 3+ gaps', () {
      // 28, 29, 30 → ortalama 29
      expect(
        CycleUtils.effectiveCycleLength(35, _recordsWithGaps([28, 29, 30])),
        29,
      );
    });

    test('respects smartEnabled=false', () {
      expect(
        CycleUtils.effectiveCycleLength(35, _recordsWithGaps([28, 29, 30]),
            smartEnabled: false),
        35,
      );
    });

    test('only considers the most recent 6 gaps', () {
      // Eski 3 aralık 40 (geçerli aralıkta), son 6 aralık 28
      final gaps = [40, 40, 40, 28, 28, 28, 28, 28, 28];
      expect(CycleUtils.effectiveCycleLength(35, _recordsWithGaps(gaps)), 28);
    });

    test('ignores outlier gaps outside min/max bounds', () {
      // 2 günlük aralık elenir; kalan 28,29,30 → 29
      expect(
        CycleUtils.effectiveCycleLength(
            35, _recordsWithGaps([28, 2, 29, 30])),
        29,
      );
    });
  });

  group('learnedCycleLength', () {
    test('null with insufficient data, value with enough', () {
      expect(CycleUtils.learnedCycleLength(_recordsWithGaps([28])), isNull);
      expect(
          CycleUtils.learnedCycleLength(_recordsWithGaps([28, 30, 32])), 30);
    });
  });

  group('isIrregular', () {
    test('null with fewer than 3 valid gaps', () {
      expect(CycleUtils.isIrregular(_recordsWithGaps([28, 29])), isNull);
    });

    test('regular when max-min gap below 9 days', () {
      expect(
          CycleUtils.isIrregular(_recordsWithGaps([26, 30, 33])), isFalse);
    });

    test('irregular when max-min gap is 9+ days', () {
      expect(CycleUtils.isIrregular(_recordsWithGaps([24, 30, 33])), isTrue);
    });
  });

  group('dayInCycleFor', () {
    final start = DateTime(2026, 1, 1);

    test('null before cycle start', () {
      expect(
          CycleUtils.dayInCycleFor(DateTime(2025, 12, 31), start, 28), isNull);
    });

    test('wraps across cycles', () {
      expect(CycleUtils.dayInCycleFor(DateTime(2026, 1, 1), start, 28), 1);
      expect(CycleUtils.dayInCycleFor(DateTime(2026, 1, 28), start, 28), 28);
      expect(CycleUtils.dayInCycleFor(DateTime(2026, 1, 29), start, 28), 1);
      expect(CycleUtils.dayInCycleFor(DateTime(2026, 2, 26), start, 28), 1);
    });
  });

  group('isPredictedPeriodDay', () {
    final start = DateTime(2026, 1, 1);

    test('current cycle is never predicted (real records own it)', () {
      expect(
          CycleUtils.isPredictedPeriodDay(DateTime(2026, 1, 3), start, 28, 5),
          isFalse);
    });

    test('marks period days in next cycles', () {
      // 2. döngü: 29 Oca = gün 1
      expect(
          CycleUtils.isPredictedPeriodDay(DateTime(2026, 1, 29), start, 28, 5),
          isTrue);
      // 2. döngü gün 5
      expect(
          CycleUtils.isPredictedPeriodDay(DateTime(2026, 2, 2), start, 28, 5),
          isTrue);
      // 2. döngü gün 6 — regl bitti
      expect(
          CycleUtils.isPredictedPeriodDay(DateTime(2026, 2, 3), start, 28, 5),
          isFalse);
      // 3. döngü gün 1 (26 Şub)
      expect(
          CycleUtils.isPredictedPeriodDay(DateTime(2026, 2, 26), start, 28, 5),
          isTrue);
    });

    test('stops after cyclesAhead horizon', () {
      // 5. döngü başı (varsayılan ufuk 3 döngü) — işaretlenmez
      final fifthCycleStart = start.add(const Duration(days: 28 * 4));
      expect(
          CycleUtils.isPredictedPeriodDay(fifthCycleStart, start, 28, 5),
          isFalse);
    });
  });

  group('future-cycle ovulation and fertile window', () {
    final start = DateTime(2026, 1, 1);

    test('ovulation repeats each cycle', () {
      // Döngü 28: ovülasyon gün 15 (predictOvulation ile aynı) →
      // 15 Oca ve 12 Şub (2. döngü)
      expect(CycleUtils.isOvulationDay(DateTime(2026, 1, 15), start, 28),
          isTrue);
      expect(CycleUtils.isOvulationDay(DateTime(2026, 2, 12), start, 28),
          isTrue);
      expect(CycleUtils.isOvulationDay(DateTime(2026, 1, 16), start, 28),
          isFalse);
    });

    test('fertile window covers ovulation-5..ovulation+1 in later cycles',
        () {
      // 2. döngü ovülasyonu 12 Şub → pencere 7-13 Şub
      expect(CycleUtils.isInFertileWindow(DateTime(2026, 2, 7), start, 28),
          isTrue);
      expect(CycleUtils.isInFertileWindow(DateTime(2026, 2, 13), start, 28),
          isTrue);
      expect(CycleUtils.isInFertileWindow(DateTime(2026, 2, 14), start, 28),
          isFalse);
    });
  });
}
