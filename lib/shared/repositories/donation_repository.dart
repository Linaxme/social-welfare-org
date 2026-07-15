import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/app_session.dart';
import '../models/firestore_mappers.dart';
import '../models/models.dart';

class DonationRepository {
  DonationRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static final DonationRepository instance = DonationRepository();

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('donations');

  Stream<List<DonationRecord>> watchRecent({int limit = 10}) {
    return _col
        .orderBy('paidAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(DonationFirestore.fromDoc).toList());
  }

  Stream<List<DonationRecord>> watchAll() {
    return _col.orderBy('paidAt', descending: true).snapshots().map(
          (s) => s.docs.map(DonationFirestore.fromDoc).toList(),
        );
  }

  Stream<List<DonationRecord>> watchForDonor(String donorId) {
    return _col
        .where('donorId', isEqualTo: donorId)
        .orderBy('paidAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(DonationFirestore.fromDoc).toList());
  }

  Future<String> _nextReceiptNo() async {
    final year = DateTime.now().year;
    final ref = _db.collection('counters').doc('receipts_$year');
    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final next = ((snap.data()?['seq'] as num?)?.toInt() ?? 0) + 1;
      tx.set(ref, {'seq': next, 'year': year}, SetOptions(merge: true));
      return 'REC-$year-${next.toString().padLeft(6, '0')}';
    });
  }

  Future<DonationRecord> addDonation({
    required AppUser donor,
    required int amount,
    required DateTime paidAt,
    required String paymentMode,
    String? note,
  }) async {
    if (amount <= 0) throw Exception('পরিমাণ সঠিক নয়');
    final receiptNo = await _nextReceiptNo();
    final enteredBy = AppSession.instance.user;
    final docRef = _col.doc();

    final record = DonationRecord(
      id: docRef.id,
      donorId: donor.id,
      donorName: donor.name,
      amount: amount,
      paidAt: paidAt,
      receiptNo: receiptNo,
      note: note,
      paymentMode: paymentMode,
      enteredByName: enteredBy.name,
    );

    final userRef = _db.collection('users').doc(donor.id);
    final dashRef = _db.collection('dashboard_summary').doc('global');

    await _db.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      final dashSnap = await tx.get(dashRef);

      tx.set(docRef, record.toMap(enteredBy: enteredBy.id));

      final prevTotal = (userSnap.data()?['totalDonation'] as num?)?.toInt() ?? 0;
      final prevCount = (userSnap.data()?['donationCount'] as num?)?.toInt() ?? 0;
      tx.set(
        userRef,
        {
          'totalDonation': prevTotal + amount,
          'donationCount': prevCount + 1,
          'lastDonationAt': Timestamp.fromDate(paidAt),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final year = DateTime.now().year;
      final monthIndex = paidAt.month - 1;
      final d = dashSnap.data() ?? {};
      var monthly = List<int>.from(
        (d['monthlyCollections'] as List?)?.map((e) => (e as num).toInt()) ??
            List.filled(12, 0),
      );
      if (monthly.length < 12) {
        monthly = [...monthly, ...List.filled(12 - monthly.length, 0)];
      }

      var thisMonthCollection =
          (d['thisMonthCollection'] as num?)?.toInt() ?? 0;
      var totalDonorCount = (d['totalDonorCount'] as num?)?.toInt() ?? 0;
      final dashYear = (d['year'] as num?)?.toInt() ?? year;

      if (dashYear != year) {
        monthly = List.filled(12, 0);
        thisMonthCollection = 0;
      }

      if (paidAt.year == year) {
        monthly[monthIndex] = monthly[monthIndex] + amount;
      }
      if (paidAt.year == year && paidAt.month == DateTime.now().month) {
        thisMonthCollection += amount;
      }
      // First-ever donation from this person → new donor
      if (prevCount == 0) {
        totalDonorCount += 1;
      }

      tx.set(
        dashRef,
        {
          'totalCollection':
              ((d['totalCollection'] as num?)?.toInt() ?? 0) + amount,
          'totalDonation': (d['totalDonation'] as num?)?.toInt() ?? 0,
          'thisMonthCollection': thisMonthCollection,
          'totalDonorCount': totalDonorCount,
          'monthlyCollections': monthly,
          'year': year,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });

    return record;
  }
}
