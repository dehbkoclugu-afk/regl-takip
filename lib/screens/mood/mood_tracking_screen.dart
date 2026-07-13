import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/enums.dart';
import '../../models/period_record.dart';
import '../../providers/providers.dart';
import '../../core/utils/motion.dart';

class MoodTrackingScreen extends ConsumerStatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  ConsumerState<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends ConsumerState<MoodTrackingScreen> {
  MoodType? _selectedMood;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(DateTime.now());
    if (log?.mood != null) {
      _selectedMood = log!.mood!.type;
      _noteController.text = log.mood!.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  static const _moodEmojis = <MoodType, (String, Color)>{
    MoodType.happy: ('\u{1F60A}', AppColors.moodHappy),
    MoodType.sad: ('\u{1F622}', AppColors.moodSad),
    MoodType.angry: ('\u{1F621}', AppColors.moodAngry),
    MoodType.anxious: ('\u{1F630}', AppColors.moodAnxious),
    MoodType.calm: ('\u{1F60C}', AppColors.moodCalm),
    MoodType.energetic: ('\u{26A1}', AppColors.moodEnergetic),
    MoodType.tired: ('\u{1F634}', AppColors.moodTired),
    MoodType.romantic: ('\u{1F970}', AppColors.moodRomantic),
    MoodType.sensitive: ('\u{1F97A}', AppColors.moodSad),
    MoodType.irritable: ('\u{1F624}', AppColors.moodAngry),
    MoodType.neutral: ('\u{1F610}', AppColors.moodNeutral),
  };

  Map<MoodType, String> _moodLabels(AppLocalizations l10n) => {
    MoodType.happy: l10n.happy,
    MoodType.sad: l10n.sad,
    MoodType.angry: l10n.angry,
    MoodType.anxious: l10n.anxious,
    MoodType.calm: l10n.calm,
    MoodType.energetic: l10n.energetic,
    MoodType.tired: l10n.tired,
    MoodType.romantic: l10n.romantic,
    MoodType.sensitive: l10n.sensitiveM,
    MoodType.irritable: l10n.irritableM,
    MoodType.neutral: l10n.neutralM,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = _moodLabels(l10n);
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(l10n.mood,
            style: TextStyle(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.howAreYouFeeling,
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold,
                          color: AppColors.tp(context)))
                      .animateSafe(context).fadeIn(duration: 400.ms),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, childAspectRatio: 0.9,
                      crossAxisSpacing: 12, mainAxisSpacing: 12,
                    ),
                    itemCount: MoodType.values.length,
                    itemBuilder: (context, index) {
                      final mood = MoodType.values[index];
                      final emojiData = _moodEmojis[mood]!;
                      final label = labels[mood]!;
                      final isSelected = _selectedMood == mood;

                      return GestureDetector(
                        onTap: () => setState(() =>
                            _selectedMood = _selectedMood == mood ? null : mood),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [emojiData.$2.withValues(alpha: 0.2), emojiData.$2.withValues(alpha: 0.08)],
                                  )
                                : null,
                            color: isSelected ? null : AppColors.sf(context),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSelected ? emojiData.$2 : AppColors.dv(context),
                              width: isSelected ? 2 : 0.5,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: emojiData.$2.withValues(alpha: 0.2), blurRadius: 12)]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(emojiData.$1,
                                  style: TextStyle(
                                      fontSize: isSelected ? 36 : 30)),
                              const SizedBox(height: 6),
                              Text(label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700 : FontWeight.w600,
                                    color: isSelected
                                        ? emojiData.$2 : AppColors.ts(context),
                                  )),
                            ],
                          ),
                        ),
                      ).animateSafe(context)
                          .fadeIn(delay: (index * 40).ms, duration: 300.ms)
                          .scale(begin: const Offset(0.9, 0.9),
                              end: const Offset(1.0, 1.0),
                              delay: (index * 40).ms, duration: 300.ms);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.addNoteOptional,
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600,
                          color: AppColors.tp(context))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.writeAboutToday,
                      hintStyle: TextStyle(color: AppColors.ts(context)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.dv(context))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2)),
                    ),
                  ).animateSafe(context).fadeIn(delay: 500.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedMood != null ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.dv(context),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(l10n.save,
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_selectedMood == null) return;
    final mood = MoodEntry(
      type: _selectedMood!,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );
    await ref.read(dailyLogProvider.notifier).updateMood(DateTime.now(), mood);
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.moodSaved),
            backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    }
  }
}
