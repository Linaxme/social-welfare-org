import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';
import '../../core/firebase/phone_id.dart';

extension AppUserFirestore on AppUser {
  Map<String, dynamic> toMap() {
    return {
      'uniqueId': PhoneId.normalize(phone),
      'phone': PhoneId.normalize(phone),
      'name': name,
      'role': role.firestoreValue,
      if (email != null) 'email': email,
      if (nidNumber != null && nidNumber!.trim().isNotEmpty)
        'nidNumber': nidNumber!.trim(),
      if (address != null && address!.trim().isNotEmpty)
        'address': address!.trim(),
      'totalDonation': totalDonation,
      'donationCount': donationCount,
      if (lastDonationAt != null)
        'lastDonationAt': Timestamp.fromDate(lastDonationAt!),
      if (joinedAt != null) 'joinedAt': Timestamp.fromDate(joinedAt!),
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static AppUser fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppUser(
      id: doc.id,
      name: d['name'] as String? ?? '',
      phone: d['phone'] as String? ?? d['uniqueId'] as String? ?? '',
      role: UserRoleX.fromFirestore(d['role'] as String?),
      email: d['email'] as String?,
      nidNumber: d['nidNumber'] as String?,
      address: d['address'] as String?,
      totalDonation: (d['totalDonation'] as num?)?.toInt() ?? 0,
      donationCount: (d['donationCount'] as num?)?.toInt() ?? 0,
      lastDonationAt: (d['lastDonationAt'] as Timestamp?)?.toDate(),
      joinedAt: (d['joinedAt'] as Timestamp?)?.toDate(),
      status: d['status'] as String? ?? 'active',
    );
  }
}

extension DonationFirestore on DonationRecord {
  Map<String, dynamic> toMap({String? enteredBy}) {
    return {
      'donorId': donorId,
      'donorName': donorName,
      'amount': amount,
      'paidAt': Timestamp.fromDate(paidAt),
      'receiptNo': receiptNo,
      if (note != null) 'note': note,
      'paymentMode': paymentMode,
      if (enteredByName != null) 'enteredByName': enteredByName,
      if (enteredBy != null) 'enteredBy': enteredBy,
      if (enteredById != null) 'enteredById': enteredById,
      'status': status,
      if (deletedAt != null) 'deletedAt': Timestamp.fromDate(deletedAt!),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static DonationRecord fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return DonationRecord(
      id: doc.id,
      donorId: d['donorId'] as String? ?? '',
      donorName: d['donorName'] as String? ?? '',
      amount: (d['amount'] as num?)?.toInt() ?? 0,
      paidAt: (d['paidAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      receiptNo: d['receiptNo'] as String? ?? '',
      note: d['note'] as String?,
      paymentMode: d['paymentMode'] as String? ?? 'cash',
      enteredByName: d['enteredByName'] as String?,
      enteredById: d['enteredById'] as String? ?? d['enteredBy'] as String?,
      status: d['status'] as String? ?? 'active',
      deletedAt: (d['deletedAt'] as Timestamp?)?.toDate(),
    );
  }
}

extension DisbursementFirestore on DisbursementRecord {
  Map<String, dynamic> toMap({String? enteredBy}) {
    return {
      'beneficiaryName': beneficiaryName,
      'nidNumber': nidNumber,
      'phone': phone,
      'address': address,
      'reason': reason,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      if (description != null) 'description': description,
      if (enteredByName != null) 'enteredByName': enteredByName,
      if (enteredBy != null) 'enteredBy': enteredBy,
      'status': status,
      if (deletedAt != null) 'deletedAt': Timestamp.fromDate(deletedAt!),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static DisbursementRecord fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return DisbursementRecord(
      id: doc.id,
      beneficiaryName: d['beneficiaryName'] as String? ?? '',
      nidNumber: d['nidNumber'] as String? ?? '',
      phone: d['phone'] as String? ?? '',
      address: d['address'] as String? ?? '',
      reason: d['reason'] as String? ?? '',
      amount: (d['amount'] as num?)?.toInt() ?? 0,
      date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: d['description'] as String?,
      enteredByName: d['enteredByName'] as String?,
      status: d['status'] as String? ?? 'active',
      deletedAt: (d['deletedAt'] as Timestamp?)?.toDate(),
    );
  }
}
