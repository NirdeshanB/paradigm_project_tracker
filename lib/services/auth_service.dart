import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/user.dart' as app_user;
class AuthService {
  bool get _isFirebaseInitialized {
    try {
      Firebase.app();
      return true;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ──────────── Auth State ────────────
  Stream<User?> get authStateChanges =>
      _isFirebaseInitialized ? _auth.authStateChanges() : Stream.value(null);

  User? get currentFirebaseUser =>
      _isFirebaseInitialized ? _auth.currentUser : null;

  // ──────────── Login ────────────
  Future<app_user.User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) return null;

      // Load or create user document
      final appUser = await _getOrCreateUserDocument(firebaseUser);

      // Update lastLoginAt
      await _db.collection('users').doc(firebaseUser.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _friendlyAuthError(e);
    }
  }

  // ──────────── Register (uses secondary FirebaseApp to avoid signing out Super Admin) ────────────
  Future<app_user.User?> registerUser({
    required String email,
    required String password,
    required String name,
    required String role, // member | admin | super_admin
    String? phone,
  }) async {
    FirebaseApp? tempApp;
    try {
      final appName = 'temp_app_${DateTime.now().millisecondsSinceEpoch}';
      tempApp = await Firebase.initializeApp(
        name: appName,
        options: Firebase.app().options,
      );
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      
      final credential = await tempAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) return null;

      final parts = name.trim().split(' ');
      final initial = parts.isNotEmpty && parts.first.isNotEmpty
          ? parts.first[0].toUpperCase()
          : 'U';

      final hash = name.hashCode;
      final colors = ['#4F46E5', '#0EA5E9', '#10B981', '#F97316', '#7C3AED', '#EF4444'];
      final avatarColor = colors[hash.abs() % colors.length];

      final userData = {
        'uid': firebaseUser.uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone,
        'initial': initial,
        'role': role,
        'avatarColor': avatarColor,
        'isActive': true,
        'fcmTokens': [],
        'notifications': 'All',
        'defaultReminder': '10:00 AM',
        'timeZone': 'Automatic',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
      };

      await _db.collection('users').doc(firebaseUser.uid).set(userData);

      return app_user.User.fromMap({
        ...userData,
        'id': firebaseUser.uid,
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseAuthException catch (e) {
      throw _friendlyAuthError(e);
    } finally {
      if (tempApp != null) {
        await tempApp.delete();
      }
    }
  }

  // ──────────── Update User Settings ────────────
  Future<void> updateUserSettings({
    required String uid,
    String? notifications,
    String? defaultReminder,
    String? timeZone,
  }) async {
    final Map<String, dynamic> updates = {};
    if (notifications != null) updates['notifications'] = notifications;
    if (defaultReminder != null) updates['defaultReminder'] = defaultReminder;
    if (timeZone != null) updates['timeZone'] = timeZone;

    if (updates.isNotEmpty) {
      await _db.collection('users').doc(uid).update(updates);
    }
  }

  // ──────────── Get current app user ────────────
  Future<app_user.User?> getCurrentAppUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await _db.collection('users').doc(firebaseUser.uid).get();
    if (!doc.exists || doc.data() == null) return null;

    return app_user.User.fromMap({
      ...doc.data()!,
      'id': doc.id,
    });
  }

  // Stream of current app user (useful for UI)
  Stream<app_user.User?> get currentAppUserStream {
    if (!_isFirebaseInitialized) return Stream.value(null);
    return _auth.authStateChanges().asyncExpand((firebaseUser) {
      if (firebaseUser == null) return Stream.value(null);
      return _db.collection('users').doc(firebaseUser.uid).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) return null;
        return app_user.User.fromMap({
          ...doc.data()!,
          'id': doc.id,
        });
      });
    });
  }

  // Stream of active team members
  Stream<List<app_user.User>> getActiveTeamMembersStream() {
    if (!_isFirebaseInitialized) return Stream.value([]);
    return _db.collection('users')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => app_user.User.fromMap({
            ...doc.data(),
            'id': doc.id,
          })).toList();
        });
  }

  // ──────────── Sign Out ────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ──────────── Helpers ────────────
  Future<app_user.User> _getOrCreateUserDocument(User firebaseUser) async {
    final docRef = _db.collection('users').doc(firebaseUser.uid);
    final doc = await docRef.get();

    if (doc.exists && doc.data() != null) {
      // User already exists (your Super Admin case)
      return app_user.User.fromMap({
        ...doc.data()!,
        'id': doc.id,
      });
    }

    // Fallback – should rarely happen if you create users properly
    final name = firebaseUser.displayName ??
        firebaseUser.email?.split('@').first ??
        'User';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    final data = {
      'uid': firebaseUser.uid,
      'name': name,
      'email': firebaseUser.email ?? '',
      'phone': null,
      'initial': initial,
      'role': 'member',
      'avatarColor': _randomAvatarColor(),
      'isActive': true,
      'fcmTokens': [],
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'createdBy': null,
    };

    await docRef.set(data);

    return app_user.User.fromMap({
      ...data,
      'id': firebaseUser.uid,
      'createdAt': DateTime.now().toIso8601String(),
      'lastLoginAt': DateTime.now().toIso8601String(),
    });
  }

  String _randomAvatarColor() {
    const colors = [
      '#4F46E5',
      '#7C3AED',
      '#0EA5E9',
      '#059669',
      '#D97706',
      '#BE123C',
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
