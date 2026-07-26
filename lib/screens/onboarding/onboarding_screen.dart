
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/adaptive_layout.dart';
import '../../core/utils/cycle_utils.dart';
import '../../providers/providers.dart';
import '../../models/enums.dart';
import '../../models/user_profile.dart';
import '../../services/hive_service.dart';
import '../../services/backup_service.dart';
import '../../services/notification_service.dart';
import '../../services/widget_service.dart';
import 'widgets/animated_ring_intro.dart';
import 'widgets/onboarding_page.dart';
import '../../core/utils/motion.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _mainPageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final ScrollController _formScrollController = ScrollController();

  /// Zorunlu alana kaydırıp odaklamak için: "Tamamla" kapalıyken kullanıcı
  /// hangi alanın eksik olduğunu aramak zorunda kalmamalı.
  final GlobalKey _lastPeriodKey = GlobalKey();

  int _currentMainPage = 0;
  static const int _totalInfoPages = 1;

  // Mod seçimi kurulumun ilk sorusu: hamile bir kullanıcı "döngü tahmini"
  // sorularıyla değil kendi akışıyla karşılanmalı (önceden ayarlarda
  // gömülüydü, varlığından haberdar olmak keşif istiyordu)
  TrackingMode _mode = TrackingMode.period;
  DateTime? _birthDate;
  DateTime? _lastPeriodDate;
  double _cycleLength = 28;
  double _periodLength = 5;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Açılışta kutular çözülemeyip sıfırdan başlandıysa (cihaz/yedek
    // geçişi) kullanıcı ilk burada karşılanır — nedeni açıklanmalı
    if (HiveService().dataResetPerformed) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showDataResetNotice());
    }
  }

  Future<void> _showDataResetNotice() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dataResetTitle),
        content: SingleChildScrollView(
          child: Text(l10n.dataResetBody,
              style: const TextStyle(fontSize: 14, height: 1.5)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _restoreFromBackup();
            },
            child: Text(l10n.restoreData),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreFromBackup() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    if (path == null) return;

    final BackupData data;
    try {
      data = BackupService(
        HiveService(),
      ).parseBackup(await File(path).readAsString());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invalidBackupFile),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.restoreConfirmTitle),
        content: Text(l10n.restoreConfirmBody(data.totalRecordCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.restore),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await BackupService(HiveService()).restoreBackup(data);
    ref.read(userProfileProvider.notifier).refresh();
    ref.read(periodRecordsProvider.notifier).refresh();
    ref.read(dailyLogProvider.notifier).refresh();

    final profile = HiveService().getUserProfile();
    if (profile != null) {
      final logs = HiveService().getAllDailyLogs();
      try {
        await NotificationService().rescheduleAll(
          profile,
          records: HiveService().getAllPeriodRecords(),
          medications: profile.medicationPlan,
          logs: logs,
        );
      } catch (_) {
        // Geri yükleme bildirim kurulumu başarısız olsa da geçerlidir.
      }
      await WidgetService.update(
        profile,
        HiveService().getAllPeriodRecords(),
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.backupRestored),
        backgroundColor: AppColors.success,
      ),
    );
    if (profile?.onboardingCompleted ?? false) {
      GoRouter.of(context).go('/dashboard');
    }
  }

  @override
  void dispose() {
    _mainPageController.dispose();
    _nameController.dispose();
    _formScrollController.dispose();
    super.dispose();
  }

  void _nextMainPage() {
    if (_currentMainPage < _totalInfoPages) {
      _mainPageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Son regl tarihi olmadan döngü matematiği çalışmaz (tahmin, faz, bildirim
  /// hepsi lastPeriodStart'a bağlı) — kurulumun tek zorunlu alanı bu. İsim ve
  /// doğum tarihi isteğe bağlı: kimliğini paylaşmak istemeyen de geçebilmeli.
  bool get _canComplete => _lastPeriodDate != null;

  /// Eksik zorunlu alana götürür. Tek ekranda form uzadığı için "Tamamla"nın
  /// neden kapalı olduğunu yazmak yetmiyor; alanın kendisi görünür olmalı.
  void _revealLastPeriodField() {
    final target = _lastPeriodKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: context.motionDuration(const Duration(milliseconds: 400)),
      curve: Curves.easeInOut,
      alignment: 0.2,
    );
  }

  void _backToIntro() {
    _mainPageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  /// Sistem izin diyaloğunun önüne uygulama içi gerekçe koyar.
  ///
  /// Android'de bildirim izni tek atıştır: reddedilirse sistem bir daha
  /// sormaz. Önceden diyalog soğuk açılışta, kurulum ekranının üstünde,
  /// hiçbir bağlam olmadan çıkıyordu — hatırlatma altyapısının tamamı o tek
  /// bağlamsız dokunuşa bağlıydı. "Şimdi değil" diyen kullanıcıya sistem
  /// diyaloğu hiç gösterilmez, böylece izin ileride ayarlardan istenebilir.
  Future<void> _askNotificationPermission() async {
    final l10n = AppLocalizations.of(context)!;
    final wants = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.notifications_active_rounded,
            color: AppColors.primaryStrong, size: 32),
        title: Text(l10n.notifPermissionTitle),
        content: Text(l10n.notifPermissionBody,
            style: const TextStyle(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.notNow),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.enableNotifications),
          ),
        ],
      ),
    );
    if (wants != true) return;
    try {
      await NotificationService().requestPermission();
    } catch (e) {
      debugPrint('[NOTIF] permission request failed: $e');
    }
  }

  Future<void> _completeOnboarding() async {
    if (_isSaving || _lastPeriodDate == null) return;
    final l10n = AppLocalizations.of(context)!;

    // Veri işleme onayı: kabul edilmeden profil oluşturulmaz
    final consented = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.consentTitle),
        content: SingleChildScrollView(
          child: Text(l10n.consentBody,
              style: const TextStyle(fontSize: 14, height: 1.5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.consentAccept),
          ),
        ],
      ),
    );
    if (consented != true || !mounted) return;

    setState(() => _isSaving = true);

    try {
      final periodLength = _periodLength.round();
      final lastPeriod = _lastPeriodDate!;

      // Hap modu paket başlangıcını ister; iptal edilirse mod hap kalır,
      // tarih ayarlardan sonradan girilebilir (dashboard chip'i o zamana
      // kadar görünmez — ayarlardaki akışla aynı davranış)
      DateTime? pillPackStart;
      if (_mode == TrackingMode.pill && mounted) {
        pillPackStart = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 28)),
          lastDate: DateTime.now(),
          helpText: l10n.pillPackStartLabel,
        );
        if (!mounted) return;
      }

      // Takvim, istatistik ve "reglim bitti" akışı profile'a değil
      // PeriodRecord'lara bakar — girilen son regl kayıt olarak da yazılmalı,
      // yoksa kullanıcı boş bir takvimle karşılaşır.
      final record =
          await ref.read(periodRecordsProvider.notifier).startPeriod(lastPeriod);
      final end = CycleUtils.completedPeriodEnd(
          lastPeriod, periodLength, DateTime.now());
      if (end != null) {
        await ref.read(periodRecordsProvider.notifier).endPeriod(record.id, end);
      }

      final profile = UserProfile(
        name: _nameController.text.trim(),
        birthDate: _birthDate,
        lastPeriodStart: lastPeriod,
        averageCycleLength: _cycleLength.round(),
        averagePeriodLength: periodLength,
        onboardingCompleted: true,
        trackingMode: _mode,
        // Gebelikte LMP = girilen son regl tarihi: hafta sayacı hemen doğru
        pregnancyStartDate:
            _mode == TrackingMode.pregnancy ? lastPeriod : null,
        pillPackStartDate: pillPackStart,
      );

      // En son: bildirim ve widget kurulumu kayıtları da görmüş olur
      await ref.read(userProfileProvider.notifier).updateProfile(profile);

      if (!mounted) return;
      // İzin ancak burada isteniyor: kullanıcı kurulumu bitirmiş, neyin
      // hatırlatılacağını biliyor. Sistem diyaloğu tek atış — önünde
      // gerekçe olmadan çıkarsa reddedilmesi çok daha olası.
      await _askNotificationPermission();

      if (!mounted) return;
      GoRouter.of(context).go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorOccurred(e.toString())),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: now,
      locale: Localizations.localeOf(context),
      builder: (context, child) => _datePickerTheme(child),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _pickLastPeriodDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      locale: Localizations.localeOf(context),
      builder: (context, child) => _datePickerTheme(child),
    );
    if (picked != null) {
      setState(() => _lastPeriodDate = picked);
    }
  }

  Theme _datePickerTheme(Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        dialogTheme: const DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
      ),
      child: child!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Sistem geri hareketi (Android predictive back) formda bir adım geri
    // almalı; ilk sayfada uygulamadan çıkışa izin verilir.
    return PopScope(
      canPop: _currentMainPage == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _isSaving) return;
        _backToIntro();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryStrong, AppColors.primaryDeep],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: PageView(
                    controller: _mainPageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentMainPage = index);
                    },
                    children: [
                      // İlk karşılama: imza ring segment segment çizilir
                      OnboardingPage(
                        icon: Icons.favorite,
                        title: l10n.welcomeInfoTitle,
                        description: l10n.welcomeInfoDesc,
                        gradientColors: const [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                        hero: const AnimatedRingIntro(),
                        // Gizlilik vaadi kurulumun sonundaki onay
                        // diyaloğunda gömülüydü; bu kategoride en güçlü
                        // argüman ve ilk ekranda görülmeli
                        assurance: l10n.privacyAssurance,
                      ),
                      _buildSetupPage(),
                    ],
                  ),
                ),
                _buildBottomControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final l10n = AppLocalizations.of(context)!;
    if (_currentMainPage >= _totalInfoPages) {
      return const SizedBox(height: 16);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 32, left: 32, right: 32),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: _ActionButton(
          label: l10n.startBtn,
          onPressed: _nextMainPage,
        ),
      ),
    );
  }

  /// Kurulumun tamamı tek kaydırmada.
  ///
  /// Önceden beş soru beş ayrı sayfaydı ve her biri "Devam"a basmayı
  /// gerektiriyordu: kullanıcı daha kaç soru kaldığını göremediği için
  /// kurulum baştan bitmek bilmez görünüyordu. Adım noktaları sayıyı
  /// gösteriyordu ama sorunun kendisi sayı değil, cevabı verilmemiş soruların
  /// tek tek karşına çıkması. Hepsi alt alta durunca form bir bakışta
  /// ölçülebiliyor ve varsayılanı kabul edilen alanlar dokunulmadan geçiliyor.
  ///
  /// Sıra bilinçli: zorunlu ve dolduranın işine yarayan alanlar üstte,
  /// isteğe bağlı kişisel alanlar altta — kaydırmayı yarıda bırakan da
  /// çalışan bir kuruluma sahip oluyor.
  Widget _buildSetupPage() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            l10n.letsKnowYou,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          )
              .animateSafe(context)
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.2, end: 0, duration: 400.ms),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: _formScrollController,
              child: _formCard(
                children: [
                  _buildModeSection(),
                  _sectionDivider(),
                  _buildLastPeriodSection(),
                  _sectionDivider(),
                  _buildDurationsSection(),
                  _sectionDivider(),
                  _buildNameSection(),
                  _sectionDivider(),
                  _buildBirthDateSection(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFormNavigation(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.textSecondary.withValues(alpha: 0.15),
      ),
    );
  }

  Widget _buildFormNavigation() {
    final l10n = AppLocalizations.of(context)!;
    final canComplete = _canComplete;
    final largeText = usesLargeText(MediaQuery.textScalerOf(context));
    final backButton = OutlinedButton.icon(
      onPressed: _isSaving ? null : _backToIntro,
      icon: const Icon(Icons.arrow_back_rounded, size: 20),
      label: Text(l10n.back),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        minimumSize: const Size(48, 52),
      ),
    );
    // Kapalı buton sessiz kalmıyor: dokunulunca eksik alana kaydırıyor.
    // Ekranın altındaki butondan yukarıdaki alanı aramak, tek ekranda
    // listenin uzamasıyla gelen tek risk.
    final completeButton = _ActionButton(
      label: l10n.completeBtn,
      onPressed: _isSaving
          ? null
          : (canComplete ? _completeOnboarding : _revealLastPeriodField),
      isEnabled: canComplete,
      isLoading: _isSaving,
    );
    return Column(
      children: [
        // Buton neden kapalı, kullanıcı bilmeli
        AnimatedSize(
          duration: context.motionDuration(const Duration(milliseconds: 200)),
          child: canComplete
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    l10n.selectDateToContinue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),
        if (largeText) ...[
          SizedBox(width: double.infinity, child: backButton),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: completeButton),
        ] else
          Row(
            children: [
              SizedBox(height: 52, child: backButton),
              const SizedBox(width: 12),
              Expanded(child: SizedBox(height: 52, child: completeButton)),
            ],
          ),
      ],
    );
  }

  /// Formun tamamını taşıyan tek kart. Kaydırma dışarıda ([_buildSetupPage]),
  /// burada olursa iç içe iki kaydırılabilir alan oluşur.
  Widget _formCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    )
        .animateSafe(context)
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.03, end: 0, duration: 350.ms);
  }

  /// Tarih seçici alan: dokunulabilir, ripple'lı, ekran okuyucuya buton
  /// olarak görünen ortak yapı (iki adım de aynısını kullanıyordu).
  Widget _dateField({
    required DateTime? value,
    required String semanticsLabel,
    required String hint,
    required VoidCallback onTap,
  }) {
    final formatter =
        DateFormat('dd MMMM yyyy', Localizations.localeOf(context).toString());
    final selected = value != null;
    return Semantics(
      button: true,
      label: semanticsLabel,
      value: selected ? formatter.format(value) : hint,
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selected ? formatter.format(value) : hint,
                    style: TextStyle(
                      fontSize: 18,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bölüm başlığı: ikon ve başlık aynı satırda, açıklama altında.
  ///
  /// Her soru ayrı sayfayken 64 piksellik yuvarlak ikon ve ortalanmış başlık
  /// sayfayı dolduruyordu. Beş bölüm alt alta gelince aynı ağırlık kaydırmayı
  /// gereksiz uzatıyor, o yüzden başlık sola yaslı ve tek satır.
  ///
  /// [optional] verildiğinde başlığın yanına "İsteğe bağlı" rozeti düşer.
  /// İsim ve doğum tarihi kodda zaten atlanabilirdi ama kullanıcıya
  /// söylenmiyordu: sağlık uygulamasında kişisel veri isteyen her alan
  /// zorunlu sanılıyor.
  Widget _sectionHeader(
    IconData icon,
    String title,
    String subtitle, {
    bool optional = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryStrong, AppColors.primaryDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              if (optional)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l10n.optionalField,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSection() {
    final l10n = AppLocalizations.of(context)!;
    final modes = [
      (TrackingMode.period, Icons.water_drop_rounded, l10n.modePeriod,
          l10n.modePeriodDesc),
      (TrackingMode.pregnancy, Icons.pregnant_woman_rounded,
          l10n.modePregnancy, l10n.modePregnancyDesc),
      (TrackingMode.pill, Icons.medication_rounded, l10n.modePill,
          l10n.modePillDesc),
      (TrackingMode.ttc, Icons.favorite_rounded, l10n.modeTtc,
          l10n.modeTtcDesc),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
            Icons.route_rounded, l10n.modeStepTitle, l10n.modeStepSubtitle),
        LayoutBuilder(
          builder: (context, constraints) {
            final textScale =
                effectiveTextScale(MediaQuery.textScalerOf(context));
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: adaptiveGridColumns(
                  width: constraints.maxWidth,
                  textScale: textScale,
                  maxColumns: 2,
                  minCardWidth: 120,
                  spacing: 10,
                ),
                mainAxisExtent: scaledGridExtent(130, textScale),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: modes.length,
              itemBuilder: (context, index) {
            final (mode, icon, title, desc) = modes[index];
            final isSelected = _mode == mode;
            return Semantics(
              button: true,
              selected: isSelected,
              label: '$title, $desc',
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _mode = mode),
                child: ExcludeSemantics(
                  child: AnimatedContainer(
                    duration: context.motionDuration(
                        const Duration(milliseconds: 200)),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryStrong
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon,
                            size: 26,
                            color: isSelected
                                ? AppColors.primaryStrong
                                : AppColors.textSecondary),
                        const SizedBox(height: 6),
                        Text(title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.primaryStrong
                                  : AppColors.textPrimary,
                            )),
                        const SizedBox(height: 2),
                        Text(desc,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10.5,
                              height: 1.2,
                              color: AppColors.textSecondary,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildNameSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(Icons.person_outline_rounded, l10n.enterName,
            l10n.whatShouldWeCallYou,
            optional: true),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            hintText: l10n.yourName,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            prefixIcon: const Icon(Icons.person, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildBirthDateSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
            Icons.cake_outlined, l10n.yourBirthDate, l10n.birthDateHelp,
            optional: true),
        _dateField(
          value: _birthDate,
          semanticsLabel: l10n.yourBirthDate,
          hint: l10n.selectDateHint,
          onTap: _pickBirthDate,
        ),
      ],
    );
  }

  Widget _buildLastPeriodSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      key: _lastPeriodKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(Icons.water_drop_outlined, l10n.lastPeriodTitle,
            l10n.lastPeriodHelp),
        _dateField(
          value: _lastPeriodDate,
          semanticsLabel: l10n.lastPeriodTitle,
          hint: l10n.selectDateHint,
          onTap: _pickLastPeriodDate,
        ),
        const SizedBox(height: 8),
        // Kurulumun tek zorunlu sorusu buydu ve tarihi hatırlamayan
        // kullanıcı sıkışıp kalıyordu. Yaklaşık seçim, uydurma bir kesinlik
        // girmekten iyi: tahminler zaten kayıt geldikçe kendini düzeltiyor.
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _pickApproximateLastPeriod,
            icon: const Icon(Icons.help_outline_rounded, size: 18),
            label: Text(l10n.dontRememberExactly),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryStrong),
          ),
        ),
      ],
    );
  }

  /// Yaklaşık son regl tarihi. Seçenekler hafta cinsinden çünkü kullanıcı
  /// "3 Temmuz" diye değil "geçen hafta" diye hatırlıyor.
  Future<void> _pickApproximateLastPeriod() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final options = <(String, int)>[
      (l10n.approxThisWeek, 3),
      (l10n.approxLastWeek, 10),
      (l10n.approxTwoWeeks, 17),
      (l10n.approxThreeWeeks, 24),
      (l10n.approxMonthOrMore, 32),
    ];

    final daysAgo = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(l10n.approxTitle,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(l10n.approxSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 8),
            // Renk açıkça veriliyor: sayfanın zemini AppColors.surface, yani
            // temadan bağımsız açık (kurulumun kartları da öyle). ListTile
            // başlığı ise rengini ortam temasından alıyordu ve koyu temada
            // açık renge düşüp beyaz zeminde okunmaz oluyordu. Sayfanın
            // başlığı ile açıklaması rengini zaten belirttiği için yalnız
            // seçenekler görünmezdi.
            for (final (label, days) in options)
              ListTile(
                title: Text(
                  label,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () => Navigator.pop(sheetContext, days),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (daysAgo == null || !mounted) return;
    setState(() =>
        _lastPeriodDate = today.subtract(Duration(days: daysAgo)));
  }

  /// Döngü ve regl uzunluğu tek bölümde: aynı biçimdeki iki slider ayrı
  /// sayfalardı, bir düşünce için iki kez "Devam"a basılıyordu. İkisi de
  /// varsayılanla geçilebilir, sonradan ayarlardan değiştirilebilir.
  Widget _buildDurationsSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(Icons.loop_rounded, l10n.durationsStepTitle,
            l10n.durationsStepHelp),
        _durationSlider(
          label: l10n.cycleLengthTitle,
          value: _cycleLength,
          min: 18,
          max: 45,
          divisions: 27,
          averageLabel: '28',
          onChanged: (v) => setState(() => _cycleLength = v),
        ),
        const SizedBox(height: 20),
        _durationSlider(
          label: l10n.periodLengthTitle,
          value: _periodLength,
          min: 2,
          max: 10,
          divisions: 8,
          averageLabel: '5',
          onChanged: (v) => setState(() => _periodLength = v),
        ),
      ],
    );
  }

  Widget _durationSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String averageLabel,
    required ValueChanged<double> onChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.nDays(value.round()),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryStrong,
              ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primaryLight.withValues(alpha: 0.3),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.15),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: l10n.nDays(value.round()),
            semanticFormatterCallback: (v) => l10n.nDays(v.round()),
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: usesLargeText(MediaQuery.textScalerOf(context))
              ? Column(
                  children: [
                    Text('$averageLabel (${l10n.averageLabel})',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${min.round()}',
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                        Text('${max.round()}',
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${min.round()}',
                        style: const TextStyle(
                            color: AppColors.textSecondary)),
                    Text('$averageLabel (${l10n.averageLabel})',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500)),
                    Text('${max.round()}',
                        style: const TextStyle(
                            color: AppColors.textSecondary)),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Görünüşü tıklanabilirlikten ayırır. Kurulumun "Tamamla" butonu eksik
  /// alan varken kapalı görünür ama dokunuşu yutmaz: eksik alana kaydırır.
  /// Varsayılan olarak [onPressed] ne diyorsa o.
  final bool? isEnabled;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = (isEnabled ?? onPressed != null) && !isLoading;
    return Material(
      color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(16),
      elevation: enabled ? 2 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primaryStrong,
                      ),
                    )
                  : Text(
                      label,
                      textAlign: TextAlign.center,
                      // primaryStrong: pastel primary beyaz zeminde 2.06:1 —
                      // buton metni okunmuyordu
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: enabled
                            ? AppColors.primaryStrong
                            : AppColors.primaryStrong.withValues(alpha: 0.6),
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
