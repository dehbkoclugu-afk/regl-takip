import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/access.dart';
import '../../core/utils/note_search.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/tracker_scaffold.dart';
import '../../models/daily_log.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final noteLogs = filterNoteLogs(ref.watch(dailyLogProvider).values);
    final selectedDate = ref.watch(selectedDateProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();
    // Kaydedilmemiş değişiklik koruması artık ortak iskelette
    // (TrackerScaffold): buradaki özel PopScope+diyalog kopyası kalktı
    return TrackerScaffold(
      title: l10n.dailyNote,
      isDirty: _dirty,
      body: SingleChildScrollView(
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
                        Expanded(
                          child: Text(l10n.myNotes,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold,
                                  color: AppColors.tp(context))),
                        ),
                        if (noteLogs.isNotEmpty)
                          IconButton(
                            tooltip: MaterialLocalizations.of(context)
                                .searchFieldLabel,
                            onPressed:
                                _dirty ? null : () => _searchNotes(noteLogs),
                            icon: const Icon(Icons.manage_search_rounded),
                            color: AppColors.notesText,
                          ),
                      ],
                    ),
                    Text(
                      DateFormat.yMMMd(locale).format(selectedDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.ts(context),
                      ),
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
      bottomBar: _buildSaveButton(l10n),
    );
  }

  Future<void> _searchNotes(List<DailyLog> logs) async {
    final selected = await showSearch<DailyLog?>(
      context: context,
      delegate: _NoteSearchDelegate(logs),
    );
    if (selected == null || !mounted) return;
    ref.read(selectedDateProvider.notifier).state = selected.date;
    _controller.text = selected.notes ?? '';
    setState(() {
      _initialText = _controller.text;
      _dirty = false;
    });
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.notesColor,
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
    if (!ensureTrackingWriteAccess(context, ref)) return;
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
    notifyTrackingRecordSaved();
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

class _NoteSearchDelegate extends SearchDelegate<DailyLog?> {
  final List<DailyLog> logs;
  DateTimeRange? _range;

  _NoteSearchDelegate(this.logs);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
            onPressed: () => query = '',
            icon: const Icon(Icons.clear_rounded),
          ),
        if (_range != null)
          IconButton(
            tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
            onPressed: () {
              _range = null;
              showSuggestions(context);
            },
            icon: const Icon(Icons.filter_alt_off_rounded),
          ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).dateRangePickerHelpText,
          color: _range == null ? null : AppColors.notesText,
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              initialDateRange: _range,
            );
            if (picked == null || !context.mounted) return;
            _range = picked;
            showSuggestions(context);
          },
          icon: Icon(_range == null
              ? Icons.date_range_rounded
              : Icons.event_available_rounded),
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => close(context, null),
        icon: const BackButtonIcon(),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final results = filterNoteLogs(
      logs,
      query: query,
      start: _range?.start,
      end: _range?.end,
    );
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: l10n.notes,
            message: l10n.noDataYet,
            accent: AppColors.notesText,
          ),
        ),
      );
    }

    final locale = Localizations.localeOf(context).toLanguageTag();
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final log = results[index];
        return ListTile(
          minVerticalPadding: 12,
          leading: const Icon(Icons.note_alt_outlined,
              color: AppColors.notesText),
          title: Text(
            log.notes!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(DateFormat.yMMMd(locale).format(log.date)),
          onTap: () => close(context, log),
        );
      },
    );
  }
}
