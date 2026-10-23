import 'calendar_days.dart';
import 'cycle_utils.dart';
import '../../models/period_record.dart';

/// Empirical range from observed cycle gaps, not a clinical confidence interval.
({DateTime earliest, DateTime latest})? predictionWindow(
    DateTime lastStart, List<PeriodRecord> records) {
  final gaps = CycleUtils.validCycleGaps(records);
  if (gaps.length < 3) return null;
  final recent = gaps.length > 6 ? gaps.sublist(gaps.length - 6) : gaps;
  final shortest = recent.reduce((a, b) => a < b ? a : b);
  final longest = recent.reduce((a, b) => a > b ? a : b);
  return (
    earliest: CalendarDays.add(lastStart, shortest),
    latest: CalendarDays.add(lastStart, longest)
  );
}
