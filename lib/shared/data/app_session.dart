import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/auth_service.dart';
import 'org_settings.dart';

/// Auth + profile session backed by Firebase.
class AppSession extends ChangeNotifier {
  AppSession._();
  static final AppSession instance = AppSession._();

  AppUser? _user;
  bool _ready = false;
  bool _initializing = false;

  AppUser? get userOrNull => _user;
  AppUser get user =>
      _user ??
      const AppUser(
        id: '',
        name: 'গেস্ট',
        phone: '',
        role: UserRole.member,
      );

  bool get isReady => _ready;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == UserRole.superAdmin;
  bool get isCollector => _user?.role == UserRole.collector;
  bool get isMember => _user?.role == UserRole.member;
  bool get canRecordDonation => isAdmin || isCollector;
  bool get canManageMembers => isAdmin || isCollector;
  bool get canEnterHelp =>
      isAdmin ||
      (isCollector && OrgSettings.instance.collectorCanEnterDonation);
  bool get canSeeReports => isAdmin || isCollector;
  bool get canEditMemberProfile =>
      isAdmin ||
      (isCollector && OrgSettings.instance.collectorCanEditProfile);

  Future<void> start() async {
    if (_initializing) return;
    _initializing = true;
    AuthService.instance.authStateChanges().listen(_onAuthChanged);
    final current = FirebaseAuth.instance.currentUser;
    if (current != null) {
      await _onAuthChanged(current);
    } else {
      _ready = true;
      notifyListeners();
    }
    _listenOrgSettings();
  }

  Future<void> _onAuthChanged(User? firebaseUser) async {
    try {
      if (firebaseUser == null) {
        _user = null;
      } else {
        _user = await AuthService.instance.loadCurrentUser();
      }
    } catch (e, st) {
      debugPrint('Session load error: $e\n$st');
      _user = null;
    } finally {
      _ready = true;
      notifyListeners();
    }
  }

  void _listenOrgSettings() {
    FirebaseFirestore.instance
        .collection('org_settings')
        .doc('global')
        .snapshots()
        .listen((snap) {
      final d = snap.data();
      if (d == null) return;
      OrgSettings.instance.applyFromMap(d);
      notifyListeners();
    });
  }

  Future<void> setUser(AppUser user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.instance.signOut();
    _user = null;
    notifyListeners();
  }

  // Kept for UI demos only — prefer real roles from Firestore.
  @Deprecated('Use Firebase login')
  void loginAsRole(UserRole role) {
    debugPrint('loginAsRole ignored — use Firebase auth');
  }
}
