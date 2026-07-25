import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/tracker_scaffold.dart';
import '../../providers/providers.dart';
import '../../core/utils/motion.dart';

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
  bool _hasExistingMeasurement = false;

  // Dirty-guard için giriş anındaki durum
  double _initialTemperature = 36.5;
  TimeOfDay? _initialTime;

  bool get _isDirty =>
      _temperature != _initialTemperature || _measureTime != _initialTime;

  @override
  void initState() {
    super.initState();
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(ref.read(selectedDateProvider));
    if (log != null) {
      _temperature = log.temperature ?? 36.5;
      _hasExistingMeasurement = log.temperature != null;
      if (log.temperatureTime != null) {
        final parts = log.temperatureTime!.split(':');
        if (parts.length == 2) {
          _measureTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 7,
              minute: int.tryParse(parts[1]) ?? 0);
        }
      }
    }
    _initialTemperature = _temperature;
    _initialTime = _measureTime;
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
    return TrackerScaffold(
      title: l10n.temperature,
      isDirty: _isDirty,
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildTempDisplay(l10n)
                      .animateSafe(context).fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 500.ms),
                  const SizedBox(height: 28),
                  _buildSlider()
                      .animateSafe(context).fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 24),
                  _buildTimeSelector(l10n)
                      .animateSafe(context).fadeIn(delay: 400.ms, duration: 400.ms),
                  const SizedBox(height: 16),
                  // Ovülasyon teyidi bu ölçümlere dayanıyor: gün içi rastgele
                  // ölçüm BBT eğrisini işe yaramaz hale getirir
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 16, color: AppColors.ts(context)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.bbtHint,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: AppColors.ts(context),
                          ),
                        ),
                      ),
                    ],
                  ).animateSafe(context).fadeIn(delay: 500.ms, duration: 400.ms),
                  if (_hasExistingMeasurement) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: Text(l10n.deleteMeasurement),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.error),
                    ),
                  ],
                ],
              ),
            ),
      bottomBar: _buildSaveButton(l10n),
    );
  }

  Widget _buildTempDisplay(AppLocalizations l10n) {
    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.15,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.thermostat_rounded, color: _getTempColor(), size: 48),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 36.5, end: _temperature),
            duration: context.motionDuration(const Duration(milliseconds: 300)),
            builder: (context, value, _) => Text(
              '${value.toStringAsFixed(1)}°C',
              // Tabular metrik ölçeği: sayaç akarken genişlik zıplamaz
              style: Theme.of(context)
                  .textTheme
                  .displayLarge!
                  .copyWith(color: _getTempColor()),
            ),
          ),
          const SizedBox(height: 8),
          Text(_getTempLabel(l10n),
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600,
                  color: _getTempColor())),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.15,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('35.0°C', style: TextStyle(
                  fontSize: 12, color: AppColors.ts(context))),
              Text('40.0°C', style: TextStyle(
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
              label: '${_temperature.toStringAsFixed(1)}°C',
              semanticFormatterCallback: (v) => '${v.toStringAsFixed(1)}°C',
              onChanged: (v) => setState(() =>
                  _temperature = double.parse(v.toStringAsFixed(1))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(AppLocalizations l10n) {
    return Semantics(
      button: true,
      label: l10n.measurementTime,
      value: _measureTime.format(context),
      child: Material(
        color: AppColors.sf(context),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final picked = await showTimePicker(
                context: context, initialTime: _measureTime);
            if (picked != null) setState(() => _measureTime = picked);
          },
          child: Container(
        padding: const EdgeInsets.all(20),
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
                  color: AppColors.categoryText(context, AppColors.temperature)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.measurementTime,
                      style: TextStyle(
                          fontSize: 14, color: AppColors.ts(context))),
                  Text(_measureTime.format(context),
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: AppColors.categoryText(context, AppColors.temperature))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.ts(context)),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.temperature,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(l10n.save,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  /// Yanlışlıkla kaydedilen ölçüm BBT eğrisini (ve ovülasyon teyidini)
  /// bozar — silinebilmeli.
  Future<void> _delete() async {
    await ref
        .read(dailyLogProvider.notifier)
        .updateTemperature(ref.read(selectedDateProvider), null);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(l10n.measurementDeleted),
          backgroundColor: AppColors.success),
    );
    Navigator.of(context).pop();
  }

  Future<void> _save() async {
    final timeStr =
        '${_measureTime.hour.toString().padLeft(2, '0')}:${_measureTime.minute.toString().padLeft(2, '0')}';
    await ref.read(dailyLogProvider.notifier).updateTemperature(
      ref.read(selectedDateProvider),
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
