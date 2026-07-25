import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/access.dart';
import '../../../core/utils/cycle_utils.dart';
import '../../../core/utils/phase_pattern.dart';
import '../../../core/utils/ring_segments.dart';
import '../../../models/enums.dart';
import '../../../providers/providers.dart';
import '../../log/quick_log_sheet.dart';

/// Ana ekranda 7 günlük mini şerit: dün/bugün/yarın bağlamı takvime
/// inmeden okunur. Takvimdeki ay şeridinin küçük kardeşi — imza faz
/// haritası dilinin beşinci yüzeyi. Geçmiş/bugün hücresine dokunmak
/// o günün hızlı kaydını açar.
class WeekStrip extends ConsumerWidget {
  const WeekStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final lastStart = profile?.lastPeriodStart;
    if (profile == null ||
        lastStart == null ||
        profile.trackingMode == TrackingMode.pregnancy) {
      return const SizedBox.shrink();
    }

    final cycleLen = ref.watch(effectiveCycleLengthProvider);
    final segments = ringSegmentsFor(cycleLen, profile.averagePeriodLength);
    final records = ref.watch(periodRecordsProvider);
    final logs = ref.watch(dailyLogProvider);
    final locale = Localizations.localeOf(context).toString();
    final weekdayFmt = DateFormat.E(locale);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Row(
      children: [
        for (var offset = -3; offset <= 3; offset++)
          Expanded(
            child: _buildDayCell(
              context,
              ref,
              date: today.add(Duration(days: offset)),
              today: today,
              records: records,
              logs: logs,
              lastStart: lastStart,
              cycleLen: cycleLen,
              segments: segments,
              weekdayFmt: weekdayFmt,
            ),
          ),
      ],
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    WidgetRef ref, {
    required DateTime date,
    required DateTime today,
    required List records,
    required Map logs,
    required DateTime lastStart,
    required int cycleLen,
    required List<RingSegment> segments,
    required DateFormat weekdayFmt,
  }) {
    final isToday = date == today;
    final isFuture = date.isAfter(today);

    // Gerçek regl günü tahminin önünde; gelecek günler tahmin — soluk
    final isPeriod = records.any((r) => r.containsDate(date));
    Color barColor;
    if (isPeriod) {
      barColor = AppColors.ringMenstrual;
    } else {
      final day = CycleUtils.dayInCycleFor(date, lastStart, cycleLen);
      barColor = day == null
          ? AppColors.dv(context)
          : segmentColorForDay(segments, day);
    }
    if (isFuture) barColor = barColor.withValues(alpha: 0.45);

    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final hasLog = logs[dateKey] != null;

    final numberColor = isToday ? AppColors.tp(context) : AppColors.ts(context);

    return Semantics(
      button: !isFuture,
      label: DateFormat.MMMEd(weekdayFmt.locale).format(date),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isFuture
            ? null
            : () {
                if (!ensurePremiumAccess(context, ref)) return;
                showQuickLogSheet(context, ref, date);
              },
        onLongPress: isFuture
            ? null
            : () {
                if (!ensurePremiumAccess(context, ref)) return;
                _showFlowQuickPick(context, ref, date);
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                weekdayFmt.format(date),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ts(context),
                ),
              ),
              const SizedBox(height: 4),
              // Bugün: dolu rozet — şeritte "buradasın" işareti
              Container(
                width: 30,
                height: 30,
                decoration: isToday
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        color: barColor.withValues(alpha: 0.18),
                        border: Border.all(color: barColor, width: 1.5),
                      )
                    : null,
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                    color: numberColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                // Doku modu: renk + desen çift kodlama
                foregroundDecoration: ref.watch(phasePatternProvider)
                    ? patternOverlayFor(
                        barColor,
                        radius: BorderRadius.circular(3),
                      )
                    : null,
              ),
              const SizedBox(height: 4),
              // Kayıt noktası: o güne günlük girildiyse
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasLog ? AppColors.primaryDeep : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFlowQuickPick(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<FlowIntensity?>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.flow,
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              for (final option in [
                (FlowIntensity.light, l10n.light, 1),
                (FlowIntensity.normal, l10n.medium, 2),
                (FlowIntensity.heavy, l10n.heavy, 3),
                (FlowIntensity.veryHeavy, l10n.veryHeavy, 4),
              ])
                ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      option.$3,
                      (_) => const Icon(
                        Icons.water_drop_rounded,
                        size: 14,
                        color: AppColors.primaryStrong,
                      ),
                    ),
                  ),
                  title: Text(option.$2),
                  onTap: () => Navigator.of(sheetContext).pop(option.$1),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected == null) return;
    await ref.read(dailyLogProvider.notifier).setFlowIntensity(date, selected);
  }
}
