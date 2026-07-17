import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/utils/cycle_utils.dart';
import 'package:regl_takip/core/utils/phase_insights.dart';
import 'package:regl_takip/models/daily_log.dart';
import 'package:regl_takip/models/enums.dart';
import 'package:regl_takip/models/period_record.dart';

void main() {
  DailyLog log(DateTime date, List<SymptomType> symptoms) => DailyLog(
        id: date.toIso8601String(),
        date: date,
        symptoms: symptoms.map((t) => SymptomEntry(type: t)).toList(),
      );

  // 28 günlük döngü, 1 Haziran başlangıç: luteal ~17. günden itibaren
  final start = DateTime(2026, 6, 1);

  test('luteal ağırlıklı semptom luteal içgörüsü üretir', () {
    final logs = [
      // 18-20. günler: luteal
      log(DateTime(2026, 6, 18), [SymptomType.headache]),
      log(DateTime(2026, 6, 19), [SymptomType.headache]),
      log(DateTime(2026, 6, 20), [SymptomType.headache]),
      // 3. gün: menstrual (azınlık)
      log(DateTime(2026, 6, 3), [SymptomType.headache]),
    ];

    final insights = topPhaseSymptoms(
      logs: logs,
      periodStarts: [start],
      cycleLength: 28,
      periodLength: 5,
    );

    expect(insights, hasLength(1));
    expect(insights.single.symptom, SymptomType.headache);
    expect(insights.single.phase, CyclePhase.luteal);
    expect(insights.single.percent, 75);
    expect(topInsightForPhase(insights, CyclePhase.luteal), isNotNull);
    expect(topInsightForPhase(insights, CyclePhase.follicular), isNull);
  });

  test('3 kayıttan az görülen semptom elenmez sınırı', () {
    final logs = [
      log(DateTime(2026, 6, 18), [SymptomType.cramp]),
      log(DateTime(2026, 6, 19), [SymptomType.cramp]),
    ];
    final insights = topPhaseSymptoms(
      logs: logs,
      periodStarts: [start],
      cycleLength: 28,
      periodLength: 5,
    );
    expect(insights, isEmpty);
  });

  test('regl başlangıcı olmayan kullanıcıda boş döner', () {
    final insights = topPhaseSymptoms(
      logs: [
        log(DateTime(2026, 6, 18), [SymptomType.cramp]),
      ],
      periodStarts: const [],
      cycleLength: 28,
      periodLength: 5,
    );
    expect(insights, isEmpty);
  });

  test('döngü başlangıcından önceki loglar faza eşlenmez', () {
    final logs = [
      log(DateTime(2026, 5, 20), [SymptomType.cramp]),
      log(DateTime(2026, 5, 21), [SymptomType.cramp]),
      log(DateTime(2026, 5, 22), [SymptomType.cramp]),
    ];
    final insights = topPhaseSymptoms(
      logs: logs,
      periodStarts: [start],
      cycleLength: 28,
      periodLength: 5,
    );
    expect(insights, isEmpty);
  });

  test('istatistik ekranıyla aynı sözleşme: toplam sayıya göre ilk 3', () {
    DailyLog many(DateTime d, SymptomType t) => log(d, [t]);
    final logs = <DailyLog>[
      for (var i = 0; i < 6; i++)
        many(DateTime(2026, 6, 17 + i), SymptomType.headache),
      for (var i = 0; i < 5; i++)
        many(DateTime(2026, 6, 1 + i), SymptomType.cramp),
      for (var i = 0; i < 4; i++)
        many(DateTime(2026, 6, 7 + i), SymptomType.fatigue),
      for (var i = 0; i < 3; i++)
        many(DateTime(2026, 6, 11 + i), SymptomType.bloating),
    ];
    final insights = topPhaseSymptoms(
      logs: logs,
      periodStarts: [start],
      cycleLength: 28,
      periodLength: 5,
    );
    expect(insights, hasLength(3));
    expect(insights[0].symptom, SymptomType.headache);
    expect(insights[1].symptom, SymptomType.cramp);
    expect(insights[2].symptom, SymptomType.fatigue);
  });

  test('PeriodRecord listesinden başlangıç akışı uyumlu', () {
    // Provider'ın kullandığı biçim: kayıtların startDate'leri
    final records = [
      PeriodRecord(id: 'a', startDate: DateTime(2026, 6, 1)),
      PeriodRecord(id: 'b', startDate: DateTime(2026, 6, 29)),
    ];
    final logs = [
      log(DateTime(2026, 7, 16), [SymptomType.headache]), // 2. döngü, luteal
      log(DateTime(2026, 7, 17), [SymptomType.headache]),
      log(DateTime(2026, 7, 18), [SymptomType.headache]),
    ];
    final insights = topPhaseSymptoms(
      logs: logs,
      periodStarts: records.map((r) => r.startDate).toList(),
      cycleLength: 28,
      periodLength: 5,
    );
    expect(insights.single.phase, CyclePhase.luteal);
  });
}
