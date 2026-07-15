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
import 'pdf_font_helper.dart';

class ReceiptService {
  static Future<pw.Document> buildPdf(DonationRecord donation) async {
    final regular = await PdfFontHelper.getRegular();
    final bold = await PdfFontHelper.getBold();
    final org = OrgSettings.instance.orgName;

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(org, regular, bold),
                pw.SizedBox(height: 16),

                // Receipt title box
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'ডোনেশন রিসিপ্ট',
                      style: pw.TextStyle(
                        font: bold,
                        fontSize: 14,
                        color: PdfColors.green900,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),

                // Receipt info
                _buildInfoSection(regular, bold, donation),
                pw.SizedBox(height: 16),

                // Amount section
                _buildAmountSection(regular, bold, donation),
                pw.SizedBox(height: 16),

                // Details
                _buildDetailsSection(regular, bold, donation),
                pw.Spacer(),

                // Footer
                _buildFooter(regular, bold, org),
              ],
            ),
          );
        },
      ),
    );
    return doc;
  }

  static pw.Widget _buildHeader(String org, pw.Font regular, pw.Font bold) {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: PdfColors.green700, width: 2),
            ),
            child: pw.Text(
              'স',
              style: pw.TextStyle(
                font: bold,
                fontSize: 28,
                color: PdfColors.green700,
              ),
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            org,
            style: pw.TextStyle(font: bold, fontSize: 18),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Center(
          child: pw.Text(
            'সমাজ কল্যাণ সংগঠন',
            style: pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey600),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoSection(
    pw.Font regular,
    pw.Font bold,
    DonationRecord donation,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          _infoRow(regular, bold, 'রিসিপ্ট নং', donation.receiptNo),
          pw.Divider(height: 8, color: PdfColors.grey200),
          _infoRow(
            regular,
            bold,
            'তারিখ',
            '${donation.paidAt.day}/${donation.paidAt.month}/${donation.paidAt.year}',
          ),
          pw.Divider(height: 8, color: PdfColors.grey200),
          _infoRow(regular, bold, 'ডোনার', donation.donorName),
        ],
      ),
    );
  }

  static pw.Widget _buildAmountSection(
    pw.Font regular,
    pw.Font bold,
    DonationRecord donation,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.green200),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'পরিমাণ',
            style: pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${donation.amount} টাকা',
            style: pw.TextStyle(
              font: bold,
              fontSize: 24,
              color: PdfColors.green900,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '(${_numberToWords(donation.amount)} টাকা মাত্র)',
            style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDetailsSection(
    pw.Font regular,
    pw.Font bold,
    DonationRecord donation,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          _infoRow(regular, bold, 'পেমেন্ট মোড', donation.paymentMode),
          if (donation.note != null && donation.note!.isNotEmpty) ...[
            pw.Divider(height: 8, color: PdfColors.grey200),
            _infoRow(regular, bold, 'নোট', donation.note!),
          ],
          if (donation.enteredByName != null) ...[
            pw.Divider(height: 8, color: PdfColors.grey200),
            _infoRow(regular, bold, 'এন্ট্রি করেছেন', donation.enteredByName!),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font regular, pw.Font bold, String org) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            'ধন্যবাদ',
            style: pw.TextStyle(font: bold, fontSize: 12, color: PdfColors.green800),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            'সমাজ কল্যাণে আপনার মূল্যবান অবদানের জন্য আন্তরিক ধন্যবাদ।',
            style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            org,
            style: pw.TextStyle(font: bold, fontSize: 8, color: PdfColors.grey500),
          ),
        ),
      ],
    );
  }

  static pw.Widget _infoRow(
    pw.Font regular,
    pw.Font bold,
    String label,
    String value,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 80,
          child: pw.Text(
            label,
            style: pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey600),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(font: bold, fontSize: 11),
          ),
        ),
      ],
    );
  }

  /// Convert number to Bangla words (simplified).
  static String _numberToWords(int number) {
    if (number == 0) return 'শূন্য';

    final units = ['', 'এক', 'দুই', 'তিন', 'চার', 'পাঁচ', 'ছয়', 'সাত', 'আট', 'নয়'];
    final tens = ['', '', 'কুই', 'ত্রিশ', 'চল্লিশ', 'পঞ্চাশ', 'ষাট', 'সত্তর', 'আশি', 'নব্বই'];

    if (number < 10) return units[number];
    if (number < 100) {
      final t = number ~/ 10;
      final u = number % 10;
      return '${tens[t]}${u > 0 ? ' ${units[u]}' : ''}';
    }
    if (number < 1000) {
      final h = number ~/ 100;
      final rest = number % 100;
      return '${units[h]} শত${rest > 0 ? ' ${_numberToWords(rest)}' : ''}';
    }
    if (number < 100000) {
      final t = number ~/ 1000;
      final rest = number % 1000;
      return '${_numberToWords(t)} হাজার${rest > 0 ? ' ${_numberToWords(rest)}' : ''}';
    }
    if (number < 10000000) {
      final l = number ~/ 100000;
      final rest = number % 100000;
      return '${_numberToWords(l)} লাখ${rest > 0 ? ' ${_numberToWords(rest)}' : ''}';
    }
    final c = number ~/ 10000000;
    final rest = number % 10000000;
    return '${_numberToWords(c)} কোটি${rest > 0 ? ' ${_numberToWords(rest)}' : ''}';
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
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }
}
