import '../../core/l10n/app_strings.dart';

enum UserRole { superAdmin, collector, member }

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.nidNumber,
    this.address,
    this.totalDonation = 0,
    this.donationCount = 0,
    this.lastDonationAt,
    this.joinedAt,
    this.status = 'active',
  });

  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String? email;
  final String? nidNumber;
  final String? address;
  final int totalDonation;
  final int donationCount;
  final DateTime? lastDonationAt;
  final DateTime? joinedAt;
  final String status;

  String get uniqueId => phone;
  bool get isActive => status == 'active';
  bool get isMemberCountEligible => isActive && switch (role) {
        UserRole.member || UserRole.collector || UserRole.superAdmin => true,
      };

  String get roleLabel {
    final s = AppStrings.current;
    return switch (role) {
      UserRole.superAdmin => s.superAdmin,
      UserRole.collector => s.collector,
      UserRole.member => s.memberRole,
    };
  }
}

extension AppUserListX on Iterable<AppUser> {
  int countMemberEligibleUsers() => where((user) => user.isMemberCountEligible).length;
}

class DonationRecord {
  const DonationRecord({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.amount,
    required this.paidAt,
    required this.receiptNo,
    this.note,
    this.paymentMode = 'cash',
    this.enteredByName,
    this.enteredById,
    this.status = 'active',
    this.deletedAt,
  });

  final String id;
  final String donorId;
  final String donorName;
  final int amount;
  final DateTime paidAt;
  final String receiptNo;
  final String? note;
  final String paymentMode;
  final String? enteredByName;
  final String? enteredById;
  final String status;
  final DateTime? deletedAt;

  bool get isDeleted => status == 'deleted';
  bool get isActive => status == 'active';

  String get paymentModeLabel {
    final s = AppStrings.current;
    return switch (paymentMode) {
      'cash' || 'নগদ' => s.cash,
      'bkash' || 'বিকাশ' => s.bkash,
      _ => s.other,
    };
  }
}

class DisbursementRecord {
  const DisbursementRecord({
    required this.id,
    required this.beneficiaryName,
    required this.nidNumber,
    required this.phone,
    required this.address,
    required this.reason,
    required this.amount,
    required this.date,
    this.description,
    this.enteredByName,
    this.status = 'active',
    this.deletedAt,
  });

  final String id;
  final String beneficiaryName;
  final String nidNumber;
  final String phone;
  final String address;
  final String reason;
  final int amount;
  final DateTime date;
  final String? description;
  final String? enteredByName;
  final String status;
  final DateTime? deletedAt;

  bool get isDeleted => status == 'deleted';
  bool get isActive => status == 'active';

  String get reasonLabel {
    final s = AppStrings.current;
    return switch (reason) {
      'medical' || 'চিকিৎসা' => s.medical,
      'education' || 'শিক্ষা' => s.education,
      'widow' || 'বিধবা সাহায্য' => s.widowHelp,
      _ => s.others,
    };
  }
}

class CollectorStat {
  const CollectorStat({
    required this.collectorId,
    required this.collectorName,
    required this.totalAmount,
    required this.count,
  });

  final String collectorId;
  final String collectorName;
  final int totalAmount;
  final int count;
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalCollection,
    required this.totalDonation,
    required this.thisMonthCollection,
    required this.totalDonorCount,
    required this.monthlyCollections,
  });

  final int totalCollection;
  final int totalDonation;
  final int thisMonthCollection;

  /// Unique donors who have given at least once
  final int totalDonorCount;

  /// Index 0 = Jan ... 11 = Dec for selected year
  final List<int> monthlyCollections;
}

class TopDonorStat {
  const TopDonorStat({
    required this.donorId,
    required this.donorName,
    required this.totalAmount,
    required this.count,
  });

  final String donorId;
  final String donorName;
  final int totalAmount;
  final int count;
}
