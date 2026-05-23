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

  bool    _isLoading        = false;
  String? _error;
  int     _ratedMoviesCount = 0;
  int     _watchedCount     = 0;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<MovieModel> get trendingMovies   => _trendingMovies;
  List<MovieModel> get newReleases      => _newReleases;
  List<MovieModel> get topRatedMovies   => _topRatedMovies;
  MovieModel?      get featuredMovie    => _featuredMovie;
  bool             get isLoading        => _isLoading;
  String?          get error            => _error;
  int              get ratedMoviesCount => _ratedMoviesCount;
  int              get watchedCount     => _watchedCount;

  // ── TMDB Config ────────────────────────────────────────────────────────────
  static const String _apiKey  = 'bbe699b7c07385e0aa7d055715d21d04';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // ── TMDB Genre ID map ──────────────────────────────────────────────────────
  static const Map<String, int> genreNameToId = {
    'All':       0,
    'Action':    28,
    'Adventure': 12,
    'Animation': 16,
    'Comedy':    35,
    'Crime':     80,
    'Drama':     18,
    'Fantasy':   14,
    'Horror':    27,
    'Mystery':   9648,
    'Romance':   10749,
    'Sci-Fi':    878,
    'Thriller':  53,
  };

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

      if (_trendingMovies.isNotEmpty) {
        _featuredMovie = _trendingMovies.first;
      }

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
    final res = await http.get(url).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final data    = json.decode(res.body);
      final results = data['results'] as List<dynamic>;
      _trendingMovies = results
          .take(15)
          .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Trending fetch failed');
    }
  }

  // ── Fetch new releases ─────────────────────────────────────────────────────
  Future<void> _fetchNewReleases() async {
    final now      = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 60));
    final from = '${monthAgo.year}-${_pad(monthAgo.month)}-${_pad(monthAgo.day)}';
    final to   = '${now.year}-${_pad(now.month)}-${_pad(now.day)}';

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
      _newReleases  = results.take(15).map((m) {
        final map = Map<String, dynamic>.from(m as Map);
        map['isNewRelease'] = true;
        return MovieModel.fromJson(map);
      }).toList();
    } else {
      throw Exception('New releases fetch failed');
    }
  }

  // ── Fetch top rated ────────────────────────────────────────────────────────
  Future<void> _fetchTopRated() async {
    final url = Uri.parse('$_baseUrl/movie/top_rated?api_key=$_apiKey');
    final res = await http.get(url).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final data    = json.decode(res.body);
      final results = data['results'] as List<dynamic>;
      _topRatedMovies = results
          .take(15)
          .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Top rated fetch failed');
    }
  }

  // ── Fetch movies by genre from TMDB ───────────────────────────────────────
  Future<List<MovieModel>> fetchByGenreName(String genreName) async {
    if (genreName == 'All') return _trendingMovies;

    final genreId = genreNameToId[genreName];
    if (genreId == null) return [];

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

  // ── Search movies ──────────────────────────────────────────────────────────
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
      return [];
    }
  }

  // ── Fetch movie detail ─────────────────────────────────────────────────────
  Future<MovieModel?> fetchMovieDetail(String movieId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/movie/$movieId'
        '?api_key=$_apiKey'
        '&append_to_response=credits',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return MovieModel.fromJson(data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ── Submit rating ──────────────────────────────────────────────────────────
  Future<void> submitRating({
    required String movieId,
    required double rating,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
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

  // ── Get user rating ────────────────────────────────────────────────────────
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
      final ratingSnap = await _firestore
          .collection('ratings')
          .where('userId', isEqualTo: uid)
          .get();
      _ratedMoviesCount = ratingSnap.docs.length;

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

  // ── Helper ─────────────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}