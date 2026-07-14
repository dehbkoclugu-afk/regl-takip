import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/cycle_utils.dart';
import '../../providers/providers.dart';
import '../../core/utils/motion.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  DateTime? _lastPeriodDate;
  double _cycleLength = 28;
  double _periodLength = 5;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    if (profile != null) {
      _nameController.text = profile.name;
      _birthDate = profile.birthDate;
      _lastPeriodDate = profile.lastPeriodStart;
      _cycleLength = profile.averageCycleLength.toDouble();
      _periodLength = profile.averagePeriodLength.toDouble();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isBirthDate}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate
          ? (_birthDate ?? DateTime(now.year - 20, now.month, now.day))
          : (_lastPeriodDate ?? now),
      firstDate: isBirthDate ? DateTime(1950) : DateTime(now.year - 1),
      lastDate: now,
      locale: Localizations.localeOf(context),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: AppColors.isDark(context)
              ? ColorScheme.dark(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: AppColors.sf(context),
                  onSurface: AppColors.tp(context),
                )
              : ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
          dialogTheme: const DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _birthDate = picked;
        } else {
          _lastPeriodDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final periodLength = _periodLength.round();
      final lastPeriod = _lastPeriodDate;

      // Takvim ve istatistikler kayıtlara bakar: profildeki tarihi
      // değiştirmek yetmez, o güne ait bir regl kaydı da olmalı
      if (lastPeriod != null) {
        final records = ref.read(periodRecordsProvider);
        final alreadyRecorded = records.any((r) =>
            r.startDate.year == lastPeriod.year &&
            r.startDate.month == lastPeriod.month &&
            r.startDate.day == lastPeriod.day);
        if (!alreadyRecorded) {
          final record = await ref
              .read(periodRecordsProvider.notifier)
              .startPeriod(lastPeriod);
          final end = CycleUtils.completedPeriodEnd(
              lastPeriod, periodLength, DateTime.now());
          if (end != null) {
            await ref
                .read(periodRecordsProvider.notifier)
                .endPeriod(record.id, end);
          }
        }
      }

      await ref.read(userProfileProvider.notifier).saveProfile(
            name: _nameController.text.trim(),
            birthDate: _birthDate,
            lastPeriodStart: _lastPeriodDate,
            averageCycleLength: _cycleLength.round(),
            averagePeriodLength: periodLength,
          );

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileSaved),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateFormatter = DateFormat('dd MMMM yyyy', locale);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(l10n.editProfile,
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
                children: [
                  // Name
                  _buildCard(
                    icon: Icons.person_rounded,
                    title: l10n.name,
                    child: TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: l10n.yourName,
                        hintStyle:
                            TextStyle(color: AppColors.ts(context)),
                        filled: true,
                        fillColor: AppColors.isDark(context) ? AppColors.cardDark : Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ).animateSafe(context).fadeIn(duration: 400.ms).slideY(begin: 0.05),

                  const SizedBox(height: 12),

                  // Birth date
                  _buildCard(
                    icon: Icons.cake_rounded,
                    title: l10n.birthDate,
                    child: _buildDateTile(
                      value: _birthDate != null
                          ? dateFormatter.format(_birthDate!)
                          : l10n.selectDateHint,
                      hasValue: _birthDate != null,
                      onTap: () => _pickDate(isBirthDate: true),
                    ),
                  ).animateSafe(context).fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05),

                  const SizedBox(height: 12),

                  // Last period date
                  _buildCard(
                    icon: Icons.water_drop_rounded,
                    title: l10n.lastPeriodDate,
                    child: _buildDateTile(
                      value: _lastPeriodDate != null
                          ? dateFormatter.format(_lastPeriodDate!)
                          : l10n.selectDateHint,
                      hasValue: _lastPeriodDate != null,
                      onTap: () => _pickDate(isBirthDate: false),
                    ),
                  ).animateSafe(context).fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.05),

                  const SizedBox(height: 12),

                  // Cycle length
                  _buildCard(
                    icon: Icons.loop_rounded,
                    title: l10n.averageCycleLength,
                    child: _buildSlider(
                      value: _cycleLength,
                      min: 18,
                      max: 45,
                      divisions: 27,
                      displayText: l10n.nDays(_cycleLength.round()),
                      onChanged: (v) => setState(() => _cycleLength = v),
                    ),
                  ).animateSafe(context).fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.05),

                  const SizedBox(height: 12),

                  // Period length
                  _buildCard(
                    icon: Icons.timelapse_rounded,
                    title: l10n.averagePeriodLength,
                    child: _buildSlider(
                      value: _periodLength,
                      min: 2,
                      max: 10,
                      divisions: 8,
                      displayText: l10n.nDays(_periodLength.round()),
                      onChanged: (v) => setState(() => _periodLength = v),
                    ),
                  ).animateSafe(context).fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.05),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildSaveButton(l10n),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sf(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tp(context))),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDateTile({
    required String value,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      value: value,
      child: Material(
        color: AppColors.isDark(context)
            ? AppColors.cardDark
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                color: hasValue ? AppColors.primary : AppColors.ts(context),
                size: 20),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: hasValue ? AppColors.tp(context) : AppColors.ts(context),
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayText,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Text(
          displayText,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primaryLight.withValues(alpha: 0.25),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.15),
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: displayText,
            semanticFormatterCallback: (v) =>
                AppLocalizations.of(context)!.nDays(v.round()),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white))
              : Text(l10n.save,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
