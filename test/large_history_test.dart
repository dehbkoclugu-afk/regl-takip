import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/utils/statistics_summary.dart';
import 'package:regl_takip/core/utils/prediction_window.dart';
import 'package:regl_takip/models/daily_log.dart';
import 'package:regl_takip/models/period_record.dart';
import 'package:regl_takip/models/enums.dart';

void main() {
  test('ten years of logs can be summarized with correct coverage', () {
    final start = DateTime(2016, 1, 1);
    final logs = List.generate(
        3653,
        (i) => DailyLog(
            id: 'l$i',
            date: DateTime(start.year, start.month, start.day + i),
            symptoms: [SymptomEntry(type: SymptomType.cramp, severity: 2)]));
    final watch = Stopwatch()..start();
    final coverage =
        calculateDataCoverage(logs, start: start, end: logs.last.date);
    final summary = summarizeSymptoms(logs);
    watch.stop();
    expect(coverage.loggedDays, logs.length);
    expect(summary.single.count, logs.length);
    expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
  });
  test('empirical range needs three complete cycle gaps', () {
    final records = [0, 27, 56, 86]
        .map((day) =>
            PeriodRecord(id: '$day', startDate: DateTime(2026, 1, 1 + day)))
        .toList();
    expect(predictionWindow(records.last.startDate, records.take(3).toList()),
        isNull);
    final range = predictionWindow(records.last.startDate, records)!;
    expect(range.earliest, DateTime(2026, 1, 1 + 86 + 27));
    expect(range.latest, DateTime(2026, 1, 1 + 86 + 30));
  });
}
