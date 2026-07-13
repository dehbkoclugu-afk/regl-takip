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

    // Geniş ekranda (tablet / masaüstü) alt bar yerine yan rail:
    // gerilmiş telefon düzeni yerine Material genişlik sınıfı davranışı
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
                labelType: NavigationRailLabelType.all,
                indicatorColor: AppColors.primary.withValues(alpha: 0.12),
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_rounded,
                        color: AppColors.primaryStrong),
                    label: Text(l10n.home),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.calendar_month_outlined),
                    selectedIcon: const Icon(Icons.calendar_month_rounded,
                        color: AppColors.primaryStrong),
                    label: Text(l10n.calendar),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.bar_chart_outlined),
                    selectedIcon: const Icon(Icons.bar_chart_rounded,
                        color: AppColors.primaryStrong),
                    label: Text(l10n.statistics),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings_rounded,
                        color: AppColors.primaryStrong),
                    label: Text(l10n.settings),
                  ),
                ],
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          // Opak pill: cam bırakıldı — son BackdropFilter da kalktı,
          // düşük donanımda kaydırma maliyeti sıfırlandı
          child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.divider,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
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
                          color: AppColors.primaryStrong,
                        ),
                        label: l10n.home,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.calendar_month_outlined, size: 24),
                        selectedIcon: const Icon(
                          Icons.calendar_month_rounded,
                          size: 24,
                          color: AppColors.primaryStrong,
                        ),
                        label: l10n.calendar,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.bar_chart_outlined, size: 24),
                        selectedIcon: const Icon(
                          Icons.bar_chart_rounded,
                          size: 24,
                          color: AppColors.primaryStrong,
                        ),
                        label: l10n.statistics,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.settings_outlined, size: 24),
                        selectedIcon: const Icon(
                          Icons.settings_rounded,
                          size: 24,
                          color: AppColors.primaryStrong,
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
    );
  }
}
