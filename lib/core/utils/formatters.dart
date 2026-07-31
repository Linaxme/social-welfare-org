import '../l10n/app_strings.dart';
import '../../shared/data/locale_provider.dart';

class Formatters {
  static const _bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

  static String toDigits(String input, {bool? forceBn}) {
    final useBn = forceBn ?? LocaleProvider.instance.isBn;
    if (!useBn) return input;
    final buffer = StringBuffer();
    for (final code in input.codeUnits) {
      if (code >= 48 && code <= 57) {
        buffer.write(_bnDigits[code - 48]);
      } else {
        buffer.writeCharCode(code);
      }
    }
    return buffer.toString();
  }

  static String toBnDigits(String input) => toDigits(input, forceBn: true);

  static String money(num amount, {bool withSymbol = true}) {
    final intPart = amount.round().abs();
    final str = intPart.toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      if (count == 3 || (count > 3 && (count - 3) % 2 == 0)) {
        buffer.write(',');
      }
      buffer.write(str[i]);
      count++;
    }
    final formatted = buffer.toString().split('').reversed.join();
    final s = AppStrings.current;
    final digits = toDigits(formatted);
    if (!withSymbol) return digits;
    return '$digits ${s.taka}';
  }

  static String phone(String phone) => toDigits(phone);

  static List<String> get monthNamesBn => const [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
    'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
  ];

  static List<String> get monthNamesEn => const [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static List<String> get monthNames =>
      LocaleProvider.instance.isEn ? monthNamesEn : monthNamesBn;

  static String shortDate(DateTime d) {
    final s = AppStrings.current;
    final names = s.monthNames;
    return '${toDigits('${d.day}')} ${names[d.month - 1]} ${toDigits('${d.year}')}';
  }
}
