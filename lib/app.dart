import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/router/app_router.dart';
import 'core/utils/access.dart';
import 'core/utils/medication_plan.dart';
import 'providers/providers.dart';
import 'screens/decoy/decoy_notes_screen.dart';
import 'screens/lock/lock_screen.dart';
import 'services/ad_service.dart';
import 'services/disguise_service.dart';
import 'services/notification_service.dart';
import 'services/premium_service.dart';
import 'services/privacy_screen_service.dart';
import 'services/quick_action_service.dart';
import 'services/widget_service.dart';
import 'screens/log/quick_log_sheet.dart';

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
  bool _suppressOpenAd = false;
  bool _trialEndNoticePending = false;
  bool _trialEndNoticeHandled = false;
  bool _widgetActionHandling = false;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static const String _trialEndNoticeKey = 'trial_end_notice_shown_v1';

  // Tam kılık: gizli modda uygulama gerçek bir not defteri olarak açılır;
  // gerçek uygulamaya yalnız bilinçli çıkış hareketiyle (altta kilit varsa
  // PIN'le) geçilir. _decoyResolved: soğuk açılışta kılık durumu native
  // taraftan okunana dek gerçek arayüz BİR KARE bile görünmemeli.
  bool _decoyActive = false;
  bool _decoyResolved = false;
  bool _isDisguisedCached = false;
  String? _shortcutSignature;

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
    ScreenProtection.enabled.addListener(_onScreenProtectionChanged);
    ScreenProtection.load().then((_) => _applySecureScreen());
    _resolveDisguise();
    // Satın alma olayları (mağazadan asenkron gelir) erişim kararlarına
    // yansımalı: ValueNotifier → Riverpod köprüsü
    PremiumService().isPremiumNotifier.addListener(_onPremiumChanged);
    // Bildirim aksiyonu uygulamayı açtığında iş burada yapılır: yazma
    // provider üzerinden gitmeli ki ekrandaki durum veriyle ayrışmasın
    NotificationService().pendingAction.addListener(_onNotificationAction);
    QuickActionService().pendingAction.addListener(_onQuickAction);
    WidgetService.pendingAction.addListener(_onWidgetAction);
    AdService.recordSavedRevision.addListener(_onRecordSaved);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onNotificationAction();
      _onQuickAction();
      _onWidgetAction();
    });
    _accessRefreshTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _refreshAccess(),
    );
    // İlk arka plan/dönüş çevriminde de doğru gecikme kullanılsın
    LockTimeout.read().then((value) {
      if (mounted) _lockTimeoutSeconds = value;
    });
  }

  void _onRecordSaved() {
    if (!mounted || _isLocked || _decoyActive) return;
    // Eski açılış bastırma bayrağı yalnız eylem tamamlanana kadar anlamlıydı.
    // Reklam artık iş bittikten sonra geldiği için başarılı kayıt onu kaldırır.
    _suppressOpenAd = false;
    _showOpenAd();
  }

  /// Bildirimden gelen aksiyonu uygular. Aksiyon tek seferlik: uygulandıktan
  /// (ya da uygulanamadıktan) sonra temizlenir, yoksa her açılışta tekrar
  /// çalışır.
  Future<void> _onNotificationAction() async {
    final action = NotificationService().pendingAction.value;
    if (action == null || !mounted) return;
    NotificationService().pendingAction.value = null;

    switch (action.id) {
      case NotificationService.actionPeriodStarted:
        final records = ref.read(periodRecordsProvider.notifier);
        final record = await records.startPeriod(DateTime.now());
        await ref
            .read(userProfileProvider.notifier)
            .saveProfile(lastPeriodStart: record.startDate);
        notifyTrackingRecordSaved();
        break;
      case NotificationService.actionMedicationTaken:
        // Deneme bittikten sonra geçmiş görünür, yeni günlük yazma premium.
        // Daha önce kurulmuş bir bildirim bu kuralı arkadan delemesin.
        if (ref.read(accessProvider) == AccessLevel.free) {
          ref.read(routerProvider).push('/paywall');
          break;
        }
        final name = action.payload;
        if (name == null || name.isEmpty) break;
        final plan = ref.read(userProfileProvider)?.medicationPlan ?? const [];
        if (plan.isEmpty) break;
        final today = DateTime.now();
        final logs = ref.read(dailyLogProvider.notifier);
        final log = logs.getDailyLog(today);
        final meds = medicationEntriesForDay(
          plan,
          log?.medications ?? const [],
        );
        // Aynı adlı ilaç birden fazla olabilir: hepsi işaretlenir
        var changed = false;
        for (final med in meds) {
          if (med.name == name && !med.taken) {
            med.taken = true;
            changed = true;
          }
        }
        if (changed) {
          await logs.updateMedications(
            today,
            medicationDailyRecord(meds, log?.medications ?? const []),
          );
        }
        break;
    }
  }

  Future<void> _onQuickAction() async {
    final service = QuickActionService();
    final type = service.pendingAction.value;
    if (type == null || !mounted) return;
    if (type == QuickActionService.actionQuickLog ||
        type == QuickActionService.actionToday) {
      _suppressOpenAd = true;
    }

    final profile = ref.read(userProfileProvider);
    final navigatorReady = rootNavigatorKey.currentContext != null;
    var destination = resolveQuickAction(
      type: type,
      disguiseResolved: _decoyResolved,
      disguised: _isDisguisedCached,
      onboardingCompleted: profile?.onboardingCompleted == true,
      locked: _isLocked && _needsLock,
      appResumed:
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed,
      navigatorReady: navigatorReady,
      hasDailyAccess: ref.read(accessProvider) != AccessLevel.free,
    );
    if (destination == QuickActionDestination.wait) return;

    // Ayarlar ekranı kılığı native tarafta bu state'ten önce değiştirmiş
    // olabilir. Sağlık sheet'i açmadan gerçek alias durumunu tekrar sor.
    final disguised = await DisguiseService.isDisguised();
    if (!mounted || service.pendingAction.value != type) return;
    destination = resolveQuickAction(
      type: type,
      disguiseResolved: _decoyResolved,
      disguised: disguised,
      onboardingCompleted: profile?.onboardingCompleted == true,
      locked: _isLocked && _needsLock,
      appResumed:
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed,
      navigatorReady: rootNavigatorKey.currentContext != null,
      hasDailyAccess: ref.read(accessProvider) != AccessLevel.free,
    );
    if (destination == QuickActionDestination.wait) return;

    service.pendingAction.value = null;
    _openAdShown = true;
    final router = ref.read(routerProvider);
    final today = DateTime.now();
    ref.read(selectedDateProvider.notifier).state = today;

    switch (destination) {
      case QuickActionDestination.today:
        router.go('/dashboard');
        break;
      case QuickActionDestination.quickLog:
        router.go('/dashboard');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = rootNavigatorKey.currentContext;
          if (mounted && context != null) {
            showQuickLogSheet(context, ref, today);
          }
        });
        break;
      case QuickActionDestination.paywall:
        router.push('/paywall');
        break;
      case QuickActionDestination.discard:
      case QuickActionDestination.wait:
        break;
    }
  }

  Future<void> _onWidgetAction() async {
    final action = WidgetService.pendingAction.value;
    if (action == null || !mounted || _widgetActionHandling) return;
    _suppressOpenAd = true;
    _widgetActionHandling = true;

    try {
      WidgetPeriodActionDestination resolve({required bool disguised}) {
        final profile = ref.read(userProfileProvider);
        final records = ref.read(periodRecordsProvider);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        return resolveWidgetPeriodAction(
          action: action,
          disguiseResolved: _decoyResolved,
          disguised: disguised,
          onboardingCompleted: profile?.onboardingCompleted == true,
          trackingMode: profile?.trackingMode,
          hasOngoingPeriod: records.any((record) => record.isOngoing),
          hasRecordToday: records.any((record) {
            final start = record.startDate;
            return DateTime(start.year, start.month, start.day) == today;
          }),
          locked: _isLocked && _needsLock,
          appResumed:
              WidgetsBinding.instance.lifecycleState ==
              AppLifecycleState.resumed,
          navigatorReady: rootNavigatorKey.currentContext != null,
        );
      }

      var destination = resolve(disguised: _isDisguisedCached);
      if (destination == WidgetPeriodActionDestination.wait) return;

      final disguised = await DisguiseService.isDisguised();
      if (!mounted || WidgetService.pendingAction.value != action) return;
      destination = resolve(disguised: disguised);
      if (destination == WidgetPeriodActionDestination.wait) return;

      WidgetService.pendingAction.value = null;
      if (destination != WidgetPeriodActionDestination.startPeriod) return;

      _openAdShown = true;
      final profileNotifier = ref.read(userProfileProvider.notifier);
      final previousProfile = ref.read(userProfileProvider);
      final record = await ref
          .read(periodRecordsProvider.notifier)
          .startPeriod(DateTime.now());
      await profileNotifier.saveProfile(lastPeriodStart: record.startDate);
      // Kayıt sürerken aynı native tıklama yeniden geldiyse de tüket.
      WidgetService.pendingAction.value = null;
      if (!mounted) return;

      ref.read(routerProvider).go('/dashboard');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final messenger = _scaffoldMessengerKey.currentState;
        final messengerContext = _scaffoldMessengerKey.currentContext;
        if (messenger == null || messengerContext == null) return;
        final l10n = AppLocalizations.of(messengerContext)!;
        messenger.showSnackBar(SnackBar(
          content: Text(l10n.periodMarkedStarted),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () async {
              await ref
                  .read(periodRecordsProvider.notifier)
                  .deleteRecord(record.id);
              if (previousProfile != null) {
                await profileNotifier.updateProfile(previousProfile);
              } else {
                profileNotifier.refresh();
              }
            },
          ),
        ));
      });
    } catch (e) {
      debugPrint('[WIDGET] period action failed: $e');
      WidgetService.pendingAction.value = null;
    } finally {
      _widgetActionHandling = false;
    }
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

  void _onScreenProtectionChanged() => _applySecureScreen();

  void _applySecureScreen({bool? needsLock}) {
    final lock = needsLock ?? _needsLock;
    PrivacyScreenService.setSecureScreen(
      lock || ScreenProtection.enabled.value,
    );
  }

  Future<void> _resolveDisguise() async {
    final disguised = await DisguiseService.isDisguised();
    if (!mounted) return;
    setState(() {
      _isDisguisedCached = disguised;
      _decoyActive = disguised;
      _decoyResolved = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onQuickAction();
      _onWidgetAction();
    });
  }

  /// 24 saat sınırına tabi kayıt sonrası reklam.
  Future<void> _showOpenAd() async {
    if (_openAdShown || _suppressOpenAd) return;
    if (QuickActionService().pendingAction.value != null) return;
    if (WidgetService.pendingAction.value != null) return;
    if (PremiumService().isPremium) return;
    // Deneme ayında da reklamsız: "1 ay ücretsiz" vaadinin deneyimi tam
    // olmalı — reklam yalnız ücretsiz katmanda
    if (ref.read(accessProvider) != AccessLevel.free) return;
    // İlk ücretsiz açılışta geçiş açıklaması reklamın altında kaybolmasın.
    // Bu oturum reklamsız kalır; sonraki açılış normal sınıra döner.
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_trialEndNoticeKey) ?? false)) return;

    // Sıklık sınırı kayıt sonrasında da korunur. Kurulum anı için deneme
    // başlangıcı kullanılır — ilk açılışta sabitlenen tek tarih o.
    final installedAt = ref.read(trialStartProvider) ?? DateTime.now();
    if (!await AdService.canShowOpenAd(installedAt: installedAt)) return;
    if (!mounted) return;

    _openAdShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Activity/ViewController tamamen hazır olduktan sonra
      await Future.delayed(const Duration(seconds: 2));
      if (_suppressOpenAd) return;
      await AdService.initialize();
      await AdService.loadOpenAd();
      await AdService.showOpenAd();
    });
  }

  Future<void> _maybeShowTrialEndNotice() async {
    if (_trialEndNoticePending || _trialEndNoticeHandled || !mounted) return;
    final profile = ref.read(userProfileProvider);
    final access = ref.read(accessProvider);
    if (access != AccessLevel.free ||
        profile?.onboardingCompleted != true ||
        _isLocked ||
        _decoyActive) {
      return;
    }

    _trialEndNoticePending = true;
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool(_trialEndNoticeKey) ?? false;
    if (!shouldShowTrialEndNotice(
      access: access,
      alreadyShown: alreadyShown,
      onboardingCompleted: profile!.onboardingCompleted,
    )) {
      _trialEndNoticeHandled = alreadyShown;
      _trialEndNoticePending = false;
      return;
    }

    final navigatorContext = rootNavigatorKey.currentContext;
    if (!mounted || navigatorContext == null) {
      _trialEndNoticePending = false;
      return;
    }
    await prefs.setBool(_trialEndNoticeKey, true);
    _trialEndNoticeHandled = true;
    final l10n = AppLocalizations.of(navigatorContext)!;
    final showPlans = await showDialog<bool>(
      context: navigatorContext,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.inventory_2_outlined,
          color: AppColors.primaryStrong,
        ),
        title: Text(l10n.freeBadge),
        content: Text(
          '${l10n.paywallFreeSubtitle}\n\n${l10n.yourDataStays}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.continueFreeBtn),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.seePlans),
          ),
        ],
      ),
    );
    _trialEndNoticePending = false;
    if (showPlans == true && mounted) {
      ref.read(routerProvider).push('/paywall');
    }
  }

  void _onUnlocked() {
    setState(() => _isLocked = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onQuickAction();
      _onWidgetAction();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _accessRefreshTimer?.cancel();
    NotificationService().pendingAction.removeListener(_onNotificationAction);
    QuickActionService().pendingAction.removeListener(_onQuickAction);
    WidgetService.pendingAction.removeListener(_onWidgetAction);
    AdService.recordSavedRevision.removeListener(_onRecordSaved);
    PremiumService().isPremiumNotifier.removeListener(_onPremiumChanged);
    ScreenProtection.enabled.removeListener(_onScreenProtectionChanged);
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
    _applySecureScreen(needsLock: needs);
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onQuickAction();
        _onWidgetAction();
      });
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
        if (mounted && value != _isDisguisedCached) {
          setState(() => _isDisguisedCached = value);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final access = ref.watch(accessProvider);

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
            _applySecureScreen(needsLock: needs);
          }
        }
      });
    }
    if (access == AccessLevel.free &&
        profile?.onboardingCompleted == true &&
        !_trialEndNoticeHandled &&
        !_trialEndNoticePending) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _maybeShowTrialEndNotice(),
      );
    }

    return MaterialApp.router(
      title: 'Regl Takip',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
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
        final l10n = AppLocalizations.of(context)!;
        final locale = Localizations.localeOf(context).languageCode;
        final shortcutSignature = '$locale:$_isDisguisedCached';
        if (_decoyResolved && _shortcutSignature != shortcutSignature) {
          _shortcutSignature = shortcutSignature;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            QuickActionService().sync(
              disguised: _isDisguisedCached,
              quickLogTitle: l10n.shortcutQuickLog,
              todayTitle: l10n.shortcutToday,
            );
          });
        }
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
