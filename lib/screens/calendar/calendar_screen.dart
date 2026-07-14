
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/cycle_utils.dart';
import '../../core/utils/enum_labels.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/providers.dart';
import '../log/quick_log_sheet.dart';
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

  bool _isPeriodDay(DateTime day, List<PeriodRecord> records) {
    for (final record in records) {
      if (record.containsDate(day)) return true;
    }
    return false;
  }

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
      body: Column(
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
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
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
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.primary),
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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _legendItem(AppColors.periodDay, l10n.periodDayLabel),
                _legendItem(AppColors.predictedPeriod, l10n.predicted),
                _legendItem(AppColors.ovulationDay, l10n.ovulation),
                _legendItem(AppColors.fertileWindow, l10n.fertile),
              ],
            ),
          ).animateSafe(context).fadeIn(delay: 300.ms, duration: 500.ms),
          const Spacer(),
          Padding(
            // Alt bar yüzen bir pill: 112 boşluk olmadan uyarı metni
            // gezinme çubuğunun altında kalıyordu
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
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
      bgColor = AppColors.primary.withValues(alpha: 0.15);
      textColor = AppColors.primary;
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
                    decoration: const BoxDecoration(
                        color: AppColors.secondary, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ),
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

  void _showDayDetailSheet(BuildContext context, DateTime day,
      List<PeriodRecord> records, Map<String, DailyLog> dailyLogs) {
    final dateKey =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final log = dailyLogs[dateKey];
    final isPeriod = _isPeriodDay(day, records);
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
                    // Geçmiş güne hızlı kayıt: sheet kapatılıp quick log açılır
                    if (!day.isAfter(DateTime.now()))
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            showQuickLogSheet(context, ref, day);
                          },
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: Text(l10n.quickLog),
                        ),
                      ),
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
            Text(label,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
