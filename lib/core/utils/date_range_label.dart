import 'package:intl/intl.dart';

/// Dar bir kartta iki tarihi tek satırda tutmaya çalışan aralık etiketi.
///
/// Ana ekrandaki üç tahmin kartı ekran genişliğini üçe bölüyor ve verimli
/// pencere tek değer değil aralık taşıdığı için taşan tek kart oydu:
/// "25 Tem - 31 Tem" ikinci satıra sarkarken kırılma noktası tarihin
/// ortasına düşüyor ve "25 Tem - 31 / Tem" çıkıyordu — ay adı bir önceki
/// satırdaki günden kopmuş oluyordu.
///
/// İki önlem var. Aynı ay içindeki aralıkta ay adı bir kez yazılıyor
/// ("25 - 31 Tem"): en sık durum bu ve etiket belirgin biçimde kısalıyor.
/// Aylar farklıysa iki tarih de tam yazılıyor ama gün ile ay arasına
/// bölünmez boşluk konuyor, böylece sarma yalnız tireden oluyor ve tarihin
/// kendisi bütün kalıyor.
String fertileWindowLabel(DateTime start, DateTime end, String locale) {
  final dayMonth = DateFormat('d MMM', locale);
  final dayOnly = DateFormat('d', locale);
  String unbreakable(String value) => value.replaceAll(' ', '\u00A0');

  if (start.year == end.year && start.month == end.month) {
    return '${dayOnly.format(start)} - ${unbreakable(dayMonth.format(end))}';
  }
  return '${unbreakable(dayMonth.format(start))} - '
      '${unbreakable(dayMonth.format(end))}';
}
