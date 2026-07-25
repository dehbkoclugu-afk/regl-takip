import 'package:flutter/material.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/motion.dart';

/// Alt bar ve yan rail aynı hedefleri gösterir — liste tek yerde tutulur.
class _ShellDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _ShellDestination(this.icon, this.selectedIcon, this.label);
}

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  List<_ShellDestination> _destinations(AppLocalizations l10n) => [
        _ShellDestination(
            Icons.home_outlined, Icons.home_rounded, l10n.home),
        _ShellDestination(Icons.calendar_month_outlined,
            Icons.calendar_month_rounded, l10n.calendar),
        _ShellDestination(
            Icons.bar_chart_outlined, Icons.bar_chart_rounded, l10n.statistics),
        _ShellDestination(
            Icons.settings_outlined, Icons.settings_rounded, l10n.settings),
      ];

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      // Aynı sekmeye tekrar basmak o dalı köküne döndürür
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = AppColors.isDark(context);
    final destinations = _destinations(l10n);

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
                onDestinationSelected: _onDestinationSelected,
                labelType: NavigationRailLabelType.all,
                indicatorColor: AppColors.primary.withValues(alpha: 0.12),
                destinations: [
                  for (final d in destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon:
                          Icon(d.selectedIcon, color: AppColors.primaryStrong),
                      label: Text(d.label),
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
        // Opak pill: cam bırakıldı — son BackdropFilter da kalktı,
        // düşük donanımda kaydırma maliyeti sıfırlandı
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
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
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: AppColors.primary.withValues(alpha: 0.12),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              // Sekme geçişi durum bildirir, gösteri değil: 250 ms.
              // Sistem animasyonları kapalıysa anında.
              animationDuration:
                  context.motionDuration(const Duration(milliseconds: 250)),
              destinations: [
                for (final d in destinations)
                  NavigationDestination(
                    icon: Icon(d.icon, size: 24),
                    selectedIcon: Icon(d.selectedIcon,
                        size: 24, color: AppColors.primaryStrong),
                    label: d.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
