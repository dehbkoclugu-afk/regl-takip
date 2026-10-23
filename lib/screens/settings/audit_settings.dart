import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/ad_service.dart';
import '../../services/usage_metrics.dart';

class AuditSettings extends ConsumerStatefulWidget {
  const AuditSettings({super.key});
  @override
  ConsumerState<AuditSettings> createState() => _AuditSettingsState();
}

class _AuditSettingsState extends ConsumerState<AuditSettings> {
  bool? _metrics;
  bool _privacy = false;
  @override
  void initState() {
    super.initState();
    UsageMetrics.enabled().then((v) {
      if (mounted) setState(() => _metrics = v);
    });
    AdService.privacyOptionsRequired().then((v) {
      if (mounted) setState(() => _privacy = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(userProfileProvider);
    return Column(children: [
      if (_privacy)
        ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.adPrivacyOptions),
            onTap: () async {
              await AdService.showPrivacyOptions();
              if (!mounted) return;
              setState(() {});
            }),
      if (profile != null)
        ListTile(
            leading: const Icon(Icons.medication_outlined),
            title: Text(l10n.pillSchedule),
            subtitle:
                Text('${profile.pillActiveDays}+${profile.pillBreakDays}'),
            onTap: () async {
              final active =
                  TextEditingController(text: '${profile.pillActiveDays}');
              final rest =
                  TextEditingController(text: '${profile.pillBreakDays}');
              final result = await showDialog<(int, int)>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                          title: Text(l10n.pillSchedule),
                          content: SingleChildScrollView(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                Text(l10n.pillPrescriptionNote),
                                TextField(
                                    controller: active,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        labelText: l10n.pillActiveDaysTitle)),
                                TextField(
                                    controller: rest,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        labelText: l10n.pillBreakDaysTitle)),
                              ])),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(l10n.cancel)),
                            FilledButton(
                                onPressed: () {
                                  final a = int.tryParse(active.text),
                                      b = int.tryParse(rest.text);
                                  if (a != null &&
                                      b != null &&
                                      a >= 1 &&
                                      a <= 120 &&
                                      b >= 0 &&
                                      b <= 14) {
                                    Navigator.pop(ctx, (a, b));
                                  }
                                },
                                child: Text(l10n.save))
                          ]));
              active.dispose();
              rest.dispose();
              if (result != null) {
                await ref.read(userProfileProvider.notifier).saveProfile(
                    pillActiveDays: result.$1, pillBreakDays: result.$2);
              }
            }),
      if (_metrics != null)
        SwitchListTile(
            value: _metrics!,
            title: Text(l10n.analyticsChoice),
            subtitle: Text(l10n.analyticsChoiceDescription),
            onChanged: (v) async {
              await UsageMetrics.setEnabled(v);
              if (mounted) setState(() => _metrics = v);
            }),
    ]);
  }
}
