import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Ana ekrandaki bilgi çiplerinin (faz, tahmin kartları) açtığı bilgi
/// penceresi. Önceden düz bir [AlertDialog] idi: başlık + gövde + "Tamam",
/// markanın yuvarlak/camsı diliyle hiç uyuşmuyordu. Bu ortak pencere renkli
/// gradyan ikon halkası, ortalanmış başlık ve tam genişlik kapatma
/// butonuyla üç yüzeyde de aynı, derli toplu görünümü verir.
Future<void> showInfoDialog(
  BuildContext context, {
  required Widget icon,
  required Color color,
  required String title,
  required String body,
  required String doneLabel,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (ctx) => _InfoDialog(
      icon: icon,
      color: color,
      title: title,
      body: body,
      doneLabel: doneLabel,
    ),
  );
}

class _InfoDialog extends StatelessWidget {
  final Widget icon;
  final Color color;
  final String title;
  final String body;
  final String doneLabel;

  const _InfoDialog({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.doneLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.sf(context),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.isDark(context)
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Renkli gradyan halka: konunun rengini taşır (faz/tahmin)
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.28),
                    color.withValues(alpha: 0.12),
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: icon,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.tp(context),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.6,
                color: AppColors.ts(context),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                // Uygulamanın buton dili: primaryStrong + beyaz (açık pembe
                // primary üzerine beyaz metnin kontrastı düşük kalıyordu).
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryStrong,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  doneLabel,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
