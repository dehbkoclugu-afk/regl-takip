import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/enum_labels.dart';
import '../../models/enums.dart';
import '../../models/period_record.dart';
import '../../providers/providers.dart';

/// Günlük kaydın %90'ı için tek sheet: akış + semptom + mood.
/// Detay isteyen "Tüm kayıt türleri" ile log ekranına iner.
/// Mevcut log prefill edilir; kaydet üçünü birden yazar.
Future<void> showQuickLogSheet(
    BuildContext context, WidgetRef ref, DateTime date) {
  // Sheet açılırken tarih provider'a yazılır: "tüm kayıt türleri"
  // yolundan gidilen tracker'lar da aynı güne yazar
  ref.read(selectedDateProvider.notifier).state = date;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _QuickLogSheet(date: date),
  );
}

class _QuickLogSheet extends ConsumerStatefulWidget {
  final DateTime date;
  const _QuickLogSheet({required this.date});

  @override
  ConsumerState<_QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends ConsumerState<_QuickLogSheet> {
  FlowIntensity? _flow;
  MoodType? _mood;
  final Map<SymptomType, int> _symptoms = {};

  /// Sheet'te gösterilen en sık semptomlar; tamamı semptom ekranında
  static const _commonSymptoms = [
    SymptomType.cramp,
    SymptomType.headache,
    SymptomType.bloating,
    SymptomType.fatigue,
    SymptomType.backPain,
    SymptomType.breastTenderness,
    SymptomType.acne,
    SymptomType.stress,
  ];

  @override
  void initState() {
    super.initState();
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(widget.date);
    if (log != null) {
      _flow = log.flowIntensity;
      _mood = log.mood?.type;
      for (final s in log.symptoms) {
        _symptoms[s.type] = s.severity;
      }
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(dailyLogProvider.notifier);

    if (_flow != null) {
      await notifier.updateFlow(widget.date, flowIntensity: _flow);
    }
    await notifier.updateMood(
        widget.date, _mood != null ? MoodEntry(type: _mood!) : null);
    await notifier.updateSymptoms(
      widget.date,
      _symptoms.entries
          .map((e) => SymptomEntry(type: e.key, severity: e.value))
          .toList(),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(l10n.savedGeneric),
          backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateStr =
        DateFormat('d MMMM, EEEE', locale).format(widget.date);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.sf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.dv(context), width: 1),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dv(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.quickLog,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.tp(context))),
              Text(dateStr,
                  style: TextStyle(
                      fontSize: 13, color: AppColors.ts(context))),
              const SizedBox(height: 20),

              // Akış şiddeti
              _sectionLabel(l10n.flow),
              const SizedBox(height: 8),
              Row(
                children: [
                  _flowOption(FlowIntensity.light, l10n.light, 1),
                  _flowOption(FlowIntensity.normal, l10n.medium, 2),
                  _flowOption(FlowIntensity.heavy, l10n.heavy, 3),
                  _flowOption(FlowIntensity.veryHeavy, l10n.veryHeavy, 4),
                ],
              ),
              const SizedBox(height: 20),

              // Mood
              _sectionLabel(l10n.mood),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: MoodType.values.map((m) {
                    final selected = _mood == m;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _chip(
                        label: EnumLabels.mood(m, l10n),
                        selected: selected,
                        onTap: () =>
                            setState(() => _mood = selected ? null : m),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Semptomlar
              _sectionLabel(l10n.symptoms),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _commonSymptoms.map((s) {
                  final selected = _symptoms.containsKey(s);
                  return _chip(
                    label: EnumLabels.symptom(s, l10n),
                    selected: selected,
                    onTap: () => setState(() {
                      if (selected) {
                        _symptoms.remove(s);
                      } else {
                        _symptoms[s] = 2;
                      }
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(l10n.save),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/log');
                  },
                  child: Text(l10n.allTrackers,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.ts(context))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.ts(context)));
  }

  Widget _flowOption(FlowIntensity intensity, String label, int drops) {
    final selected = _flow == intensity;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          onTap: () =>
              setState(() => _flow = selected ? null : intensity),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.menstrual.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? AppColors.primaryStrong
                    : AppColors.dv(context),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    drops,
                    (_) => Icon(Icons.water_drop_rounded,
                        size: 10,
                        color: selected
                            ? AppColors.primaryStrong
                            : AppColors.ts(context)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.primaryStrong
                            : AppColors.ts(context))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryStrong.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primaryStrong
                  : AppColors.dv(context),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.primaryStrong
                      : AppColors.tp(context))),
        ),
      ),
    );
  }
}
