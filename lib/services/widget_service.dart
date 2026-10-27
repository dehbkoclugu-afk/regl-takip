import 'dart:convert' show jsonEncode;
import 'dart:io' show File, Platform;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/cycle_utils.dart';
import '../core/utils/date_only.dart';
import '../core/utils/language_utils.dart';
import '../core/utils/ring_segments.dart';
import '../models/enums.dart';
import '../models/period_record.dart';
import '../models/user_profile.dart';
import 'disguise_service.dart';

enum WidgetPeriodActionDestination { wait, discard, startPeriod }

bool shouldShowWidgetPeriodAction({
  required bool onboardingCompleted,
  required bool disguised,
  required TrackingMode? trackingMode,
  required bool hasOngoingPeriod,
}) =>
    onboardingCompleted &&
    !disguised &&
    !hasOngoingPeriod &&
    (trackingMode == TrackingMode.period || trackingMode == TrackingMode.ttc);

String? widgetActionFromUri(Uri? uri) {
  if (uri?.scheme == 'regltakip' &&
      uri?.host == 'widget' &&
      uri?.path == '/period-start') {
    return WidgetService.periodStartAction;
  }
  return null;
}

WidgetPeriodActionDestination resolveWidgetPeriodAction({
  required String? action,
  required bool disguiseResolved,
  required bool disguised,
  required bool onboardingCompleted,
  required TrackingMode? trackingMode,
  required bool hasOngoingPeriod,
  required bool hasRecordToday,
  required bool locked,
  required bool appResumed,
  required bool navigatorReady,
}) {
  if (action != WidgetService.periodStartAction) {
    return WidgetPeriodActionDestination.discard;
  }
  if (!disguiseResolved || locked || !appResumed || !navigatorReady) {
    return WidgetPeriodActionDestination.wait;
  }
  if (!shouldShowWidgetPeriodAction(
        onboardingCompleted: onboardingCompleted,
        disguised: disguised,
        trackingMode: trackingMode,
        hasOngoingPeriod: hasOngoingPeriod,
      ) ||
      hasRecordToday) {
    return WidgetPeriodActionDestination.discard;
  }
  return WidgetPeriodActionDestination.startPeriod;
}

/// Android ana ekran widget'ını besler. Metinler Dart tarafında
/// lokalize edilip SharedPreferences üzerinden native provider'a geçer
/// (native tarafta l10n altyapısı yok).
class WidgetService {
  static const _androidProvider = 'CycleWidgetProvider';
  static const _androidWideProvider = 'CycleWideWidgetProvider';
  static const periodStartAction = 'period_start';

  static final ValueNotifier<String?> pendingAction = ValueNotifier(null);
  static bool _initialized = false;

