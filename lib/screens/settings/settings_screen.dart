import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/access.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/art/art_slot.dart';
import '../../models/user_profile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../core/utils/cycle_utils.dart';
import '../../models/enums.dart';
import '../../providers/providers.dart';
import '../../services/backup_service.dart';
import '../../services/disguise_service.dart';
import '../../services/export_service.dart';
import '../../services/health_sync_service.dart';
import '../../services/hive_service.dart';
import '../../services/notification_service.dart';
import '../../services/premium_service.dart';
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
        title: Text(l10n.settings,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.tp(context))),
        backgroundColor: AppColors.bg(context),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          // Profil başlığı görseli
          ArtSlot(id: 'R16-profile-header', height: 120, radius: 20),
          const SizedBox(height: 16),
          // Profile section
          _sectionHeader(context, l10n.profileSection),
          _settingsCard(context, [
            _infoTile(context, Icons.person_rounded, l10n.name, profile?.name ?? '-'),
            _divider(context),
            _infoTile(context, Icons.cake_rounded, l10n.age,
                profile?.age != null ? l10n.nYearsOld(profile!.age!) : '-'),
            _divider(context),
            _infoTile(context, Icons.loop_rounded, l10n.cycleDuration,
                l10n.nDays(profile?.averageCycleLength ?? 28)),
            _divider(context),
            _infoTile(context, Icons.water_drop_rounded, l10n.periodDuration,
                l10n.nDays(profile?.averagePeriodLength ?? 5)),
            _divider(context),
            _actionTile(context, Icons.edit_rounded, l10n.editProfile,
                AppColors.primary, () => context.push('/profile-edit')),
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
                          (TrackingMode.period, Icons.water_drop_rounded,
                              l10n.modePeriod),
                          (
                            TrackingMode.pregnancy,
                            Icons.pregnant_woman_rounded,
                            l10n.modePregnancy
                          ),
                        ],
                        [
                          (TrackingMode.pill, Icons.medication_rounded,
                              l10n.modePill),
                          (TrackingMode.ttc, Icons.favorite_rounded,
                              l10n.modeTtc),
                        ],
                      ]) ...[
                        Row(
                          children: [
                            for (final (mode, icon, label) in pair) ...[
                              Expanded(
                                child: _modeCard(context, ref, profile,
                                    mode, icon, label),
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
                          fontSize: 12, color: AppColors.ts(context)),
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
                    colors: [AppColors.primary.withValues(alpha: 0.25), AppColors.primary.withValues(alpha: 0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.language_rounded,
                    color: AppColors.primary, size: 22),
              ),
              title: Text(l10n.language,
                  style: TextStyle(fontWeight: FontWeight.w600)),
              // 6 dil + sistem: varsayılan cihaz dilini izler
              trailing: DropdownButton<String>(
                value: profile?.language ?? 'system',
                underline: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(14),
                items: [
                  DropdownMenuItem(
                      value: 'system', child: Text(l10n.languageSystem)),
                  const DropdownMenuItem(
                      value: 'tr', child: Text('Türkçe')),
                  const DropdownMenuItem(
                      value: 'en', child: Text('English')),
                  const DropdownMenuItem(
                      value: 'es', child: Text('Español')),
                  const DropdownMenuItem(
                      value: 'de', child: Text('Deutsch')),
                  const DropdownMenuItem(
                      value: 'fr', child: Text('Français')),
                  const DropdownMenuItem(
                      value: 'ru', child: Text('Русский')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  ref.read(localeProvider.notifier).state =
                      value == 'system' ? null : Locale(value);
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
                child: const Icon(Icons.dark_mode_rounded,
                    color: AppColors.primary, size: 22),
              ),
              title: Text(l10n.theme,
                  style: TextStyle(fontWeight: FontWeight.w600)),
              // Üçlü seçici trailing'e sığmıyordu (başlığı eziyor, dar
              // ekranda taşıyordu) — satırın altında tam genişlik
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                        value: 'system', label: Text(l10n.themeSystem)),
                    ButtonSegment(
                        value: 'light', label: Text(l10n.themeLight)),
                    ButtonSegment(value: 'dark', label: Text(l10n.themeDark)),
                  ],
                  selected: {
                    switch (profile?.themePreference ?? 'system') {
                      'dark' => 'dark',
                      'light' => 'light',
                      'system' => 'system',
                      // '' = eski kayıt: o günkü açık/koyu seçimi
                      _ => (profile?.darkModeEnabled ?? false)
                          ? 'dark'
                          : 'light',
                    }
                  },
                  onSelectionChanged: (selected) {
                    final value = selected.first;
                    ref.read(themeModeProvider.notifier).state =
                        switch (value) {
                      'dark' => ThemeMode.dark,
                      'light' => ThemeMode.light,
                      _ => ThemeMode.system,
                    };
                    ref
                        .read(userProfileProvider.notifier)
                        .saveProfile(themePreference: value);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    textStyle:
                        WidgetStateProperty.all(TextStyle(fontSize: 12)),
                  ),
                ),
              ),
            ),
            _divider(context),
            // Renk körü dostu doku modu: faz bantlarına renk + desen
            // çift kodlama (folliküler/luteal turuncu ailesi
            // deuteranopiada ayrışmıyor)
            _switchTile(context,
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
            _switchTile(context,
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
            _switchTile(context,
              Icons.notifications_rounded,
              l10n.periodReminder,
              profile?.periodReminderEnabled ?? true,
              (val) => ref
                  .read(userProfileProvider.notifier)
                  .saveProfile(periodReminderEnabled: val),
            ),
            _divider(context),
            _switchTile(context,
              Icons.egg_rounded,
              l10n.ovulationReminder,
              profile?.ovulationReminderEnabled ?? true,
              (val) => ref
                  .read(userProfileProvider.notifier)
                  .saveProfile(ovulationReminderEnabled: val),
            ),
            _divider(context),
            _switchTile(context,
              Icons.medication_rounded,
              l10n.medicationReminder,
              profile?.medicationReminderEnabled ?? false,
              (val) => ref
                  .read(userProfileProvider.notifier)
                  .saveProfile(medicationReminderEnabled: val),
            ),
            _divider(context),
            _reminderTimeTile(context, ref, profile, l10n.reminderTime),
          ]),
          const SizedBox(height: 16),

          // Security
          _sectionHeader(context, l10n.security),
          _settingsCard(context, [
            _switchTile(context,
              Icons.pin_rounded,
              l10n.pinLock,
              profile?.pinEnabled ?? false,
              (val) async {
                if (val) {
                  final success = await showPinSetupDialog(context);
                  if (success) {
                    ref.read(userProfileProvider.notifier)
                        .saveProfile(pinEnabled: true);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.pinSet),
                            backgroundColor: AppColors.success),
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
                  await ref.read(userProfileProvider.notifier).saveProfile(
                      pinEnabled: false, biometricEnabled: false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.pinRemoved),
                          backgroundColor: AppColors.success),
                    );
                  }
                }
              },
            ),
            _divider(context),
            _switchTile(context,
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
                        SnackBar(content: Text(l10n.biometricNotAvailable),
                            backgroundColor: AppColors.warning),
                      );
                    }
                    return;
                  }
                  // PIN yoksa önce PIN kurduralım (fallback için)
                  if (profile?.pinEnabled != true) {
                    if (!context.mounted) return;
                    final pinSet = await showPinSetupDialog(context);
                    if (!pinSet) return;
                    ref.read(userProfileProvider.notifier)
                        .saveProfile(pinEnabled: true);
                  }
                }
                ref.read(userProfileProvider.notifier)
                    .saveProfile(biometricEnabled: val);
              },
            ),
            if (DisguiseService.isSupported) ...[
              _divider(context),
              const _DisguiseTile(),
            ],
          ]),
          const SizedBox(height: 16),

          // Premium: durum + planlar. Erişim kararı accessProvider'da
          // (premium / deneme N gün / ücretsiz)
          _sectionHeader(context, l10n.premiumSection),
          Builder(builder: (context) {
            final access = ref.watch(accessProvider);
            final daysLeft = ref.watch(trialDaysLeftProvider);
            final statusText = switch (access) {
              AccessLevel.premium => l10n.premiumActive,
              AccessLevel.trial => l10n.trialBadge(daysLeft),
              AccessLevel.free => l10n.freeBadge,
            };
            return _settingsCard(context, [
              _infoTile(context, Icons.workspace_premium_rounded,
                  l10n.premiumSection, statusText),
              if (access == AccessLevel.free) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    l10n.freeExplain,
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.ts(context)),
                  ),
                ),
              ],
              if (access != AccessLevel.premium) ...[
                _divider(context),
                _actionTile(context, Icons.workspace_premium_rounded,
                    l10n.seePlans, AppColors.warning,
                    () => context.push('/paywall')),
              ],
              _divider(context),
              _actionTile(context, Icons.restore_page_rounded,
                  l10n.restorePurchases, AppColors.primary, () async {
                await PremiumService().restore();
              }),
            ]);
          }),
          const SizedBox(height: 16),

          // Data
          _sectionHeader(context, l10n.dataSection),
          _settingsCard(context, [
            _actionTile(context, Icons.backup_rounded, l10n.backupData,
                AppColors.primary, () async {
              try {
                final backupService = BackupService(HiveService());
                final path = await backupService.exportBackup();
                await ExportService().shareFile(path);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.errorOccurred(e.toString())),
                        backgroundColor: AppColors.error),
                  );
                }
              }
            }),
            _divider(context),
            _actionTile(context, Icons.restore_rounded, l10n.restoreData,
                AppColors.primary, () async {
              await _restoreFromBackup(context, ref, l10n);
            }),
            _divider(context),
            _actionTile(context, Icons.favorite_rounded, l10n.healthSync,
                AppColors.error, () async {
              if (!ensurePremiumAccess(context, ref)) return;
              final result = await HealthSyncService()
                  .syncPeriods(ref.read(periodRecordsProvider));
              if (!context.mounted) return;
              final (message, color) = switch (result) {
                HealthSyncResult.success => (
                    l10n.healthSyncSuccess,
                    AppColors.success
                  ),
                HealthSyncResult.permissionDenied => (
                    l10n.healthSyncDenied,
                    AppColors.warning
                  ),
                HealthSyncResult.unavailable => (
                    l10n.healthSyncUnavailable,
                    AppColors.warning
                  ),
                HealthSyncResult.error => (
                    l10n.healthSyncFailed,
                    AppColors.error
                  ),
              };
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message), backgroundColor: color),
              );
            }),
            _divider(context),
            _actionTile(context, Icons.picture_as_pdf_rounded, l10n.exportPdfReport,
                AppColors.error, () async {
              if (!ensurePremiumAccess(context, ref)) return;
              final exportService = ExportService();
              final periods = ref.read(periodRecordsProvider);
              final dailyLogs = ref.read(dailyLogProvider);
              final p = ref.read(userProfileProvider);
              if (p == null) return;
              try {
                final path = await exportService.exportPdf(
                    p, periods, dailyLogs, l10n);
                await exportService.shareFile(path);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.errorOccurred(e.toString())),
                        backgroundColor: AppColors.error),
                  );
                }
              }
            }),
            _divider(context),
            _actionTile(context,
                Icons.table_chart_rounded, l10n.exportCsvFile, AppColors.success, () async {
              if (!ensurePremiumAccess(context, ref)) return;
              final exportService = ExportService();
              final periods = ref.read(periodRecordsProvider);
              final dailyLogs = ref.read(dailyLogProvider);
              try {
                final path = await exportService.exportCsv(
                    periods, dailyLogs, l10n);
                await exportService.shareFile(path);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.errorOccurred(e.toString())),
                        backgroundColor: AppColors.error),
                  );
                }
              }
            }),
            _divider(context),
            _actionTile(context, Icons.delete_forever_rounded,
                l10n.deleteAllData, AppColors.error, () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: Text(l10n.deleteAllData),
                  content: Text(l10n.deleteAllDataConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.error),
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              );
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
                    SnackBar(content: Text(l10n.dataDeleted),
                        backgroundColor: AppColors.success),
                  );
                  context.go('/onboarding');
                }
              }
            }),
          ]),
          const SizedBox(height: 16),

          // About
          _sectionHeader(context, l10n.about),
          _settingsCard(context, [
            _infoTile(context, Icons.info_rounded, l10n.version, '1.1.0'),
            _divider(context),
            _actionTile(context, Icons.privacy_tip_rounded,
                l10n.privacyPolicy, AppColors.primary,
                () => _showPrivacyPolicy(context, l10n)),
          ]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
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
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showPrivacyPolicy(
      BuildContext context, AppLocalizations l10n) async {
    // Yasal metin arayüz dilini izlemeli; politika dosyası yalnız TR/EN
    // var — diğer diller İngilizce politikayı görür
    final lang = Localizations.localeOf(context).languageCode == 'tr'
        ? 'tr'
        : 'en';
    final text = await DefaultAssetBundle.of(context)
        .loadString('assets/legal/privacy_policy_$lang.md');
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
                  fontSize: 13, height: 1.5, color: AppColors.tp(ctx)),
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

  Future<void> _onModeChanged(
      BuildContext context, WidgetRef ref, TrackingMode mode) async {
    // Modlar (hamilelik/hap/TTC) premium kapsamı; regl modu her zaman açık
    if (mode != TrackingMode.period &&
        !ensurePremiumAccess(context, ref)) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.read(userProfileProvider);

    if (mode == TrackingMode.pregnancy) {
      // Gebelik başlangıcı = son adet tarihi; öneri olarak mevcut değer
      final picked = await showDatePicker(
        context: context,
        initialDate: profile?.pregnancyStartDate ??
            profile?.lastPeriodStart ??
            DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 300)),
        lastDate: DateTime.now(),
        helpText: l10n.pregnancyStartLabel,
      );
      if (picked == null) return; // vazgeçti — mod değişmesin
      await ref.read(userProfileProvider.notifier).saveProfile(
            trackingMode: mode,
            pregnancyStartDate: picked,
          );
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
      await ref.read(userProfileProvider.notifier).saveProfile(
            trackingMode: mode,
            pillPackStartDate: picked,
          );
      return;
    }

    // period ve ttc: ekstra tarih girdisi gerekmez
    await ref
        .read(userProfileProvider.notifier)
        .saveProfile(trackingMode: mode);
  }

  String _smartPredictionSubtitle(WidgetRef ref, AppLocalizations l10n) {
    final learned =
        CycleUtils.learnedCycleLength(ref.watch(periodRecordsProvider));
    if (learned != null) return l10n.learnedCycleLength(learned);
    return l10n.smartPredictionDesc;
  }

  Future<void> _restoreFromBackup(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    if (path == null) return;

    final BackupData data;
    try {
      final jsonString = await File(path).readAsString();
      data = BackupService(HiveService()).parseBackup(jsonString);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.invalidBackupFile),
              backgroundColor: AppColors.error),
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
        content: Text(l10n.restoreConfirmBody(data.totalRecordCount)),
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
        final logsWithMeds = HiveService()
            .getAllDailyLogs()
            .where((l) => l.medications.isNotEmpty)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        await NotificationService().rescheduleAll(
          restoredProfile,
          records: HiveService().getAllPeriodRecords(),
          medications:
              logsWithMeds.isEmpty ? const [] : logsWithMeds.first.medications,
          logs: HiveService().getAllDailyLogs(),
        );
      } catch (_) {
        // Bildirim kurulamasa da geri yükleme başarılı sayılır
      }
      await WidgetService.update(
          restoredProfile, HiveService().getAllPeriodRecords());
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.backupRestored),
            backgroundColor: AppColors.success),
      );
    }
  }

  Widget _sectionHeader(BuildContext context, String title) {
    // Bölüm başlığı dili: 13/w700 ikincil renk — kart başlıklarından
    // (18/bold birincil) net biçimde ayrışır, ListView ritmini bozmaz
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(title,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ts(context))),
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

  Widget _infoTile(BuildContext context, IconData icon, String title, String value) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withValues(alpha: 0.25), AppColors.primary.withValues(alpha: 0.1)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      // Uzun değerler ("Deneme: 27 gün kaldı", uzun isim) başlığı ezmesin
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 170),
        child: Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 14, color: AppColors.ts(context))),
      ),
    );
  }

  /// Takip modu kartı (2×2 ızgaranın hücresi): ikon + etiket, seçili
  /// hal tek vurgu ailesinin gradyanını giyer
  Widget _modeCard(BuildContext context, WidgetRef ref, UserProfile? profile,
      TrackingMode mode, IconData icon, String label) {
    final selected =
        (profile?.trackingMode ?? TrackingMode.period) == mode;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onModeChanged(context, ref, mode),
        child: ExcludeSemantics(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryStrong,
                        AppColors.primaryDeep,
                      ],
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
                Icon(icon,
                    size: 24,
                    color: selected
                        ? Colors.white
                        : AppColors.primaryStrong),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color:
                        selected ? Colors.white : AppColors.tp(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _switchTile(BuildContext context,
      IconData icon, String title, bool value, ValueChanged<bool> onChanged,
      {String? subtitle}) {
    // İkon durumu taşır: özellik kapalıyken rozet soluklaşır — satırın
    // açık/kapalı hali switch'e bakmadan, ikondan okunur
    final iconColor = value ? AppColors.primary : AppColors.ts(context);
    return ListTile(
      leading: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: value
                ? [
                    AppColors.primary.withValues(alpha: 0.25),
                    AppColors.primary.withValues(alpha: 0.1)
                  ]
                : [
                    AppColors.ts(context).withValues(alpha: 0.12),
                    AppColors.ts(context).withValues(alpha: 0.05)
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(fontSize: 12))
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _actionTile(BuildContext context,
      IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.1)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.ts(context)),
    );
  }

  Widget _reminderTimeTile(
      BuildContext context, WidgetRef ref, UserProfile? profile, String title) {
    final hour = profile?.reminderHour ?? 9;
    final minute = profile?.reminderMinute ?? 0;
    final timeStr =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return ListTile(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hour, minute: minute),
        );
        if (picked != null) {
          ref.read(userProfileProvider.notifier).saveProfile(
                reminderHour: picked.hour,
                reminderMinute: picked.minute,
              );
        }
      },
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withValues(alpha: 0.25), AppColors.primary.withValues(alpha: 0.1)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 22),
      ),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: Text(timeStr,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.isDark(context)
                  ? AppColors.primaryLight
                  : AppColors.primaryStrong)),
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
        child: const Icon(Icons.visibility_off_rounded,
            color: AppColors.primary, size: 22),
      ),
      title: Text(l10n.disguiseTitle,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(l10n.disguiseDesc, style: TextStyle(fontSize: 11)),
      trailing: Switch(
        value: _enabled ?? false,
        activeColor: AppColors.primary,
        onChanged: _enabled == null
            ? null
            : (value) async {
                // Gizli mod premium kapsamı; KAPATMAK her zaman serbest
                // (aboneliği biten kullanıcı kılıkta mahsur kalmamalı)
                if (value && !ensurePremiumAccess(context, ref)) return;
                final ok = await DisguiseService.setDisguise(value);
                if (!ok) return;
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
                    final logsWithMeds = HiveService()
                        .getAllDailyLogs()
                        .where((l) => l.medications.isNotEmpty)
                        .toList()
                      ..sort((a, b) => b.date.compareTo(a.date));
                    await NotificationService().rescheduleAll(
                      profile,
                      records: HiveService().getAllPeriodRecords(),
                      medications: logsWithMeds.isEmpty
                          ? const []
                          : logsWithMeds.first.medications,
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
