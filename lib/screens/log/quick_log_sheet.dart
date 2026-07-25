import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/adaptive_layout.dart';
import '../../core/utils/enum_labels.dart';
import '../../core/utils/symptom_ranking.dart';
import '../../models/enums.dart';
import '../../models/period_record.dart';
import '../../providers/providers.dart';

/// Günlük kaydın %90'ı için tek sheet: akış + semptom + mood.
/// Detay isteyen "Tüm kayıt türleri" ile log ekranına iner.
/// Mevcut log prefill edilir; kaydet üçünü birden yazar.
Future<void> showQuickLogSheet(
  BuildContext context,
  WidgetRef ref,
  DateTime date,
) {
  // Sheet açılırken tarih provider'a yazılır: "tüm kayıt türleri"
  // yolundan gidilen tracker'lar da aynı güne yazar
  ref.read(selectedDateProvider.notifier).state = date;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _QuickLogSheet(date: date),
  );
}

class _QuickLogSheet extends ConsumerStatefulWidget {
  final DateTime date;
  const _QuickLogSheet({required this.date});

  @override
  ConsumerState<_QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends ConsumerState<_QuickLogSheet> {
  /// Sheet açıldığı güne çakılı değil: akşam uygulamayı açıp dünü girmek
  /// tipik davranıştı ama sheet içinde gün değiştirilemiyordu — kullanıcı
  /// kapatıp takvime inmek zorundaydı.
  late DateTime _date;

  FlowIntensity? _flow;
  MoodType? _mood;
  final Map<SymptomType, int> _symptoms = {};
  final TextEditingController _noteController = TextEditingController();

  /// Sheet'te gösterilen en sık semptomlar; tamamı semptom ekranında
  static const _commonSymptoms = [
    SymptomType.cramp,
    SymptomType.headache,
    SymptomType.bloating,
    SymptomType.fatigue,
    SymptomType.backPain,
    SymptomType.breastTenderness,
    SymptomType.acne,
    SymptomType.stress,
  ];

  @override
  void initState() {
    super.initState();
    _date = widget.date;
    _loadFor(_date);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Seçili günün kaydını forma yükler.
  void _loadFor(DateTime date) {
    final log = ref.read(dailyLogProvider.notifier).getDailyLog(date);
    _flow = log?.flowIntensity;
    _mood = log?.mood?.type;
    _symptoms.clear();
    for (final s in log?.symptoms ?? const <SymptomEntry>[]) {
      _symptoms[s.type] = s.severity;
    }
    _noteController.text = log?.notes ?? '';
  }

  /// Formdaki hâli [date] gününe yazar. Hiçbir şey girilmemişse ve o güne
  /// ait kayıt da yoksa dokunmaz: boş günlük, takvimde "kayıt var" noktası
  /// çıkarıyordu.
  /// Yazma gerçekleştiyse true.
  Future<bool> _persist(DateTime date) async {
    final notifier = ref.read(dailyLogProvider.notifier);
    final note = _noteController.text.trim();
    final hasExistingLog = notifier.getDailyLog(date) != null;
    final hasInput =
        _flow != null ||
        _mood != null ||
        _symptoms.isNotEmpty ||
        note.isNotEmpty;
    if (!hasInput && !hasExistingLog) return false;

    // setFlowIntensity: seçim kaldırıldığında akış da silinmeli.
    // updateFlow null'ı "dokunma" sayıyor, eski değer kalıyordu.
    await notifier.setFlowIntensity(date, _flow);
    await notifier.updateMood(
      date,
      _mood != null ? MoodEntry(type: _mood!) : null,
    );
    await notifier.updateSymptoms(
      date,
      _symptoms.entries
          .map((e) => SymptomEntry(type: e.key, severity: e.value))
          .toList(),
    );
    await notifier.updateNotes(date, note.isEmpty ? null : note);
    return true;
  }

  /// Gün değiştirir. Ekrandaki hâl önce mevcut güne yazılır: kullanıcı
  /// "dünü girdim, şimdi bugüne geçeyim" derken girdisini kaybetmemeli.
  Future<void> _switchDay(int deltaDays) async {
    final target = DateTime(_date.year, _date.month, _date.day + deltaDays);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (target.isAfter(today)) return;

    await _persist(_date);
    if (!mounted) return;
    setState(() {
      _date = target;
      _loadFor(target);
    });
    // "Tüm kayıt türleri" yolundan gidilen tracker'lar da bu güne yazsın
    ref.read(selectedDateProvider.notifier).state = target;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final wrote = await _persist(_date);
    if (!mounted) return;
    navigator.pop();
    // Hiçbir şey yazılmadıysa "Kaydedildi" demek yanlış bilgi
    if (!wrote) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.savedGeneric),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateStr = DateFormat('d MMMM, EEEE', locale).format(_date);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final canGoForward = _date.isBefore(today);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.sf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.dv(context), width: 1),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dv(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.quickLog,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.tp(context),
                ),
              ),
              const SizedBox(height: 4),
              // Gün gezinmesi: sheet açıldığı güne çakılıydı, dünü girmek
              // için kapatıp takvime inmek gerekiyordu
              Row(
                children: [
                  IconButton(
                    onPressed: () => _switchDay(-1),
                    icon: const Icon(Icons.chevron_left_rounded),
                    tooltip: l10n.previousDay,
                    color: AppColors.ts(context),
                  ),
                  Expanded(
                    child: Text(
                      dateStr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tp(context),
                      ),
                    ),
                  ),
                  IconButton(
                    // Gelecek gün kaydı anlamsız
                    onPressed: canGoForward ? () => _switchDay(1) : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                    tooltip: l10n.nextDay,
                    color: AppColors.ts(context),
                    disabledColor: AppColors.dv(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Akış şiddeti
              _sectionLabel(l10n.flow),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = adaptiveGridColumns(
                    width: constraints.maxWidth,
                    textScale: effectiveTextScale(
                      MediaQuery.textScalerOf(context),
                    ),
                    maxColumns: 4,
                    minCardWidth: 64,
                    spacing: 8,
                  );
                  final optionWidth =
                      (constraints.maxWidth - (columns - 1) * 8) / columns;
                  final options = [
                    (FlowIntensity.light, l10n.light, 1),
                    (FlowIntensity.normal, l10n.medium, 2),
                    (FlowIntensity.heavy, l10n.heavy, 3),
                    (FlowIntensity.veryHeavy, l10n.veryHeavy, 4),
                  ];
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in options)
                        SizedBox(
                          width: optionWidth,
                          child:
                              _flowOption(option.$1, option.$2, option.$3),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Mood
              _sectionLabel(l10n.mood),
              const SizedBox(height: 8),
              SizedBox(
                height: usesLargeText(MediaQuery.textScalerOf(context))
                    ? 72
                    : 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: MoodType.values.map((m) {
                    final selected = _mood == m;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _chip(
                        label: EnumLabels.mood(m, l10n),
                        selected: selected,
                        onTap: () =>
                            setState(() => _mood = selected ? null : m),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Semptomlar — sık girilenler önde (liste kullanıldıkça
              // kişiselleşir, seçenek kümesi daralmaz)
              _sectionLabel(l10n.symptoms),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    SymptomRanking.reorder(
                      _commonSymptoms,
                      ref.read(dailyLogProvider).values,
                    ).map((s) {
                      final selected = _symptoms.containsKey(s);
                      final severity = _symptoms[s] ?? 2;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _chip(
                            label: EnumLabels.symptom(s, l10n),
                            selected: selected,
                            onTap: () => setState(() {
                              if (selected) {
                                _symptoms.remove(s);
                              } else {
                                _symptoms[s] = 2;
                              }
                            }),
                          ),
                          if (selected)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                5,
                                (index) => Semantics(
                                  button: true,
                                  selected: index < severity,
                                  label: l10n.severityLevel(index + 1),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () => setState(
                                      () => _symptoms[s] = index + 1,
                                    ),
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: Icon(
                                        index < severity
                                            ? Icons.circle
                                            : Icons.circle_outlined,
                                        size: 11,
                                        color: AppColors.primaryStrong,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),

              // Not: en sık girilen dördüncü alandı ama "tüm kayıt
              // türleri"nin arkasında duruyordu
              _sectionLabel(l10n.notes),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(fontSize: 14, color: AppColors.tp(context)),
                decoration: InputDecoration(
                  hintText: l10n.notesHint,
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppColors.ts(context),
                  ),
                  filled: true,
                  fillColor: AppColors.bg(context),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _save, child: Text(l10n.save)),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/log');
                  },
                  child: Text(
                    l10n.allTrackers,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.ts(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.ts(context),
      ),
    );
  }

  Widget _flowOption(FlowIntensity intensity, String label, int drops) {
    final selected = _flow == intensity;
    return Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.menstrual.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primaryStrong : AppColors.dv(context),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _flow = selected ? null : intensity),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        drops,
                        (_) => Icon(
                          Icons.water_drop_rounded,
                          size: 10,
                          color: selected
                              ? AppColors.primaryStrong
                              : AppColors.ts(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.primaryStrong
                            : AppColors.ts(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? AppColors.primaryStrong.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            // Material minimum dokunma hedefi 48 dp: chip'ler 33 px idi
            constraints: const BoxConstraints(minHeight: 44),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? AppColors.primaryStrong
                    : AppColors.dv(context),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? AppColors.primaryStrong
                    : AppColors.tp(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
