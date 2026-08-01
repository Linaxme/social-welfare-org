import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:excel/excel.dart' hide TextSpan;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../data/locale_provider.dart';
import '../data/org_settings.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/disbursement_repository.dart';
import '../repositories/donation_repository.dart';
import '../repositories/user_repository.dart';

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
    final s = AppStrings.current;

    final headers = [s.name, s.phone, s.role, s.totalDonation, s.status];
    final colRatios = [0.28, 0.22, 0.20, 0.18, 0.12];

    final allRows = [
      for (final m in members)
        [
          m.name,
          m.phone,
          m.roleLabel,
          Formatters.money(m.totalDonation),
          m.isActive ? s.active : s.inactive,
        ],
    ];

    const int rowsPerPage = 26;
    final totalPages = (allRows.length / rowsPerPage).ceil().clamp(1, 999);
    final doc = pw.Document();

    for (int p = 0; p < totalPages; p++) {
      final start = p * rowsPerPage;
      final end = (start + rowsPerPage).clamp(0, allRows.length);
      final pageRows = start < allRows.length ? allRows.sublist(start, end) : <List<String>>[];

      final pngBytes = await _renderReportTablePagePng(
        title: s.memberListReport,
        headers: headers,
        rows: pageRows,
        colRatios: colRatios,
        pageNum: p + 1,
        totalPages: totalPages,
        totalLabel: p == totalPages - 1 ? '${s.totalMembers}:' : null,
        totalValue: p == totalPages - 1 ? Formatters.toDigits('${members.length}') : null,
      );

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (ctx) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Image(pw.MemoryImage(pngBytes), fit: pw.BoxFit.contain),
          ),
        ),
      );
    }

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
    final s = AppStrings.current;

    final headers = [s.date, s.donor, s.amount, s.receipt, s.paymentMode];
    final colRatios = [0.18, 0.32, 0.20, 0.15, 0.15];

    final allRows = [
      for (final d in list)
        [
          '${Formatters.toDigits('${d.paidAt.day}')}/${Formatters.toDigits('${d.paidAt.month}')}/${Formatters.toDigits('${d.paidAt.year}')}',
          d.donorName,
          Formatters.money(d.amount),
          d.receiptNo,
          d.paymentModeLabel,
        ],
    ];

    final totalAmount = list.fold<int>(0, (sum, item) => sum + item.amount);
    const int rowsPerPage = 26;
    final totalPages = (allRows.length / rowsPerPage).ceil().clamp(1, 999);
    final doc = pw.Document();

    for (int p = 0; p < totalPages; p++) {
      final start = p * rowsPerPage;
      final end = (start + rowsPerPage).clamp(0, allRows.length);
      final pageRows = start < allRows.length ? allRows.sublist(start, end) : <List<String>>[];

      final pngBytes = await _renderReportTablePagePng(
        title: '${Formatters.toDigits('$year')} — ${s.collectionReport}',
        headers: headers,
        rows: pageRows,
        colRatios: colRatios,
        pageNum: p + 1,
        totalPages: totalPages,
        totalLabel: p == totalPages - 1 ? '${s.totalCollection}:' : null,
        totalValue: p == totalPages - 1 ? Formatters.money(totalAmount) : null,
      );

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (ctx) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Image(pw.MemoryImage(pngBytes), fit: pw.BoxFit.contain),
          ),
        ),
      );
    }

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
    final months = summary.monthlyCollections;
    final s = AppStrings.current;
    final names = s.monthNames;

    final headers = [s.month, s.amount];
    final colRatios = [0.50, 0.50];

    final allRows = [
      for (var i = 0; i < 12; i++)
        [
          names[i],
          Formatters.money(months[i]),
        ],
    ];

    final pngBytes = await _renderReportTablePagePng(
      title: '${Formatters.toDigits('$year')} — ${s.monthlyCollection}',
      headers: headers,
      rows: allRows,
      colRatios: colRatios,
      pageNum: 1,
      totalPages: 1,
      totalLabel: '${s.totalCollection}:',
      totalValue: Formatters.money(summary.totalCollection),
    );

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Image(pw.MemoryImage(pngBytes), fit: pw.BoxFit.contain),
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
    final s = AppStrings.current;

    final headers = [s.name, s.date, s.reason, s.amount, s.phone];
    final colRatios = [0.28, 0.18, 0.22, 0.18, 0.14];

    final allRows = [
      for (final h in disbursements)
        [
          h.beneficiaryName,
          '${Formatters.toDigits('${h.date.day}')}/${Formatters.toDigits('${h.date.month}')}/${Formatters.toDigits('${h.date.year}')}',
          h.reasonLabel,
          Formatters.money(h.amount),
          h.phone,
        ],
    ];

    final totalDisbursed = disbursements.fold<int>(0, (sum, item) => sum + item.amount);
    const int rowsPerPage = 26;
    final totalPages = (allRows.length / rowsPerPage).ceil().clamp(1, 999);
    final doc = pw.Document();

    for (int p = 0; p < totalPages; p++) {
      final start = p * rowsPerPage;
      final end = (start + rowsPerPage).clamp(0, allRows.length);
      final pageRows = start < allRows.length ? allRows.sublist(start, end) : <List<String>>[];

      final pngBytes = await _renderReportTablePagePng(
        title: LocaleProvider.instance.isEn ? 'Aid & Welfare Disbursement Report' : 'সহায়তা ও বিতরণ রিপোর্ট',
        headers: headers,
        rows: pageRows,
        colRatios: colRatios,
        pageNum: p + 1,
        totalPages: totalPages,
        totalLabel: p == totalPages - 1 ? '${s.totalDonation}:' : null,
        totalValue: p == totalPages - 1 ? Formatters.money(totalDisbursed) : null,
      );

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (ctx) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Image(pw.MemoryImage(pngBytes), fit: pw.BoxFit.contain),
          ),
        ),
      );
    }

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
    final s = AppStrings.current;

    final headers = [s.subject, s.amount];
    final colRatios = [0.60, 0.40];

    final allRows = [
      [s.totalCollection, Formatters.money(summary.totalCollection)],
      [s.totalDonation, Formatters.money(summary.totalDonation)],
      [s.currentBalance, Formatters.money(summary.totalCollection - summary.totalDonation)],
      [s.thisMonthCollection, Formatters.money(summary.thisMonthCollection)],
    ];

    final pngBytes = await _renderReportTablePagePng(
      title: '${Formatters.toDigits('$year')} — ${s.yearlySummary}',
      headers: headers,
      rows: allRows,
      colRatios: colRatios,
      pageNum: 1,
      totalPages: 1,
      totalLabel: '${s.currentBalance}:',
      totalValue: Formatters.money(summary.totalCollection - summary.totalDonation),
    );

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Image(pw.MemoryImage(pngBytes), fit: pw.BoxFit.contain),
        ),
      ),
    );

    await _sharePdf(context, doc.save(), 'somiti_yearly_$year.pdf');
  }

  // ─────────────── CANVAS REPORT RENDERER ───────────────

  static Future<Uint8List> _renderReportTablePagePng({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
    required List<double> colRatios,
    required int pageNum,
    required int totalPages,
    String? totalLabel,
    String? totalValue,
  }) async {
    const double width = 1240.0;
    const double height = 1754.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
    final orgName = OrgSettings.instance.orgName;

    // Background - Clean White Page
    final bgPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Top Header Banner (Emerald / Dark Green Gradient)
    final headerRect = Rect.fromLTWH(0, 0, width, 140);
    final headerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF005A3C), Color(0xFF007A52)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(headerRect);
    canvas.drawRect(headerRect, headerPaint);

    // Org Name in Header
    final orgTp = TextPainter(
      text: TextSpan(
        text: orgName,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    orgTp.layout(maxWidth: width - 350);
    orgTp.paint(canvas, const Offset(40, 24));

    // Report Title in Header
    final titleTp = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFFD1FAE5),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titleTp.layout(maxWidth: width - 350);
    titleTp.paint(canvas, const Offset(40, 68));

    // Page Number & Date in Top Right
    final dateNow = DateTime.now();
    final dateStr = 'তারিখ: ${Formatters.toDigits('${dateNow.day}')}/${Formatters.toDigits('${dateNow.month}')}/${Formatters.toDigits('${dateNow.year}')}';
    final pageStr = 'পৃষ্ঠা $pageNum / $totalPages';

    final topRightTp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(text: '$dateStr\n', style: const TextStyle(fontSize: 14, color: Color(0xFFD1FAE5))),
          TextSpan(text: pageStr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    topRightTp.layout();
    topRightTp.paint(canvas, Offset(width - topRightTp.width - 40, 34));

    // Table Container Box
    double y = 160;
    const double tableMargin = 40.0;
    final double tableWidth = width - (tableMargin * 2);

    // Table Header Row
    const double headerHeight = 44.0;
    final tableHeaderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tableMargin, y, tableWidth, headerHeight),
      const Radius.circular(8),
    );
    final tableHeaderBg = Paint()..color = const Color(0xFFE6F4EA);
    canvas.drawRRect(tableHeaderRect, tableHeaderBg);

    // Header Cell Titles
    double currentX = tableMargin;
    for (int i = 0; i < headers.length; i++) {
      final colW = tableWidth * colRatios[i];
      final headTp = TextPainter(
        text: TextSpan(
          text: headers[i],
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004D34),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      headTp.layout(maxWidth: colW - 16);
      headTp.paint(canvas, Offset(currentX + 10, y + (headerHeight - headTp.height) / 2));
      currentX += colW;
    }

    y += headerHeight + 4;

    // Table Rows
    const double rowHeight = 46.0;
    final linePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    for (int r = 0; r < rows.length; r++) {
      final isEven = r % 2 == 0;
      final rowRect = Rect.fromLTWH(tableMargin, y, tableWidth, rowHeight);
      final rowBg = Paint()..color = isEven ? const Color(0xFFFFFFFF) : const Color(0xFFF8FAFC);
      canvas.drawRect(rowRect, rowBg);
      canvas.drawLine(Offset(tableMargin, y + rowHeight), Offset(tableMargin + tableWidth, y + rowHeight), linePaint);

      currentX = tableMargin;
      final rowData = rows[r];
      for (int c = 0; c < rowData.length && c < colRatios.length; c++) {
        final colW = tableWidth * colRatios[c];
        final cellTp = TextPainter(
          text: TextSpan(
            text: rowData[c],
            style: TextStyle(
              fontSize: 14,
              fontWeight: c == 0 || c == 2 ? FontWeight.w700 : FontWeight.w500,
              color: const Color(0xFF1E293B),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        cellTp.layout(maxWidth: colW - 16);
        cellTp.paint(canvas, Offset(currentX + 10, y + (rowHeight - cellTp.height) / 2));
        currentX += colW;
      }
      y += rowHeight;
    }

    // Optional Total Row at bottom
    if (totalLabel != null && totalValue != null) {
      y += 12;
      final totalRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(tableMargin, y, tableWidth, 48),
        const Radius.circular(8),
      );
      final totalBg = Paint()..color = const Color(0xFFECFDF5);
      final totalBorder = Paint()
        ..color = const Color(0xFF10B981)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(totalRect, totalBg);
      canvas.drawRRect(totalRect, totalBorder);

      final totalLblTp = TextPainter(
        text: TextSpan(
          text: totalLabel,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
        ),
        textDirection: TextDirection.ltr,
      );
      totalLblTp.layout();
      totalLblTp.paint(canvas, Offset(tableMargin + 20, y + (48 - totalLblTp.height) / 2));

      final totalValTp = TextPainter(
        text: TextSpan(
          text: totalValue,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF047857)),
        ),
        textDirection: TextDirection.ltr,
      );
      totalValTp.layout();
      totalValTp.paint(canvas, Offset(tableMargin + tableWidth - totalValTp.width - 20, y + (48 - totalValTp.height) / 2));
    }

    // Page Footer
    final footerTp = TextPainter(
      text: TextSpan(
        text: '$orgName — সমাজকল্যাণ সফটওয়্যার সলিউশন',
        style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      ),
      textDirection: TextDirection.ltr,
    );
    footerTp.layout();
    footerTp.paint(canvas, Offset((width - footerTp.width) / 2, height - 40));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // ─────────────── HELPERS ───────────────

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
