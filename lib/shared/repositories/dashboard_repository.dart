import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';

class DashboardRepository {
  DashboardRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static final DashboardRepository instance = DashboardRepository();

  /// Watch summary for a specific year. Defaults to current year.
  /// Falls back to 'global' document if year-specific doc doesn't exist.
  Stream<DashboardSummary> watchSummary({int? year}) {
    final targetYear = year ?? DateTime.now().year;
    
    return _db
        .collection('dashboard_summary')
        .doc('$targetYear')
        .snapshots()
        .asyncMap((snap) async {
      // If year-specific document exists, use it
      if (snap.exists && snap.data() != null) {
        return _parseSummary(snap.data()!);
      }
      
      // Fallback: check 'global' document (legacy data)
      final globalSnap = await _db
          .collection('dashboard_summary')
          .doc('global')
          .get();
      
      if (globalSnap.exists && globalSnap.data() != null) {
        return _parseSummary(globalSnap.data()!);
      }
      
      // No data at all
      return const DashboardSummary(
        totalCollection: 0,
        totalDonation: 0,
        thisMonthCollection: 0,
        totalDonorCount: 0,
        monthlyCollections: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      );
    });
  }

  DashboardSummary _parseSummary(Map<String, dynamic> d) {
    final monthly = List<int>.from(
      (d['monthlyCollections'] as List?)?.map((e) => (e as num).toInt()) ??
          List.filled(12, 0),
    );
    while (monthly.length < 12) {
      monthly.add(0);
    }
    return DashboardSummary(
      totalCollection: (d['totalCollection'] as num?)?.toInt() ?? 0,
      totalDonation: (d['totalDonation'] as num?)?.toInt() ?? 0,
      thisMonthCollection: (d['thisMonthCollection'] as num?)?.toInt() ?? 0,
      totalDonorCount: (d['totalDonorCount'] as num?)?.toInt() ?? 0,
      monthlyCollections: monthly.take(12).toList(),
    );
  }

  /// Watch summary from all years combined (for lifetime stats).
  Stream<DashboardSummary> watchAllTimeSummary() {
    return _db.collection('dashboard_summary').snapshots().map((snapshot) {
      int totalCollection = 0;
      int totalDonation = 0;
      int totalDonorCount = 0;
      final monthly = List<int>.filled(12, 0);

      for (final doc in snapshot.docs) {
        final d = doc.data();
        totalCollection += (d['totalCollection'] as num?)?.toInt() ?? 0;
        totalDonation += (d['totalDonation'] as num?)?.toInt() ?? 0;
        totalDonorCount += (d['totalDonorCount'] as num?)?.toInt() ?? 0;

        // Only add monthly data for current year
        final docYear = (d['year'] as num?)?.toInt();
        if (docYear == DateTime.now().year) {
          final yearMonthly = List<int>.from(
            (d['monthlyCollections'] as List?)
                    ?.map((e) => (e as num).toInt()) ??
                List.filled(12, 0),
          );
          for (var i = 0; i < 12 && i < yearMonthly.length; i++) {
            monthly[i] += yearMonthly[i];
          }
        }
      }

      final currentMonth = DateTime.now().month - 1;
      final thisMonthCollection = monthly[currentMonth];

      return DashboardSummary(
        totalCollection: totalCollection,
        totalDonation: totalDonation,
        thisMonthCollection: thisMonthCollection,
        totalDonorCount: totalDonorCount,
        monthlyCollections: monthly,
      );
    });
  }
}
