import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/app_strings.dart';
import '../data/org_settings.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/disbursement_repository.dart';
import '../repositories/donation_repository.dart';
import '../repositories/user_repository.dart';
import 'pdf_font_helper.dart';

class ReportExportService {
  // ─────────────── MEMBERS ───────────────

  static Future<void> exportMembersExcel(BuildContext context) async {
    final members = await UserRepository.instance.fetchMembers();
    final s = AppStrings.current;

    final excel = Excel.createExcel();
    final sheet = excel['Members'];
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    sheet.appendRow([
      TextCellValue(s.name),
      TextCellValue(s.phone),
      TextCellValue(s.role),
      TextCellValue(s.totalDonation),
      TextCellValue(s.status),
    ]);

    for (final m in members) {
      sheet.appendRow([
        TextCellValue(m.name),
        TextCellValue(m.phone),
        TextCellValue(m.roleLabel),
        IntCellValue(m.totalDonation),
        TextCellValue(m.isActive ? s.active : s.inactive),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;
    await _shareBytes(
      context,
      Uint8List.fromList(bytes),
      'somiti_members.xlsx',
    );
  }

  static Future<void> exportMembersPdf(BuildContext context) async {
    final members = await UserRepository.instance.fetchMembers();
    final regular = await PdfFontHelper.getRegular();
    final bold = await PdfFontHelper.getBold();
    final s = AppStrings.current;
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _header(s.memberListReport, regular, bold),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: [s.name, s.phone, s.role, s.totalDonation, s.status].map((e) => PdfFontHelper.fixBangla(e)).toList(),
            data: [
              for (final m in members)
                [
                  PdfFontHelper.fixBangla(m.name),
                  PdfFontHelper.fixBangla(m.phone),
                  PdfFontHelper.fixBangla(m.roleLabel),
                  PdfFontHelper.fixBangla('${m.totalDonation} ${s.taka}'),
                  PdfFontHelper.fixBangla(m.isActive ? s.active : s.inactive),
                ],
            ],
            headerStyle: pw.TextStyle(font: bold, fontSize: 10),
            cellStyle: pw.TextStyle(font: regular, fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal100),
          ),
        ],
      ),
    );