  static const _strings = {
    'tr': {
      'daysLate': 'gün gecikme',
      'notes': 'Notlar',
      'day': 'Gün',
      'daysLeft': 'gün kaldı',
      'today': 'Bugün!',
      'week': 'hafta',
      'pill': 'Hap',
      'breakWeek': 'Ara hafta',
      'nextPeriod': 'Sonraki regl',
      'ovulation': 'Ovülasyon',
      'fertile': 'Verimli pencere',
      'periodStarted': 'Reglim başladı',
    },
    'en': {
      'daysLate': 'days late',
      'notes': 'Notes',
      'day': 'Day',
      'daysLeft': 'days left',
      'today': 'Today!',
      'week': 'Week',
      'pill': 'Pill',
      'breakWeek': 'Break week',
      'nextPeriod': 'Next period',
      'ovulation': 'Ovulation',
      'fertile': 'Fertile window',
      'periodStarted': 'My period started',
    },
    'es': {
      'daysLate': 'días de retraso',
      'notes': 'Notas',
      'day': 'Día',
      'daysLeft': 'días restantes',
      'today': '¡Hoy!',
      'week': 'Semana',
      'pill': 'Píldora',
      'breakWeek': 'Semana de descanso',
      'nextPeriod': 'Próxima regla',
      'ovulation': 'Ovulación',
      'fertile': 'Ventana fértil',
      'periodStarted': 'Mi regla empezó',
    },
    'de': {
      'daysLate': 'Tage überfällig',
      'notes': 'Notizen',
      'day': 'Tag',
      'daysLeft': 'Tage übrig',
      'today': 'Heute!',
      'week': 'Woche',
      'pill': 'Pille',
      'breakWeek': 'Pausenwoche',
      'nextPeriod': 'Nächste Periode',
      'ovulation': 'Eisprung',
      'fertile': 'Fruchtbares Fenster',
      'periodStarted': 'Periode hat begonnen',
    },
    'fr': {
      'daysLate': 'jours de retard',
      'notes': 'Notes',
      'day': 'Jour',
      'daysLeft': 'jours restants',
      'today': "Aujourd'hui !",
      'week': 'Semaine',
      'pill': 'Pilule',
      'breakWeek': 'Semaine de pause',
      'nextPeriod': 'Prochaines règles',
      'ovulation': 'Ovulation',
      'fertile': 'Fenêtre fertile',
      'periodStarted': 'Mes règles ont commencé',
    },
    'ru': {
      'daysLate': 'дн. задержки',
      'notes': 'Заметки',
      'day': 'День',
      'daysLeft': 'дн. осталось',
      'today': 'Сегодня!',
      'week': 'Неделя',
      'pill': 'Таблетка',
      'breakWeek': 'Неделя перерыва',
      'nextPeriod': 'След. месячные',
      'ovulation': 'Овуляция',
      'fertile': 'Фертильное окно',
      'periodStarted': 'Месячные начались',
    },
  };

  static String _t(String locale, String key) =>
      _strings[locale]?[key] ?? _strings['en']![key]!;

  static bool get _isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> init() async {
    if (_initialized || !_isSupported) return;
    try {
      _acceptUri(await HomeWidget.initiallyLaunchedFromHomeWidget());
      HomeWidget.widgetClicked.listen(_acceptUri);
      _initialized = true;
    } catch (e) {
      debugPrint('[WIDGET] click setup failed: $e');
    }
  }

  static void _acceptUri(Uri? uri) {
    final action = widgetActionFromUri(uri);
    if (action != null) pendingAction.value = action;
  }

  /// Widget'ın önceden hesaplandığı gün sayısı (bugün dahil).
  ///
  /// Native provider metni yalnız yeniden çiziyordu; uygulama açılmadıkça
  /// "Gün X / N gün kaldı" günlerce bayat kalıyordu. Dart her güncellemede
  /// önümüzdeki günlerin içeriğini de yazar, native taraf o günün satırını
  /// seçer (updatePeriodMillis ile gün içinde tazelenir).
  static const int precomputeDays = 7;

  /// Widget verisini günceller. Android dışında no-op.
  static Future<void> update(
    UserProfile? profile,
    List<PeriodRecord> records,
  ) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      final locale = resolveLanguageCode(profile?.language);

      // Gizli moddayken widget döngü verisi sızdırmamalı —
      // uygulama "Notlar" kılığındayken nötr içerik göster
      if (await DisguiseService.isDisguised()) {
        await HomeWidget.saveWidgetData<String>('line1', _t(locale, 'notes'));
        await HomeWidget.saveWidgetData<String>('line2', '');
        await HomeWidget.saveWidgetData<String>('ring_path', null);
        await HomeWidget.saveWidgetData<String>('daily', null);
        await HomeWidget.saveWidgetData<bool>(
            'period_action_visible', false);
        await HomeWidget.saveWidgetData<String>('period_action_label', '');
        await _savePredictions(null, null, null, null);
        await HomeWidget.updateWidget(androidName: _androidProvider);
        await HomeWidget.updateWidget(androidName: _androidWideProvider);
        return;
      }

      final now = DateTime.now();
      final days = <String, Map<String, String?>>{};
      for (var offset = 0; offset < precomputeDays; offset++) {
        final day = addDays(now, offset);
        days[_dayKey(day)] = await _snapshotFor(
          profile,
          records,
          locale,
          day,
          ringFile: 'cycle_widget_ring_$offset.png',
        );
      }
      final today = days[_dayKey(now)]!;

