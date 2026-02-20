import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/providers.dart';

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key});

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDates;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _buildWeekDates();
  }

  void _buildWeekDates() {
    final now = DateTime.now();
    _weekDates = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dailyLogs = ref.watch(dailyLogProvider);
    final dateKey =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final log = dailyLogs[dateKey];

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(l10n.dailyLog,
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold, color: AppColors.tp(context))),
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.tp(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(),
            const SizedBox(height: 24),
            _buildCategoryGrid(log, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _weekDates.length,
        itemBuilder: (context, index) {
          final date = _weekDates[index];
          final isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;
          final isToday = date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.sf(context),
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8)]
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', Localizations.localeOf(context).toString()).format(date).substring(0, 2).toUpperCase(),
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white70 : AppColors.ts(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.tp(context),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms);
        },
      ),
    );
  }

  Widget _buildCategoryGrid(dynamic log, AppLocalizations l10n) {
    final categories = [
      _CategoryItem(Icons.water_drop_rounded, l10n.flow, AppColors.menstrual,
          _getFlowSummary(log, l10n), () => context.push('/flow')),
      _CategoryItem(Icons.face_rounded, l10n.symptoms, AppColors.secondary,
          _getSymptomSummary(log, l10n), () => context.push('/symptoms')),
      _CategoryItem(Icons.mood_rounded, l10n.mood, AppColors.moodHappy,
          _getMoodSummary(log, l10n), () => context.push('/mood')),
      _CategoryItem(Icons.thermostat_rounded, l10n.temperature, AppColors.temperature,
          _getTempSummary(log), () => context.push('/temperature')),
      _CategoryItem(Icons.monitor_weight_rounded, l10n.weight, AppColors.weightColor,
          _getWeightSummary(log), () => context.push('/weight')),
      _CategoryItem(Icons.local_drink_rounded, l10n.waterIntake, AppColors.water,
          _getWaterSummary(log, l10n), () => context.push('/water')),
      _CategoryItem(Icons.bedtime_rounded, l10n.sleep, AppColors.sleep,
          _getSleepSummary(log), () => context.push('/sleep')),
      _CategoryItem(Icons.favorite_rounded, l10n.sexualActivity, AppColors.moodRomantic,
          _getSexualSummary(log, l10n), () => context.push('/sexual-activity')),
      _CategoryItem(Icons.medication_rounded, l10n.medication, AppColors.medication,
          _getMedSummary(log, l10n), () => context.push('/medication')),
      _CategoryItem(Icons.edit_note_rounded, l10n.notes, AppColors.notesColor,
          _getNotesSummary(log), () => context.push('/notes')),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return GestureDetector(
          onTap: cat.onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.sf(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: cat.color.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(cat.icon, color: cat.color, size: 20),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat.label,
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.tp(context),
                              ),
                              overflow: TextOverflow.ellipsis),
                          if (cat.summary.isNotEmpty)
                            Text(cat.summary,
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  color: AppColors.ts(context),
                                ),
                                overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.ts(context), size: 18),
                  ],
                ),
              ],
            ),
          ),
        ).animate()
            .fadeIn(delay: (index * 50).ms, duration: 300.ms)
            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1),
                delay: (index * 50).ms, duration: 300.ms);
      },
    );
  }

  String _getFlowSummary(dynamic log, AppLocalizations l10n) {
    if (log == null || log.flowIntensity == null) return '';
    final labels = [l10n.light, l10n.medium, l10n.heavy, l10n.veryHeavy];
    return labels[log.flowIntensity.index];
  }

  String _getSymptomSummary(dynamic log, AppLocalizations l10n) {
    if (log == null || log.symptoms.isEmpty) return '';
    return l10n.nSymptoms(log.symptoms.length);
  }

  String _getMoodSummary(dynamic log, AppLocalizations l10n) {
    if (log == null || log.mood == null) return '';
    final labels = [l10n.happy, l10n.sad, l10n.angry, l10n.anxious, l10n.calm,
        l10n.energetic, l10n.tired, l10n.romantic, l10n.sensitiveM, l10n.irritableM, l10n.neutralM];
    return labels[log.mood.type.index];
  }

  String _getTempSummary(dynamic log) {
    if (log == null || log.temperature == null) return '';
    return '${log.temperature.toStringAsFixed(1)}°C';
  }

  String _getWeightSummary(dynamic log) {
    if (log == null || log.weight == null) return '';
    return '${log.weight.toStringAsFixed(1)} kg';
  }

  String _getWaterSummary(dynamic log, AppLocalizations l10n) {
    if (log == null || log.waterIntake == 0) return '';
    return l10n.nGlasses(log.waterIntake);
  }

  String _getSleepSummary(dynamic log) {
    if (log == null || log.sleepStart == null) return '';
    return '${log.sleepStart} - ${log.sleepEnd ?? '?'}';
  }

  String _getSexualSummary(dynamic log, AppLocalizations l10n) {
    if (log == null || log.sexualActivity == null) return '';
    return l10n.recorded;
  }

  String _getMedSummary(dynamic log, AppLocalizations l10n) {
    if (log == null || log.medications.isEmpty) return '';
    return l10n.nMedications(log.medications.length);
  }

  String _getNotesSummary(dynamic log) {
    if (log == null || log.notes == null || log.notes.isEmpty) return '';
    return log.notes.length > 20 ? '${log.notes.substring(0, 20)}...' : log.notes;
  }
}

class _CategoryItem {
  final IconData icon;
  final String label;
  final Color color;
  final String summary;
  final VoidCallback onTap;

  _CategoryItem(this.icon, this.label, this.color, this.summary, this.onTap);
}
