import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth     _auth         = FirebaseAuth.instance;
  final FirebaseFirestore _firestore   = FirebaseFirestore.instance;
  final GoogleSignIn     _googleSignIn = GoogleSignIn();

  // ── Current user ──────────────────────────────────────────────────────────
  User? get currentFirebaseUser => _auth.currentUser;
  bool  get isLoggedIn          => _auth.currentUser != null;

  // ── Auth state stream ─────────────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ══════════════════════════════════════════════════════════════════════════
  //  REGISTER
  // ══════════════════════════════════════════════════════════════════════════
  Future<({UserModel? user, String? error})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email:    email,
        password: password,
      );

      // Update display name
      await credential.user!.updateDisplayName(name);

      // Create user model
      final user = UserModel(
        uid:   credential.user!.uid,
        name:  name,
        email: email,
      );

      // Save to Firestore
      await _saveUserToFirestore(user);

      return (user: user, error: null);
    } on FirebaseAuthException catch (e) {
      return (user: null, error: _errorMessage(e.code));
    } catch (e) {
      return (user: null, error: 'Registration failed. Try again.');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  LOGIN
  // ══════════════════════════════════════════════════════════════════════════
  Future<({UserModel? user, String? error})> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email:    email,
        password: password,
      );

      // Load user from Firestore
      final user = await _getUserFromFirestore(credential.user!.uid);
      return (user: user, error: null);
    } on FirebaseAuthException catch (e) {
      return (user: null, error: _errorMessage(e.code));
    } catch (e) {
      return (user: null, error: 'Login failed. Try again.');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  GOOGLE SIGN IN
  // ══════════════════════════════════════════════════════════════════════════
  Future<({UserModel? user, String? error})> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return (user: null, error: 'Google sign-in cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser   = userCredential.user!;

      // Check if new user
      final existingUser = await _getUserFromFirestore(firebaseUser.uid);

      if (existingUser != null) {
        return (user: existingUser, error: null);
      }

      // New user — create profile
      final newUser = UserModel(
        uid:      firebaseUser.uid,
        name:     firebaseUser.displayName ?? 'Movie Fan',
        email:    firebaseUser.email       ?? '',
        photoUrl: firebaseUser.photoURL    ?? '',
      );

      await _saveUserToFirestore(newUser);
      return (user: newUser, error: null);
    } on FirebaseAuthException catch (e) {
      return (user: null, error: _errorMessage(e.code));
    } catch (e) {
      return (user: null, error: 'Google sign-in failed. Try again.');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  LOGOUT
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> logout() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  UPDATE PROFILE
  // ══════════════════════════════════════════════════════════════════════════
  Future<String?> updateProfile({
    required String uid,
    String? name,
    String? photoUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name     != null) data['name']     = name;
      if (photoUrl != null) data['photoUrl'] = photoUrl;

      await _firestore.collection('users').doc(uid).update(data);

      if (name != null) {
        await _auth.currentUser?.updateDisplayName(name);
      }
      if (photoUrl != null) {
        await _auth.currentUser?.updatePhotoURL(photoUrl);
      }

      return null;
    } catch (e) {
      return 'Failed to update profile.';
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  CHANGE PASSWORD
  // ══════════════════════════════════════════════════════════════════════════
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user  = _auth.currentUser!;
      final email = user.email!;

      // Re-authenticate
      final cred = EmailAuthProvider.credential(
        email:    email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    } catch (e) {
      return 'Password change failed.';
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  FORGOT PASSWORD
  // ══════════════════════════════════════════════════════════════════════════
  Future<String?> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  DELETE ACCOUNT
  // ══════════════════════════════════════════════════════════════════════════
  Future<String?> deleteAccount({required String password}) async {
    try {
      final user  = _auth.currentUser!;
      final email = user.email!;

      // Re-authenticate
      final cred = EmailAuthProvider.credential(
        email:    email,
        password: password,
      );
      await user.reauthenticateWithCredential(cred);

      // Delete Firestore data
      await _deleteUserData(user.uid);

      // Delete Firebase Auth account
      await user.delete();
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    } catch (e) {
      return 'Account deletion failed.';
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  // Save user to Firestore
  Future<void> _saveUserToFirestore(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toJson(), SetOptions(merge: true));
  }

  // Get user from Firestore
  Future<UserModel?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Delete all user data from Firestore
  Future<void> _deleteUserData(String uid) async {
    final batch = _firestore.batch();

    // Delete user document
    batch.delete(_firestore.collection('users').doc(uid));

    // Delete favourites
    final favSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favourites')
        .get();
    for (final doc in favSnap.docs) {
      batch.delete(doc.reference);
    }

    // Delete ratings
    final ratingSnap = await _firestore
        .collection('ratings')
        .where('userId', isEqualTo: uid)
        .get();
    for (final doc in ratingSnap.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Firebase error messages
  String _errorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'requires-recent-login':
        return 'Please login again to continue.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}