import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'services/premium_service.dart';
import 'services/widget_service.dart';
import 'providers/providers.dart';
import 'app.dart';

/// Crash raporlama DSN'i build sırasında verilir:
///   flutter build apk --dart-define=SENTRY_DSN=https://...
/// Boşsa Sentry tamamen devre dışı — telemetri gönderilmez (gizlilik
/// hassas ürün: DSN eklenirse de PII gönderimi kapalı tutulmalı).
const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

Future<void> main() async {
  if (_sentryDsn.isEmpty) {
    await _run();
    return;
  }
  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.sendDefaultPii = false;
      options.tracesSampleRate = 0.0; // yalnız crash, performans izleme yok
    },
    appRunner: _run,
  );
}

Future<void> _run() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  // Oryantasyon kilidi yok: tüm ekranlar kaydırılabilir, tablet/landscape
  // düzenleri app_shell'deki genişlik sınıfı (NavigationRail) ile karşılanıyor

  // Status bar stili tema tarafından yönetiliyor (AppBarTheme.systemOverlayStyle)
  // — global set edilirse açık temada beyaz ikonlar görünmez oluyordu

  // Initialize Hive
  await HiveService().init();

  final profile = HiveService().getUserProfile();

  // Premium durumu ve widget güncellemesi arka planda
  unawaited(PremiumService().init());
  unawaited(
      WidgetService.update(profile, HiveService().getAllPeriodRecords()));

  // Bildirim kurulumu ilk kareyi bloklamasın — arka planda tamamlanır
  final notificationService = NotificationService();
  unawaited(() async {
    try {
      await notificationService.init();
      await notificationService.requestPermission();
      if (profile != null) {
        await notificationService.rescheduleAll(
          profile,
          records: HiveService().getAllPeriodRecords(),
        );
      }
    } catch (e) {
      // Bildirimler olmadan devam et
      debugPrint('[NOTIF] setup failed: $e');
    }
  }());

  runApp(
    ProviderScope(
      overrides: [
        if (profile != null) ...[
          darkModeProvider.overrideWith((ref) => profile.darkModeEnabled),
          localeProvider.overrideWith((ref) => Locale(profile.language)),
        ],
      ],
      child: const ReglTakipApp(),
    ),
  );
}
