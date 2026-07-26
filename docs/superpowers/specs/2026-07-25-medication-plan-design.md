# Kalıcı ilaç planı tasarımı

## Amaç

İlaç adı, doz ve hatırlatma saatini belirli bir günlük kayda bağlı olmaktan
çıkarmak; “bugün alındı” bilgisini günlük geçmiş olarak korumak. Bildirimler
artık en son ilaç girilmiş günü aramayacak.

## Veri modeli

`UserProfile` iki yeni alan taşır:

- `medicationPlan`: adı, dozu ve hatırlatma saati bulunan
  `MedicationEntry` listesi. Bu listedeki `taken` her zaman `false` kabul
  edilir.
- `medicationPlanMigrated`: eski günlük kayıtlardan geçişin bir kez
  tamamlandığını belirtir.

Yeni Hive kutusu veya model eklenmez. `MedicationEntry` için mevcut adapter
kullanılır; profil zaten şifreli Hive kutusunda ve JSON yedeğinde bulunduğu
için plan aynı güvenlik ve yedekleme akışına girer.

## Eski veri geçişi

Profil henüz taşınmamışsa günlük kayıtlar yeniden eskiye taranır. İlaç içeren
en yeni kaydın adı, dozu ve saati plana kopyalanır; `taken` sıfırlanır.
Sonuç boş olsa bile `medicationPlanMigrated` işaretlenir. Böylece kullanıcı
planı sonradan tamamen silerse eski tarihsel kayıtlar bir sonraki açılışta
ilaçları geri getirmez.

Geçiş eski günlük kayıtları değiştirmez veya silmez.

## Ekran ve veri akışı

İlaç ekranı seçili gün için profil planını gösterir:

- ekleme ve kaydırarak silme profil planını günceller;
- onay kutusu yalnız seçili günün `DailyLog.medications` listesindeki
  `taken` değerini günceller;
- o gün henüz kayıt yoksa bütün plan `taken: false` ile hazırlanır;
- geçmiş bir güne bakıldığında o günün alınma durumu planla eşleştirilir;
- plandan silinen ilaç eski günlük kayıtlarda kalır.

Eşleme mevcut ürün davranışıyla uyumlu olarak ad + doz + saat üçlüsünü
kullanır. Aynı üçlüde iki ayrı ilaç desteklenmez; ekran aynı girdiyi ikinci
kez eklemeyi reddeder.

## Bildirimler

Tüm yeniden planlama noktaları `profile.medicationPlan` kullanır. İlaç planı
değiştiğinde profil notifier’ı bildirimleri yeniden kurar.

Bildirimde “alındı” eylemi seçildiğinde bugünün günlük kaydı yoksa profil
planından oluşturulur ve eşleşen ilaç alınmış işaretlenir. Profil planındaki
`taken` değeri değişmez.

## Hata ve boş durumlar

- Boş ilaç adı kaydedilmez.
- Plan boşsa mevcut boş durum kullanılır.
- Profil henüz yüklenmemişse ekran boş planla açılır; veri yazımı profil
  notifier’ı üzerinden güvenli varsayılan profil oluşturur.
- Bildirim yeniden planlama hatası ilaç planını geri almaz; mevcut hata
  yutma ve debug kaydı davranışı korunur.

## Doğrulama

- Profil JSON ve Hive adapter alanları planı ve geçiş işaretini korumalı.
- Geçiş en yeni günlük listeyi bir kez taşımalı ve `taken` değerini
  sıfırlamalı.
- Günlük plan birleştirme testi geçmiş `taken` değerini korumalı.
- Bildirim çağrı noktalarında “en son günlük ilaç listesi” taraması
  kalmamalı.
- Altı dilde mesaj ve generated getter eşliği korunmalı.

## Kapsam dışı

Çoklu günlük doz şeması, başlangıç/bitiş tarihi, stok takibi ve doz başına
ayrı alınma zamanları bu turda eklenmez. Mevcut tek ilaç + tek hatırlatma
saati modeli korunur.
