import 'dart:math' as math;
import 'dart:ui' as ui show TextDirection, ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/adaptive_layout.dart';
import '../../core/utils/cycle_utils.dart';
import '../../core/utils/enum_labels.dart';
import '../../core/utils/phase_insights.dart';
import '../../core/utils/ring_segments.dart';
import '../../core/utils/statistics_summary.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../models/enums.dart';
import '../../models/period_record.dart';
import '../../models/daily_log.dart';
import '../../models/user_profile.dart';
import '../../providers/providers.dart';
import '../../services/export_service.dart';
import '../period_history/period_record_editor.dart';
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
    // kaçırdığını bilsin); içerik kilidin ardında bulanık duruyor.
    final locked = ref.watch(accessProvider) == AccessLevel.free;

    final records = ref.watch(periodRecordsProvider);
    final dailyLogs = ref.watch(dailyLogProvider);
    final profile = ref.watch(userProfileProvider);

    // 0 = tüm zamanlar. Aylık pencereler kısa geçmişi olan kullanıcıyı
    // kendi verisinden mahrum bırakıyordu: 12 aydan eski kaydı olan da
    // tamamını görebilmeli.
    final cutoff = _filterMonths == 0
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.now().subtract(Duration(days: _filterMonths * 30));
    final filteredRecords =
        records.where((r) => r.startDate.isAfter(cutoff)).toList();
    final filteredLogs =
        dailyLogs.values.where((l) => l.date.isAfter(cutoff)).toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final meaningfulLogs = dailyLogs.values
        .where((log) =>
            hasMeaningfulDailyData(log) && !log.date.isAfter(today))
        .toList();
    final coverageStart = _filterMonths == 0
        ? (meaningfulLogs.isEmpty
            ? today
            : meaningfulLogs
                .map((log) =>
                    DateTime(log.date.year, log.date.month, log.date.day))
                .reduce((a, b) => a.isBefore(b) ? a : b))
        : today.subtract(Duration(days: _filterMonths * 30));
    final coverage = calculateDataCoverage(
      dailyLogs.values,
      start: coverageStart,
      end: today,
    );
    final monthlyCoverage = calculateMonthlyDataCoverage(
      dailyLogs.values,
      start: coverageStart,
      end: today,
    );

    // Filtre çipleri KARTIN TAMAMINA işler: önceden Ort. Döngü ve
    // Düzenlilik tüm kayıtlardan, Ort. Regl filtreden hesaplanıyordu —
    // aynı kartta iki farklı kapsam (hangi sayının neye baktığı belirsizdi)
    final avgCycle = CycleUtils.calculateAverageCycleLength(filteredRecords);
    // Seçili aralıktaki tüm kayıtlar devam ediyorsa (endDate yok) eski
    // hesap 0/1 = 0 veriyor ve "0,0 gün" yazıyordu — profil değeri kullanılır
    final avgPeriod = CycleUtils.averagePeriodDuration(
        filteredRecords, profile?.averagePeriodLength ?? 5);

    final content = SingleChildScrollView(
        // Kilitliyken kaydırma kapalı: bulanık içerik gezilecek bir şey değil
        physics: locked ? const NeverScrollableScrollPhysics() : null,
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomNavInset(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiç kayıt yoksa: tek seferlik yönlendirme metni
            // (kart içi boşlukların üstünde, tekrarı önler)
            if (records.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: EmptyState(
                    icon: Icons.insights_outlined,
                    title: l10n.statistics,
                    message: l10n.noDataYet,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Doktora götürülecek özet uygulamanın en somut faydası ama
            // ayarların derinliğinde duruyordu — istatistiğin başında olmalı
            _buildDoctorExportButton(l10n, records, dailyLogs, profile)
                .animateSafe(context)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            // Tek parça segmentli filtre: üç ayrı baloncuk yerine
            // birleşik seçici — daha derli toplu, daha "ürün" his
            _buildFilterBar(l10n).animateSafe(context).fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            _sectionHeader(l10n.statsSectionOverview),
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
            _buildDataCoverageCard(l10n, coverage, monthlyCoverage),
            const SizedBox(height: 28),
            _sectionHeader(l10n.statsSectionCharts),
            _buildSymptomChart(l10n, filteredLogs),
            const SizedBox(height: 16),
            _buildMoodChart(l10n, filteredLogs),
            const SizedBox(height: 16),
            _buildPhaseInsights(l10n, filteredLogs, records, profile),
            const SizedBox(height: 16),
            _buildCycleSymptomComparison(
              l10n,
              dailyLogs.values.toList(),
              records,
            ),
            const SizedBox(height: 28),
            _sectionHeader(l10n.statsSectionHistory),
            _buildCycleHistory(l10n, filteredRecords),
            const SizedBox(height: 16),
            _buildTrendChart(
              l10n.temperatureTrend, filteredLogs,
              (log) => log.temperature, AppColors.temperature, '°C',
              records, profile,
            ),
            const SizedBox(height: 16),
            _buildTrendChart(
              l10n.weightTrend, filteredLogs,
              (log) => log.weight, AppColors.weightColor, 'kg',
              records, profile,
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
      );

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(l10n.statistics,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.tp(context))),
        backgroundColor: AppColors.bg(context),
        elevation: 0,
      ),
      body: locked
          ? Stack(
              children: [
                // Kilit ekranı ikon + metinden ibaretti: kullanıcı neyi
                // kaçırdığını görmüyordu. Arkada kendi verisi duruyor —
                // uydurma bir örnek değil, bulanıklaştırılmış gerçek.
                Positioned.fill(
                  child: ImageFiltered(
                    imageFilter:
                        ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: IgnorePointer(child: content),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: AppColors.bg(context).withValues(alpha: 0.55),
                  ),
                ),
                Center(child: _buildLockCard(l10n)),
              ],
            )
          : content,
    );
  }

  /// "Doktoruma özet çıkar": PDF raporu paylaşım sayfasına verir.
  /// Ayarlar > Veri altındaki aynı akış; oradaki giriş de duruyor.
  Widget _buildDoctorExportButton(
    AppLocalizations l10n,
    List<PeriodRecord> records,
    Map<String, DailyLog> dailyLogs,
    UserProfile? profile,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        // Profil yoksa rapor üretilemez (exportPdf profil istiyor)
        onPressed: profile == null
            ? null
            : () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final service = ExportService();
                  final path = await service.exportPdf(
                      profile, records, dailyLogs, l10n);
                  await service.shareFile(path);
                } catch (e) {
                  messenger.showSnackBar(SnackBar(
                    content: Text(l10n.errorOccurred(e.toString())),
                    backgroundColor: AppColors.error,
                  ));
                }
              },
        icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
        label: Text(l10n.doctorSummary),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDeep,
          side: BorderSide(color: AppColors.dv(context)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildLockCard(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.sf(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.dv(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 40, color: AppColors.primaryStrong),
            const SizedBox(height: 12),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/paywall'),
                child: Text(l10n.seePlans),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Birleşik segmentli dönem seçici: 3 ay / 6 ay / 12 ay tek kapsülde
  Widget _buildFilterBar(AppLocalizations l10n) {
    final options = [
      (l10n.last3Months, 3),
      (l10n.last6Months, 6),
      (l10n.last12Months, 12),
      (l10n.allTime, 0),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.sf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dv(context)),
      ),
      child: Row(
        children: [
          for (final (label, months) in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: _filterMonths == months,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _filterMonths = months),
                  child: AnimatedContainer(
                    duration: context.motionDuration(
                        const Duration(milliseconds: 200)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: _filterMonths == months
                          ? const LinearGradient(colors: [
                              AppColors.primaryStrong,
                              AppColors.primaryDeep,
                            ])
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _filterMonths == months
                            ? Colors.white
                            : AppColors.ts(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Sayfa bölümleri: kart yığını tek düze akıyordu — kısa başlıklar
  /// hiyerarşi kurar
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: AppColors.ts(context),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(color: AppColors.tp(context))),
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

  Widget _buildDataCoverageCard(
    AppLocalizations l10n,
    DataCoverage coverage,
    List<MonthlyDataCoverage> monthlyCoverage,
  ) {
    final monthFormat =
        DateFormat('MMM yyyy', Localizations.localeOf(context).toString());
    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.18,
      padding: const EdgeInsets.all(20),
      child: Semantics(
        label: l10n.dataCoverageValue(
          coverage.loggedDays,
          coverage.totalDays,
          coverage.percent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_view_month_rounded,
                    size: 20, color: AppColors.primaryStrong),
                const SizedBox(width: 8),
                Text(
                  l10n.dataCoverage,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tp(context),
                  ),
                ),
                const Spacer(),
                Text(
                  '%${coverage.percent}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryStrong,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: coverage.percent / 100,
                minHeight: 8,
                backgroundColor: AppColors.dv(context),
                color: AppColors.primaryStrong,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.dataCoverageValue(
                coverage.loggedDays,
                coverage.totalDays,
                coverage.percent,
              ),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.ts(context),
              ),
            ),
            if (monthlyCoverage.length > 1) ...[
              const SizedBox(height: 16),
              ...monthlyCoverage.map(
                (month) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: Text(
                          monthFormat.format(month.month),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.ts(context),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: month.percent / 100,
                            minHeight: 6,
                            backgroundColor: AppColors.dv(context),
                            color: AppColors.primaryStrong,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 34,
                        child: Text(
                          '%${month.percent}',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tp(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    )
        .animateSafe(context)
        .fadeIn(delay: 115.ms, duration: 400.ms)
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
    final gapCount = CycleUtils.validCycleGaps(records).length;
    final statItems = <Widget>[
      _statItem(l10n.avgCycle, avgCycle.toStringAsFixed(1), l10n.days,
          Icons.loop_rounded, AppColors.primaryStrong),
      _statItem(l10n.avgPeriod, avgPeriod.toStringAsFixed(1), l10n.days,
          Icons.water_drop_rounded, AppColors.menstrual),
      InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showRegularityInfo(l10n, irregular, gapCount),
        child: _statItem(
            l10n.regularity,
            irregular == null
                ? l10n.insufficientData
                : (irregular ? l10n.irregular : l10n.regular),
            null,
            irregular == true
                ? Icons.info_outline_rounded
                : Icons.check_circle_rounded,
            irregular == null
                ? AppColors.warningText
                : (irregular
                    ? AppColors.warningText
                    : AppColors.fertileWindowText)),
      ),
    ];
    final largeText = usesLargeText(MediaQuery.textScalerOf(context));
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
          if (largeText)
            Column(
              children: [
                for (var i = 0; i < statItems.length; i++) ...[
                  SizedBox(width: double.infinity, child: statItems[i]),
                  if (i < statItems.length - 1) const SizedBox(height: 20),
                ],
              ],
            )
          else
            Row(
              children: [
                for (final item in statItems) Expanded(child: item),
              ],
            ),
          const SizedBox(height: 14),
          // Sayının tek başına anlamı yok: "29,3 gün" iyi mi kötü mü?
          Text(
            l10n.typicalRangeNote(AppConstants.typicalCycleMin,
                AppConstants.typicalCycleMax, AppConstants.typicalPeriodMax),
            style: TextStyle(
                fontSize: 11, height: 1.4, color: AppColors.ts(context)),
          ),
          // Az veriyle hesaplanan ortalama yanıltıcı: kaç döngüden
          // çıktığı söylenmeli
          if (gapCount < AppConstants.minGapsForRegularity) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 13, color: AppColors.warningText),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.lowConfidenceNote(gapCount),
                    style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: AppColors.warningText),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animateSafe(context).fadeIn(delay: 60.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  /// Düzenlilik yargısının ne demek olduğunu açıklar. Ölçütü saklamak
  /// kullanıcıyı yargının karşısında çaresiz bırakıyor.
  void _showRegularityInfo(
      AppLocalizations l10n, bool? irregular, int gapCount) {
    final body = irregular == null
        ? l10n.regularityInfoInsufficient(AppConstants.minGapsForRegularity)
        : (irregular
            ? l10n.regularityInfoIrregular
            : l10n.regularityInfoRegular);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.sf(ctx),
        title: Text(l10n.regularity,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(body,
                  style: const TextStyle(fontSize: 14, height: 1.5)),
              const SizedBox(height: 12),
              Text(l10n.regularityInfoSeeDoctor,
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tp(ctx))),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  /// Genel bakış metriği: kahraman sayı + küçük birim (metrik ölçek
  /// dili). unit null ise değer metin olarak (düzenlilik durumu) yazılır.
  Widget _statItem(
      String label, String value, String? unit, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.08)],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 10),
        if (unit == null)
          Text(value,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color))
        else
          Text.rich(
            TextSpan(
              text: value,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall!
                  .copyWith(color: AppColors.tp(context)),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ts(context),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.ts(context))),
      ],
    );
  }

  Widget _buildSymptomChart(AppLocalizations l10n, List<DailyLog> logs) {
    final top5 = summarizeSymptoms(logs);

    if (top5.isEmpty) {
      return _emptyCard(l10n.symptomFrequency, l10n.noSymptomData);
    }

    // Hikâye cümlesi: son 30 gün vs önceki 30 gün toplam belirti kaydı
    final now = DateTime.now();
    var recent = 0;
    var previous = 0;
    for (final log in logs) {
      final age = now.difference(log.date).inDays;
      if (age < 30) {
        recent += log.symptoms.length;
      } else if (age < 60) {
        previous += log.symptoms.length;
      }
    }
    String? story;
    if (previous > 0 || recent > 0) {
      if (recent > previous) {
        story = l10n.storySymptomsMore(recent, previous);
      } else if (recent < previous) {
        story = l10n.storySymptomsLess(recent, previous);
      } else {
        story = l10n.storySymptomsSame;
      }
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
          if (story != null) ...[
            const SizedBox(height: 4),
            _storyLine(story),
          ],
          const SizedBox(height: 16),
          // Ekran okuyucu için grafik verisi metin özeti olarak sunulur
          Semantics(
            label: top5
                .map((e) =>
                    '${_symptomName(e.type, l10n)}: ${e.count}, '
                    '${l10n.averageSeverity(e.averageSeverity.toStringAsFixed(1))}')
                .join(', '),
            child: ExcludeSemantics(
              child: SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (top5.first.count + 2).toDouble(),
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
                          final name = _symptomName(top5[idx].type, l10n);
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: SizedBox(
                              // 60 px etiketler 5 çubuklu dar grafikte
                              // birbirine değiyordu
                              width: 50,
                              child: Text(
                                name,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 8.5,
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
                        toY: entry.value.count.toDouble(),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: top5
                .map(
                  (summary) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_symptomName(summary.type, l10n)} · '
                      '${l10n.averageSeverity(summary.averageSeverity.toStringAsFixed(1))}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tp(context),
                      ),
                    ),
                  ),
                )
                .toList(),
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
                  // Yüzde lejantta da yazar: dilimi lejanta bağlayan tek
                  // kanal renkti ve ruh hâli paleti pastel — deuteranopiada
                  // sarı/turuncu/yeşil noktalar birbirine karışıyor.
                  // Dilimin içindeki "%38" ile lejanttaki "%38" eşleşiyor.
                  Text(
                      '${_moodName(e.key, l10n)} '
                      '%${(e.value / total * 100).toStringAsFixed(0)}',
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
                      size: 18, color: AppColors.primaryDeep),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.insightLine(
                        _symptomName(insight.symptom, l10n),
                        EnumLabels.phase(insight.phase, l10n),
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

  Widget _buildCycleSymptomComparison(
    AppLocalizations l10n,
    List<DailyLog> logs,
    List<PeriodRecord> records,
  ) {
    final comparison = compareLastTwoCycleSymptoms(
      logs: logs,
      periodStarts: records.map((record) => record.startDate),
      today: DateTime.now(),
    );
    if (records.length < 2 || comparison.isEmpty) {
      return _emptyCard(l10n.cycleOverlayTitle, l10n.noInsightsYet);
    }

    List<FlSpot> spots(Map<int, double> values) {
      final entries = values.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      return entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
          .toList();
    }

    final currentSpots = spots(comparison.current);
    final previousSpots = spots(comparison.previous);
    final allSpots = [...currentSpots, ...previousSpots];
    final maxX = allSpots
        .map((spot) => spot.x)
        .reduce((a, b) => a > b ? a : b);
    final maxY = allSpots
        .map((spot) => spot.y)
        .reduce((a, b) => a > b ? a : b);
    final currentTotal = comparison.current.values
        .fold<double>(0, (total, value) => total + value);
    final previousTotal = comparison.previous.values
        .fold<double>(0, (total, value) => total + value);

    Widget legend(Color color, String label, {bool dashed = false}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < (dashed ? 3 : 1); i++)
                    Container(
                      width: dashed ? 4 : 18,
                      height: 3,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(label,
                style:
                    TextStyle(fontSize: 11, color: AppColors.ts(context))),
          ],
        );

    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.18,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cycleOverlayTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.tp(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.symptomLoadComparison,
            style: TextStyle(fontSize: 12, color: AppColors.ts(context)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              legend(AppColors.primaryStrong, l10n.currentCycleLabel),
              legend(
                AppColors.secondaryStrong,
                l10n.previousCycleLabel,
                dashed: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            label: '${l10n.currentCycleLabel}: '
                '${currentTotal.toStringAsFixed(0)}. '
                '${l10n.previousCycleLabel}: '
                '${previousTotal.toStringAsFixed(0)}.',
            child: ExcludeSemantics(
              child: SizedBox(
                height: 190,
                child: LineChart(
                  LineChartData(
                    minX: 1,
                    maxX: maxX < 2 ? 2.0 : maxX,
                    minY: 0,
                    maxY: maxY + 1,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.dv(context),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: (maxX / 4)
                              .ceilToDouble()
                              .clamp(1, 30)
                              .toDouble(),
                          getTitlesWidget: (value, _) => Text(
                            value.round().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.ts(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touched) => touched
                            .map((spot) => LineTooltipItem(
                                  '${l10n.day} ${spot.x.round()}\n'
                                  '${spot.y.toStringAsFixed(0)}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    lineBarsData: [
                      if (previousSpots.isNotEmpty)
                        LineChartBarData(
                          spots: previousSpots,
                          color: AppColors.secondaryStrong,
                          barWidth: 2,
                          dashArray: const [6, 4],
                          dotData: FlDotData(show: false),
                          isCurved: true,
                        ),
                      if (currentSpots.isNotEmpty)
                        LineChartBarData(
                          spots: currentSpots,
                          color: AppColors.primaryStrong,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          isCurved: true,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animateSafe(context).fadeIn(delay: 240.ms, duration: 400.ms);
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
                        // Tarih aralığı + süre + kalem dar ekranda taşıyordu:
                        // tarih bölümü esner, gerekirse kısalır
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: dateFormat.format(r.startDate),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.tp(context)),
                              children: [
                                if (r.endDate != null)
                                  TextSpan(
                                    text:
                                        ' - ${dateFormat.format(r.endDate!)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.ts(context)),
                                  )
                                else
                                  TextSpan(
                                    text: ' (${l10n.ongoing})',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.menstrual,
                                        fontStyle: FontStyle.italic),
                                  ),
                              ],
                            ),
                            maxLines: usesLargeText(
                                    MediaQuery.textScalerOf(context))
                                ? null
                                : 1,
                            overflow: usesLargeText(
                                    MediaQuery.textScalerOf(context))
                                ? null
                                : TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
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

  /// Kayıt düzenleyici artık ortak: aynı sayfa ücretsiz katmandaki
  /// regl geçmişi ekranından da açılıyor.
  Future<void> _showRecordEditor(PeriodRecord record) =>
      showPeriodRecordEditor(context, ref, record);

  Widget _buildTrendChart(
    String title,
    List<DailyLog> logs,
    double? Function(DailyLog) valueExtractor,
    Color color,
    String unit,
    List<PeriodRecord> records,
    UserProfile? profile,
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

    final cycleLength = ref.watch(effectiveCycleLengthProvider);
    final periodLength = profile?.averagePeriodLength ?? 5;
    final starts = records.map((record) => DateUtils.dateOnly(record.startDate))
        .toList()
      ..sort();
    CyclePhase? phaseOf(DateTime date) {
      DateTime? anchor;
      for (final start in starts) {
        if (!start.isAfter(date)) {
          anchor = start;
        } else {
          break;
        }
      }
      if (anchor == null) return null;
      final rawDay = DateUtils.dateOnly(date).difference(anchor).inDays + 1;
      return CycleUtils.phaseForDay(
        CycleUtils.wrappedCycleDay(rawDay, cycleLength),
        cycleLength,
        periodLength,
      );
    }

    final confirmedOvulation = ref.watch(confirmedOvulationProvider);
    final ovulationDates = profile?.trackingMode == TrackingMode.pregnancy
        ? const <DateTime>[]
        : ovulationMarkersForRange(
            periodStarts: starts,
            cycleLength: cycleLength,
            rangeStart: firstDay,
            rangeEnd: dataPoints.last.key,
            confirmedLatest: confirmedOvulation,
          );

    final spots = dataPoints
        .map((e) => FlSpot(dayOf(e.key), e.value))
        .toList();
    final totalDays = spots.last.x;

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.15;
    final localeStr = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('d/M', localeStr);

    // Hikâye cümlesi: grafik okumayan kullanıcı da değeri alsın —
    // dönem içi net değişim tek cümlede (küçük dalgalanma "yatay" sayılır)
    final l10nStory = AppLocalizations.of(context)!;
    String? story;
    if (spots.length >= 2) {
      final delta = spots.last.y - spots.first.y;
      final threshold = unit == 'kg' ? 0.3 : 0.15;
      if (delta.abs() < threshold) {
        story = l10nStory.storyTrendFlat;
      } else if (delta > 0) {
        story = l10nStory.storyTrendUp(delta.toStringAsFixed(1), unit);
      } else {
        story = l10nStory.storyTrendDown(delta.abs().toStringAsFixed(1), unit);
      }
    }

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
          if (story != null) ...[
            const SizedBox(height: 4),
            _storyLine(story),
          ],
          const SizedBox(height: 16),
          // Ekran okuyucu için trend özeti: son / en düşük / en yüksek
          Semantics(
            label:
                '$title: ${spots.last.y.toStringAsFixed(1)} $unit. '
                'Min ${minY.toStringAsFixed(1)}, Max ${maxY.toStringAsFixed(1)} $unit.'
                '${ovulationDates.isEmpty ? '' : ' ${l10nStory.ovulationMarkerHint}.'}',
            child: ExcludeSemantics(
              child: SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minY - padding.clamp(0.5, 5),
                maxY: maxY + padding.clamp(0.5, 5),
                extraLinesData: ExtraLinesData(
                  verticalLines: ovulationDates
                      .map(
                        (date) => VerticalLine(
                          x: dayOf(date),
                          color: AppColors.ringOvulation
                              .withValues(alpha: 0.75),
                          strokeWidth: 1.5,
                          dashArray: const [5, 4],
                        ),
                      )
                      .toList(),
                ),
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
                  touchCallback: (event, response) {
                    if (event is! FlTapUpEvent) return;
                    final touchedSpots = response?.lineBarSpots;
                    if (touchedSpots == null || touchedSpots.isEmpty) {
                      return;
                    }
                    ref.read(selectedDateProvider.notifier).state =
                        dateOf(touchedSpots.first.x);
                    context.push('/log');
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final phase = phaseOf(dateOf(spot.x));
                        return LineTooltipItem(
                          '${dateFormat.format(dateOf(spot.x))}\n'
                          '${spot.y.toStringAsFixed(1)} $unit'
                          '${phase == null ? '' : '\n${EnumLabels.phase(phase, l10nStory)}'}',
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
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.touch_app_rounded,
                  size: 14, color: AppColors.ts(context)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10nStory.tapChartPointHint,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.ts(context),
                  ),
                ),
              ),
            ],
          ),
          if (ovulationDates.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  width: 14,
                  child: Divider(
                    color: AppColors.ringOvulation,
                    thickness: 1.5,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10nStory.ovulationMarkerHint,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.ts(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animateSafe(context).fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  /// Grafik kartının başlığı altına veriden türetilmiş tek cümle:
  /// sayı-anlatıcı kimliğin metin hali
  Widget _storyLine(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        height: 1.35,
        color: AppColors.ts(context),
      ),
    );
  }

  Widget _emptyCard(String title, String message) {
    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        borderRadius: 20,
        blur: 0,
        opacity: 0.12,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: EmptyState(
          icon: Icons.insights_rounded,
          title: title,
          message: message,
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
