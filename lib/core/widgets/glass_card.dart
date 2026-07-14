import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tarihsel not: bu bileşenler cam (blur + yarı saydamlık) ile doğdu.
/// Tasarım dili opak yüzeylere geçti — düz, sıcak zemin + ince kenar.
/// API geriye uyumlu: [blur] > 0 verilirse hâlâ cam çizer (bilinçli
/// istisnalar için), [opacity]/[gradient] eski çağrılar kırılmasın diye
/// duruyor ama varsayılan görünümde kullanılmıyor.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    // Kart dili: 20px — kontroller 16, sheet/hero 28
    this.borderRadius = 20,
    this.blur = 0,
    this.opacity = 0.15,
    this.borderColor,
    this.padding,
    this.margin,
    this.borderWidth = 1.0,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.cardDark : Colors.white;
    final border = borderColor ?? AppColors.dv(context);

    final inner = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? bgColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: border,
          width: borderWidth,
        ),
        // Düz kart dili: ince kenar + çok hafif zemin gölgesi.
        // Belirgin ışıma yalnız hero yüzeylerde (ring).
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: child,
    );

    return Container(
      margin: margin,
      // Opak yolda clip gerekmiyor: zaten yuvarlatılmış dekorasyon var.
      // Her kart için bir clip katmanı kaydırmada bedava değil.
      child: blur > 0
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: inner,
              ),
            )
          : inner,
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 0,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ?? (isDark ? AppColors.cardDark : Colors.white);

    final inner = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.dv(context),
          width: 1,
        ),
      ),
      child: child,
    );

    return Container(
      margin: margin,
      width: width,
      height: height,
      // Opak yolda clip gerekmiyor: zaten yuvarlatılmış dekorasyon var.
      // Her kart için bir clip katmanı kaydırmada bedava değil.
      child: blur > 0
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: inner,
              ),
            )
          : inner,
    );
  }
}
