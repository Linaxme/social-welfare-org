import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class OrgSettings extends ChangeNotifier {
  OrgSettings._();
  static final OrgSettings instance = OrgSettings._();

  String orgName = 'হিলফুল ফুযুল কেশবপুর পশ্চিমপাড়া';
  bool collectorCanEditProfile = false;
  bool collectorCanEnterDonation = false;

  void applyFromMap(Map<String, dynamic> d) {
    orgName = d['orgName'] as String? ?? orgName;
    collectorCanEditProfile = d['collectorCanEditProfile'] as bool? ?? false;
    collectorCanEnterDonation =
        d['collectorCanEnterDonation'] as bool? ?? false;
    notifyListeners();
  }

  Future<void> updateOrgName(String name) async {
    orgName = name.trim().isEmpty ? orgName : name.trim();
    notifyListeners();
    await FirebaseFirestore.instance
        .collection('org_settings')
        .doc('global')
        .set({
      'orgName': orgName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setCollectorCanEditProfile(bool value) async {
    collectorCanEditProfile = value;
    notifyListeners();
    await FirebaseFirestore.instance
        .collection('org_settings')
        .doc('global')
        .set({
      'collectorCanEditProfile': value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setCollectorCanEnterDonation(bool value) async {
    collectorCanEnterDonation = value;
    notifyListeners();
    await FirebaseFirestore.instance
        .collection('org_settings')
        .doc('global')
        .set({
      'collectorCanEnterDonation': value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
