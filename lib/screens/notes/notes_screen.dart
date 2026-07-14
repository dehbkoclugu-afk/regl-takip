import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/providers.dart';
import '../../core/utils/motion.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _controller = TextEditingController();
  static const int _maxChars = 2000;
  String _initialText = '';
  bool _dirty = false;

  bool get _isDirty => _controller.text != _initialText;

  @override
  void initState() {
    super.initState();
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(ref.read(selectedDateProvider));
    if (log?.notes != null) {
      _controller.text = log!.notes!;
      _initialText = log.notes!;
    }
  }

  /// Not yazıp kaydetmeden geri dönmek metni sessizce çöpe atıyordu
  Future<bool> _confirmDiscard() async {
    if (!_isDirty) return true;
    final l10n = AppLocalizations.of(context)!;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    return discard == true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard()) navigator.pop();
      },
      child: Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(l10n.dailyNote,
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
              child: GlassCard(
                borderRadius: 20,
                blur: 0,
                opacity: 0.15,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note_rounded,
                            color: AppColors.notesColor, size: 22),
                        const SizedBox(width: 8),
                        Text(l10n.myNotes,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold,
                                color: AppColors.tp(context))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      maxLines: 14,
                      maxLength: _maxChars,
                      // Karakter sayacını TextField kendi güncelliyor; her
                      // tuşta tüm ekranı yeniden kurmak gereksizdi. Yalnız
                      // "kaydedilmemiş değişiklik" durumu değişince rebuild.
                      onChanged: (_) {
                        if (_isDirty != _dirty) {
                          setState(() => _dirty = _isDirty);
                        }
                      },
                      style: TextStyle(
                          fontSize: 15, color: AppColors.tp(context),
                          height: 1.5),
                      decoration: InputDecoration(
                        hintText: l10n.notesHint,
                        hintStyle: TextStyle(
                            color: AppColors.ts(context)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.dv(context))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.notesColor, width: 2)),
                        counterStyle: TextStyle(
                            fontSize: 12, color: AppColors.ts(context)),
                      ),
                    ),
                  ],
                ),
              ).animateSafe(context).fadeIn(duration: 500.ms)
                  .slideY(begin: 0.1, end: 0, duration: 500.ms),
            ),
          ),
          _buildSaveButton(l10n),
        ],
      ),
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
            backgroundColor: AppColors.notesColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(l10n.save,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(dailyLogProvider.notifier);
    final date = ref.read(selectedDateProvider);
    final text = _controller.text.trim();

    // Boş notu boş güne yazmak sahte "kayıt var" işareti bırakıyordu
    if (text.isEmpty && notifier.getDailyLog(date) == null) {
      _initialText = '';
      if (mounted) Navigator.of(context).pop();
      return;
    }

    await notifier.updateNotes(date, text.isEmpty ? null : text);
    // Kaydettikten sonra "kaydedilmemiş değişiklik" uyarısı çıkmasın
    _initialText = _controller.text;
    _dirty = false;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noteSaved),
            backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    }
  }
}
