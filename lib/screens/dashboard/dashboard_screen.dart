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

    if (profile?.lastPeriodStart != null) {
      final cycleLen = profile!.averageCycleLength;
      final lastStart = profile.lastPeriodStart!;
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
              // Phase name
              GestureDetector(
                onTap: () => _showPhaseInfoDialog(context, phase, l10n),
                child: GlassContainer(
                  borderRadius: 20,
                  blur: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              const SizedBox(height: 28),
              // Progress Ring
              CycleProgressRing(
                cycleDay: cycleDay,
                cycleLength: profile?.averageCycleLength ?? 28,
                phase: phase,
                daysUntilNextPeriod: daysUntil,
              ),
              const SizedBox(height: 32),
              // Prediction Cards
              PredictionCardsRow(
                nextPeriodDate: nextPeriodStr,
                ovulationDate: ovulationStr,
                fertileWindowDate: fertileStr,
              ),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                children: [
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
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      icon: Icons.add_reaction_rounded,
                      label: l10n.addRecord,
                      color: AppColors.secondary,
                      onTap: () => context.push('/log'),
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
