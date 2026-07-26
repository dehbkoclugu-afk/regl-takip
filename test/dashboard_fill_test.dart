import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ana sayfanın kapanış yerleşimi.
///
/// İçerik ekranı doldurmadığında artan alan sayfanın sonunda tek parça ölü
/// boşluk olarak kalıyordu. Kaydırma yokken dolguyu azaltmak bunu kapatmıyor
/// — görünen şey viewport'un kendisi. Çözüm: kapanış satırı kaydırma alanının
/// dışında, sabit bir alt şerit. Artan alan şeridin üstünde kalıyor, yani
/// sayfa sonundaki ölü boşluk yerine bölümler arası bir ayrım oluyor.
///
/// Bu yerleşime iki başarısız denemeden sonra gelindi. Önce `IntrinsicHeight`,
/// sonra `SliverFillRemaining(hasScrollBody: false)` denendi; ikisi de sütuna
/// sınırlı boy vermek için intrinsic ölçüm istiyor, ana sayfanın içindeki
/// geniş ekran `LayoutBuilder`'ı ise intrinsic ölçüm veremiyor. Sonuç her
/// karede layout hatasıydı: ana sayfa donuyor, kaydırma da dokunma da
/// çalışmıyordu.
///
/// Aşağıdaki sayfa bu yüzden bilerek bir `LayoutBuilder` taşıyor. Yerleşim
/// yeniden intrinsic ölçüm isteyen bir sarmalayıcıya geçerse bu testler
/// düşer.
Widget _page({required double contentHeight, required double bottomInset}) {
  return Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              // Gerçek sayfadaki geniş ekran dalının karşılığı.
              LayoutBuilder(
                builder: (context, constraints) => SizedBox(
                  key: const Key('content'),
                  height: contentHeight,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 8, bottom: bottomInset),
        child: const SizedBox(
            key: Key('footer'), height: 60, width: double.infinity),
      ),
    ],
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
          body: _page(contentHeight: contentHeight, bottomInset: bottomInset),
        ),
      ),
    );
  }

  testWidgets('kapanış satırı gezinme payının hemen üstünde durur',
      (tester) async {
    await pump(tester, 200);
    expect(tester.takeException(), isNull);

    final footer = tester.getRect(find.byKey(const Key('footer')));
    expect(footer.bottom, viewportHeight - bottomInset);

    // Artan alan içerikle kapanış arasında kalıyor: içerik yukarıda.
    final content = tester.getRect(find.byKey(const Key('content')));
    expect(content.bottom, 200);
    expect(footer.top, greaterThan(content.bottom));
  });

  testWidgets('içerik uzunken kapanış satırı yerinde kalır', (tester) async {
    await pump(tester, 2000);
    expect(tester.takeException(), isNull);

    final footer = tester.getRect(find.byKey(const Key('footer')));
    expect(footer.bottom, viewportHeight - bottomInset);
  });

  testWidgets('uzun sayfa gerçekten kaydırılabiliyor', (tester) async {
    // Donmanın belirtisi buydu: kaydırma ölmüştü.
    await pump(tester, 2000);
    final before = tester.getRect(find.byKey(const Key('content'))).top;
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pump();
    final after = tester.getRect(find.byKey(const Key('content'))).top;
    expect(after, lessThan(before));
    expect(tester.takeException(), isNull);
  });
}
