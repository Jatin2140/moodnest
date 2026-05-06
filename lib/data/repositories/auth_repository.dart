import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../../core/utils/result.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<Result<UserProfile>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user!.updateDisplayName(displayName);
      final profile = UserProfile(
        uid: cred.user!.uid,
        displayName: displayName,
        email: email,
        createdAt: DateTime.now(),
      );
      await _db
          .collection('users')
          .doc(cred.user!.uid)
          .set(profile.toMap());
      return Ok(profile);
    } on FirebaseAuthException catch (e) {
      return Err(_authMessage(e.code));
    } catch (e) {
      return Err('Something went wrong. Please try again.');
    }
  }

  Future<Result<UserProfile>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc =
          await _db.collection('users').doc(cred.user!.uid).get();
      if (doc.exists) {
        return Ok(UserProfile.fromMap(doc.data()!));
      }
      return Ok(UserProfile(
        uid: cred.user!.uid,
        displayName: cred.user!.displayName ?? 'Friend',
        email: email,
        createdAt: DateTime.now(),
      ));
    } on FirebaseAuthException catch (e) {
      return Err(_authMessage(e.code));
    } catch (e) {
      return Err('Something went wrong. Please try again.');
    }
  }

  Future<Result<UserProfile>> signInAnonymously() async {
    try {
      final cred = await _auth.signInAnonymously();
      final profile = UserProfile(
        uid: cred.user!.uid,
        displayName: 'Guest',
        email: '',
        createdAt: DateTime.now(),
      );
      return Ok(profile);
    } catch (e) {
      return Err('Could not start guest session.');
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<Result<void>> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Ok(null);
    } on FirebaseAuthException catch (e) {
      return Err(_authMessage(e.code));
    }
  }

  Future<Result<void>> updateDisplayName(String uid, String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name);
      await _db
          .collection('users')
          .doc(uid)
          .set({'displayName': name}, SetOptions(merge: true));
      return const Ok(null);
    } catch (e) {
      return Err('Could not update name.');
    }
  }

  Future<Result<void>> updateOnboarding(String uid) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .set({'onboardingDone': true}, SetOptions(merge: true));
      return const Ok(null);
    } catch (e) {
      return Err('Failed to update onboarding.');
    }
  }

  Future<Result<void>> deleteAccount(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();
      await _auth.currentUser?.delete();
      return const Ok(null);
    } catch (e) {
      return Err('Could not delete account. Re-authentication may be needed.');
    }
  }

  Future<Result<UserProfile>> getProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return Err('Profile not found.');
      return Ok(UserProfile.fromMap(doc.data()!));
    } catch (e) {
      return Err('Could not load profile.');
    }
  }

  Future<Result<void>> updateDarkMode(String uid, bool dark) async {
    try {
      await _db.collection('users').doc(uid).set({'darkMode': dark}, SetOptions(merge: true));
      return const Ok(null);
    } catch (e) {
      return Err('Could not update preference.');
    }
  }

  String _authMessage(String code) => switch (code) {
        'user-not-found' => 'No account found with that email.',
        'wrong-password' => 'Incorrect password — give it another try.',
        'email-already-in-use' => 'That email is already registered.',
        'weak-password' => 'Choose a password with at least 8 characters.',
        'invalid-email' => 'That doesn\'t look like a valid email.',
        'network-request-failed' => 'Check your internet connection.',
        _ => 'Authentication failed. Please try again.',
      };
}
