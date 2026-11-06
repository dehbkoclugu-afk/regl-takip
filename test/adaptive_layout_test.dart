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

  testWidgets('gezinme dolgusu sistem çubuğu boşluğunu da sayar',
      (tester) async {
    // Hata buydu: ekranlar sabit sayı yazıyordu (istatistik 112, takvim ve
    // ana sayfa 92) ve hiçbiri cihazın gezinme çubuğunu saymıyordu. Üç tuşlu
    // gezinmesi olan telefonda istatistikteki yasal uyarı kesiliyordu.
    Future<double> insetFor(double systemBar) async {
      late double result;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            viewPadding: EdgeInsets.only(bottom: systemBar),
          ),
          child: Builder(builder: (context) {
            result = bottomNavInset(context);
            return const SizedBox();
          }),
        ),
      );
      return result;
    }

    // Pill'in kendi yüksekliği: kenar boşluğu 16+24, iç dolgu 2x4, çubuk 80
    // — toplam 128; üstüne varsayılan 56 piksellik nefes payı (cihazda
    // gerçek pil yüksekliği nominal 80'i aştığı için büyütüldü)
    expect(await insetFor(0), 184);
    expect(await insetFor(48), 232);
  });
}
