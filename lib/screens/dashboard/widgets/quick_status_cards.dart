import 'package:flutter/material.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/adaptive_layout.dart';
import '../../../core/utils/enum_labels.dart';
import '../../../core/utils/statistics_summary.dart';
import '../../../models/enums.dart';
import '../../../providers/providers.dart';
import '../../../core/utils/motion.dart';

class QuickStatusCards extends ConsumerWidget {
  const QuickStatusCards({super.key});

  String _moodEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return '\u{1F60A}';
      case MoodType.sad:
        return '\u{1F622}';
      case MoodType.angry:
        return '\u{1F621}';
      case MoodType.anxious:
        return '\u{1F630}';
      case MoodType.calm:
        return '\u{1F60C}';
      case MoodType.energetic:
        return '\u{26A1}';
      case MoodType.tired:
        return '\u{1F634}';
      case MoodType.romantic:
        return '\u{1F970}';
      case MoodType.sensitive:
        return '\u{1F97A}';
      case MoodType.irritable:
        return '\u{1F624}';
      case MoodType.neutral:
        return '\u{1F610}';
    }
  }

  String _moodName(MoodType mood, AppLocalizations l10n) =>
      EnumLabels.mood(mood, l10n);

  Color _moodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return AppColors.moodHappy;
      case MoodType.sad:
        return AppColors.moodSad;
      case MoodType.angry:
        return AppColors.moodAngry;
      case MoodType.anxious:
        return AppColors.moodAnxious;
      case MoodType.calm:
        return AppColors.moodCalm;
      case MoodType.energetic:
        return AppColors.moodEnergetic;
      case MoodType.tired:
        return AppColors.moodTired;
      case MoodType.romantic:
        return AppColors.moodRomantic;
      case MoodType.sensitive:
        return AppColors.moodSad;
      case MoodType.irritable:
        return AppColors.moodAngry;
      case MoodType.neutral:
        return AppColors.moodNeutral;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final largeText = usesLargeText(MediaQuery.textScalerOf(context));
    final dailyLogs = ref.watch(dailyLogProvider);
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final todayLog = dailyLogs[todayKey];

    final hasMood = todayLog?.mood != null;
    final hasSymptoms =
        todayLog != null && todayLog.symptoms.isNotEmpty;
    final hasAnyLog = hasMood || hasSymptoms;
    final consistency = calculateTrackingConsistency(
      dailyLogs.values,
      today: now,
    );
    final consistencyText = consistency.streakDays > 0
        ? '${l10n.trackingStreak(consistency.streakDays)} · '
            '${l10n.weeklyTracking(consistency.lastSevenDays)}'
        : l10n.weeklyTracking(consistency.lastSevenDays);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  l10n.todaySummary,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tp(context),
                  ),
                ),
              ),
              if (consistency.lastSevenDays > 0)
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      consistencyText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (!hasAnyLog) _buildEmptyState(context, ref, l10n),
        if (hasAnyLog) ...[
          if (largeText && hasMood && hasSymptoms)
            Column(
              children: [
                _buildMoodCard(context, ref, todayLog.mood!.type, l10n),
                const SizedBox(height: 12),
                _buildSymptomCard(
                    context, ref, todayLog.symptoms.length, l10n),
              ],
            )
          else
            Row(
              children: [
                if (hasMood)
                  Expanded(
                    child: _buildMoodCard(
                        context, ref, todayLog!.mood!.type, l10n),
                  ),
                if (hasMood && hasSymptoms) const SizedBox(width: 12),
                if (hasSymptoms)
                  Expanded(
                    child: _buildSymptomCard(
                        context, ref, todayLog.symptoms.length, l10n),
                  ),
              ],
            ),
          // Kısmi gün: biri girilmiş, diğeri boş. Boş durumda yönlendirme
          // vardı ama yarısı dolu günde eksik olan hiç istenmiyordu.
          if (!hasMood || !hasSymptoms) ...[
            const SizedBox(height: 10),
            _buildMissingPrompt(
              context,
              ref,
              label: hasMood ? l10n.symptoms : l10n.mood,
              route: hasMood ? '/symptoms' : '/mood',
              icon: hasMood
                  ? Icons.monitor_heart_rounded
                  : Icons.add_reaction_rounded,
              l10n: l10n,
            ),
          ],
        ],
      ],
    )
        .animateSafe(context)
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.15, end: 0, delay: 600.ms, duration: 600.ms);
  }

  /// Kart kabuğunu bozmadan dokunulabilir yapar.
  Widget _tappable(
    BuildContext context,
    WidgetRef ref, {
    required String route,
    required String semanticsLabel,
    required Widget child,
  }) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            ref.read(selectedDateProvider.notifier).state = DateTime.now();
            context.push(route);
          },
          child: ExcludeSemantics(child: child),
        ),
      ),
    );
  }

  /// Eksik olanı isteyen ince satır. Kart değil: gün zaten yarı dolu,
  /// ikinci bir kart kabuğu özeti bastırırdı.
  Widget _buildMissingPrompt(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required String route,
    required IconData icon,
    required AppLocalizations l10n,
  }) {
    return Semantics(
      button: true,
      label: l10n.notLoggedToday(label),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            ref.read(selectedDateProvider.notifier).state = DateTime.now();
            context.push(route);
          },
          child: Padding(
            // 18 px ikon + 2x15 = 48 px: Material asgari dokunma hedefi
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.ts(context)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.notLoggedToday(label),
                    style: TextStyle(
                        fontSize: 13, color: AppColors.ts(context)),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppColors.ts(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Semantics(
      button: true,
      label: '${l10n.howAreYouFeeling}. ${l10n.logMoodAndSymptoms}',
      child: Material(
        color: AppColors.sf(context),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Dashboard'dan kayıt her zaman bugüne girilir
            ref.read(selectedDateProvider.notifier).state = DateTime.now();
            context.push('/log');
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Row(
              children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryLight.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.add_reaction_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.howAreYouFeeling,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tp(context),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.logMoodAndSymptoms,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ts(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.ts(context).withValues(alpha: 0.5),
              size: 24,
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context, WidgetRef ref, MoodType mood,
      AppLocalizations l10n) {
    // Kart özeti gösteriyordu ama dokunulmuyordu: düzeltmek için günlük
    // ekranından dolaşmak gerekiyordu
    return _tappable(
      context,
      ref,
      route: '/mood',
      semanticsLabel: '${l10n.mood}: ${_moodName(mood, l10n)}',
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sf(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _moodColor(mood).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _moodColor(mood).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _moodEmoji(mood),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.mood,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ts(context),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _moodName(mood, l10n),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tp(context),
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

  Widget _buildSymptomCard(BuildContext context, WidgetRef ref,
      int symptomCount, AppLocalizations l10n) {
    return _tappable(
      context,
      ref,
      route: '/symptoms',
      semanticsLabel: '${l10n.symptoms}: ${l10n.nSymptoms(symptomCount)}',
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sf(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.monitor_heart_rounded,
              color: AppColors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.symptoms,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ts(context),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.nSymptoms(symptomCount),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tp(context),
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
}
