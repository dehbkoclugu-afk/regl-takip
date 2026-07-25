import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/cycle_utils.dart';
import '../../../core/utils/enum_labels.dart';
import '../../../core/utils/motion.dart';
import '../../../core/utils/phase_pattern.dart';
import '../../../core/utils/ring_segments.dart';
import '../../../core/widgets/phase_glyph.dart';

export '../../../core/utils/ring_segments.dart' show RingSegment, ringSegmentsFor;

class CycleProgressRing extends StatefulWidget {
  final int cycleDay;
  final int cycleLength;
  final int periodLength;
  final CyclePhase phase;
  final int daysUntilNextPeriod;

  /// Tahmini tarihin kaç gün geçtiği; gecikme yoksa 0. Gecikme kendi
  /// diline sahip olmalı: rozet "bugün!" derken kullanıcı üç gündür
  /// bekliyor olabiliyordu.
  final int delayDays;

  /// Segment dokunuşunda tarih aralığı gösterebilmek için: döngü günü 1'in
  /// takvim karşılığı. null ise gün numarası aralığı gösterilir.
  final DateTime? lastPeriodStart;

  /// Renk körü dostu doku modu: segmentlere faz başına farklı kesik
  /// çizgi deseni biner (renk + doku çift kodlama)
  final bool patterned;

  const CycleProgressRing({
    super.key,
    required this.cycleDay,
    required this.cycleLength,
    this.periodLength = 5,
    required this.phase,
    required this.daysUntilNextPeriod,
    this.delayDays = 0,
    this.lastPeriodStart,
    this.patterned = false,
  });

  @override
  State<CycleProgressRing> createState() => _CycleProgressRingState();
}

class _CycleProgressRingState extends State<CycleProgressRing> {
  static const _size = 264.0;

  /// Dokunuşla seçilen segment; null = normal merkez içerik
  RingSegment? _selected;
  bool _focused = false;
  Timer? _revertTimer;

  @override
  void dispose() {
    _revertTimer?.cancel();
    super.dispose();
  }

  /// Daha koyu/doygun ring rengi - arka plandan ayrışması için
  Color get _ringColor {
    switch (widget.phase) {
      case CyclePhase.menstrual:
        return AppColors.ringMenstrual;
      case CyclePhase.follicular:
        return AppColors.ringFollicular;
      case CyclePhase.ovulation:
        return AppColors.ringOvulation;
      case CyclePhase.luteal:
        return AppColors.ringLuteal;
    }
  }

  /// Merkezdeki METİN için renk: açık zeminde ring tonları (özellikle
  /// folliküler/luteal turuncu-amber) 3:1'in bile altında kalıyordu —
  /// açık temada koyulaştırılmış metin tonu, koyu temada ring tonu.
  Color _textColor(bool isDark) {
    if (isDark) return _ringColor;
    switch (widget.phase) {
      case CyclePhase.menstrual:
        return AppColors.menstrualText;
      case CyclePhase.follicular:
        return AppColors.follicularText;
      case CyclePhase.ovulation:
        return AppColors.ovulationText;
      case CyclePhase.luteal:
        return AppColors.lutealText;
    }
  }

  /// Segment rengi -> okunur metin tonu (açık tema); koyu temada rengin kendisi
  Color _segmentTextColor(RingSegment s, bool isDark) {
    if (isDark) return s.color;
    if (s.color == AppColors.ringMenstrual) return AppColors.menstrualText;
    if (s.color == AppColors.ringFollicular) return AppColors.follicularText;
    if (s.color == AppColors.ringFertile) return AppColors.fertileWindowText;
    return AppColors.lutealText;
  }

  String _segmentName(RingSegment s, AppLocalizations l10n) {
    if (s.color == AppColors.ringMenstrual) return l10n.menstrualPhase;
    if (s.color == AppColors.ringFollicular) return l10n.follicularPhase;
    if (s.color == AppColors.ringFertile) return l10n.fertileWindow;
    return l10n.lutealPhase;
  }

