import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/providers.dart';
import 'screens/decoy/decoy_notes_screen.dart';
import 'screens/lock/lock_screen.dart';
import 'services/ad_service.dart';
import 'services/disguise_service.dart';
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

  // Tam kılık: gizli modda uygulama gerçek bir not defteri olarak açılır;
  // gerçek uygulamaya yalnız bilinçli çıkış hareketiyle (altta kilit varsa
  // PIN'le) geçilir. _decoyResolved: soğuk açılışta kılık durumu native
  // taraftan okunana dek gerçek arayüz BİR KARE bile görünmemeli.
  bool _decoyActive = false;
  bool _decoyResolved = false;
  bool _isDisguisedCached = false;

  /// Deneme süresi zamanın geçmesiyle dolar ama accessProvider'ı tazeleyen
  /// bir olay yoktu: 30. gün uygulama açıkken dolduğunda erişim yeniden
  /// başlatılana dek premium kalıyordu. Periyodik tik + arka plandan dönüş.
  Timer? _accessRefreshTimer;

  /// Uygulamanın arka plana alındığı an. Kilit kararı artık burada değil
  /// dönüşte veriliyor: kullanıcının seçtiği gecikme dolmadıysa PIN
  /// sorulmaz. null = uygulama hiç arka plana gitmedi (soğuk açılış).
  DateTime? _backgroundedAt;

  /// Kilit gecikmesi (saniye). 0 = hemen, eski davranış.
  int _lockTimeoutSeconds = LockTimeout.defaultSeconds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLockNeeded();
    _resolveDisguise();
    // Satın alma olayları (mağazadan asenkron gelir) erişim kararlarına
    // yansımalı: ValueNotifier → Riverpod köprüsü
    PremiumService().isPremiumNotifier.addListener(_onPremiumChanged);
    _accessRefreshTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _refreshAccess(),
    );
    // İlk arka plan/dönüş çevriminde de doğru gecikme kullanılsın
    LockTimeout.read().then((value) {
      if (mounted) _lockTimeoutSeconds = value;
    });
    // Kilit varsa reklam kilit açıldıktan sonra gösterilir (_onUnlocked)
    if (!_needsLock) _showOpenAd();
  }

  void _refreshAccess() {
    if (!mounted) return;
    ref.invalidate(accessProvider);
    ref.invalidate(trialDaysLeftProvider);
  }

  void _onPremiumChanged() {
    if (!mounted) return;
    ref.read(isPremiumProvider.notifier).state =
        PremiumService().isPremium;
  }

  Future<void> _resolveDisguise() async {
    final disguised = await DisguiseService.isDisguised();
    if (!mounted) return;
    setState(() {
      _isDisguisedCached = disguised;
      _decoyActive = disguised;
      _decoyResolved = true;
    });
  }

  Future<void> _showOpenAd() async {
    if (_openAdShown) return;
    if (PremiumService().isPremium) return;
    // Deneme ayında da reklamsız: "1 ay ücretsiz" vaadinin deneyimi tam
    // olmalı — reklam yalnız ücretsiz katmanda
    if (ref.read(accessProvider) != AccessLevel.free) return;

    // Sıklık sınırı: reklam her açılışta çıkıyordu. Regl takibi
    // "gir-kaydet-çık" uygulaması, üç saniyelik işin önündeki tam ekran
    // reklam uygulamayı açmayı caydırıyor. Kurulum anı için deneme
    // başlangıcı kullanılır — ilk açılışta sabitlenen tek tarih o.
    final installedAt = ref.read(trialStartProvider) ?? DateTime.now();
    if (!await AdService.canShowOpenAd(installedAt: installedAt)) return;
    if (!mounted) return;

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
    _accessRefreshTimer?.cancel();
    PremiumService().isPremiumNotifier.removeListener(_onPremiumChanged);
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
    if (state == AppLifecycleState.resumed) {
      // Arka planda geçen süre denemeyi bitirmiş olabilir
      _refreshAccess();
      // Kilit kararı burada: gecikme dolmadıysa PIN sorulmaz. Bildirime
      // bakıp dönmek, fotoğraf seçiciden çıkmak, bir bağlantı açıp kapatmak
      // her seferinde PIN istiyordu — kilidi kapattıran türden sürtünme.
      final profile = ref.read(userProfileProvider);
      final needs = (profile?.pinEnabled == true) ||
          (profile?.biometricEnabled == true);
      if (needs &&
          !_isLocked &&
          LockTimeout.shouldLock(
            now: DateTime.now(),
            backgroundedAt: _backgroundedAt,
            timeoutSeconds: _lockTimeoutSeconds,
          )) {
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() => _isLocked = true);
      }
      _backgroundedAt = null;
      return;
    }
    // Yalnız paused/hidden: `inactive` bildirim çekmecesi, izin diyaloğu,
    // paylaşım sayfası gibi geçici odak kayıplarında da gelir — orada
    // kilitlemek her seferinde PIN + (eski davranışta) state kaybı demekti.
    // Recents önizleme sızıntısını FLAG_SECURE çözer (PrivacyScreenService).
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Zaman damgası: kilit kararı dönüşte bunun üzerinden veriliyor
      _backgroundedAt ??= DateTime.now();
      // Gecikme tercihi arka planda tazelenir; dönüşte okuma beklenmesin
      LockTimeout.read().then((value) {
        if (mounted) _lockTimeoutSeconds = value;
      });
      // Kılık tutarlılığı: gizli moddayken arka plana giden uygulama
      // dönüşte yine "Notlar" olarak açılmalı
      if (_isDisguisedCached && !_decoyActive) {
        setState(() => _decoyActive = true);
      }
      // Ayarlardan kılık değişmiş olabilir — önbelleği tazele
      DisguiseService.isDisguised().then((value) {
        if (mounted) _isDisguisedCached = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

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
      // Üç durumlu tercih (sistem/açık/koyu); varsayılan sistem —
      // sistemi koyu kullanan kullanıcı ilk açılışta kör edilmez
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Desteklenen diller arb dosyalarından: tr, en, es, de, fr, ru
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        // Kılık durumu çözülmeden gerçek arayüz bir kare bile görünmesin
        if (!_decoyResolved) {
          return const ColoredBox(color: Colors.white);
        }
        // Katman sırası (üstte olan kazanır): decoy > kilit > uygulama.
        // Decoy'dan çıkış hareketi decoy'u kaldırır; altında kilit varsa
        // PIN doğal olarak sorulur. Kilit, child'ın YERİNE değil ÜSTÜNE
        // gelir: alttaki Navigator ağacı yaşamaya devam eder.
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            if (_isLocked && _needsLock)
              LockScreen(onUnlocked: _onUnlocked),
            if (_decoyActive)
              DecoyNotesScreen(
                onExitRequested: () =>
                    setState(() => _decoyActive = false),
              ),
          ],
        );
      },
    );
  }
}
