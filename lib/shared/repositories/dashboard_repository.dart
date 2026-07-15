import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';

class DashboardRepository {
  DashboardRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static final DashboardRepository instance = DashboardRepository();

  Stream<DashboardSummary> watchSummary() {
    return _db
        .collection('dashboard_summary')
        .doc('global')
        .snapshots()
        .map((snap) {
      final d = snap.data() ?? {};
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
    });
  }
}
