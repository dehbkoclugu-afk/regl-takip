import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/tracker_scaffold.dart';
import '../../providers/providers.dart';
import '../../core/utils/motion.dart';

class WaterTrackingScreen extends ConsumerStatefulWidget {
  const WaterTrackingScreen({super.key});

  @override
  ConsumerState<WaterTrackingScreen> createState() => _WaterTrackingScreenState();
}

class _WaterTrackingScreenState extends ConsumerState<WaterTrackingScreen> {
  int _glasses = 0;
  int _initialGlasses = 0;

  bool get _isDirty => _glasses != _initialGlasses;

  int get _goal => ref.read(userProfileProvider)?.waterGoal ?? AppConstants.defaultWaterGoal;

  @override
  void initState() {
    super.initState();
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(ref.read(selectedDateProvider));
    if (log != null) {
      _glasses = log.waterIntake;
    }
    _initialGlasses = _glasses;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final goal = _goal;
    final progress = goal > 0 ? _glasses / goal : 0.0;
    final totalMl = _glasses * AppConstants.waterGlassMl;
    final goalMl = goal * AppConstants.waterGlassMl;

    return TrackerScaffold(
      title: l10n.waterTracking,
      isDirty: _isDirty,
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildWaterCircle(progress, totalMl, goalMl, goal, l10n)
                      .animateSafe(context).fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 500.ms),
                  const SizedBox(height: 12),
                  Text(
                    '1 ${l10n.glasses} = ${AppConstants.waterGlassMl} ml',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.ts(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildControls(goal)
                      .animateSafe(context).fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 28),
                  _buildGlassGrid(goal, l10n)
                      .animateSafe(context).fadeIn(delay: 400.ms, duration: 400.ms),
                ],
              ),
            ),
      bottomBar: _buildSaveButton(l10n),
    );
  }

  Widget _buildWaterCircle(double progress, int totalMl, int goalMl, int goal, AppLocalizations l10n) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 12,
                    backgroundColor: AppColors.water.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(AppColors.water),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_drink_rounded,
                        color: AppColors.water, size: 36),
                    const SizedBox(height: 8),
                    Text('$_glasses/$goal',
                        style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.bold,
                            color: AppColors.water)),
                    Text(l10n.glasses,
                        style: TextStyle(
                            fontSize: 14, color: AppColors.ts(context))),
                    const SizedBox(height: 4),
                    Text('$totalMl / $goalMl ml',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.ts(context))),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildControls(int goal) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _counterBtn(Icons.remove, l10n.decrease, () {
          if (_glasses > 0) setState(() => _glasses--);
        }),
        const SizedBox(width: 32),
        Semantics(
          button: true,
          label: '${l10n.dailyGoal}: $goal',
          child: Material(
            color: AppColors.water.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _showGoalDialog,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.water.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit_rounded,
                        color: AppColors.water, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${l10n.dailyGoal}: $goal',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.water,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),
        // Hedefin üstünde içilen su da kayda girmeli: sayaç hedefte
        // durduruluyordu, fazlası kaydedilemiyordu
        _counterBtn(Icons.add, l10n.increase,
            () => setState(() => _glasses++)),
      ],
    );
  }

  void _showGoalDialog() {
    final l10n = AppLocalizations.of(context)!;
    int tempGoal = _goal;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final tempMl = tempGoal * AppConstants.waterGlassMl;
          return AlertDialog(
            title: Text(l10n.dailyGoal,
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: tempGoal > 1
                          ? () => setDialogState(() => tempGoal--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      color: AppColors.water,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$tempGoal',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.water,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: tempGoal < 20
                          ? () => setDialogState(() => tempGoal++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      color: AppColors.water,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$tempGoal ${l10n.glasses} = $tempMl ml',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.ts(context),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(userProfileProvider.notifier)
                      .saveProfile(waterGoal: tempGoal);
                  // Hedef düşürülünce içilen su kırpılıyordu: hedef bir
                  // hedeftir, kayıtlı veriyi silmez
                  setState(() {});
                  Navigator.pop(ctx);
                },
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _counterBtn(IconData icon, String label, VoidCallback onTap) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.water.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(icon, color: AppColors.water, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassGrid(int goal, AppLocalizations l10n) {
    return GlassCard(
      borderRadius: 20,
      blur: 0,
      opacity: 0.15,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.dailyGoal,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.tp(context))),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12,
            ),
            // Hedef aşıldıysa fazla bardaklar da görünsün
            itemCount: _glasses > goal ? _glasses : goal,
            itemBuilder: (context, index) {
              final isFilled = index < _glasses;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isFilled
                      ? AppColors.water.withValues(alpha: 0.15)
                      : AppColors.isDark(context) ? AppColors.cardDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFilled ? AppColors.water : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(Icons.local_drink_rounded,
                    color: isFilled
                        ? AppColors.water
                        : AppColors.ts(context).withValues(alpha: 0.3),
                    size: 28),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.water,
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

  Future<void> _save() async {
    await ref.read(dailyLogProvider.notifier).updateWater(ref.read(selectedDateProvider), _glasses);
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.waterSaved),
            backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    }
  }
}
