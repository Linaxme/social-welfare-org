import '../models/models.dart';

/// Mock data so UI screens work before Firebase is wired.
class MockData {
  static final now = DateTime(2026, 7, 14);

  static const currentUser = AppUser(
    id: 'admin-1',
    name: 'এডমিন',
    phone: '01700000000',
    email: 'admin@somiti.app',
    role: UserRole.superAdmin,
  );

  static final members = <AppUser>[
    AppUser(
      id: 'm1',
      name: 'রহিম উদ্দিন',
      phone: '01712345678',
      role: UserRole.member,
      totalDonation: 5000,
      donationCount: 5,
      lastDonationAt: DateTime(2026, 7, 14),
      joinedAt: DateTime(2025, 1, 15),
    ),
    AppUser(
      id: 'm2',
      name: 'করিম আহমেদ',
      phone: '01812345679',
      role: UserRole.member,
      totalDonation: 3500,
      donationCount: 4,
      lastDonationAt: DateTime(2026, 7, 13),
      joinedAt: DateTime(2025, 2, 10),
    ),
    AppUser(
      id: 'm3',
      name: 'সালমা খাতুন',
      phone: '01912345680',
      role: UserRole.member,
      totalDonation: 8000,
      donationCount: 8,
      lastDonationAt: DateTime(2026, 7, 12),
      joinedAt: DateTime(2024, 11, 5),
    ),
    AppUser(
      id: 'm4',
      name: 'জাহিদ হাসান',
      phone: '01612345681',
      role: UserRole.member,
      totalDonation: 2000,
      donationCount: 2,
      lastDonationAt: DateTime(2026, 6, 28),
      joinedAt: DateTime(2026, 3, 1),
    ),
    AppUser(
      id: 'm5',
      name: 'নাজমা বেগম',
      phone: '01512345682',
      role: UserRole.member,
      totalDonation: 6500,
      donationCount: 7,
      lastDonationAt: DateTime(2026, 7, 10),
      joinedAt: DateTime(2025, 6, 20),
    ),
    AppUser(
      id: 'c1',
      name: 'মোস্তাফিজুর রহমান',
      phone: '01798765432',
      role: UserRole.collector,
      totalDonation: 4000,
      donationCount: 4,
      lastDonationAt: DateTime(2026, 7, 8),
      joinedAt: DateTime(2024, 8, 1),
    ),
  ];

  static final donations = <DonationRecord>[
    DonationRecord(
      id: 'd1',
      donorId: 'm1',
      donorName: 'রহিম উদ্দিন',
      amount: 1000,
      paidAt: DateTime(2026, 7, 14, 10, 30),
      receiptNo: 'REC-2026-000142',
      paymentMode: 'নগদ',
      enteredByName: 'মোস্তাফিজুর রহমান',
    ),
    DonationRecord(
      id: 'd2',
      donorId: 'm2',
      donorName: 'করিম আহমেদ',
      amount: 500,
      paidAt: DateTime(2026, 7, 13, 16, 0),
      receiptNo: 'REC-2026-000141',
      paymentMode: 'বিকাশ',
      enteredByName: 'মোস্তাফিজুর রহমান',
    ),
    DonationRecord(
      id: 'd3',
      donorId: 'm3',
      donorName: 'সালমা খাতুন',
      amount: 2000,
      paidAt: DateTime(2026, 7, 12, 11, 15),
      receiptNo: 'REC-2026-000140',
      paymentMode: 'নগদ',
      enteredByName: 'এডমিন',
    ),
    DonationRecord(
      id: 'd4',
      donorId: 'm5',
      donorName: 'নাজমা বেগম',
      amount: 1500,
      paidAt: DateTime(2026, 7, 10, 9, 45),
      receiptNo: 'REC-2026-000139',
      paymentMode: 'নগদ',
      enteredByName: 'মোস্তাফিজুর রহমান',
    ),
    DonationRecord(
      id: 'd5',
      donorId: 'c1',
      donorName: 'মোস্তাফিজুর রহমান',
      amount: 1000,
      paidAt: DateTime(2026, 7, 8, 14, 20),
      receiptNo: 'REC-2026-000138',
      paymentMode: 'নগদ',
      enteredByName: 'এডমিন',
    ),
    DonationRecord(
      id: 'd6',
      donorId: 'm1',
      donorName: 'রহিম উদ্দিন',
      amount: 1000,
      paidAt: DateTime(2026, 6, 28, 10, 0),
      receiptNo: 'REC-2026-000130',
      paymentMode: 'নগদ',
      enteredByName: 'মোস্তাফিজুর রহমান',
    ),
    DonationRecord(
      id: 'd7',
      donorId: 'm4',
      donorName: 'জাহিদ হাসান',
      amount: 1000,
      paidAt: DateTime(2026, 6, 28, 11, 0),
      receiptNo: 'REC-2026-000129',
      paymentMode: 'বিকাশ',
      enteredByName: 'মোস্তাফিজুর রহমান',
    ),
    DonationRecord(
      id: 'd8',
      donorId: 'm3',
      donorName: 'সালমা খাতুন',
      amount: 1000,
      paidAt: DateTime(2026, 6, 15, 12, 0),
      receiptNo: 'REC-2026-000120',
      paymentMode: 'নগদ',
      enteredByName: 'এডমিন',
    ),
    DonationRecord(
      id: 'd9',
      donorId: 'm2',
      donorName: 'করিম আহমেদ',
      amount: 500,
      paidAt: DateTime(2026, 5, 20, 15, 0),
      receiptNo: 'REC-2026-000110',
      paymentMode: 'নগদ',
      enteredByName: 'মোস্তাফিজুর রহমান',
    ),
    DonationRecord(
      id: 'd10',
      donorId: 'm5',
      donorName: 'নাজমা বেগম',
      amount: 1000,
      paidAt: DateTime(2026, 5, 10, 9, 0),
      receiptNo: 'REC-2026-000100',
      paymentMode: 'নগদ',
      enteredByName: 'এডমিন',
    ),
    DonationRecord(
      id: 'd11',
      donorId: 'm1',
      donorName: 'রহিম উদ্দিন',
      amount: 1000,
      paidAt: DateTime(2026, 4, 5, 10, 0),
      receiptNo: 'REC-2026-000090',
      paymentMode: 'নগদ',
      enteredByName: 'মোস্তাফিজুর রহমান',
    ),
  ];

