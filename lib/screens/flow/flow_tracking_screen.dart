import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/enums.dart';
import '../../providers/providers.dart';

class FlowTrackingScreen extends ConsumerStatefulWidget {
  const FlowTrackingScreen({super.key});

  @override
  ConsumerState<FlowTrackingScreen> createState() => _FlowTrackingScreenState();
}

class _FlowTrackingScreenState extends ConsumerState<FlowTrackingScreen> {
  FlowIntensity? _intensity;
  FlowColor? _colorSelection;
  bool _hasClots = false;
  int _padChanges = 0;

  @override
  void initState() {
    super.initState();
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(DateTime.now());
    if (log != null) {
      _intensity = log.flowIntensity;
      _colorSelection = log.flowColor;
      _hasClots = log.hasClots ?? false;
      _padChanges = log.padChangeCount ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(l10n.flowTracking,
            style: GoogleFonts.nunito(
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
                  Text(l10n.flowIntensity,
                      style: GoogleFonts.nunito(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: AppColors.tp(context)))
                      .animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 16),
                  _buildIntensityRow(l10n),
                  const SizedBox(height: 28),
                  Text(l10n.color,
                      style: GoogleFonts.nunito(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: AppColors.tp(context)))
                      .animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  const SizedBox(height: 16),
                  _buildColorRow(l10n),
                  const SizedBox(height: 28),
                  _buildClotsToggle(l10n)
                      .animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 28),
                  _buildPadCounter(l10n)
                      .animate().fadeIn(delay: 300.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
          _buildSaveButton(l10n),
        ],
      ),
    );
  }

  Widget _buildIntensityRow(AppLocalizations l10n) {
    final items = [
      (FlowIntensity.light, l10n.light, 1, AppColors.flowLight),
      (FlowIntensity.normal, l10n.medium, 2, AppColors.flowNormal),
      (FlowIntensity.heavy, l10n.heavy, 3, AppColors.flowHeavy),
      (FlowIntensity.veryHeavy, l10n.veryHeavy, 4, AppColors.flowVeryHeavy),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final isSelected = _intensity == item.$1;
        return GestureDetector(
          onTap: () => setState(() =>
              _intensity = _intensity == item.$1 ? null : item.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? item.$4.withValues(alpha: 0.2)
                  : AppColors.sf(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? item.$4 : AppColors.dv(context),
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(item.$3,
                      (_) => Icon(Icons.water_drop, color: item.$4, size: 16)),
                ),
                const SizedBox(height: 6),
                Text(item.$2,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? item.$4 : AppColors.ts(context),
                    )),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (i * 60).ms, duration: 300.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1),
                delay: (i * 60).ms, duration: 300.ms);
      }).toList(),
    );
  }

  Widget _buildColorRow(AppLocalizations l10n) {
    final colors = [
      (FlowColor.lightRed, l10n.lightRed, const Color(0xFFFF8A80)),
      (FlowColor.red, l10n.red, const Color(0xFFEF5350)),
      (FlowColor.darkRed, l10n.darkRed, const Color(0xFFB71C1C)),
      (FlowColor.brown, l10n.brown, const Color(0xFF795548)),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: colors.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final isSelected = _colorSelection == item.$1;
        return GestureDetector(
          onTap: () => setState(() =>
              _colorSelection = _colorSelection == item.$1 ? null : item.$1),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.$3,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.tp(context) : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: item.$3.withValues(alpha: 0.4), blurRadius: 8)]
                      : [],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 22)
                    : null,
              ),
              const SizedBox(height: 6),
              Text(item.$2,
                  style: GoogleFonts.nunito(
                      fontSize: 11, color: AppColors.ts(context)),
                  textAlign: TextAlign.center),
            ],
          ),
        ).animate().fadeIn(delay: (100 + i * 60).ms, duration: 300.ms);
      }).toList(),
    );
  }

  Widget _buildClotsToggle(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.sf(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.clots,
                  style: GoogleFonts.nunito(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppColors.tp(context))),
              Text(l10n.clotsQuestion,
                  style: GoogleFonts.nunito(
                      fontSize: 13, color: AppColors.ts(context))),
            ],
          ),
          Switch.adaptive(
            value: _hasClots,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _hasClots = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPadCounter(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.sf(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.padChange,
              style: GoogleFonts.nunito(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.tp(context))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _counterBtn(Icons.remove, () {
                if (_padChanges > 0) setState(() => _padChanges--);
              }),
              const SizedBox(width: 32),
              Text('$_padChanges',
                  style: GoogleFonts.nunito(
                      fontSize: 36, fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const SizedBox(width: 32),
              _counterBtn(Icons.add, () => setState(() => _padChanges++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(l10n.save,
              style: GoogleFonts.nunito(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Future<void> _save() async {
    await ref.read(dailyLogProvider.notifier).updateFlow(
      DateTime.now(),
      flowIntensity: _intensity,
      flowColor: _colorSelection,
      hasClots: _hasClots,
      padChangeCount: _padChanges,
    );
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.flowSaved),
            backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    }
  }
}
