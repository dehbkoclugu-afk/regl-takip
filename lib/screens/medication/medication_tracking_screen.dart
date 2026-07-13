import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
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

  @override
  void initState() {
    super.initState();
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(ref.read(selectedDateProvider));
    if (log != null && log.medications.isNotEmpty) {
      _medications = List.from(log.medications);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(l10n.medicationTracking,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.tp(context))),
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.tp(context)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: AppColors.medication,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _medications.isEmpty ? _buildEmpty(l10n) : _buildList(),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.medication_rounded, size: 64,
              color: AppColors.ts(context).withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(l10n.noMedicationsYet,
              style: TextStyle(
                  fontSize: 16, color: AppColors.ts(context))),
          const SizedBox(height: 8),
          Text(l10n.tapToAdd,
              style: TextStyle(
                  fontSize: 13, color: AppColors.ts(context))),
        ],
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
            key: Key('med_${index}_${med.name}'),
            direction: DismissDirection.endToStart,
            onDismissed: (_) {
              setState(() => _medications.removeAt(index));
              _saveAll();
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
                  GestureDetector(
                    onTap: () {
                      setState(() => med.taken = !med.taken);
                      _saveAll();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: med.taken ? AppColors.medication : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: med.taken
                              ? AppColors.medication
                              : AppColors.ts(context),
                          width: 2,
                        ),
                      ),
                      child: med.taken
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
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
                            color: AppColors.medication)),
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
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                      context: ctx, initialTime: selectedTime);
                  if (picked != null) setSheetState(() => selectedTime = picked);
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final timeStr =
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                    setState(() {
                      _medications.add(MedicationEntry(
                        name: nameCtrl.text.trim(),
                        dose: doseCtrl.text.trim(),
                        reminderTime: timeStr,
                      ));
                    });
                    _saveAll();
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
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAll() async {
    await ref.read(dailyLogProvider.notifier).updateMedications(
        ref.read(selectedDateProvider), _medications);
  }
}
