import 'dart:async';

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

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot>? _orgSettingsSubscription;

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

    // Cancel existing subscriptions to prevent duplicates
    await _authSubscription?.cancel();
    await _orgSettingsSubscription?.cancel();

    _authSubscription = AuthService.instance.authStateChanges().listen(_onAuthChanged);
    final current = FirebaseAuth.instance.currentUser;
    if (current != null) {
      await _onAuthChanged(current);
    } else {
      _ready = true;
      notifyListeners();
    }
  }

  Future<void> _onAuthChanged(User? firebaseUser) async {
    try {
      if (firebaseUser == null) {
        _user = null;
      } else {
        _user = await AuthService.instance.loadCurrentUser();
        _listenOrgSettings();
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
    _orgSettingsSubscription = FirebaseFirestore.instance
        .collection('org_settings')
        .doc('global')
        .snapshots()
        .listen(
      (snap) {
        final d = snap.data();
        if (d == null) return;
        OrgSettings.instance.applyFromMap(d);
        notifyListeners();
      },
      onError: (e) {
        debugPrint('OrgSettings listener error: $e');
      },
    );
  }

  Future<void> setUser(AppUser user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    // Cancel Firestore listener
    await _orgSettingsSubscription?.cancel();
    _orgSettingsSubscription = null;

    await AuthService.instance.signOut();
    _user = null;
    _ready = true;
    notifyListeners();
  }

  /// Cancel all subscriptions. Call when app is being destroyed.
  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _orgSettingsSubscription?.cancel();
    _authSubscription = null;
    _orgSettingsSubscription = null;
    _initializing = false;
  }

  // Kept for UI demos only — prefer real roles from Firestore.
  @Deprecated('Use Firebase login')
  void loginAsRole(UserRole role) {
    debugPrint('loginAsRole ignored — use Firebase auth');
  }
}
