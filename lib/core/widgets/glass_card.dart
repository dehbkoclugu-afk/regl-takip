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
    this.borderRadius = 24,
    this.blur = 12,
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

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
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
              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
            ),
            child: child,
          ),
        ),
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
    this.blur = 8,
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

    return Container(
      margin: margin,
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
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
          ),
        ),
      ),
    );
  }
}
