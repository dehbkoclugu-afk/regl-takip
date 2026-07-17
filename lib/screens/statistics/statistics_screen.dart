import 'dart:math' as math;
import 'dart:ui' as ui show TextDirection;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/cycle_utils.dart';
import '../../core/utils/enum_labels.dart';
import '../../core/utils/phase_insights.dart';
import '../../core/utils/ring_segments.dart';
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

    // İstatistik premium kapsamı. Sekme görünür kalır (kullanıcı neyi
    // kaçırdığını bilsin) ama içerik kilit ekranına döner.
    if (ref.watch(accessProvider) == AccessLevel.free) {
      return Scaffold(
        backgroundColor: AppColors.bg(context),
        appBar: AppBar(
          title: Text(l10n.statistics,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.tp(context))),
          backgroundColor: AppColors.bg(context),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 56, color: AppColors.ts(context)),
                const SizedBox(height: 16),
                Text(l10n.premiumLockedTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tp(context))),
                const SizedBox(height: 8),
                Text(l10n.premiumLockedBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: AppColors.ts(context))),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.push('/paywall'),
                  child: Text(l10n.seePlans),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final records = ref.watch(periodRecordsProvider);
    final dailyLogs = ref.watch(dailyLogProvider);
    final profile = ref.watch(userProfileProvider);

    final cutoff = DateTime.now().subtract(Duration(days: _filterMonths * 30));
    final filteredRecords =
        records.where((r) => r.startDate.isAfter(cutoff)).toList();
    final filteredLogs =
        dailyLogs.values.where((l) => l.date.isAfter(cutoff)).toList();

    // Filtre çipleri KARTIN TAMAMINA işler: önceden Ort. Döngü ve
    // Düzenlilik tüm kayıtlardan, Ort. Regl filtreden hesaplanıyordu —
    // aynı kartta iki farklı kapsam (hangi sayının neye baktığı belirsizdi)
    final avgCycle = CycleUtils.calculateAverageCycleLength(filteredRecords);
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
            _buildOverviewCard(l10n, avgCycle, avgPeriod, filteredRecords),
            const SizedBox(height: 16),
            // "Son döngün normaline göre nasıldı?" — filtreden bağımsız:
            // "son" ve "ortalaman" kişisel normun tamamından hesaplanır
            _buildComparisonCard(l10n, records, profile),
            const SizedBox(height: 16),
            // "Yılım": son 12 ay tek halka — düzenlilik bir bakışta.
            // Ring/faz şeridiyle aynı görsel aile (imza dili üçüncü yüzeyde)
            _buildYearRing(l10n, records, profile),
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

  /// "Yılım" halkası: son 365 gün saat yönünde tek çember. Gerçek regl
  /// günleri koyu, geçmiş günlerin fazları soluk tonlarda; ilk kayıttan
  /// önceki dönem boş iz. Düzenli bir yıl eşit aralıklı koyu dilimler
  /// olarak okunur — düzensizlik kendini gösterir.
  Widget _buildYearRing(
      AppLocalizations l10n, List<PeriodRecord> records, UserProfile? profile) {
    if (records.isEmpty || profile == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 364));
    final cycleLen = ref.watch(effectiveCycleLengthProvider);
    final periodLen = profile.averagePeriodLength;
    final segments = ringSegmentsFor(cycleLen, periodLen);
    final sortedStarts = records.map((r) => r.startDate).toList()..sort();

    // Yıl içindeki döngü sayısı (halka merkez özeti)
    final cyclesInYear = sortedStarts
        .where((s) => !s.isBefore(start) && !s.isAfter(today))
        .length;

    Color? colorFor(DateTime date) {
      if (records.any((r) => r.containsDate(date))) {
        return AppColors.ringMenstrual;
      }
      // Tarihten önceki en yakın gerçek başlangıç o günün döngüsünü belirler
      DateTime? anchor;
      for (final s in sortedStarts) {
        if (!s.isAfter(date)) {
          anchor = s;
        } else {
          break;
        }
      }
      if (anchor == null) return null; // ilk kayıttan önce: bilinmiyor
      final day = CycleUtils.dayInCycleFor(date, anchor, cycleLen);
      if (day == null) return null;
      // Fazlar soluk: gerçek regl günleri baskın kalsın
      return segmentColorForDay(segments, day).withValues(alpha: 0.35);
    }

    final dayColors = List<Color?>.generate(
        365, (i) => colorFor(start.add(Duration(days: i))));
    final monthLabels = List<String>.generate(12, (i) {
      final m = DateTime(start.year, start.month + i, 1);
      return DateFormat('MMM', Localizations.localeOf(context).toString())
          .format(m);
    });

    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.18,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.yearRingTitle,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tp(context))),
          const SizedBox(height: 16),
          Semantics(
            label: l10n.yearRingSummary(cyclesInYear),
            child: ExcludeSemantics(
              child: Center(
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: CustomPaint(
                    painter: _YearRingPainter(
                      dayColors: dayColors,
                      monthLabels: monthLabels,
                      trackColor: AppColors.dv(context),
                      labelColor: AppColors.ts(context),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$cyclesInYear',
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.tp(context))),
                          Text(l10n.yearRingCycles,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: AppColors.ts(context))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animateSafe(context)
        .fadeIn(delay: 110.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  /// Son döngü ve son regl, kullanıcının kendi ortalamasıyla kıyaslanır
  /// (Clue'nun sevilen deseni: "normalin nasıl?" sorusuna tek bakış).
  Widget _buildComparisonCard(
      AppLocalizations l10n, List<PeriodRecord> records, UserProfile? profile) {
    // Son tamamlanmış döngü = son iki başlangıç arası
    final starts = records.map((r) => r.startDate).toList()..sort();
    if (starts.length < 2) return const SizedBox.shrink();

    final lastGap =
        starts[starts.length - 1].difference(starts[starts.length - 2]).inDays;
    final avgCycleAll = CycleUtils.calculateAverageCycleLength(records);
    final avgPeriodAll = CycleUtils.averagePeriodDuration(
        records, profile?.averagePeriodLength ?? 5);

    PeriodRecord? lastCompleted;
    for (final r in records) {
      if (r.endDate != null &&
          (lastCompleted == null ||
              r.startDate.isAfter(lastCompleted.startDate))) {
        lastCompleted = r;
      }
    }

    String diffText(num value, double average) {
      final diff = (value - average).round();
      if (diff > 0) return l10n.vsAverageMore(diff);
      if (diff < 0) return l10n.vsAverageLess(-diff);
      return l10n.vsAverageSame;
    }

    Widget line(IconData icon, Color color, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(text,
                    style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.tp(context))),
              ),
            ],
          ),
        );

    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.18,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.cycleComparison,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tp(context))),
          const SizedBox(height: 12),
          line(
            Icons.loop_rounded,
            AppColors.isDark(context)
                ? AppColors.primaryLight
                : AppColors.primaryStrong,
            '${l10n.lastCycleLength(lastGap)} — '
            '${diffText(lastGap, avgCycleAll)}',
          ),
          if (lastCompleted != null)
            line(
              Icons.water_drop_rounded,
              AppColors.isDark(context)
                  ? AppColors.menstrual
                  : AppColors.menstrualText,
              '${l10n.lastPeriodLength(lastCompleted.durationDays)} — '
              '${diffText(lastCompleted.durationDays, avgPeriodAll)}',
            ),
        ],
      ),
    )
        .animateSafe(context)
        .fadeIn(delay: 90.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
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
    ).animateSafe(context).fadeIn(delay: 60.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
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
                // Değer çubuğun üstünde kalıcı yazılır: dokunma kapalıyken
                // gören kullanıcı yalnız göreli yükseklik görüyordu (ekran
                // okuyucu özeti sayı alırken görene sayı yoktu)
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.transparent,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 2,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        BarTooltipItem(
                      rod.toY.round().toString(),
                      TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tp(context),
                      ),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      // İki satırlık tam ad için yer; 4 harfe kırpma
                      // ("Baş ", "Kram") TR'de hiçbir şey ayırt etmiyordu
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < top5.length) {
                          final name = _symptomName(top5[idx].key, l10n);
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: SizedBox(
                              width: 60,
                              child: Text(
                                name,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 9,
                                    height: 1.15,
                                    color: AppColors.ts(context)),
                              ),
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
    ).animateSafe(context).fadeIn(delay: 120.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
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
                      final sliceColor = colors[e.key] ?? AppColors.moodNeutral;
                      // Soluk pastel dilimde beyaz yüzde okunmuyor (~1.4:1):
                      // dilimin parlaklığına göre koyu/beyaz metin seçilir
                      final titleColor = sliceColor.computeLuminance() > 0.5
                          ? AppColors.textPrimary
                          : Colors.white;
                      return PieChartSectionData(
                        color: sliceColor,
                        value: e.value.toDouble(),
                        title: '$pct%',
                        radius: 50,
                        titleStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: titleColor),
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
    ).animateSafe(context).fadeIn(delay: 180.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
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

    // Motor core'da (topPhaseSymptoms): koç satırı ve faz-ipucu bildirimi
    // ile aynı hesap. Burada filtreli loglar beslenir (ekranın kapsamı).
    final insights = topPhaseSymptoms(
      logs: logs,
      periodStarts: records.map((r) => r.startDate).toList(),
      cycleLength: ref.watch(effectiveCycleLengthProvider),
      periodLength: profile.averagePeriodLength,
    );

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
                        _symptomName(insight.symptom, l10n),
                        _phaseNameFor(insight.phase, l10n),
                        insight.percent,
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
    ).animateSafe(context).fadeIn(delay: 220.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
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
    ).animateSafe(context).fadeIn(delay: 260.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
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

    // x = ilk ölçümden itibaren GÜN: önceden x liste indeksiydi, seyrek
    // veri (bir haftada 3 ölçüm + iki ay boşluk) eşit aralıklı çizilip
    // eğilimin biçimini çarpıtıyordu
    final firstDay = DateTime(dataPoints.first.key.year,
        dataPoints.first.key.month, dataPoints.first.key.day);
    double dayOf(DateTime d) =>
        DateTime(d.year, d.month, d.day).difference(firstDay).inDays.toDouble();
    DateTime dateOf(double x) => firstDay.add(Duration(days: x.round()));

    final spots = dataPoints
        .map((e) => FlSpot(dayOf(e.key), e.value))
        .toList();
    final totalDays = spots.last.x;

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
                      interval:
                          (totalDays / 4).ceilToDouble().clamp(1, 3650),
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value > totalDays) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dateFormat.format(dateOf(value)),
                            style: TextStyle(
                                fontSize: 9, color: AppColors.ts(context)),
                          ),
                        );
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
                        return LineTooltipItem(
                          '${dateFormat.format(dateOf(spot.x))}\n'
                          '${spot.y.toStringAsFixed(1)} $unit',
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
    ).animateSafe(context).fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
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

