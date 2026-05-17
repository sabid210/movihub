import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/movie_model.dart';
import '../services/firestore_service.dart';

class MovieRepository {
  final FirebaseFirestore  _firestore = FirebaseFirestore.instance;
  final FirebaseAuth       _auth      = FirebaseAuth.instance;
  final FirestoreService   _firestoreService = FirestoreService();

  // ── TMDB Config ───────────────────────────────────────────────────────────
  static const String _apiKey  = 'bbe699b7c07385e0aa7d055715d21d04';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // ══════════════════════════════════════════════════════════════════════════
  //  TMDB API CALLS
  // ══════════════════════════════════════════════════════════════════════════

  // Fetch trending movies
  Future<List<MovieModel>> fetchTrending() async {
    try {
      final url = Uri.parse('$_baseUrl/trending/movie/week?api_key=$_apiKey');
      final res = await http.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data    = json.decode(res.body);
        final results = data['results'] as List<dynamic>;
        return results
            .take(10)
            .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching trending: $e');
      return [];
    }
  }

  // Fetch new releases
  Future<List<MovieModel>> fetchNewReleases() async {
    try {
      final now      = DateTime.now();
      final monthAgo = now.subtract(const Duration(days: 30));
      final from     = _formatDate(monthAgo);
      final to       = _formatDate(now);

      final url = Uri.parse(
        '$_baseUrl/discover/movie'
        '?api_key=$_apiKey'
        '&primary_release_date.gte=$from'
        '&primary_release_date.lte=$to'
        '&sort_by=popularity.desc',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data    = json.decode(res.body);
        final results = data['results'] as List<dynamic>;
        return results.take(10).map((m) {
          final map = Map<String, dynamic>.from(m as Map);
          map['isNewRelease'] = true;
          return MovieModel.fromJson(map);
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching new releases: $e');
      return [];
    }
  }

  // Fetch top rated
  Future<List<MovieModel>> fetchTopRated() async {
    try {
      final url = Uri.parse(
        '$_baseUrl/movie/top_rated?api_key=$_apiKey',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data    = json.decode(res.body);
        final results = data['results'] as List<dynamic>;
        return results
            .take(10)
            .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching top rated: $e');
      return [];
    }
  }

  // Search movies
  Future<List<MovieModel>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final url = Uri.parse(
        '$_baseUrl/search/movie'
        '?api_key=$_apiKey'
        '&query=${Uri.encodeComponent(query)}'
        '&include_adult=false',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data    = json.decode(res.body);
        final results = data['results'] as List<dynamic>;
        return results
            .take(20)
            .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error searching movies: $e');
      return [];
    }
  }

  // Fetch movie detail
  Future<MovieModel?> fetchMovieDetail(String movieId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/movie/$movieId'
        '?api_key=$_apiKey'
        '&append_to_response=credits,videos',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return MovieModel.fromJson(data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching movie detail: $e');
      return null;
    }
  }

  // Fetch movies by genre
  Future<List<MovieModel>> fetchByGenre(int genreId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/discover/movie'
        '?api_key=$_apiKey'
        '&with_genres=$genreId'
        '&sort_by=popularity.desc',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data    = json.decode(res.body);
        final results = data['results'] as List<dynamic>;
        return results
            .take(15)
            .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching by genre: $e');
      return [];
    }
  }

  // Fetch popular movies
  Future<List<MovieModel>> fetchPopular() async {
    try {
      final url = Uri.parse(
        '$_baseUrl/movie/popular?api_key=$_apiKey',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data    = json.decode(res.body);
        final results = data['results'] as List<dynamic>;
        return results
            .take(10)
            .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching popular: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  FIRESTORE OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  // Submit rating
  Future<void> submitRating({
    required String movieId,
    required String movieTitle,
    required double rating,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestoreService.submitRating(
        movieId:    movieId,
        movieTitle: movieTitle,
        rating:     rating,
      );
    } catch (e) {
      debugPrint('Error submitting rating: $e');
    }
  }

  // Get user rating
  Future<double?> getUserRating(String movieId) async {
    return _firestoreService.getUserRating(movieId);
  }

  // Get movie average rating
  Future<double> getMovieAverageRating(String movieId) async {
    return _firestoreService.getMovieAverageRating(movieId);
  }

  // Get all user ratings
  Future<List<Map<String, dynamic>>> getUserRatings() async {
    return _firestoreService.getUserRatings();
  }

  // Add to watchlist
  Future<void> addToWatchlist(MovieModel movie) async {
    try {
      await _firestoreService.addToWatchlist(movie);
    } catch (e) {
      debugPrint('Error adding to watchlist: $e');
    }
  }

  // Remove from watchlist
  Future<void> removeFromWatchlist(String movieId) async {
    try {
      await _firestoreService.removeFromWatchlist(movieId);
    } catch (e) {
      debugPrint('Error removing from watchlist: $e');
    }
  }

  // Check watchlist
  Future<bool> isInWatchlist(String movieId) async {
    return _firestoreService.isInWatchlist(movieId);
  }

  // Get watchlist
  Future<List<Map<String, dynamic>>> getWatchlist() async {
    return _firestoreService.getWatchlist();
  }

  // Save movie to Firestore cache
  Future<void> cacheMovie(MovieModel movie) async {
    try {
      await _firestore
          .collection('movies')
          .doc(movie.id)
          .set(movie.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error caching movie: $e');
    }
  }

  // Get cached movie from Firestore
  Future<MovieModel?> getCachedMovie(String movieId) async {
    try {
      final doc = await _firestore
          .collection('movies')
          .doc(movieId)
          .get();
      if (doc.exists && doc.data() != null) {
        return MovieModel.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  HELPER
  // ══════════════════════════════════════════════════════════════════════════
  String _formatDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}