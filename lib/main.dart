import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Erişim modeli: deneme başlangıcı ilk açılışta sabitlenir (Hive değil
  // SharedPreferences — "tüm verileri sil" denemeyi sıfırlamaz), premium
  // önbelleği mağaza cevap vermeden de bilinmeli (kısıt kararları için)
  final trialStart = await PremiumService.ensureTrialStart();
  final prefs = await SharedPreferences.getInstance();
  final cachedPremium = prefs.getBool('premium_active') ?? false;
  final phasePattern = prefs.getBool('phase_pattern') ?? false;
  final backdateHint = prefs.getBool('backdate_hint_needed') ?? true;

  // Premium durumu ve widget güncellemesi arka planda
  unawaited(PremiumService().init());
  unawaited(
      WidgetService.update(profile, HiveService().getAllPeriodRecords()));

  // Bildirim kurulumu ilk kareyi bloklamasın — arka planda tamamlanır
  final notificationService = NotificationService();
  unawaited(() async {
    try {
      await notificationService.init();
      // İzin artık soğuk açılışta istenmiyor: sistem diyaloğu kurulum
      // ekranının üstünde, hiçbir gerekçe görülmeden çıkıyordu ve
      // reddedildiğinde Android bir daha sormuyor — yani tüm hatırlatma
      // altyapısı tek bir bağlamsız dokunuşla ölüyordu. Yeni kurulumda izin
      // kurulum bittikten sonra, ne işe yaradığı anlatılarak isteniyor
      // (onboarding_screen). Profili olan kurulumlar eski akıştan geçmiş:
      // izin verilmişse çağrı zaten sessiz, reddedilmişse sistem sormuyor.
      if (profile != null) {
        await notificationService.requestPermission();
        // İlaç hatırlatmaları ilaçların kendi saatlerinde kurulur: soğuk
        // açılışta liste verilmezse yalnız genel hatırlatma planlanıyordu
        final logsWithMeds = HiveService()
            .getAllDailyLogs()
            .where((l) => l.medications.isNotEmpty)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        await notificationService.rescheduleAll(
          profile,
          records: HiveService().getAllPeriodRecords(),
          medications:
              logsWithMeds.isEmpty ? const [] : logsWithMeds.first.medications,
          logs: HiveService().getAllDailyLogs(),
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
        trialStartProvider.overrideWith((ref) => trialStart),
        isPremiumProvider.overrideWith((ref) => cachedPremium),
        phasePatternProvider.overrideWith((ref) => phasePattern),
        backdateHintProvider.overrideWith((ref) => backdateHint),
        if (profile != null) ...[
          themeModeProvider.overrideWith((ref) => themeModeFromProfile(profile)),
          // 'system' = override yok, MaterialApp cihaz dilini izler
          if (profile.language != 'system')
            localeProvider.overrideWith((ref) => Locale(profile.language)),
        ],
      ],
      child: const ReglTakipApp(),
    ),
  );
}
