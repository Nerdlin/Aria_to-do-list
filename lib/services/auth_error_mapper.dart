import 'package:firebase_auth/firebase_auth.dart';

import '../utils/translations.dart';

String authErrorMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return tr('Please enter a valid email address.');
    case 'user-disabled':
      return tr('This account has been disabled.');
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return tr('Email or password is incorrect.');
    case 'email-already-in-use':
      return tr('This email is already registered.');
    case 'weak-password':
      return tr('Password must be at least 6 characters.');
    case 'operation-not-allowed':
      return tr('Email/password sign-in is not enabled.');
    case 'requires-recent-login':
      return tr('Please sign in again before changing your email.');
    case 'too-many-requests':
      return tr('Too many attempts. Please try again later.');
    case 'network-request-failed':
      return tr('Network error. Check your connection and try again.');
    default:
      return error.message ?? tr('Something went wrong. Please try again.');
  }
}
