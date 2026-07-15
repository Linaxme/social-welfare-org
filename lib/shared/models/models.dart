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

  String get roleLabel => switch (role) {
        UserRole.superAdmin => 'সুপার অ্যাডমিন',
        UserRole.collector => 'কালেক্টর',
        UserRole.member => 'মেম্বার',
      };
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
    this.paymentMode = 'নগদ',
    this.enteredByName,
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
