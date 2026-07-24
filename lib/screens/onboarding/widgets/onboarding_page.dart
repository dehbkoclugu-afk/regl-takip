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

  /// Açıklamanın altında rozet olarak gösterilecek güvence metni.
  /// "Veriler yalnız cihazında" bu kategorideki en güçlü argüman ve
  /// kurulumun sonundaki onay diyaloğuna saklanmayacak kadar önemli.
  final String? assurance;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
    this.hero,
    this.assurance,
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

          if (assurance != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      assurance!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animateSafe(context)
                .fadeIn(delay: 600.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 500.ms),
          ],

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
