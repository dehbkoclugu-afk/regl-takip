import 'dart:ui';
import 'package:flutter/material.dart';

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
    // BackdropFilter Flutter'ın en pahalı efekti; kartların arkasında
    // çoğunlukla düz gradyan var — blur görsel fark yaratmıyor ama
    // orta segment Android'de kaydırma jank'ine yol açıyor.
    // Varsayılan 0: yarı saydam dolgu aynı görünümü bedava verir.
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
    final bgColor = isDark
        ? Colors.white.withValues(alpha: opacity * 0.9)
        : Colors.white.withValues(alpha: opacity + 0.55);
    final border = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.18)
            : const Color(0xFFBA90C6).withValues(alpha: 0.12));

    final inner = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                bgColor,
                bgColor.withValues(alpha: bgColor.a * 0.7),
              ],
            ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: border,
          width: borderWidth,
        ),
        // Düz kart dili: ince kenar + çok hafif zemin gölgesi.
        // Belirgin ışıma yalnız hero yüzeylerde (ring) — kart başına
        // ağır gölge görsel gürültüydü.
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: blur > 0
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: inner,
              )
            : inner,
      ),
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
    // Bkz. GlassCard.blur — varsayılan 0, blur yalnız bilinçli istekle
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
    final bgColor = backgroundColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.65));

    final inner = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : const Color(0xFFBA90C6).withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: child,
    );

    return Container(
      margin: margin,
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: blur > 0
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: inner,
              )
            : inner,
      ),
    );
  }
}
