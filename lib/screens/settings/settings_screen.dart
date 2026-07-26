import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/access.dart';
import '../../core/utils/adaptive_layout.dart';
import '../../core/widgets/glass_card.dart';
import '../../models/user_profile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/utils/cycle_utils.dart';
import '../../models/enums.dart';
import '../../providers/providers.dart';
import '../../services/backup_service.dart';
import '../../services/encrypted_backup_codec.dart';
import '../../services/disguise_service.dart';
import '../../services/export_service.dart';
import '../../services/health_sync_service.dart';
import '../../services/hive_service.dart';
import '../../services/notification_service.dart';
import '../../services/premium_service.dart';
import '../../services/privacy_screen_service.dart';
import '../../services/quick_action_service.dart';
import '../../services/widget_service.dart';
import '../lock/pin_setup_dialog.dart';
import '../../core/utils/motion.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.tp(context),
          ),
        ),
        backgroundColor: AppColors.bg(context),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          GlassCard(
            borderRadius: 16,
            blur: 0,
            opacity: 0.12,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: AppColors.primaryStrong,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.privacySummary,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tp(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Profile section
          _sectionHeader(context, l10n.profileSection),
          _settingsCard(context, [
            _infoTile(
              context,
              Icons.person_rounded,
              l10n.name,
              profile?.name ?? '-',
            ),
            _divider(context),
            _infoTile(
              context,
              Icons.cake_rounded,
              l10n.age,
              profile?.age != null ? l10n.nYearsOld(profile!.age!) : '-',
            ),
            _divider(context),
            _infoTile(
              context,
              Icons.loop_rounded,
              l10n.cycleDuration,
              l10n.nDays(profile?.averageCycleLength ?? 28),
            ),
            _divider(context),
            _infoTile(
              context,
              Icons.water_drop_rounded,
              l10n.periodDuration,
              l10n.nDays(profile?.averagePeriodLength ?? 5),
            ),
            _divider(context),
            _actionTile(
              context,
              Icons.edit_rounded,
              l10n.editProfile,
              AppColors.primary,
              () => context.push('/profile-edit'),
            ),
            _divider(context),
            // Ücretsiz katmanda da açık: yanlış girilen regl kaydını
            // düzeltmek takibin kendisi kadar temel
            _actionTile(
              context,
              Icons.history_rounded,
              l10n.cycleHistory,
              AppColors.menstrual,
              () => context.push('/period-history'),
            ),
          ]),
          const SizedBox(height: 16),

          // Tracking mode
          _sectionHeader(context, l10n.trackingModeTitle),
          _settingsCard(context, [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 2×2 mod kartları: chip'ler dar ekranda taşıyordu —
                  // onboarding'deki mod adımıyla aynı dil (ikon + etiket)
                  Column(
                    children: [
                      for (final pair in [
                        [
                          (
                            TrackingMode.period,
                            Icons.water_drop_rounded,
                            l10n.modePeriod,
                          ),
                          (
                            TrackingMode.pregnancy,
                            Icons.pregnant_woman_rounded,
                            l10n.modePregnancy,
                          ),
                        ],
                        [
                          (
                            TrackingMode.pill,
                            Icons.medication_rounded,
                            l10n.modePill,
                          ),
                          (
                            TrackingMode.ttc,
                            Icons.favorite_rounded,
                            l10n.modeTtc,
                          ),
                        ],
                      ]) ...[
                        if (usesLargeText(MediaQuery.textScalerOf(context)))
                          Column(
                            children: [
                              for (final (mode, icon, label) in pair) ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: _modeCard(context, ref, profile, mode,
                                      icon, label),
                                ),
                                if (mode != pair.last.$1)
                                  const SizedBox(height: 10),
                              ],
                            ],
                          )
                        else
                          Row(
                            children: [
                              for (final (mode, icon, label) in pair) ...[
                                Expanded(
                                  child: _modeCard(context, ref, profile, mode,
                                      icon, label),
                                ),
                                if (mode != pair.last.$1)
                                  const SizedBox(width: 10),
                              ],
                            ],
                          ),
                        if (pair.first.$1 != TrackingMode.pill)
                          const SizedBox(height: 10),
                      ],
                    ],
                  ),
                  if (profile?.trackingMode == TrackingMode.pregnancy) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.pregnancyModeInfo,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.ts(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ]),
          const SizedBox(height: 16),

          // Preferences
          _sectionHeader(context, l10n.preferences),
          _settingsCard(context, [
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              title: Text(
                l10n.language,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              // 6 dil + sistem: varsayılan cihaz dilini izler
              trailing: DropdownButton<String>(
                value: profile?.language ?? 'system',
                underline: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(14),
                items: [
                  DropdownMenuItem(
                    value: 'system',
                    child: Text(l10n.languageSystem),
                  ),
                  const DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                  const DropdownMenuItem(value: 'en', child: Text('English')),
                  const DropdownMenuItem(value: 'es', child: Text('Español')),
                  const DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                  const DropdownMenuItem(value: 'fr', child: Text('Français')),
                  const DropdownMenuItem(value: 'ru', child: Text('Русский')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  ref.read(localeProvider.notifier).state = value == 'system'
                      ? null
                      : Locale(value);
                  ref
                      .read(userProfileProvider.notifier)
                      .saveProfile(language: value);
                },
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tp(context),
                ),
              ),
            ),
            _divider(context),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.weightColor.withValues(alpha: 0.25),
                      AppColors.weightColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.straighten_rounded,
                  color: AppColors.weightColor,
                  size: 22,
                ),
              ),
              title: Text(
                l10n.weight,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('kg')),
                  ButtonSegment(value: true, label: Text('lb')),
                ],
                selected: {profile?.usePounds ?? false},
                onSelectionChanged: (selected) => ref
                    .read(userProfileProvider.notifier)
                    .saveProfile(usePounds: selected.first),
              ),
            ),
            _divider(context),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.temperature.withValues(alpha: 0.25),
                      AppColors.temperature.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.thermostat_rounded,
                  color: AppColors.temperature,
                  size: 22,
                ),
              ),
              title: Text(
                l10n.temperature,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('°C')),
                  ButtonSegment(value: true, label: Text('°F')),
                ],
                selected: {profile?.useFahrenheit ?? false},
                onSelectionChanged: (selected) => ref
                    .read(userProfileProvider.notifier)
                    .saveProfile(useFahrenheit: selected.first),
              ),
            ),
            _divider(context),
            // Üç durumlu tema: sistem tercihi birinci sınıf seçenek —
            // ikili anahtar sistemi koyu kullananı el ile ayara mecbur
            // bırakıyordu
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.dark_mode_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              title: Text(
                l10n.theme,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              // Üçlü seçici trailing'e sığmıyordu (başlığı eziyor, dar
              // ekranda taşıyordu) — satırın altında tam genişlik
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'system',
                      label: Text(l10n.themeSystem),
                    ),
                    ButtonSegment(value: 'light', label: Text(l10n.themeLight)),
                    ButtonSegment(value: 'dark', label: Text(l10n.themeDark)),
                  ],
                  selected: {
                    switch (profile?.themePreference ?? 'system') {
                      'dark' => 'dark',
                      'light' => 'light',
                      'system' => 'system',
                      // '' = eski kayıt: o günkü açık/koyu seçimi
                      _ =>
                        (profile?.darkModeEnabled ?? false) ? 'dark' : 'light',
                    },
                  },
                  onSelectionChanged: (selected) {
                    final value = selected.first;
                    ref
                        .read(themeModeProvider.notifier)
                        .state = switch (value) {
                      'dark' => ThemeMode.dark,
                      'light' => ThemeMode.light,
                      _ => ThemeMode.system,
                    };
                    ref
                        .read(userProfileProvider.notifier)
                        .saveProfile(themePreference: value);
                  },
                  style: ButtonStyle(
                    // compact yoğunluk dokunma hedefini 48 px'in altına
                    // indiriyordu (Material asgarisi)
                    textStyle: WidgetStateProperty.all(TextStyle(fontSize: 12)),
                  ),
                ),
              ),
            ),
            _divider(context),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.view_agenda_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              title: Text(
                l10n.homePriority,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in HomePriority.values)
                      ChoiceChip(
                        label: Text(
                          option == HomePriority.cycle
                              ? l10n.cycleFirst
                              : l10n.todayFirst,
                        ),
                        selected:
                            ref.watch(homePriorityProvider) == option,
                        onSelected: (_) async {
                          ref.read(homePriorityProvider.notifier).state =
                              option;
                          final prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString(
                            homePriorityKey,
                            option.name,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            _divider(context),
            // Renk körü dostu doku modu: faz bantlarına renk + desen
            // çift kodlama (folliküler/luteal turuncu ailesi
            // deuteranopiada ayrışmıyor)
            _switchTile(
              context,
              Icons.texture_rounded,
              l10n.colorBlindPattern,
              ref.watch(phasePatternProvider),
              (val) async {
                ref.read(phasePatternProvider.notifier).state = val;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('phase_pattern', val);
              },
              subtitle: l10n.colorBlindPatternDesc,
            ),
            _divider(context),
            _switchTile(
              context,
              Icons.auto_awesome_rounded,
              l10n.smartPrediction,
              profile?.smartPredictionEnabled ?? true,
              (val) => ref
                  .read(userProfileProvider.notifier)
                  .saveProfile(smartPredictionEnabled: val),
              subtitle: _smartPredictionSubtitle(ref, l10n),
            ),
          ]),
          const SizedBox(height: 16),

          // Notifications
          _sectionHeader(context, l10n.notifications),
          _settingsCard(context, [
            _switchTile(
              context,
              Icons.notifications_rounded,
              l10n.periodReminder,
              profile?.periodReminderEnabled ?? true,
              (val) => ref
                  .read(userProfileProvider.notifier)
                  .saveProfile(periodReminderEnabled: val),
            ),
            _divider(context),
            _switchTile(
              context,
              Icons.egg_rounded,
              l10n.ovulationReminder,
              profile?.ovulationReminderEnabled ?? true,
              (val) => ref
                  .read(userProfileProvider.notifier)
                  .saveProfile(ovulationReminderEnabled: val),
            ),
            _divider(context),
            _switchTile(
              context,
              Icons.medication_rounded,
              l10n.medicationReminder,
              profile?.medicationReminderEnabled ?? false,
              (val) => ref
                  .read(userProfileProvider.notifier)
                  .saveProfile(medicationReminderEnabled: val),
            ),
            _divider(context),
            // Tek saat üç türü birden yönetiyordu: ilacını sabah alan ama
            // regl uyarısını akşam isteyen kullanıcı birinden vazgeçiyordu
            _reminderTimeTile(
              context,
              ref,
              title: l10n.cycleReminderTime,
              hour: profile?.effectiveCycleHour ?? 9,
              minute: profile?.effectiveCycleMinute ?? 0,
              onPicked: (t) => ref
                  .read(userProfileProvider.notifier)
                  .saveProfile(
                    cycleReminderHour: t.hour,
                    cycleReminderMinute: t.minute,
                  ),
            ),
            _divider(context),
            _reminderTimeTile(
              context,
              ref,
              title: l10n.medicationReminderTime,
              hour: profile?.effectiveMedicationHour ?? 9,
              minute: profile?.effectiveMedicationMinute ?? 0,
              onPicked: (t) => ref
                  .read(userProfileProvider.notifier)
                  .saveProfile(
                    medicationReminderHour: t.hour,
                    medicationReminderMinute: t.minute,
                  ),
            ),
            _divider(context),
            _leadDaysTile(context, ref, profile, l10n),
            _divider(context),
            _notificationFrequencyTile(context, ref, profile, l10n),
            _divider(context),
            // Ayarlarda yalnız tür başına aç/kapa vardı: "bildirim istiyorum
            // ama telefonum çalmasın" diyen kullanıcının tek seçeneği hepsini
            // kapatmaktı
            _switchTile(
              context,
              Icons.notifications_off_rounded,
              l10n.quietNotifications,
              profile?.quietNotifications ?? false,
              (val) => ref
                  .read(userProfileProvider.notifier)
                  .saveProfile(quietNotifications: val),
              subtitle: l10n.quietNotificationsDesc,
            ),
          ]),
          const SizedBox(height: 16),

          // Security
          _sectionHeader(context, l10n.security),
          _settingsCard(context, [
            // Gizli mod uygulamanın ayırt edici güvenlik özelliği; kartın
            // dibinde PIN seçeneklerinin altında kaybolmamalı.
            if (DisguiseService.isSupported) ...[
              const _DisguiseTile(),
              _divider(context),
            ],
            if (PrivacyScreenService.isSupported) ...[
              const _ScreenProtectionTile(),
              _divider(context),
            ],
            _switchTile(
              context,
              Icons.pin_rounded,
              l10n.pinLock,
              profile?.pinEnabled ?? false,
              (val) async {
                if (val) {
                  final success = await showPinSetupDialog(context);
                  if (success) {
                    ref
                        .read(userProfileProvider.notifier)
                        .saveProfile(pinEnabled: true);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.pinSet),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  }
                } else {
                  // Güvenlik gevşetme mevcut PIN'i ister: kilidi açık
                  // unutulmuş telefonda tek dokunuşla koruma kalkmasın
                  final verified = await showPinVerifyDialog(context);
                  if (!verified) return;
                  const storage = FlutterSecureStorage();
                  await storage.delete(key: 'app_pin');
                  // Kilitlenme sayacı da gitmeli: PIN yeniden kurulduğunda
                  // eski yanlış denemeler yüzünden bekleme başlamasın
                  await storage.delete(key: 'pin_failed_attempts');
                  await storage.delete(key: 'pin_lockout_until');
                  // Biyometri PIN'i fallback olarak şart koşuyor (kurulumda
                  // zorunlu); PIN gidince biyometri tek başına kalamaz —
                  // sensör arızasında kalıcı kilitlenme demek olur
                  await ref
                      .read(userProfileProvider.notifier)
                      .saveProfile(pinEnabled: false, biometricEnabled: false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.pinRemoved),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
            ),
            _divider(context),
            _switchTile(
              context,
              Icons.fingerprint_rounded,
              l10n.biometricLock,
              profile?.biometricEnabled ?? false,
              (val) async {
                if (val) {
                  final localAuth = LocalAuthentication();
                  final canCheck = await localAuth.canCheckBiometrics;
                  final isSupported = await localAuth.isDeviceSupported();
                  if (!canCheck || !isSupported) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.biometricNotAvailable),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                    }
                    return;
                  }
                  // PIN yoksa önce PIN kurduralım (fallback için)
                  if (profile?.pinEnabled != true) {
                    if (!context.mounted) return;
                    final pinSet = await showPinSetupDialog(context);
                    if (!pinSet) return;
                    ref
                        .read(userProfileProvider.notifier)
                        .saveProfile(pinEnabled: true);
                  }
                }
                ref
                    .read(userProfileProvider.notifier)
                    .saveProfile(biometricEnabled: val);
              },
            ),
            // Kilit varken anlamlı: gecikme yoksa her dönüşte PIN
            if ((profile?.pinEnabled ?? false) ||
                (profile?.biometricEnabled ?? false)) ...[
              _divider(context),
              const _LockTimeoutTile(),
            ],
          ]),
          const SizedBox(height: 16),

          // Premium: durum + planlar. Erişim kararı accessProvider'da
          // (premium / deneme N gün / ücretsiz)
          _sectionHeader(context, l10n.premiumSection),
          Builder(
            builder: (context) {
              final access = ref.watch(accessProvider);
              final daysLeft = ref.watch(trialDaysLeftProvider);
              final statusText = switch (access) {
                AccessLevel.premium => l10n.premiumActive,
                AccessLevel.trial => l10n.trialBadge(daysLeft),
                AccessLevel.free => l10n.freeBadge,
              };
              return _settingsCard(context, [
                _infoTile(
                  context,
                  Icons.workspace_premium_rounded,
                  l10n.premiumSection,
                  statusText,
                ),
                if (access == AccessLevel.free) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      l10n.freeExplain,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.ts(context),
                      ),
                    ),
                  ),
                ],
                if (access != AccessLevel.premium) ...[
                  _divider(context),
                  _actionTile(
                    context,
                    Icons.workspace_premium_rounded,
                    l10n.seePlans,
                    AppColors.warning,
                    () => context.push('/paywall'),
                  ),
                ],
                _divider(context),
                _actionTile(
                  context,
                  Icons.restore_page_rounded,
                  l10n.restorePurchases,
                  AppColors.primary,
                  () async {
                    // Sonuç söylenmeli: sessiz kalınca buton bozuk görünüyordu
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.restoringPurchases)),
                    );
                    final restored = await PremiumService().restore();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          restored
                              ? l10n.premiumActive
                              : l10n.noPurchasesToRestore,
                        ),
                      ),
                    );
                  },
                ),
              ]);
            },
          ),
          const SizedBox(height: 16),

          // Data
          _sectionHeader(context, l10n.dataSection),
          _settingsCard(context, [
            // Yedek bayatladıysa (ya da hiç alınmadıysa) uyarı satırı:
            // yedekleme tamamen kullanıcıya bırakılmıştı ve telefon
            // kaybında yılların verisi gidiyordu
            _backupStatusTile(context, ref, l10n),
            _divider(context),
            _actionTile(
              context,
              Icons.backup_rounded,
              l10n.backupData,
              AppColors.primary,
              () async {
                final password = await _requestBackupPassword(
                  context,
                  l10n,
                  confirmPassword: true,
                );
                if (password == null || !context.mounted) return;
                try {
                  final backupService = BackupService(HiveService());
                  final path = await _withBackupProgress(
                    context,
                    l10n.backupData,
                    () => backupService.exportBackup(password),
                  );
                  await ExportService().shareFile(path);
                  // Dosyayı yazmak yeterli değil; paylaşım da tamamlandı
                  await BackupService.markBackedUp();
                  ref.invalidate(lastBackupProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.errorOccurred(e.toString())),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
            ),
            _divider(context),
            _actionTile(
              context,
              Icons.restore_rounded,
              l10n.restoreData,
              AppColors.primary,
              () async {
                await _restoreFromBackup(context, ref, l10n);
              },
            ),
            _divider(context),
            _actionTile(
              context,
              Icons.favorite_rounded,
              l10n.healthSync,
              AppColors.error,
              () async {
                if (!ensurePremiumAccess(context, ref)) return;
                final result = await HealthSyncService().syncPeriods(
                  ref.read(periodRecordsProvider),
                );
                if (!context.mounted) return;
                final (message, color) = switch (result) {
                  HealthSyncResult.success => (
                    l10n.healthSyncSuccess,
                    AppColors.success,
                  ),
                  HealthSyncResult.permissionDenied => (
                    l10n.healthSyncDenied,
                    AppColors.warning,
                  ),
                  HealthSyncResult.unavailable => (
                    l10n.healthSyncUnavailable,
                    AppColors.warning,
                  ),
                  HealthSyncResult.error => (
                    l10n.healthSyncFailed,
                    AppColors.error,
                  ),
                };
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message), backgroundColor: color),
                );
              },
            ),
            _divider(context),
            // Entegrasyon tek yönlüydü: uygulama yazıyordu ama okumuyordu.
            // Başka uygulamadan geçen kullanıcının geçmişi Health
            // Connect'te duruyor olabilir.
            _actionTile(
              context,
              Icons.download_rounded,
              l10n.healthImport,
              AppColors.primaryDeep,
              () async {
                if (!ensurePremiumAccess(context, ref)) return;
                await _importFromHealth(context, ref, l10n);
              },
            ),
            _divider(context),
            _actionTile(
              context,
              Icons.picture_as_pdf_rounded,
              l10n.exportPdfReport,
              AppColors.error,
              () async {
                if (!ensurePremiumAccess(context, ref)) return;
                final exportService = ExportService();
                final periods = ref.read(periodRecordsProvider);
                final dailyLogs = ref.read(dailyLogProvider);
                final p = ref.read(userProfileProvider);
                if (p == null) return;
                try {
                  final path = await exportService.exportPdf(
                    p,
                    periods,
                    dailyLogs,
                    l10n,
                  );
                  await exportService.shareFile(path);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.errorOccurred(e.toString())),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
            ),
            _divider(context),
            _actionTile(
              context,
              Icons.table_chart_rounded,
              l10n.exportCsvFile,
              AppColors.success,
              () async {
                if (!ensurePremiumAccess(context, ref)) return;
                final exportService = ExportService();
                final periods = ref.read(periodRecordsProvider);
                final dailyLogs = ref.read(dailyLogProvider);
                try {
                  final path = await exportService.exportCsv(
                    periods,
                    dailyLogs,
                    l10n,
                  );
                  await exportService.shareFile(path);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.errorOccurred(e.toString())),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
            ),
            _divider(context),
            _actionTile(
              context,
              Icons.calendar_month_rounded,
              l10n.exportCalendarFile,
              AppColors.primaryDeep,
              () async {
                if (!ensurePremiumAccess(context, ref)) return;
                final exportService = ExportService();
                try {
                  final path = await exportService.exportCalendar(
                    ref.read(periodRecordsProvider),
                    l10n,
                  );
                  await exportService.shareFile(path);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.errorOccurred(e.toString())),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
            ),
            _divider(context),
            _actionTile(
              context,
              Icons.delete_forever_rounded,
              l10n.deleteAllData,
              AppColors.error,
              () async {
                final controller = TextEditingController();
                final deleteToken = l10n.delete.toUpperCase();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => StatefulBuilder(
                    builder: (ctx, setDialogState) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      title: Text(l10n.deleteAllData),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.deleteAllDataConfirm),
                          const SizedBox(height: 16),
                          Text(
                            deleteToken,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: controller,
                            autofocus: true,
                            textCapitalization: TextCapitalization.characters,
                            onChanged: (_) => setDialogState(() {}),
                            decoration: InputDecoration(
                              hintText: deleteToken,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: controller.text.trim().toUpperCase() ==
                                  deleteToken
                              ? () => Navigator.pop(ctx, true)
                              : null,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: Text(l10n.delete),
                        ),
                      ],
                    ),
                  ),
                );
                controller.dispose();
                if (confirmed == true) {
                  await HiveService().clearAll();
                  // Migrasyondan kalan düz metin anlık görüntü de "tüm veri"nin
                  // parçası — kutularla birlikte gitmeli
                  await HiveService().deleteLegacyPlaintextSnapshot();
                  // Veri silindi ama kilit, bildirimler ve ana ekran widget'ı
                  // eski veriyle ayakta kalıyordu: PIN hâlâ kurulu, hatırlatmalar
                  // planlı, widget döngü gününü göstermeye devam ediyordu
                  const storage = FlutterSecureStorage();
                  await storage.delete(key: 'app_pin');
                  await storage.delete(key: 'pin_failed_attempts');
                  await storage.delete(key: 'pin_lockout_until');
                  try {
                    await NotificationService().cancelAll();
                  } catch (_) {
                    // Bildirim iptali başarısız olsa da silme tamamlanmalı
                  }
                  await WidgetService.update(null, const []);

                  ref.read(userProfileProvider.notifier).refresh();
                  ref.read(periodRecordsProvider.notifier).refresh();
                  ref.read(dailyLogProvider.notifier).refresh();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.dataDeleted),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    context.go('/onboarding');
                  }
                }
              },
            ),
          ]),
          const SizedBox(height: 16),

          // About
          _sectionHeader(context, l10n.about),
          _settingsCard(context, [
            _infoTile(context, Icons.info_rounded, l10n.version, '1.1.0'),
            _divider(context),
            _actionTile(
              context,
              Icons.privacy_tip_rounded,
              l10n.privacyPolicy,
              AppColors.primary,
              () => _showPrivacyPolicy(context, l10n),
            ),
          ]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.ts(context).withValues(alpha: 0.6),
                ),
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
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showPrivacyPolicy(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    // Yasal metin arayüz dilini izlemeli; politika dosyası yalnız TR/EN
    // var — diğer diller İngilizce politikayı görür
    final lang = Localizations.localeOf(context).languageCode == 'tr'
        ? 'tr'
        : 'en';
    final text = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/legal/privacy_policy_$lang.md');
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.privacyPolicy),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.tp(ctx),
              ),
            ),
          ),
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

  /// Health Connect'ten adet geçmişini içe aktarır.
  ///
  /// Okuma öneri üretir, yazma kullanıcı onayından sonra: kimsenin
  /// geçmişi sorulmadan değiştirilmemeli. Mevcut kayıtlarla kesişen
  /// aralıklar serviste zaten eleniyor — kullanıcının kendi kaydı esas.
  Future<void> _importFromHealth(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await HealthSyncService().readPeriods(
      ref.read(periodRecordsProvider),
    );
    if (!context.mounted) return;

    if (result.status != HealthSyncResult.success) {
      final (message, color) = switch (result.status) {
        HealthSyncResult.permissionDenied => (
          l10n.healthSyncDenied,
          AppColors.warning,
        ),
        HealthSyncResult.unavailable => (
          l10n.healthSyncUnavailable,
          AppColors.warning,
        ),
        _ => (l10n.healthSyncFailed, AppColors.error),
      };
      messenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
      return;
    }

    if (result.ranges.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.healthImportNothingNew)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.healthImport),
        content: Text(
          l10n.healthImportConfirm(result.ranges.length),
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.healthImportAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final notifier = ref.read(periodRecordsProvider.notifier);
    for (final (start, end) in result.ranges) {
      final record = await notifier.startPeriod(start);
      await notifier.endPeriod(record.id, end);
    }
    // Profil tarihi kayıtların türevi: en yeni kayda eşitlenmeli
    final records = ref.read(periodRecordsProvider);
    if (records.isNotEmpty) {
      await ref
          .read(userProfileProvider.notifier)
          .saveProfile(lastPeriodStart: records.first.startDate);
    }
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.healthImportDone(result.ranges.length)),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _onModeChanged(
    BuildContext context,
    WidgetRef ref,
    TrackingMode mode,
  ) async {
    // Modlar (hamilelik/hap/TTC) premium kapsamı; regl modu her zaman açık
    if (mode != TrackingMode.period && !ensurePremiumAccess(context, ref)) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.read(userProfileProvider);
    if (profile?.trackingMode == mode) return;

    final explanation = switch (mode) {
      TrackingMode.pregnancy => l10n.pregnancyModeInfo,
      TrackingMode.pill => l10n.modePillDesc,
      TrackingMode.ttc => l10n.modeTtcDesc,
      TrackingMode.period => l10n.modePeriodDesc,
    };
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.trackingModeTitle),
        content: Text(
          explanation,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.continueBtn),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    if (mode == TrackingMode.pregnancy) {
      // Gebelik başlangıcı = son adet tarihi; öneri olarak mevcut değer
      final picked = await showDatePicker(
        context: context,
        initialDate:
            profile?.pregnancyStartDate ??
            profile?.lastPeriodStart ??
            DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 300)),
        lastDate: DateTime.now(),
        helpText: l10n.pregnancyStartLabel,
      );
      if (picked == null) return; // vazgeçti — mod değişmesin
      await ref
          .read(userProfileProvider.notifier)
          .saveProfile(trackingMode: mode, pregnancyStartDate: picked);
      return;
    }

    if (mode == TrackingMode.pill) {
      final picked = await showDatePicker(
        context: context,
        initialDate: profile?.pillPackStartDate ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 28)),
        lastDate: DateTime.now(),
        helpText: l10n.pillPackStartLabel,
      );
      if (picked == null) return;
      await ref
          .read(userProfileProvider.notifier)
          .saveProfile(trackingMode: mode, pillPackStartDate: picked);
      return;
    }

    // period ve ttc: ekstra tarih girdisi gerekmez
    await ref
        .read(userProfileProvider.notifier)
        .saveProfile(trackingMode: mode);
  }

  String _smartPredictionSubtitle(WidgetRef ref, AppLocalizations l10n) {
    final learned = CycleUtils.learnedCycleLength(
      ref.watch(periodRecordsProvider),
    );
    if (learned != null) return l10n.learnedCycleLength(learned);
    return l10n.smartPredictionDesc;
  }

  Future<void> _restoreFromBackup(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['rtbackup', 'json'],
    );
    final path = result?.files.single.path;
    if (path == null) return;

    final BackupData data;
    var isLegacyBackup = false;
    try {
      final backupService = BackupService(HiveService());
      var source = await backupService.readBackupFile(path);
      final isEncrypted = path.toLowerCase().endsWith('.rtbackup') ||
          backupService.isEncryptedBackup(source);
      if (isEncrypted) {
        if (!context.mounted) return;
        final password = await _requestBackupPassword(
          context,
          l10n,
          confirmPassword: false,
        );
        if (password == null || !context.mounted) return;
        source = await _withBackupProgress(
          context,
          l10n.unlockBackupTitle,
          () => backupService.decryptBackup(source, password),
        );
      } else {
        isLegacyBackup = true;
      }
      data = backupService.parseBackup(source);
    } on EncryptedBackupException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.backupPasswordOrFileInvalid),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.invalidBackupFile),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.restoreConfirmTitle),
        content: Text(
          [
            l10n.restoreConfirmBody(data.totalRecordCount),
            if (isLegacyBackup) l10n.legacyBackupWarning,
          ].join('\n\n'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.restore),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await BackupService(HiveService()).restoreBackup(data);
    ref.read(userProfileProvider.notifier).refresh();
    ref.read(periodRecordsProvider.notifier).refresh();
    ref.read(dailyLogProvider.notifier).refresh();

    // Geri yüklenen veriye göre bildirimleri ve widget'ı yeniden kur
    final restoredProfile = HiveService().getUserProfile();
    if (restoredProfile != null) {
      try {
        // İlaç hatırlatmaları da yedekteki listeye göre kurulmalı
        await NotificationService().rescheduleAll(
          restoredProfile,
          records: HiveService().getAllPeriodRecords(),
          medications: restoredProfile.medicationPlan,
          logs: HiveService().getAllDailyLogs(),
        );
      } catch (_) {
        // Bildirim kurulamasa da geri yükleme başarılı sayılır
      }
      await WidgetService.update(
        restoredProfile,
        HiveService().getAllPeriodRecords(),
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.backupRestored),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<String?> _requestBackupPassword(
    BuildContext context,
    AppLocalizations l10n, {
    required bool confirmPassword,
  }) async {
    final passwordController = TextEditingController();
    final confirmationController = TextEditingController();
    var obscurePassword = true;
    String? errorText;

    try {
      return await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setSheetState) {
            void submit() {
              final password = passwordController.text;
              final confirmation = confirmationController.text;
              final validation = validateBackupPassword(
                password,
                confirmation: confirmPassword ? confirmation : null,
              );
              final error = switch (validation) {
                BackupPasswordValidation.valid => null,
                BackupPasswordValidation.invalidLength =>
                  l10n.backupPasswordLength,
                BackupPasswordValidation.mismatch =>
                  l10n.backupPasswordsDoNotMatch,
              };
              if (error != null) {
                setSheetState(() => errorText = error);
                return;
              }
              Navigator.pop(sheetContext, password);
            }

            final visibilityLabel = obscurePassword
                ? l10n.showPassword
                : l10n.hidePassword;
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  0,
                  24,
                  24 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      confirmPassword
                          ? l10n.backupData
                          : l10n.unlockBackupTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      confirmPassword
                          ? l10n.backupNoRecovery
                          : l10n.unlockBackupBody,
                      style: TextStyle(
                        height: 1.4,
                        color: confirmPassword
                            ? AppColors.warningText
                            : AppColors.ts(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      autofocus: true,
                      obscureText: obscurePassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: confirmPassword
                          ? TextInputAction.next
                          : TextInputAction.done,
                      onSubmitted: confirmPassword ? null : (_) => submit(),
                      decoration: InputDecoration(
                        labelText: l10n.backupPassword,
                        errorText: errorText,
                        suffixIcon: IconButton(
                          tooltip: visibilityLabel,
                          onPressed: () => setSheetState(
                            () => obscurePassword = !obscurePassword,
                          ),
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                          ),
                        ),
                      ),
                    ),
                    if (confirmPassword) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmationController,
                        obscureText: obscurePassword,
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => submit(),
                        decoration: InputDecoration(
                          labelText: l10n.backupPasswordConfirm,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: Text(l10n.cancel),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: submit,
                          child: Text(l10n.continueBtn),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } finally {
      passwordController.dispose();
      confirmationController.dispose();
    }
  }

  Future<T> _withBackupProgress<T>(
    BuildContext context,
    String label,
    Future<T> Function() operation,
  ) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    );
    try {
      return await operation();
    } finally {
      if (navigator.canPop()) navigator.pop();
    }
  }

  Widget _sectionHeader(BuildContext context, String title) {
    // Bölüm başlığı dili: 13/w700 ikincil renk — kart başlıklarından
    // (18/bold birincil) net biçimde ayrışır, ListView ritmini bozmaz
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.ts(context),
        ),
      ),
    ).animateSafe(context).fadeIn(duration: 400.ms);
  }

  Widget _settingsCard(BuildContext context, List<Widget> children) {
    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.15,
      child: Column(children: children),
    ).animateSafe(context).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _infoTile(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    final largeText = usesLargeText(MediaQuery.textScalerOf(context));
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.25),
              AppColors.primary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: largeText
          ? Text(value,
              style: TextStyle(fontSize: 14, color: AppColors.ts(context)))
          : null,
      // Uzun değerler ("Deneme: 27 gün kaldı", uzun isim) başlığı ezmesin
      trailing: largeText
          ? null
          : ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 170),
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 14, color: AppColors.ts(context)),
              ),
            ),
    );
  }

  /// Takip modu kartı (2×2 ızgaranın hücresi): ikon + etiket, seçili
  /// hal tek vurgu ailesinin gradyanını giyer
  Widget _modeCard(
    BuildContext context,
    WidgetRef ref,
    UserProfile? profile,
    TrackingMode mode,
    IconData icon,
    String label,
  ) {
    final selected = (profile?.trackingMode ?? TrackingMode.period) == mode;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onModeChanged(context, ref, mode),
        child: ExcludeSemantics(
          child: AnimatedContainer(
            duration: context.motionDuration(const Duration(milliseconds: 200)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryStrong, AppColors.primaryDeep],
                    )
                  : null,
              color: selected ? null : AppColors.bg(context),
              borderRadius: BorderRadius.circular(16),
              border: selected
                  ? null
                  : Border.all(color: AppColors.dv(context)),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: selected ? Colors.white : AppColors.primaryStrong,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.tp(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _switchTile(
    BuildContext context,
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    String? subtitle,
  }) {
    // İkon durumu taşır: özellik kapalıyken rozet soluklaşır — satırın
    // açık/kapalı hali switch'e bakmadan, ikondan okunur
    final iconColor = value ? AppColors.primary : AppColors.ts(context);
    return ListTile(
      leading: AnimatedContainer(
        duration: context.motionDuration(const Duration(milliseconds: 200)),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: value
                ? [
                    AppColors.primary.withValues(alpha: 0.25),
                    AppColors.primary.withValues(alpha: 0.1),
                  ]
                : [
                    AppColors.ts(context).withValues(alpha: 0.12),
                    AppColors.ts(context).withValues(alpha: 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(fontSize: 12))
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  Widget _actionTile(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.25),
              color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.ts(context)),
    );
  }

  /// Son yedeğin durumu. Bayat ya da hiç alınmamışsa uyarı tonunda;
  /// güncelse sessiz bir bilgi satırı.
  Widget _backupStatusTile(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final async = ref.watch(lastBackupProvider);
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (last) {
        final stale = BackupService.isStale(last);
        final locale = Localizations.localeOf(context).toString();
        final text = last == null
            ? l10n.backupNever
            : l10n.backupLastAt(DateFormat('d MMM yyyy', locale).format(last));
        final color = stale ? AppColors.warningText : AppColors.ts(context);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                stale ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stale ? '$text ${l10n.backupStaleHint}' : text,
                  style: TextStyle(fontSize: 12, height: 1.4, color: color),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Regl hatırlatmasının kaç gün önce gönderileceği. Sabit 1 gündü;
  /// kimi kullanıcı hazırlanmak için daha erken haber almak istiyor.
  Widget _leadDaysTile(
    BuildContext context,
    WidgetRef ref,
    UserProfile? profile,
    AppLocalizations l10n,
  ) {
    final lead = profile?.periodReminderLeadDays ?? 1;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.25),
              AppColors.primary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.event_available_rounded,
          color: AppColors.primary,
          size: 22,
        ),
      ),
      title: Text(
        l10n.periodReminderLead,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: DropdownButton<int>(
        value: lead.clamp(0, 7),
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(14),
        items: [
          DropdownMenuItem(value: 0, child: Text(l10n.leadSameDay)),
          for (final d in const [1, 2, 3, 5, 7])
            DropdownMenuItem(value: d, child: Text(l10n.leadNDaysBefore(d))),
        ],
        onChanged: (value) {
          if (value == null) return;
          ref
              .read(userProfileProvider.notifier)
              .saveProfile(periodReminderLeadDays: value);
        },
      ),
    );
  }

  Widget _notificationFrequencyTile(
    BuildContext context,
    WidgetRef ref,
    UserProfile? profile,
    AppLocalizations l10n,
  ) {
    final frequency = profile?.cycleNotificationFrequency ?? 3;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.25),
              AppColors.primary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.tune_rounded,
          color: AppColors.primary,
          size: 22,
        ),
      ),
      title: Text(
        l10n.cycleNotificationFrequency,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(l10n.cycleNotificationFrequencyDesc),
      trailing: DropdownButton<int>(
        value: frequency.clamp(1, 3),
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(14),
        items: [
          DropdownMenuItem(
            value: 1,
            child: Text(l10n.notificationFrequencyEssential),
          ),
          DropdownMenuItem(
            value: 2,
            child: Text(l10n.notificationFrequencyBalanced),
          ),
          DropdownMenuItem(
            value: 3,
            child: Text(l10n.notificationFrequencyDetailed),
          ),
        ],
        onChanged: (value) {
          if (value == null) return;
          ref
              .read(userProfileProvider.notifier)
              .saveProfile(cycleNotificationFrequency: value);
        },
      ),
    );
  }

  Widget _reminderTimeTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required int hour,
    required int minute,
    required void Function(TimeOfDay) onPicked,
  }) {
    final timeStr =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return ListTile(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hour, minute: minute),
        );
        if (picked != null) onPicked(picked);
      },
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.25),
              AppColors.primary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.access_time_rounded,
          color: AppColors.primary,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: Text(
        timeStr,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.isDark(context)
              ? AppColors.primaryLight
              : AppColors.primaryStrong,
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppColors.dv(context)),
    );
  }
}

