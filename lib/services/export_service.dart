import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
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
  Future<String> exportCsv(
    List<PeriodRecord> periods,
    Map<String, DailyLog> dailyLogs,
    String locale,
  ) async {
    final dateFormat = DateFormat('yyyy-MM-dd');

    final headers = [
      'Date',
      'Flow',
      'Mood',
      'Symptoms',
      'Temperature',
      'Weight',
      'Water',
      'Sleep Quality',
      'Notes',
    ];

    // Sort daily logs by date
    final sortedLogs = dailyLogs.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final rows = <List<dynamic>>[headers];

    for (final log in sortedLogs) {
      rows.add([
        dateFormat.format(log.date),
        log.flowIntensity?.name ?? '',
        log.mood?.type.name ?? '',
        log.symptoms.length,
        log.temperature?.toStringAsFixed(1) ?? '',
        log.weight?.toStringAsFixed(1) ?? '',
        log.waterIntake,
        log.sleepQuality ?? '',
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

  /// Exports a PDF report. Returns the file path.
  Future<String> exportPdf(
    UserProfile profile,
    List<PeriodRecord> periods,
    Map<String, DailyLog> dailyLogs,
    String locale,
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
              'Period Tracker Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            'Generated: ${dateFormat.format(now)}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),

          // Profile summary
          pw.Header(level: 1, text: 'Profile Summary'),
          _buildProfileTable(profile),
          pw.SizedBox(height: 20),

          // Period history
          pw.Header(level: 1, text: 'Period History'),
          if (sortedPeriods.isEmpty)
            pw.Text('No period records found.')
          else
            _buildPeriodTable(sortedPeriods, dateFormat),
          pw.SizedBox(height: 20),

          // Last 30 days
          pw.Header(level: 1, text: 'Last 30 Days Summary'),
          if (recentLogs.isEmpty)
            pw.Text('No daily logs in the last 30 days.')
          else
            _buildDailyLogTable(recentLogs, dateFormat),
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

  pw.Widget _buildProfileTable(UserProfile profile) {
    return pw.TableHelper.fromTextArray(
      headerCount: 0,
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      data: [
        ['Name', profile.name.isNotEmpty ? profile.name : '-'],
        ['Average Cycle Length', '${profile.averageCycleLength} days'],
        ['Average Period Length', '${profile.averagePeriodLength} days'],
      ],
    );
  }

  pw.Widget _buildPeriodTable(
    List<PeriodRecord> periods,
    DateFormat dateFormat,
  ) {
    return pw.TableHelper.fromTextArray(
      headerAlignment: pw.Alignment.centerLeft,
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      headers: ['Start Date', 'End Date', 'Duration (days)'],
      data: periods.map((p) {
        return [
          dateFormat.format(p.startDate),
          p.endDate != null ? dateFormat.format(p.endDate!) : 'Ongoing',
          '${p.durationDays}',
        ];
      }).toList(),
    );
  }

  pw.Widget _buildDailyLogTable(
    List<DailyLog> logs,
    DateFormat dateFormat,
  ) {
    return pw.TableHelper.fromTextArray(
      headerAlignment: pw.Alignment.centerLeft,
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      headers: ['Date', 'Flow', 'Mood', 'Symptoms', 'Temp', 'Notes'],
      data: logs.map((log) {
        return [
          dateFormat.format(log.date),
          log.flowIntensity?.name ?? '-',
          log.mood?.type.name ?? '-',
          log.symptoms.length.toString(),
          log.temperature?.toStringAsFixed(1) ?? '-',
          (log.notes ?? '-').length > 30
              ? '${log.notes!.substring(0, 30)}...'
              : (log.notes ?? '-'),
        ];
      }).toList(),
    );
  }
}
