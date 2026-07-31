import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Helper class for loading Bengali fonts for PDF generation and shaping text.
class PdfFontHelper {
  static pw.Font? _regular;
  static pw.Font? _bold;

  /// Preload Bengali fonts in background so PDF creation is instantaneous.
  static Future<void> preload() async {
    try {
      await Future.wait([
        getRegular(),
        getBold(),
      ]);
    } catch (e) {
      debugPrint('PdfFontHelper preload error: $e');
    }
  }

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

  /// Shapes Bengali text for PDF rendering so that pre-base matras (ি, ে, ৈ)
  /// and two-part matras (ো, ৌ) render in the correct position without breaking.
  static String fixBangla(String text) {
    if (text.isEmpty) return text;

    final StringBuffer sb = StringBuffer();
    final runes = text.runes.toList();
    final int len = runes.length;

    int i = 0;
    while (i < len) {
      final int ch = runes[i];

      // If it's a Bengali character range (U+0980 - U+09FF)
      if (ch >= 0x0980 && ch <= 0x09FF) {
        int start = i;
        while (i < len && runes[i] >= 0x0980 && runes[i] <= 0x09FF) {
          i++;
        }
        final wordRunes = runes.sublist(start, i);
        sb.write(_shapeBengaliWord(wordRunes));
      } else {
        sb.writeCharCode(ch);
        i++;
      }
    }

    return sb.toString();
  }

  static String _shapeBengaliWord(List<int> runes) {
    final StringBuffer result = StringBuffer();
    final int len = runes.length;

    int i = 0;
    while (i < len) {
      if (_isConsonant(runes[i]) || _isVowel(runes[i])) {
        int clusterStart = i;
        int clusterEnd = i + 1;

        while (clusterEnd < len) {
          if (runes[clusterEnd] == 0x09CD && clusterEnd + 1 < len && _isConsonant(runes[clusterEnd + 1])) {
            clusterEnd += 2;
          } else {
            break;
          }
        }

        List<int> preMatras = [];
        List<int> postMatras = [];

        int scan = clusterEnd;
        while (scan < len) {
          final int m = runes[scan];
          if (m == 0x09BF) {
            // ি (i-kar) -> pre-base
            preMatras.add(0x09BF);
            scan++;
          } else if (m == 0x09C7) {
            // ে (e-kar) -> pre-base
            preMatras.add(0x09C7);
            scan++;
          } else if (m == 0x09C8) {
            // ৈ (oi-kar) -> pre-base
            preMatras.add(0x09C8);
            scan++;
          } else if (m == 0x09CB) {
            // ো (o-kar) -> split to pre-base ে and post-base া
            preMatras.add(0x09C7);
            postMatras.add(0x09BE);
            scan++;
          } else if (m == 0x09CC) {
            // ৌ (ou-kar) -> split to pre-base ে and post-base ৗ
            preMatras.add(0x09C7);
            postMatras.add(0x09D7);
            scan++;
          } else if (_isOtherMatraOrSign(m)) {
            postMatras.add(m);
            scan++;
          } else {
            break;
          }
        }

        for (final m in preMatras) {
          result.writeCharCode(m);
        }

        for (int c = clusterStart; c < clusterEnd; c++) {
          result.writeCharCode(runes[c]);
        }

        for (final m in postMatras) {
          result.writeCharCode(m);
        }

        i = scan;
      } else {
        result.writeCharCode(runes[i]);
        i++;
      }
    }

    return result.toString();
  }

  static bool _isConsonant(int r) {
    return (r >= 0x0995 && r <= 0x09B9) || (r >= 0x09DC && r <= 0x09DF) || r == 0x09CE;
  }

  static bool _isVowel(int r) {
    return (r >= 0x0985 && r <= 0x0994);
  }

  static bool _isOtherMatraOrSign(int r) {
    return (r >= 0x09BE && r <= 0x09C4) || (r >= 0x0981 && r <= 0x0983) || r == 0x09BC;
  }
}

