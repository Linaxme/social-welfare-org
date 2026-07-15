/// Form validators for Bangladeshi phone numbers and amounts.
class Validators {
  Validators._();

  /// BD mobile: 01XXXXXXXXX (11 digits, starts with 01)
  static final RegExp _bdPhoneRegex = RegExp(r'^01[3-9]\d{8}$');

  /// Validate Bangladeshi phone number.
  /// Returns error message or null if valid.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ফোন নম্বর দিন';
    }

    // Remove spaces, dashes, parentheses
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (cleaned.length != 11) {
      return 'ফোন নম্বর ১১ ডিজিট হতে হবে';
    }

    if (!cleaned.startsWith('01')) {
      return 'ফোন নম্বর ০১ দিয়ে শুরু হতে হবে';
    }

    if (!_bdPhoneRegex.hasMatch(cleaned)) {
      return 'সঠিক ফোন নম্বর দিন (01XXXXXXXXX)';
    }

    return null;
  }

  /// Validate donation/help amount.
  /// Returns error message or null if valid.
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'পরিমাণ দিন';
    }

    // Remove commas, spaces
    final cleaned = value.replaceAll(RegExp(r'[,\s]'), '');

    final parsed = int.tryParse(cleaned);
    if (parsed == null) {
      return 'সংখ্যা দিন';
    }

    if (parsed <= 0) {
      return 'পরিমাণ ০ এর বেশি হতে হবে';
    }

    if (parsed < 10) {
      return 'সর্বনিম্ন ১০ টাকা';
    }

    if (parsed > 10000000) {
      return 'সর্বোচ্চ ১ কোটি টাকা';
    }

    return null;
  }

  /// Validate name (non-empty, min length).
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'নাম দিন';
    }

    if (value.trim().length < 2) {
      return 'নাম কমপক্ষে ২ অক্ষর হতে হবে';
    }

    return null;
  }

  /// Validate NID number (optional, but if provided must be valid).
  static String? nid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');

    if (cleaned.length != 10 && cleaned.length != 13 && cleaned.length != 17) {
      return 'NID ১০, ১৩ বা ১৭ ডিজিট হতে হবে';
    }

    return null;
  }

  /// Validate password (min 6 chars).
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'পাসওয়ার্ড দিন';
    }

    if (value.length < 6) {
      return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষর হতে হবে';
    }

    return null;
  }

  /// Validate email (simple check).
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ইমেইল দিন';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'সঠিক ইমেইল দিন';
    }
    return null;
  }

  /// Validate confirm password matches new password.
  static String? confirmPassword(String? value, String newPassword) {
    if (value == null || value.isEmpty) {
      return 'পাসওয়ার্ড নিশ্চিত করুন';
    }
    if (value != newPassword) {
      return 'পাসওয়ার্ড মিলছে না';
    }
    return null;
  }

  /// Clean phone number (remove spaces, dashes, etc).
  static String cleanPhone(String value) {
    return value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  /// Clean amount string (remove commas, spaces).
  static int? cleanAmount(String value) {
    final cleaned = value.replaceAll(RegExp(r'[,\s]'), '');
    return int.tryParse(cleaned);
  }
}
