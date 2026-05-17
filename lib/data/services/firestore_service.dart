import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db   = FirebaseFirestore.instance;
  final FirebaseAuth      _auth = FirebaseAuth.instance;

  // ── Current user ID ───────────────────────────────────────────────────────
  String? get _uid => _auth.currentUser?.uid;

  // ══════════════════════════════════════════════════════════════════════════
  //  USER OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  // Create user document
  Future<void> createUser(UserModel user) async {
    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  // Get user document
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  // Update user document
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  // Stream user document (realtime)
  Stream<UserModel?> streamUser(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  FAVOURITES OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  // Add movie to favourites
  Future<void> addFavourite(MovieModel movie) async {
    if (_uid == null) return;
    try {
      final batch = _db.batch();

      // Add to subcollection
      final favRef = _db
          .collection('users')
          .doc(_uid)
          .collection('favourites')
          .doc(movie.id);

      batch.set(favRef, {
        ...movie.toJson(),
        'addedAt': FieldValue.serverTimestamp(),
      });

      // Update favourites array in user doc
      final userRef = _db.collection('users').doc(_uid);
      batch.update(userRef, {
        'favourites': FieldValue.arrayUnion([movie.id]),
      });

      await batch.commit();
    } catch (e) {
      debugPrint('Error adding favourite: $e');
      rethrow;
    }
  }

  // Remove movie from favourites
  Future<void> removeFavourite(String movieId) async {
    if (_uid == null) return;
    try {
      final batch = _db.batch();

      // Remove from subcollection
      final favRef = _db
          .collection('users')
          .doc(_uid)
          .collection('favourites')
          .doc(movieId);
      batch.delete(favRef);

      // Update favourites array in user doc
      final userRef = _db.collection('users').doc(_uid);
      batch.update(userRef, {
        'favourites': FieldValue.arrayRemove([movieId]),
      });

      await batch.commit();
    } catch (e) {
      debugPrint('Error removing favourite: $e');
      rethrow;
    }
  }

  // Get all favourites
  Future<List<MovieModel>> getFavourites() async {
    if (_uid == null) return [];
    try {
      final snapshot = await _db
          .collection('users')
          .doc(_uid)
          .collection('favourites')
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return MovieModel.fromFirestore(doc.data());
      }).toList();
    } catch (e) {
      debugPrint('Error getting favourites: $e');
      return [];
    }
  }

  // Stream favourites (realtime)
  Stream<List<MovieModel>> streamFavourites() {
    if (_uid == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(_uid)
        .collection('favourites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MovieModel.fromFirestore(doc.data()))
            .toList());
  }

  // Check if movie is favourite
  Future<bool> isFavourite(String movieId) async {
    if (_uid == null) return false;
    try {
      final doc = await _db
          .collection('users')
          .doc(_uid)
          .collection('favourites')
          .doc(movieId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  RATINGS OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  // Submit rating
  Future<void> submitRating({
    required String movieId,
    required String movieTitle,
    required double rating,
  }) async {
    if (_uid == null) return;
    try {
      await _db
          .collection('ratings')
          .doc('${_uid}_$movieId')
          .set({
        'userId':     _uid,
        'movieId':    movieId,
        'movieTitle': movieTitle,
        'rating':     rating,
        'timestamp':  FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      rethrow;
    }
  }

  // Get user rating for a movie
  Future<double?> getUserRating(String movieId) async {
    if (_uid == null) return null;
    try {
      final doc = await _db
          .collection('ratings')
          .doc('${_uid}_$movieId')
          .get();
      if (doc.exists) {
        return (doc.data()!['rating'] as num).toDouble();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get all user ratings
  Future<List<Map<String, dynamic>>> getUserRatings() async {
    if (_uid == null) return [];
    try {
      final snapshot = await _db
          .collection('ratings')
          .where('userId', isEqualTo: _uid)
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((d) => d.data()).toList();
    } catch (e) {
      return [];
    }
  }

  // Get average rating for a movie
  Future<double> getMovieAverageRating(String movieId) async {
    try {
      final snapshot = await _db
          .collection('ratings')
          .where('movieId', isEqualTo: movieId)
          .get();
      if (snapshot.docs.isEmpty) return 0;
      final total = snapshot.docs
          .map((d) => (d.data()['rating'] as num).toDouble())
          .reduce((a, b) => a + b);
      return total / snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  WATCHLIST OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  // Add to watchlist
  Future<void> addToWatchlist(MovieModel movie) async {
    if (_uid == null) return;
    try {
      await _db
          .collection('watchlist')
          .doc('${_uid}_${movie.id}')
          .set({
        'userId':    _uid,
        'movieId':   movie.id,
        'title':     movie.title,
        'posterUrl': movie.posterUrl,
        'rating':    movie.rating,
        'addedAt':   FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding to watchlist: $e');
      rethrow;
    }
  }

  // Remove from watchlist
  Future<void> removeFromWatchlist(String movieId) async {
    if (_uid == null) return;
    try {
      await _db
          .collection('watchlist')
          .doc('${_uid}_$movieId')
          .delete();
    } catch (e) {
      debugPrint('Error removing from watchlist: $e');
      rethrow;
    }
  }

  // Get watchlist
  Future<List<Map<String, dynamic>>> getWatchlist() async {
    if (_uid == null) return [];
    try {
      final snapshot = await _db
          .collection('watchlist')
          .where('userId', isEqualTo: _uid)
          .orderBy('addedAt', descending: true)
          .get();
      return snapshot.docs.map((d) => d.data()).toList();
    } catch (e) {
      return [];
    }
  }

  // Check if in watchlist
  Future<bool> isInWatchlist(String movieId) async {
    if (_uid == null) return false;
    try {
      final doc = await _db
          .collection('watchlist')
          .doc('${_uid}_$movieId')
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  USER STATS
  // ══════════════════════════════════════════════════════════════════════════

  Future<Map<String, int>> getUserStats() async {
    if (_uid == null) return {'favourites': 0, 'rated': 0, 'watched': 0};
    try {
      final results = await Future.wait([
        _db
            .collection('users')
            .doc(_uid)
            .collection('favourites')
            .count()
            .get(),
        _db
            .collection('ratings')
            .where('userId', isEqualTo: _uid)
            .count()
            .get(),
        _db
            .collection('watchlist')
            .where('userId', isEqualTo: _uid)
            .count()
            .get(),
      ]);

      return {
        'favourites': results[0].count ?? 0,
        'rated':      results[1].count ?? 0,
        'watched':    results[2].count ?? 0,
      };
    } catch (e) {
      return {'favourites': 0, 'rated': 0, 'watched': 0};
    }
  }
}