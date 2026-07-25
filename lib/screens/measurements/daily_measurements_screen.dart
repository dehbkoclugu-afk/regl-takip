import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/input_parsing.dart';
import '../../core/utils/unit_conversion.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/tracker_scaffold.dart';
import '../../providers/providers.dart';

class DailyMeasurementsScreen extends ConsumerStatefulWidget {
  const DailyMeasurementsScreen({super.key});

  @override
  ConsumerState<DailyMeasurementsScreen> createState() =>
      _DailyMeasurementsScreenState();
}

class _DailyMeasurementsScreenState
    extends ConsumerState<DailyMeasurementsScreen> {
  final _weightController = TextEditingController();
  final _temperatureController = TextEditingController();

  int _glasses = 0;
  bool _sleepEnabled = false;
  TimeOfDay _bedTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  int _sleepQuality = 3;
  TimeOfDay _temperatureTime = TimeOfDay.now();

  late String _initialWeight;
  late String _initialTemperature;
  late int _initialGlasses;
  late bool _initialSleepEnabled;
  late TimeOfDay _initialBedTime;
  late TimeOfDay _initialWakeTime;
  late int _initialSleepQuality;
  late TimeOfDay _initialTemperatureTime;

  bool get _usePounds => ref.read(userProfileProvider)?.usePounds ?? false;
  bool get _useFahrenheit =>
      ref.read(userProfileProvider)?.useFahrenheit ?? false;
  String get _weightUnit => _usePounds ? 'lb' : 'kg';
  String get _temperatureUnit => _useFahrenheit ? '°F' : '°C';

  bool get _isDirty =>
      _weightController.text != _initialWeight ||
      _temperatureController.text != _initialTemperature ||
      _glasses != _initialGlasses ||
      _sleepEnabled != _initialSleepEnabled ||
      _bedTime != _initialBedTime ||
      _wakeTime != _initialWakeTime ||
      _sleepQuality != _initialSleepQuality ||
      _temperatureTime != _initialTemperatureTime;

  @override
  void initState() {
    super.initState();
    final log = ref
        .read(dailyLogProvider.notifier)
        .getDailyLog(ref.read(selectedDateProvider));
    _glasses = log?.waterIntake ?? 0;

    if (log?.weight != null) {
      final shown = _usePounds
          ? UnitConversion.kilogramsToPounds(log!.weight!)
          : log!.weight!;
      _weightController.text = shown.toStringAsFixed(1);
    }
    if (log?.temperature != null) {
      final shown = _useFahrenheit
          ? UnitConversion.celsiusToFahrenheit(log!.temperature!)
          : log!.temperature!;
      _temperatureController.text = shown.toStringAsFixed(1);
    }

    _sleepEnabled = log?.sleepStart != null || log?.sleepEnd != null;
    _bedTime = _parseTime(log?.sleepStart, _bedTime);
    _wakeTime = _parseTime(log?.sleepEnd, _wakeTime);
    _sleepQuality = log?.sleepQuality ?? 3;
    _temperatureTime = _parseTime(
      log?.temperatureTime,
      _temperatureTime,
    );

    _initialWeight = _weightController.text;
    _initialTemperature = _temperatureController.text;
    _initialGlasses = _glasses;
    _initialSleepEnabled = _sleepEnabled;
    _initialBedTime = _bedTime;
    _initialWakeTime = _wakeTime;
    _initialSleepQuality = _sleepQuality;
    _initialTemperatureTime = _temperatureTime;
  }

  TimeOfDay _parseTime(String? value, TimeOfDay fallback) {
    final parts = value?.split(':');
    if (parts == null || parts.length != 2) return fallback;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return fallback;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TrackerScaffold(
      title: l10n.dailyMeasurements,
      isDirty: _isDirty,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _waterCard(l10n),
            const SizedBox(height: 16),
            _sleepCard(l10n),
            const SizedBox(height: 16),
            _numberCard(
              icon: Icons.monitor_weight_rounded,
              title: l10n.weight,
              color: AppColors.weightColor,
              controller: _weightController,
              unit: _weightUnit,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _temperatureCard(l10n),
          ],
        ),
      ),
      bottomBar: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            l10n.save,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _waterCard(AppLocalizations l10n) {
    return _section(
      icon: Icons.local_drink_rounded,
      title: l10n.waterIntake,
      color: AppColors.water,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20,
        runSpacing: 8,
        children: [
          IconButton.filledTonal(
            onPressed:
                _glasses == 0 ? null : () => setState(() => _glasses--),
            tooltip: l10n.decrease,
            icon: const Icon(Icons.remove_rounded),
          ),
          Semantics(
            liveRegion: true,
            label: l10n.nGlasses(_glasses),
            child: ExcludeSemantics(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_glasses',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.categoryText(context, AppColors.water),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${l10n.glasses} · '
                    '${_glasses * AppConstants.waterGlassMl} ml',
                    style: TextStyle(color: AppColors.ts(context)),
                  ),
                ],
              ),
            ),
          ),
          IconButton.filledTonal(
            onPressed: () => setState(() => _glasses++),
            tooltip: l10n.increase,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }

  Widget _sleepCard(AppLocalizations l10n) {
    return _section(
      icon: Icons.bedtime_rounded,
      title: l10n.sleep,
      color: AppColors.sleep,
      trailing: Switch(
        value: _sleepEnabled,
        onChanged: (value) => setState(() => _sleepEnabled = value),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: !_sleepEnabled
            ? const SizedBox.shrink()
            : Column(
                key: const ValueKey('sleep-fields'),
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _timeButton(
                        l10n.bedTimeLabel,
                        _bedTime,
                        AppColors.sleep,
                        (value) => setState(() => _bedTime = value),
                      ),
                      _timeButton(
                        l10n.wakeTimeLabel,
                        _wakeTime,
                        AppColors.sleep,
                        (value) => setState(() => _wakeTime = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.sleepQuality,
                      style: TextStyle(
                        color: AppColors.tp(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: List.generate(5, (index) {
                      final value = index + 1;
                      return IconButton(
                        onPressed: () =>
                            setState(() => _sleepQuality = value),
                        tooltip: l10n.severityLevel(value),
                        icon: Icon(
                          value <= _sleepQuality
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: AppColors.sleep,
                        ),
                      );
                    }),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _temperatureCard(AppLocalizations l10n) {
    return _section(
      icon: Icons.thermostat_rounded,
      title: l10n.temperature,
      color: AppColors.temperature,
      child: Column(
        children: [
          TextField(
            controller: _temperatureController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              suffixText: _temperatureUnit,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_temperatureController.text.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _timeButton(
              l10n.measurementTime,
              _temperatureTime,
              AppColors.temperature,
              (value) => setState(() => _temperatureTime = value),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.ts(context),
              ),
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
          ),
        ],
      ),
    );
  }

  Widget _numberCard({
    required IconData icon,
    required String title,
    required Color color,
    required TextEditingController controller,
    required String unit,
    required TextInputAction action,
  }) {
    return _section(
      icon: icon,
      title: title,
      color: color,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: action,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          suffixText: unit,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
    Widget? trailing,
  }) {
    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.15,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tp(context),
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _timeButton(
    String label,
    TimeOfDay value,
    Color color,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value,
        );
        if (picked != null) onChanged(picked);
      },
      icon: Icon(Icons.access_time_rounded, color: color),
      label: Text('$label · ${value.format(context)}'),
    );
  }

  double? _parseWeight(String raw) {
    if (raw.trim().isEmpty) return null;
    final value = double.tryParse(raw.trim().replaceAll(',', '.'));
    if (value == null || value.isNaN) return double.nan;
    final kilograms =
        _usePounds ? UnitConversion.poundsToKilograms(value) : value;
    if (kilograms < InputParsing.minWeightKg ||
        kilograms > InputParsing.maxWeightKg) {
      return double.nan;
    }
    return double.parse(kilograms.toStringAsFixed(1));
  }

  double? _parseTemperature(String raw) {
    if (raw.trim().isEmpty) return null;
    final value = double.tryParse(raw.trim().replaceAll(',', '.'));
    if (value == null || value.isNaN) return double.nan;
    final celsius = _useFahrenheit
        ? UnitConversion.fahrenheitToCelsius(value)
        : value;
    if (celsius < 35 || celsius > 40) return double.nan;
    return double.parse(celsius.toStringAsFixed(1));
  }

  String _timeString(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final weight = _parseWeight(_weightController.text);
    if (weight?.isNaN == true) {
      _showError(l10n.invalidWeight);
      return;
    }
    final temperature = _parseTemperature(_temperatureController.text);
    if (temperature?.isNaN == true) {
      _showError(l10n.invalidTemperature);
      return;
    }

    await ref.read(dailyLogProvider.notifier).updateMeasurements(
      ref.read(selectedDateProvider),
      waterIntake: _glasses,
      temperature: temperature,
      temperatureTime:
          temperature == null ? null : _timeString(_temperatureTime),
      weight: weight,
      sleepStart: _sleepEnabled ? _timeString(_bedTime) : null,
      sleepEnd: _sleepEnabled ? _timeString(_wakeTime) : null,
      sleepQuality: _sleepEnabled ? _sleepQuality : null,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.savedGeneric),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
