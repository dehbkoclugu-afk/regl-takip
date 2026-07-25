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
