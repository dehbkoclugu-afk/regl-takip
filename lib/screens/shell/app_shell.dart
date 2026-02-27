import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = AppColors.isDark(context);

    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 30,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: NavigationBar(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: (index) {
                      navigationShell.goBranch(
                        index,
                        initialLocation: index == navigationShell.currentIndex,
                      );
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    indicatorColor: AppColors.primary.withValues(alpha: 0.12),
                    indicatorShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                    animationDuration: const Duration(milliseconds: 400),
                    destinations: [
                      NavigationDestination(
                        icon: const Icon(Icons.home_outlined, size: 24),
                        selectedIcon: const Icon(
                          Icons.home_rounded,
                          size: 24,
                          color: AppColors.primary,
                        ),
                        label: l10n.home,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.calendar_month_outlined, size: 24),
                        selectedIcon: const Icon(
                          Icons.calendar_month_rounded,
                          size: 24,
                          color: AppColors.primary,
                        ),
                        label: l10n.calendar,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.bar_chart_outlined, size: 24),
                        selectedIcon: const Icon(
                          Icons.bar_chart_rounded,
                          size: 24,
                          color: AppColors.primary,
                        ),
                        label: l10n.statistics,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.settings_outlined, size: 24),
                        selectedIcon: const Icon(
                          Icons.settings_rounded,
                          size: 24,
                          color: AppColors.primary,
                        ),
                        label: l10n.settings,
                      ),
                    ],
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
