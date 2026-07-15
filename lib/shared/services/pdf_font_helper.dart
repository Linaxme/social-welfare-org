import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Helper class for loading Bengali fonts for PDF generation.
class PdfFontHelper {
  static pw.Font? _regular;
  static pw.Font? _bold;

  /// Get regular Bengali font.
  static Future<pw.Font> getRegular() async {
    _regular ??= await PdfGoogleFonts.notoSansBengaliRegular();
    return _regular!;
  }

  /// Get bold Bengali font.
  static Future<pw.Font> getBold() async {
    _bold ??= await PdfGoogleFonts.notoSansBengaliBold();
    return _bold!;
  }

  /// Create text style with Bengali fonts.
  static Future<pw.TextStyle> regularStyle({
    double fontSize = 10,
    PdfColor? color,
  }) async {
    return pw.TextStyle(
      font: await getRegular(),
      fontSize: fontSize,
      color: color,
    );
  }

  /// Create bold text style with Bengali fonts.
  static Future<pw.TextStyle> boldStyle({
    double fontSize = 10,
    PdfColor? color,
  }) async {
    return pw.TextStyle(
      font: await getBold(),
      fontSize: fontSize,
      color: color,
    );
  }
}
