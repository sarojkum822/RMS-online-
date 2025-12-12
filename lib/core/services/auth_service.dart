import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateEmail(String email) async {
    try {
      // Using verifyBeforeUpdateEmail as updateEmail is deprecated/removed in newer SDKs
      await _auth.currentUser?.verifyBeforeUpdateEmail(email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> updatePassword(String password) async {
    try {
      await _auth.currentUser?.updatePassword(password);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // 1. Delete User Data from Firestore
      // Note: In a real production app, use Cloud Functions for recursive delete.
      // Here we do a best-effort client-side delete of the main profile.
      // The Security Rules allow owners to delete their own data.
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      
      // 2. Delete the Authentication User
      await user.delete();
    } catch (e) {
      // Re-authentication might be required if sensitive action
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
         throw Exception('Please log out and log in again to delete your account.');
      }
      throw _handleAuthException(e);
    }
  }

  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found for that email.');
        case 'wrong-password':
          return Exception('Wrong password provided for that user.');
        case 'email-already-in-use':
          return Exception('The account already exists for that email.');
        case 'invalid-email':
          return Exception('The email address is not valid.');
        case 'invalid-credential':
          return Exception('Invalid email or password. If you haven\'t created an account, please Sign Up.');
        default:
          return Exception(e.message ?? 'An unknown authentication error occurred.');
      }
    }
    return Exception('An unknown error occurred: $e');
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
