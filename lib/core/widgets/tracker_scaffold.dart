import 'package:flutter/material.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import '../theme/app_colors.dart';
import '../utils/adaptive_layout.dart';

/// 10 takip ekranının ortak iskeleti: Scaffold + AppBar + kaydırılan
/// gövde + alt aksiyon alanı + kaydedilmemiş değişiklik koruması.
///
/// Denetimde aynı hata sınıfları (dokunma hedefi, hayalet kayıt, korumasız
/// çıkış) 6-7 ekranda ayrı ayrı düzeltilmek zorunda kalmıştı — kalıp tek
/// yerde olsaydı tek düzeltmeydi. Bu bileşen o tek yer; dirty-guard artık
/// yalnız Notlar'da değil, kullanan her ekranda bedava.
class TrackerScaffold extends StatefulWidget {
  /// AppBar başlığı.
  final String title;

  /// Kaydırılan içerik. Padding'i ekran verir (alt aksiyon alanı
  /// iskeletten geldiği için 100+ px alt boşluklara gerek yok).
  final Widget body;

  /// Alt aksiyon alanı: kaydet butonu, varsa sil düğmesi. Ekran kurar —
  /// renk/etiket ekran kimliğine ait. null ise alan hiç çizilmez.
  final Widget? bottomBar;

  /// Kaydedilmemiş değişiklik var mı? true iken geri hareketi önce
  /// "değişiklikler kaydedilmedi" diyaloğuna takılır (Nielsen #5:
  /// sessiz veri kaybı yok).
  final bool isDirty;

  /// AppBar altı (ör. semptom ekranındaki kategori TabBar'ı).
  final PreferredSizeWidget? appBarBottom;

  /// İlaç ekranındaki "ekle" gibi tek birincil eylem.
  final Widget? floatingActionButton;

  const TrackerScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottomBar,
    this.isDirty = false,
    this.appBarBottom,
    this.floatingActionButton,
  });

  @override
  State<TrackerScaffold> createState() => _TrackerScaffoldState();
}

class _TrackerScaffoldState extends State<TrackerScaffold> {
  @override
  void initState() {
    super.initState();
    // Kaydet-ve-kapan akışlarında bildirim çubuğu kök ScaffoldMessenger'da
    // yaşıyor, yani onu açan ekran kapandıktan sonra da ayakta kalıyor.
    // Kullanıcı süre dolmadan başka bir izleyiciye girerse ruh hali ekranının
    // "Ruh hali kaydedildi" mesajı akış ekranının Kaydet butonunun üstünde
    // duruyordu — hem yanlış ekranda hem de birincil eylemi örterek.
    // Yeni bir izleyici açılırken önceki ekranın mesajı artık temizleniyor.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ScaffoldMessenger.of(context).clearSnackBars();
    });
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    return discard == true;
  }

  @override
  Widget build(BuildContext context) {
    final largeText = usesLargeText(MediaQuery.textScalerOf(context));
    return PopScope(
      canPop: !widget.isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmDiscard(context) && navigator.mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        appBar: AppBar(
          title: Text(widget.title,
              maxLines: largeText ? 2 : 1,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.tp(context))),
          toolbarHeight: largeText ? 80 : null,
          backgroundColor: AppColors.bg(context),
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.tp(context)),
          bottom: widget.appBarBottom,
        ),
        floatingActionButton: widget.floatingActionButton,
        body: Column(
          children: [
            Expanded(child: widget.body),
            if (widget.bottomBar != null)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: widget.bottomBar!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
