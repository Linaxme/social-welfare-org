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

import '../data/mock_data.dart';
import '../data/org_settings.dart';

class ReportExportService {
  static Future<void> exportMembersExcel(BuildContext context) async {
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

    for (final m in MockData.members) {
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

  static Future<void> exportCollectionsExcel(
    BuildContext context, {
    required int year,
  }) async {
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

    final list = MockData.donations.where((d) => d.paidAt.year == year).toList()
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

  static Future<void> exportHelpPdf(BuildContext context) async {
    final font = await PdfGoogleFonts.notoSansBengaliRegular();
    final bold = await PdfGoogleFonts.notoSansBengaliBold();
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            OrgSettings.instance.orgName,
            style: pw.TextStyle(font: bold, fontSize: 16),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'সাহায্য বিতরণ রিপোর্ট',
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['নাম', 'তারিখ', 'কারণ', 'পরিমাণ', 'ফোন'],
            data: [
              for (final h in MockData.disbursements)
                [
                  h.beneficiaryName,
                  '${h.date.day}/${h.date.month}/${h.date.year}',
                  h.reason,
                  '${h.amount}',
                  h.phone,
                ],
            ],
            headerStyle: pw.TextStyle(font: bold, fontSize: 10),
            cellStyle: pw.TextStyle(font: font, fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal100),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  static Future<void> exportMonthlyCollectionPdf(
    BuildContext context, {
    required int year,
  }) async {
    final font = await PdfGoogleFonts.notoSansBengaliRegular();
    final bold = await PdfGoogleFonts.notoSansBengaliBold();
    final months = MockData.dashboard.monthlyCollections;
    const names = [
      'জানুয়ারি',
      'ফেব্রুয়ারি',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর',
    ];
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              OrgSettings.instance.orgName,
              style: pw.TextStyle(font: bold, fontSize: 14),
            ),
            pw.Text(
              '$year — মাসিক কালেকশন',
              style: pw.TextStyle(font: font, fontSize: 12),
            ),
            pw.SizedBox(height: 16),
            for (var i = 0; i < 12; i++)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(names[i], style: pw.TextStyle(font: font)),
                    pw.Text(
                      '${months[i]} টাকা',
                      style: pw.TextStyle(font: bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => doc.save());
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
