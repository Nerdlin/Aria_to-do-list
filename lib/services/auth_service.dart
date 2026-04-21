import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (error) {
      if (kDebugMode) {
        print('Error during sign in: ${error.message}');
      }
      rethrow;
    }
  }

  Future<User?> registerWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (displayName != null && displayName.trim().isNotEmpty) {
        await result.user?.updateDisplayName(displayName.trim());
      }

      return result.user;
    } on FirebaseAuthException catch (error) {
      if (kDebugMode) {
        print('Error during registration: ${error.message}');
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error) {
      if (kDebugMode) {
        print('Error during sign out: $error');
      }
    }
  }

  Stream<User?> get user => _auth.authStateChanges();
}
