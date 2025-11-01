import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  );

  Future<UserCredential> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}
