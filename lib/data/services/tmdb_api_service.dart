import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/movie_model.dart';

class TmdbApiService {
  // ── Config ────────────────────────────────────────────────────────────────
  static const String _apiKey  = 'bbe699b7c07385e0aa7d055715d21d04';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBase = 'https://image.tmdb.org/t/p';

  static const Duration _timeout = Duration(seconds: 10);

  // ── Image URL helpers ─────────────────────────────────────────────────────
  static String posterUrl(String path, {String size = 'w500'}) =>
      '$_imageBase/$size$path';

  static String backdropUrl(String path, {String size = 'w780'}) =>
      '$_imageBase/$size$path';

  static String profileUrl(String path, {String size = 'w185'}) =>
      '$_imageBase/$size$path';

  // ══════════════════════════════════════════════════════════════════════════
  //  MOVIES
  // ══════════════════════════════════════════════════════════════════════════

  // Trending movies (week)
  Future<List<MovieModel>> getTrending({String timeWindow = 'week'}) async {
    return _fetchMovieList(
      '$_baseUrl/trending/movie/$timeWindow?api_key=$_apiKey',
    );
  }

  // Now playing
  Future<List<MovieModel>> getNowPlaying() async {
    return _fetchMovieList(
      '$_baseUrl/movie/now_playing?api_key=$_apiKey',
    );
  }

  // Popular
  Future<List<MovieModel>> getPopular() async {
    return _fetchMovieList(
      '$_baseUrl/movie/popular?api_key=$_apiKey',
    );
  }

  // Top rated
  Future<List<MovieModel>> getTopRated() async {
    return _fetchMovieList(
      '$_baseUrl/movie/top_rated?api_key=$_apiKey',
    );
  }

  // Upcoming
  Future<List<MovieModel>> getUpcoming() async {
    return _fetchMovieList(
      '$_baseUrl/movie/upcoming?api_key=$_apiKey',
    );
  }

  // New releases (last 30 days)
  Future<List<MovieModel>> getNewReleases() async {
    final now      = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    final from     = _formatDate(monthAgo);
    final to       = _formatDate(now);

    return _fetchMovieList(
      '$_baseUrl/discover/movie'
      '?api_key=$_apiKey'
      '&primary_release_date.gte=$from'
      '&primary_release_date.lte=$to'
      '&sort_by=popularity.desc',
      isNewRelease: true,
    );
  }

  // Movie detail
  Future<MovieModel?> getMovieDetail(String movieId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/movie/$movieId'
        '?api_key=$_apiKey'
        '&append_to_response=credits,videos,similar',
      );
      final res = await http.get(url).timeout(_timeout);

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        return MovieModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting movie detail: $e');
      return null;
    }
  }

  // Search movies
  Future<List<MovieModel>> searchMovies({
    required String query,
    int page = 1,
  }) async {
    if (query.trim().isEmpty) return [];
    return _fetchMovieList(
      '$_baseUrl/search/movie'
      '?api_key=$_apiKey'
      '&query=${Uri.encodeComponent(query)}'
      '&page=$page'
      '&include_adult=false',
    );
  }

  // Movies by genre
  Future<List<MovieModel>> getMoviesByGenre({
    required int genreId,
    int page = 1,
    String sortBy = 'popularity.desc',
  }) async {
    return _fetchMovieList(
      '$_baseUrl/discover/movie'
      '?api_key=$_apiKey'
      '&with_genres=$genreId'
      '&sort_by=$sortBy'
      '&page=$page',
    );
  }

  // Similar movies
  Future<List<MovieModel>> getSimilarMovies(String movieId) async {
    return _fetchMovieList(
      '$_baseUrl/movie/$movieId/similar?api_key=$_apiKey',
    );
  }

  // Recommended movies
  Future<List<MovieModel>> getRecommendedMovies(String movieId) async {
    return _fetchMovieList(
      '$_baseUrl/movie/$movieId/recommendations?api_key=$_apiKey',
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  GENRES
  // ══════════════════════════════════════════════════════════════════════════

  // Get genre list
  Future<List<Map<String, dynamic>>> getGenres() async {
    try {
      final url = Uri.parse(
        '$_baseUrl/genre/movie/list?api_key=$_apiKey',
      );
      final res = await http.get(url).timeout(_timeout);

      if (res.statusCode == 200) {
        final data   = json.decode(res.body) as Map<String, dynamic>;
        final genres = data['genres'] as List<dynamic>;
        return genres
            .map((g) => g as Map<String, dynamic>)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting genres: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  CAST & CREW
  // ══════════════════════════════════════════════════════════════════════════

  // Get movie cast
  Future<List<Map<String, dynamic>>> getMovieCast(String movieId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/movie/$movieId/credits?api_key=$_apiKey',
      );
      final res = await http.get(url).timeout(_timeout);

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final cast = data['cast'] as List<dynamic>;
        return cast
            .take(10)
            .map((c) {
          final member = c as Map<String, dynamic>;
          return {
            'id':          member['id'],
            'name':        member['name'] ?? '',
            'character':   member['character'] ?? '',
            'profilePath': member['profile_path'] != null
                ? profileUrl(member['profile_path'] as String)
                : '',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting cast: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  VIDEOS / TRAILERS
  // ══════════════════════════════════════════════════════════════════════════

  // Get movie trailer
  Future<String?> getMovieTrailer(String movieId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/movie/$movieId/videos?api_key=$_apiKey',
      );
      final res = await http.get(url).timeout(_timeout);

      if (res.statusCode == 200) {
        final data    = json.decode(res.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;

        // Find YouTube trailer
        final trailer = results.firstWhere(
          (v) =>
              (v as Map<String, dynamic>)['site'] == 'YouTube' &&
              v['type'] == 'Trailer',
          orElse: () => null,
        );

        if (trailer != null) {
          final key = (trailer as Map<String, dynamic>)['key'] as String;
          return 'https://www.youtube.com/watch?v=$key';
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting trailer: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  MULTI SEARCH
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<MovieModel>> multiSearch(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final url = Uri.parse(
        '$_baseUrl/search/multi'
        '?api_key=$_apiKey'
        '&query=${Uri.encodeComponent(query)}'
        '&include_adult=false',
      );
      final res = await http.get(url).timeout(_timeout);

      if (res.statusCode == 200) {
        final data    = json.decode(res.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;

        // Filter only movies
        return results
            .where((r) => (r as Map<String, dynamic>)['media_type'] == 'movie')
            .take(20)
            .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error in multi search: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<MovieModel>> _fetchMovieList(
    String endpoint, {
    bool isNewRelease = false,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(endpoint);
      final res = await http.get(url).timeout(_timeout);

      if (res.statusCode == 200) {
        final data    = json.decode(res.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;

        return results.take(limit).map((m) {
          final map = Map<String, dynamic>.from(m as Map);
          if (isNewRelease) map['isNewRelease'] = true;
          return MovieModel.fromJson(map);
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching movie list: $e');
      return [];
    }
  }

  String _formatDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}