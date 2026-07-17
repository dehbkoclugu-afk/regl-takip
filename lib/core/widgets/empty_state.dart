import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Boş durum kompozisyon dili: yumuşak renkli daire zemin + ikon,
/// başlık, tek satır yönlendirme. "Soluk ikon + metin" dağınıklığı
/// yerine her boşluk aynı elden çıkmış görünür.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color accent;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.accent = AppColors.primaryStrong,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 34, color: accent),
        ),
        const SizedBox(height: 14),
        Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.tp(context))),
        const SizedBox(height: 6),
        Text(message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.ts(context))),
      ],
    );
  }
}
