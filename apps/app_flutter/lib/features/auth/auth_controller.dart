import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/app_user.dart';
import '../../services/auth_repository.dart';
import '../../services/user_service.dart';

enum AuthStatus {
  initializing,
  unauthenticated,
  loadingProfile,
  needsProfile,
  authenticated,
  error,
}

class AuthController extends ChangeNotifier {
  AuthController(this._authRepository, this._userService) {
    _authSubscription =
        _authRepository.authStateChanges().listen(_handleAuthChange);
  }

  final AuthRepository _authRepository;
  final UserService _userService;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<AppUser?>? _profileSubscription;

  AuthStatus _status = AuthStatus.initializing;
  AppUser? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  AppUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  bool get isAdmin =>
      _currentUser?.role == UserRole.orgAdmin ||
      _currentUser?.role == UserRole.teamAdmin;

  @override
  void dispose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      _setStatus(AuthStatus.loadingProfile);
      await _authRepository.signInWithEmailAndPassword(email, password);
    } on FirebaseAuthException catch (error) {
      _setError(error.message ?? 'Unable to sign in');
    } catch (error) {
      _setError(error.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _setStatus(AuthStatus.loadingProfile);
      await _authRepository.signInWithGoogle();
    } on FirebaseAuthException catch (error) {
      _setError(error.message ?? 'Unable to sign in');
    } catch (error) {
      _setError(error.toString());
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  Future<void> resetPassword(String email) {
    return _authRepository.sendPasswordResetEmail(email);
  }

  void _handleAuthChange(User? firebaseUser) {
    _profileSubscription?.cancel();
    if (firebaseUser == null) {
      _currentUser = null;
      _setStatus(AuthStatus.unauthenticated);
      return;
    }

    _setStatus(AuthStatus.loadingProfile);
    _profileSubscription = _userService
        .watchUserProfile(firebaseUser.uid)
        .listen((AppUser? profile) {
      if (profile == null) {
        _currentUser = null;
        _setStatus(AuthStatus.needsProfile);
      } else {
        _currentUser = profile;
        _setStatus(AuthStatus.authenticated);
      }
    }, onError: (Object error) {
      _setError(error.toString());
    });
  }

  void _setStatus(AuthStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setStatus(AuthStatus.error);
  }
}
