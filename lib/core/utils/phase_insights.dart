import '../../models/daily_log.dart';
import '../../models/enums.dart';
import 'cycle_utils.dart';

/// "Bu semptom en çok şu fazda görülüyor" içgörüsü.
/// [percent]: semptomun tüm kayıtları içinde [phase]'e düşen pay.
class PhaseInsight {
  final SymptomType symptom;
  final CyclePhase phase;
  final int percent;
  final int totalCount;

  const PhaseInsight(this.symptom, this.phase, this.percent, this.totalCount);
}

/// Semptom kayıtlarını döngü fazlarına eşler; her semptomun en sık
/// görüldüğü fazı yüzdesiyle çıkarır. İstatistik ekranının "faz
/// içgörüleri" kartı ile kişisel koç satırı ve faz-ipucu bildirimi
/// aynı motoru kullanır (tek doğru).
///
/// [periodStarts] artan sırada regl başlangıçları; log tarihinden önceki
/// en yakın başlangıç o logun döngüsünü belirler (öncesinde kayıt yoksa
/// faz bilinemez, atlanır). En az [minOccurrences] kez kaydedilmiş
/// semptomlar, toplam sayıya göre ilk [take] tanesi döner.
List<PhaseInsight> topPhaseSymptoms({
  required List<DailyLog> logs,
  required List<DateTime> periodStarts,
  required int cycleLength,
  required int periodLength,
  int minOccurrences = 3,
  int take = 3,
}) {
  if (periodStarts.isEmpty) return const [];
  final sortedStarts = List<DateTime>.from(periodStarts)..sort();

  final counts = <SymptomType, Map<CyclePhase, int>>{};

  for (final log in logs) {
    if (log.symptoms.isEmpty) continue;
    DateTime? anchor;
    for (final start in sortedStarts) {
      if (!start.isAfter(log.date)) {
        anchor = start;
      } else {
        break;
      }
    }
    if (anchor == null) continue;

    final rawDay = log.date
            .difference(DateTime(anchor.year, anchor.month, anchor.day))
            .inDays +
        1;
    final day = CycleUtils.wrappedCycleDay(rawDay, cycleLength);
    final phase = CycleUtils.phaseForDay(day, cycleLength, periodLength);

    for (final symptom in log.symptoms) {
      counts.putIfAbsent(symptom.type, () => {});
      counts[symptom.type]![phase] = (counts[symptom.type]![phase] ?? 0) + 1;
    }
  }

  final eligible = counts.entries
      .where((e) =>
          e.value.values.fold<int>(0, (a, b) => a + b) >= minOccurrences)
      .toList()
    ..sort((a, b) => b.value.values
        .fold<int>(0, (x, y) => x + y)
        .compareTo(a.value.values.fold<int>(0, (x, y) => x + y)));

  final insights = <PhaseInsight>[];
  for (final entry in eligible.take(take)) {
    final total = entry.value.values.fold<int>(0, (a, b) => a + b);
    final topPhase =
        entry.value.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final percent = (topPhase.value / total * 100).round();
    insights.add(PhaseInsight(entry.key, topPhase.key, percent, total));
  }
  return insights;
}

/// Verilen faz için en güçlü içgörü (yoksa null) — koç satırı ve
/// faz-ipucu bildirimi için kısayol.
PhaseInsight? topInsightForPhase(
    List<PhaseInsight> insights, CyclePhase phase) {
  for (final insight in insights) {
    if (insight.phase == phase) return insight;
  }
  return null;
}
