import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/app_session.dart';
import '../models/firestore_mappers.dart';
import '../models/models.dart';

class DisbursementRepository {
  DisbursementRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static final DisbursementRepository instance = DisbursementRepository();

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('disbursements');

  Stream<List<DisbursementRecord>> watchAll() {
    return _col.orderBy('date', descending: true).snapshots().map(
          (s) => s.docs
              .map(DisbursementFirestore.fromDoc)
              .where((d) => d.isActive)
              .toList(),
        );
  }

  Stream<List<DisbursementRecord>> watchTrash() {
    return _col
        .where('status', isEqualTo: 'deleted')
        .orderBy('deletedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(DisbursementFirestore.fromDoc).toList());
  }

  Future<DisbursementRecord?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return DisbursementFirestore.fromDoc(doc);
  }

  Future<DisbursementRecord> add(DisbursementRecord record) async {
    final enteredBy = AppSession.instance.user;
    final docRef = _col.doc();
    final saved = DisbursementRecord(
      id: docRef.id,
      beneficiaryName: record.beneficiaryName,
      nidNumber: record.nidNumber,
      phone: record.phone,
      address: record.address,
      reason: record.reason,
      amount: record.amount,
      date: record.date,
      description: record.description,
      enteredByName: enteredBy.name,
    );

    final dashRef = _db.collection('dashboard_summary').doc('global');

    await _db.runTransaction((tx) async {
      final dashSnap = await tx.get(dashRef);
      tx.set(docRef, saved.toMap(enteredBy: enteredBy.id));
      final d = dashSnap.data() ?? {};
      tx.set(
        dashRef,
        {
          'totalDonation':
              ((d['totalDonation'] as num?)?.toInt() ?? 0) + record.amount,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });

    return saved;
  }

  /// Soft delete — move to trash and update dashboard total
  Future<void> softDelete(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return;
    final record = DisbursementFirestore.fromDoc(doc);
    if (record.isDeleted) return;

    final dashRef = _db.collection('dashboard_summary').doc('global');

    await _db.runTransaction((tx) async {
      final dashSnap = await tx.get(dashRef);

      // Mark as deleted
      tx.update(_col.doc(id), {
        'status': 'deleted',
        'deletedAt': FieldValue.serverTimestamp(),
      });

      // Update dashboard summary - subtract donation amount
      final d = dashSnap.data() ?? {};
      final prevDonation = (d['totalDonation'] as num?)?.toInt() ?? 0;
      tx.set(
        dashRef,
        {
          'totalDonation': (prevDonation - record.amount).clamp(0, 999999999),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Restore from trash and add back to dashboard total
  Future<void> restore(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return;
    final record = DisbursementFirestore.fromDoc(doc);
    if (!record.isDeleted) return;

    final dashRef = _db.collection('dashboard_summary').doc('global');

    await _db.runTransaction((tx) async {
      final dashSnap = await tx.get(dashRef);

      // Mark as active
      tx.update(_col.doc(id), {
        'status': 'active',
        'deletedAt': FieldValue.delete(),
      });

      // Update dashboard summary - add back donation amount
      final d = dashSnap.data() ?? {};
      final prevDonation = (d['totalDonation'] as num?)?.toInt() ?? 0;
      tx.set(
        dashRef,
        {
          'totalDonation': prevDonation + record.amount,
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

  /// Empty all trash for disbursements
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
