import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../models/user_profile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
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
    final locale = ref.watch(localeProvider);
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
                AppColors.secondary, () => context.push('/profile-edit')),
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
                  SegmentedButton<TrackingMode>(
                    // 4 segment + ikon dar ekranda taşıyor — yalnız etiket
                    segments: [
                      ButtonSegment(
                          value: TrackingMode.period,
                          label: Text(l10n.modePeriod)),
                      ButtonSegment(
                          value: TrackingMode.pregnancy,
                          label: Text(l10n.modePregnancy)),
                      ButtonSegment(
                          value: TrackingMode.pill,
                          label: Text(l10n.modePill)),
                      ButtonSegment(
                          value: TrackingMode.ttc,
                          label: Text(l10n.modeTtc)),
                    ],
                    selected: {profile?.trackingMode ?? TrackingMode.period},
                    onSelectionChanged: (selected) =>
                        _onModeChanged(context, ref, selected.first),
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      textStyle:
                          WidgetStateProperty.all(TextStyle(fontSize: 12)),
                    ),
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
                    colors: [AppColors.secondary.withValues(alpha: 0.25), AppColors.secondary.withValues(alpha: 0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.language_rounded,
                    color: AppColors.secondary, size: 22),
              ),
              title: Text(l10n.language,
                  style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'tr', label: Text('TR')),
                  ButtonSegment(value: 'en', label: Text('EN')),
                ],
                selected: {locale.languageCode},
                onSelectionChanged: (selected) {
                  ref.read(localeProvider.notifier).state =
                      Locale(selected.first);
                  ref.read(userProfileProvider.notifier)
                      .saveProfile(language: selected.first);
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStateProperty.all(
                      TextStyle(fontSize: 13)),
                ),
              ),
            ),
            _divider(context),
            _switchTile(
              Icons.dark_mode_rounded,
              l10n.darkTheme,
              ref.watch(darkModeProvider),
              (val) {
                ref.read(darkModeProvider.notifier).state = val;
                ref.read(userProfileProvider.notifier)
                    .saveProfile(darkModeEnabled: val);
              },
            ),
            _divider(context),
            _switchTile(
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
              Icons.notifications_rounded,
              l10n.periodReminder,
              profile?.periodReminderEnabled ?? true,
              (val) => ref
                  .read(userProfileProvider.notifier)
                  .saveProfile(periodReminderEnabled: val),
            ),
            _divider(context),
            _switchTile(
              Icons.egg_rounded,
              l10n.ovulationReminder,
              profile?.ovulationReminderEnabled ?? true,
              (val) => ref
                  .read(userProfileProvider.notifier)
                  .saveProfile(ovulationReminderEnabled: val),
            ),
            _divider(context),
            _switchTile(
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
            _switchTile(
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
                  const storage = FlutterSecureStorage();
                  await storage.delete(key: 'app_pin');
                  ref.read(userProfileProvider.notifier)
                      .saveProfile(pinEnabled: false);
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
            _switchTile(
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

          // Premium
          _sectionHeader(context, l10n.premiumSection),
          ValueListenableBuilder<bool>(
            valueListenable: PremiumService().isPremiumNotifier,
            builder: (context, isPremium, _) {
              if (isPremium) {
                return _settingsCard(context, [
                  _infoTile(context, Icons.workspace_premium_rounded,
                      l10n.premiumSection, l10n.premiumActive),
                ]);
              }
              final service = PremiumService();
              final priceSuffix = service.product != null
                  ? ' (${service.product!.price})'
                  : '';
              return _settingsCard(context, [
                _actionTile(context, Icons.workspace_premium_rounded,
                    '${l10n.removeAds}$priceSuffix', AppColors.warning,
                    () async {
                  final started = await service.buy();
                  if (!started && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l10n.storeUnavailable),
                          backgroundColor: AppColors.warning),
                    );
                  }
                }),
                _divider(context),
                _actionTile(context, Icons.restore_page_rounded,
                    l10n.restorePurchases, AppColors.secondary, () async {
                  await service.restore();
                }),
              ]);
            },
          ),
          const SizedBox(height: 16),

          // Data
          _sectionHeader(context, l10n.dataSection),
          _settingsCard(context, [
            _actionTile(context, Icons.backup_rounded, l10n.backupData,
                AppColors.secondary, () async {
              try {
                final backupService = BackupService(HiveService());
                final path = await backupService.exportBackup();
                await ExportService().shareFile(path);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backup error: $e'),
                        backgroundColor: AppColors.error),
                  );
                }
              }
            }),
            _divider(context),
            _actionTile(context, Icons.restore_rounded, l10n.restoreData,
                AppColors.secondary, () async {
              await _restoreFromBackup(context, ref, l10n);
            }),
            _divider(context),
            _actionTile(context, Icons.favorite_rounded, l10n.healthSync,
                AppColors.error, () async {
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
              final exportService = ExportService();
              final periods = ref.read(periodRecordsProvider);
              final dailyLogs = ref.read(dailyLogProvider);
              final p = ref.read(userProfileProvider);
              if (p == null) return;
              try {
                final path = await exportService.exportPdf(
                    p, periods, dailyLogs, locale.languageCode);
                await exportService.shareFile(path);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PDF export error: $e'),
                        backgroundColor: AppColors.error),
                  );
                }
              }
            }),
            _divider(context),
            _actionTile(context,
                Icons.table_chart_rounded, l10n.exportCsvFile, AppColors.success, () async {
              final exportService = ExportService();
              final periods = ref.read(periodRecordsProvider);
              final dailyLogs = ref.read(dailyLogProvider);
              try {
                final path = await exportService.exportCsv(
                    periods, dailyLogs, locale.languageCode);
                await exportService.shareFile(path);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('CSV export error: $e'),
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
            _infoTile(context, Icons.info_rounded, l10n.version, '1.0.0'),
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

  Future<void> _onModeChanged(
      BuildContext context, WidgetRef ref, TrackingMode mode) async {
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
        await NotificationService().rescheduleAll(
          restoredProfile,
          records: HiveService().getAllPeriodRecords(),
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
      trailing: Text(value,
          style: TextStyle(
              fontSize: 14, color: AppColors.ts(context))),
    );
  }

  Widget _switchTile(
      IconData icon, String title, bool value, ValueChanged<bool> onChanged,
      {String? subtitle}) {
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
              color: AppColors.primary)),
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
class _DisguiseTile extends StatefulWidget {
  const _DisguiseTile();

  @override
  State<_DisguiseTile> createState() => _DisguiseTileState();
}

class _DisguiseTileState extends State<_DisguiseTile> {
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
                final ok = await DisguiseService.setDisguise(value);
                if (!ok) return;
                // Widget'ı yeni duruma göre hemen yenile: gizliyken nötr
                // içerik, kapatınca gerçek döngü verisi
                await WidgetService.update(
                  HiveService().getUserProfile(),
                  HiveService().getAllPeriodRecords(),
                );
                if (mounted) setState(() => _enabled = value);
              },
      ),
    );
  }
}