  static final disbursements = <DisbursementRecord>[
    DisbursementRecord(
      id: 'h1',
      beneficiaryName: 'ফাতেমা বেগম',
      nidNumber: '1234567890123',
      phone: '01711112222',
      address: 'গ্রাম: চরপাড়া, উপজেলা: সোনাগাজী, জেলা: ফেনী',
      reason: 'চিকিৎসা',
      description: 'ডায়ালিসিস খরচ, ৩ মাসের জন্য',
      amount: 5000,
      date: DateTime(2026, 7, 10),
      enteredByName: 'এডমিন',
    ),
    DisbursementRecord(
      id: 'h2',
      beneficiaryName: 'আব্দুল করিম',
      nidNumber: '9876543210987',
      phone: '01822223333',
      address: 'গ্রাম: মির্জাপুর, উপজেলা: চৌদ্দগ্রাম, জেলা: কুমিল্লা',
      reason: 'শিক্ষা',
      description: 'মেয়ের কলেজ ভর্তির খরচ',
      amount: 3000,
      date: DateTime(2026, 6, 20),
      enteredByName: 'এডমিন',
    ),
    DisbursementRecord(
      id: 'h3',
      beneficiaryName: 'রাশিদা বেগম',
      nidNumber: '4567890123456',
      phone: '01933334444',
      address: 'গ্রাম: নয়াপাড়া, উপজেলা: ফেনী সদর, জেলা: ফেনী',
      reason: 'বিধবা সাহায্য',
      description: 'মাসিক জীবনধারণ সহায়তা',
      amount: 2000,
      date: DateTime(2026, 5, 15),
      enteredByName: 'এডমিন',
    ),
  ];

  static const dashboard = DashboardSummary(
    totalCollection: 150000,
    totalDonation: 80000,
    thisMonthCollection: 18000,
    totalDonorCount: 25,
    monthlyCollections: [
      12000,
      8500,
      15000,
      11000,
      14000,
      9500,
      18000,
      0,
      0,
      0,
      0,
      0,
    ],
  );

  static List<DonationRecord> get last10Donations =>
      List.of(donations)..sort((a, b) => b.paidAt.compareTo(a.paidAt));

  static AppUser? memberById(String id) {
    try {
      return members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<DonationRecord> donationsFor(String memberId) =>
      donations.where((d) => d.donorId == memberId).toList()
        ..sort((a, b) => b.paidAt.compareTo(a.paidAt));

  static DisbursementRecord? helpById(String id) {
    try {
      return disbursements.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }
}