/// Gizli mod anahtarı: launcher ikonunu/adını "Notlar" kılığına sokar.
/// Durum platformdan okunur (secure storage değil — gerçek alias durumu).
class _DisguiseTile extends ConsumerStatefulWidget {
  const _DisguiseTile();

  @override
  ConsumerState<_DisguiseTile> createState() => _DisguiseTileState();
}

class _DisguiseTileState extends ConsumerState<_DisguiseTile> {
  bool? _enabled;

  @override
  void initState() {
    super.initState();
    DisguiseService.isDisguised().then((value) {
      if (mounted) setState(() => _enabled = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.25),
              AppColors.primary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.visibility_off_rounded,
          color: AppColors.primary,
          size: 22,
        ),
      ),
      title: Text(
        l10n.disguiseTitle,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(l10n.disguiseDesc, style: TextStyle(fontSize: 11)),
      trailing: Switch(
        value: _enabled ?? false,
        activeThumbColor: AppColors.primary,
        onChanged: _enabled == null
            ? null
            : (value) async {
                // Gizli mod premium kapsamı; KAPATMAK her zaman serbest
                // (aboneliği biten kullanıcı kılıkta mahsur kalmamalı)
                if (value && !ensurePremiumAccess(context, ref)) return;
                final ok = await DisguiseService.setDisguise(value);
                if (!ok) return;
                // Launcher kimliği değiştiği anda sağlık kısayolları da
                // kaybolmalı; uygulamanın yeniden açılmasını bekleme.
                await QuickActionService().sync(
                  disguised: value,
                  quickLogTitle: l10n.shortcutQuickLog,
                  todayTitle: l10n.shortcutToday,
                );
                // Widget'ı yeni duruma göre hemen yenile: gizliyken nötr
                // içerik, kapatınca gerçek döngü verisi
                await WidgetService.update(
                  HiveService().getUserProfile(),
                  HiveService().getAllPeriodRecords(),
                );
                // Planlı bildirimler de kılığa uymalı: gizliyken "Adet
                // Hatırlatması" kilit ekranına düşerse kılığın anlamı kalmaz
                final profile = HiveService().getUserProfile();
                if (profile != null) {
                  try {
                    await NotificationService().rescheduleAll(
                      profile,
                      records: HiveService().getAllPeriodRecords(),
                      medications: profile.medicationPlan,
                      logs: HiveService().getAllDailyLogs(),
                    );
                  } catch (_) {
                    // Bildirim kurulamazsa kılık değişimi yine geçerli
                  }
                }
                if (mounted) setState(() => _enabled = value);
              },
      ),
    );
  }
}

