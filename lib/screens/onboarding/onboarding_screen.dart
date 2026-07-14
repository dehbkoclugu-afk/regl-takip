
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/cycle_utils.dart';
import '../../providers/providers.dart';
import '../../models/user_profile.dart';
import 'widgets/onboarding_page.dart';
import '../../core/utils/motion.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _mainPageController = PageController();
  final PageController _formPageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  int _currentMainPage = 0;
  int _currentFormStep = 0;
  static const int _totalInfoPages = 1;
  static const int _totalFormSteps = 5;

  DateTime? _birthDate;
  DateTime? _lastPeriodDate;
  double _cycleLength = 28;
  double _periodLength = 5;

  bool _isSaving = false;

  @override
  void dispose() {
    _mainPageController.dispose();
    _formPageController.dispose();
    _nameController.dispose();
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
  /// hepsi lastPeriodStart'a bağlı) — bu adım zorunlu. İsim ve doğum tarihi
  /// isteğe bağlı: kimliğini paylaşmak istemeyen kullanıcı da geçebilmeli.
  bool get _canContinue {
    if (_currentFormStep == 2) return _lastPeriodDate != null;
    return true;
  }

  void _nextFormStep() {
    if (!_canContinue) return;
    if (_currentFormStep < _totalFormSteps - 1) {
      _formPageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _prevFormStep() {
    if (_currentFormStep > 0) {
      _formPageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _mainPageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
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
      );

      // En son: bildirim ve widget kurulumu kayıtları da görmüş olur
      await ref.read(userProfileProvider.notifier).updateProfile(profile);

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
        _prevFormStep();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryStrong, AppColors.secondaryStrong],
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
                      OnboardingPage(
                        icon: Icons.favorite,
                        title: l10n.welcomeInfoTitle,
                        description: l10n.welcomeInfoDesc,
                        gradientColors: const [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
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
          const SizedBox(height: 8),
          _buildStepProgress(),
          const SizedBox(height: 16),
          Expanded(
            child: PageView(
              controller: _formPageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentFormStep = index);
              },
              children: [
                _buildNameStep(),
                _buildBirthDateStep(),
                _buildLastPeriodStep(),
                _buildCycleLengthStep(),
                _buildPeriodLengthStep(),
              ],
            ),
          ),
          _buildFormNavigation(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.stepOfSteps(_currentFormStep + 1, _totalFormSteps),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: List.generate(_totalFormSteps, (index) {
            final isActive = index <= _currentFormStep;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.25),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFormNavigation() {
    final l10n = AppLocalizations.of(context)!;
    final canContinue = _canContinue;
    return Column(
      children: [
        // Zorunlu adımda buton neden kapalı, kullanıcı bilmeli
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: canContinue
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
        Row(
          children: [
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _isSaving ? null : _prevFormStep,
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                label: Text(l10n.back),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: _ActionButton(
                  label: _currentFormStep == _totalFormSteps - 1
                      ? l10n.completeBtn
                      : l10n.continueBtn,
                  onPressed: (_isSaving || !canContinue) ? null : _nextFormStep,
                  isLoading: _isSaving,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _formCard({required List<Widget> children}) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
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
            .slideX(begin: 0.05, end: 0, duration: 350.ms),
      ),
    );
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
        color: Colors.grey.shade50,
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

  Widget _stepIcon(IconData icon) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primaryStrong, AppColors.secondaryStrong],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }

  Widget _stepTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
      ),
    );
  }

  Widget _stepSubtitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }

  Widget _buildNameStep() {
    final l10n = AppLocalizations.of(context)!;
    return _formCard(
      children: [
        _stepIcon(Icons.person_outline_rounded),
        _stepTitle(l10n.enterName),
        _stepSubtitle(l10n.whatShouldWeCallYou),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _nextFormStep(),
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            hintText: l10n.yourName,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            prefixIcon: const Icon(Icons.person, color: AppColors.primary),
            filled: true,
            fillColor: Colors.grey.shade50,
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

  Widget _buildBirthDateStep() {
    final l10n = AppLocalizations.of(context)!;
    return _formCard(
      children: [
        _stepIcon(Icons.cake_outlined),
        _stepTitle(l10n.yourBirthDate),
        _stepSubtitle(l10n.birthDateHelp),
        _dateField(
          value: _birthDate,
          semanticsLabel: l10n.yourBirthDate,
          hint: l10n.selectDateHint,
          onTap: _pickBirthDate,
        ),
      ],
    );
  }

  Widget _buildLastPeriodStep() {
    final l10n = AppLocalizations.of(context)!;
    return _formCard(
      children: [
        _stepIcon(Icons.water_drop_outlined),
        _stepTitle(l10n.lastPeriodTitle),
        _stepSubtitle(l10n.lastPeriodHelp),
        _dateField(
          value: _lastPeriodDate,
          semanticsLabel: l10n.lastPeriodTitle,
          hint: l10n.selectDateHint,
          onTap: _pickLastPeriodDate,
        ),
      ],
    );
  }

  Widget _buildCycleLengthStep() {
    final l10n = AppLocalizations.of(context)!;
    return _formCard(
      children: [
        _stepIcon(Icons.loop_rounded),
        _stepTitle(l10n.cycleLengthTitle),
        _stepSubtitle(l10n.cycleLengthHelp),
        const SizedBox(height: 8),
        Text(
          l10n.nDays(_cycleLength.round()),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 12),
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
            value: _cycleLength,
            min: 18,
            max: 45,
            divisions: 27,
            label: l10n.nDays(_cycleLength.round()),
            semanticFormatterCallback: (v) => l10n.nDays(v.round()),
            onChanged: (v) => setState(() => _cycleLength = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('18', style: TextStyle(color: AppColors.textSecondary)),
              Text('28 (${l10n.averageLabel})',
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
              const Text('45', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodLengthStep() {
    final l10n = AppLocalizations.of(context)!;
    return _formCard(
      children: [
        _stepIcon(Icons.timelapse_rounded),
        _stepTitle(l10n.periodLengthTitle),
        _stepSubtitle(l10n.periodLengthHelp),
        const SizedBox(height: 8),
        Text(
          l10n.nDays(_periodLength.round()),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 12),
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
            value: _periodLength,
            min: 2,
            max: 10,
            divisions: 8,
            label: l10n.nDays(_periodLength.round()),
            semanticFormatterCallback: (v) => l10n.nDays(v.round()),
            onChanged: (v) => setState(() => _periodLength = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('2', style: TextStyle(color: AppColors.textSecondary)),
              Text('5 (${l10n.averageLabel})',
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
              const Text('10', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Gradyan üstünde duran opak beyaz birincil aksiyon butonu.
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return Material(
      color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(16),
      elevation: enabled ? 2 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: enabled
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.6),
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
