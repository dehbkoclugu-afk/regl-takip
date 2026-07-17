import 'dart:io' show File, Platform;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';

import '../core/utils/cycle_utils.dart';
import '../core/utils/ring_segments.dart';
import '../models/enums.dart';
import '../models/period_record.dart';
import '../models/user_profile.dart';
import 'disguise_service.dart';

/// Android ana ekran widget'ını besler. Metinler Dart tarafında
/// lokalize edilip SharedPreferences üzerinden native provider'a geçer
/// (native tarafta l10n altyapısı yok).
class WidgetService {
  static const _androidProvider = 'CycleWidgetProvider';

  static const _strings = {
    'tr': {
      'day': 'Gün',
      'daysLeft': 'gün kaldı',
      'today': 'Bugün!',
      'week': 'hafta',
      'pill': 'Hap',
      'breakWeek': 'Ara hafta',
    },
    'en': {
      'day': 'Day',
      'daysLeft': 'days left',
      'today': 'Today!',
      'week': 'Week',
      'pill': 'Pill',
      'breakWeek': 'Break week',
    },
  };

  static String _t(String locale, String key) =>
      _strings[locale]?[key] ?? _strings['en']![key]!;

  /// Widget verisini günceller. Android dışında no-op.
  static Future<void> update(
    UserProfile? profile,
    List<PeriodRecord> records,
  ) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      // Gizli moddayken widget döngü verisi sızdırmamalı —
      // uygulama "Notlar" kılığındayken nötr içerik göster
      if (await DisguiseService.isDisguised()) {
        await HomeWidget.saveWidgetData<String>('line1', 'Notlar');
        await HomeWidget.saveWidgetData<String>('line2', '');
        await HomeWidget.saveWidgetData<String>('ring_path', null);
        await HomeWidget.updateWidget(androidName: _androidProvider);
        return;
      }

      final locale = profile?.language ?? 'tr';
      String line1 = 'Regl Takip';
      String line2 = '';
      String? ringPath;

      if (profile != null) {
        switch (profile.trackingMode) {
          case TrackingMode.pregnancy:
            if (profile.pregnancyStartDate != null) {
              final week =
                  CycleUtils.pregnancyWeek(profile.pregnancyStartDate!);
              line1 = locale == 'tr'
                  ? '$week. ${_t(locale, 'week')}'
                  : '${_t(locale, 'week')} $week';
            }
            break;
          case TrackingMode.pill:
            if (profile.pillPackStartDate != null) {
              final day =
                  CycleUtils.pillDayInPack(profile.pillPackStartDate!);
              line1 = day > 21
                  ? '${_t(locale, 'breakWeek')} ${day - 21}/7'
                  : '${_t(locale, 'pill')} $day/21';
            }
            break;
          case TrackingMode.ttc:
          case TrackingMode.period:
            if (profile.lastPeriodStart != null) {
              final cycleLen = CycleUtils.effectiveCycleLength(
                profile.averageCycleLength,
                records,
                smartEnabled: profile.smartPredictionEnabled,
              );
              final day = CycleUtils.wrappedCycleDay(
                CycleUtils.currentCycleDay(profile.lastPeriodStart!),
                cycleLen,
              );
              final daysLeft = CycleUtils.daysUntilNextPeriod(
                  profile.lastPeriodStart!, cycleLen);
              line1 = '${_t(locale, 'day')} $day';
              line2 = daysLeft > 0
                  ? '$daysLeft ${_t(locale, 'daysLeft')}'
                  : _t(locale, 'today');
              // İmza görsel cebe: mini faz ring'i (uygulamadaki haritanın
              // küçük hali) PNG olarak çizilir, native ImageView gösterir
              ringPath = await _renderRingPng(
                  cycleLen, profile.averagePeriodLength, day);
            }
            break;
        }
      }

      await HomeWidget.saveWidgetData<String>('line1', line1);
      await HomeWidget.saveWidgetData<String>('line2', line2);
      await HomeWidget.saveWidgetData<String>('ring_path', ringPath);
      await HomeWidget.updateWidget(androidName: _androidProvider);
    } catch (e) {
      // Widget güncellemesi asla akışı bozmasın
      debugPrint('[WIDGET] update failed: $e');
    }
  }

  /// Mini faz ring'ini PNG'ye çizer, dosya yolunu döndürür.
  /// Dashboard ring'iyle aynı segment haritası (ringSegmentsFor) —
  /// imza görsel iki yüzeyde tek kaynaktan. Hata durumunda null:
  /// widget ring'siz, metinle çalışmaya devam eder.
  static Future<String?> _renderRingPng(
      int cycleLength, int periodLength, int day) async {
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
      final file = File('${dir.path}/cycle_widget_ring.png');
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      return file.path;
    } catch (e) {
      debugPrint('[WIDGET] ring render failed: $e');
      return null;
    }
  }
}
