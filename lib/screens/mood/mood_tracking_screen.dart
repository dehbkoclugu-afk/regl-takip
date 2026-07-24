import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/enum_labels.dart';
import '../../core/widgets/tracker_scaffold.dart';
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

  /// Ekrana kayıtlı bir ruh haliyle girildiyse true. Kullanıcı seçimi
  /// kaldırdığında "Kaydet" kapanmamalı — silme de bir kayıttır.
  bool _hadExistingMood = false;

  // Dirty-guard için giriş anındaki durum
  MoodType? _initialMood;
  String _initialNote = '';
  bool _noteDirty = false;

  bool get _isDirty =>
      _selectedMood != _initialMood ||
      _noteController.text.trim() != _initialNote;

  @override
  void initState() {
    super.initState();
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(ref.read(selectedDateProvider));
    if (log?.mood != null) {
      _selectedMood = log!.mood!.type;
      _noteController.text = log.mood!.note ?? '';
      _hadExistingMood = true;
    }
    _initialMood = _selectedMood;
    _initialNote = _noteController.text.trim();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TrackerScaffold(
      title: l10n.mood,
      isDirty: _isDirty,
      body: SingleChildScrollView(
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
                      // Etiketler tek kaynaktan (EnumLabels); ekranın kendi
                      // kopya map'i vardı
                      final label = EnumLabels.mood(mood, l10n);
                      final isSelected = _selectedMood == mood;

                      return Semantics(
                        button: true,
                        selected: isSelected,
                        label: label,
                        child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => setState(() =>
                            _selectedMood = _selectedMood == mood ? null : mood),
                        child: ExcludeSemantics(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [emojiData.$2.withValues(alpha: 0.2), emojiData.$2.withValues(alpha: 0.08)],
                                  )
                                : null,
                            color: isSelected ? null : AppColors.sf(context),
                            borderRadius: BorderRadius.circular(20),
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
                    // Dirty durumu değiştiğinde PopScope tazelenmeli; her
                    // tuş vuruşunda değil, yalnız bayrak dönünce rebuild
                    onChanged: (_) {
                      final dirty = _isDirty;
                      if (dirty != _noteDirty) {
                        setState(() => _noteDirty = dirty);
                      }
                    },
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
      bottomBar: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          // Kayıtlı ruh hali varken seçim kaldırılırsa kaydetmek
          // silme anlamına gelir — buton kapanmamalı
          onPressed:
              (_selectedMood != null || _hadExistingMood) ? _save : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryStrong,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.dv(context),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(l10n.save,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final selected = _selectedMood;
    final mood = selected == null
        ? null
        : MoodEntry(
            type: selected,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
    await ref
        .read(dailyLogProvider.notifier)
        .updateMood(ref.read(selectedDateProvider), mood);
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