    await _sharePdf(context, doc.save(), 'somiti_members.pdf');
  }

  // ─────────────── COLLECTIONS ───────────────

  static Future<void> exportCollectionsExcel(
    BuildContext context, {
    required int year,
  }) async {
    final allDonations = await DonationRepository.instance.watchAll().first;
    final s = AppStrings.current;

    final excel = Excel.createExcel();
    final sheet = excel['Collections'];
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    sheet.appendRow([
      TextCellValue(s.date),
      TextCellValue(s.donor),
      TextCellValue(s.amount),
      TextCellValue(s.receipt),
      TextCellValue(s.paymentMode),
    ]);

    final list = allDonations.where((d) => d.paidAt.year == year).toList()
      ..sort((a, b) => b.paidAt.compareTo(a.paidAt));

    for (final d in list) {
      sheet.appendRow([
        TextCellValue('${d.paidAt.day}/${d.paidAt.month}/${d.paidAt.year}'),
        TextCellValue(d.donorName),
        IntCellValue(d.amount),
        TextCellValue(d.receiptNo),
        TextCellValue(d.paymentModeLabel),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;
    await _shareBytes(
      context,
      Uint8List.fromList(bytes),
      'somiti_collections_$year.xlsx',
    );
  }

  static Future<void> exportCollectionsPdf(
    BuildContext context, {
    required int year,
  }) async {
    final allDonations = await DonationRepository.instance.watchAll().first;
    final list = allDonations.where((d) => d.paidAt.year == year).toList()
      ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
    final regular = await PdfFontHelper.getRegular();
    final bold = await PdfFontHelper.getBold();
    final s = AppStrings.current;
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _header('$year — ${s.collectionReport}', regular, bold),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: [s.date, s.donor, s.amount, s.receipt, s.paymentMode].map((e) => PdfFontHelper.fixBangla(e)).toList(),
            data: [
              for (final d in list)
                [
                  '${d.paidAt.day}/${d.paidAt.month}/${d.paidAt.year}',
                  PdfFontHelper.fixBangla(d.donorName),
                  PdfFontHelper.fixBangla('${d.amount} ${s.taka}'),
                  d.receiptNo,
                  PdfFontHelper.fixBangla(d.paymentModeLabel),
                ],
            ],
            headerStyle: pw.TextStyle(font: bold, fontSize: 10),
            cellStyle: pw.TextStyle(font: regular, fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal100),
          ),
        ],
      ),
    );

    await _sharePdf(context, doc.save(), 'somiti_collections_$year.pdf');
  }

  // ─────────────── MONTHLY COLLECTION SUMMARY ───────────────

  static Future<void> exportMonthlyCollectionExcel(
    BuildContext context, {
    required int year,
  }) async {
    final summary = await DashboardRepository.instance
        .watchSummary(year: year)
        .first;
    final months = summary.monthlyCollections;
    final s = AppStrings.current;
    final names = s.monthNames;

    final excel = Excel.createExcel();
    final sheet = excel['Monthly'];
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    sheet.appendRow([
      TextCellValue(s.month),
      TextCellValue(s.collectionReport),
    ]);

    for (var i = 0; i < 12; i++) {
      sheet.appendRow([
        TextCellValue(names[i]),
        IntCellValue(months[i]),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;
    await _shareBytes(
      context,
      Uint8List.fromList(bytes),
      'somiti_monthly_$year.xlsx',
    );
  }

  static Future<void> exportMonthlyCollectionPdf(
    BuildContext context, {
    required int year,
  }) async {
    final summary = await DashboardRepository.instance
        .watchSummary(year: year)
        .first;
    final regular = await PdfFontHelper.getRegular();
    final bold = await PdfFontHelper.getBold();
    final months = summary.monthlyCollections;
    final s = AppStrings.current;
    final names = s.monthNames;
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _header('$year — ${s.monthlyCollection}', regular, bold),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: [s.month, s.amount].map((e) => PdfFontHelper.fixBangla(e)).toList(),
              data: [
                for (var i = 0; i < 12; i++)
                  [PdfFontHelper.fixBangla(names[i]), PdfFontHelper.fixBangla('${months[i]} ${s.taka}')],
              ],
              headerStyle: pw.TextStyle(font: bold, fontSize: 10),
              cellStyle: pw.TextStyle(font: regular, fontSize: 9),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.teal100),
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(PdfFontHelper.fixBangla('${s.total}:'), style: pw.TextStyle(font: bold, fontSize: 12)),
                pw.Text(
                  PdfFontHelper.fixBangla('${summary.totalCollection} ${s.taka}'),
                  style: pw.TextStyle(font: bold, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await _sharePdf(context, doc.save(), 'somiti_monthly_$year.pdf');
  }

  // ─────────────── HELP / DISBURSEMENTS ───────────────

  static Future<void> exportHelpExcel(BuildContext context) async {
    final disbursements =
        await DisbursementRepository.instance.watchAll().first;
    final s = AppStrings.current;

    final excel = Excel.createExcel();
    final sheet = excel['Help'];
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    sheet.appendRow([
      TextCellValue(s.name),
      TextCellValue(s.date),
      TextCellValue(s.reason),
      TextCellValue(s.amount),
      TextCellValue(s.phone),
      TextCellValue('NID'),
    ]);

    for (final h in disbursements) {
      sheet.appendRow([
        TextCellValue(h.beneficiaryName),
        TextCellValue('${h.date.day}/${h.date.month}/${h.date.year}'),
        TextCellValue(h.reasonLabel),
        IntCellValue(h.amount),
        TextCellValue(h.phone),
        TextCellValue(h.nidNumber),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;
    await _shareBytes(
      context,
      Uint8List.fromList(bytes),
      'somiti_help.xlsx',
    );
  }

  static Future<void> exportHelpPdf(BuildContext context) async {
    final disbursements =
        await DisbursementRepository.instance.watchAll().first;
    final regular = await PdfFontHelper.getRegular();
    final bold = await PdfFontHelper.getBold();
    final s = AppStrings.current;
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _header(s.helpDistributionReport, regular, bold),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: [s.name, s.date, s.reason, s.amount, s.phone].map((e) => PdfFontHelper.fixBangla(e)).toList(),
            data: [
              for (final h in disbursements)
                [
                  PdfFontHelper.fixBangla(h.beneficiaryName),
                  '${h.date.day}/${h.date.month}/${h.date.year}',
                  PdfFontHelper.fixBangla(h.reasonLabel),
                  PdfFontHelper.fixBangla('${h.amount} ${s.taka}'),
                  PdfFontHelper.fixBangla(h.phone),
                ],
            ],
            headerStyle: pw.TextStyle(font: bold, fontSize: 10),
            cellStyle: pw.TextStyle(font: regular, fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal100),
          ),
        ],
      ),
    );

    await _sharePdf(context, doc.save(), 'somiti_help.pdf');
  }

  // ─────────────── YEARLY SUMMARY ───────────────

  static Future<void> exportYearlySummaryExcel(
    BuildContext context, {
    required int year,
  }) async {
    final summary = await DashboardRepository.instance
        .watchSummary(year: year)
        .first;
    final allDonations = await DonationRepository.instance.watchAll().first;
    final disbursements =
        await DisbursementRepository.instance.watchAll().first;
    final members = await UserRepository.instance.fetchMembers();
    final s = AppStrings.current;

    final yearDonations = allDonations.where((d) => d.paidAt.year == year).toList();
    final yearHelp = disbursements.where((h) => h.date.year == year).toList();

    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    final summarySheet = excel[s.summary];
    summarySheet.appendRow([TextCellValue(s.subject), TextCellValue(s.amount)]);
    summarySheet.appendRow([TextCellValue(s.totalCollection), IntCellValue(summary.totalCollection)]);
    summarySheet.appendRow([TextCellValue(s.totalDonation), IntCellValue(summary.totalDonation)]);
    summarySheet.appendRow([TextCellValue(s.currentBalance), IntCellValue(summary.totalCollection - summary.totalDonation)]);
    summarySheet.appendRow([TextCellValue(s.totalMembers), IntCellValue(members.length)]);
    summarySheet.appendRow([TextCellValue('${s.total} ${s.collectionReport}'), IntCellValue(yearDonations.length)]);
    summarySheet.appendRow([TextCellValue('${s.total} ${s.helpDistribution}'), IntCellValue(yearHelp.length)]);

    final bytes = excel.encode();
    if (bytes == null) return;
    await _shareBytes(
      context,
      Uint8List.fromList(bytes),
      'somiti_yearly_$year.xlsx',
    );
  }

  static Future<void> exportYearlySummaryPdf(
    BuildContext context, {
    required int year,
  }) async {
    final summary = await DashboardRepository.instance
        .watchSummary(year: year)
        .first;
    final regular = await PdfFontHelper.getRegular();
    final bold = await PdfFontHelper.getBold();
    final s = AppStrings.current;
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _header('$year — ${s.yearlySummary}', regular, bold),
            pw.SizedBox(height: 24),
            _summaryRow(regular, bold, s.totalCollection, '${summary.totalCollection} ${s.taka}'),
            _summaryRow(regular, bold, s.totalDonation, '${summary.totalDonation} ${s.taka}'),
            _summaryRow(regular, bold, s.currentBalance,
                '${summary.totalCollection - summary.totalDonation} ${s.taka}'),
            _summaryRow(regular, bold, s.thisMonthCollection,
                '${summary.thisMonthCollection} ${s.taka}'),
          ],
        ),
      ),
    );

    await _sharePdf(context, doc.save(), 'somiti_yearly_$year.pdf');
  }

  // ─────────────── HELPERS ───────────────

  static pw.Widget _header(String title, pw.Font font, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          PdfFontHelper.fixBangla(OrgSettings.instance.orgName),
          style: pw.TextStyle(font: bold, fontSize: 14),
        ),
        pw.Text(
          PdfFontHelper.fixBangla(title),
          style: pw.TextStyle(font: font, fontSize: 12),
        ),
        pw.Divider(color: PdfColors.teal200),
      ],
    );
  }

  static pw.Widget _summaryRow(pw.Font font, pw.Font bold, String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(PdfFontHelper.fixBangla(label), style: pw.TextStyle(font: font, fontSize: 11)),
          pw.Text(PdfFontHelper.fixBangla(value), style: pw.TextStyle(font: bold, fontSize: 11)),
        ],
      ),
    );
  }

  static Future<void> _sharePdf(
    BuildContext context,
    Future<List<int>> bytesFuture,
    String filename,
  ) async {
    final bytes = await bytesFuture;
    await _shareBytes(context, Uint8List.fromList(bytes), filename);
  }

  static Future<void> _shareBytes(
    BuildContext context,
    Uint8List bytes,
    String filename,
  ) async {
    final s = AppStrings.current;
    try {
      if (kIsWeb) {
        await Printing.sharePdf(bytes: bytes, filename: filename);
        await Future.delayed(const Duration(milliseconds: 150));
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)], text: filename);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$filename ${s.created}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${s.exportFailed}: $e')),
        );
      }
    }
  }
}
