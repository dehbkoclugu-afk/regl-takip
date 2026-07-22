import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/access.dart';
import '../../core/utils/cycle_utils.dart';
import '../../core/utils/enum_labels.dart';
import '../../core/utils/phase_insights.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/phase_glyph.dart';
import '../../core/art/art_slot.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../models/enums.dart';
import '../../providers/providers.dart';
import '../log/quick_log_sheet.dart';
import 'widgets/cycle_progress_ring.dart';
import 'widgets/prediction_card.dart';
import 'widgets/quick_status_cards.dart';
import 'widgets/week_strip.dart';
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

  String _artIdForPhase(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return 'R6-phase-menstrual';
      case CyclePhase.follicular:
        return 'R7-phase-follicular';
      case CyclePhase.ovulation:
        return 'R8-phase-ovulation';
      case CyclePhase.luteal:
        return 'R9-phase-luteal';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.sf(context),
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
    final gradient = _gradientForPhase(phase);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    final dateFormat = DateFormat('d MMM', locale);
    String nextPeriodStr = '-';
    String ovulationStr = '-';
    String fertileStr = '-';

    final effectiveCycleLen = ref.watch(effectiveCycleLengthProvider);
    final access = ref.watch(accessProvider);
    final trialDaysLeft = ref.watch(trialDaysLeftProvider);
    // Ücretsiz katman yalnız regl takibi: modlara özel arayüz (hamilelik
    // hero'su, hap çipi, TTC kartı) premium kapsamında — free'de veri
    // silinmez ama görünüm klasik regl takibine döner
    final storedMode = profile?.trackingMode ?? TrackingMode.period;
    final mode =
        access == AccessLevel.free ? TrackingMode.period : storedMode;
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

    // Faz değişince zemin rengi atlamak yerine yumuşakça akar
    // (AnimatedContainer gradyanı kendisi lerp'ler)
    return AnimatedContainer(
      duration: context.motionEnabled
          ? const Duration(milliseconds: 600)
          : Duration.zero,
      curve: Curves.easeOutQuart,
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
          // Alt boşluk yüzen gezinme çubuğunu aşacak kadar — fazlası
          // sayfa sonunda ölü alan bırakıyordu
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 92),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Dark mode toggle - sağ üst
              Align(
                alignment: Alignment.centerRight,
                child: GlassContainer(
                  borderRadius: 12,
                  blur: 0,
                  padding: EdgeInsets.zero,
                  child: Material(
                    color: Colors.transparent,
                    child: Semantics(
                      button: true,
                      label: l10n.darkTheme,
                      toggled: AppColors.isDark(context),
                      child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      // Hızlı geçiş etkin parlaklığa göre açık/koyu yazar;
                      // "sistem" tercihine dönüş ayarlardaki üçlü seçimde
                      onTap: () {
                        final target =
                            AppColors.isDark(context) ? 'light' : 'dark';
                        ref.read(themeModeProvider.notifier).state =
                            target == 'dark'
                                ? ThemeMode.dark
                                : ThemeMode.light;
                        ref.read(userProfileProvider.notifier)
                            .saveProfile(themePreference: target);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          AppColors.isDark(context)
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
              // Greeting — isim isteğe bağlı, boşsa "Merhaba, !" yazmasın
              Text(
                (profile?.name.trim().isNotEmpty ?? false)
                    ? l10n.helloName(profile!.name.trim())
                    : l10n.helloGeneric,
                style: TextStyle(
                  // Display anı: gövdeden (w500) net ayrışan ağırlık
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.tp(context),
                ),
              )
                  .animateSafe(context)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: -0.2, end: 0, duration: 350.ms),
              // Deneme/ücretsiz durumu görünür olmalı: kalan gün ve
              // kapsam bilgisi — dokununca planlar
              if (access != AccessLevel.premium) ...[
                const SizedBox(height: 4),
                _buildAccessChip(context, l10n, access, trialDaysLeft),
              ],
              const SizedBox(height: 8),
              if (mode == TrackingMode.pregnancy) ...[
                // Hamilelik modu: hafta sayacı hero, tahminler gizli
                const SizedBox(height: 20),
                _buildPregnancyHero(context, l10n, profile?.pregnancyStartDate),
                const SizedBox(height: 24),
                _buildActionRow(context, ref, l10n, mode),
                const SizedBox(height: 24),
              ] else ...[
                // Phase name — faz bilgisini açan buton
                PressableScale(
                    child: Semantics(
                  button: true,
                  label: _phaseName(phase, l10n),
                  child: Material(
                    color: AppColors.sf(context),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showPhaseInfoDialog(context, phase, l10n),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PhaseGlyph(
                                phase: phase,
                                size: 15,
                                color: AppColors.primaryDeep),
                            const SizedBox(width: 7),
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
                    ),
                  ),
                )).animateSafe(context).fadeIn(delay: 100.ms, duration: 400.ms),
                if (mode == TrackingMode.pill &&
                    profile?.pillPackStartDate != null) ...[
                  const SizedBox(height: 8),
                  _buildPillChip(context, l10n, profile!.pillPackStartDate!),
                ],
                const SizedBox(height: 16),
                // Faz illüstrasyonu — faz haritasının yumuşak görsel yüzeyi
                ArtSlot(
                  id: _artIdForPhase(phase),
                  height: 150,
                  radius: 22,
                ).animateSafe(context).fadeIn(delay: 120.ms, duration: 450.ms),
                const SizedBox(height: 28),
                // Progress Ring
                CycleProgressRing(
                  cycleDay: cycleDay,
                  cycleLength: effectiveCycleLen,
                  periodLength: profile?.averagePeriodLength ?? 5,
                  phase: phase,
                  daysUntilNextPeriod: daysUntil,
                  lastPeriodStart: profile?.lastPeriodStart,
                  patterned: ref.watch(phasePatternProvider),
                ),
                const SizedBox(height: 20),
                // 7 günlük mini şerit: dün/bugün/yarın bağlamı takvime
                // inmeden — imza faz haritasının beşinci yüzeyi
                const WeekStrip()
                    .animateSafe(context)
                    .fadeIn(delay: 150.ms, duration: 400.ms),
                const SizedBox(height: 24),
                // Aksiyonlar ringin hemen altında: göz ring'den iner inmez
                // bir numaralı iş ("Reglim başladı") elin altında —
                // tahminler bilgidir, aşağıda yaşayabilir
                _buildActionRow(context, ref, l10n, mode),
                const SizedBox(height: 28),
                // Prediction Cards
                PredictionCardsRow(
                  nextPeriodDate: nextPeriodStr,
                  ovulationDate: ovulationStr,
                  fertileWindowDate: fertileStr,
                  ovulationConfirmed: confirmedOvulation != null,
                ),
                // Tahminlerden sonrası nefes alsın: bloklar arası eşit
                // ve cömert boşluk (sıkışıklık şikayetinin adresi)
                const SizedBox(height: 24),
                if (mode == TrackingMode.ttc) ...[
                  _buildTtcCard(context, ref, l10n, cycleDay,
                      effectiveCycleLen),
                  const SizedBox(height: 24),
                ],
                // Günlük faz koçluğu — faza göre pratik ipucu
                _buildCoachCard(context, ref, phase, l10n),
              ],
              const SizedBox(height: 28),
              const QuickStatusCards(),
              const SizedBox(height: 20),
              _buildDisclaimer(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, TrackingMode mode) {
    final ongoingPeriod = ref.watch(ongoingPeriodProvider);
    return Row(
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
                        // Regl geçmişi en değerli veri, dokunuş yanlışlıkla
                        // olabilir: onay diyaloğu yerine 6 sn'lik Geri Al
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final recordsNotifier =
                              ref.read(periodRecordsProvider.notifier);
                          final profileNotifier =
                              ref.read(userProfileProvider.notifier);
                          final prevProfile = ref.read(userProfileProvider);

                          // Uygulamanın en önemli veri anı: dokunuşa
                          // fiziksel teyit eşlik eder (ring + zemin de
                          // yeni faza yumuşakça akar)
                          HapticFeedback.mediumImpact();
                          if (ongoingPeriod != null) {
                            final recordId = ongoingPeriod.id;
                            await recordsNotifier.endPeriod(
                                recordId, DateTime.now());
                            profileNotifier.refresh();
                            messenger.showSnackBar(SnackBar(
                              content: Text(l10n.periodMarkedEnded),
                              duration: const Duration(seconds: 6),
                              action: SnackBarAction(
                                label: l10n.undo,
                                onPressed: () async {
                                  await recordsNotifier.reopenRecord(recordId);
                                  profileNotifier.refresh();
                                },
                              ),
                            ));
                          } else {
                            final record = await recordsNotifier
                                .startPeriod(DateTime.now());
                            await profileNotifier.saveProfile(
                                lastPeriodStart: record.startDate);
                            messenger.showSnackBar(SnackBar(
                              content: Text(l10n.periodMarkedStarted),
                              duration: const Duration(seconds: 6),
                              action: SnackBarAction(
                                label: l10n.undo,
                                onPressed: () async {
                                  await recordsNotifier
                                      .deleteRecord(record.id);
                                  // Profil (lastPeriodStart dahil) eski haline:
                                  // updateProfile bildirim/widget'ı da tazeler
                                  if (prevProfile != null) {
                                    await profileNotifier
                                        .updateProfile(prevProfile);
                                  } else {
                                    profileNotifier.refresh();
                                  }
                                },
                              ),
                            ));
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
                      color: AppColors.primaryStrong,
                      onTap: () {
                        // Günlük kayıt premium kapsamı: ücretsiz katman
                        // yalnız regl takibi
                        if (!ensurePremiumAccess(context, ref)) return;
                        showQuickLogSheet(context, ref, DateTime.now());
                      },
                    ),
                  ),
                ],
              )
        .animateSafe(context)
        .fadeIn(delay: 250.ms, duration: 400.ms)
        .slideY(begin: 0.15, end: 0, delay: 250.ms, duration: 400.ms);
  }

  Widget _buildAccessChip(BuildContext context, AppLocalizations l10n,
      AccessLevel access, int daysLeft) {
    final isFree = access == AccessLevel.free;
    final label =
        isFree ? l10n.freeBadge : l10n.trialBadge(daysLeft);
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.sf(context),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => GoRouter.of(context).push('/paywall'),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.dv(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFree
                      ? Icons.lock_outline_rounded
                      : Icons.hourglass_bottom_rounded,
                  size: 14,
                  color: isFree
                      ? AppColors.warningText
                      : AppColors.ts(context),
                ),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ts(context),
                    )),
              ],
            ),
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
    final isDark = AppColors.isDark(context);
    // Rozet METNİ pastel durum rengiyle yazılamaz (açık zeminde ~2:1):
    // açık temada koyu metin tonu, zemin tonu pastel kalır
    final (levelText, levelColor, levelTextColor) = switch (level) {
      FertilityLevel.high => (
          l10n.fertilityHigh,
          AppColors.success,
          isDark ? AppColors.success : AppColors.fertileWindowText
        ),
      FertilityLevel.medium => (
          l10n.fertilityMedium,
          AppColors.warning,
          isDark ? AppColors.warning : AppColors.warningText
        ),
      FertilityLevel.low => (
          l10n.fertilityLow,
          AppColors.textSecondary,
          AppColors.ts(context)
        ),
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
                        color: levelTextColor)),
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
                  color: AppColors.isDark(context)
                      ? AppColors.success
                      : AppColors.fertileWindowText,
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
    ).animateSafe(context).fadeIn(delay: 200.ms, duration: 400.ms);
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
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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

  Widget _buildCoachCard(BuildContext context, WidgetRef ref,
      CyclePhase phase, AppLocalizations l10n) {
    // Genel ipucunun üstüne kişisel içgörü: kullanıcının KENDİ kayıtları
    // bu fazda hangi semptomu gösteriyorsa o söylenir — "uygulama beni
    // tanıyor" anı (motor: topPhaseSymptoms, istatistikle aynı).
    // Kişisel içgörü premium kapsamı: ücretsizde genel ipucu kalır.
    final personal = ref.watch(accessProvider) == AccessLevel.free
        ? null
        : topInsightForPhase(ref.watch(phaseInsightsProvider), phase);

    // Kart perhizi: koç bilgi bloğudur, dokunulmaz — kart kabuğu yerine
    // çıplak blok (her şey kart olunca hiçbir şey kart değildi).
    // Faz glifi bloğun kimliği; kişisel içgörü aynı hizada ikinci satır.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (personal != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.insights_rounded,
                    size: 18, color: AppColors.primaryDeep),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.coachPersonalInsight(
                      EnumLabels.symptom(personal.symptom, l10n),
                      personal.percent,
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tp(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: PhaseGlyph(
                    phase: phase, size: 17, color: AppColors.primaryDeep),
              ),
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
        ],
      ),
    ).animateSafe(context).fadeIn(delay: 250.ms, duration: 400.ms);
  }

  Widget _buildPregnancyHero(
      BuildContext context, AppLocalizations l10n, DateTime? start) {
    // Başlangıç tarihi yoksa "1. hafta" göstermek uydurma bilgi olur:
    // kullanıcıyı tarihi gireceği yere yönlendir
    if (start == null) {
      return Semantics(
        button: true,
        label: l10n.pregnancySetStartPrompt,
        child: Material(
          color: AppColors.sf(context),
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => GoRouter.of(context).go('/settings'),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const Icon(Icons.pregnant_woman_rounded,
                      size: 40, color: AppColors.primaryDeep),
                  const SizedBox(height: 12),
                  Text(
                    l10n.pregnancySetStartPrompt,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tp(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animateSafe(context).fadeIn(delay: 100.ms, duration: 400.ms);
    }

    final week = CycleUtils.pregnancyWeek(start);
    final trimester = week <= 13
        ? l10n.trimester1
        : (week <= 27 ? l10n.trimester2 : l10n.trimester3);

    return Semantics(
      label:
          '${l10n.modePregnancy}: ${l10n.pregnancyWeekLabel(week)}, $trimester',
      child: ExcludeSemantics(
        child: GlassCard(
          borderRadius: 28,
          blur: 0,
          opacity: 0.2,
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Icon(Icons.pregnant_woman_rounded,
                  size: 40, color: AppColors.primaryDeep),
              const SizedBox(height: 8),
              Text(
                l10n.pregnancyWeekLabel(week),
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: AppColors.tp(context)),
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
    ).animateSafe(context).fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildPillChip(
      BuildContext context, AppLocalizations l10n, DateTime packStart) {
    final day = CycleUtils.pillDayInPack(packStart);
    final isBreak = day > 21;
    final label =
        isBreak ? l10n.pillBreakLabel(day - 21) : l10n.pillDayLabel(day);

    return GlassContainer(
      borderRadius: 16,
      blur: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.medication_rounded,
              size: 16,
              color: isBreak ? AppColors.warning : AppColors.primaryDeep),
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
    ).animateSafe(context).fadeIn(delay: 120.ms, duration: 400.ms);
  }

  Widget _buildDisclaimer(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Row(
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
          const SizedBox(height: 8),
          // Yasal zorunluluk düzeyinde uyarı: tahminler korunma aracı değil
          Row(
            children: [
              Icon(Icons.gpp_maybe_rounded,
                  size: 14, color: AppColors.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.notContraceptionWarning,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ts(context),
                    height: 1.4,
                  ),
                ),
              ),
            ],
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
    return PressableScale(
        child: GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.2,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
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
    ));
  }
}
