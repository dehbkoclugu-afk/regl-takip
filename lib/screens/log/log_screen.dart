import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/enum_labels.dart';
import '../../models/daily_log.dart';
import '../../providers/providers.dart';
import '../../core/utils/motion.dart';
import '../flow/flow_tracking_screen.dart';
import '../medication/medication_tracking_screen.dart';
import '../mood/mood_tracking_screen.dart';
import '../notes/notes_screen.dart';
import '../sexual_activity/sexual_activity_screen.dart';
import '../sleep/sleep_tracking_screen.dart';
import '../symptoms/symptom_tracking_screen.dart';
import '../temperature/temperature_tracking_screen.dart';
import '../water/water_tracking_screen.dart';
import '../weight/weight_tracking_screen.dart';

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
    // Takvimden gün seçilerek gelindiyse o gün açılır
    final fromCalendar = ref.read(selectedDateProvider);
    final now = DateTime.now();
    _selectedDate = fromCalendar.isAfter(now) ? now : fromCalendar;
    _buildWeekDates();
  }

  /// Hafta şeridi seçili günü son eleman olarak gösterir (geçmiş güne
  /// gidildiğinde şerit o güne kayar); bugünden ileri gitmez.
  void _buildWeekDates() {
    final anchor =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    _weekDates =
        List.generate(7, (i) => anchor.subtract(Duration(days: 6 - i)));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _buildWeekDates();
    });
    ref.read(selectedDateProvider.notifier).state = picked;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dailyLogs = ref.watch(dailyLogProvider);
    final dateKey =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final log = dailyLogs[dateKey];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logBg = isDark
        ? const Color(0xFF1A1020)
        : const Color(0xFFEDE0F0);

    return Scaffold(
      backgroundColor: logBg,
      appBar: AppBar(
        title: Text(l10n.dailyLog,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.tp(context))),
        backgroundColor: logBg,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.tp(context)),
        actions: [
          IconButton(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: MaterialLocalizations.of(context).dateInputLabel,
          ),
        ],
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

          final locale = Localizations.localeOf(context).toString();
          return Semantics(
            button: true,
            selected: isSelected,
            label: DateFormat('d MMMM EEEE', locale).format(date),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() => _selectedDate = date);
                // Kategori ekranları bu provider'daki güne kayıt yazar
                ref.read(selectedDateProvider.notifier).state = date;
              },
              child: ExcludeSemantics(
                child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      )
                    : null,
                color: isSelected ? null : AppColors.sf(context),
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5)
                    : null,
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', Localizations.localeOf(context).toString()).format(date).substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white70 : AppColors.ts(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.tp(context),
                    ),
                  ),
                ],
              ),
                ),
              ),
            ),
          ).animateSafe(context).fadeIn(delay: (index * 50).ms, duration: 300.ms);
        },
      ),
    );
  }

  Widget _buildCategoryGrid(DailyLog? log, AppLocalizations l10n) {
    final categories = [
      _CategoryItem(Icons.water_drop_rounded, l10n.flow, AppColors.menstrual,
          _getFlowSummary(log, l10n), '/flow',
          (_) => const FlowTrackingScreen()),
      _CategoryItem(Icons.face_rounded, l10n.symptoms, AppColors.secondary,
          _getSymptomSummary(log, l10n), '/symptoms',
          (_) => const SymptomTrackingScreen()),
      _CategoryItem(Icons.mood_rounded, l10n.mood, AppColors.moodHappy,
          _getMoodSummary(log, l10n), '/mood',
          (_) => const MoodTrackingScreen()),
      _CategoryItem(Icons.thermostat_rounded, l10n.temperature,
          AppColors.temperature, _getTempSummary(log), '/temperature',
          (_) => const TemperatureTrackingScreen()),
      _CategoryItem(Icons.monitor_weight_rounded, l10n.weight,
          AppColors.weightColor, _getWeightSummary(log), '/weight',
          (_) => const WeightTrackingScreen()),
      _CategoryItem(Icons.local_drink_rounded, l10n.waterIntake,
          AppColors.water, _getWaterSummary(log, l10n), '/water',
          (_) => const WaterTrackingScreen()),
      _CategoryItem(Icons.bedtime_rounded, l10n.sleep, AppColors.sleep,
          _getSleepSummary(log), '/sleep',
          (_) => const SleepTrackingScreen()),
      _CategoryItem(Icons.favorite_rounded, l10n.sexualActivity,
          AppColors.moodRomantic, _getSexualSummary(log, l10n),
          '/sexual-activity', (_) => const SexualActivityScreen()),
      _CategoryItem(Icons.medication_rounded, l10n.medication,
          AppColors.medication, _getMedSummary(log, l10n), '/medication',
          (_) => const MedicationTrackingScreen()),
      _CategoryItem(Icons.edit_note_rounded, l10n.notes, AppColors.notesColor,
          _getNotesSummary(log), '/notes', (_) => const NotesScreen()),
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
        final motion = context.motionEnabled;
        // Container transform: kart, açılan ekranın kendisine BÜYÜR —
        // "bu ekran o karttan çıktı" mekânsal sürekliliği. Hareket
        // kısıtlıysa düz rota geçişi.
        final Widget card;
        if (motion) {
          card = OpenContainer(
            transitionDuration: const Duration(milliseconds: 350),
            transitionType: ContainerTransitionType.fadeThrough,
            closedElevation: 0,
            openElevation: 0,
            closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            closedColor: AppColors.sf(context),
            middleColor: AppColors.bg(context),
            openColor: AppColors.bg(context),
            openBuilder: (context, _) => cat.screenBuilder(context),
            closedBuilder: (context, open) => InkWell(
              onTap: open,
              child: _buildCategoryCardBody(cat),
            ),
          );
        } else {
          card = Material(
            color: AppColors.sf(context),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.push(cat.route),
              child: _buildCategoryCardBody(cat),
            ),
          );
        }
        return Semantics(
          button: true,
          label: cat.summary.isEmpty
              ? cat.label
              : '${cat.label}: ${cat.summary}',
          child: card,
        ).animateSafe(context)
            .fadeIn(delay: (index * 50).ms, duration: 300.ms)
            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1),
                delay: (index * 50).ms, duration: 300.ms);
      },
    );
  }

  Widget _buildCategoryCardBody(_CategoryItem cat) {
    return Padding(
                  padding: const EdgeInsets.all(14),
                  child: ExcludeSemantics(
                    child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cat.color.withValues(alpha: 0.25),
                        cat.color.withValues(alpha: 0.1),
                      ],
                    ),
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
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.tp(context),
                              ),
                              overflow: TextOverflow.ellipsis),
                          if (cat.summary.isNotEmpty)
                            Text(cat.summary,
                                style: TextStyle(
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
    );
  }

  // Özetler: enum -> etiket eşlemesi EnumLabels üzerinden. Daha önce
  // `labels[enum.index]` kullanılıyordu; enum'a değer eklendiğinde ya da
  // sıra değiştiğinde sessizce yanlış etiket (ya da RangeError) veriyordu.
  String _getFlowSummary(DailyLog? log, AppLocalizations l10n) {
    final flow = log?.flowIntensity;
    if (flow == null) return '';
    return EnumLabels.flow(flow, l10n);
  }

  String _getSymptomSummary(DailyLog? log, AppLocalizations l10n) {
    if (log == null || log.symptoms.isEmpty) return '';
    return l10n.nSymptoms(log.symptoms.length);
  }

  String _getMoodSummary(DailyLog? log, AppLocalizations l10n) {
    final mood = log?.mood;
    if (mood == null) return '';
    return EnumLabels.mood(mood.type, l10n);
  }

  String _getTempSummary(DailyLog? log) {
    final temp = log?.temperature;
    if (temp == null) return '';
    return '${temp.toStringAsFixed(1)}°C';
  }

  String _getWeightSummary(DailyLog? log) {
    final weight = log?.weight;
    if (weight == null) return '';
    return '${weight.toStringAsFixed(1)} kg';
  }

  String _getWaterSummary(DailyLog? log, AppLocalizations l10n) {
    if (log == null || log.waterIntake == 0) return '';
    return l10n.nGlasses(log.waterIntake);
  }

  String _getSleepSummary(DailyLog? log) {
    final start = log?.sleepStart;
    if (start == null) return '';
    return '$start - ${log!.sleepEnd ?? '?'}';
  }

  String _getSexualSummary(DailyLog? log, AppLocalizations l10n) {
    if (log?.sexualActivity == null) return '';
    return l10n.recorded;
  }

  String _getMedSummary(DailyLog? log, AppLocalizations l10n) {
    if (log == null || log.medications.isEmpty) return '';
    return l10n.nMedications(log.medications.length);
  }

  String _getNotesSummary(DailyLog? log) {
    final notes = log?.notes;
    if (notes == null || notes.isEmpty) return '';
    return notes.length > 20 ? '${notes.substring(0, 20)}...' : notes;
  }
}

class _CategoryItem {
  final IconData icon;
  final String label;
  final Color color;
  final String summary;

  /// Hareket kısıtlı kullanıcı için düz rota geçişi
  final String route;

  /// Container transform'un açtığı ekran (rota tablosuyla aynı ekranlar)
  final WidgetBuilder screenBuilder;

  _CategoryItem(this.icon, this.label, this.color, this.summary, this.route,
      this.screenBuilder);
}