  void _handleTap(TapUpDetails details, List<RingSegment> segments) {
    final local = details.localPosition;
    const center = Offset(_size / 2, _size / 2);
    final d = local - center;
    final dist = d.distance;
    // Merkez içerik alanı dışındaki HER dokunuş segment seçer — dar bant
    // hedefi parmakla tutturmak zordu, "çalışmıyor" hissi veriyordu
    if (dist < 62) {
      _clearSelection();
      return;
    }
    // Açı -> döngü günü: gün 1 saat 12'den başlar, saat yönünde
    var angle = math.atan2(d.dy, d.dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;
    final day =
        (angle / (2 * math.pi) * widget.cycleLength).floor() + 1;
    final hit = segments.where(
        (s) => day >= s.startDay && day <= s.endDay);
    if (hit.isEmpty) return;
    _toggleSelection(hit.first);
  }

  void _toggleSelection(RingSegment segment) {
    if (_selected == segment) {
      _clearSelection();
      return;
    }
    setState(() => _selected = segment);
    _revertTimer?.cancel();
    _revertTimer = Timer(const Duration(seconds: 5), _clearSelection);
  }

  void _toggleCurrentSelection(List<RingSegment> segments) {
    final current = segments.firstWhere(
      (segment) =>
          widget.cycleDay >= segment.startDay &&
          widget.cycleDay <= segment.endDay,
      orElse: () => segments.last,
    );
    _toggleSelection(current);
  }

  void _clearSelection() {
    _revertTimer?.cancel();
    if (_selected != null && mounted) setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = AppColors.isDark(context);
    final motion = context.motionEnabled;
    final segments =
        ringSegmentsFor(widget.cycleLength, widget.periodLength);

    // Faz değişiminde (ör. "Reglim başladı") ışıma ve merkez renkleri
    // atlamaz, yeni faza yumuşakça akar — motion bütçesi asıl bu ana
    final phaseShift =
        context.motionDuration(const Duration(milliseconds: 600));

    final ring = AnimatedContainer(
      duration: phaseShift,
      curve: Curves.easeOutQuart,
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? Colors.black.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.65),
        border: Border.all(
          color: _focused
              ? (isDark ? AppColors.primaryLight : AppColors.primaryDeep)
              : isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.8),
          width: _focused ? 3 : 1.5,
        ),
        // Hero ışıması: yalnız ring'de — yumuşak, faz renginde hale.
        // Gece sahnesinde kısık: karanlık odada parlama rahatsız eder.
        boxShadow: [
          BoxShadow(
            color: _ringColor.withValues(alpha: isDark ? 0.10 : 0.18),
            blurRadius: isDark ? 20 : 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _SegmentedRingPainter(
          segments: segments,
          cycleLength: widget.cycleLength,
          todayDay: widget.cycleDay,
          ovulationDay: CycleUtils.ovulationDayNumber(widget.cycleLength),
          trackColor: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          highlighted: _selected,
          patterned: widget.patterned,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration:
                context.motionDuration(const Duration(milliseconds: 200)),
            child: _selected == null
                ? _buildCenterContent(l10n, context)
                : _buildSegmentDetail(l10n, context, _selected!, isDark),
          ),
        ),
      ),
    );

