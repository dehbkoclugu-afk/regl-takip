import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/cycle_utils.dart';
import '../../core/utils/enum_labels.dart';
import '../../core/widgets/glass_card.dart';
import '../../models/enums.dart';
import '../../models/period_record.dart';
import '../../models/daily_log.dart';
import '../../models/user_profile.dart';
import '../../providers/providers.dart';
import '../../core/utils/motion.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  int _filterMonths = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final records = ref.watch(periodRecordsProvider);
    final dailyLogs = ref.watch(dailyLogProvider);
    final profile = ref.watch(userProfileProvider);

    final cutoff = DateTime.now().subtract(Duration(days: _filterMonths * 30));
    final filteredRecords =
        records.where((r) => r.startDate.isAfter(cutoff)).toList();
    final filteredLogs =
        dailyLogs.values.where((l) => l.date.isAfter(cutoff)).toList();

    final avgCycle = CycleUtils.calculateAverageCycleLength(records);
    // Seçili aralıktaki tüm kayıtlar devam ediyorsa (endDate yok) eski
    // hesap 0/1 = 0 veriyor ve "0,0 gün" yazıyordu — profil değeri kullanılır
    final avgPeriod = CycleUtils.averagePeriodDuration(
        filteredRecords, profile?.averagePeriodLength ?? 5);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(l10n.statistics,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.tp(context))),
        backgroundColor: AppColors.bg(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            Row(
              children: [
                _filterChip(l10n.last3Months, 3),
                const SizedBox(width: 8),
                _filterChip(l10n.last6Months, 6),
                const SizedBox(width: 8),
                _filterChip(l10n.last12Months, 12),
              ],
            ).animateSafe(context).fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            _buildOverviewCard(l10n, avgCycle, avgPeriod, records),
            const SizedBox(height: 16),
            _buildSymptomChart(l10n, filteredLogs),
            const SizedBox(height: 16),
            _buildMoodChart(l10n, filteredLogs),
            const SizedBox(height: 16),
            _buildPhaseInsights(l10n, filteredLogs, records, profile),
            const SizedBox(height: 16),
            _buildCycleHistory(l10n, filteredRecords),
            const SizedBox(height: 16),
            _buildTrendChart(
              l10n.temperatureTrend, filteredLogs,
              (log) => log.temperature, AppColors.temperature, '°C',
            ),
            const SizedBox(height: 16),
            _buildTrendChart(
              l10n.weightTrend, filteredLogs,
              (log) => log.weight, AppColors.weightColor, 'kg',
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.ts(context)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.healthDisclaimer,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.ts(context),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, int months) {
    final isSelected = _filterMonths == months;
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _filterMonths = months),
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                )
              : null,
          color: isSelected ? null : AppColors.sf(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.ts(context),
            )),
        ),
      ),
    );
  }

  String _symptomName(SymptomType type, AppLocalizations l10n) =>
      EnumLabels.symptom(type, l10n);

  String _moodName(MoodType mood, AppLocalizations l10n) =>
      EnumLabels.mood(mood, l10n);

  Widget _buildOverviewCard(
      AppLocalizations l10n, double avgCycle, double avgPeriod, List<PeriodRecord> records) {
    // null = veri yetersiz; aksi halde en uzun/en kısa döngü farkı >= 9 gün
    // düzensiz sayılır (CycleUtils.isIrregular)
    final irregular = CycleUtils.isIrregular(records);
    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.18,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.cycleOverview,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tp(context))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statItem(l10n.avgCycle, '${avgCycle.toStringAsFixed(1)} ${l10n.days}',
                    Icons.loop_rounded, AppColors.primary),
              ),
              Expanded(
                child: _statItem(l10n.avgPeriod, '${avgPeriod.toStringAsFixed(1)} ${l10n.days}',
                    Icons.water_drop_rounded, AppColors.menstrual),
              ),
              Expanded(
                child: _statItem(
                    l10n.regularity,
                    irregular == null
                        ? l10n.insufficientData
                        : (irregular ? l10n.irregular : l10n.regular),
                    irregular == true
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_rounded,
                    irregular == null
                        ? AppColors.warning
                        : (irregular
                            ? AppColors.error
                            : AppColors.success)),
              ),
            ],
          ),
        ],
      ),
    ).animateSafe(context).fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.1)],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.tp(context))),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: AppColors.ts(context))),
      ],
    );
  }

  Widget _buildSymptomChart(AppLocalizations l10n, List<DailyLog> logs) {
    final symptomCount = <SymptomType, int>{};
    for (final log in logs) {
      for (final s in log.symptoms) {
        symptomCount[s.type] = (symptomCount[s.type] ?? 0) + 1;
      }
    }
    final sorted = symptomCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();

    if (top5.isEmpty) {
      return _emptyCard(l10n.symptomFrequency, l10n.noSymptomData);
    }

    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.18,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.symptomFrequency,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tp(context))),
          const SizedBox(height: 16),
          // Ekran okuyucu için grafik verisi metin özeti olarak sunulur
          Semantics(
            label: top5
                .map((e) => '${_symptomName(e.key, l10n)}: ${e.value}')
                .join(', '),
            child: ExcludeSemantics(
              child: SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (top5.first.value + 2).toDouble(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < top5.length) {
                          final name = _symptomName(top5[idx].key, l10n);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              name.length > 4 ? name.substring(0, 4) : name,
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.ts(context)),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: top5.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value.toDouble(),
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppColors.primaryLight, AppColors.primary],
                        ),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
            ),
          ),
        ],
      ),
    ).animateSafe(context).fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMoodChart(AppLocalizations l10n, List<DailyLog> logs) {
    final moodCount = <MoodType, int>{};
    for (final log in logs) {
      if (log.mood != null) {
        moodCount[log.mood!.type] = (moodCount[log.mood!.type] ?? 0) + 1;
      }
    }

    if (moodCount.isEmpty) {
      return _emptyCard(l10n.moodDistribution, l10n.noMoodData);
    }

    final colors = {
      MoodType.happy: AppColors.moodHappy,
      MoodType.sad: AppColors.moodSad,
      MoodType.angry: AppColors.moodAngry,
      MoodType.anxious: AppColors.moodAnxious,
      MoodType.calm: AppColors.moodCalm,
      MoodType.energetic: AppColors.moodEnergetic,
      MoodType.tired: AppColors.moodTired,
      MoodType.romantic: AppColors.moodRomantic,
      MoodType.neutral: AppColors.moodNeutral,
    };

    final total = moodCount.values.fold<int>(0, (a, b) => a + b);

    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.18,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.moodDistribution,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tp(context))),
          const SizedBox(height: 16),
          // Ekran okuyucu için pasta grafiği metin özeti olarak sunulur
          Semantics(
            label: moodCount.entries
                .map((e) =>
                    '${_moodName(e.key, l10n)}: %${(e.value / total * 100).toStringAsFixed(0)}')
                .join(', '),
            child: ExcludeSemantics(
              child: SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: moodCount.entries.map((e) {
                      final pct = (e.value / total * 100).toStringAsFixed(0);
                      return PieChartSectionData(
                        color: colors[e.key] ?? AppColors.moodNeutral,
                        value: e.value.toDouble(),
                        title: '$pct%',
                        radius: 50,
                        titleStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: moodCount.entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[e.key] ?? AppColors.moodNeutral,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(_moodName(e.key, l10n),
                      style: TextStyle(
                          fontSize: 11, color: AppColors.ts(context))),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    ).animateSafe(context).fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  String _phaseNameFor(CyclePhase phase, AppLocalizations l10n) {
    switch (phase) {
      case CyclePhase.menstrual:
        return l10n.menstrualPhase;
      case CyclePhase.follicular:
        return l10n.follicularPhase;
      case CyclePhase.ovulation:
        return l10n.ovulationPhase;
      case CyclePhase.luteal:
        return l10n.lutealPhase;
    }
  }

  /// Semptom kayıtlarını döngü fazlarına eşler; her semptomun en sık
  /// görüldüğü fazı yüzdesiyle listeler.
  Widget _buildPhaseInsights(
    AppLocalizations l10n,
    List<DailyLog> logs,
    List<PeriodRecord> records,
    UserProfile? profile,
  ) {
    if (profile == null || records.isEmpty) {
      return _emptyCard(l10n.phaseInsights, l10n.noInsightsYet);
    }

    final cycleLen = ref.read(effectiveCycleLengthProvider);
    final periodLen = profile.averagePeriodLength;
    final sortedStarts = records.map((r) => r.startDate).toList()
      ..sort();

    // symptomType -> phase -> count
    final counts = <SymptomType, Map<CyclePhase, int>>{};

    for (final log in logs) {
      if (log.symptoms.isEmpty) continue;
      // Log tarihinden önceki en yakın adet başlangıcı bu logun döngüsünü
      // belirler; öncesinde kayıt yoksa faz bilinemez, atlanır
      DateTime? anchor;
      for (final start in sortedStarts) {
        if (!start.isAfter(log.date)) {
          anchor = start;
        } else {
          break;
        }
      }
      if (anchor == null) continue;

      final rawDay = log.date.difference(
              DateTime(anchor.year, anchor.month, anchor.day)).inDays + 1;
      final day = CycleUtils.wrappedCycleDay(rawDay, cycleLen);
      final phase = CycleUtils.phaseForDay(day, cycleLen, periodLen);

      for (final symptom in log.symptoms) {
        counts.putIfAbsent(symptom.type, () => {});
        counts[symptom.type]![phase] =
            (counts[symptom.type]![phase] ?? 0) + 1;
      }
    }

    // En az 3 kez kaydedilmiş semptomlar, toplam sayıya göre ilk 3
    final insights = <(SymptomType, CyclePhase, int)>[];
    final eligible = counts.entries
        .where((e) => e.value.values.fold<int>(0, (a, b) => a + b) >= 3)
        .toList()
      ..sort((a, b) => b.value.values
          .fold<int>(0, (x, y) => x + y)
          .compareTo(a.value.values.fold<int>(0, (x, y) => x + y)));

    for (final entry in eligible.take(3)) {
      final total = entry.value.values.fold<int>(0, (a, b) => a + b);
      final topPhase = entry.value.entries
          .reduce((a, b) => a.value >= b.value ? a : b);
      final percent = (topPhase.value / total * 100).round();
      insights.add((entry.key, topPhase.key, percent));
    }

    if (insights.isEmpty) {
      return _emptyCard(l10n.phaseInsights, l10n.noInsightsYet);
    }

    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.18,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.phaseInsights,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tp(context))),
          const SizedBox(height: 12),
          ...insights.map((insight) {
            final (symptom, phase, percent) = insight;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.insights_rounded,
                      size: 18, color: AppColors.secondaryStrong),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.insightLine(
                        _symptomName(symptom, l10n),
                        _phaseNameFor(phase, l10n),
                        percent,
                      ),
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: AppColors.tp(context)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animateSafe(context).fadeIn(delay: 350.ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildCycleHistory(AppLocalizations l10n, List<PeriodRecord> records) {
    if (records.isEmpty) {
      return _emptyCard(l10n.cycleHistory, l10n.noCycleData);
    }

    final localeStr = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('d MMM yyyy', localeStr);
    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.18,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.cycleHistory,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tp(context))),
          const SizedBox(height: 12),
          // Kayıtlar salt-okunur değil: yanlış girilen tarih düzeltilebilmeli,
          // yanlış açılan kayıt silinebilmeli — aksi halde bozuk veri kalıcı
          // ve tahmin motoru onunla çalışır
          ...records.take(10).map((r) => Semantics(
                button: true,
                label:
                    '${l10n.editPeriodRecord}: ${dateFormat.format(r.startDate)}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showRecordEditor(r),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.periodDay,
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 12),
                        Text(dateFormat.format(r.startDate),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.tp(context))),
                        if (r.endDate != null) ...[
                          Text(' - ${dateFormat.format(r.endDate!)}',
                              style: TextStyle(
                                  fontSize: 14, color: AppColors.ts(context))),
                        ] else
                          Text(' (${l10n.ongoing})',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.menstrual,
                                  fontStyle: FontStyle.italic)),
                        const Spacer(),
                        Text(l10n.nDays(r.durationDays),
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ts(context))),
                        const SizedBox(width: 8),
                        Icon(Icons.edit_rounded,
                            size: 16, color: AppColors.ts(context)),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    ).animateSafe(context).fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  /// Düzenleme/silme sonrası profil tarihi kayıtların türevi olarak
  /// eşitlenir: en yeni kaydın başlangıcı = lastPeriodStart. Elle çift
  /// tutmanın ürettiği ayrışma (B-8) böylece tek yönlü akara bağlanır.
  Future<void> _syncProfileToNewestRecord() async {
    final records = ref.read(periodRecordsProvider);
    if (records.isEmpty) return;
    final newest = records.first; // provider startDate'e göre azalan sıralı
    final profile = ref.read(userProfileProvider);
    final current = profile?.lastPeriodStart;
    final same = current != null &&
        current.year == newest.startDate.year &&
        current.month == newest.startDate.month &&
        current.day == newest.startDate.day;
    if (!same) {
      await ref
          .read(userProfileProvider.notifier)
          .saveProfile(lastPeriodStart: newest.startDate);
    }
  }

  Future<void> _showRecordEditor(PeriodRecord record) async {
    final l10n = AppLocalizations.of(context)!;
    final localeStr = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('d MMM yyyy', localeStr);
    final messenger = ScaffoldMessenger.of(context);

    var start = DateTime(
        record.startDate.year, record.startDate.month, record.startDate.day);
    var end = record.endDate != null
        ? DateTime(record.endDate!.year, record.endDate!.month,
            record.endDate!.day)
        : null;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Future<void> pickStart() async {
            final picked = await showDatePicker(
              context: sheetContext,
              initialDate: start,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setSheetState(() {
                start = DateTime(picked.year, picked.month, picked.day);
                if (end != null && end!.isBefore(start)) end = start;
              });
            }
          }

          Future<void> pickEnd() async {
            final picked = await showDatePicker(
              context: sheetContext,
              initialDate: end ?? start,
              firstDate: start,
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setSheetState(
                  () => end = DateTime(picked.year, picked.month, picked.day));
            }
          }

          Widget dateTile({
            required String label,
            required String value,
            required VoidCallback onTap,
            Widget? trailing,
          }) {
            return Semantics(
              button: true,
              label: label,
              value: value,
              child: Material(
                color: AppColors.bg(sheetContext),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Text(label,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ts(sheetContext))),
                        const Spacer(),
                        Text(value,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.tp(sheetContext))),
                        if (trailing != null) trailing,
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: AppColors.sf(sheetContext),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.fromLTRB(
                24, 16, 24, 24 + MediaQuery.viewInsetsOf(sheetContext).bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.dv(sheetContext),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.editPeriodRecord,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tp(sheetContext))),
                const SizedBox(height: 16),
                dateTile(
                  label: l10n.startDateLabel,
                  value: dateFormat.format(start),
                  onTap: pickStart,
                ),
                const SizedBox(height: 8),
                dateTile(
                  label: l10n.endDateLabel,
                  value: end != null ? dateFormat.format(end!) : l10n.ongoing,
                  onTap: pickEnd,
                  trailing: end != null
                      ? IconButton(
                          tooltip: l10n.ongoing,
                          icon: Icon(Icons.close_rounded,
                              size: 18, color: AppColors.ts(sheetContext)),
                          onPressed: () => setSheetState(() => end = null),
                        )
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    await ref
                        .read(periodRecordsProvider.notifier)
                        .updateRecordDates(record.id, start, end);
                    await _syncProfileToNewestRecord();
                    messenger.showSnackBar(SnackBar(
                        content: Text(l10n.recordUpdated),
                        backgroundColor: AppColors.success));
                  },
                  child: Text(l10n.save),
                ),
                TextButton(
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.error),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: sheetContext,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        title: Text(l10n.deleteRecord),
                        content: Text(end != null
                            ? '${dateFormat.format(start)} - ${dateFormat.format(end!)}'
                            : '${dateFormat.format(start)} (${l10n.ongoing})'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.error),
                            child: Text(l10n.delete),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                    await ref
                        .read(periodRecordsProvider.notifier)
                        .deleteRecord(record.id);
                    await _syncProfileToNewestRecord();
                    messenger.showSnackBar(SnackBar(
                        content: Text(l10n.recordDeleted),
                        backgroundColor: AppColors.success));
                  },
                  child: Text(l10n.deleteRecord),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendChart(
    String title,
    List<DailyLog> logs,
    double? Function(DailyLog) valueExtractor,
    Color color,
    String unit,
  ) {
    final dataPoints = <MapEntry<DateTime, double>>[];
    for (final log in logs) {
      final val = valueExtractor(log);
      if (val != null) {
        dataPoints.add(MapEntry(log.date, val));
      }
    }
    dataPoints.sort((a, b) => a.key.compareTo(b.key));

    if (dataPoints.isEmpty) {
      return _emptyCard(title, AppLocalizations.of(context)!.noDataYet);
    }

    final spots = dataPoints.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.15;
    final localeStr = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('d/M', localeStr);

    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.18,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tp(context))),
          const SizedBox(height: 16),
          // Ekran okuyucu için trend özeti: son / en düşük / en yüksek
          Semantics(
            label:
                '$title: ${spots.last.y.toStringAsFixed(1)} $unit. '
                'Min ${minY.toStringAsFixed(1)}, Max ${maxY.toStringAsFixed(1)} $unit.',
            child: ExcludeSemantics(
              child: SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minY - padding.clamp(0.5, 5),
                maxY: maxY + padding.clamp(0.5, 5),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) > 0 ? (maxY - minY) / 4 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.dv(context),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(1),
                            style: TextStyle(
                                fontSize: 10, color: AppColors.ts(context)));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (spots.length / 4).ceilToDouble().clamp(1, 100),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < dataPoints.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              dateFormat.format(dataPoints[idx].key),
                              style: TextStyle(
                                  fontSize: 9, color: AppColors.ts(context)),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final idx = spot.x.toInt();
                        final date = idx >= 0 && idx < dataPoints.length
                            ? dateFormat.format(dataPoints[idx].key)
                            : '';
                        return LineTooltipItem(
                          '$date\n${spot.y.toStringAsFixed(1)} $unit',
                          TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: spots.length <= 15,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: color,
                        strokeWidth: 1.5,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.withValues(alpha: 0.2),
                          color.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
            ),
          ),
        ],
      ),
    ).animateSafe(context).fadeIn(delay: 500.ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _emptyCard(String title, String message) {
    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        borderRadius: 20,
        blur: 0,
        opacity: 0.12,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tp(context))),
            const SizedBox(height: 12),
            Text(message,
                style: TextStyle(
                    fontSize: 14, color: AppColors.ts(context))),
          ],
        ),
      ),
    ).animateSafe(context).fadeIn(duration: 400.ms);
  }
}
