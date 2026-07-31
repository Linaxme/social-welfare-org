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
        .limit(limit * 2) // fetch extra to account for deleted items
        .snapshots()
        .map((s) => s.docs
            .map(DonationFirestore.fromDoc)
            .where((d) => d.isActive)
            .take(limit)
            .toList());
  }

  Stream<List<DonationRecord>> watchAll() {
    return _col.orderBy('paidAt', descending: true).snapshots().map(
          (s) => s.docs
              .map(DonationFirestore.fromDoc)
              .where((d) => d.isActive)
              .toList(),
        );
  }

  Stream<List<DonationRecord>> watchAllIncludingDeleted() {
    return _col.orderBy('paidAt', descending: true).snapshots().map(
          (s) => s.docs.map(DonationFirestore.fromDoc).toList(),
        );
  }

  Stream<List<DonationRecord>> watchTrash() {
    return _col
        .where('status', isEqualTo: 'deleted')
        .orderBy('deletedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(DonationFirestore.fromDoc).toList());
  }

  Stream<List<DonationRecord>> watchForDonor(String donorId) {
    return _col
        .where('donorId', isEqualTo: donorId)
        .orderBy('paidAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map(DonationFirestore.fromDoc)
            .where((d) => d.isActive)
            .toList());
  }

  Stream<List<DonationRecord>> watchByCollector(String collectorId) {
    return _col
        .where('enteredBy', isEqualTo: collectorId)
        .orderBy('paidAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map(DonationFirestore.fromDoc)
            .where((d) => d.isActive)
            .toList());
  }

  /// Get collection stats grouped by collector (enteredBy field).
  Stream<List<CollectorStat>> watchCollectorStats() {
    return _col
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      final map = <String, CollectorStat>{};
      for (final doc in snapshot.docs) {
        final d = doc.data();
        final enteredBy = d['enteredBy'] as String? ?? '';
        final enteredByName = d['enteredByName'] as String? ?? '';
        final amount = (d['amount'] as num?)?.toInt() ?? 0;
        if (enteredBy.isEmpty) continue;

        final existing = map[enteredBy];
        if (existing != null) {
          map[enteredBy] = CollectorStat(
            collectorId: enteredBy,
            collectorName: existing.collectorName.isNotEmpty
                ? existing.collectorName
                : enteredByName,
            totalAmount: existing.totalAmount + amount,
            count: existing.count + 1,
          );
        } else {
          map[enteredBy] = CollectorStat(
            collectorId: enteredBy,
            collectorName: enteredByName,
            totalAmount: amount,
            count: 1,
          );
        }
      }
      final list = map.values.toList();
      list.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      return list;
    });
  }

  /// All-time top donors aggregated by donorId.
  Stream<List<TopDonorStat>> watchTopDonors({int limit = 3}) {
    return _col
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      final map = <String, TopDonorStat>{};
      for (final doc in snapshot.docs) {
        final d = doc.data();
        final donorId = d['donorId'] as String? ?? '';
        final donorName = d['donorName'] as String? ?? '';
        final amount = (d['amount'] as num?)?.toInt() ?? 0;
        if (donorId.isEmpty) continue;
        final existing = map[donorId];
        if (existing != null) {
          map[donorId] = TopDonorStat(
            donorId: donorId,
            donorName: existing.donorName,
            totalAmount: existing.totalAmount + amount,
            count: existing.count + 1,
          );
        } else {
          map[donorId] = TopDonorStat(
            donorId: donorId,
            donorName: donorName,
            totalAmount: amount,
            count: 1,
          );
        }
      }
      final list = map.values.toList();
      list.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      return list.take(limit).toList();
    });
  }

  /// Monthly top donors for the given month/year.
  Stream<List<TopDonorStat>> watchMonthlyTopDonors({
    required int year,
    required int month,
    int limit = 3,
  }) {
    final from = Timestamp.fromDate(DateTime(year, month, 1));
    final to = Timestamp.fromDate(DateTime(year, month + 1, 1));
    return _col
        .where('status', isEqualTo: 'active')
        .where('paidAt', isGreaterThanOrEqualTo: from)
        .where('paidAt', isLessThan: to)
        .snapshots()
        .map((snapshot) {
      final map = <String, TopDonorStat>{};
      for (final doc in snapshot.docs) {
        final d = doc.data();
        final donorId = d['donorId'] as String? ?? '';
        final donorName = d['donorName'] as String? ?? '';
        final amount = (d['amount'] as num?)?.toInt() ?? 0;
        if (donorId.isEmpty) continue;
        final existing = map[donorId];
        if (existing != null) {
          map[donorId] = TopDonorStat(
            donorId: donorId,
            donorName: existing.donorName,
            totalAmount: existing.totalAmount + amount,
            count: existing.count + 1,
          );
        } else {
          map[donorId] = TopDonorStat(
            donorId: donorId,
            donorName: donorName,
            totalAmount: amount,
            count: 1,
          );
        }
      }
      final list = map.values.toList();
      list.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      return list.take(limit).toList();
    });
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
    if (amount <= 0) throw Exception('Amount must be positive');
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
      enteredById: enteredBy.id,
    );

    final userRef = _db.collection('users').doc(donor.id);
    final donationYear = paidAt.year;
    final dashRef = _db.collection('dashboard_summary').doc('$donationYear');

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

      final monthIndex = paidAt.month - 1;
      final d = dashSnap.data() ?? {};
      var monthly = List<int>.from(
        (d['monthlyCollections'] as List?)?.map((e) => (e as num).toInt()) ??
            List.filled(12, 0),
      );
      if (monthly.length < 12) {
        monthly = [...monthly, ...List.filled(12 - monthly.length, 0)];
      }

      monthly[monthIndex] = monthly[monthIndex] + amount;

      var thisMonthCollection = (d['thisMonthCollection'] as num?)?.toInt() ?? 0;
      final now = DateTime.now();
      if (donationYear == now.year && paidAt.month == now.month) {
        thisMonthCollection += amount;
      } else if (donationYear != now.year) {
        thisMonthCollection = (d['thisMonthCollection'] as num?)?.toInt() ?? 0;
      }

      var totalDonorCount = (d['totalDonorCount'] as num?)?.toInt() ?? 0;
      final prevYearDonationCount = (d['donorCount_${donor.id}'] as num?)?.toInt() ?? 0;
      if (prevYearDonationCount == 0) {
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
          'year': donationYear,
          'donorCount_${donor.id}': prevYearDonationCount + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });

    return record;
  }

  Future<void> updateDonation({
    required String id,
    required int newAmount,
    required DateTime newPaidAt,
    required String newPaymentMode,
    String? newNote,
  }) async {
    if (newAmount <= 0) throw Exception('Amount must be positive');

    final doc = await _col.doc(id).get();
    if (!doc.exists) return;
    final old = DonationFirestore.fromDoc(doc);

    final oldYear = old.paidAt.year;
    final newYear = newPaidAt.year;
    final oldMonth = old.paidAt.month - 1;
    final newMonth = newPaidAt.month - 1;
    final amountDiff = newAmount - old.amount;

    final userRef = _db.collection('users').doc(old.donorId);

    await _db.runTransaction((tx) async {
      // Update the donation doc
      tx.update(_col.doc(id), {
        'amount': newAmount,
        'paidAt': Timestamp.fromDate(newPaidAt),
        'paymentMode': newPaymentMode,
        'note': newNote,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update user totals (only if amount changed)
      if (amountDiff != 0) {
        final userSnap = await tx.get(userRef);
        final prevTotal =
            (userSnap.data()?['totalDonation'] as num?)?.toInt() ?? 0;
        tx.set(
          userRef,
          {
            'totalDonation': (prevTotal + amountDiff).clamp(0, 999999999),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      // Update old year dashboard summary (subtract old amount)
      if (oldYear == newYear && oldMonth == newMonth && amountDiff == 0) {
        // No dashboard update needed
      } else {
        // Subtract from old month/year
        final oldDashRef =
            _db.collection('dashboard_summary').doc('$oldYear');
        final oldDashSnap = await tx.get(oldDashRef);
        final od = oldDashSnap.data() ?? {};
        var oldMonthly = List<int>.from(
          (od['monthlyCollections'] as List?)
                  ?.map((e) => (e as num).toInt()) ??
              List.filled(12, 0),
        );
        if (oldMonthly.length < 12) {
          oldMonthly = [
            ...oldMonthly,
            ...List.filled(12 - oldMonthly.length, 0),
          ];
        }
        oldMonthly[oldMonth] =
            (oldMonthly[oldMonth] - old.amount).clamp(0, 999999999);

        var oldThisMonth = (od['thisMonthCollection'] as num?)?.toInt() ?? 0;
        final now = DateTime.now();
        if (oldYear == now.year && old.paidAt.month == now.month) {
          oldThisMonth =
              (oldThisMonth - old.amount).clamp(0, 999999999);
        }

        tx.set(
          oldDashRef,
          {
            'totalCollection':
                ((od['totalCollection'] as num?)?.toInt() ?? 0) - old.amount,
            'thisMonthCollection': oldThisMonth,
            'monthlyCollections': oldMonthly,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        // Add to new month/year
        final newDashRef =
            _db.collection('dashboard_summary').doc('$newYear');
        final newDashSnap = await tx.get(newDashRef);
        final nd = newDashSnap.data() ?? {};
        var newMonthly = List<int>.from(
          (nd['monthlyCollections'] as List?)
                  ?.map((e) => (e as num).toInt()) ??
              List.filled(12, 0),
        );
        if (newMonthly.length < 12) {
          newMonthly = [
            ...newMonthly,
            ...List.filled(12 - newMonthly.length, 0),
          ];
        }
        newMonthly[newMonth] = newMonthly[newMonth] + newAmount;

        var newThisMonth = (nd['thisMonthCollection'] as num?)?.toInt() ?? 0;
        if (newYear == now.year && newPaidAt.month == now.month) {
          newThisMonth += newAmount;
        }

        tx.set(
          newDashRef,
          {
            'totalCollection':
                ((nd['totalCollection'] as num?)?.toInt() ?? 0) + newAmount,
            'thisMonthCollection': newThisMonth,
            'monthlyCollections': newMonthly,
            'year': newYear,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
    });
  }

  /// Soft delete — move to trash and update dashboard/user totals
  Future<void> softDelete(String id) async {
    // First get the donation record
    final doc = await _col.doc(id).get();
    if (!doc.exists) return;
    final donation = DonationFirestore.fromDoc(doc);
    if (donation.isDeleted) return; // already deleted

    final donationYear = donation.paidAt.year;
    final monthIndex = donation.paidAt.month - 1;
    final dashRef = _db.collection('dashboard_summary').doc('$donationYear');
    final userRef = _db.collection('users').doc(donation.donorId);

    await _db.runTransaction((tx) async {
      final dashSnap = await tx.get(dashRef);
      final userSnap = await tx.get(userRef);

      // Mark as deleted
      tx.update(_col.doc(id), {
        'status': 'deleted',
        'deletedAt': FieldValue.serverTimestamp(),
      });

      // Update dashboard summary
      final d = dashSnap.data() ?? {};
      var monthly = List<int>.from(
        (d['monthlyCollections'] as List?)?.map((e) => (e as num).toInt()) ??
            List.filled(12, 0),
      );
      if (monthly.length < 12) {
        monthly = [...monthly, ...List.filled(12 - monthly.length, 0)];
      }
      monthly[monthIndex] =
          (monthly[monthIndex] - donation.amount).clamp(0, 999999999);

      var thisMonthCollection =
          (d['thisMonthCollection'] as num?)?.toInt() ?? 0;
      final now = DateTime.now();
      if (donationYear == now.year && donation.paidAt.month == now.month) {
        thisMonthCollection =
            (thisMonthCollection - donation.amount).clamp(0, 999999999);
      }

      var totalDonorCount = (d['totalDonorCount'] as num?)?.toInt() ?? 0;
      final donorCountKey = 'donorCount_${donation.donorId}';
      final prevYearDonationCount =
          (d[donorCountKey] as num?)?.toInt() ?? 0;
      if (prevYearDonationCount <= 1) {
        totalDonorCount = (totalDonorCount - 1).clamp(0, 999999999);
      }

      tx.set(
        dashRef,
        {
          'totalCollection':
              ((d['totalCollection'] as num?)?.toInt() ?? 0) - donation.amount,
          'thisMonthCollection': thisMonthCollection,
          'totalDonorCount': totalDonorCount,
          'monthlyCollections': monthly,
          donorCountKey: (prevYearDonationCount - 1).clamp(0, 999999999),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // Update user totals
      final prevTotal =
          (userSnap.data()?['totalDonation'] as num?)?.toInt() ?? 0;
      final prevCount =
          (userSnap.data()?['donationCount'] as num?)?.toInt() ?? 0;
      tx.set(
        userRef,
        {
          'totalDonation': (prevTotal - donation.amount).clamp(0, 999999999),
          'donationCount': (prevCount - 1).clamp(0, 999999999),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Restore from trash and add back to dashboard/user totals
  Future<void> restore(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return;
    final donation = DonationFirestore.fromDoc(doc);
    if (!donation.isDeleted) return; // already active

    final donationYear = donation.paidAt.year;
    final monthIndex = donation.paidAt.month - 1;
    final dashRef = _db.collection('dashboard_summary').doc('$donationYear');
    final userRef = _db.collection('users').doc(donation.donorId);

    await _db.runTransaction((tx) async {
      final dashSnap = await tx.get(dashRef);
      final userSnap = await tx.get(userRef);

      // Mark as active
      tx.update(_col.doc(id), {
        'status': 'active',
        'deletedAt': FieldValue.delete(),
      });

      // Update dashboard summary
      final d = dashSnap.data() ?? {};
      var monthly = List<int>.from(
        (d['monthlyCollections'] as List?)?.map((e) => (e as num).toInt()) ??
            List.filled(12, 0),
      );
      if (monthly.length < 12) {
        monthly = [...monthly, ...List.filled(12 - monthly.length, 0)];
      }
      monthly[monthIndex] = monthly[monthIndex] + donation.amount;

      var thisMonthCollection =
          (d['thisMonthCollection'] as num?)?.toInt() ?? 0;
      final now = DateTime.now();
      if (donationYear == now.year && donation.paidAt.month == now.month) {
        thisMonthCollection += donation.amount;
      }

      var totalDonorCount = (d['totalDonorCount'] as num?)?.toInt() ?? 0;
      final donorCountKey = 'donorCount_${donation.donorId}';
      final prevYearDonationCount =
          (d[donorCountKey] as num?)?.toInt() ?? 0;
      if (prevYearDonationCount == 0) {
        totalDonorCount += 1;
      }

      tx.set(
        dashRef,
        {
          'totalCollection':
              ((d['totalCollection'] as num?)?.toInt() ?? 0) + donation.amount,
          'thisMonthCollection': thisMonthCollection,
          'totalDonorCount': totalDonorCount,
          'monthlyCollections': monthly,
          donorCountKey: prevYearDonationCount + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // Update user totals
      final prevTotal =
          (userSnap.data()?['totalDonation'] as num?)?.toInt() ?? 0;
      final prevCount =
          (userSnap.data()?['donationCount'] as num?)?.toInt() ?? 0;
      tx.set(
        userRef,
        {
          'totalDonation': prevTotal + donation.amount,
          'donationCount': prevCount + 1,
          'lastDonationAt': Timestamp.fromDate(donation.paidAt),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Permanently delete
  Future<void> permanentDelete(String id) async {
    await _col.doc(id).delete();
  }

  /// Empty all trash for donations
  Future<void> emptyTrash() async {
    final trashSnap =
        await _col.where('status', isEqualTo: 'deleted').get();
    final batch = _db.batch();
    for (final doc in trashSnap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
