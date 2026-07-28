import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/access.dart';
import '../../../core/utils/adaptive_layout.dart';
import '../../../core/utils/motion.dart';
import '../../../providers/providers.dart';

/// Ana sayfayÄ± kapatan kÄ±sayol satÄ±rÄ±.
///
/// SayfanÄ±n sonunda Ã¶lÃ¼ bir alan kalÄ±yordu: iÃ§erik ekranÄ± doldurmuyor ve
/// altta yÃ¼zen Ã§ubuÄŸa kadar boÅŸluk uzuyordu. Oraya bilgi koymak yerine en
/// sÄ±k yapÄ±lan iÅŸi koyduk â€” bu ekranÄ±n iÅŸi "ne zaman?" sorusunu cevaplayÄ±p
/// kayÄ±t almak, ve kayÄ±t almanÄ±n yolu buraya kadar Ã¼Ã§ dokunuÅŸtu:
/// KayÄ±t Ekle â†’ gÃ¼nlÃ¼k ekranÄ± â†’ kategori. Bu satÄ±rla tek dokunuÅŸ.
///
/// DÃ¶rdÃ¼ de gÃ¼nlÃ¼k takip kapsamÄ±nda, yani Ã¼cretsiz katmanda kapalÄ±; giriÅŸ
/// kontrolÃ¼ ana sayfadaki diÄŸer iki kayÄ±t giriÅŸiyle aynÄ± (rotalar zaten
/// router redirect'iyle de korunuyor, bu kontrol kullanÄ±cÄ±ya baÅŸtan
/// sÃ¶ylemek iÃ§in).
class QuickAccessRow extends ConsumerWidget {
  const QuickAccessRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final items = <_QuickAccessItem>[
      _QuickAccessItem(
          Icons.water_drop_rounded, l10n.flow, AppColors.menstrual, '/flow'),
      _QuickAccessItem(
          Icons.face_rounded, l10n.symptoms, AppColors.secondary, '/symptoms'),
      _QuickAccessItem(
          Icons.mood_rounded, l10n.mood, AppColors.moodHappy, '/mood'),
      _QuickAccessItem(Icons.monitor_heart_rounded, l10n.dailyMeasurements,
          AppColors.temperature, '/measurements'),
    ];

    // BÃ¼yÃ¼k yazÄ±da dÃ¶rt sÃ¼tun etiketleri okunmaz hÃ¢le getiriyor: ikiÅŸerli
    // iki sÄ±ra, kalan ekranlarda tek sÄ±ra.
    final grid = usesLargeText(MediaQuery.textScalerOf(context))
        ? Column(
            children: [
              _row(context, ref, items.sublist(0, 2)),
              const SizedBox(height: 12),
              _row(context, ref, items.sublist(2)),
            ],
          )
        : _row(context, ref, items);

    return grid
        .animateSafe(context)
        .fadeIn(delay: 700.ms, duration: 600.ms)
        .slideY(begin: 0.15, end: 0, delay: 700.ms, duration: 600.ms);
  }

  Widget _row(
      BuildContext context, WidgetRef ref, List<_QuickAccessItem> items) {
    return Row(
      // Ãœstten hizalÄ±: "GÃ¼nlÃ¼k Ã–lÃ§Ã¼mler" gibi iki satÄ±ra sarkan etiketler
      // komÅŸularÄ±nÄ±n ikonunu aÅŸaÄŸÄ± itmemeli.
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: _tile(context, ref, items[i])),
        ],
      ],
    );
  }

  Widget _tile(BuildContext context, WidgetRef ref, _QuickAccessItem item) {
    return Semantics(
      button: true,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (!ensurePremiumAccess(context, ref)) return;
            // Ana sayfadan kayÄ±t her zaman bugÃ¼ne girilir
            ref.read(selectedDateProvider.notifier).state = DateTime.now();
            context.push(item.route);
          },
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(item.icon, color: item.color, size: 23),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: AppColors.ts(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAccessItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _QuickAccessItem(this.icon, this.label, this.color, this.route);
}

