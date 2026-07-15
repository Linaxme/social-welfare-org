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

    final excel = Excel.createExcel();
    final sheet = excel['Members'];
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    sheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Phone'),
      TextCellValue('Role'),
      TextCellValue('TotalDonation'),
      TextCellValue('Status'),
    ]);

    for (final m in members) {
      sheet.appendRow([
        TextCellValue(m.name),
        TextCellValue(m.phone),
        TextCellValue(m.roleLabel),
        IntCellValue(m.totalDonation),
        TextCellValue(m.isActive ? 'active' : 'inactive'),
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
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _header('মেম্বার তালিকা', regular, bold),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['নাম', 'ফোন', 'রোল', 'মোট ডোনেশন', 'স্ট্যাটাস'],
            data: [
              for (final m in members)
                [
                  m.name,
                  m.phone,
                  m.roleLabel,
                  '${m.totalDonation} টাকা',
                  m.isActive ? 'সক্রিয়' : 'নিষ্ক্রিয়',
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

    final excel = Excel.createExcel();
    final sheet = excel['Collections'];
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Donor'),
      TextCellValue('Amount'),
      TextCellValue('Receipt'),
      TextCellValue('Mode'),
    ]);

    final list = allDonations.where((d) => d.paidAt.year == year).toList()
      ..sort((a, b) => b.paidAt.compareTo(a.paidAt));

    for (final d in list) {
      sheet.appendRow([
        TextCellValue('${d.paidAt.day}/${d.paidAt.month}/${d.paidAt.year}'),
        TextCellValue(d.donorName),
        IntCellValue(d.amount),
        TextCellValue(d.receiptNo),
        TextCellValue(d.paymentMode),
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
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _header('$year — কালেকশন রিপোর্ট', regular, bold),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['তারিখ', 'দাতা', 'পরিমাণ', 'রিসিপ্ট', 'মোড'],
            data: [
              for (final d in list)
                [
                  '${d.paidAt.day}/${d.paidAt.month}/${d.paidAt.year}',
                  d.donorName,
                  '${d.amount} টাকা',
                  d.receiptNo,
                  d.paymentMode,
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
    const names = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
    ];

    final excel = Excel.createExcel();
    final sheet = excel['Monthly'];
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    sheet.appendRow([
      TextCellValue('Month'),
      TextCellValue('Collection'),
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
    const names = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
    ];
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _header('$year — মাসিক কালেকশন', regular, bold),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: ['মাস', 'পরিমাণ'],
              data: [
                for (var i = 0; i < 12; i++)
                  [names[i], '${months[i]} টাকা'],
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
                pw.Text('মোট:', style: pw.TextStyle(font: bold, fontSize: 12)),
                pw.Text(
                  '${summary.totalCollection} টাকা',
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

    final excel = Excel.createExcel();
    final sheet = excel['Help'];
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    sheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Date'),
      TextCellValue('Reason'),
      TextCellValue('Amount'),
      TextCellValue('Phone'),
      TextCellValue('NID'),
    ]);

    for (final h in disbursements) {
      sheet.appendRow([
        TextCellValue(h.beneficiaryName),
        TextCellValue('${h.date.day}/${h.date.month}/${h.date.year}'),
        TextCellValue(h.reason),
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
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _header('সাহায্য বিতরণ রিপোর্ট', regular, bold),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['নাম', 'তারিখ', 'কারণ', 'পরিমাণ', 'ফোন'],
            data: [
              for (final h in disbursements)
                [
                  h.beneficiaryName,
                  '${h.date.day}/${h.date.month}/${h.date.year}',
                  h.reason,
                  '${h.amount} টাকা',
                  h.phone,
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

    final yearDonations = allDonations.where((d) => d.paidAt.year == year).toList();
    final yearHelp = disbursements.where((h) => h.date.year == year).toList();

    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    // Summary sheet
    final summarySheet = excel['সারাংশ'];
    summarySheet.appendRow([TextCellValue('বিষয়'), TextCellValue('পরিমাণ')]);
    summarySheet.appendRow([TextCellValue('মোট কালেকশন'), IntCellValue(summary.totalCollection)]);
    summarySheet.appendRow([TextCellValue('মোট ডোনেশন'), IntCellValue(summary.totalDonation)]);
    summarySheet.appendRow([TextCellValue('বর্তমান ব্যালেন্স'), IntCellValue(summary.totalCollection - summary.totalDonation)]);
    summarySheet.appendRow([TextCellValue('মোট মেম্বার'), IntCellValue(members.length)]);
    summarySheet.appendRow([TextCellValue('মোট কালেকশন সংখ্যা'), IntCellValue(yearDonations.length)]);
    summarySheet.appendRow([TextCellValue('মোট সাহায্য সংখ্যা'), IntCellValue(yearHelp.length)]);

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
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _header('$year — বার্ষিক সারাংশ', regular, bold),
            pw.SizedBox(height: 24),
            _summaryRow(regular, bold, 'মোট কালেকশন', '${summary.totalCollection} টাকা'),
            _summaryRow(regular, bold, 'মোট ডোনেশন', '${summary.totalDonation} টাকা'),
            _summaryRow(regular, bold, 'বর্তমান ব্যালেন্স',
                '${summary.totalCollection - summary.totalDonation} টাকা'),
            _summaryRow(regular, bold, 'এই মাসের কালেকশন',
                '${summary.thisMonthCollection} টাকা'),
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
          OrgSettings.instance.orgName,
          style: pw.TextStyle(font: bold, fontSize: 14),
        ),
        pw.Text(
          title,
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
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 11)),
          pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 11)),
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
    try {
      if (kIsWeb) {
        await Printing.sharePdf(bytes: bytes, filename: filename);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)], text: filename);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$filename তৈরি হয়েছে')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('এক্সপোর্ট ব্যর্থ: $e')),
        );
      }
    }
  }
}