class _ScreenProtectionTile extends StatefulWidget {
  const _ScreenProtectionTile();

  @override
  State<_ScreenProtectionTile> createState() => _ScreenProtectionTileState();
}

class _ScreenProtectionTileState extends State<_ScreenProtectionTile> {
  @override
  void initState() {
    super.initState();
    ScreenProtection.load();
  }

  (String, String) _labels(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => (
          'Ekran görüntüsü koruması',
          'Ekran görüntülerini ve son uygulamalar önizlemesini engeller.'
        ),
      'de' => (
          'Bildschirmschutz',
          'Blockiert Screenshots und die Vorschau der letzten Apps.'
        ),
      'es' => (
          'Protección de pantalla',
          'Bloquea capturas y la vista previa de aplicaciones recientes.'
        ),
      'fr' => (
          'Protection de l’écran',
          'Bloque les captures et l’aperçu des applications récentes.'
        ),
      'ru' => (
          'Защита экрана',
          'Блокирует снимки экрана и предпросмотр недавних приложений.'
        ),
      _ => (
          'Screen protection',
          'Blocks screenshots and the recent-apps preview.'
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = _labels(context);
    return ValueListenableBuilder<bool>(
      valueListenable: ScreenProtection.enabled,
      builder: (context, enabled, _) => ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.screenshot_monitor_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: Switch(
          value: enabled,
          activeThumbColor: AppColors.primary,
          onChanged: ScreenProtection.write,
        ),
      ),
    );
  }
}

