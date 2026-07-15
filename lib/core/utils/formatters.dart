/// Shared money / Bangla number helpers for UI
class Formatters {
  static const _bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

  static String toBnDigits(String input) {
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

  /// Formats amount like 150000 → ১,৫০,০০০
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
    final bn = toBnDigits(formatted);
    if (!withSymbol) return bn;
    return '$bn টাকা';
  }

  static String phone(String phone) => toBnDigits(phone);

  static const monthNamesBn = [
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

  static String shortDate(DateTime d) {
    return '${toBnDigits('${d.day}')} ${monthNamesBn[d.month - 1]} ${toBnDigits('${d.year}')}';
  }
}
