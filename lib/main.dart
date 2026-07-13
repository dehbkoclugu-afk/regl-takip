import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'providers/providers.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  // Oryantasyon kilidi yok: tüm ekranlar kaydırılabilir, tablet/landscape
  // düzenleri app_shell'deki genişlik sınıfı (NavigationRail) ile karşılanıyor

  // Status bar stili tema tarafından yönetiliyor (AppBarTheme.systemOverlayStyle)
  // — global set edilirse açık temada beyaz ikonlar görünmez oluyordu

  // Initialize Hive
  await HiveService().init();

  final profile = HiveService().getUserProfile();

  // Bildirim kurulumu ilk kareyi bloklamasın — arka planda tamamlanır
  final notificationService = NotificationService();
  unawaited(() async {
    try {
      await notificationService.init();
      await notificationService.requestPermission();
      if (profile != null) {
        await notificationService.rescheduleAll(profile);
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
