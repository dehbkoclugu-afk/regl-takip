import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/tracker_scaffold.dart';
import '../../models/enums.dart';
import '../../providers/providers.dart';
import '../../core/utils/motion.dart';

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

  // Dirty-guard için giriş anındaki durum
  FlowIntensity? _initialIntensity;
  FlowColor? _initialColor;
  bool _initialClots = false;
  int _initialPads = 0;

  bool get _isDirty =>
      _intensity != _initialIntensity ||
      _colorSelection != _initialColor ||
      _hasClots != _initialClots ||
      _padChanges != _initialPads;

  @override
  void initState() {
    super.initState();
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(ref.read(selectedDateProvider));
    if (log != null) {
      _intensity = log.flowIntensity;
      _colorSelection = log.flowColor;
      _hasClots = log.hasClots ?? false;
      _padChanges = log.padChangeCount ?? 0;
    }
    _initialIntensity = _intensity;
    _initialColor = _colorSelection;
    _initialClots = _hasClots;
    _initialPads = _padChanges;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TrackerScaffold(
      title: l10n.flowTracking,
      isDirty: _isDirty,
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.flowIntensity,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: AppColors.tp(context)))
                      .animateSafe(context).fadeIn(duration: 400.ms),
                  const SizedBox(height: 16),
                  _buildIntensityRow(l10n),
                  const SizedBox(height: 28),
                  Text(l10n.color,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: AppColors.tp(context)))
                      .animateSafe(context).fadeIn(delay: 100.ms, duration: 400.ms),
                  const SizedBox(height: 16),
                  _buildColorRow(l10n),
                  const SizedBox(height: 28),
                  _buildClotsToggle(l10n)
                      .animateSafe(context).fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 28),
                  _buildPadCounter(l10n)
                      .animateSafe(context).fadeIn(delay: 300.ms, duration: 400.ms),
                ],
              ),
            ),
      bottomBar: _buildSaveButton(l10n),
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
        return Semantics(
          button: true,
          selected: isSelected,
          label: item.$2,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(
                () => _intensity = _intensity == item.$1 ? null : item.$1),
            child: ExcludeSemantics(
              child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [item.$4.withValues(alpha: 0.3), item.$4.withValues(alpha: 0.15)],
                    )
                  : null,
              color: isSelected ? null : AppColors.sf(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? item.$4 : AppColors.dv(context),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: item.$4.withValues(alpha: 0.2), blurRadius: 12)]
                  : [],
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
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? item.$4 : AppColors.ts(context),
                    )),
              ],
            ),
              ),
            ),
          ),
        ).animateSafe(context).fadeIn(delay: (i * 60).ms, duration: 300.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1),
                delay: (i * 60).ms, duration: 300.ms);
      }).toList(),
    );
  }

  Widget _buildColorRow(AppLocalizations l10n) {
    final colors = [
      (FlowColor.lightRed, l10n.lightRed, const Color(0xFFFFB0B0)),
      (FlowColor.red, l10n.red, const Color(0xFFF0AAC0)),
      (FlowColor.darkRed, l10n.darkRed, const Color(0xFFBE5B7B)),
      (FlowColor.brown, l10n.brown, const Color(0xFFA08070)),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: colors.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final isSelected = _colorSelection == item.$1;
        return Semantics(
          button: true,
          selected: isSelected,
          label: item.$2,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() =>
                _colorSelection = _colorSelection == item.$1 ? null : item.$1),
            child: ExcludeSemantics(
              child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.$3,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.tp(context) : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: item.$3.withValues(alpha: 0.4), blurRadius: 12)]
                      : [],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 22)
                    : null,
              ),
              const SizedBox(height: 6),
              Text(item.$2,
                  style: TextStyle(
                      fontSize: 11, color: AppColors.ts(context)),
                  textAlign: TextAlign.center),
            ],
          ),
            ),
          ),
        ).animateSafe(context).fadeIn(delay: (100 + i * 60).ms, duration: 300.ms);
      }).toList(),
    );
  }

  Widget _buildClotsToggle(AppLocalizations l10n) {
    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.15,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.clots,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppColors.tp(context))),
              Text(l10n.clotsQuestion,
                  style: TextStyle(
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
    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.15,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.padChange,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.tp(context))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _counterBtn(Icons.remove, l10n.decrease, () {
                if (_padChanges > 0) setState(() => _padChanges--);
              }),
              const SizedBox(width: 32),
              Semantics(
                liveRegion: true,
                child: Text('$_padChanges',
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
              ),
              const SizedBox(width: 32),
              _counterBtn(
                  Icons.add, l10n.increase, () => setState(() => _padChanges++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counterBtn(IconData icon, String label, VoidCallback onTap) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: AppColors.primary, size: 24),
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(l10n.save,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _save() async {
    final notifier = ref.read(dailyLogProvider.notifier);
    final date = ref.read(selectedDateProvider);

    final hasInput = _intensity != null ||
        _colorSelection != null ||
        _hasClots ||
        _padChanges > 0;
    // Hiç veri yoksa ve o güne kayıt da yoksa boş günlük yazma
    if (!hasInput && notifier.getDailyLog(date) == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // setFlowDetails: seçim kaldırıldıysa alan da silinmeli. updateFlow
    // null'ı "dokunma" sayıyordu; kullanıcı akışı kaldırıp kaydettiğinde
    // eski değer kalıyordu.
    await notifier.setFlowDetails(
      date,
      intensity: _intensity,
      color: _colorSelection,
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
