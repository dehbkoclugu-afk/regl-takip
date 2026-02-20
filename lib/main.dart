import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
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

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermission();

  // Schedule notifications if profile exists
  final profile = HiveService().getUserProfile();
  if (profile != null) {
    await notificationService.rescheduleAll(profile);
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
