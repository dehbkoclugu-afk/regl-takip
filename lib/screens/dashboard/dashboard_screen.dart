import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/cycle_utils.dart';
import '../../providers/providers.dart';
import 'widgets/cycle_progress_ring.dart';
import 'widgets/prediction_card.dart';
import 'widgets/quick_status_cards.dart';

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
      nextPeriodStr =
          dateFormat.format(CycleUtils.predictNextPeriod(lastStart, cycleLen));
      ovulationStr =
          dateFormat.format(CycleUtils.predictOvulation(lastStart, cycleLen));
      final fStart = CycleUtils.fertileWindowStart(lastStart, cycleLen);
      final fEnd = CycleUtils.fertileWindowEnd(lastStart, cycleLen);
      fertileStr = '${dateFormat.format(fStart)} - ${dateFormat.format(fEnd)}';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [gradient[0], gradient[1], AppColors.bg(context)],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                l10n.helloName(profile?.name ?? ''),
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2, end: 0, duration: 500.ms),
              const SizedBox(height: 8),
              Text(
                _phaseName(phase, l10n),
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const SizedBox(height: 24),
              CycleProgressRing(
                cycleDay: cycleDay,
                cycleLength: profile?.averageCycleLength ?? 28,
                phase: phase,
                daysUntilNextPeriod: daysUntil,
              ),
              const SizedBox(height: 32),
              PredictionCardsRow(
                nextPeriodDate: nextPeriodStr,
                ovulationDate: ovulationStr,
                fertileWindowDate: fertileStr,
              ),
              const SizedBox(height: 24),
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
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                  .slideY(
                      begin: 0.15, end: 0, delay: 500.ms, duration: 600.ms),
              const SizedBox(height: 24),
              const QuickStatusCards(),
              const SizedBox(height: 24),
            ],
          ),
        ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.sf(context),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tp(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
