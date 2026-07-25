import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/access.dart';
import '../../core/utils/medication_plan.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/tracker_scaffold.dart';
import '../../models/period_record.dart';
import '../../providers/providers.dart';
import '../../core/utils/motion.dart';

class MedicationTrackingScreen extends ConsumerStatefulWidget {
  const MedicationTrackingScreen({super.key});

  @override
  ConsumerState<MedicationTrackingScreen> createState() =>
      _MedicationTrackingScreenState();
}

class _MedicationTrackingScreenState
    extends ConsumerState<MedicationTrackingScreen> {
  List<MedicationEntry> _medications = [];
  List<MedicationEntry> _existingDailyMedications = [];

  @override
  void initState() {
    super.initState();
    final plan = ref.read(userProfileProvider)?.medicationPlan ?? const [];
    final log = ref
        .read(dailyLogProvider.notifier)
        .getDailyLog(ref.read(selectedDateProvider));
    _existingDailyMedications = List.from(log?.medications ?? const []);
    _medications = medicationEntriesForDay(
      plan,
      _existingDailyMedications,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Bu ekran canlı kaydeder (_saveAll her değişiklikte) — dirty yok
    return TrackerScaffold(
      title: l10n.medicationTracking,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        tooltip: l10n.addMedication,
        backgroundColor: AppColors.medication,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 17,
                  color: AppColors.ts(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.medicationPlanHint,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.ts(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _medications.isEmpty ? _buildEmpty(l10n) : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: EmptyState(
        icon: Icons.medication_rounded,
        title: l10n.noMedicationsYet,
        message: l10n.tapToAdd,
        accent: AppColors.medication,
      ),
    ).animateSafe(context).fadeIn(duration: 400.ms);
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final med = _medications[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Dismissible(
            // Anahtar index'e bağlıydı: bir ilaç silinince altındakilerin
            // anahtarı kayıyor ve yanlış satır animasyonla siliniyordu
            key: ObjectKey(med),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async =>
                ensureTrackingWriteAccess(context, ref),
            onDismissed: (_) {
              setState(() => _medications.remove(med));
              _savePlan();
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.delete_rounded, color: Colors.white),
            ),
            child: GlassCard(
              borderRadius: 20,
              blur: 0,
              opacity: 0.15,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Semantics(
                    label: med.name,
                    toggled: med.taken,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        if (!ensureTrackingWriteAccess(context, ref)) return;
                        setState(() => med.taken = !med.taken);
                        _saveDailyStatus();
                      },
                      // 28 px kutu tek başına dokunma hedefiydi: 48 px alan
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: AnimatedContainer(
                            duration: context.motionDuration(
                                const Duration(milliseconds: 200)),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: med.taken
                                  ? AppColors.medication
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: med.taken
                                    ? AppColors.medication
                                    : AppColors.ts(context),
                                width: 2,
                              ),
                            ),
                            child: med.taken
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 18)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(med.name,
                            style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700,
                              color: AppColors.tp(context),
                              decoration: med.taken
                                  ? TextDecoration.lineThrough
                                  : null,
                            )),
                        if (med.dose.isNotEmpty)
                          Text(med.dose,
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.ts(context))),
                      ],
                    ),
                  ),
                  if (med.reminderTime != null)
                    Text(med.reminderTime!,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: AppColors.categoryText(context, AppColors.medication))),
                ],
              ),
            ),
          ),
        ).animateSafe(context).fadeIn(delay: (index * 60).ms, duration: 300.ms)
            .slideX(begin: 0.1, end: 0, delay: (index * 60).ms, duration: 300.ms);
      },
    );
  }

  void _showAddSheet() {
    if (!ensureTrackingWriteAccess(context, ref)) return;
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.ts(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(l10n.addMedication,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold,
                      color: AppColors.tp(context))),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: AppColors.tp(context)),
                decoration: InputDecoration(
                  labelText: l10n.medicationName,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.medication, width: 2)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: doseCtrl,
                style: TextStyle(color: AppColors.tp(context)),
                decoration: InputDecoration(
                  labelText: l10n.dose,
                  hintText: l10n.doseHint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.medication, width: 2)),
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                button: true,
                label: l10n.reminderTime,
                value: selectedTime.format(ctx),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final picked = await showTimePicker(
                        context: ctx, initialTime: selectedTime);
                    if (picked != null) {
                      setSheetState(() => selectedTime = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.dv(context)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            color: AppColors.medication),
                        const SizedBox(width: 12),
                        Text(selectedTime.format(ctx),
                            style: TextStyle(
                                fontSize: 16, color: AppColors.tp(context))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final timeStr =
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                    final medication = MedicationEntry(
                      name: nameCtrl.text.trim(),
                      dose: doseCtrl.text.trim(),
                      reminderTime: timeStr,
                    );
                    if (_medications.any(
                      (existing) =>
                          medicationIdentity(existing) ==
                          medicationIdentity(medication),
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.medicationAlreadyInPlan),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _medications.add(medication);
                    });
                    _savePlan();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.medication,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.add,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      // Sheet kapanınca controller'lar serbest bırakılmalıydı — her açılışta
      // yeni bir çift sızıyordu
      nameCtrl.dispose();
      doseCtrl.dispose();
    });
  }

  Future<void> _savePlan() async {
    if (!ensureTrackingWriteAccess(context, ref)) return;
    await ref.read(userProfileProvider.notifier).saveProfile(
          medicationPlan:
              _medications.map(medicationDefinition).toList(),
          medicationPlanMigrated: true,
        );
  }

  Future<void> _saveDailyStatus() async {
    if (!ensureTrackingWriteAccess(context, ref)) return;
    final dailyRecord = medicationDailyRecord(
      _medications,
      _existingDailyMedications,
    );
    await ref.read(dailyLogProvider.notifier).updateMedications(
          ref.read(selectedDateProvider),
          dailyRecord,
        );
    _existingDailyMedications = dailyRecord;
    notifyTrackingRecordSaved();
  }
}
