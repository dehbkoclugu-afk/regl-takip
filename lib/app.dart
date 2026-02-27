import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/providers.dart';
import 'screens/lock/lock_screen.dart';
import 'screens/paywall/paywall_screen.dart';
import 'services/premium_service.dart';

class ReglTakipApp extends ConsumerStatefulWidget {
  const ReglTakipApp({super.key});

  @override
  ConsumerState<ReglTakipApp> createState() => _ReglTakipAppState();
}

class _ReglTakipAppState extends ConsumerState<ReglTakipApp>
    with WidgetsBindingObserver {
  bool _isLocked = true;
  bool _needsLock = false;
  bool _pendingLockUpdate = false;
  bool _showPaywall = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLockNeeded();
    _checkPremiumAccess();
  }

  Future<void> _checkPremiumAccess() async {
    final premiumService = PremiumService();
    await premiumService.initialize();
    final hasAccess = await premiumService.hasAccess();
    if (!hasAccess && mounted) {
      setState(() => _showPaywall = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _checkLockNeeded() {
    final profile = ref.read(userProfileProvider);
    final needs = (profile?.pinEnabled == true) || (profile?.biometricEnabled == true);
    setState(() {
      _needsLock = needs;
      _isLocked = needs;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Re-lock when app goes to background
      final profile = ref.read(userProfileProvider);
      if ((profile?.pinEnabled == true) || (profile?.biometricEnabled == true)) {
        setState(() => _isLocked = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);
    final isDarkMode = ref.watch(darkModeProvider);

    // Watch profile changes to detect lock settings changes
    final profile = ref.watch(userProfileProvider);
    final currentNeedsLock =
        (profile?.pinEnabled == true) || (profile?.biometricEnabled == true);
    if (currentNeedsLock != _needsLock && !_pendingLockUpdate) {
      _pendingLockUpdate = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _pendingLockUpdate = false;
          final p = ref.read(userProfileProvider);
          final needs = (p?.pinEnabled == true) || (p?.biometricEnabled == true);
          if (needs != _needsLock) {
            setState(() {
              _needsLock = needs;
              if (!needs) _isLocked = false;
            });
          }
        }
      });
    }

    return MaterialApp.router(
      title: 'Regl Takip',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
      ],
      routerConfig: router,
      builder: (context, child) {
        if (_isLocked && _needsLock) {
          return LockScreen(
            onUnlocked: () => setState(() => _isLocked = false),
          );
        }
        if (_showPaywall) {
          return PaywallScreen(
            key: const ValueKey('paywall'),
            onPremiumActivated: () {
              setState(() => _showPaywall = false);
            },
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
