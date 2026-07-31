import '../l10n/app_strings.dart';

class Validators {
  Validators._();

  static final RegExp _bdPhoneRegex = RegExp(r'^01[3-9]\d{8}$');

  static String? phone(String? value) {
    final s = AppStrings.current;
    if (value == null || value.trim().isEmpty) {
      return s.enterPhone;
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length != 11) {
      return s.phoneMustBe11;
    }
    if (!cleaned.startsWith('01')) {
      return s.phoneMustStart01;
    }
    if (!_bdPhoneRegex.hasMatch(cleaned)) {
      return s.enterValidPhone;
    }
    return null;
  }

  static String? amount(String? value) {
    final s = AppStrings.current;
    if (value == null || value.trim().isEmpty) {
      return s.enterAmount;
    }
    final cleaned = value.replaceAll(RegExp(r'[,\s]'), '');
    final parsed = int.tryParse(cleaned);
    if (parsed == null) {
      return s.enterNumber;
    }
    if (parsed <= 0) {
      return s.amountMustBePositive;
    }
    if (parsed < 10) {
      return s.minAmount10;
    }
    if (parsed > 10000000) {
      return s.maxAmount1Cr;
    }
    return null;
  }

  static String? name(String? value) {
    final s = AppStrings.current;
    if (value == null || value.trim().isEmpty) {
      return s.enterName;
    }
    if (value.trim().length < 2) {
      return s.nameMin2;
    }
    return null;
  }

  static String? nid(String? value) {
    final s = AppStrings.current;
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.length != 10 && cleaned.length != 13 && cleaned.length != 17) {
      return s.nidDigitsError;
    }
    return null;
  }

  static String? password(String? value) {
    final s = AppStrings.current;
    if (value == null || value.isEmpty) {
      return s.enterPassword;
    }
    if (value.length < 6) {
      return s.passwordMin6;
    }
    return null;
  }

  static String? email(String? value) {
    final s = AppStrings.current;
    if (value == null || value.trim().isEmpty) {
      return s.enterEmail;
    }
    if (!value.contains('@') || !value.contains('.')) {
      return s.enterValidEmail;
    }
    return null;
  }

  static String? confirmPassword(String? value, String newPassword) {
    final s = AppStrings.current;
    if (value == null || value.isEmpty) {
      return s.confirmPassword;
    }
    if (value != newPassword) {
      return s.passwordMismatch;
    }
    return null;
  }

  static String cleanPhone(String value) {
    return value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  static int? cleanAmount(String value) {
    final cleaned = value.replaceAll(RegExp(r'[,\s]'), '');
    return int.tryParse(cleaned);
  }
}
