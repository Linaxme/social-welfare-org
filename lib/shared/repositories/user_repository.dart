import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/firestore_mappers.dart';
import '../models/models.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static final UserRepository instance = UserRepository();

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users');

  Stream<List<AppUser>> watchMembers() {
    return _col.orderBy('name').snapshots().map(
          (s) => s.docs.map(AppUserFirestore.fromDoc).toList(),
        );
  }

  Future<List<AppUser>> fetchMembers() async {
    final s = await _col.orderBy('name').get();
    return s.docs.map(AppUserFirestore.fromDoc).toList();
  }

  Future<AppUser?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return AppUserFirestore.fromDoc(doc);
  }

  Future<void> updateProfile({
    required String id,
    required String name,
    required String phone,
    String? nidNumber,
    String? address,
    String? status,
  }) async {
    await _col.doc(id).update({
      'name': name.trim(),
      'phone': phone,
      'uniqueId': phone,
      'nidNumber': nidNumber?.trim() ?? '',
      'address': address?.trim() ?? '',
      if (status != null) 'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