/// Kilit gecikmesi seçici. Cihaza özel tercih olduğu için profilde değil
/// SharedPreferences'ta (PIN/biyometri durumu da yedeğe girmiyor).
class _LockTimeoutTile extends StatefulWidget {
  const _LockTimeoutTile();

  @override
  State<_LockTimeoutTile> createState() => _LockTimeoutTileState();
}

class _LockTimeoutTileState extends State<_LockTimeoutTile> {
  int? _seconds;

  @override
  void initState() {
    super.initState();
    LockTimeout.read().then((value) {
      if (mounted) setState(() => _seconds = value);
    });
  }

  String _label(AppLocalizations l10n, int seconds) => switch (seconds) {
    0 => l10n.lockImmediately,
    60 => l10n.lockAfterMinutes(1),
    300 => l10n.lockAfterMinutes(5),
    _ => l10n.lockAfterMinutes(15),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.25),
              AppColors.primary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.lock_clock_rounded,
          color: AppColors.primary,
          size: 22,
        ),
      ),
      title: Text(
        l10n.lockTimeoutTitle,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        l10n.lockTimeoutDesc,
        style: const TextStyle(fontSize: 11),
      ),
      trailing: _seconds == null
          ? const SizedBox.shrink()
          : DropdownButton<int>(
              value: _seconds,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(14),
              items: [
                for (final s in LockTimeout.options)
                  DropdownMenuItem(value: s, child: Text(_label(l10n, s))),
              ],
              onChanged: (value) async {
                if (value == null) return;
                setState(() => _seconds = value);
                await LockTimeout.write(value);
              },
            ),
    );
  }
}
