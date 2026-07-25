import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/access.dart';
import '../../core/utils/adaptive_layout.dart';
import '../../core/utils/cycle_utils.dart';
import '../../core/utils/enum_labels.dart';
import '../../core/utils/phase_insights.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/phase_glyph.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../models/enums.dart';
import '../../models/period_record.dart';
import '../../models/user_profile.dart';
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
          EnumLabels.phase(phase, l10n),
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
    // Tarih olarak da lazım: TTC kartındaki test günü bundan hesaplanıyor
    DateTime? ovulationDate;

    final effectiveCycleLen = ref.watch(effectiveCycleLengthProvider);
    final access = ref.watch(accessProvider);
    final trialDaysLeft = ref.watch(trialDaysLeftProvider);
    final todayFirst =
        ref.watch(homePriorityProvider) == HomePriority.today;
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
      ovulationDate = ovulation;
      ovulationStr = dateFormat.format(ovulation);
      final fStart = ovulation.subtract(const Duration(days: 5));
      final fEnd = ovulation.add(const Duration(days: 1));
      fertileStr = '${dateFormat.format(fStart)} - ${dateFormat.format(fEnd)}';
    }

    final isDarkTheme = AppColors.isDark(context);
    // Faz değişince zemin rengi atlamak yerine yumuşakça akar
    // (AnimatedContainer gradyanı kendisi lerp'ler)
    return AnimatedContainer(
      duration: context.motionDuration(const Duration(milliseconds: 600)),
      curve: Curves.easeOutQuart,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            // Koyu temada tint zemini AÇIYOR, yani açık renkli ikincil
            // metnin kontrastını düşürüyor: aynı alfada dört fazın hepsi
            // 2,6–3,7:1'e iniyordu. Kısılmış alfa hem okunurluğu kurtarıyor
            // hem "parlak öğeler dark'ta kısılır" ilkesiyle uyumlu.
            gradient[0].withValues(alpha: isDarkTheme ? 0.15 : 0.35),
            gradient[1].withValues(alpha: isDarkTheme ? 0.10 : 0.20),
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              const SizedBox(height: 20),
              // Selamlama artık display anı değil: ekranın en büyük yazısı
              // kullanıcının sorusuna ("ne zaman?") ait olmalı, ismine değil.
              // Tema düğmesi de buradan kalktı — ayda bir kullanılan bir
              // tercih, her açılışta göz hizasındaki köşeyi hak etmiyor
              // (üçlü seçici ayarlarda duruyor).
              Text(
                (profile?.name.trim().isNotEmpty ?? false)
                    ? l10n.helloName(profile!.name.trim())
                    : l10n.helloGeneric,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ts(context),
                ),
                textAlign: TextAlign.center,
              )
                  .animateSafe(context)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: -0.2, end: 0, duration: 350.ms),
              if (mode != TrackingMode.pregnancy) ...[
                const SizedBox(height: 6),
                _buildHeadline(context, l10n, ref, profile, daysUntil, locale)
                    .animateSafe(context)
                    .fadeIn(delay: 60.ms, duration: 400.ms)
                    .slideY(begin: -0.15, end: 0, duration: 400.ms),
              ],
              if (todayFirst) ...[
                const SizedBox(height: 20),
                const QuickStatusCards(),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 14),
              if (mode == TrackingMode.pregnancy) ...[
                // Hamilelik modu: hafta sayacı hero, tahminler gizli
                const SizedBox(height: 20),
                _buildPregnancyHero(context, l10n, profile?.pregnancyStartDate),
                if (profile?.pregnancyStartDate != null) ...[
                  const SizedBox(height: 14),
                  _buildPregnancyInsight(
                    context,
                    l10n,
                    profile!.pregnancyStartDate!,
                  ),
                ],
                const SizedBox(height: 24),
                _buildActionRow(context, ref, l10n, mode),
                const SizedBox(height: 24),
              ] else ...[
                // Phase name — faz bilgisini açan buton
                PressableScale(
                    child: Semantics(
                  button: true,
                  label: EnumLabels.phase(phase, l10n),
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
                            Flexible(
                              child: Text(
                                EnumLabels.phase(phase, l10n),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.tp(context),
                                ),
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
                  _buildPillCard(context, l10n, profile!.pillPackStartDate!),
                ],
                const SizedBox(height: 28),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final expanded = constraints.maxWidth >= 840;

                    Widget cycleColumn() => Column(
                          children: [
                            CycleProgressRing(
                              cycleDay: cycleDay,
                              cycleLength: effectiveCycleLen,
                              periodLength:
                                  profile?.averagePeriodLength ?? 5,
                              phase: phase,
                              daysUntilNextPeriod: daysUntil,
                              delayDays: ref.watch(periodDelayProvider),
                              lastPeriodStart: profile?.lastPeriodStart,
                              patterned: ref.watch(phasePatternProvider),
                            ),
                            const SizedBox(height: 20),
                            const WeekStrip()
                                .animateSafe(context)
                                .fadeIn(delay: 150.ms, duration: 400.ms),
                            const SizedBox(height: 24),
                            _buildActionRow(context, ref, l10n, mode),
                          ],
                        );

                    Widget insightColumn() => Column(
                          children: [
                            PredictionCardsRow(
                              nextPeriodDate: nextPeriodStr,
                              ovulationDate: ovulationStr,
                              fertileWindowDate: fertileStr,
                              ovulationConfirmed:
                                  confirmedOvulation != null,
                            ),
                            const SizedBox(height: 24),
                            if (mode == TrackingMode.ttc) ...[
                              _buildTtcCard(
                                context,
                                ref,
                                l10n,
                                cycleDay,
                                effectiveCycleLen,
                                ovulationDate,
                                locale,
                              ),
                              const SizedBox(height: 24),
                            ],
                            _buildCoachCard(context, ref, phase, l10n),
                          ],
                        );

                    return FocusTraversalGroup(
                      policy: WidgetOrderTraversalPolicy(),
                      child: expanded
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: cycleColumn()),
                                const SizedBox(width: 32),
                                Expanded(child: insightColumn()),
                              ],
                            )
                          : Column(
                              children: [
                                cycleColumn(),
                                const SizedBox(height: 28),
                                insightColumn(),
                              ],
                            ),
                    );
                  },
                ),
              ],
              // Deneme/ücretsiz durumu görünür kalır ama ekranın tepesinde
              // değil: orası "ne zaman?" cevabının yeri
              if (access == AccessLevel.free ||
                  (access == AccessLevel.trial && trialDaysLeft <= 7)) ...[
                const SizedBox(height: 24),
                _buildAccessChip(context, l10n, access, trialDaysLeft),
              ],
              if (!todayFirst) ...[
                const SizedBox(height: 28),
                const QuickStatusCards(),
              ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Ekranın tek cümlelik cevabı: "ne zaman?".
  ///
  /// Ring döngü gününü görsel olarak anlatıyordu ama kullanıcının %90
  /// sorusuna açık bir cümleyle cevap veren hiçbir şey yoktu — tarih yalnız
  /// tahmin kartlarının içinde, kaydırmanın altındaydı. Ekranın en büyük
  /// yazısı artık bu.
  Widget _buildHeadline(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    UserProfile? profile,
    int daysUntil,
    String locale,
  ) {
    final ongoing = ref.watch(ongoingPeriodProvider);
    final delay = ref.watch(periodDelayProvider);

    String headline;
    String? subtitle;

    if (profile?.lastPeriodStart == null) {
      // Kurulum yarım kalmış: cevap yerine tek yapılacak iş
      headline = l10n.headlineNoData;
    } else if (delay > 0) {
      // Kullanıcının uygulamayı en çok açtığı an: cevap "gecikme" olmalı,
      // ileri sarılmış bir sonraki tahmin değil. Alt satır sakinleştirici
      // ve eyleme dönük — tanı koymaz.
      headline = l10n.headlineDelay(delay);
      subtitle = l10n.headlineDelaySubtitle;
    } else if (ongoing != null) {
      final now = DateTime.now();
      final start = ongoing.startDate;
      final dayOfPeriod = DateTime(now.year, now.month, now.day)
              .difference(DateTime(start.year, start.month, start.day))
              .inDays +
          1;
      headline = l10n.headlinePeriodDay(dayOfPeriod);
    } else {
      final cycleLen = ref.watch(effectiveCycleLengthProvider);
      final next = CycleUtils.nextFuturePeriod(profile!.lastPeriodStart!, cycleLen);
      subtitle = DateFormat('d MMMM', locale).format(next);
      headline = switch (daysUntil) {
        0 => l10n.headlinePeriodToday,
        1 => l10n.headlinePeriodTomorrow,
        _ => l10n.headlinePeriodInDays(daysUntil),
      };
    }

    return Column(
      children: [
        Text(
          headline,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.2,
            color: AppColors.tp(context),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ts(context),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionRow(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, TrackingMode mode) {
    final ongoingPeriod = ref.watch(ongoingPeriodProvider);
    // Keşfi olmayan bir hareket olmayan bir özelliktir: ipucu, kullanıcı
    // hareketi bir kez kullanana kadar durur, sonra kalıcı olarak kapanır
    final showHint = mode != TrackingMode.pregnancy &&
        ref.watch(backdateHintProvider);

    final buttons = <Widget>[
      if (mode != TrackingMode.pregnancy)
        _buildActionButton(
                        context: context,
                        icon: Icons.water_drop_rounded,
                        label: ongoingPeriod != null
                            ? l10n.periodEnded
                            : l10n.periodStarted,
                        color: AppColors.menstrual,
                        // Regl geçmişi en değerli veri, dokunuş yanlışlıkla
                        // olabilir: onay diyaloğu yerine 6 sn'lik Geri Al
                        onTap: () => _togglePeriod(
                            context, ref, l10n, ongoingPeriod, DateTime.now()),
                        // Regl iki gün sonra hatırlanabiliyor: dokunuş hep
                        // bugünü yazdığı için geç kalan kullanıcı yanlış tarih
                        // girmek zorundaydı. Uzun bas = gün seç.
                        onLongPress: () => _pickPeriodDate(
                            context, ref, l10n, ongoingPeriod),
                      ),
      _buildActionButton(
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
    ];
    final row = usesLargeText(MediaQuery.textScalerOf(context)) &&
            buttons.length > 1
        ? Column(
            children: [
              SizedBox(width: double.infinity, child: buttons.first),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: buttons.last),
            ],
          )
        : Row(
            children: [
              for (var i = 0; i < buttons.length; i++) ...[
                Expanded(child: buttons[i]),
                if (i < buttons.length - 1) const SizedBox(width: 12),
              ],
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        if (showHint) ...[
          const SizedBox(height: 8),
          Text(
            l10n.backdateHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: AppColors.ts(context),
            ),
          ),
        ],
      ],
    )
        .animateSafe(context)
        .fadeIn(delay: 250.ms, duration: 400.ms)
        .slideY(begin: 0.15, end: 0, delay: 250.ms, duration: 400.ms);
  }

  /// Regl başlangıcı/bitişi kaydeder. [date] hem bugün (dokunuş) hem geçmiş
  /// bir gün (uzun bas → tarih seçici) olabilir.
  Future<void> _togglePeriod(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    PeriodRecord? ongoingPeriod,
    DateTime date,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final recordsNotifier = ref.read(periodRecordsProvider.notifier);
    final profileNotifier = ref.read(userProfileProvider.notifier);
    final prevProfile = ref.read(userProfileProvider);

    // Uygulamanın en önemli veri anı: dokunuşa fiziksel teyit eşlik eder
    // (ring + zemin de yeni faza yumuşakça akar)
    HapticFeedback.mediumImpact();
    if (ongoingPeriod != null) {
      final recordId = ongoingPeriod.id;
      await recordsNotifier.endPeriod(recordId, date);
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
      final record = await recordsNotifier.startPeriod(date);
      await profileNotifier.saveProfile(lastPeriodStart: record.startDate);
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.periodMarkedStarted),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () async {
            await recordsNotifier.deleteRecord(record.id);
            // Profil (lastPeriodStart dahil) eski haline:
            // updateProfile bildirim/widget'ı da tazeler
            if (prevProfile != null) {
              await profileNotifier.updateProfile(prevProfile);
            } else {
              profileNotifier.refresh();
            }
          },
        ),
      ));
    }
  }

  /// Geçmiş bir gün için regl başlangıcı/bitişi. Gelecek seçilemez; geriye
  /// 90 gün yeter (daha eskisi geçmiş düzenlemesi, kayıt değil).
  Future<void> _pickPeriodDate(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    PeriodRecord? ongoingPeriod,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Bitiş, başlangıçtan önce olamaz
    final earliest = ongoingPeriod != null
        ? DateTime(ongoingPeriod.startDate.year, ongoingPeriod.startDate.month,
            ongoingPeriod.startDate.day)
        : today.subtract(const Duration(days: 90));

    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: earliest,
      lastDate: today,
      helpText: ongoingPeriod != null
          ? l10n.periodEndDateHelp
          : l10n.periodStartDateHelp,
    );
    if (picked == null || !context.mounted) return;

    // Hareket kullanıldı: ipucu artık yer kaplamasın
    if (ref.read(backdateHintProvider)) {
      ref.read(backdateHintProvider.notifier).state = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('backdate_hint_needed', false);
      if (!context.mounted) return;
    }

    await _togglePeriod(context, ref, l10n, ongoingPeriod, picked);
  }

  Widget _buildAccessChip(BuildContext context, AppLocalizations l10n,
      AccessLevel access, int daysLeft) {
    final isFree = access == AccessLevel.free;
    // Deneme bitişi sessizce geliyordu: 30. gün her şey açık, 31. gün on
    // ekran birden kapalı. Son üç gün çip uyarı diline geçer ki kapanış
    // sürpriz olmasın.
    final isEnding = !isFree && daysLeft <= 3;
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
              border: Border.all(
                color: (isFree || isEnding)
                    ? AppColors.warningText.withValues(alpha: 0.5)
                    : AppColors.dv(context),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFree
                      ? Icons.lock_outline_rounded
                      : Icons.hourglass_bottom_rounded,
                  size: 14,
                  color: (isFree || isEnding)
                      ? AppColors.warningText
                      : AppColors.ts(context),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isEnding
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isEnding
                            ? AppColors.warningText
                            : AppColors.ts(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
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

  Widget _buildTtcCard(
      BuildContext context,
      WidgetRef ref,
      AppLocalizations l10n,
      int cycleDay,
      int cycleLength,
      DateTime? ovulationDate,
      String locale) {
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
          // TTC kullanıcısının en beklediği tarih buydu ve hiçbir yerde
          // yazmıyordu. Daha erken test yanlış negatif verir.
          if (ovulationDate != null) ...[
            const SizedBox(height: 10),
            Builder(builder: (context) {
              final testDay =
                  CycleUtils.earliestPregnancyTestDay(ovulationDate);
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final ready = !testDay.isAfter(today);
              return Row(
                children: [
                  Icon(
                    ready
                        ? Icons.check_circle_outline_rounded
                        : Icons.schedule_rounded,
                    size: 15,
                    color: ready
                        ? AppColors.fertileWindowText
                        : AppColors.ts(context),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      ready
                          ? l10n.pregnancyTestReady
                          : l10n.pregnancyTestFrom(
                              DateFormat('d MMMM', locale).format(testDay)),
                      style: TextStyle(
                        fontSize: 12,
                        color: ready
                            ? AppColors.fertileWindowText
                            : AppColors.ts(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }),
          ],
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
    final trimester = switch (CycleUtils.pregnancyTrimester(week)) {
      1 => l10n.trimester1,
      2 => l10n.trimester2,
      _ => l10n.trimester3,
    };

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

  Widget _buildPregnancyInsight(
    BuildContext context,
    AppLocalizations l10n,
    DateTime start,
  ) {
    final week = CycleUtils.pregnancyWeek(start);
    final development = switch (CycleUtils.pregnancyTrimester(week)) {
      1 => l10n.pregnancyDevelopment1,
      2 => l10n.pregnancyDevelopment2,
      _ => l10n.pregnancyDevelopment3,
    };
    final semantics =
        '${l10n.pregnancyDevelopmentTitle}. $development. '
        '${l10n.pregnancyCheckupReminder}';

    return Semantics(
      label: semantics,
      child: ExcludeSemantics(
        child: GlassCard(
          borderRadius: 20,
          blur: 0,
          opacity: 0.16,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 20,
                    color: AppColors.primaryDeep,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.pregnancyDevelopmentTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tp(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                development,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.tp(context),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 18,
                    color: AppColors.ts(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.pregnancyCheckupReminder,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.ts(context),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animateSafe(context).fadeIn(delay: 180.ms, duration: 400.ms);
  }

  /// Hap paketi kartı.
  ///
  /// Tek bir çipti: kaçıncı gün olduğu yazıyordu ama bu modun asıl sorusu
  /// ("ara ne zaman başlıyor", "yeni paket ne zaman") cevapsızdı.
  Widget _buildPillCard(
      BuildContext context, AppLocalizations l10n, DateTime packStart) {
    final day = CycleUtils.pillDayInPack(packStart);
    final isBreak = CycleUtils.pillIsBreak(day);
    final accent = isBreak ? AppColors.warningText : AppColors.primaryDeep;

    final title = isBreak
        ? l10n.pillBreakLabel(day - AppConstants.pillActiveDays)
        : l10n.pillDayLabel(day);
    final next = isBreak
        ? l10n.pillNewPackIn(CycleUtils.pillDaysUntilNewPack(day))
        : l10n.pillBreakIn(CycleUtils.pillDaysUntilBreak(day));

    return GlassCard(
      borderRadius: 18,
      blur: 0,
      opacity: 0.18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.medication_rounded, size: 20, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tp(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  next,
                  style: TextStyle(fontSize: 12, color: AppColors.ts(context)),
                ),
              ],
            ),
          ),
          // 28 günlük paketin neresindeyiz — sayı yerine oran
          Text(
            '$day/${AppConstants.pillPackDays}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    ).animateSafe(context).fadeIn(delay: 120.ms, duration: 400.ms);
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
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
          onLongPress: onLongPress,
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
                // Etiket iki butona bölünmüş dar alanda yaşıyor: büyük yazı
                // tipinde satırı taşırmak yerine sarmalı
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tp(context),
                    ),
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
