import '../../models/daily_log.dart';
import '../../models/enums.dart';
import 'cycle_utils.dart';

class SymptomSummary {
  final SymptomType type;
  final int count;
  final double averageSeverity;

  const SymptomSummary(this.type, this.count, this.averageSeverity);
}

List<SymptomSummary> summarizeSymptoms(
  Iterable<DailyLog> logs, {
  int take = 5,
}) {
  final counts = <SymptomType, int>{};
  final severityTotals = <SymptomType, int>{};

  for (final log in logs) {
    for (final symptom in log.symptoms) {
      counts[symptom.type] = (counts[symptom.type] ?? 0) + 1;
      severityTotals[symptom.type] =
          (severityTotals[symptom.type] ?? 0) + symptom.severity;
    }
  }

  final summaries = counts.entries
      .map((entry) => SymptomSummary(
            entry.key,
            entry.value,
            severityTotals[entry.key]! / entry.value,
          ))
      .toList()
    ..sort((a, b) => b.count.compareTo(a.count));
  return summaries.take(take).toList();
}

bool hasMeaningfulDailyData(DailyLog log) =>
    log.symptoms.isNotEmpty ||
    log.mood != null ||
    log.temperature != null ||
    log.weight != null ||
    log.waterIntake > 0 ||
    log.sleepStart != null ||
    log.sleepEnd != null ||
    log.sleepQuality != null ||
    log.sexualActivity != null ||
    log.medications.isNotEmpty ||
    (log.notes?.trim().isNotEmpty ?? false) ||
    log.flowIntensity != null ||
    log.flowColor != null ||
    log.hasClots != null ||
    log.padChangeCount != null ||
    log.ovulationTestPositive != null;

class DataCoverage {
  final int loggedDays;
  final int totalDays;

  const DataCoverage(this.loggedDays, this.totalDays);

  int get percent =>
      totalDays == 0 ? 0 : (loggedDays / totalDays * 100).round();
}

class TrackingConsistency {
  final int streakDays;
  final int lastSevenDays;

  const TrackingConsistency(this.streakDays, this.lastSevenDays);
}

TrackingConsistency calculateTrackingConsistency(
  Iterable<DailyLog> logs, {
  required DateTime today,
}) {
  String key(DateTime day) => '${day.year}-${day.month}-${day.day}';

  final currentDay = DateTime(today.year, today.month, today.day);
  final loggedDays = logs
      .where(hasMeaningfulDailyData)
      .map((log) => key(log.date))
      .toSet();

  var lastSevenDays = 0;
  for (var offset = 0; offset < 7; offset++) {
    if (loggedDays.contains(
        key(currentDay.subtract(Duration(days: offset))))) {
      lastSevenDays++;
    }
  }

  var cursor = loggedDays.contains(key(currentDay))
      ? currentDay
      : currentDay.subtract(const Duration(days: 1));
  var streakDays = 0;
  while (loggedDays.contains(key(cursor))) {
    streakDays++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return TrackingConsistency(streakDays, lastSevenDays);
}

List<DateTime> ovulationMarkersForRange({
  required Iterable<DateTime> periodStarts,
  required int cycleLength,
  required DateTime rangeStart,
  required DateTime rangeEnd,
  DateTime? confirmedLatest,
}) {
  DateTime day(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  final starts = periodStarts.map(day).toList()..sort();
  final firstDay = day(rangeStart);
  final lastDay = day(rangeEnd);
  final markers = <DateTime>[];
  for (var index = 0; index < starts.length; index++) {
    final predicted = starts[index].add(Duration(
      days: CycleUtils.ovulationDayNumber(cycleLength) - 1,
    ));
    final marker = index == starts.length - 1 && confirmedLatest != null
        ? day(confirmedLatest)
        : predicted;
    if (!marker.isBefore(firstDay) && !marker.isAfter(lastDay)) {
      markers.add(marker);
    }
  }
  return markers;
}

class CycleSymptomComparison {
  final Map<int, double> current;
  final Map<int, double> previous;

  const CycleSymptomComparison(this.current, this.previous);

  bool get isEmpty => current.isEmpty && previous.isEmpty;
}

CycleSymptomComparison compareLastTwoCycleSymptoms({
  required Iterable<DailyLog> logs,
  required Iterable<DateTime> periodStarts,
  required DateTime today,
}) {
  DateTime day(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  final starts = periodStarts.map(day).toList()..sort();
  if (starts.length < 2) {
    return const CycleSymptomComparison({}, {});
  }
  final currentStart = starts.last;
  final previousStart = starts[starts.length - 2];
  final currentDay = day(today).difference(currentStart).inDays + 1;
  if (currentDay < 1) return const CycleSymptomComparison({}, {});

  final current = <int, double>{};
  final previous = <int, double>{};
  for (final log in logs) {
    if (log.symptoms.isEmpty) continue;
    final logDay = day(log.date);
    final severity = log.symptoms.fold<int>(
        0, (total, symptom) => total + symptom.severity);
    if (!logDay.isBefore(currentStart) && !logDay.isAfter(day(today))) {
      final cycleDay = logDay.difference(currentStart).inDays + 1;
      current[cycleDay] = (current[cycleDay] ?? 0) + severity;
    } else if (!logDay.isBefore(previousStart) &&
        logDay.isBefore(currentStart)) {
      final cycleDay = logDay.difference(previousStart).inDays + 1;
      if (cycleDay <= currentDay) {
        previous[cycleDay] = (previous[cycleDay] ?? 0) + severity;
      }
    }
  }
  return CycleSymptomComparison(current, previous);
}

class MonthlyDataCoverage extends DataCoverage {
  final DateTime month;

  const MonthlyDataCoverage(
    this.month,
    int loggedDays,
    int totalDays,
  ) : super(loggedDays, totalDays);
}

DataCoverage calculateDataCoverage(
  Iterable<DailyLog> logs, {
  required DateTime start,
  required DateTime end,
}) {
  final firstDay = DateTime(start.year, start.month, start.day);
  final lastDay = DateTime(end.year, end.month, end.day);
  if (lastDay.isBefore(firstDay)) return const DataCoverage(0, 0);

  final loggedDates = <String>{};
  for (final log in logs) {
    final day = DateTime(log.date.year, log.date.month, log.date.day);
    if (day.isBefore(firstDay) ||
        day.isAfter(lastDay) ||
        !hasMeaningfulDailyData(log)) {
      continue;
    }
    loggedDates.add('${day.year}-${day.month}-${day.day}');
  }

  return DataCoverage(
    loggedDates.length,
    lastDay.difference(firstDay).inDays + 1,
  );
}

List<MonthlyDataCoverage> calculateMonthlyDataCoverage(
  Iterable<DailyLog> logs, {
  required DateTime start,
  required DateTime end,
  int maxMonths = 12,
}) {
  final firstMonth = DateTime(start.year, start.month);
  final lastMonth = DateTime(end.year, end.month);
  if (lastMonth.isBefore(firstMonth) || maxMonths <= 0) return const [];

  final months = <DateTime>[];
  var month = firstMonth;
  while (!month.isAfter(lastMonth)) {
    months.add(month);
    month = DateTime(month.year, month.month + 1);
  }

  return months.reversed.take(maxMonths).toList().reversed.map((month) {
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final rangeStart = month.isBefore(start) ? start : month;
    final rangeEnd = monthEnd.isAfter(end) ? end : monthEnd;
    final coverage = calculateDataCoverage(
      logs,
      start: rangeStart,
      end: rangeEnd,
    );
    return MonthlyDataCoverage(
      month,
      coverage.loggedDays,
      coverage.totalDays,
    );
  }).toList();
}
