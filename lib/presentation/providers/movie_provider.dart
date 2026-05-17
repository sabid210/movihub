import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../data/models/movie_model.dart';

class MovieProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth      _auth      = FirebaseAuth.instance;

  // ── State ──────────────────────────────────────────────────────────────────
  List<MovieModel> _trendingMovies  = [];
  List<MovieModel> _newReleases     = [];
  List<MovieModel> _topRatedMovies  = [];
  MovieModel?      _featuredMovie;

  bool    _isLoading = false;
  String? _error;

  int _ratedMoviesCount = 0;
  int _watchedCount     = 0;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<MovieModel> get trendingMovies  => _trendingMovies;
  List<MovieModel> get newReleases     => _newReleases;
  List<MovieModel> get topRatedMovies  => _topRatedMovies;
  MovieModel?      get featuredMovie   => _featuredMovie;
  bool             get isLoading       => _isLoading;
  String?          get error           => _error;
  int              get ratedMoviesCount => _ratedMoviesCount;
  int              get watchedCount    => _watchedCount;

  // ── TMDB config ────────────────────────────────────────────────────────────
  // Replace with your own TMDB API key from https://www.themoviedb.org/settings/api
  static const String _apiKey  = 'bbe699b7c07385e0aa7d055715d21d04';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // ── Fetch all movies ───────────────────────────────────────────────────────
  Future<void> fetchAllMovies() async {
    _setLoading(true);
    _error = null;

    try {
      await Future.wait([
        _fetchTrending(),
        _fetchNewReleases(),
        _fetchTopRated(),
      ]);

      // Set featured movie from trending
      if (_trendingMovies.isNotEmpty) {
        _featuredMovie = _trendingMovies.first;
      }

      // Load user stats
      await _loadUserStats();

      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load movies. Check your connection.';
      _setLoading(false);
    }
  }

  // ── Fetch trending ─────────────────────────────────────────────────────────
  Future<void> _fetchTrending() async {
    final url = Uri.parse('$_baseUrl/trending/movie/week?api_key=$_apiKey');
    final res  = await http.get(url);

    if (res.statusCode == 200) {
      final data    = json.decode(res.body);
      final results = data['results'] as List<dynamic>;
      _trendingMovies = results
          .take(10)
          .map((m) => MovieModel.fromJson(m))
          .toList();
    } else {
      throw Exception('Trending fetch failed');
    }
  }

  // ── Fetch new releases ─────────────────────────────────────────────────────
  Future<void> _fetchNewReleases() async {
    final now       = DateTime.now();
    final monthAgo  = now.subtract(const Duration(days: 30));
    final fromDate  = '${monthAgo.year}-${_pad(monthAgo.month)}-${_pad(monthAgo.day)}';
    final toDate    = '${now.year}-${_pad(now.month)}-${_pad(now.day)}';

    final url = Uri.parse(
      '$_baseUrl/discover/movie'
      '?api_key=$_apiKey'
      '&primary_release_date.gte=$fromDate'
      '&primary_release_date.lte=$toDate'
      '&sort_by=popularity.desc',
    );

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data    = json.decode(res.body);
      final results = data['results'] as List<dynamic>;
      _newReleases  = results
          .take(10)
          .map((m) => MovieModel.fromJson(m
            ..['isNewRelease'] = true))
          .toList();
    } else {
      throw Exception('New releases fetch failed');
    }
  }

  // ── Fetch top rated ────────────────────────────────────────────────────────
  Future<void> _fetchTopRated() async {
    final url = Uri.parse(
      '$_baseUrl/movie/top_rated?api_key=$_apiKey',
    );
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data    = json.decode(res.body);
      final results = data['results'] as List<dynamic>;
      _topRatedMovies = results
          .take(10)
          .map((m) => MovieModel.fromJson(m))
          .toList();
    } else {
      throw Exception('Top rated fetch failed');
    }
  }

  // ── Search movies ──────────────────────────────────────────────────────────
  Future<List<MovieModel>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(query)}',
      );
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data    = json.decode(res.body);
        final results = data['results'] as List<dynamic>;
        return results
            .take(20)
            .map((m) => MovieModel.fromJson(m))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ── Fetch movie detail (with runtime) ──────────────────────────────────────
  Future<MovieModel?> fetchMovieDetail(String movieId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/movie/$movieId?api_key=$_apiKey&append_to_response=credits',
      );
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return MovieModel.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ── Submit user rating ─────────────────────────────────────────────────────
  Future<void> submitRating({
    required String movieId,
    required double rating,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      // Save to Firestore
      await _firestore
          .collection('ratings')
          .doc('${uid}_$movieId')
          .set({
        'userId':    uid,
        'movieId':   movieId,
        'rating':    rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _ratedMoviesCount++;
      notifyListeners();
    } catch (e) {
      debugPrint('Error submitting rating: $e');
    }
  }

  // ── Get user rating for a movie ────────────────────────────────────────────
  Future<double?> getUserRating(String movieId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _firestore
          .collection('ratings')
          .doc('${uid}_$movieId')
          .get();

      if (doc.exists) {
        return (doc.data()!['rating'] as num).toDouble();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ── Load user stats ────────────────────────────────────────────────────────
  Future<void> _loadUserStats() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      // Rated count
      final ratingSnap = await _firestore
          .collection('ratings')
          .where('userId', isEqualTo: uid)
          .get();
      _ratedMoviesCount = ratingSnap.docs.length;

      // Watched count (from Firestore watchlist)
      final watchSnap = await _firestore
          .collection('watchlist')
          .where('userId', isEqualTo: uid)
          .get();
      _watchedCount = watchSnap.docs.length;
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  // ── Add to watchlist ───────────────────────────────────────────────────────
  Future<void> addToWatchlist(MovieModel movie) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection('watchlist')
          .doc('${uid}_${movie.id}')
          .set({
        'userId':    uid,
        'movieId':   movie.id,
        'title':     movie.title,
        'posterUrl': movie.posterUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _watchedCount++;
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to watchlist: $e');
    }
  }

  // ── Fetch movies by genre ──────────────────────────────────────────────────
  Future<List<MovieModel>> fetchByGenre(int genreId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/discover/movie'
        '?api_key=$_apiKey'
        '&with_genres=$genreId'
        '&sort_by=popularity.desc',
      );
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data    = json.decode(res.body);
        final results = data['results'] as List<dynamic>;
        return results
            .take(15)
            .map((m) => MovieModel.fromJson(m))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}