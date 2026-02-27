import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/providers.dart';

class WeightTrackingScreen extends ConsumerStatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  ConsumerState<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends ConsumerState<WeightTrackingScreen> {
  double _weight = 60.0;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(DateTime.now());
    if (log?.weight != null) {
      _weight = log!.weight!;
    }
    _controller.text = _weight.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _adjust(double delta) {
    setState(() {
      _weight = double.parse(
          (_weight + delta).clamp(20.0, 300.0).toStringAsFixed(1));
      _controller.text = _weight.toStringAsFixed(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(l10n.weight,
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
                children: [
                  const SizedBox(height: 16),
                  _buildWeightDisplay()
                      .animate().fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 500.ms),
                  const SizedBox(height: 28),
                  _buildQuickAdjust(l10n)
                      .animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 20),
                  _buildManualInput(l10n)
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

  Widget _buildWeightDisplay() {
    return GlassCard(
      borderRadius: 24,
      blur: 10,
      opacity: 0.15,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.monitor_weight_rounded,
              color: AppColors.weightColor, size: 48),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(_weight.toStringAsFixed(1),
                  style: GoogleFonts.nunito(
                      fontSize: 48, fontWeight: FontWeight.bold,
                      color: AppColors.weightColor)),
              const SizedBox(width: 4),
              Text('kg',
                  style: GoogleFonts.nunito(
                      fontSize: 22, fontWeight: FontWeight.w600,
                      color: AppColors.weightColor.withValues(alpha: 0.7))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAdjust(AppLocalizations l10n) {
    return GlassCard(
      borderRadius: 22,
      blur: 8,
      opacity: 0.15,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.quickAdjust,
              style: GoogleFonts.nunito(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.tp(context))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _adjustBtn('-1.0', () => _adjust(-1.0)),
              _adjustBtn('-0.1', () => _adjust(-0.1)),
              _adjustBtn('+0.1', () => _adjust(0.1)),
              _adjustBtn('+1.0', () => _adjust(1.0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _adjustBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.weightColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(label,
            style: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.weightColor)),
      ),
    );
  }

  Widget _buildManualInput(AppLocalizations l10n) {
    return GlassCard(
      borderRadius: 22,
      blur: 8,
      opacity: 0.15,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.manualEntry,
              style: GoogleFonts.nunito(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.tp(context))),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.nunito(
                fontSize: 22, fontWeight: FontWeight.bold,
                color: AppColors.weightColor),
            decoration: InputDecoration(
              suffixText: 'kg',
              suffixStyle: GoogleFonts.nunito(
                  fontSize: 16, color: AppColors.weightColor),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.dv(context))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.weightColor, width: 2)),
            ),
            onSubmitted: (v) {
              final parsed = double.tryParse(v);
              if (parsed != null && parsed >= 20 && parsed <= 300) {
                setState(() => _weight = double.parse(parsed.toStringAsFixed(1)));
              }
            },
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
            backgroundColor: AppColors.weightColor,
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
    await ref.read(dailyLogProvider.notifier).updateWeight(DateTime.now(), _weight);
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.weightSaved),
            backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    }
  }
}
