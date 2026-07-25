import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/adaptive_layout.dart';
import '../../core/utils/enum_labels.dart';
import '../../core/widgets/tracker_scaffold.dart';
import '../../models/enums.dart';
import '../../models/period_record.dart';
import '../../providers/providers.dart';
import '../../core/utils/motion.dart';

class SymptomTrackingScreen extends ConsumerStatefulWidget {
  const SymptomTrackingScreen({super.key});

  @override
  ConsumerState<SymptomTrackingScreen> createState() =>
      _SymptomTrackingScreenState();
}

class _SymptomTrackingScreenState extends ConsumerState<SymptomTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<SymptomType, int> _selectedSymptoms = {};
  final Map<SymptomType, int> _initialSymptoms = {};

  bool get _isDirty {
    if (_selectedSymptoms.length != _initialSymptoms.length) return true;
    for (final entry in _selectedSymptoms.entries) {
      if (_initialSymptoms[entry.key] != entry.value) return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: SymptomCategory.values.length, vsync: this);
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(ref.read(selectedDateProvider));
    if (log != null) {
      for (final entry in log.symptoms) {
        _selectedSymptoms[entry.type] = entry.severity;
      }
    }
    _initialSymptoms.addAll(_selectedSymptoms);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<SymptomType> _getSymptomsForCategory(SymptomCategory category) {
    switch (category) {
      case SymptomCategory.physical:
        return [SymptomType.cramp, SymptomType.headache, SymptomType.bloating,
          SymptomType.breastTenderness, SymptomType.backPain,
          SymptomType.fatigue, SymptomType.nausea, SymptomType.dizziness];
      case SymptomCategory.emotional:
        return [SymptomType.stress, SymptomType.anxiety,
          SymptomType.irritability, SymptomType.crying, SymptomType.sensitivity];
      case SymptomCategory.skin:
        return [SymptomType.acne, SymptomType.oilySkin, SymptomType.drySkin,
          SymptomType.glowing];
      case SymptomCategory.digestive:
        return [SymptomType.constipation, SymptomType.diarrhea, SymptomType.gas,
          SymptomType.increasedAppetite, SymptomType.decreasedAppetite];
      case SymptomCategory.other:
        return [SymptomType.insomnia, SymptomType.hotFlash, SymptomType.edema,
          SymptomType.hairLoss];
    }
  }

  String _symptomName(SymptomType type, AppLocalizations l10n) =>
      EnumLabels.symptom(type, l10n);

  IconData _symptomIcon(SymptomType type) {
    const icons = {
      SymptomType.cramp: Icons.flash_on_rounded,
      SymptomType.headache: Icons.psychology_rounded,
      SymptomType.bloating: Icons.circle_rounded,
      SymptomType.breastTenderness: Icons.favorite_rounded,
      SymptomType.backPain: Icons.accessibility_new_rounded,
      SymptomType.fatigue: Icons.battery_2_bar_rounded,
      SymptomType.nausea: Icons.sick_rounded,
      SymptomType.dizziness: Icons.rotate_right_rounded,
      SymptomType.stress: Icons.bolt_rounded,
      SymptomType.anxiety: Icons.warning_rounded,
      SymptomType.irritability: Icons.whatshot_rounded,
      SymptomType.crying: Icons.water_drop_rounded,
      SymptomType.sensitivity: Icons.sensors_rounded,
      SymptomType.acne: Icons.face_rounded,
      SymptomType.oilySkin: Icons.opacity_rounded,
      SymptomType.drySkin: Icons.grain_rounded,
      SymptomType.glowing: Icons.auto_awesome_rounded,
      SymptomType.constipation: Icons.block_rounded,
      SymptomType.diarrhea: Icons.water_rounded,
      SymptomType.gas: Icons.air_rounded,
      SymptomType.increasedAppetite: Icons.restaurant_rounded,
      SymptomType.decreasedAppetite: Icons.no_food_rounded,
      SymptomType.insomnia: Icons.nightlight_rounded,
      SymptomType.hotFlash: Icons.thermostat_rounded,
      SymptomType.edema: Icons.water_damage_rounded,
      SymptomType.hairLoss: Icons.content_cut_rounded,
    };
    return icons[type] ?? Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TrackerScaffold(
      title: l10n.symptomTracking,
      isDirty: _isDirty,
      appBarBottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.ts(context),
        indicatorColor: AppColors.primary,
        labelStyle: TextStyle(fontWeight: FontWeight.w700),
        tabs: [
          Tab(text: l10n.physical), Tab(text: l10n.emotional), Tab(text: l10n.skinCategory),
          Tab(text: l10n.digestive), Tab(text: l10n.otherCategory),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: SymptomCategory.values
            .map((cat) => _buildCategoryGrid(cat, l10n))
            .toList(),
      ),
      bottomBar: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryStrong,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(l10n.saveNSymptoms(_selectedSymptoms.length),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(SymptomCategory category, AppLocalizations l10n) {
    final symptoms = _getSymptomsForCategory(category);
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale =
            effectiveTextScale(MediaQuery.textScalerOf(context));
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: adaptiveGridColumns(
              width: constraints.maxWidth - 32,
              textScale: textScale,
              maxColumns: 2,
              minCardWidth: 130,
            ),
            mainAxisExtent: scaledGridExtent(105, textScale),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: symptoms.length,
          itemBuilder: (context, index) {
        final symptom = symptoms[index];
        final isSelected = _selectedSymptoms.containsKey(symptom);
        final severity = _selectedSymptoms[symptom] ?? 1;

        return Semantics(
          button: true,
          selected: isSelected,
          label: isSelected
              ? '${_symptomName(symptom, l10n)}, ${l10n.severityLevel(severity)}'
              : _symptomName(symptom, l10n),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() {
              if (isSelected) {
                _selectedSymptoms.remove(symptom);
              } else {
                _selectedSymptoms[symptom] = 1;
              }
            }),
            child: AnimatedContainer(
            duration: context.motionDuration(const Duration(milliseconds: 250)),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.primary.withValues(alpha: 0.05)],
                    )
                  : null,
              color: isSelected ? null : AppColors.sf(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.dv(context),
                width: isSelected ? 1.5 : 0.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 12)]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_symptomIcon(symptom),
                    // primary beyaz zeminde 2,01:1 — ikon için de 3:1 gerekir
                    color: isSelected
                        ? AppColors.primaryStrong
                        : AppColors.ts(context),
                    size: 28),
                const SizedBox(height: 6),
                Text(_symptomName(symptom, l10n),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      // Seçim etiketi primary'ye dönüyordu: 2,01:1. Ailenin
                      // bordo ucu aynı kimliği 6,30:1 ile veriyor
                      color: isSelected
                          ? AppColors.primaryDeep
                          : AppColors.tp(context),
                    ),
                    textAlign: TextAlign.center),
                if (isSelected) ...[
                  const SizedBox(height: 2),
                  // Şiddet noktaları 10 px ikon + 2 px boşluktu: dokunma
                  // hedefi ~14 px. Her nokta artık 28 px'lik alanda.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => Semantics(
                        button: true,
                        selected: i < severity,
                        label: l10n.severityLevel(i + 1),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () =>
                              setState(() => _selectedSymptoms[symptom] = i + 1),
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: Icon(
                              i < severity
                                  ? Icons.circle
                                  : Icons.circle_outlined,
                              size: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ),
        ).animateSafe(context).fadeIn(delay: (index * 50).ms, duration: 300.ms);
          },
        );
      },
    );
  }

  Future<void> _save() async {
    final notifier = ref.read(dailyLogProvider.notifier);
    final date = ref.read(selectedDateProvider);
    final entries = _selectedSymptoms.entries
        .map((e) => SymptomEntry(type: e.key, severity: e.value))
        .toList();

    // Hiç semptom seçilmediyse ve o güne kayıt da yoksa boş günlük yazma
    if (entries.isEmpty && notifier.getDailyLog(date) == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    await notifier.updateSymptoms(date, entries);
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.nSymptomsSaved(entries.length)),
            backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    }
  }
}
