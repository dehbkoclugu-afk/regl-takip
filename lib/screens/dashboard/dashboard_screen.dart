import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/cycle_utils.dart';
import '../../core/widgets/glass_card.dart';
import '../../models/enums.dart';
import '../../providers/providers.dart';
import 'widgets/cycle_progress_ring.dart';
import 'widgets/prediction_card.dart';
import 'widgets/quick_status_cards.dart';
import '../../core/utils/motion.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  List<Color> _gradientForPhase(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return AppColors.menstrualGradient;
      case CyclePhase.follicular:
        return AppColors.follicularGradient;
      case CyclePhase.ovulation:
        return AppColors.ovulationGradient;
      case CyclePhase.luteal:
        return AppColors.lutealGradient;
    }
  }

  String _phaseName(CyclePhase phase, AppLocalizations l10n) {
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

  String _phaseInfo(CyclePhase phase, AppLocalizations l10n) {
    switch (phase) {
      case CyclePhase.menstrual:
        return l10n.menstrualPhaseInfo;
      case CyclePhase.follicular:
        return l10n.follicularPhaseInfo;
      case CyclePhase.ovulation:
        return l10n.ovulationPhaseInfo;
      case CyclePhase.luteal:
        return l10n.lutealPhaseInfo;
    }
  }

  void _showPhaseInfoDialog(BuildContext context, CyclePhase phase, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: AppColors.sf(context).withValues(alpha: 0.95),
        title: Text(
          _phaseName(phase, l10n),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          _phaseInfo(phase, l10n),
          style: TextStyle(fontSize: 14, height: 1.5),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final cycleDay = ref.watch(currentCycleDayProvider);
    final phase = ref.watch(currentCyclePhaseProvider);
    final daysUntil = ref.watch(daysUntilNextPeriodProvider);
    final ongoingPeriod = ref.watch(ongoingPeriodProvider);
    final gradient = _gradientForPhase(phase);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    final dateFormat = DateFormat('d MMM', locale);
    String nextPeriodStr = '-';
    String ovulationStr = '-';
    String fertileStr = '-';

    final effectiveCycleLen = ref.watch(effectiveCycleLengthProvider);
    final mode = profile?.trackingMode ?? TrackingMode.period;
    final confirmedOvulation = ref.watch(confirmedOvulationProvider);
    if (profile?.lastPeriodStart != null) {
      final cycleLen = effectiveCycleLen;
      final lastStart = profile!.lastPeriodStart!;
      // Tahmin geçmişte kaldıysa (gecikmiş döngü) ileri sarılmış tarih göster
      final nextPeriod = CycleUtils.nextFuturePeriod(lastStart, cycleLen);
      nextPeriodStr = dateFormat.format(nextPeriod);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      var ovulation = nextPeriod.subtract(
          const Duration(days: AppConstants.ovulationDayBeforePeriod));
      if (ovulation.isBefore(today)) {
        ovulation = ovulation.add(Duration(days: cycleLen));
      }
      // Sıcaklıktan teyit varsa tahmin yerine ölçülen tarih gösterilir
      if (confirmedOvulation != null) {
        ovulation = confirmedOvulation;
      }
      ovulationStr = dateFormat.format(ovulation);
      final fStart = ovulation.subtract(const Duration(days: 5));
      final fEnd = ovulation.add(const Duration(days: 1));
      fertileStr = '${dateFormat.format(fStart)} - ${dateFormat.format(fEnd)}';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient[0].withValues(alpha: 0.35),
            gradient[1].withValues(alpha: 0.2),
            AppColors.bg(context),
          ],
          stops: const [0.0, 0.3, 0.8],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Dark mode toggle - sağ üst
              Align(
                alignment: Alignment.centerRight,
                child: GlassContainer(
                  borderRadius: 14,
                  blur: 0,
                  padding: EdgeInsets.zero,
                  child: Material(
                    color: Colors.transparent,
                    child: Semantics(
                      button: true,
                      label: l10n.darkTheme,
                      toggled: ref.watch(darkModeProvider),
                      child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        final current = ref.read(darkModeProvider);
                        ref.read(darkModeProvider.notifier).state = !current;
                        ref.read(userProfileProvider.notifier)
                            .saveProfile(darkModeEnabled: !current);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          ref.watch(darkModeProvider)
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: AppColors.tp(context),
                          size: 22,
                        ),
                      ),
                    ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Greeting
              Text(
                l10n.helloName(profile?.name ?? ''),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tp(context),
                ),
              )
                  .animateSafe(context)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2, end: 0, duration: 500.ms),
              const SizedBox(height: 8),
              if (mode == TrackingMode.pregnancy) ...[
                // Hamilelik modu: hafta sayacı hero, tahminler gizli
                const SizedBox(height: 20),
                _buildPregnancyHero(context, l10n, profile?.pregnancyStartDate),
                const SizedBox(height: 24),
              ] else ...[
                // Phase name
                GestureDetector(
                  onTap: () => _showPhaseInfoDialog(context, phase, l10n),
                  child: GlassContainer(
                    borderRadius: 20,
                    blur: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _phaseName(phase, l10n),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.tp(context),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppColors.ts(context),
                        ),
                      ],
                    ),
                  ),
                ).animateSafe(context).fadeIn(delay: 200.ms, duration: 500.ms),
                if (mode == TrackingMode.pill &&
                    profile?.pillPackStartDate != null) ...[
                  const SizedBox(height: 8),
                  _buildPillChip(context, l10n, profile!.pillPackStartDate!),
                ],
                const SizedBox(height: 28),
                // Progress Ring
                CycleProgressRing(
                  cycleDay: cycleDay,
                  cycleLength: effectiveCycleLen,
                  phase: phase,
                  daysUntilNextPeriod: daysUntil,
                ),
                const SizedBox(height: 32),
                // Prediction Cards
                PredictionCardsRow(
                  nextPeriodDate: nextPeriodStr,
                  ovulationDate: ovulationStr,
                  fertileWindowDate: fertileStr,
                  ovulationConfirmed: confirmedOvulation != null,
                ),
                const SizedBox(height: 16),
                if (mode == TrackingMode.ttc) ...[
                  _buildTtcCard(context, ref, l10n, cycleDay,
                      effectiveCycleLen),
                  const SizedBox(height: 16),
                ],
                // Günlük faz koçluğu — faza göre pratik ipucu
                _buildCoachCard(context, phase, l10n),
                const SizedBox(height: 24),
              ],
              // Action Buttons
              Row(
                children: [
                  if (mode != TrackingMode.pregnancy) ...[
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        icon: Icons.water_drop_rounded,
                        label: ongoingPeriod != null
                            ? l10n.periodEnded
                            : l10n.periodStarted,
                        color: AppColors.menstrual,
                        onTap: () async {
                          if (ongoingPeriod != null) {
                            await ref
                                .read(periodRecordsProvider.notifier)
                                .endPeriod(ongoingPeriod.id, DateTime.now());
                            ref.read(userProfileProvider.notifier).refresh();
                          } else {
                            final record = await ref
                                .read(periodRecordsProvider.notifier)
                                .startPeriod(DateTime.now());
                            await ref
                                .read(userProfileProvider.notifier)
                                .saveProfile(lastPeriodStart: record.startDate);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      icon: Icons.add_reaction_rounded,
                      label: l10n.addRecord,
                      color: AppColors.secondary,
                      onTap: () {
                        // Dashboard'dan kayıt her zaman bugüne girilir
                        ref.read(selectedDateProvider.notifier).state =
                            DateTime.now();
                        context.push('/log');
                      },
                    ),
                  ),
                ],
              )
                  .animateSafe(context)
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                  .slideY(
                      begin: 0.15, end: 0, delay: 500.ms, duration: 600.ms),
              const SizedBox(height: 24),
              const QuickStatusCards(),
              const SizedBox(height: 16),
              _buildDisclaimer(context, l10n),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _coachMessage(CyclePhase phase, AppLocalizations l10n) {
    final messages = switch (phase) {
      CyclePhase.menstrual => [
          l10n.coachMenstrual0,
          l10n.coachMenstrual1,
          l10n.coachMenstrual2
        ],
      CyclePhase.follicular => [
          l10n.coachFollicular0,
          l10n.coachFollicular1,
          l10n.coachFollicular2
        ],
      CyclePhase.ovulation => [
          l10n.coachOvulation0,
          l10n.coachOvulation1,
          l10n.coachOvulation2
        ],
      CyclePhase.luteal => [
          l10n.coachLuteal0,
          l10n.coachLuteal1,
          l10n.coachLuteal2
        ],
    };
    // Gün bazlı deterministik rotasyon: aynı gün hep aynı mesaj,
    // ertesi gün değişir
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return messages[dayOfYear % messages.length];
  }

  Widget _buildTtcCard(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, int cycleDay, int cycleLength) {
    final level = CycleUtils.fertilityLevelForDay(cycleDay, cycleLength);
    final (levelText, levelColor) = switch (level) {
      FertilityLevel.high => (l10n.fertilityHigh, AppColors.success),
      FertilityLevel.medium => (l10n.fertilityMedium, AppColors.warning),
      FertilityLevel.low => (l10n.fertilityLow, AppColors.textSecondary),
    };

    final today = DateTime.now();
    final todayLog = ref.watch(dailyLogProvider)[
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}'];
    final lhResult = todayLog?.ovulationTestPositive;

    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded,
                  size: 18, color: AppColors.primaryStrong),
              const SizedBox(width: 8),
              Text(l10n.fertilityToday,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tp(context))),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(levelText,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: levelColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.lhTestTitle,
              style: TextStyle(
                  fontSize: 13, color: AppColors.ts(context))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _lhButton(
                  context,
                  label: l10n.lhPositive,
                  selected: lhResult == true,
                  color: AppColors.success,
                  onTap: () => ref
                      .read(dailyLogProvider.notifier)
                      .updateOvulationTest(
                          today, lhResult == true ? null : true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _lhButton(
                  context,
                  label: l10n.lhNegative,
                  selected: lhResult == false,
                  color: AppColors.textSecondary,
                  onTap: () => ref
                      .read(dailyLogProvider.notifier)
                      .updateOvulationTest(
                          today, lhResult == false ? null : false),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animateSafe(context).fadeIn(delay: 420.ms, duration: 500.ms);
  }

  Widget _lhButton(
    BuildContext context, {
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? color.withValues(alpha: 0.18)
            : AppColors.sf(context),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? color
                    : AppColors.dv(context),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? color : AppColors.ts(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoachCard(
      BuildContext context, CyclePhase phase, AppLocalizations l10n) {
    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.16,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tips_and_updates_rounded,
              size: 20, color: AppColors.secondaryStrong),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _coachMessage(phase, l10n),
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppColors.tp(context),
              ),
            ),
          ),
        ],
      ),
    ).animateSafe(context).fadeIn(delay: 450.ms, duration: 500.ms);
  }

  Widget _buildPregnancyHero(
      BuildContext context, AppLocalizations l10n, DateTime? start) {
    final week = start != null ? CycleUtils.pregnancyWeek(start) : 1;
    final trimester = week <= 13
        ? l10n.trimester1
        : (week <= 27 ? l10n.trimester2 : l10n.trimester3);

    return Semantics(
      label: '${l10n.modePregnancy}: ${l10n.pregnancyWeekLabel(week)}, $trimester',
      child: ExcludeSemantics(
        child: GlassCard(
          borderRadius: 28,
          blur: 0,
          opacity: 0.2,
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Text('\u{1F930}', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                l10n.pregnancyWeekLabel(week),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.tp(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                trimester,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ts(context),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animateSafe(context).fadeIn(delay: 200.ms, duration: 500.ms);
  }

  Widget _buildPillChip(
      BuildContext context, AppLocalizations l10n, DateTime packStart) {
    final day = CycleUtils.pillDayInPack(packStart);
    final isBreak = day > 21;
    final label =
        isBreak ? l10n.pillBreakLabel(day - 21) : l10n.pillDayLabel(day);

    return GlassContainer(
      borderRadius: 20,
      blur: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.medication_rounded,
              size: 16,
              color: isBreak ? AppColors.warning : AppColors.secondaryStrong),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.tp(context),
            ),
          ),
        ],
      ),
    ).animateSafe(context).fadeIn(delay: 250.ms, duration: 500.ms);
  }

  Widget _buildDisclaimer(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 14, color: AppColors.ts(context)),
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
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      borderRadius: 24,
      blur: 0,
      opacity: 0.2,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.15)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tp(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
