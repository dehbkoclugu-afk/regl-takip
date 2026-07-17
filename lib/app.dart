import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/providers.dart';
import 'screens/lock/lock_screen.dart';
import 'services/ad_service.dart';
import 'services/premium_service.dart';
import 'services/privacy_screen_service.dart';

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
  bool _openAdShown = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLockNeeded();
    // Kilit varsa reklam kilit açıldıktan sonra gösterilir (_onUnlocked)
    if (!_needsLock) _showOpenAd();
  }

  Future<void> _showOpenAd() async {
    if (_openAdShown) return;
    if (PremiumService().isPremium) return;
    _openAdShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Activity/ViewController tamamen hazır olduktan sonra
      await Future.delayed(const Duration(seconds: 2));
      await AdService.initialize();
      await AdService.loadOpenAd();
      await AdService.showOpenAd();
    });
  }

  void _onUnlocked() {
    setState(() => _isLocked = false);
    _showOpenAd();
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
    // Recents önizlemesi ve ekran görüntüsü FLAG_SECURE ile engellenir —
    // kilidi geçici odak kayıplarında indirmeye gerek kalmaz
    PrivacyScreenService.setSecureScreen(needs);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Yalnız paused/hidden: `inactive` bildirim çekmecesi, izin diyaloğu,
    // paylaşım sayfası gibi geçici odak kayıplarında da gelir — orada
    // kilitlemek her seferinde PIN + (eski davranışta) state kaybı demekti.
    // Recents önizleme sızıntısını FLAG_SECURE çözer (PrivacyScreenService).
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      final profile = ref.read(userProfileProvider);
      if ((profile?.pinEnabled == true) ||
          (profile?.biometricEnabled == true)) {
        if (!_isLocked) {
          // Kilit örtüsü inerken alttaki alan odağı bırakmalı (klavye açık
          // kalmasın, tuş vuruşları alta gitmesin)
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() => _isLocked = true);
        }
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
            PrivacyScreenService.setSecureScreen(needs);
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
        // Kilit, child'ın YERİNE değil ÜSTÜNE gelir: alttaki Navigator
        // ağacı yaşamaya devam eder — kaydırma konumu, açık sheet, yazılan
        // not kilitten dönüşte aynen durur. (Eski davranış child'ı ağaçtan
        // söküyordu; bildirim çekmecesine bir bakış her şeyi sıfırlıyordu.)
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            if (_isLocked && _needsLock)
              LockScreen(onUnlocked: _onUnlocked),
          ],
        );
      },
    );
  }
}
