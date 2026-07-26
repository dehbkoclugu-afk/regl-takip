import 'dart:math' as math;

import 'package:flutter/widgets.dart';

double effectiveTextScale(TextScaler scaler, {double referenceSize = 14}) =>
    scaler.scale(referenceSize) / referenceSize;

bool usesLargeText(TextScaler scaler) => effectiveTextScale(scaler) >= 1.3;

int adaptiveGridColumns({
  required double width,
  required double textScale,
  required int maxColumns,
  required double minCardWidth,
  double spacing = 12,
}) {
  final scaleGrowth = 1 + (math.max(1, textScale) - 1) * 0.35;
  final targetWidth = minCardWidth * scaleGrowth;
  return ((width + spacing) / (targetWidth + spacing))
      .floor()
      .clamp(1, maxColumns);
}

double scaledGridExtent(
  double baseExtent,
  double textScale, {
  double growth = 0.65,
}) =>
    baseExtent * (1 + (math.max(1, textScale) - 1) * growth);

/// Yüzen gezinme pill'inin kapladığı dikey alan.
///
/// Kabuk `extendBody: true` kullanıyor, yani sekme içerikleri pill'in altından
/// akıyor ve her ekran son öğesini pill'in üstünde tutacak kadar alt dolgu
/// vermek zorunda. Bu sayı elle yazıldığında kaçınılmaz olarak dağılıyordu —
/// istatistik 112, takvim ve ana sayfa 92 kullanıyordu — ve hiçbiri sistem
/// gezinme çubuğunun boşluğunu saymıyordu. Üç tuşlu gezinmesi olan bir
/// telefonda istatistikteki yasal uyarı bu yüzden ortasından kesiliyordu.
///
/// Pill'in yüksekliği kabuktaki ölçülerin toplamı: dikey kenar boşluğu 2×16,
/// iç dolgu 2×4, `NavigationBar`'ın kendi yüksekliği 80.
double bottomNavInset(BuildContext context) =>
    MediaQuery.viewPaddingOf(context).bottom + 120;
