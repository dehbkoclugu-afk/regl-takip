import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// The app shell that wraps the main content with a bottom navigation bar.
///
/// Uses [StatefulNavigationShell] from go_router to maintain the state
/// of each navigation branch independently (indexed stack).
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.sf(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  // Navigate to the initial location of the branch when
                  // tapping on the item that is already active.
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: AppColors.primary.withValues(alpha: 0.12),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              animationDuration: const Duration(milliseconds: 400),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined, size: 26),
                  selectedIcon: const Icon(
                    Icons.home_rounded,
                    size: 26,
                    color: AppColors.primary,
                  ),
                  label: l10n.home,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.calendar_month_outlined, size: 26),
                  selectedIcon: const Icon(
                    Icons.calendar_month_rounded,
                    size: 26,
                    color: AppColors.primary,
                  ),
                  label: l10n.calendar,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.bar_chart_outlined, size: 26),
                  selectedIcon: const Icon(
                    Icons.bar_chart_rounded,
                    size: 26,
                    color: AppColors.primary,
                  ),
                  label: l10n.statistics,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined, size: 26),
                  selectedIcon: const Icon(
                    Icons.settings_rounded,
                    size: 26,
                    color: AppColors.primary,
                  ),
                  label: l10n.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
