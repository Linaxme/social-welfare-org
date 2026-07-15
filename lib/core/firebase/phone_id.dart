import '../../shared/models/models.dart';

class PhoneId {
  /// Normalize BD mobile to 11-digit 01XXXXXXXXX
  static String normalize(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('880') && digits.length >= 13) {
      digits = '0${digits.substring(3)}';
    }
    if (digits.length > 11) {
      digits = digits.substring(digits.length - 11);
    }
    return digits;
  }

  static String toAuthEmail(String phoneOrId) {
    final id = normalize(phoneOrId);
    return '$id@somiti.app';
  }

  static bool isValidBdMobile(String phone) {
    final n = normalize(phone);
    return RegExp(r'^01[3-9]\d{8}$').hasMatch(n);
  }
}

extension UserRoleX on UserRole {
  String get firestoreValue => switch (this) {
        UserRole.superAdmin => 'superAdmin',
        UserRole.collector => 'collector',
        UserRole.member => 'member',
      };

  static UserRole fromFirestore(String? value) {
    return switch (value) {
      'superAdmin' => UserRole.superAdmin,
      'collector' => UserRole.collector,
      _ => UserRole.member,
    };
  }
}
