import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../data/org_settings.dart';
import '../models/models.dart';

class ReceiptService {
  static Future<pw.Document> buildPdf(DonationRecord donation) async {
    final font = await PdfGoogleFonts.notoSansBengaliRegular();
    final bold = await PdfGoogleFonts.notoSansBengaliBold();
    final org = OrgSettings.instance.orgName;

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    org,
                    style: pw.TextStyle(font: bold, fontSize: 16),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    'ডোনেশন রিসিপ্ট',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Divider(),
                pw.SizedBox(height: 12),
                _row(font, bold, 'রিসিপ্ট নং', donation.receiptNo),
                _row(
                  font,
                  bold,
                  'তারিখ',
                  '${donation.paidAt.day}/${donation.paidAt.month}/${donation.paidAt.year}',
                ),
                _row(font, bold, 'ডোনার', donation.donorName),
                _row(font, bold, 'পরিমাণ', '${donation.amount} টাকা'),
                _row(font, bold, 'পেমেন্ট', donation.paymentMode),
                if (donation.note != null && donation.note!.isNotEmpty)
                  _row(font, bold, 'নোট', donation.note!),
                if (donation.enteredByName != null)
                  _row(font, bold, 'এন্ট্রি', donation.enteredByName!),
                pw.Spacer(),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    'ধন্যবাদ — সমাজ কল্যাণে আপনার অবদান',
                    style: pw.TextStyle(font: font, fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    return doc;
  }

  static pw.Widget _row(
    pw.Font font,
    pw.Font bold,
    String label,
    String value,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 90,
            child: pw.Text(label, style: pw.TextStyle(font: bold, fontSize: 11)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  /// PC/Web → PDF ডাউনলোড · মোবাইল → শেয়ার শিট
  static Future<void> preview(
    BuildContext context,
    DonationRecord donation,
  ) async {
    try {
      final doc = await buildPdf(donation);
      final bytes = await doc.save();
      final filename = '${donation.receiptNo}.pdf';

      if (_isDesktopOrWeb) {
        await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: filename);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('রিসিপ্ট ডাউনলোড: $filename')),
          );
        }
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'application/pdf', name: filename)],
          subject: 'ডোনেশন রিসিপ্ট',
          text: '${OrgSettings.instance.orgName}\n${donation.receiptNo}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('রিসিপ্ট তৈরি ব্যর্থ: $e')),
        );
      }
    }
  }

  static bool get _isDesktopOrWeb {
    if (kIsWeb) return true;
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } catch (_) {
      return true;
    }
  }
}
