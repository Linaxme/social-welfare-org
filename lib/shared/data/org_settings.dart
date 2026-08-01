import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class OrgSettings extends ChangeNotifier {
  OrgSettings._();
  static final OrgSettings instance = OrgSettings._();

  String orgName = 'হিলফুল ফুযুল কেশবপুর পশ্চিমপাড়া';
  String apkDownloadUrl =
      'https://github.com/Linaxme/social-welfare-org/releases/download/v1.0.0.2/hilful-fuzul.v1.0.0.2.apk';
  bool collectorCanEditProfile = false;
  bool collectorCanEnterDonation = false;
  bool showDashboardSlider = true;
  String sliderContentType = 'donors'; // 'donors', 'aids', 'both'

  void applyFromMap(Map<String, dynamic> d) {
    orgName = d['orgName'] as String? ?? orgName;
    apkDownloadUrl = d['apkDownloadUrl'] as String? ?? apkDownloadUrl;
    collectorCanEditProfile = d['collectorCanEditProfile'] as bool? ?? false;
    collectorCanEnterDonation =
        d['collectorCanEnterDonation'] as bool? ?? false;
    showDashboardSlider = d['showDashboardSlider'] as bool? ?? true;
    sliderContentType = d['sliderContentType'] as String? ?? 'donors';
    notifyListeners();
  }

  Future<void> updateShowDashboardSlider(bool value) async {
    showDashboardSlider = value;
    notifyListeners();
    await FirebaseFirestore.instance
        .collection('org_settings')
        .doc('global')
        .set({
      'showDashboardSlider': value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateSliderContentType(String type) async {
    sliderContentType = type;
    notifyListeners();
    await FirebaseFirestore.instance
        .collection('org_settings')
        .doc('global')
        .set({
      'sliderContentType': type,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateApkDownloadUrl(String url) async {
    apkDownloadUrl = url.trim();
    notifyListeners();
    await FirebaseFirestore.instance
        .collection('org_settings')
        .doc('global')
        .set({
      'apkDownloadUrl': apkDownloadUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
