import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/utils/adaptive_layout.dart';

void main() {
  test('etkin ölçek ve büyük yazı eşiği sistem tercihini izler', () {
    expect(effectiveTextScale(TextScaler.noScaling), 1);
    expect(effectiveTextScale(const TextScaler.linear(2)), 2);
    expect(usesLargeText(const TextScaler.linear(1.29)), isFalse);
    expect(usesLargeText(const TextScaler.linear(1.3)), isTrue);
  });

  test('dar ve büyük yazıda grid sütunu azalır', () {
    expect(
      adaptiveGridColumns(
        width: 320,
        textScale: 1,
        maxColumns: 3,
        minCardWidth: 92,
      ),
      3,
    );
    expect(
      adaptiveGridColumns(
        width: 320,
        textScale: 2,
        maxColumns: 3,
        minCardWidth: 92,
      ),
      2,
    );
    expect(
      adaptiveGridColumns(
        width: 320,
        textScale: 2,
        maxColumns: 2,
        minCardWidth: 140,
      ),
      1,
    );
  });

  test('sütun hesabı güvenli sınırlar içinde kalır', () {
    expect(
      adaptiveGridColumns(
        width: 1,
        textScale: 3,
        maxColumns: 2,
        minCardWidth: 140,
      ),
      1,
    );
    expect(
      adaptiveGridColumns(
        width: 1200,
        textScale: 1,
        maxColumns: 3,
        minCardWidth: 92,
      ),
      3,
    );
    expect(scaledGridExtent(100, 1), 100);
    expect(scaledGridExtent(100, 2), 165);
  });
}