    // Ring artık dokunulabilir harita: segmente dokun -> faz + tarih aralığı
    final tappable = FocusableActionDetector(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _toggleCurrentSelection(segments);
            return null;
          },
        ),
      },
      onShowFocusHighlight: (focused) {
        if (_focused != focused) setState(() => _focused = focused);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => _handleTap(details, segments),
        child: ring,
      ),
    );

    // Ekran okuyucu için ring tek bir özet olarak duyurulur.
    //
    // Etiket gördüğünün aynısını söylemeli: faz adı hiç duyurulmuyordu
    // (ring'in ortasındaki glif ve renk görene faz bilgisi veriyor) ve
    // gecikmede "bugün!" deniyordu — rozet metni gecikmeyi gösterirken
    // ekran okuyucu üç gündür bekleyen kullanıcıya yanlış bilgi veriyordu.
    final status = widget.delayDays > 0
        ? l10n.delayDays(widget.delayDays)
        : (widget.daysUntilNextPeriod > 0
            ? l10n.daysLater(widget.daysUntilNextPeriod)
            : l10n.todayExclamation);
    final labeled = Semantics(
      button: true,
      onTap: () => _toggleCurrentSelection(segments),
      label: '${EnumLabels.phase(widget.phase, l10n)}. '
          '${l10n.cycleDay}: ${widget.cycleDay} / ${widget.cycleLength}. '
          '$status',
      child: ExcludeSemantics(child: tappable),
    );

    if (!motion) return labeled;
    return labeled
        .animateSafe(context)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
          curve: Curves.easeOutQuart,
        )
        .fadeIn(duration: 500.ms);
  }

  /// Segment dokunuş detayı: faz adı + takvimdeki karşılığı.
  /// Görsel imzanın etkileşim imzasına dönüşen hali.
  Widget _buildSegmentDetail(AppLocalizations l10n, BuildContext context,
      RingSegment s, bool isDark) {
    final textColor = _segmentTextColor(s, isDark);
    String range;
    final start = widget.lastPeriodStart;
    if (start != null) {
      final locale = Localizations.localeOf(context).toString();
      final fmt = DateFormat('d MMM', locale);
      final from = start.add(Duration(days: s.startDay - 1));
      final to = start.add(Duration(days: s.endDay - 1));
      range = s.startDay == s.endDay
          ? fmt.format(from)
          : '${fmt.format(from)} – ${fmt.format(to)}';
    } else {
      range = '${l10n.day} ${s.startDay}–${s.endDay}';
    }
    return Column(
      key: ValueKey(s.startDay),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(shape: BoxShape.circle, color: s.color),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _segmentName(s, l10n),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          range,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.tp(context),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${s.endDay - s.startDay + 1} ${l10n.days}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.ts(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterContent(AppLocalizations l10n, BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textColor = _textColor(isDark);
    final phaseShift =
        context.motionDuration(const Duration(milliseconds: 600));
    // Gecikmede rozet kendi rengini ve metnini alır: aynı kabuk içinde
    // "bugün!" demek, üç gündür bekleyen kullanıcıya yanlış bilgiydi
    final delayed = widget.delayDays > 0;
    final badgeColor = delayed
        ? (isDark ? AppColors.warning : AppColors.warningText)
        : _ringColor;
    return Column(
      key: const ValueKey('center'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Özel faz glifi: Material genel setinden markanın alfabesine
        PhaseGlyph(phase: widget.phase, size: 24, color: _ringColor),
        const SizedBox(height: 6),
        AnimatedDefaultTextStyle(
          duration: phaseShift,
          curve: Curves.easeOutQuart,
          // Metrik ölçeği temadan (tabular w800) — kahraman sayı dili
          style: Theme.of(context)
              .textTheme
              .displayLarge!
              .copyWith(color: textColor),
          child: Text('${widget.cycleDay}'),
        ),
        const SizedBox(height: 2),
        Text(
          l10n.day,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.tp(context),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: phaseShift,
          curve: Curves.easeOutQuart,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: AnimatedDefaultTextStyle(
            duration: phaseShift,
            curve: Curves.easeOutQuart,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: delayed ? badgeColor : textColor,
            ),
            child: Text(
              delayed
                  ? l10n.delayDays(widget.delayDays)
                  : (widget.daysUntilNextPeriod > 0
                      ? l10n.daysLater(widget.daysUntilNextPeriod)
                      : l10n.todayExclamation),
            ),
          ),
        ),
      ],
    );
  }
}

class _SegmentedRingPainter extends CustomPainter {
  final List<RingSegment> segments;
  final int cycleLength;
  final int todayDay;
  final int ovulationDay;
  final Color trackColor;

  /// Dokunuşla seçilen segment: kalınlaşarak "seni duydum" der
  final RingSegment? highlighted;

  /// Renk körü dostu doku: faz başına farklı kesik çizgi overlay'i
  final bool patterned;

  static const _stroke = 16.0;
  static const _inset = 22.0; // dış kenardan yay merkezine mesafe
  static const _gapRadians = 0.035; // segmentler arası nefes boşluğu

  _SegmentedRingPainter({
    required this.segments,
    required this.cycleLength,
    required this.todayDay,
    required this.ovulationDay,
    required this.trackColor,
    this.highlighted,
    this.patterned = false,
  });

  /// Gün -> açı: gün 1 üstten (saat 12) başlar, saat yönünde ilerler.
  /// Bir günün yay aralığı [dayStartAngle(d), dayStartAngle(d+1)).
  double _dayStartAngle(int day) =>
      -math.pi / 2 + (day - 1) / cycleLength * 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - _inset;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Zemin izi
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    // Faz segmentleri
    for (final segment in segments) {
      final start = _dayStartAngle(segment.startDay) + _gapRadians / 2;
      final end = _dayStartAngle(segment.endDay + 1) - _gapRadians / 2;
      if (end <= start) continue;
      final isHighlighted = identical(segment, highlighted) ||
          (highlighted != null &&
              segment.startDay == highlighted!.startDay &&
              segment.endDay == highlighted!.endDay);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHighlighted ? _stroke + 5 : _stroke
        ..strokeCap = StrokeCap.round
        ..color = segment.color;
      canvas.drawArc(rect, start, end - start, false, paint);

      // Doku modu: renk + desen çift kodlama (renk körü erişilebilirliği)
      if (patterned) {
        final intervals = dashIntervalsFor(segment.color);
        if (intervals != null) {
          canvas.drawPath(
            dashArc(rect, start, end - start, intervals),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..strokeCap = StrokeCap.round
              ..color = Colors.white.withValues(alpha: 0.65),
          );
        }
      }
    }

    // Ovülasyon işareti: bandın içinde koyu mor nokta
    final ovAngle = _dayStartAngle(ovulationDay) +
        math.pi / cycleLength; // gün ortası
    final ovCenter = Offset(
      center.dx + radius * math.cos(ovAngle),
      center.dy + radius * math.sin(ovAngle),
    );
    canvas.drawCircle(
        ovCenter, 5, Paint()..color = AppColors.ringOvulation);

    // Bugün işareti: beyaz halkalı nokta — haritada "buradasın"
    final todayAngle =
        _dayStartAngle(todayDay.clamp(1, cycleLength)) +
            math.pi / cycleLength;
    final todayCenter = Offset(
      center.dx + radius * math.cos(todayAngle),
      center.dy + radius * math.sin(todayAngle),
    );
    canvas.drawCircle(todayCenter, 9, Paint()..color = Colors.white);
    canvas.drawCircle(
        todayCenter,
        6,
        Paint()
          ..color = segments
              .firstWhere(
                (s) => todayDay >= s.startDay && todayDay <= s.endDay,
                orElse: () => segments.last,
              )
              .color);
  }

  @override
  bool shouldRepaint(_SegmentedRingPainter oldDelegate) =>
      oldDelegate.todayDay != todayDay ||
      oldDelegate.cycleLength != cycleLength ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.highlighted != highlighted ||
      oldDelegate.patterned != patterned;
}
