import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/providers/providers.dart';

/// Erişim modeli: 30 gün deneme → premium yoksa yalnız regl takibi.
void main() {
  ProviderContainer container({
    bool premium = false,
    DateTime? trialStart,
  }) =>
      ProviderContainer(overrides: [
        isPremiumProvider.overrideWith((ref) => premium),
        trialStartProvider.overrideWith((ref) => trialStart),
      ]);

  test('premium her durumda kazanır (deneme bitmiş olsa da)', () {
    final c = container(
        premium: true,
        trialStart: DateTime.now().subtract(const Duration(days: 400)));
    expect(c.read(accessProvider), AccessLevel.premium);
  });

  test('deneme penceresi içinde trial', () {
    final c = container(
        trialStart: DateTime.now().subtract(const Duration(days: 10)));
    expect(c.read(accessProvider), AccessLevel.trial);
    expect(c.read(trialDaysLeftProvider), 20);
  });

  test('30. günün sonunda free', () {
    final c = container(
        trialStart: DateTime.now().subtract(const Duration(days: 30)));
    expect(c.read(accessProvider), AccessLevel.free);
    expect(c.read(trialDaysLeftProvider), 0);
  });

  test('çok eski deneme: kalan gün negatife düşmez', () {
    final c = container(
        trialStart: DateTime.now().subtract(const Duration(days: 200)));
    expect(c.read(accessProvider), AccessLevel.free);
    expect(c.read(trialDaysLeftProvider), 0);
  });

  test('çözülmemiş deneme başlangıcı kullanıcıyı kısıtlamaz', () {
    final c = container(trialStart: null);
    expect(c.read(accessProvider), AccessLevel.trial);
  });
}
