import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/providers.dart';

class WaterTrackingScreen extends ConsumerStatefulWidget {
  const WaterTrackingScreen({super.key});

  @override
  ConsumerState<WaterTrackingScreen> createState() => _WaterTrackingScreenState();
}

class _WaterTrackingScreenState extends ConsumerState<WaterTrackingScreen> {
  int _glasses = 0;

  int get _goal => ref.read(userProfileProvider)?.waterGoal ?? AppConstants.defaultWaterGoal;

  @override
  void initState() {
    super.initState();
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(DateTime.now());
    if (log != null) {
      _glasses = log.waterIntake;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final goal = _goal;
    final progress = goal > 0 ? _glasses / goal : 0.0;
    final totalMl = _glasses * AppConstants.waterGlassMl;
    final goalMl = goal * AppConstants.waterGlassMl;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(l10n.waterTracking,
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
                  _buildWaterCircle(progress, totalMl, goalMl, goal, l10n)
                      .animate().fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 500.ms),
                  const SizedBox(height: 12),
                  Text(
                    '1 ${l10n.glasses} = ${AppConstants.waterGlassMl} ml',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: AppColors.ts(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildControls(goal)
                      .animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 28),
                  _buildGlassGrid(goal, l10n)
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
                        style: GoogleFonts.nunito(
                            fontSize: 36, fontWeight: FontWeight.bold,
                            color: AppColors.water)),
                    Text(l10n.glasses,
                        style: GoogleFonts.nunito(
                            fontSize: 14, color: AppColors.ts(context))),
                    const SizedBox(height: 4),
                    Text('$totalMl / $goalMl ml',
                        style: GoogleFonts.nunito(
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _counterBtn(Icons.remove, () {
          if (_glasses > 0) setState(() => _glasses--);
        }),
        const SizedBox(width: 32),
        GestureDetector(
          onTap: _showGoalDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.water.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.water.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_rounded,
                    color: AppColors.water, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${AppLocalizations.of(context)!.dailyGoal}: $goal',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.water,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 32),
        _counterBtn(Icons.add, () {
          if (_glasses < goal) setState(() => _glasses++);
        }),
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
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
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
                      style: GoogleFonts.nunito(
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
                  style: GoogleFonts.nunito(
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
                  ref.read(userProfileProvider.notifier)
                      .saveProfile(waterGoal: tempGoal);
                  if (_glasses > tempGoal) {
                    setState(() => _glasses = tempGoal);
                  }
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

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.water.withValues(alpha: 0.2), AppColors.water.withValues(alpha: 0.08)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: AppColors.water, size: 28),
      ),
    );
  }

  Widget _buildGlassGrid(int goal, AppLocalizations l10n) {
    return GlassCard(
      borderRadius: 22,
      blur: 8,
      opacity: 0.15,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.dailyGoal,
              style: GoogleFonts.nunito(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.tp(context))),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12,
            ),
            itemCount: goal,
            itemBuilder: (context, index) {
              final isFilled = index < _glasses;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isFilled
                      ? AppColors.water.withValues(alpha: 0.15)
                      : AppColors.isDark(context) ? AppColors.cardDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
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
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.water,
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
    await ref.read(dailyLogProvider.notifier).updateWater(DateTime.now(), _glasses);
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
