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
    String? name,
    String? phone,
    String? nidNumber,
    String? address,
    String? status,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updates['name'] = name.trim();
    if (phone != null) {
      updates['phone'] = phone;
      updates['uniqueId'] = phone;
    }
    if (nidNumber != null) updates['nidNumber'] = nidNumber.trim();
    if (address != null) updates['address'] = address.trim();
    if (status != null) updates['status'] = status;

    await _col.doc(id).update(updates);
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  /// Updates user role with safety checks
  /// - Prevents removing the last super admin
  /// - Only super admins can change roles
  Future<void> updateUserRole({
    required String userId,
    required UserRole newRole,
  }) async {
    // Check if trying to remove last super admin
    if (newRole != UserRole.superAdmin) {
      final superAdmins = await fetchMembers();
      final superAdminCount =
          superAdmins.where((u) => u.role == UserRole.superAdmin).length;

      // Safety guard: keep at least one super admin
      if (superAdminCount <= 1) {
        throw Exception('অন্তত একজন সুপার অ্যাডমিন থাকতে হবে');
      }
    }

    await _col.doc(userId).update({
      'role': newRole.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get count of super admins
  Future<int> getSuperAdminCount() async {
    final members = await fetchMembers();
    return members.where((u) => u.role == UserRole.superAdmin).length;
  }
}
