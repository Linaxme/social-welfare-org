import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/app_strings.dart';
import '../data/locale_provider.dart';
import '../data/org_settings.dart';
import '../models/models.dart';
import 'pdf_font_helper.dart';

class ReceiptService {
  static Future<pw.Document> buildPdf(DonationRecord donation) async {
    final regular = await PdfFontHelper.getRegular();
    final bold = await PdfFontHelper.getBold();
    final org = OrgSettings.instance.orgName;
    final s = AppStrings.current;

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
                _buildHeader(org, regular, bold, s),
                pw.SizedBox(height: 16),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      PdfFontHelper.fixBangla(s.donationReceipt),
                      style: pw.TextStyle(
                        font: bold,
                        fontSize: 14,
                        color: PdfColors.green900,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),
                _buildInfoSection(regular, bold, donation, s),
                pw.SizedBox(height: 16),
                _buildAmountSection(regular, bold, donation, s),
                pw.SizedBox(height: 16),
                _buildDetailsSection(regular, bold, donation, s),
                pw.Spacer(),
                _buildFooter(regular, bold, org, s),
              ],
            ),
          );
        },
      ),
    );
    return doc;
  }

  static pw.Widget _buildHeader(String org, pw.Font regular, pw.Font bold, AppStrings s) {
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
              LocaleProvider.instance.isBn ? 'স' : 'S',
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
            PdfFontHelper.fixBangla(org),
            style: pw.TextStyle(font: bold, fontSize: 18),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Center(
          child: pw.Text(
            PdfFontHelper.fixBangla(s.socialWelfareOrg),
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
    AppStrings s,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          _infoRow(regular, bold, s.receiptNo, donation.receiptNo),
          pw.Divider(height: 8, color: PdfColors.grey200),
          _infoRow(
            regular,
            bold,
            s.date,
            '${donation.paidAt.day}/${donation.paidAt.month}/${donation.paidAt.year}',
          ),
          pw.Divider(height: 8, color: PdfColors.grey200),
          _infoRow(regular, bold, s.donor, donation.donorName),
        ],
      ),
    );
  }

  static pw.Widget _buildAmountSection(
    pw.Font regular,
    pw.Font bold,
    DonationRecord donation,
    AppStrings s,
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
            PdfFontHelper.fixBangla(s.amount),
            style: pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            PdfFontHelper.fixBangla('${donation.amount} ${s.taka}'),
            style: pw.TextStyle(
              font: bold,
              fontSize: 24,
              color: PdfColors.green900,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            PdfFontHelper.fixBangla('(${_numberToWords(donation.amount)} ${s.takaOnly})'),
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
    AppStrings s,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          _infoRow(regular, bold, s.paymentMode, donation.paymentModeLabel),
          if (donation.note != null && donation.note!.isNotEmpty) ...[
            pw.Divider(height: 8, color: PdfColors.grey200),
            _infoRow(regular, bold, s.note, donation.note!),
          ],
          if (donation.enteredByName != null) ...[
            pw.Divider(height: 8, color: PdfColors.grey200),
            _infoRow(regular, bold, s.entryBy, donation.enteredByName!),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font regular, pw.Font bold, String org, AppStrings s) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            PdfFontHelper.fixBangla(s.thankYou),
            style: pw.TextStyle(font: bold, fontSize: 12, color: PdfColors.green800),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            PdfFontHelper.fixBangla(s.thankYouMsg),
            style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            PdfFontHelper.fixBangla(org),
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
            PdfFontHelper.fixBangla(label),
            style: pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey600),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            PdfFontHelper.fixBangla(value),
            style: pw.TextStyle(font: bold, fontSize: 11),
          ),
        ),
      ],
    );
  }

  static String _numberToWords(int number) {
    if (number == 0) return LocaleProvider.instance.isEn ? 'zero' : 'শূন্য';

    if (LocaleProvider.instance.isEn) {
      return _enNumberToWords(number);
    } else {
      return _bnNumberToWords(number);
    }
  }

  static String _enNumberToWords(int number) {
    if (number == 0) return '';
    final units = [
      '', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine',
      'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen',
      'seventeen', 'eighteen', 'nineteen'
    ];
    final tens = [
      '', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'
    ];

    if (number < 20) return units[number];
    if (number < 100) {
      final t = number ~/ 10;
      final u = number % 10;
      return '${tens[t]}${u > 0 ? ' ${units[u]}' : ''}';
    }
    if (number < 1000) {
      final h = number ~/ 100;
      final rest = number % 100;
      return '${units[h]} hundred${rest > 0 ? ' ${_enNumberToWords(rest)}' : ''}';
    }
    if (number < 100000) {
      final t = number ~/ 1000;
      final rest = number % 1000;
      return '${_enNumberToWords(t)} thousand${rest > 0 ? ' ${_enNumberToWords(rest)}' : ''}';
    }
    if (number < 10000000) {
      final l = number ~/ 100000;
      final rest = number % 100000;
      return '${_enNumberToWords(l)} lakh${rest > 0 ? ' ${_enNumberToWords(rest)}' : ''}';
    }
    final c = number ~/ 10000000;
    final rest = number % 10000000;
    return '${_enNumberToWords(c)} crore${rest > 0 ? ' ${_enNumberToWords(rest)}' : ''}';
  }

  static String _bnNumberToWords(int number) {
    if (number == 0) return '';

    const bn1to99 = [
      '', 'এক', 'দুই', 'তিন', 'চার', 'পাঁচ', 'ছয়', 'সাত', 'আট', 'নয়', 'দশ',
      'এগারো', 'বারো', 'তেরো', 'চৌদ্দ', 'পনেরো', 'ষোলো', 'সতেরো', 'আঠারো', 'উনিশ', 'বিশ',
      'একুশ', 'বাইশ', 'তেইশ', 'চব্বিশ', 'পঁচিশ', 'ছাব্বিশ', 'সাতাশ', 'আটাশ', 'উনত্রিশ', 'ত্রিশ',
      'একত্রিশ', 'বত্রিশ', 'তেত্রিশ', 'চৌত্রিশ', 'পঁয়ত্রিশ', 'ছত্রিশ', 'সাইত্রিশ', 'আটত্রিশ', 'উনচল্লিশ', 'চল্লিশ',
      'একচল্লিশ', 'বিয়াল্লিশ', 'তেতাল্লিশ', 'চুয়াল্লিশ', 'পঁয়তাল্লিশ', 'ছেচল্লিশ', 'সাতচল্লিশ', 'আটচল্লিশ', 'উনপঞ্চাশ', 'পঞ্চাশ',
      'একান্ন', 'বায়ান্ন', 'তিরান্ন', 'চুয়ান্ন', 'পঞ্চান্ন', 'ছাপ্পান্ন', 'সাতান্ন', 'আটান্ন', 'উনষাট', 'ষাট',
      'একষট্টি', 'বাষট্টি', 'তেষট্টি', 'চৌষট্টি', 'পঁয়ষট্টি', 'ছেষট্টি', 'সাতষট্টি', 'আটষট্টি', 'উনসত্তর', 'সত্তর',
      'একাত্তর', 'বাহাত্তর', 'তিয়াত্তর', 'চুয়াত্তর', 'পঁচাত্তর', 'ছেয়াত্তর', 'সাতাত্তর', 'আটাত্তর', 'উনাশি', 'আশি',
      'একাশি', 'বিরাশি', 'তিরাশি', 'চৌরাশি', 'পঁচাশি', 'ছিয়াশি', 'সাতাশি', 'আটাশি', 'উননব্বই', 'নব্বই',
      'একানব্বই', 'বিয়ানব্বই', 'তিরানব্বই', 'চুয়ানব্বই', 'পঁচানব্বই', 'ছেয়ানব্বই', 'সাতানব্বই', 'আটানব্বই', 'নিরানব্বই'
    ];

    if (number < 100) return bn1to99[number];
    if (number < 1000) {
      final h = number ~/ 100;
      final rest = number % 100;
      return '${bn1to99[h]} শত${rest > 0 ? ' ${_bnNumberToWords(rest)}' : ''}';
    }
    if (number < 100000) {
      final t = number ~/ 1000;
      final rest = number % 1000;
      return '${_bnNumberToWords(t)} হাজার${rest > 0 ? ' ${_bnNumberToWords(rest)}' : ''}';
    }
    if (number < 10000000) {
      final l = number ~/ 100000;
      final rest = number % 100000;
      return '${_bnNumberToWords(l)} লাখ${rest > 0 ? ' ${_bnNumberToWords(rest)}' : ''}';
    }
    final c = number ~/ 10000000;
    final rest = number % 10000000;
    return '${_bnNumberToWords(c)} কোটি${rest > 0 ? ' ${_bnNumberToWords(rest)}' : ''}';
  }

  static Future<void> preview(
    BuildContext context,
    DonationRecord donation,
  ) async {
    final s = AppStrings.current;
    try {
      final doc = await buildPdf(donation);
      final bytes = await doc.save();
      final filename = '${donation.receiptNo}.pdf';

      if (_isDesktopOrWeb) {
        await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: filename);
        if (kIsWeb) {
          await Future.delayed(const Duration(milliseconds: 150));
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${s.receiptDownload}: $filename')),
          );
        }
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'application/pdf', name: filename)],
          subject: s.donationReceipt,
          text: '${OrgSettings.instance.orgName}\n${donation.receiptNo}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${s.receiptFailed}: $e')),
        );
      }
    }
  }

  static bool get _isDesktopOrWeb {
    if (kIsWeb) return true;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }
}