      final periodActionVisible = shouldShowWidgetPeriodAction(
        onboardingCompleted: profile?.onboardingCompleted == true,
        disguised: false,
        trackingMode: profile?.trackingMode,
        hasOngoingPeriod: records.any((record) => record.isOngoing),
      );
      await HomeWidget.saveWidgetData<String>('line1', today['line1']);
      await HomeWidget.saveWidgetData<String>('line2', today['line2']);
      await HomeWidget.saveWidgetData<String>('ring_path', today['ring']);
      await HomeWidget.saveWidgetData<String>('daily', jsonEncode(days));
      await HomeWidget.saveWidgetData<bool>(
          'period_action_visible', periodActionVisible);
      await HomeWidget.saveWidgetData<String>(
          'period_action_label', _t(locale, 'periodStarted'));
      for (final key in _predictionKeys) {
        await HomeWidget.saveWidgetData<String>(key, today[key] ?? '');
      }
      await HomeWidget.updateWidget(androidName: _androidProvider);
      await HomeWidget.updateWidget(androidName: _androidWideProvider);
    } catch (e) {
      // Widget güncellemesi asla akışı bozmasın
      debugPrint('[WIDGET] update failed: $e');
    }
  }

  static const _predictionKeys = [
    'pred1_label',
    'pred1_value',
    'pred2_label',
    'pred2_value',
    'pred3_label',
    'pred3_value',
  ];

  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// [day] günü widget'ta görünecek içerik (satırlar, ring, tahminler).
  static Future<Map<String, String?>> _snapshotFor(
    UserProfile? profile,
    List<PeriodRecord> records,
    String locale,
    DateTime day, {
    required String ringFile,
  }) async {
    final out = <String, String?>{
      'line1': 'Regl Takip',
      'line2': '',
      'ring': null,
      for (final key in _predictionKeys) key: '',
    };
    if (profile == null) return out;

    switch (profile.trackingMode) {
      case TrackingMode.pregnancy:
        if (profile.pregnancyStartDate != null) {
          final week =
              CycleUtils.pregnancyWeek(profile.pregnancyStartDate!, now: day);
          out['line1'] = locale == 'tr'
              ? '$week. ${_t(locale, 'week')}'
              : '${_t(locale, 'week')} $week';
        }
        break;
      case TrackingMode.pill:
        if (profile.pillPackStartDate != null) {
          final pillDay =
              CycleUtils.pillDayInPack(profile.pillPackStartDate!, now: day);
          out['line1'] = pillDay > 21
              ? '${_t(locale, 'breakWeek')} ${pillDay - 21}/7'
              : '${_t(locale, 'pill')} $pillDay/21';
        }
        break;
      case TrackingMode.ttc:
      case TrackingMode.period:
        final lastStart = profile.lastPeriodStart;
        if (lastStart == null) break;
        final cycleLen = CycleUtils.effectiveCycleLength(
          profile.averageCycleLength,
          records,
          smartEnabled: profile.smartPredictionEnabled,
        );
        final cycleDay =
            CycleUtils.displayCycleDay(lastStart, cycleLen, now: day);
        final delay =
            CycleUtils.periodDelayDays(lastStart, cycleLen, now: day);
        final daysLeft =
            CycleUtils.daysUntilNextPeriod(lastStart, cycleLen, now: day);
        out['line1'] = '${_t(locale, 'day')} $cycleDay';
        // Gecikmede "26 gün kaldı" demek gecikmeyi saklardı (tahmin bir
        // sonraki döngüye ileri sarılıyor)
        out['line2'] = delay > 0
            ? '$delay ${_t(locale, 'daysLate')}'
            : daysLeft > 0
                ? '$daysLeft ${_t(locale, 'daysLeft')}'
                : _t(locale, 'today');
        // İmza görsel cebe: mini faz ring'i (uygulamadaki haritanın
        // küçük hali) PNG olarak çizilir, native ImageView gösterir
        out['ring'] = await _renderRingPng(
            cycleLen, profile.averagePeriodLength, cycleDay, ringFile);

        // Geniş widget: üç tahmin tarihi. Geçmişte kalan
        // ovülasyon/fertil pencere bir sonraki döngüye kaydırılır.
        final today = dateOnly(day);
        final predPeriod =
            CycleUtils.nextFuturePeriod(lastStart, cycleLen, now: day);
        var ovulation = CycleUtils.predictOvulation(lastStart, cycleLen);
        while (ovulation.isBefore(today)) {
          ovulation = addDays(ovulation, cycleLen);
        }
        final fertile = addDays(
            ovulation, -AppConstants.fertileWindowStartBeforeOvulation);
        String fmt(DateTime d) {
          // Locale verisi henüz yüklenmemişse (erken çağrı) sayısal düşüş
          try {
            return DateFormat('d MMM', locale).format(d);
          } catch (_) {
            return '${d.day}.${d.month}';
          }
        }

        out['pred1_label'] = _t(locale, 'nextPeriod');
        out['pred1_value'] = fmt(predPeriod);
        out['pred2_label'] = _t(locale, 'ovulation');
        out['pred2_value'] = fmt(ovulation);
        out['pred3_label'] = _t(locale, 'fertile');
        out['pred3_value'] = fmt(fertile);
        break;
    }
    return out;
  }

  /// Geniş widget'ın tahmin satırlarını yazar; null tarih = satır gizli
  /// (native tarafta boş değerli satırlar GONE olur).
  static Future<void> _savePredictions(
    String? locale,
    DateTime? period,
    DateTime? ovulation,
    DateTime? fertile,
  ) async {
    final loc = locale ?? 'tr';
    String fmtDate(DateTime d) {
      try {
        return DateFormat('d MMM', loc).format(d);
      } catch (_) {
        return '${d.day}.${d.month}';
      }
    }

    Future<void> save(String key, String label, DateTime? date) async {
      await HomeWidget.saveWidgetData<String>(
          '${key}_label', date == null ? '' : _t(loc, label));
      await HomeWidget.saveWidgetData<String>(
          '${key}_value', date == null ? '' : fmtDate(date));
    }

    await save('pred1', 'nextPeriod', period);
    await save('pred2', 'ovulation', ovulation);
    await save('pred3', 'fertile', fertile);
  }

  /// Mini faz ring'ini PNG'ye çizer, dosya yolunu döndürür.
  /// Dashboard ring'iyle aynı segment haritası (ringSegmentsFor) —
  /// imza görsel iki yüzeyde tek kaynaktan. Hata durumunda null:
  /// widget ring'siz, metinle çalışmaya devam eder.
  static Future<String?> _renderRingPng(
      int cycleLength, int periodLength, int day, String fileName) async {
    try {
      const size = 160.0;
      const stroke = 20.0;
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final center = const ui.Offset(size / 2, size / 2);
      final radius = size / 2 - stroke / 2 - 6;
      final rect = ui.Rect.fromCircle(center: center, radius: radius);

      canvas.drawCircle(
        center,
        radius,
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = const ui.Color(0x14000000),
      );

      final segments = ringSegmentsFor(cycleLength, periodLength);
      const gap = 0.06;
      double angleOf(int d) =>
          -math.pi / 2 + (d - 1) / cycleLength * 2 * math.pi;

      for (final s in segments) {
        final start = angleOf(s.startDay) + gap / 2;
        final end = angleOf(s.endDay + 1) - gap / 2;
        if (end <= start) continue;
        canvas.drawArc(
          rect,
          start,
          end - start,
          false,
          ui.Paint()
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = stroke
            ..strokeCap = ui.StrokeCap.round
            ..color = s.color,
        );
      }

      // "Buradasın" noktası
      final clamped = day.clamp(1, cycleLength);
      final tAngle = angleOf(clamped) + math.pi / cycleLength;
      final todayCenter = ui.Offset(
        center.dx + radius * math.cos(tAngle),
        center.dy + radius * math.sin(tAngle),
      );
      canvas.drawCircle(
          todayCenter, 11, ui.Paint()..color = const ui.Color(0xFFFFFFFF));
      canvas.drawCircle(todayCenter, 7,
          ui.Paint()..color = segmentColorForDay(segments, clamped));

      final image =
          await recorder.endRecording().toImage(size.toInt(), size.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return null;

      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      return file.path;
    } catch (e) {
      debugPrint('[WIDGET] ring render failed: $e');
      return null;
    }
  }
}
