import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/utils/statistics_summary.dart';
import 'package:regl_takip/models/daily_log.dart';
import 'package:regl_takip/models/enums.dart';
import 'package:regl_takip/models/period_record.dart';

void main() {
  test('symptom summaries include count and average severity', () {
    final logs = [
      DailyLog(
        id: '1',
        date: DateTime(2026, 1, 1),
        symptoms: [
          SymptomEntry(type: SymptomType.cramp, severity: 2),
          SymptomEntry(type: SymptomType.headache, severity: 5),
        ],
      ),
      DailyLog(
        id: '2',
        date: DateTime(2026, 1, 2),
        symptoms: [
          SymptomEntry(type: SymptomType.cramp, severity: 4),
        ],
      ),
    ];

    final summaries = summarizeSymptoms(logs);

    expect(summaries.first.type, SymptomType.cramp);
    expect(summaries.first.count, 2);
    expect(summaries.first.averageSeverity, 3);
  });

  test('coverage ignores empty logs and includes both boundary days', () {
    final logs = [
      DailyLog(id: 'empty', date: DateTime(2026, 1, 1)),
      DailyLog(id: 'note', date: DateTime(2026, 1, 2), notes: 'not'),
      DailyLog(id: 'water', date: DateTime(2026, 1, 3), waterIntake: 2),
      DailyLog(id: 'outside', date: DateTime(2026, 1, 4), notes: 'not'),
    ];

    final coverage = calculateDataCoverage(
      logs,
      start: DateTime(2026, 1, 1),
      end: DateTime(2026, 1, 3),
    );

    expect(coverage.loggedDays, 2);
    expect(coverage.totalDays, 3);
    expect(coverage.percent, 67);
  });

  test('monthly coverage separates months and trims the first range', () {
    final logs = [
      DailyLog(id: 'jan', date: DateTime(2026, 1, 31), notes: 'not'),
      DailyLog(id: 'feb', date: DateTime(2026, 2, 1), notes: 'not'),
    ];

    final months = calculateMonthlyDataCoverage(
      logs,
      start: DateTime(2026, 1, 31),
      end: DateTime(2026, 2, 2),
    );

    expect(months, hasLength(2));
    expect(months.first.totalDays, 1);
    expect(months.first.loggedDays, 1);
    expect(months.last.totalDays, 2);
    expect(months.last.loggedDays, 1);
  });

  test('tracking consistency keeps yesterday streak before today is logged',
      () {
    final logs = [
      DailyLog(id: '1', date: DateTime(2026, 7, 22), notes: 'not'),
      DailyLog(id: '2', date: DateTime(2026, 7, 23), waterIntake: 1),
      DailyLog(id: '3', date: DateTime(2026, 7, 24), mood: MoodEntry(type: MoodType.calm)),
    ];

    final consistency = calculateTrackingConsistency(
      logs,
      today: DateTime(2026, 7, 25),
    );

    expect(consistency.streakDays, 3);
    expect(consistency.lastSevenDays, 3);
  });

  test('ovulation markers replace latest estimate with confirmed date', () {
    final markers = ovulationMarkersForRange(
      periodStarts: [DateTime(2026, 1, 1), DateTime(2026, 2, 1)],
      cycleLength: 28,
      rangeStart: DateTime(2026, 1, 1),
      rangeEnd: DateTime(2026, 2, 28),
      confirmedLatest: DateTime(2026, 2, 18),
    );

    expect(markers, [DateTime(2026, 1, 15), DateTime(2026, 2, 18)]);
  });

  test('cycle comparison aligns symptom severity by cycle day', () {
    final comparison = compareLastTwoCycleSymptoms(
      periodStarts: [DateTime(2026, 1, 1), DateTime(2026, 1, 29)],
      today: DateTime(2026, 2, 2),
      logs: [
        DailyLog(
          id: 'previous',
          date: DateTime(2026, 1, 3),
          symptoms: [
            SymptomEntry(type: SymptomType.cramp, severity: 4),
          ],
        ),
        DailyLog(
          id: 'current',
          date: DateTime(2026, 1, 31),
          symptoms: [
            SymptomEntry(type: SymptomType.cramp, severity: 2),
            SymptomEntry(type: SymptomType.headache, severity: 3),
          ],
        ),
        DailyLog(
          id: 'previous-after-comparable-window',
          date: DateTime(2026, 1, 10),
          symptoms: [
            SymptomEntry(type: SymptomType.fatigue, severity: 5),
          ],
        ),
      ],
    );

    expect(comparison.previous, {3: 4});
    expect(comparison.current, {3: 5});
  });
}
