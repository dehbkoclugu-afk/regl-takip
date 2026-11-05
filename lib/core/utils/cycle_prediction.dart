import '../../models/daily_log.dart';
import '../../models/enums.dart';
import 'cycle_utils.dart';
import 'date_only.dart';

/// Calendar predictions are prospective; measurements describe this recorded
/// cycle retrospectively. A measurement is never a clinical confirmation.
enum PredictionSource { calendar, lh, temperature }

class CyclePrediction {
  final DateTime nextPeriod;
  final DateTime ovulation;
  final PredictionSource source;
  final bool sufficientData;
  const CyclePrediction(
    this.nextPeriod,
    this.ovulation,
    this.source, {
    this.sufficientData = false,
  });
  DateTime get fertileStart => addDays(ovulation, -5);
  DateTime get fertileEnd => addDays(ovulation, 1);
  bool isOvulation(DateTime day) => dateOnly(day) == dateOnly(ovulation);
  bool isFertile(DateTime day) =>
      !dateOnly(day).isBefore(fertileStart) &&
      !dateOnly(day).isAfter(fertileEnd);

  static CyclePrediction? calculate({
    required DateTime? start,
    required int length,
    required TrackingMode mode,
    Iterable<DailyLog> logs = const [],
    DateTime? now,
  }) {
    if (start == null ||
        mode == TrackingMode.pregnancy ||
        mode == TrackingMode.pill)
      return null;
    final today = dateOnly(now ?? DateTime.now());
    final next = CycleUtils.nextFuturePeriod(start, length, now: today);
    var ovulation = addDays(next, -14);
    if (ovulation.isBefore(today)) ovulation = addDays(ovulation, length);
    final temperatures = <MapEntry<DateTime, double>>[];
    DateTime? lh;
    for (final log in logs) {
      final day = dateOnly(log.date);
      if (day.isBefore(dateOnly(start)) || day.isAfter(today)) continue;
      // Old, unqualified temperature entries remain visible but do not become
      // basal observations merely because they contain a number.
      if (log.temperature != null && log.temperatureTime != null) {
        temperatures.add(MapEntry(day, log.temperature!));
      }
      if (log.ovulationTestPositive == true && (lh == null || day.isAfter(lh)))
        lh = day;
    }
    final bbt = CycleUtils.detectOvulationFromBBT(temperatures);
    if (bbt != null)
      return CyclePrediction(
        next,
        bbt,
        PredictionSource.temperature,
        sufficientData: true,
      );
    // A stale LH result cannot describe an indefinitely delayed cycle.
    if (lh != null && daysBetween(lh, today) <= length)
      return CyclePrediction(next, addDays(lh, 1), PredictionSource.lh);
    return CyclePrediction(next, ovulation, PredictionSource.calendar);
  }
}
