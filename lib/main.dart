import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'services/premium_service.dart';
import 'providers/providers.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Hive
  await HiveService().init();

  // Initialize Premium/Trial service
  await PremiumService().initialize();

  // Initialize notifications (with error handling to prevent freeze)
  final notificationService = NotificationService();
  try {
    await notificationService.init();
    await notificationService.requestPermission();
  } catch (_) {
    // Notification init failed - continue without notifications
  }

  // Schedule notifications if profile exists
  final profile = HiveService().getUserProfile();
  if (profile != null) {
    try {
      await notificationService.rescheduleAll(profile);
    } catch (_) {
      // Notification scheduling failed - continue without notifications
    }
  }

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
