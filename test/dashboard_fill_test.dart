import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ana sayfanın kapanış yerleşimi.
///
/// İçerik ekranı doldurmadığında artan alan sayfanın sonunda tek parça ölü
/// boşluk olarak kalıyordu. Kaydırma yokken dolguyu azaltmak bunu kapatmıyor
/// — görünen şey viewport'un kendisi — o yüzden düzeltme yapısal: sütun en az
/// viewport kadar uzun tutuluyor ve artan alan kısayol satırının üstündeki
/// esnek boşluğa veriliyor.
///
/// Buradaki test o yerleşimin kendisini sabitliyor: kaydırılamayan sayfada
/// kapanış satırı ekranın altına yaslanmalı, kaydırılabilir sayfada ise
/// yerleşim hiç değişmemeli.
Widget _page({required double contentHeight, required double bottomInset}) {
  return LayoutBuilder(
    builder: (context, viewport) => SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 1180,
            minHeight: viewport.maxHeight - bottomInset,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                SizedBox(
                    key: const Key('content'),
                    height: contentHeight,
                    width: double.infinity),
                const Spacer(),
                const SizedBox(
                    key: Key('footer'), height: 60, width: double.infinity),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  const viewportHeight = 800.0;
  const bottomInset = 100.0;

  Future<void> pump(WidgetTester tester, double contentHeight) async {
    tester.view.physicalSize = const Size(400, viewportHeight);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _page(
              contentHeight: contentHeight, bottomInset: bottomInset),
        ),
      ),
    );
  }

  testWidgets('kısa sayfada kapanış satırı ekranın altına yaslanır',
      (tester) async {
    await pump(tester, 200);

    final footer = tester.getRect(find.byKey(const Key('footer')));
    // Sütun viewport kadar uzun: kapanış satırının altı, gezinme çubuğuna
    // ayrılan payın hemen üstünde bitmeli — arkasında ölü alan kalmamalı.
    expect(footer.bottom, viewportHeight - bottomInset);

    // Artan alan içerikle kapanış arasında: içerik yukarıda kalıyor.
    final content = tester.getRect(find.byKey(const Key('content')));
    expect(content.bottom, 200);
    expect(footer.top, greaterThan(content.bottom));
  });

  testWidgets('uzun sayfada esnek boşluk yerleşimi değiştirmez',
      (tester) async {
    await pump(tester, 2000);

    final content = tester.getRect(find.byKey(const Key('content')));
    final footer = tester.getRect(find.byKey(const Key('footer')));
    // İçerik zaten taşıyor: Spacer sıfır pay alıyor, kapanış satırı
    // doğrudan içeriğin ardından geliyor.
    expect(footer.top, content.bottom);
  });
}
