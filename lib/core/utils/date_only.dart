/// Takvim günü aritmetiği.
///
/// Yerel `DateTime` üzerinde `add(Duration(days: n))` ve
/// `difference().inDays` yaz saati geçişlerinde bir gün kayar: geçiş
/// haftasında bir "gün" 23 ya da 25 saattir. 1 Ekim + 28 gün Avrupa'da
/// 28 Ekim 23:00 çıkar (29 Ekim olmalı), 28→30 Mart farkı 1 gün çıkar.
/// Türkiye'de yaz saati olmadığı için görünmüyordu; de/fr/es kullanıcıları
/// ve yurt dışındaki kullanıcılar tahminleri bir gün kaymış görüyordu.
///
/// Buradaki yardımcılar saat değil takvim günüyle çalışır.
library;

/// Saat bilgisini atar: yerel gece yarısı.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// [d]'nin takvim gününe [days] gün ekler (negatif = geri). Sonuç yerel
/// gece yarısıdır; yaz saati geçişinden etkilenmez.
DateTime addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

/// [from]'dan [to]'ya kaç takvim günü olduğu (saatler yok sayılır).
int daysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;

/// İki tarih aynı takvim gününde mi?
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
