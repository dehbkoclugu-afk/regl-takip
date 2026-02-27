import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/providers.dart';

class TemperatureTrackingScreen extends ConsumerStatefulWidget {
  const TemperatureTrackingScreen({super.key});

  @override
  ConsumerState<TemperatureTrackingScreen> createState() =>
      _TemperatureTrackingScreenState();
}

class _TemperatureTrackingScreenState
    extends ConsumerState<TemperatureTrackingScreen> {
  double _temperature = 36.5;
  TimeOfDay _measureTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(DateTime.now());
    if (log != null) {
      _temperature = log.temperature ?? 36.5;
      if (log.temperatureTime != null) {
        final parts = log.temperatureTime!.split(':');
        if (parts.length == 2) {
          _measureTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 7,
              minute: int.tryParse(parts[1]) ?? 0);
        }
      }
    }
  }

  Color _getTempColor() {
    if (_temperature < 36.0) return Colors.blue;
    if (_temperature < 37.0) return AppColors.success;
    if (_temperature < 38.0) return AppColors.warning;
    return AppColors.error;
  }

  String _getTempLabel(AppLocalizations l10n) {
    if (_temperature < 36.0) return l10n.lowTemp;
    if (_temperature < 37.0) return l10n.normalTemp;
    if (_temperature < 38.0) return l10n.highTemp;
    return l10n.fever;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(l10n.temperature,
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
                  _buildTempDisplay(l10n)
                      .animate().fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 500.ms),
                  const SizedBox(height: 28),
                  _buildSlider()
                      .animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 24),
                  _buildTimeSelector(l10n)
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

  Widget _buildTempDisplay(AppLocalizations l10n) {
    return GlassCard(
      borderRadius: 24,
      blur: 10,
      opacity: 0.15,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.thermostat_rounded, color: _getTempColor(), size: 48),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 36.5, end: _temperature),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, _) => Text(
              '${value.toStringAsFixed(1)}°C',
              style: GoogleFonts.nunito(
                  fontSize: 48, fontWeight: FontWeight.bold,
                  color: _getTempColor()),
            ),
          ),
          const SizedBox(height: 8),
          Text(_getTempLabel(l10n),
              style: GoogleFonts.nunito(
                  fontSize: 16, fontWeight: FontWeight.w600,
                  color: _getTempColor())),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return GlassCard(
      borderRadius: 22,
      blur: 8,
      opacity: 0.15,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('35.0°C', style: GoogleFonts.nunito(
                  fontSize: 12, color: AppColors.ts(context))),
              Text('40.0°C', style: GoogleFonts.nunito(
                  fontSize: 12, color: AppColors.ts(context))),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.temperature,
              inactiveTrackColor: AppColors.temperature.withValues(alpha: 0.15),
              thumbColor: AppColors.temperature,
              overlayColor: AppColors.temperature.withValues(alpha: 0.12),
              trackHeight: 6,
            ),
            child: Slider(
              value: _temperature,
              min: 35.0,
              max: 40.0,
              divisions: 50,
              onChanged: (v) => setState(() =>
                  _temperature = double.parse(v.toStringAsFixed(1))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
            context: context, initialTime: _measureTime);
        if (picked != null) setState(() => _measureTime = picked);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.sf(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.temperature.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.access_time_rounded,
                  color: AppColors.temperature),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.measurementTime,
                      style: GoogleFonts.nunito(
                          fontSize: 14, color: AppColors.ts(context))),
                  Text(_measureTime.format(context),
                      style: GoogleFonts.nunito(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: AppColors.temperature)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.ts(context)),
          ],
        ),
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
            backgroundColor: AppColors.temperature,
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
    final timeStr =
        '${_measureTime.hour.toString().padLeft(2, '0')}:${_measureTime.minute.toString().padLeft(2, '0')}';
    await ref.read(dailyLogProvider.notifier).updateTemperature(
      DateTime.now(),
      _temperature,
      temperatureTime: timeStr,
    );
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.temperatureSaved),
            backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    }
  }
}
