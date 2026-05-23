import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth      _auth         = FirebaseAuth.instance;
  final FirebaseFirestore _firestore    = FirebaseFirestore.instance;
  final GoogleSignIn      _googleSignIn = GoogleSignIn();

  UserModel? _currentUser;
  bool       _isLoading = false;
  String?    _error;

  UserModel? get currentUser => _currentUser;
  bool       get isLoading   => _isLoading;
  String?    get error       => _error;
  bool       get isLoggedIn  => _auth.currentUser != null;

  AuthProvider() {
    _init();
  }

  // ── Init: listen to auth state changes ────────────────────────────────────
  void _init() {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserFromFirestore(firebaseUser.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // ── Load user from Firestore ──────────────────────────────────────────────
  Future<void> _loadUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
    notifyListeners();
  }

  // ── Save user to Firestore ────────────────────────────────────────────────
  Future<void> _saveUserToFirestore(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toJson(), SetOptions(merge: true));
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  REGISTER
  // ══════════════════════════════════════════════════════════════════════════
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email:    email,
        password: password,
      );

      final user = UserModel(
        uid:   credential.user!.uid,
        name:  name,
        email: email,
      );

      await _saveUserToFirestore(user);
      await credential.user!.updateDisplayName(name);

      _currentUser = user;
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return _authErrorMessage(e.code);
    } catch (e) {
      _setLoading(false);
      return 'Something went wrong. Please try again.';
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  LOGIN
  // ══════════════════════════════════════════════════════════════════════════
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email:    email,
        password: password,
      );
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return _authErrorMessage(e.code);
    } catch (e) {
      _setLoading(false);
      return 'Something went wrong. Please try again.';
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  GOOGLE SIGN IN
  // ══════════════════════════════════════════════════════════════════════════
  Future<String?> signInWithGoogle() async {
    _setLoading(true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return 'Google sign-in cancelled.';
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser   = userCredential.user!;

      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) {
        final user = UserModel(
          uid:      firebaseUser.uid,
          name:     firebaseUser.displayName ?? 'Movie Fan',
          email:    firebaseUser.email       ?? '',
          photoUrl: firebaseUser.photoURL    ?? '',
        );
        await _saveUserToFirestore(user);
        _currentUser = user;
      } else {
        _currentUser = UserModel.fromJson(doc.data()!);
      }

      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return _authErrorMessage(e.code);
    } catch (e) {
      _setLoading(false);
      return 'Google sign-in failed. Try again.';
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  LOGOUT
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
    _currentUser = null;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  UPDATE PROFILE (name / photoUrl)
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    if (_currentUser == null) return;
    _setLoading(true);
    try {
      final updated = _currentUser!.copyWith(
        name:     name,
        photoUrl: photoUrl,
      );
      await _saveUserToFirestore(updated);

      if (name != null) {
        await _auth.currentUser?.updateDisplayName(name);
      }
      if (photoUrl != null) {
        await _auth.currentUser?.updatePhotoURL(photoUrl);
      }

      _currentUser = updated;
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
    _setLoading(false);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  UPDATE PROFILE PHOTO (from File)
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> updateProfilePhoto(File imageFile) async {
    if (_currentUser == null) return;
    _setLoading(true);
    try {
      // Save local file path as photoUrl
      // (Firebase Storage integration করতে চাইলে পরে যোগ করা যাবে)
      final localPath = imageFile.path;

      final updated = _currentUser!.copyWith(photoUrl: localPath);
      await _saveUserToFirestore(updated);
      _currentUser = updated;
    } catch (e) {
      debugPrint('Error updating profile photo: $e');
    }
    _setLoading(false);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  CHANGE PASSWORD
  // ══════════════════════════════════════════════════════════════════════════
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      final user  = _auth.currentUser!;
      final email = user.email!;

      final cred = EmailAuthProvider.credential(
        email:    email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return _authErrorMessage(e.code);
    } catch (e) {
      _setLoading(false);
      return 'Password change failed.';
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  FORGOT PASSWORD
  // ══════════════════════════════════════════════════════════════════════════
  Future<String?> sendPasswordReset({required String email}) async {
    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return _authErrorMessage(e.code);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _authErrorMessage(String code) {
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
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}