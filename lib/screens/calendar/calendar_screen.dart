
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/access.dart';
import '../../core/utils/cycle_utils.dart';
import '../../core/utils/enum_labels.dart';
import '../../core/utils/phase_pattern.dart';
import '../../core/utils/ring_segments.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/providers.dart';
import '../log/quick_log_sheet.dart';
import '../period_history/period_record_editor.dart';
import '../../models/daily_log.dart';
import '../../models/enums.dart';
import '../../models/period_record.dart';
import '../../models/user_profile.dart';
import '../../core/utils/motion.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Uzun-bas önizleme baloncuğu: sheet törenine girmeden hızlı bakış
  OverlayEntry? _peekEntry;
  Timer? _peekTimer;

  /// Renk anlamları her açılışta yer kaplıyordu. İlk birkaç kullanımdan
  /// sonra kullanıcı renkleri biliyor; kapatılabilir ve tercih kalıcı.
  static const String _legendHiddenKey = 'calendar_legend_hidden';
  bool _legendHidden = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final hidden = prefs.getBool(_legendHiddenKey) ?? false;
      if (mounted && hidden) setState(() => _legendHidden = true);
    });
  }

  Future<void> _setLegendHidden(bool hidden) async {
    setState(() => _legendHidden = hidden);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_legendHiddenKey, hidden);
  }

  @override
  void dispose() {
    _removePeek();
    super.dispose();
  }

  void _removePeek() {
    _peekTimer?.cancel();
    _peekTimer = null;
    _peekEntry?.remove();
    _peekEntry = null;
  }

  /// Günün özetini geçici baloncukta gösterir; parmağı kaldırınca sheet
  /// açılmaz, baloncuk 2,5 sn sonra kendiliğinden kaybolur.
  void _showDayPeek(DateTime day, List<PeriodRecord> records,
      Map<String, DailyLog> dailyLogs) {
    _removePeek();
    HapticFeedback.lightImpact();

    final l10n = AppLocalizations.of(context)!;
    final profile = ref.read(userProfileProvider);
    final locale = Localizations.localeOf(context).toString();

    final isPeriod = _isPeriodDay(day, records);
    var isOvulation = false;
    var isFertile = false;
    var isPredicted = false;
    final lastStart = profile?.lastPeriodStart;
    if (profile?.trackingMode != TrackingMode.pregnancy &&
        lastStart != null) {
      final cycleLen = ref.read(effectiveCycleLengthProvider);
      isOvulation = CycleUtils.isOvulationDay(day, lastStart, cycleLen);
      isFertile = CycleUtils.isInFertileWindow(day, lastStart, cycleLen);
      isPredicted = !isPeriod &&
          CycleUtils.isPredictedPeriodDay(
              day, lastStart, cycleLen, profile!.averagePeriodLength);
    }
    final dateKey =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final log = dailyLogs[dateKey];

    final states = <(String, Color)>[
      if (isPeriod) (l10n.periodDayLabel, AppColors.ringMenstrual),
      if (isPredicted) (l10n.predicted, AppColors.primaryStrong),
      if (isOvulation) (l10n.ovulation, AppColors.ringOvulation),
      if (isFertile) (l10n.fertile, AppColors.fertileWindowText),
      if (log != null && log.symptoms.isNotEmpty)
        (l10n.nSymptoms(log.symptoms.length), AppColors.primaryDeep),
      if (log != null && log.symptoms.isEmpty)
        (l10n.dayHasRecord, AppColors.primaryDeep),
    ];

    final isDark = AppColors.isDark(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 64,
        left: 36,
        right: 36,
        child: IgnorePointer(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, (1 - t) * -6),
                child: child,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardDark
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('d MMMM EEEE', locale).format(day),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.tp(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (states.isEmpty)
                      Text(
                        l10n.noDataYet,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.ts(context),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final (label, color) in states)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry);
    _peekEntry = entry;
    _peekTimer =
        Timer(const Duration(milliseconds: 2500), _removePeek);
  }

  /// Günün düştüğü regl kaydı; yoksa null.
  PeriodRecord? _recordForDay(DateTime day, List<PeriodRecord> records) {
    for (final record in records) {
      if (record.containsDate(day)) return record;
    }
    return null;
  }

  bool _isPeriodDay(DateTime day, List<PeriodRecord> records) =>
      _recordForDay(day, records) != null;

  // Faz-adaptif vurgu (kontrollü): "bugün" işareti güncel fazın rengini
  // giyer — uygulama yaşayan bir döngüyü izlediğini hissettirir.
  // Kapsam bilinçli dar: yalnız bugün vurgusu; gerisi nötr kalır.
  Color _phaseRingColor(CyclePhase phase) => switch (phase) {
        CyclePhase.menstrual => AppColors.ringMenstrual,
        CyclePhase.follicular => AppColors.ringFollicular,
        CyclePhase.ovulation => AppColors.ringOvulation,
        CyclePhase.luteal => AppColors.ringLuteal,
      };

  Color _phaseTextColor(CyclePhase phase, bool isDark) => isDark
      ? _phaseRingColor(phase)
      : switch (phase) {
          CyclePhase.menstrual => AppColors.menstrualText,
          CyclePhase.follicular => AppColors.follicularText,
          CyclePhase.ovulation => AppColors.ovulationText,
          CyclePhase.luteal => AppColors.lutealText,
        };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(userProfileProvider);
    final records = ref.watch(periodRecordsProvider);
    final dailyLogs = ref.watch(dailyLogProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(
          l10n.calendar,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.tp(context),
          ),
        ),
        backgroundColor: AppColors.bg(context),
        elevation: 0,
      ),
      // Spacer kalktı: içerik doğal akar, küçük ekranda kaydırılabilir
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 92),
        child: Column(
        children: [
          GlassCard(
            borderRadius: 20,
            blur: 0,
            opacity: 0.18,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: TableCalendar(
              firstDay: DateTime(2020, 1, 1),
              lastDay: DateTime(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              locale: Localizations.localeOf(context).toString(),
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                // Log ekranı açıldığında bu gün seçili gelsin
                ref.read(selectedDateProvider.notifier).state = selectedDay;
                _showDayDetailSheet(context, selectedDay, records, dailyLogs);
              },
              // Uzun basış: sheet açmadan hafif önizleme baloncuğu
              onDayLongPressed: (day, _) =>
                  _showDayPeek(day, records, dailyLogs),
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              // setState: alttaki faz şeridi görünen aya göre çiziliyor
              onPageChanged: (focusedDay) =>
                  setState(() => _focusedDay = focusedDay),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tp(context),
                ),
                leftChevronIcon: const Icon(Icons.chevron_left_rounded,
                    color: AppColors.primary),
                rightChevronIcon: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.primary),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ts(context)),
                weekendStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ts(context)),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.tp(context)),
                weekendTextStyle: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.tp(context)),
                todayDecoration: BoxDecoration(
                  color: _phaseRingColor(ref.watch(currentCyclePhaseProvider))
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _phaseTextColor(
                        ref.watch(currentCyclePhaseProvider),
                        AppColors.isDark(context))),
                selectedDecoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                selectedTextStyle: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (ctx, day, focused) =>
                    _buildDayCell(day, profile, records, dailyLogs, false),
                todayBuilder: (ctx, day, focused) =>
                    _buildDayCell(day, profile, records, dailyLogs, true),
              ),
            ),
          ).animateSafe(context).fadeIn(duration: 500.ms),
          // Takvim ile faz şeridi arası nefes: şerit karta yapışıktı
          const SizedBox(height: 20),
          // Ring'in faz haritası dili takvimde: görünen ayın günleri faz
          // renkleriyle ince bir şerit — ay bir bakışta "nasıl akacak"
          _buildMonthPhaseStrip(profile, records)
              .animateSafe(context)
              .fadeIn(delay: 150.ms, duration: 400.ms),
          const SizedBox(height: 16),
          // Görünen ayın tek satırlık özeti: ay geçişinde bağlam
          // kayboluyordu ("bu ayda ne oldu?" sorusu cevapsızdı)
          _buildMonthSummary(l10n, records, dailyLogs)
              .animateSafe(context)
              .fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 12),
          // Efsane kapatılabilir: renk anlamları ilk birkaç kullanımdan
          // sonra biliniyor ama her açılışta yer kaplıyordu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _legendHidden
                ? Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _setLegendHidden(false),
                      icon: const Icon(Icons.help_outline_rounded, size: 16),
                      label: Text(l10n.showLegend),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.ts(context),
                          textStyle: const TextStyle(fontSize: 12)),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _legendItem(
                                AppColors.periodDay, l10n.periodDayLabel),
                            _legendItem(
                                AppColors.predictedPeriod, l10n.predicted),
                            _legendItem(
                                AppColors.ovulationDay, l10n.ovulation),
                            _legendItem(
                                AppColors.fertileWindow, l10n.fertile),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _setLegendHidden(true),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        tooltip: l10n.hideLegend,
                        color: AppColors.ts(context),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
          ).animateSafe(context).fadeIn(delay: 300.ms, duration: 500.ms),
          // Spacer uyarıyı en dibe itip üstte ölü boşluk bırakıyordu —
          // içerik doğal akışında, uyarı hemen lejantın altında
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.ts(context).withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.healthDisclaimer,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.ts(context).withValues(alpha: 0.6),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, UserProfile? profile,
      List<PeriodRecord> records, Map<String, DailyLog> dailyLogs, bool isToday) {
    final l10n = AppLocalizations.of(context)!;
    final isPeriod = _isPeriodDay(day, records);
    final dateKey =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final hasLog = dailyLogs.containsKey(dateKey);

    bool isOvulation = false;
    bool isFertile = false;
    bool isPredicted = false;

    // Hamilelik modunda tahmin/ovülasyon işaretleri yanıltıcı — gösterme
    final showPredictions = profile?.trackingMode != TrackingMode.pregnancy;
    final lastStart = profile?.lastPeriodStart;
    if (showPredictions && lastStart != null) {
      final cycleLen = ref.read(effectiveCycleLengthProvider);
      final periodLen = profile!.averagePeriodLength;
      isOvulation = CycleUtils.isOvulationDay(day, lastStart, cycleLen);
      isFertile = CycleUtils.isInFertileWindow(day, lastStart, cycleLen);
      // 3 döngü ileriye tahmini adet günleri
      isPredicted = !isPeriod &&
          CycleUtils.isPredictedPeriodDay(day, lastStart, cycleLen, periodLen);
    }

    Color? bgColor;
    Color textColor = AppColors.tp(context);
    // Tahmin günü gerçek regl gününden yalnız renk tonuyla ayrılıyordu:
    // renk körlüğünde ikisi aynı görünür, kesikli olmayan bir çerçeve ekle
    Border? border;

    if (isPeriod) {
      bgColor = AppColors.periodDay;
      textColor = Colors.white;
    } else if (isPredicted) {
      bgColor = AppColors.periodDayLight;
      textColor = AppColors.primaryDark;
      border = Border.all(color: AppColors.periodDay, width: 1.5);
    } else if (isOvulation) {
      bgColor = AppColors.ovulationDay;
      textColor = Colors.white;
    } else if (isFertile) {
      bgColor = AppColors.fertileWindowLight;
      textColor = AppColors.fertileWindowText;
    } else if (isToday) {
      final currentPhase = ref.watch(currentCyclePhaseProvider);
      bgColor = _phaseRingColor(currentPhase).withValues(alpha: 0.15);
      textColor = _phaseTextColor(currentPhase, AppColors.isDark(context));
    }

    // Renk tek başına bilgi taşıyordu: ekran okuyucu yalnız gün sayısını
    // okuyordu. Durum etiketleri sesli okunsun.
    final states = <String>[
      if (isPeriod) l10n.periodDayLabel,
      if (isPredicted) l10n.predicted,
      if (isOvulation) l10n.ovulation,
      if (isFertile) l10n.fertile,
      if (hasLog) l10n.dayHasRecord,
    ];

    return Semantics(
      label: states.isEmpty
          ? '${day.day}'
          : '${day.day}, ${states.join(', ')}',
      child: ExcludeSemantics(
        child: Container(
          margin: const EdgeInsets.all(3),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: border,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              if (hasLog)
                Positioned(
                  bottom: 2,
                  child: Container(
                    width: 5,
                    height: 5,
                    // Bordo: pembe regl zemininde de okunur (mor marka
                    // noktalarından çekildi)
                    decoration: const BoxDecoration(
                        color: AppColors.primaryDeep, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Görünen ayın faz şeridi: ring segment renkleriyle gün gün ince bant,
  /// gerçek regl günleri kayıtlardan, bugün üstte nokta ile işaretli.
  /// Dekoratif (gün hücreleri + lejant zaten anlatıyor) — semantics dışı.
  Widget _buildMonthPhaseStrip(
      UserProfile? profile, List<PeriodRecord> records) {
    final lastStart = profile?.lastPeriodStart;
    if (profile == null ||
        lastStart == null ||
        profile.trackingMode == TrackingMode.pregnancy) {
      return const SizedBox.shrink();
    }

    final cycleLen = ref.watch(effectiveCycleLengthProvider);
    final segments = ringSegmentsFor(cycleLen, profile.averagePeriodLength);
    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final trackColor = AppColors.dv(context);

    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 6,
              child: Row(
                children: [
                  for (var d = 1; d <= daysInMonth; d++)
                    Expanded(
                      child: Center(
                        child: DateTime(_focusedDay.year, _focusedDay.month,
                                    d) ==
                                today
                            ? Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.tp(context),
                                  shape: BoxShape.circle,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 5,
                child: Row(
                  children: [
                    for (var d = 1; d <= daysInMonth; d++)
                      Expanded(
                        child: Builder(builder: (context) {
                          final color = _stripColorFor(
                            DateTime(
                                _focusedDay.year, _focusedDay.month, d),
                            records,
                            lastStart,
                            cycleLen,
                            segments,
                            trackColor,
                          );
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0.5),
                            color: color,
                            // Doku modu: renk + desen çift kodlama
                            foregroundDecoration:
                                ref.watch(phasePatternProvider)
                                    ? patternOverlayFor(color)
                                    : null,
                          );
                        }),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _stripColorFor(
    DateTime date,
    List<PeriodRecord> records,
    DateTime lastStart,
    int cycleLen,
    List<RingSegment> segments,
    Color trackColor,
  ) {
    // Gerçek regl günü tahminin önünde
    if (_isPeriodDay(date, records)) return AppColors.ringMenstrual;
    final day = CycleUtils.dayInCycleFor(date, lastStart, cycleLen);
    if (day == null) return trackColor;
    return segmentColorForDay(segments, day);
  }

  /// Görünen ayın tek satırlık özeti + bugüne dönüş.
  ///
  /// Önceki aya gidince "bu ayda ne oldu" sorusu cevapsız kalıyordu ve
  /// birkaç ay geriye kaydıran kullanıcı bugüne elle dönmek zorundaydı.
  Widget _buildMonthSummary(AppLocalizations l10n,
      List<PeriodRecord> records, Map<String, DailyLog> dailyLogs) {
    final now = DateTime.now();
    final isCurrentMonth =
        _focusedDay.year == now.year && _focusedDay.month == now.month;

    // Görünen ayın gün sayısı: bir sonraki ayın 0. günü
    final daysInMonth =
        DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    var periodDays = 0;
    var loggedDays = 0;
    for (var d = 1; d <= daysInMonth; d++) {
      final day = DateTime(_focusedDay.year, _focusedDay.month, d);
      if (_isPeriodDay(day, records)) periodDays++;
      final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-'
          '${day.day.toString().padLeft(2, '0')}';
      if (dailyLogs.containsKey(key)) loggedDays++;
    }

    final parts = <String>[
      if (periodDays > 0) l10n.monthPeriodDays(periodDays),
      if (loggedDays > 0) l10n.monthLoggedDays(loggedDays),
    ];
    final summary = parts.isEmpty ? l10n.monthNoRecords : parts.join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              summary,
              style: TextStyle(fontSize: 12, color: AppColors.ts(context)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isCurrentMonth)
            TextButton(
              onPressed: () => setState(() => _focusedDay = now),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryStrong,
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                  visualDensity: VisualDensity.compact),
              child: Text(l10n.backToToday),
            ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: AppColors.ts(context))),
      ],
    );
  }

  /// Seçilen günde regl başlatır. Ana ekrandaki butonla aynı sözleşme:
  /// onay diyaloğu yerine 6 saniyelik geri al.
  ///
  /// Ana ekrandan farklı olarak burada devam eden bir kayıt varken de
  /// çağrılabiliyor ve `startPeriod` o durumda ya devam eden kaydı kapatıyor
  /// ya da (gün kaydın başlangıcında/öncesindeyse) mevcut kaydı geri
  /// döndürüyor. Geri al bunları bilmezse kullanıcının eski kaydını siler
  /// ya da kapanmış bir kaydı açık sanır — bu yüzden önceki durum önce
  /// yakalanır.
  Future<void> _startPeriodOn(DateTime day) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final recordsNotifier = ref.read(periodRecordsProvider.notifier);
    final profileNotifier = ref.read(userProfileProvider.notifier);
    final prevProfile = ref.read(userProfileProvider);

    final before = ref.read(periodRecordsProvider);
    final idsBefore = before.map((r) => r.id).toSet();
    final ongoingBefore =
        before.where((r) => r.isOngoing).map((r) => r.id).toList();

    HapticFeedback.mediumImpact();
    final record = await recordsNotifier.startPeriod(day);
    // Mevcut bir kayıt döndürüldüyse yeni kayıt oluşmamıştır
    final created = !idsBefore.contains(record.id);
    await profileNotifier.saveProfile(lastPeriodStart: record.startDate);

    messenger.showSnackBar(SnackBar(
      content: Text(l10n.periodMarkedStarted),
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
        label: l10n.undo,
        onPressed: () async {
          if (created) {
            await recordsNotifier.deleteRecord(record.id);
          }
          // Kapatılmış olabilecek kayıtlar yeniden açılır
          for (final id in ongoingBefore) {
            if (id != record.id) await recordsNotifier.reopenRecord(id);
          }
          if (prevProfile != null) {
            await profileNotifier.updateProfile(prevProfile);
          } else {
            profileNotifier.refresh();
          }
        },
      ),
    ));
  }

  void _showDayDetailSheet(BuildContext context, DateTime day,
      List<PeriodRecord> records, Map<String, DailyLog> dailyLogs) {
    final dateKey =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final log = dailyLogs[dateKey];
    final isPeriod = _isPeriodDay(day, records);
    // Gün bir kayda düşüyorsa eylem "düzenle", düşmüyorsa "burada başladı"
    final recordForDay = _recordForDay(day, records);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateStr = DateFormat('d MMMM yyyy, EEEE', locale).format(day);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.25,
        maxChildSize: 0.7,
        expand: false,
        builder: (sheetContext, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          // Opak sheet: cam dili bırakıldı
          child: Container(
              decoration: BoxDecoration(
                color: AppColors.sf(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: AppColors.dv(context),
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.dv(context),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(dateStr,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.tp(context))),
                    const SizedBox(height: 16),
                    if (isPeriod)
                      _chip(Icons.water_drop, l10n.periodDayLabel, AppColors.menstrual),
                    if (log?.mood != null)
                      _chip(
                          Icons.emoji_emotions,
                          l10n.moodLabel(
                              EnumLabels.mood(log!.mood!.type, l10n)),
                          AppColors.moodHappy),
                    if (log != null && log.symptoms.isNotEmpty)
                      _chip(Icons.monitor_heart,
                          l10n.nSymptoms(log.symptoms.length), AppColors.secondary),
                    if (log?.temperature != null)
                      _chip(Icons.thermostat,
                          '${log!.temperature!.toStringAsFixed(1)}°C', AppColors.warning),
                    if (log != null && log.waterIntake > 0)
                      _chip(Icons.water_drop_outlined,
                          l10n.nGlassesWater(log.waterIntake), AppColors.water),
                    if (log == null && !isPeriod)
                      Text(l10n.noRecordForDay,
                          style: TextStyle(
                              fontSize: 14, color: AppColors.ts(context))),
                    const SizedBox(height: 16),
                    // Regl eylemi bilerek premium kapısının dışında: takvim
                    // ücretsiz katmanın vaadinin parçası ve o katmanda
                    // buradan hiçbir şey işaretlenemiyordu — gün sayfası
                    // salt okunur bir kartondu
                    if (!day.isAfter(DateTime.now())) ...[
                      SizedBox(
                        width: double.infinity,
                        child: recordForDay != null
                            ? OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(sheetContext).pop();
                                  showPeriodRecordEditor(
                                      context, ref, recordForDay);
                                },
                                icon: const Icon(Icons.edit_calendar_rounded,
                                    size: 18),
                                label: Text(l10n.editPeriodRecord),
                              )
                            : OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(sheetContext).pop();
                                  _startPeriodOn(day);
                                },
                                icon: const Icon(Icons.water_drop_rounded,
                                    size: 18),
                                label: Text(l10n.periodStartedOnThisDay),
                              ),
                      ),
                      const SizedBox(height: 8),
                      // Günlük kayıt (akış, ruh hâli, semptom) premium kapsamı
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            if (!ensurePremiumAccess(context, ref)) return;
                            showQuickLogSheet(context, ref, day);
                          },
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: Text(l10n.quickLog),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            // Metin token renginin kendisiyle yazılmaz (moodHappy sarısı
            // gibi pasteller açık zeminde okunmuyor) — ikon rengi taşır,
            // metin standart birincil renkte kalır
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tp(context))),
          ],
        ),
      ),
    );
  }
}
