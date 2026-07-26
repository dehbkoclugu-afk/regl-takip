import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/calendar/calendar_screen.dart';
import '../../screens/symptoms/symptom_tracking_screen.dart';
import '../../screens/mood/mood_tracking_screen.dart';
import '../../screens/statistics/statistics_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/shell/app_shell.dart';
import '../../screens/log/log_screen.dart';
import '../../screens/measurements/daily_measurements_screen.dart';
import '../../screens/flow/flow_tracking_screen.dart';
import '../../screens/water/water_tracking_screen.dart';
import '../../screens/temperature/temperature_tracking_screen.dart';
import '../../screens/weight/weight_tracking_screen.dart';
import '../../screens/sleep/sleep_tracking_screen.dart';
import '../../screens/sexual_activity/sexual_activity_screen.dart';
import '../../screens/medication/medication_tracking_screen.dart';
import '../../screens/notes/notes_screen.dart';
import '../../screens/paywall/paywall_screen.dart';
import '../../screens/period_history/period_history_screen.dart';
import '../../screens/profile/profile_edit_screen.dart';
import '../../providers/providers.dart';

// Navigation keys for each branch in the StatefulShellRoute
final _rootNavigatorKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;
final _shellNavigatorDashboardKey =
    GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _shellNavigatorCalendarKey =
    GlobalKey<NavigatorState>(debugLabel: 'calendar');
final _shellNavigatorStatisticsKey =
    GlobalKey<NavigatorState>(debugLabel: 'statistics');
final _shellNavigatorSettingsKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

final routerProvider = Provider<GoRouter>((ref) {
  final userProfile = ref.read(userProfileProvider);
  final isOnboarded = userProfile?.onboardingCompleted ?? false;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: isOnboarded ? '/dashboard' : '/onboarding',
    // Bildirim/widget/deep link doğrudan bir sekmeye atlayabilir: profil
    // yoksa döngü ekranları boş veriyle açılır. Kurulum tamamlanmadan
    // hiçbir yere girilemez, tamamlandıysa kuruluma geri dönülemez.
    redirect: (context, state) {
      final onboarded =
          ref.read(userProfileProvider)?.onboardingCompleted ?? false;
      final atOnboarding = state.matchedLocation == '/onboarding';
      if (!onboarded && !atOnboarding) return '/onboarding';
      if (onboarded && atOnboarding) return '/dashboard';
      // Deneme bittikten sonra takip rotaları salt-okunur açılır. Yazma
      // eylemleri ekranlardaki ortak premium kapısında durdurulur; böylece
      // kullanıcı yıllardır tuttuğu geçmişi görmeye devam eder.
      return null;
    },
    // Bilinmeyen yol (eski bildirim payload'ı, hatalı deep link) kırmızı
    // hata ekranı yerine ana sayfaya düşer
    onException: (context, state, router) => router.go('/dashboard'),
    routes: [
      // Onboarding - no shell, full screen
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main app with bottom navigation shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0 - Dashboard (Ana Sayfa)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDashboardKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch 1 - Calendar (Takvim)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCalendarKey,
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),

          // Branch 2 - Statistics (Istatistik)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorStatisticsKey,
            routes: [
              GoRoute(
                path: '/statistics',
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),

          // Branch 3 - Settings (Ayarlar)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Full-screen routes without bottom navigation
      GoRoute(
        path: '/symptoms',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SymptomTrackingScreen(),
      ),
      GoRoute(
        path: '/mood',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MoodTrackingScreen(),
      ),
      GoRoute(
        path: '/log',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LogScreen(),
      ),
      GoRoute(
        path: '/flow',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FlowTrackingScreen(),
      ),
      GoRoute(
        path: '/water',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WaterTrackingScreen(),
      ),
      GoRoute(
        path: '/measurements',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DailyMeasurementsScreen(),
      ),
      GoRoute(
        path: '/temperature',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TemperatureTrackingScreen(),
      ),
      GoRoute(
        path: '/weight',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WeightTrackingScreen(),
      ),
      GoRoute(
        path: '/sleep',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SleepTrackingScreen(),
      ),
      GoRoute(
        path: '/sexual-activity',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SexualActivityScreen(),
      ),
      GoRoute(
        path: '/medication',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MedicationTrackingScreen(),
      ),
      GoRoute(
        path: '/notes',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: '/profile-edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileEditScreen(),
      ),
      // Ücretsiz katmanın vaadi regl takibi; yanlış girilen kaydı
      // düzeltmek o vaadin parçası ve yazma istisnası olarak kalır.
      GoRoute(
        path: '/period-history',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PeriodHistoryScreen(),
      ),
      GoRoute(
        path: '/paywall',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PaywallScreen(),
      ),
    ],
  );
});