/// Son 365 günü saat yönünde tek çember olarak çizer: gün başına ince bir
/// yay dilimi. Ay başlangıçları dış kenarda kısa adlarla işaretlenir.
class _YearRingPainter extends CustomPainter {
  final List<Color?> dayColors;
  final List<String> monthLabels;
  final Color trackColor;
  final Color labelColor;

  static const _stroke = 22.0;

  _YearRingPainter({
    required this.dayColors,
    required this.monthLabels,
    required this.trackColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Dışta ay etiketlerine yer bırak
    final radius = size.width / 2 - _stroke / 2 - 18;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final total = dayColors.length;
    final sweepPerDay = 2 * math.pi / total;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = trackColor.withValues(alpha: 0.5);
    canvas.drawCircle(center, radius, trackPaint);

    // Ardışık aynı renkli günleri tek yayda birleştir (365 ayrı çizim
    // yerine tipik ~40 yay — hem hızlı hem dikişsiz)
    var runStart = 0;
    while (runStart < total) {
      final color = dayColors[runStart];
      var runEnd = runStart;
      while (runEnd + 1 < total && dayColors[runEnd + 1] == color) {
        runEnd++;
      }
      if (color != null) {
        final startAngle = -math.pi / 2 + runStart * sweepPerDay;
        final sweep = (runEnd - runStart + 1) * sweepPerDay;
        canvas.drawArc(
          rect,
          startAngle,
          sweep,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = _stroke
            ..color = color,
        );
      }
      runStart = runEnd + 1;
    }

    // Ay etiketleri: her ayın halkadaki başlangıç açısına
    final labelRadius = size.width / 2 - 7;
    for (var i = 0; i < monthLabels.length; i++) {
      final angle = -math.pi / 2 + (i * total / 12) * sweepPerDay;
      final pos = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: monthLabels[i],
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        // intl paketi de TextDirection tanımlıyor — dart:ui'ninki kastedilen
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_YearRingPainter oldDelegate) =>
      oldDelegate.dayColors != dayColors ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.labelColor != labelColor;
}
