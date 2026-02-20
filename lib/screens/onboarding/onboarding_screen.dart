import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/providers.dart';
import '../../models/user_profile.dart';
import 'widgets/onboarding_page.dart';

/// Main onboarding screen with a 4-page PageView.
///
/// Pages 1-3 are informational pages using [OnboardingPage].
/// Page 4 is a multi-step data-collection form that gathers
/// the user's name, birth date, last period date, cycle length,
/// and period length.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  // ---------------------------------------------------------------------------
  // Controllers & State
  // ---------------------------------------------------------------------------
  final PageController _mainPageController = PageController();
  final PageController _formPageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  int _currentMainPage = 0;
  int _currentFormStep = 0;
  static const int _totalInfoPages = 3;
  static const int _totalFormSteps = 5;

  // Form data
  DateTime? _birthDate;
  DateTime? _lastPeriodDate;
  double _cycleLength = 28;
  double _periodLength = 5;

  bool _isSaving = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    _mainPageController.dispose();
    _formPageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------
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
      // Go back to info pages
      _mainPageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Save & navigate
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // Date pickers
  // ---------------------------------------------------------------------------
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
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
      child: child!,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- Skip button (visible only on info pages) ---
              if (_currentMainPage < _totalInfoPages)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 16),
                    child: TextButton(
                      onPressed: () {
                        _mainPageController.animateToPage(
                          _totalInfoPages,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        l10n.skip,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 48),

              // --- Main PageView ---
              Expanded(
                child: PageView(
                  controller: _mainPageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => _currentMainPage = index);
                  },
                  children: [
                    // Page 1 - Welcome
                    OnboardingPage(
                      icon: Icons.favorite,
                      title: l10n.welcomeInfoTitle,
                      description: l10n.welcomeInfoDesc,
                      gradientColors: const [
                        Color(0xFFE91E63),
                        Color(0xFFAD1457),
                      ],
                    ),

                    // Page 2 - Track
                    OnboardingPage(
                      icon: Icons.calendar_month,
                      title: l10n.trackCycleTitle,
                      description: l10n.trackCycleDesc,
                      gradientColors: const [
                        Color(0xFF9C27B0),
                        Color(0xFF7B1FA2),
                      ],
                    ),

                    // Page 3 - Predict
                    OnboardingPage(
                      icon: Icons.auto_graph,
                      title: l10n.getPredictionsTitle,
                      description: l10n.getPredictionsDesc,
                      gradientColors: const [
                        Color(0xFFFF4081),
                        Color(0xFFC51162),
                      ],
                    ),

                    // Page 4 - Setup form
                    _buildSetupPage(),
                  ],
                ),
              ),

              // --- Bottom controls ---
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom controls: dots + button (info pages) or nothing (form page)
  // ---------------------------------------------------------------------------
  Widget _buildBottomControls() {
    final l10n = AppLocalizations.of(context)!;
    if (_currentMainPage >= _totalInfoPages) {
      // Form page has its own navigation
      return const SizedBox(height: 16);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 32, left: 32, right: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page indicator dots
          SmoothPageIndicator(
            controller: _mainPageController,
            count: _totalInfoPages + 1,
            effect: ExpandingDotsEffect(
              activeDotColor: Colors.white,
              dotColor: Colors.white.withValues(alpha: 0.35),
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
              spacing: 6,
            ),
          ),
          const SizedBox(height: 32),

          // Action button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: _GradientButton(
              label: _currentMainPage == _totalInfoPages - 1
                  ? l10n.startBtn
                  : l10n.next,
              onPressed: _nextMainPage,
            ),
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 400.ms)
              .slideY(
                begin: 0.2,
                end: 0,
                delay: 500.ms,
                duration: 400.ms,
              ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Page 4 : Setup form
  // ---------------------------------------------------------------------------
  Widget _buildSetupPage() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Title
          Text(
            l10n.letsKnowYou,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.2, end: 0, duration: 400.ms),

          const SizedBox(height: 8),

          // Step progress
          _buildStepProgress(),

          const SizedBox(height: 16),

          // Form steps PageView
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

          // Form navigation buttons
          _buildFormNavigation(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step progress indicator
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // Form navigation
  // ---------------------------------------------------------------------------
  Widget _buildFormNavigation() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        // Back button
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _prevFormStep,
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            label: Text(l10n.back),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Next / Complete button
        Expanded(
          child: SizedBox(
            height: 52,
            child: _GradientButton(
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

  // ---------------------------------------------------------------------------
  // Form step cards
  // ---------------------------------------------------------------------------

  /// Wraps form step content in a styled white card.
  Widget _formCard({required List<Widget> children}) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        )
            .animate()
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
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
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

  // ---- Step 1: Name ----
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
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }

  // ---- Step 2: Birth date ----
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _birthDate != null
                    ? AppColors.primary
                    : Colors.transparent,
                width: 2,
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

  // ---- Step 3: Last period date ----
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _lastPeriodDate != null
                    ? AppColors.primary
                    : Colors.transparent,
                width: 2,
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

  // ---- Step 4: Cycle length ----
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
            inactiveTrackColor: AppColors.primaryLight.withValues(alpha: 0.25),
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

  // ---- Step 5: Period length ----
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
            inactiveTrackColor: AppColors.primaryLight.withValues(alpha: 0.25),
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

// =============================================================================
// Gradient Button
// =============================================================================

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _GradientButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFFFF0F3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
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
    );
  }
}
