import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/movie_model.dart';
import '../services/firestore_service.dart';

class UserRepository {
  final FirebaseFirestore _firestore       = FirebaseFirestore.instance;
  final FirebaseAuth      _auth            = FirebaseAuth.instance;
  final FirestoreService  _firestoreService = FirestoreService();

  // ── Current user ID ───────────────────────────────────────────────────────
  String? get _uid => _auth.currentUser?.uid;

  // ══════════════════════════════════════════════════════════════════════════
  //  USER PROFILE
  // ══════════════════════════════════════════════════════════════════════════

  // Get user profile
  Future<UserModel?> getUserProfile() async {
    if (_uid == null) return null;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_uid)
          .get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Stream user profile (realtime updates)
  Stream<UserModel?> streamUserProfile() {
    if (_uid == null) return Stream.value(null);
    return _firestore
        .collection('users')
        .doc(_uid)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  // Update user profile
  Future<String?> updateProfile({
    String? name,
    String? photoUrl,
  }) async {
    if (_uid == null) return 'User not logged in.';
    try {
      final data = <String, dynamic>{};
      if (name     != null) data['name']     = name;
      if (photoUrl != null) data['photoUrl'] = photoUrl;

      await _firestore
          .collection('users')
          .doc(_uid)
          .update(data);

      // Update Firebase Auth display name
      if (name != null) {
        await _auth.currentUser?.updateDisplayName(name);
      }
      if (photoUrl != null) {
        await _auth.currentUser?.updatePhotoURL(photoUrl);
      }

      return null;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return 'Failed to update profile.';
    }
  }

  // Create user profile
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _firestoreService.createUser(user);
    } catch (e) {
      debugPrint('Error creating user profile: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  FAVOURITES
  // ══════════════════════════════════════════════════════════════════════════

  // Get favourites
  Future<List<MovieModel>> getFavourites() async {
    return _firestoreService.getFavourites();
  }

  // Stream favourites (realtime)
  Stream<List<MovieModel>> streamFavourites() {
    return _firestoreService.streamFavourites();
  }

  // Add favourite
  Future<String?> addFavourite(MovieModel movie) async {
    try {
      await _firestoreService.addFavourite(movie);
      return null;
    } catch (e) {
      return 'Failed to add favourite.';
    }
  }

  // Remove favourite
  Future<String?> removeFavourite(String movieId) async {
    try {
      await _firestoreService.removeFavourite(movieId);
      return null;
    } catch (e) {
      return 'Failed to remove favourite.';
    }
  }

  // Check if favourite
  Future<bool> isFavourite(String movieId) async {
    return _firestoreService.isFavourite(movieId);
  }

  // Toggle favourite
  Future<String?> toggleFavourite(MovieModel movie) async {
    try {
      final isAlreadyFav = await isFavourite(movie.id);
      if (isAlreadyFav) {
        return removeFavourite(movie.id);
      } else {
        return addFavourite(movie);
      }
    } catch (e) {
      return 'Failed to toggle favourite.';
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  RATINGS
  // ══════════════════════════════════════════════════════════════════════════

  // Get user rating for a movie
  Future<double?> getUserRating(String movieId) async {
    return _firestoreService.getUserRating(movieId);
  }

  // Submit rating
  Future<String?> submitRating({
    required String movieId,
    required String movieTitle,
    required double rating,
  }) async {
    try {
      await _firestoreService.submitRating(
        movieId:    movieId,
        movieTitle: movieTitle,
        rating:     rating,
      );
      return null;
    } catch (e) {
      return 'Failed to submit rating.';
    }
  }

  // Get all user ratings
  Future<List<Map<String, dynamic>>> getAllUserRatings() async {
    return _firestoreService.getUserRatings();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  WATCHLIST
  // ══════════════════════════════════════════════════════════════════════════

  // Get watchlist
  Future<List<Map<String, dynamic>>> getWatchlist() async {
    return _firestoreService.getWatchlist();
  }

  // Add to watchlist
  Future<String?> addToWatchlist(MovieModel movie) async {
    try {
      await _firestoreService.addToWatchlist(movie);
      return null;
    } catch (e) {
      return 'Failed to add to watchlist.';
    }
  }

  // Remove from watchlist
  Future<String?> removeFromWatchlist(String movieId) async {
    try {
      await _firestoreService.removeFromWatchlist(movieId);
      return null;
    } catch (e) {
      return 'Failed to remove from watchlist.';
    }
  }

  // Check if in watchlist
  Future<bool> isInWatchlist(String movieId) async {
    return _firestoreService.isInWatchlist(movieId);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  USER STATS
  // ══════════════════════════════════════════════════════════════════════════

  // Get user stats
  Future<Map<String, int>> getUserStats() async {
    return _firestoreService.getUserStats();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SEARCH HISTORY
  // ══════════════════════════════════════════════════════════════════════════

  // Save search query
  Future<void> saveSearchHistory(String query) async {
    if (_uid == null || query.trim().isEmpty) return;
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('searchHistory')
          .add({
        'query':     query,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }

  // Get search history
  Future<List<String>> getSearchHistory() async {
    if (_uid == null) return [];
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('searchHistory')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((d) => d.data()['query'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Clear search history
  Future<void> clearSearchHistory() async {
    if (_uid == null) return;
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('searchHistory')
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing search history: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  NOTIFICATIONS
  // ══════════════════════════════════════════════════════════════════════════

  // Update notification settings
  Future<void> updateNotificationSettings({
    required bool enabled,
  }) async {
    if (_uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .update({'notificationsEnabled': enabled});
    } catch (e) {
      debugPrint('Error updating notifications: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  DELETE ACCOUNT DATA
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> deleteAllUserData(String uid) async {
    try {
      final batch = _firestore.batch();

      // Delete favourites
      final favSnap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('favourites')
          .get();
      for (final doc in favSnap.docs) {
        batch.delete(doc.reference);
      }

      // Delete search history
      final historySnap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('searchHistory')
          .get();
      for (final doc in historySnap.docs) {
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

      // Delete watchlist
      final watchSnap = await _firestore
          .collection('watchlist')
          .where('userId', isEqualTo: uid)
          .get();
      for (final doc in watchSnap.docs) {
        batch.delete(doc.reference);
      }

      // Delete user document
      batch.delete(_firestore.collection('users').doc(uid));

      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting user data: $e');
    }
  }
}