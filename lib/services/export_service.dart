import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../core/utils/enum_labels.dart';
import '../models/period_record.dart';
import '../models/daily_log.dart';
import '../models/user_profile.dart';

class ExportService {
  /// CSV injection koruması: Excel/Sheets formül olarak yorumlamasın diye
  /// riskli karakterle başlayan hücrelere tek tırnak eklenir.
  static String sanitizeCsvCell(String value) {
    if (value.isEmpty) return value;
    const riskyPrefixes = ['=', '+', '-', '@', '\t', '\r'];
    if (riskyPrefixes.contains(value[0])) return "'$value";
    return value;
  }

  /// Exports daily log data as a CSV file. Returns the file path.
  /// Başlıklar ve enum değerleri arayüz dilini izler; semptomlar sayı
  /// değil ad listesi olarak yazılır (doktor çıktısında "3 semptom"ın
  /// bilgi değeri yoktu), ilaç adları da eklenir.
  Future<String> exportCsv(
    List<PeriodRecord> periods,
    Map<String, DailyLog> dailyLogs,
    AppLocalizations l10n,
  ) async {
    final dateFormat = DateFormat('yyyy-MM-dd');

    final headers = [
      l10n.dateLabel,
      l10n.flow,
      l10n.mood,
      l10n.symptoms,
      l10n.temperature,
      l10n.weight,
      l10n.waterIntake,
      l10n.sleepQuality,
      l10n.medication,
      l10n.notes,
    ];

    // Sort daily logs by date
    final sortedLogs = dailyLogs.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final rows = <List<dynamic>>[headers];

    for (final log in sortedLogs) {
      final symptomNames =
          log.symptoms.map((s) => EnumLabels.symptom(s.type, l10n)).join('; ');
      final medicationNames =
          log.medications.map((m) => m.name).where((n) => n.isNotEmpty).join('; ');
      rows.add([
        dateFormat.format(log.date),
        log.flowIntensity != null
            ? EnumLabels.flow(log.flowIntensity!, l10n)
            : '',
        log.mood != null ? EnumLabels.mood(log.mood!.type, l10n) : '',
        sanitizeCsvCell(symptomNames),
        log.temperature?.toStringAsFixed(1) ?? '',
        log.weight?.toStringAsFixed(1) ?? '',
        log.waterIntake,
        log.sleepQuality ?? '',
        sanitizeCsvCell(medicationNames),
        sanitizeCsvCell(log.notes ?? ''),
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/period_tracker_$timestamp.csv');
    await file.writeAsString(csv);

    return file.path;
  }

  static String buildCalendarIcs(
    List<PeriodRecord> periods, {
    required String eventTitle,
    DateTime? generatedAt,
  }) {
    String date(DateTime value) => DateFormat('yyyyMMdd').format(value);
    String timestamp(DateTime value) =>
        DateFormat("yyyyMMdd'T'HHmmss'Z'").format(value.toUtc());
    String escape(String value) => value
        .replaceAll('\\', '\\\\')
        .replaceAll('\n', '\\n')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;');

    final now = generatedAt ?? DateTime.now();
    final sorted = List<PeriodRecord>.from(periods)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final lines = <String>[
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Regl Takip//Cycle Calendar//EN',
      'CALSCALE:GREGORIAN',
      'METHOD:PUBLISH',
    ];
    for (final period in sorted) {
      final rawEnd = period.endDate ?? now;
      final end = rawEnd.isBefore(period.startDate)
          ? period.startDate
          : rawEnd;
      lines.addAll([
        'BEGIN:VEVENT',
        'UID:${period.id}@regl-takip',
        'DTSTAMP:${timestamp(now)}',
        'DTSTART;VALUE=DATE:${date(period.startDate)}',
        'DTEND;VALUE=DATE:${date(end.add(const Duration(days: 1)))}',
        'SUMMARY:${escape(eventTitle)}',
        'TRANSP:TRANSPARENT',
        'END:VEVENT',
      ]);
    }
    lines.add('END:VCALENDAR');
    return '${lines.join('\r\n')}\r\n';
  }

  /// Regl geçmişini standart, tüm gün etkinliklerinden oluşan ICS dosyası
  /// olarak dışa aktarır. DTEND iCalendar standardında kapsayıcı değildir.
  Future<String> exportCalendar(
    List<PeriodRecord> periods,
    AppLocalizations l10n,
  ) async {
    final contents = buildCalendarIcs(
      periods,
      eventTitle: l10n.periodDayLabel,
    );
    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/period_calendar_$timestamp.ics');
    await file.writeAsString(contents);
    return file.path;
  }

  /// Exports a PDF report. Returns the file path.
  Future<String> exportPdf(
    UserProfile profile,
    List<PeriodRecord> periods,
    Map<String, DailyLog> dailyLogs,
    AppLocalizations l10n,
  ) async {
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Default Helvetica'da Türkçe glifler (ğ, ş, İ, ı) yok — Nunito göm
    final fontData =
        await rootBundle.load('assets/fonts/Nunito-Variable.ttf');
    final nunito = pw.Font.ttf(fontData);
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: nunito,
        bold: nunito,
        italic: nunito,
        boldItalic: nunito,
      ),
    );

    // Sort periods by start date descending
    final sortedPeriods = List<PeriodRecord>.from(periods)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    // Last 30 days logs
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentLogs = dailyLogs.values
        .where((log) => log.date.isAfter(thirtyDaysAgo))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Text(
              l10n.reportTitle,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            '${l10n.reportGenerated}: ${dateFormat.format(now)}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),

          // Profile summary
          pw.Header(level: 1, text: l10n.profileSummary),
          _buildProfileTable(profile, l10n),
          pw.SizedBox(height: 20),

          // Period history
          pw.Header(level: 1, text: l10n.periodHistory),
          if (sortedPeriods.isEmpty)
            pw.Text(l10n.noCycleData)
          else
            _buildPeriodTable(sortedPeriods, dateFormat, l10n),
          pw.SizedBox(height: 20),

          // Last 30 days
          pw.Header(level: 1, text: l10n.last30DaysSummary),
          if (recentLogs.isEmpty)
            pw.Text(l10n.noDataYet)
          else
            _buildDailyLogTable(recentLogs, dateFormat, l10n),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/period_tracker_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  /// Shares a file using the system share sheet.
  Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }

  // --- Private helpers ---

  pw.Widget _buildProfileTable(UserProfile profile, AppLocalizations l10n) {
    return pw.TableHelper.fromTextArray(
      headerCount: 0,
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      data: [
        [l10n.name, profile.name.isNotEmpty ? profile.name : '-'],
        [l10n.cycleDuration, l10n.nDays(profile.averageCycleLength)],
        [l10n.periodDuration, l10n.nDays(profile.averagePeriodLength)],
      ],
    );
  }

  pw.Widget _buildPeriodTable(
    List<PeriodRecord> periods,
    DateFormat dateFormat,
    AppLocalizations l10n,
  ) {
    return pw.TableHelper.fromTextArray(
      headerAlignment: pw.Alignment.centerLeft,
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      headers: [l10n.startDateLabel, l10n.endDateLabel, l10n.durationDaysHeader],
      data: periods.map((p) {
        return [
          dateFormat.format(p.startDate),
          p.endDate != null ? dateFormat.format(p.endDate!) : l10n.ongoing,
          '${p.durationDays}',
        ];
      }).toList(),
    );
  }

  pw.Widget _buildDailyLogTable(
    List<DailyLog> logs,
    DateFormat dateFormat,
    AppLocalizations l10n,
  ) {
    return pw.TableHelper.fromTextArray(
      headerAlignment: pw.Alignment.centerLeft,
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      headers: [
        l10n.dateLabel,
        l10n.flow,
        l10n.mood,
        l10n.symptoms,
        l10n.temperature,
        l10n.notes,
      ],
      data: logs.map((log) {
        // Semptomlar ad olarak: "3" doktora hiçbir şey söylemiyordu.
        // Hücre metni pdf tablosunda kendiliğinden sarılır.
        final symptomNames = log.symptoms
            .map((s) => EnumLabels.symptom(s.type, l10n))
            .join(', ');
        return [
          dateFormat.format(log.date),
          log.flowIntensity != null
              ? EnumLabels.flow(log.flowIntensity!, l10n)
              : '-',
          log.mood != null ? EnumLabels.mood(log.mood!.type, l10n) : '-',
          symptomNames.isEmpty ? '-' : symptomNames,
          log.temperature?.toStringAsFixed(1) ?? '-',
          (log.notes ?? '-').length > 30
              ? '${log.notes!.substring(0, 30)}...'
              : (log.notes ?? '-'),
        ];
      }).toList(),
    );
  }
}
