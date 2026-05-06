import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/utils/result.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;

  AuthStatus _status = AuthStatus.unknown;
  UserProfile? _profile;
  String? _error;
  bool _loading = false;

  AuthProvider({AuthRepository? repo})
      : _repo = repo ?? AuthRepository() {
    _repo.authStateChanges.listen(_onAuthChanged);
  }

  AuthStatus get status => _status;
  UserProfile? get profile => _profile;
  String? get error => _error;
  bool get isLoading => _loading;
  String? get uid => _profile?.uid ?? _repo.currentUser?.uid;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void _onAuthChanged(User? user) async {
    if (user == null) {
      _profile = null;
      _status = AuthStatus.unauthenticated;
    } else {
      if (_profile == null || _profile!.uid != user.uid) {
        final result = await _repo.getProfile(user.uid);
        result.fold(
          (p) => _profile = p,
          (_) => _profile = UserProfile(
            uid: user.uid,
            displayName: user.displayName ?? 'Friend',
            email: user.email ?? '',
            createdAt: DateTime.now(),
          ),
        );
      }
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repo.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    _loading = false;
    result.fold((p) => _profile = p, (e) => _error = e);
    notifyListeners();
    return result.isOk;
  }

  Future<bool> signIn({required String email, required String password}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repo.signIn(email: email, password: password);
    _loading = false;
    result.fold((p) => _profile = p, (e) => _error = e);
    notifyListeners();
    return result.isOk;
  }

  Future<bool> signInAnonymously() async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repo.signInAnonymously();
    _loading = false;
    result.fold((p) => _profile = p, (e) => _error = e);
    notifyListeners();
    return result.isOk;
  }

  Future<bool> signInWithGoogle() async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repo.signInWithGoogle();
    _loading = false;
    result.fold((p) => _profile = p, (e) => _error = e);
    notifyListeners();
    return result.isOk;
  }

  Future<void> signOut() async {
    await _repo.signOut();
  }

  Future<bool> updateDisplayName(String name) async {
    if (uid == null) return false;
    final result = await _repo.updateDisplayName(uid!, name);
    if (result.isOk) {
      _profile = _profile?.copyWith(displayName: name);
      notifyListeners();
    }
    return result.isOk;
  }

  Future<bool> updateDarkMode(bool dark) async {
    if (uid == null) return false;
    final result = await _repo.updateDarkMode(uid!, dark);
    if (result.isOk) {
      _profile = _profile?.copyWith(darkMode: dark);
      notifyListeners();
    }
    return result.isOk;
  }

  Future<bool> completeOnboarding() async {
    if (uid == null) return false;
    // Always update local state so the user can proceed
    _profile = _profile?.copyWith(onboardingDone: true);
    notifyListeners();
    // Attempt to persist to Firestore (best-effort)
    final result = await _repo.updateOnboarding(uid!);
    return result.isOk;
  }

  Future<bool> deleteAccount() async {
    if (uid == null) return false;
    final result = await _repo.deleteAccount(uid!);
    return result.isOk;
  }

  Future<bool> sendPasswordReset(String email) async {
    final result = await _repo.sendPasswordReset(email);
    result.fold((_) {}, (e) => _error = e);
    notifyListeners();
    return result.isOk;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
