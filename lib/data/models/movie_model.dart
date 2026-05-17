class MovieModel {
  final String       id;
  final String       title;
  final String       overview;
  final String       posterUrl;
  final String       backdropUrl;
  final double       rating;
  final int          voteCount;
  final String       releaseDate;
  final List<String> genres;
  final int          runtime;
  final String       revenue;
  final String       totalWatches;
  final String       audienceScore;
  final String       trendingRank;
  final bool         isNewRelease;

  const MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.backdropUrl,
    required this.rating,
    required this.voteCount,
    required this.releaseDate,
    required this.genres,
    required this.runtime,
    required this.revenue,
    required this.totalWatches,
    required this.audienceScore,
    required this.trendingRank,
    this.isNewRelease = false,
  });

  // ── Runtime formatted ─────────────────────────────────────────────────────
  String get runtimeFormatted {
    if (runtime == 0) return 'N/A';
    final h = runtime ~/ 60;
    final m = runtime % 60;
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }

  // ── Release year ──────────────────────────────────────────────────────────
  String get releaseYear {
    if (releaseDate.length >= 4) return releaseDate.substring(0, 4);
    return '';
  }

  // ── Genre map ─────────────────────────────────────────────────────────────
  static const Map<int, String> _genreMap = {
    28:    'Action',    12:    'Adventure', 16:    'Animation',
    35:    'Comedy',    80:    'Crime',     99:    'Documentary',
    18:    'Drama',     10751: 'Family',    14:    'Fantasy',
    36:    'History',   27:    'Horror',    10402: 'Music',
    9648:  'Mystery',   10749: 'Romance',   878:   'Sci-Fi',
    10770: 'TV Movie',  53:    'Thriller',  10752: 'War',
    37:    'Western',
  };

  // ── From TMDB JSON ────────────────────────────────────────────────────────
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final posterPath   = json['poster_path']   as String? ?? '';
    final backdropPath = json['backdrop_path'] as String? ?? '';

    final genreIds = json['genre_ids'] as List<dynamic>? ?? [];
    final genres   = genreIds
        .map((id) => _genreMap[id as int] ?? 'Movie')
        .toList();

    final revenueRaw = json['revenue'] as int? ?? 0;
    final revenueStr = revenueRaw > 0
        ? '\$${(revenueRaw / 1e6).toStringAsFixed(1)}M'
        : 'N/A';

    final popularity = (json['popularity'] as num?)?.toDouble() ?? 0;
    final watchStr   = popularity > 0
        ? '${popularity.toStringAsFixed(1)}K'
        : 'N/A';

    final voteAvg  = (json['vote_average'] as num?)?.toDouble() ?? 0;
    final scoreStr = voteAvg > 0
        ? '${((voteAvg / 10) * 100).toInt()}%'
        : 'N/A';

    return MovieModel(
      id:            (json['id'] ?? 0).toString(),
      title:         (json['title']        as String?) ?? 'Unknown',
      overview:      (json['overview']     as String?) ?? '',
      posterUrl:     posterPath.isNotEmpty
                         ? 'https://image.tmdb.org/t/p/w500$posterPath'
                         : '',
      backdropUrl:   backdropPath.isNotEmpty
                         ? 'https://image.tmdb.org/t/p/w780$backdropPath'
                         : '',
      rating:        voteAvg,
      voteCount:     (json['vote_count']   as int?)    ?? 0,
      releaseDate:   (json['release_date'] as String?) ?? '',
      genres:        genres,
      runtime:       (json['runtime']      as int?)    ?? 0,
      revenue:       revenueStr,
      totalWatches:  watchStr,
      audienceScore: scoreStr,
      trendingRank:  '#?',
      isNewRelease:  json['isNewRelease']  as bool?    ?? false,
    );
  }

  // ── From Firestore ────────────────────────────────────────────────────────
  factory MovieModel.fromFirestore(Map<String, dynamic> data) {
    return MovieModel(
      id:            (data['id']            as String?) ?? '',
      title:         (data['title']         as String?) ?? '',
      overview:      (data['overview']      as String?) ?? '',
      posterUrl:     (data['posterUrl']     as String?) ?? '',
      backdropUrl:   (data['backdropUrl']   as String?) ?? '',
      rating:        (data['rating']        as num?)?.toDouble() ?? 0,
      voteCount:     (data['voteCount']     as int?)    ?? 0,
      releaseDate:   (data['releaseDate']   as String?) ?? '',
      genres:        List<String>.from(data['genres']   as List? ?? []),
      runtime:       (data['runtime']       as int?)    ?? 0,
      revenue:       (data['revenue']       as String?) ?? 'N/A',
      totalWatches:  (data['totalWatches']  as String?) ?? 'N/A',
      audienceScore: (data['audienceScore'] as String?) ?? 'N/A',
      trendingRank:  (data['trendingRank']  as String?) ?? 'N/A',
      isNewRelease:  (data['isNewRelease']  as bool?)   ?? false,
    );
  }

  // ── To JSON ───────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'id':            id,
    'title':         title,
    'overview':      overview,
    'posterUrl':     posterUrl,
    'backdropUrl':   backdropUrl,
    'rating':        rating,
    'voteCount':     voteCount,
    'releaseDate':   releaseDate,
    'genres':        genres,
    'runtime':       runtime,
    'revenue':       revenue,
    'totalWatches':  totalWatches,
    'audienceScore': audienceScore,
    'trendingRank':  trendingRank,
    'isNewRelease':  isNewRelease,
  };

  // ── Copy with ─────────────────────────────────────────────────────────────
  MovieModel copyWith({
    String? trendingRank,
    bool?   isNewRelease,
  }) {
    return MovieModel(
      id:            id,
      title:         title,
      overview:      overview,
      posterUrl:     posterUrl,
      backdropUrl:   backdropUrl,
      rating:        rating,
      voteCount:     voteCount,
      releaseDate:   releaseDate,
      genres:        genres,
      runtime:       runtime,
      revenue:       revenue,
      totalWatches:  totalWatches,
      audienceScore: audienceScore,
      trendingRank:  trendingRank ?? this.trendingRank,
      isNewRelease:  isNewRelease ?? this.isNewRelease,
    );
  }
}