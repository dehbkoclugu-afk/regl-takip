import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/period_record.dart';
import '../../providers/providers.dart';
import 'period_record_editor.dart';

/// Regl geçmişi — kayıtları görme, tarih düzeltme, silme.
///
/// Bilerek ücretsiz katmana açık. Ücretsiz sürümün vaadi regl takibi; bir
/// kaydı yanlış güne yazdıktan sonra düzeltememek o vaadi boşa çıkarıyordu.
/// İstatistik ekranı kendi zengin geçmiş kartını korur, düzenleyici ortak.
class PeriodHistoryScreen extends ConsumerWidget {
  const PeriodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final records = ref.watch(periodRecordsProvider);
    final localeStr = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('d MMM yyyy', localeStr);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(l10n.cycleHistory,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.tp(context))),
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.tp(context)),
      ),
      body: records.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: EmptyState(
                  icon: Icons.water_drop_outlined,
                  title: l10n.cycleHistory,
                  message: l10n.noCycleData,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: records.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AppColors.dv(context),
              ),
              itemBuilder: (context, index) => _RecordTile(
                record: records[index],
                dateFormat: dateFormat,
                onTap: () => showPeriodRecordEditor(
                    context, ref, records[index]),
              ),
            ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final PeriodRecord record;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  const _RecordTile({
    required this.record,
    required this.dateFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ongoing = record.endDate == null;
    final range = ongoing
        ? '${dateFormat.format(record.startDate)} (${l10n.ongoing})'
        : '${dateFormat.format(record.startDate)} - ${dateFormat.format(record.endDate!)}';

    return Semantics(
      button: true,
      label: '${l10n.editPeriodRecord}: $range',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          // 48 px asgari dokunma hedefi
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.periodDay, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  range,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tp(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(l10n.nDays(record.durationDays),
                  style: TextStyle(
                      fontSize: 13, color: AppColors.ts(context))),
              const SizedBox(width: 4),
              Icon(Icons.edit_rounded,
                  size: 16, color: AppColors.ts(context)),
            ],
          ),
        ),
      ),
    );
  }
}
