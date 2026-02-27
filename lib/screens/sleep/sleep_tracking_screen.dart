import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/providers.dart';

class SleepTrackingScreen extends ConsumerStatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  ConsumerState<SleepTrackingScreen> createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends ConsumerState<SleepTrackingScreen> {
  TimeOfDay _bedTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  int _quality = 3;

  @override
  void initState() {
    super.initState();
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(DateTime.now());
    if (log != null) {
      if (log.sleepStart != null) {
        final parts = log.sleepStart!.split(':');
        if (parts.length == 2) {
          _bedTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 23,
              minute: int.tryParse(parts[1]) ?? 0);
        }
      }
      if (log.sleepEnd != null) {
        final parts = log.sleepEnd!.split(':');
        if (parts.length == 2) {
          _wakeTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 7,
              minute: int.tryParse(parts[1]) ?? 0);
        }
      }
      _quality = log.sleepQuality ?? 3;
    }
  }

  String _calculateDuration() {
    int bedMinutes = _bedTime.hour * 60 + _bedTime.minute;
    int wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    if (wakeMinutes <= bedMinutes) wakeMinutes += 24 * 60;
    final diff = wakeMinutes - bedMinutes;
    return AppLocalizations.of(context)!.sleepDurationShort(diff ~/ 60, diff % 60);
  }

  String _qualityLabelText(AppLocalizations l10n) {
    switch (_quality) {
      case 1: return l10n.veryBad;
      case 2: return l10n.bad;
      case 3: return l10n.moderate;
      case 4: return l10n.good;
      case 5: return l10n.great;
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(l10n.sleepTracking,
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
                  _buildDurationDisplay(l10n)
                      .animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 24),
                  _buildTimeCards(l10n)
                      .animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 24),
                  _buildQualitySection(l10n)
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

  Widget _buildDurationDisplay(AppLocalizations l10n) {
    return GlassCard(
      borderRadius: 24,
      blur: 10,
      opacity: 0.15,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.bedtime_rounded, color: AppColors.sleep, size: 48),
          const SizedBox(height: 12),
          Text(_calculateDuration(),
              style: GoogleFonts.nunito(
                  fontSize: 42, fontWeight: FontWeight.bold,
                  color: AppColors.sleep)),
          const SizedBox(height: 4),
          Text(l10n.totalSleep,
              style: GoogleFonts.nunito(
                  fontSize: 14, color: AppColors.ts(context))),
        ],
      ),
    );
  }

  Widget _buildTimeCards(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: _buildTimeCard(
          Icons.nightlight_round, l10n.bedTimeLabel, _bedTime,
          () async {
            final p = await showTimePicker(context: context, initialTime: _bedTime);
            if (p != null) setState(() => _bedTime = p);
          },
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildTimeCard(
          Icons.wb_sunny_rounded, l10n.wakeTimeLabel, _wakeTime,
          () async {
            final p = await showTimePicker(context: context, initialTime: _wakeTime);
            if (p != null) setState(() => _wakeTime = p);
          },
        )),
      ],
    );
  }

  Widget _buildTimeCard(IconData icon, String label, TimeOfDay time,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        borderRadius: 22,
        blur: 8,
        opacity: 0.15,
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, color: AppColors.sleep, size: 28),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.nunito(
                fontSize: 13, color: AppColors.ts(context))),
            const SizedBox(height: 4),
            Text(time.format(context),
                style: GoogleFonts.nunito(
                    fontSize: 22, fontWeight: FontWeight.bold,
                    color: AppColors.sleep)),
          ],
        ),
      ),
    );
  }

  Widget _buildQualitySection(AppLocalizations l10n) {
    return GlassCard(
      borderRadius: 22,
      blur: 8,
      opacity: 0.15,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.sleepQuality,
              style: GoogleFonts.nunito(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.tp(context))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _quality = star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedScale(
                    scale: star <= _quality ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      star <= _quality ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: star <= _quality ? AppColors.sleep : AppColors.ts(context),
                      size: 40,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(_qualityLabelText(l10n),
                style: GoogleFonts.nunito(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: AppColors.sleep)),
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
            backgroundColor: AppColors.sleep,
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
    final l10n = AppLocalizations.of(context)!;
    final bedStr =
        '${_bedTime.hour.toString().padLeft(2, '0')}:${_bedTime.minute.toString().padLeft(2, '0')}';
    final wakeStr =
        '${_wakeTime.hour.toString().padLeft(2, '0')}:${_wakeTime.minute.toString().padLeft(2, '0')}';
    await ref.read(dailyLogProvider.notifier).updateSleep(
      DateTime.now(),
      sleepStart: bedStr,
      sleepEnd: wakeStr,
      sleepQuality: _quality,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sleepSaved),
            backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    }
  }
}
