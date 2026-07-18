import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/motion.dart';

/// A reusable info page widget for onboarding screens (pages 1-3).
///
/// Displays a large animated icon inside a gradient circle,
/// a bold title, and a descriptive subtitle. All elements
/// animate in with staggered fade and slide effects.
class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;

  /// Verilirse gradyan daire + ikon yerine bu widget çizilir
  /// (ör. animasyonlu imza ring'i)
  final Widget? hero;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
    this.hero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // --- Hero görseli: özel widget ya da gradyan daire + ikon ---
          (hero ??
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              gradientColors.first.withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 80,
                      color: Colors.white,
                    ),
                  ))
              .animateSafe(context)
              .fadeIn(duration: 600.ms, curve: Curves.easeOut)
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),

          const SizedBox(height: 48),

          // --- Title ---
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          )
              .animateSafe(context)
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideY(
                begin: 0.3,
                end: 0,
                delay: 200.ms,
                duration: 500.ms,
                curve: Curves.easeOut,
              ),

          const SizedBox(height: 16),

          // --- Description ---
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.5,
                ),
          )
              .animateSafe(context)
              .fadeIn(delay: 400.ms, duration: 500.ms)
              .slideY(
                begin: 0.3,
                end: 0,
                delay: 400.ms,
                duration: 500.ms,
                curve: Curves.easeOut,
              ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
