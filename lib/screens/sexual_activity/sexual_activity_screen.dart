import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../models/enums.dart';
import '../../models/period_record.dart';
import '../../providers/providers.dart';

class SexualActivityScreen extends ConsumerStatefulWidget {
  const SexualActivityScreen({super.key});

  @override
  ConsumerState<SexualActivityScreen> createState() =>
      _SexualActivityScreenState();
}

class _SexualActivityScreenState extends ConsumerState<SexualActivityScreen> {
  ProtectionMethod _protection = ProtectionMethod.none;
  bool _orgasm = false;
  final _noteController = TextEditingController();

  Map<ProtectionMethod, String> _protectionLabels(AppLocalizations l10n) => {
    ProtectionMethod.condom: l10n.condom,
    ProtectionMethod.pill: l10n.pill,
    ProtectionMethod.iud: l10n.spiral,
    ProtectionMethod.none: l10n.none,
    ProtectionMethod.other: l10n.other,
  };

  @override
  void initState() {
    super.initState();
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(DateTime.now());
    if (log?.sexualActivity != null) {
      _protection = log!.sexualActivity!.protectionMethod;
      _orgasm = log.sexualActivity!.orgasm;
      _noteController.text = log.sexualActivity!.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(l10n.sexualActivity,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.tp(context))),
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.tp(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.protectionMethod,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: AppColors.tp(context)))
                      .animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 16),
                  _buildProtectionChips(l10n),
                  const SizedBox(height: 28),
                  _buildOrgasmToggle(l10n)
                      .animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 28),
                  _buildNoteField(l10n)
                      .animate().fadeIn(delay: 400.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
          _buildSaveButton(l10n),
        ],
      ),
    );
  }

  Widget _buildProtectionChips(AppLocalizations l10n) {
    final labels = _protectionLabels(l10n);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ProtectionMethod.values.asMap().entries.map((entry) {
        final i = entry.key;
        final method = entry.value;
        final isSelected = _protection == method;
        return ChoiceChip(
          label: Text(labels[method]!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.tp(context),
              )),
          selected: isSelected,
          selectedColor: AppColors.moodRomantic,
          backgroundColor: AppColors.sf(context),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          onSelected: (_) => setState(() => _protection = method),
        ).animate().fadeIn(delay: (i * 60).ms, duration: 300.ms);
      }).toList(),
    );
  }

  Widget _buildOrgasmToggle(AppLocalizations l10n) {
    return GlassCard(
      borderRadius: 22,
      blur: 8,
      opacity: 0.15,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.orgasm,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.tp(context))),
          Switch.adaptive(
            value: _orgasm,
            activeColor: AppColors.moodRomantic,
            onChanged: (v) => setState(() => _orgasm = v),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField(AppLocalizations l10n) {
    return GlassCard(
      borderRadius: 22,
      blur: 8,
      opacity: 0.15,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.noteOptional,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.tp(context))),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: TextStyle(color: AppColors.tp(context)),
            decoration: InputDecoration(
              hintText: l10n.addNoteHint,
              hintStyle: TextStyle(color: AppColors.ts(context)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.dv(context))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.moodRomantic, width: 2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.moodRomantic,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(l10n.save,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final entry = SexualActivityEntry(
      protectionMethod: _protection,
      orgasm: _orgasm,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );
    await ref
        .read(dailyLogProvider.notifier)
        .updateSexualActivity(DateTime.now(), entry);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedGeneric),
            backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    }
  }
}
