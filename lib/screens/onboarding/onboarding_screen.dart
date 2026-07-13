import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import '../../core/theme/app_colors.dart';
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

  void _nextFormStep() {
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
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final profile = UserProfile(
        name: _nameController.text.trim(),
        birthDate: _birthDate,
        lastPeriodStart: _lastPeriodDate,
        averageCycleLength: _cycleLength.round(),
        averagePeriodLength: _periodLength.round(),
        onboardingCompleted: true,
      );

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
    return Scaffold(
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
        child: _GlassButton(
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
    return Padding(
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
    );
  }

  Widget _buildFormNavigation() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _prevFormStep,
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            label: Text(l10n.back),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: _GlassButton(
              label: _currentFormStep == _totalFormSteps - 1
                  ? l10n.completeBtn
                  : l10n.continueBtn,
              onPressed: _isSaving ? null : _nextFormStep,
              isLoading: _isSaving,
            ),
          ),
        ),
      ],
    );
  }

  Widget _formCard({required List<Widget> children}) {
    return Center(
      child: SingleChildScrollView(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
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
            ),
          ),
        )
            .animateSafe(context)
            .fadeIn(duration: 350.ms)
            .slideX(begin: 0.05, end: 0, duration: 350.ms),
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
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            hintText: l10n.yourName,
            hintStyle: TextStyle(color: Colors.grey.shade400),
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
    final dateFormatter = DateFormat('dd MMMM yyyy', Localizations.localeOf(context).toString());
    return _formCard(
      children: [
        _stepIcon(Icons.cake_outlined),
        _stepTitle(l10n.yourBirthDate),
        _stepSubtitle(l10n.birthDateHelp),
        GestureDetector(
          onTap: _pickBirthDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _birthDate != null
                    ? AppColors.primary
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  _birthDate != null
                      ? dateFormatter.format(_birthDate!)
                      : l10n.selectDateHint,
                  style: TextStyle(
                    fontSize: 18,
                    color: _birthDate != null
                        ? AppColors.textPrimary
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastPeriodStep() {
    final l10n = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat('dd MMMM yyyy', Localizations.localeOf(context).toString());
    return _formCard(
      children: [
        _stepIcon(Icons.water_drop_outlined),
        _stepTitle(l10n.lastPeriodTitle),
        _stepSubtitle(l10n.lastPeriodHelp),
        GestureDetector(
          onTap: _pickLastPeriodDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _lastPeriodDate != null
                    ? AppColors.primary
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  _lastPeriodDate != null
                      ? dateFormatter.format(_lastPeriodDate!)
                      : l10n.selectDateHint,
                  style: TextStyle(
                    fontSize: 18,
                    color: _lastPeriodDate != null
                        ? AppColors.textPrimary
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
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
            onChanged: (v) => setState(() => _cycleLength = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('18', style: TextStyle(color: Colors.grey.shade500)),
              Text('28 (${l10n.averageLabel})',
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
              Text('45', style: TextStyle(color: Colors.grey.shade500)),
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
            onChanged: (v) => setState(() => _periodLength = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('2', style: TextStyle(color: Colors.grey.shade500)),
              Text('5 (${l10n.averageLabel})',
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
              Text('10', style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _GlassButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
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
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
