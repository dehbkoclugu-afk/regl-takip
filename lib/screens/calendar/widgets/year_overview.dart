import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/adaptive_layout.dart';
import '../../../core/utils/cycle_utils.dart';
import '../../../models/enums.dart';
import '../../../models/period_record.dart';
import '../../../models/user_profile.dart';

/// Material haftanın ilk günü indeksine göre sabit altı haftalık ay ızgarası.
List<DateTime?> buildMonthGrid(
  int year,
  int month,
  int firstDayOfWeek,
) {
  if (firstDayOfWeek < 0 || firstDayOfWeek > 6) {
    throw RangeError.range(firstDayOfWeek, 0, 6, 'firstDayOfWeek');
  }
  final first = DateTime(year, month);
  final offset = (first.weekday % 7 - firstDayOfWeek + 7) % 7;
  final daysInMonth = DateTime(year, month + 1, 0).day;
  return List<DateTime?>.generate(42, (index) {
    final day = index - offset + 1;
    return day < 1 || day > daysInMonth
        ? null
        : DateTime(year, month, day);
  });
}

class YearOverviewSheet extends StatefulWidget {
  final int initialYear;
  final int firstDayOfWeek;
  final List<PeriodRecord> records;
  final UserProfile? profile;
  final int cycleLength;
  final ValueChanged<DateTime> onMonthSelected;

  const YearOverviewSheet({
    super.key,
    required this.initialYear,
    required this.firstDayOfWeek,
    required this.records,
    required this.profile,
    required this.cycleLength,
    required this.onMonthSelected,
  });

  @override
  State<YearOverviewSheet> createState() => _YearOverviewSheetState();
}

class _YearOverviewSheetState extends State<YearOverviewSheet> {
  late int _year = widget.initialYear;

  bool _isPeriodDay(DateTime day) =>
      widget.records.any((record) => record.containsDate(day));

  bool _isPredictedDay(DateTime day) {
    final profile = widget.profile;
    final start = profile?.lastPeriodStart;
    return profile != null &&
        start != null &&
        profile.trackingMode != TrackingMode.pregnancy &&
        !_isPeriodDay(day) &&
        CycleUtils.isPredictedPeriodDay(
          day,
          start,
          widget.cycleLength,
          profile.averagePeriodLength,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return SafeArea(
      top: false,
      child: Material(
        color: AppColors.sf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dv(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed:
                        _year <= 2020 ? null : () => setState(() => _year--),
                    tooltip: '${_year - 1}',
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        '${l10n.yearRingTitle} · $_year',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tp(context),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed:
                        _year >= 2030 ? null : () => setState(() => _year++),
                    tooltip: '${_year + 1}',
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FocusTraversalGroup(
                  policy: ReadingOrderTraversalPolicy(),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final textScale = effectiveTextScale(
                        MediaQuery.textScalerOf(context),
                      );
                      final largeText = usesLargeText(
                        MediaQuery.textScalerOf(context),
                      );
                      final maxColumns = constraints.maxWidth >= 720
                          ? 4
                          : constraints.maxWidth >= 420
                              ? 3
                              : 2;
                      final columns = largeText
                          ? adaptiveGridColumns(
                              width: constraints.maxWidth,
                              textScale: textScale,
                              maxColumns: maxColumns,
                              minCardWidth: 150,
                              spacing: 10,
                            )
                          : maxColumns;
                      return GridView.builder(
                        padding: const EdgeInsets.only(bottom: 8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio:
                              largeText ? 1 : (columns == 2 ? 1.15 : 1.05),
                          mainAxisExtent: largeText
                              ? scaledGridExtent(
                                  125,
                                  textScale,
                                  growth: 0.45,
                                )
                              : null,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) => _MonthCard(
                          year: _year,
                          month: index + 1,
                          locale: locale,
                          firstDayOfWeek: widget.firstDayOfWeek,
                          isPeriodDay: _isPeriodDay,
                          isPredictedDay: _isPredictedDay,
                          onTap: () => widget.onMonthSelected(
                            DateTime(_year, index + 1),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 18,
                runSpacing: 6,
                children: [
                  _LegendDot(
                    filled: true,
                    label: l10n.periodDayLabel,
                  ),
                  _LegendDot(
                    filled: false,
                    label: l10n.predicted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final int year;
  final int month;
  final int firstDayOfWeek;
  final String locale;
  final bool Function(DateTime day) isPeriodDay;
  final bool Function(DateTime day) isPredictedDay;
  final VoidCallback onTap;

  const _MonthCard({
    required this.year,
    required this.month,
    required this.firstDayOfWeek,
    required this.locale,
    required this.isPeriodDay,
    required this.isPredictedDay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final days = buildMonthGrid(year, month, firstDayOfWeek);
    final periodDays =
        days.whereType<DateTime>().where(isPeriodDay).length;
    final predictedDays =
        days.whereType<DateTime>().where(isPredictedDay).length;
    final monthName = DateFormat.MMMM(locale).format(DateTime(year, month));
    final stateLabel = [
      if (periodDays > 0) l10n.monthPeriodDays(periodDays),
      if (predictedDays > 0) '${l10n.predicted}: $predictedDays',
    ].join('. ');

    return Semantics(
      button: true,
      label: stateLabel.isEmpty ? monthName : '$monthName. $stateLabel',
      child: Material(
        color: AppColors.bg(context),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          focusColor: AppColors.primary.withValues(alpha: 0.14),
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monthName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tp(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.35,
                      ),
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final day = days[index];
                        if (day == null) return const SizedBox.shrink();
                        final actual = isPeriodDay(day);
                        final predicted = !actual && isPredictedDay(day);
                        return Center(
                          child: Container(
                            width: actual || predicted ? 7 : 3,
                            height: actual || predicted ? 7 : 3,
                            decoration: BoxDecoration(
                              color: actual
                                  ? AppColors.primaryStrong
                                  : predicted
                                      ? Colors.transparent
                                      : AppColors.dv(context),
                              shape: BoxShape.circle,
                              border: predicted
                                  ? Border.all(
                                      color: AppColors.primaryStrong,
                                      width: 1.2,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
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
}

class _LegendDot extends StatelessWidget {
  final bool filled;
  final String label;

  const _LegendDot({required this.filled, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: filled ? AppColors.primaryStrong : Colors.transparent,
              shape: BoxShape.circle,
              border: filled
                  ? null
                  : Border.all(color: AppColors.primaryStrong, width: 1.4),
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.ts(context)),
            ),
          ),
        ],
      );
}
