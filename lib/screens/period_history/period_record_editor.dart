import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../models/period_record.dart';
import '../../providers/providers.dart';

/// Regl kaydı düzenleyici: başlangıç/bitiş tarihi değiştirme ve silme.
///
/// İstatistik ekranının içinde yaşıyordu, o ekran da ücretsiz katmanda
/// tamamen kilitli. Sonuç: ücretsiz kullanıcının tek yazma eylemi ana
/// ekrandaki "Reglim başladı" butonuydu ve 6 saniyelik geri al penceresi
/// kapandıktan sonra yanlış kaydı düzeltmesinin hiçbir yolu yoktu.
/// Takibin kendisi ücretsizse doğruluğu da ücretsiz olmalı — bu yüzden
/// düzenleyici ortak bir yere taşındı.


/// Düzenleme/silme sonrası profil tarihi kayıtların türevi olarak
/// eşitlenir: en yeni kaydın başlangıcı = lastPeriodStart. Elle çift
/// tutmanın ürettiği ayrışma (B-8) böylece tek yönlü akara bağlanır.
Future<void> _syncProfileToNewestRecord(WidgetRef ref) async {
  final records = ref.read(periodRecordsProvider);
  if (records.isEmpty) return;
  final newest = records.first; // provider startDate'e göre azalan sıralı
  final profile = ref.read(userProfileProvider);
  final current = profile?.lastPeriodStart;
  final same = current != null &&
      current.year == newest.startDate.year &&
      current.month == newest.startDate.month &&
      current.day == newest.startDate.day;
  if (!same) {
    await ref
        .read(userProfileProvider.notifier)
        .saveProfile(lastPeriodStart: newest.startDate);
  }
}

Future<void> showPeriodRecordEditor(
  BuildContext context,
  WidgetRef ref,
  PeriodRecord record,
) async {
  final l10n = AppLocalizations.of(context)!;
  final localeStr = Localizations.localeOf(context).toString();
  final dateFormat = DateFormat('d MMM yyyy', localeStr);
  final messenger = ScaffoldMessenger.of(context);

  var start = DateTime(
      record.startDate.year, record.startDate.month, record.startDate.day);
  var end = record.endDate != null
      ? DateTime(record.endDate!.year, record.endDate!.month,
          record.endDate!.day)
      : null;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        Future<void> pickStart() async {
          final picked = await showDatePicker(
            context: sheetContext,
            initialDate: start,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setSheetState(() {
              start = DateTime(picked.year, picked.month, picked.day);
              if (end != null && end!.isBefore(start)) end = start;
            });
          }
        }

        Future<void> pickEnd() async {
          final picked = await showDatePicker(
            context: sheetContext,
            initialDate: end ?? start,
            firstDate: start,
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setSheetState(
                () => end = DateTime(picked.year, picked.month, picked.day));
          }
        }

        Widget dateTile({
          required String label,
          required String value,
          required VoidCallback onTap,
          Widget? trailing,
        }) {
          return Semantics(
            button: true,
            label: label,
            value: value,
            child: Material(
              color: AppColors.bg(sheetContext),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ts(sheetContext))),
                      const Spacer(),
                      Text(value,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.tp(sheetContext))),
                      if (trailing != null) trailing,
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.sf(sheetContext),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
              24, 16, 24, 24 + MediaQuery.viewInsetsOf(sheetContext).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dv(sheetContext),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.editPeriodRecord,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tp(sheetContext))),
              const SizedBox(height: 16),
              dateTile(
                label: l10n.startDateLabel,
                value: dateFormat.format(start),
                onTap: pickStart,
              ),
              const SizedBox(height: 8),
              dateTile(
                label: l10n.endDateLabel,
                value: end != null ? dateFormat.format(end!) : l10n.ongoing,
                onTap: pickEnd,
                trailing: end != null
                    ? IconButton(
                        tooltip: l10n.ongoing,
                        icon: Icon(Icons.close_rounded,
                            size: 18, color: AppColors.ts(sheetContext)),
                        onPressed: () => setSheetState(() => end = null),
                      )
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  await ref
                      .read(periodRecordsProvider.notifier)
                      .updateRecordDates(record.id, start, end);
                  await _syncProfileToNewestRecord(ref);
                  messenger.showSnackBar(SnackBar(
                      content: Text(l10n.recordUpdated),
                      backgroundColor: AppColors.success));
                },
                child: Text(l10n.save),
              ),
              TextButton(
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.error),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: sheetContext,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      title: Text(l10n.deleteRecord),
                      content: Text(end != null
                          ? '${dateFormat.format(start)} - ${dateFormat.format(end!)}'
                          : '${dateFormat.format(start)} (${l10n.ongoing})'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.error),
                          child: Text(l10n.delete),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                  await ref
                      .read(periodRecordsProvider.notifier)
                      .deleteRecord(record.id);
                  await _syncProfileToNewestRecord(ref);
                  messenger.showSnackBar(SnackBar(
                      content: Text(l10n.recordDeleted),
                      backgroundColor: AppColors.success));
                },
                child: Text(l10n.deleteRecord),
              ),
            ],
          ),
        );
      },
    ),
  );
}
