import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/movie_model.dart';

enum FavouriteSort { recentlyAdded, highestRated, alphabetical }

class FavouritesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth      _auth      = FirebaseAuth.instance;

  // ── State ──────────────────────────────────────────────────────────────────
  List<MovieModel>  _favourites = [];
  bool              _isLoading  = false;
  FavouriteSort     _sortBy     = FavouriteSort.recentlyAdded;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<MovieModel> get favourites => _sortedFavourites();
  bool             get isLoading  => _isLoading;
  FavouriteSort    get sortBy     => _sortBy;

  // ── Load favourites from Firestore ─────────────────────────────────────────
  Future<void> loadFavourites() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _setLoading(true);
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('favourites')
          .orderBy('addedAt', descending: true)
          .get();

      _favourites = snapshot.docs.map((doc) {
        final data = doc.data();
        return MovieModel(
          id:            data['id']            ?? '',
          title:         data['title']         ?? '',
          overview:      data['overview']      ?? '',
          posterUrl:     data['posterUrl']     ?? '',
          backdropUrl:   data['backdropUrl']   ?? '',
          rating:        (data['rating']       ?? 0).toDouble(),
          voteCount:     data['voteCount']     ?? 0,
          releaseDate:   data['releaseDate']   ?? '',
          genres:        List<String>.from(data['genres'] ?? []),
          runtime:       data['runtime']       ?? 0,
          revenue:       data['revenue']       ?? 'N/A',
          totalWatches:  data['totalWatches']  ?? 'N/A',
          audienceScore: data['audienceScore'] ?? 'N/A',
          trendingRank:  data['trendingRank']  ?? 'N/A',
          isNewRelease:  data['isNewRelease']  ?? false,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading favourites: $e');
    }
    _setLoading(false);
  }

  // ── Toggle favourite ───────────────────────────────────────────────────────
  Future<void> toggleFavourite(MovieModel movie) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('favourites')
        .doc(movie.id);

    if (isFavourite(movie.id)) {
      // Remove
      await docRef.delete();
      _favourites.removeWhere((m) => m.id == movie.id);
    } else {
      // Add
      await docRef.set({
        'id':            movie.id,
        'title':         movie.title,
        'overview':      movie.overview,
        'posterUrl':     movie.posterUrl,
        'backdropUrl':   movie.backdropUrl,
        'rating':        movie.rating,
        'voteCount':     movie.voteCount,
        'releaseDate':   movie.releaseDate,
        'genres':        movie.genres,
        'runtime':       movie.runtime,
        'revenue':       movie.revenue,
        'totalWatches':  movie.totalWatches,
        'audienceScore': movie.audienceScore,
        'trendingRank':  movie.trendingRank,
        'isNewRelease':  movie.isNewRelease,
        'addedAt':       FieldValue.serverTimestamp(),
      });
      _favourites.insert(0, movie);
    }

    // Also update user doc favourites array
    await _updateUserFavouritesArray(movie.id);

    notifyListeners();
  }

  // ── Check if movie is favourite ────────────────────────────────────────────
  bool isFavourite(String movieId) {
    return _favourites.any((m) => m.id == movieId);
  }

  // ── Set sort ───────────────────────────────────────────────────────────────
  void setSortBy(FavouriteSort sort) {
    _sortBy = sort;
    notifyListeners();
  }

  // ── Clear all favourites ───────────────────────────────────────────────────
  Future<void> clearAll() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _setLoading(true);
    try {
      final batch    = _firestore.batch();
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('favourites')
          .get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Clear user doc array too
      await _firestore.collection('users').doc(uid).update({
        'favourites': [],
      });

      _favourites.clear();
    } catch (e) {
      debugPrint('Error clearing favourites: $e');
    }
    _setLoading(false);
  }

  // ── Get favourites count ───────────────────────────────────────────────────
  int get count => _favourites.length;

  // ── Sorted list ────────────────────────────────────────────────────────────
  List<MovieModel> _sortedFavourites() {
    final list = List<MovieModel>.from(_favourites);
    switch (_sortBy) {
      case FavouriteSort.recentlyAdded:
        // Already ordered by addedAt desc from Firestore
        return list;
      case FavouriteSort.highestRated:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        return list;
      case FavouriteSort.alphabetical:
        list.sort((a, b) => a.title.compareTo(b.title));
        return list;
    }
  }

  // ── Update user doc favourites array ──────────────────────────────────────
  Future<void> _updateUserFavouritesArray(String movieId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final isFav = isFavourite(movieId);
      await _firestore.collection('users').doc(uid).update({
        'favourites': isFav
            ? FieldValue.arrayUnion([movieId])
            : FieldValue.arrayRemove([movieId]),
      });
    } catch (e) {
      debugPrint('Error updating favourites array: $e');
    }
  }

  // ── Helper ─────────────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}