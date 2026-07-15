import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/firebase/phone_id.dart';
import '../../firebase_options.dart';
import '../models/firestore_mappers.dart';
import '../models/models.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  static final AuthService instance = AuthService();

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _loadOrBootstrapUser(cred.user!);
  }

  Future<AppUser> signInWithPhoneId({
    required String phoneOrId,
    required String password,
  }) async {
    final email = PhoneId.toAuthEmail(phoneOrId);
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _loadOrBootstrapUser(cred.user!);
  }

  /// First-time super admin registration (Firebase Auth + Firestore profile).
  Future<AppUser> registerSuperAdmin({
    required String email,
    required String password,
    required String name,
  }) async {
    final existing = await _db.collection('users').limit(1).get();
    if (existing.docs.isNotEmpty) {
      throw Exception('অ্যাডমিন ইতিমধ্যে আছে — লগইন করুন');
    }
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user!.updateDisplayName(name.trim());
    final appUser = AppUser(
      id: cred.user!.uid,
      name: name.trim(),
      phone: '01700000000',
      email: email.trim(),
      role: UserRole.superAdmin,
      joinedAt: DateTime.now(),
    );
    await _db.collection('users').doc(cred.user!.uid).set({
      ...appUser.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _ensureOrgDefaults();
    return appUser;
  }

  Future<void> signOut() => _auth.signOut();

  Future<AppUser?> loadCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _loadOrBootstrapUser(user);
  }

  Future<AppUser> _loadOrBootstrapUser(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (snap.exists) {
      return AppUserFirestore.fromDoc(snap);
    }

    final users = await _db.collection('users').limit(1).get();
    final isFirst = users.docs.isEmpty;
    final appUser = AppUser(
      id: user.uid,
      name: user.displayName ?? (isFirst ? 'সুপার অ্যাডমিন' : 'ইউজার'),
      phone: _phoneFromEmail(user.email) ?? '01700000000',
      email: user.email,
      role: isFirst ? UserRole.superAdmin : UserRole.member,
      joinedAt: DateTime.now(),
    );
    await ref.set({
      ...appUser.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _ensureOrgDefaults();
    return appUser;
  }

  String? _phoneFromEmail(String? email) {
    if (email == null) return null;
    if (email.endsWith('@somiti.app')) {
      return email.split('@').first;
    }
    return null;
  }

  Future<void> _ensureOrgDefaults() async {
    final ref = _db.collection('org_settings').doc('global');
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'orgName': 'হিলফুল ফুযুল কেশবপুর পশ্চিমপাড়া',
        'collectorCanEditProfile': false,
        'collectorCanEnterDonation': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    final dash = _db.collection('dashboard_summary').doc('global');
    if (!(await dash.get()).exists) {
      await dash.set({
        'totalCollection': 0,
        'totalDonation': 0,
        'thisMonthCollection': 0,
        'totalDonorCount': 0,
        'monthlyCollections': List.filled(12, 0),
        'year': DateTime.now().year,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<AppUser> createUserAccount({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
    String? nidNumber,
    String? address,
  }) async {
    if (!PhoneId.isValidBdMobile(phone)) {
      throw Exception('সঠিক বাংলাদেশি মোবাইল নম্বর দিন');
    }
    final uniqueId = PhoneId.normalize(phone);
    final email = PhoneId.toAuthEmail(uniqueId);

    final existing = await _db
        .collection('users')
        .where('uniqueId', isEqualTo: uniqueId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw Exception('এই ফোন নম্বর ইতিমধ্যে নিবন্ধিত');
    }

    FirebaseApp? secondary;
    try {
      try {
        secondary = Firebase.app('SecondaryAuth');
      } catch (_) {
        secondary = await Firebase.initializeApp(
          name: 'SecondaryAuth',
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondary);
      final cred = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;
      await secondaryAuth.signOut();

      final appUser = AppUser(
        id: uid,
        name: name.trim(),
        phone: uniqueId,
        email: email,
        role: role,
        nidNumber: nidNumber?.trim().isEmpty == true ? null : nidNumber?.trim(),
        address: address?.trim().isEmpty == true ? null : address?.trim(),
        joinedAt: DateTime.now(),
      );
      await _db.collection('users').doc(uid).set({
        ...appUser.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return appUser;
    } finally {
      // Keep secondary app for reuse; deleting can race on web
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('লগইন নেই');
    }
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }
}
