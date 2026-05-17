import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/movie_model.dart';
import '../../providers/favourites_provider.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/movie_card.dart';

class MovieDetailScreen extends StatefulWidget {
  final MovieModel movie;
  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  double _userRating    = 0;
  bool   _ratingSubmitted = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FavouritesProvider>().loadFavourites();
    });
  }

  Future<void> _submitRating(double rating) async {
    setState(() {
      _userRating      = rating;
      _ratingSubmitted = true;
    });
    await context.read<MovieProvider>().submitRating(
          movieId: widget.movie.id,
          rating:  rating,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You rated ${widget.movie.title} $rating/5 ⭐'),
        backgroundColor: AppColors.surface,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavouritesProvider>();
    final isFav       = favProvider.isFavourite(widget.movie.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _DetailAppBar(movie: widget.movie),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Title
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize:   24,
                      fontWeight: FontWeight.bold,
                      color:      AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${widget.movie.releaseYear}'
                    ' · ${widget.movie.runtimeFormatted}'
                    ' · ${widget.movie.genres.isNotEmpty ? widget.movie.genres.join(", ") : ""}',
                    style: const TextStyle(
                      fontSize: 13,
                      color:    AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Genre pills
                  Wrap(
                    spacing:    8,
                    runSpacing: 8,
                    children: widget.movie.genres
                        .map((g) => _GenrePill(label: g))
                        .toList(),
                  ),

                  const SizedBox(height: 20),

                  // Rating row
                  _RatingRow(movie: widget.movie),

                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label:     AppStrings.watchNow,
                          icon:      Icons.play_circle_outline_rounded,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Opening player...'),
                                backgroundColor: AppColors.surface,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      FavouriteButton(
                        isFavourite: isFav,
                        onPressed: () async {
                          await favProvider.toggleFavourite(widget.movie);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFav
                                    ? 'Removed from favourites'
                                    : 'Added to favourites ❤️',
                              ),
                              backgroundColor: AppColors.surface,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _IconActionButton(
                        icon:      Icons.share_outlined,
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Stats grid
                  _StatsGrid(movie: widget.movie),

                  const SizedBox(height: 24),

                  // Overview
                  const _SectionTitle(title: AppStrings.overview),
                  const SizedBox(height: 10),
                  _ExpandableText(text: widget.movie.overview),

                  const SizedBox(height: 28),

                  // Your rating
                  const _SectionTitle(title: AppStrings.yourRating),
                  const SizedBox(height: 14),
                  _UserRatingSection(
                    userRating:      _userRating,
                    ratingSubmitted: _ratingSubmitted,
                    onRatingUpdate:  _submitRating,
                  ),

                  const SizedBox(height: 28),

                  // More like this
                  const _SectionTitle(title: 'More like this'),
                  const SizedBox(height: 14),
                  _MoreLikeThis(currentMovieId: widget.movie.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sliver app bar ─────────────────────────────────────────────────────────────
class _DetailAppBar extends StatelessWidget {
  final MovieModel movie;
  const _DetailAppBar({required this.movie});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight:  280,
      pinned:          true,
      backgroundColor: AppColors.background,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:        Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size:  18,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl:    movie.backdropUrl,
              fit:         BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.surface),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surface,
                child: const Icon(
                  Icons.movie_rounded,
                  color: AppColors.textMuted,
                  size:  60,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topCenter,
                  end:    Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rating row ────────────────────────────────────────────────────────────────
class _RatingRow extends StatelessWidget {
  final MovieModel movie;
  const _RatingRow({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize:   34,
                  fontWeight: FontWeight.bold,
                  color:      AppColors.star,
                ),
              ),
              Text(
                '${_formatVotes(movie.voteCount)} votes',
                style: const TextStyle(
                  fontSize: 11,
                  color:    AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Container(width: 0.5, height: 50, color: AppColors.border),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(5, (i) {
                  final filled = i < (movie.rating / 2).round();
                  return Icon(
                    filled
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.star,
                    size:  20,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '${movie.totalWatches} views',
                style: const TextStyle(
                  fontSize: 11,
                  color:    AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatVotes(int votes) {
    if (votes >= 1000) return '${(votes / 1000).toStringAsFixed(1)}K';
    return votes.toString();
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final MovieModel movie;
  const _StatsGrid({required this.movie});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'label': AppStrings.boxOffice,     'value': movie.revenue},
      {'label': AppStrings.totalWatches,  'value': movie.totalWatches},
      {'label': AppStrings.audienceScore, 'value': movie.audienceScore},
      {'label': AppStrings.trendingRank,  'value': movie.trendingRank},
    ];
    return GridView.count(
      crossAxisCount:   2,
      shrinkWrap:       true,
      physics:          const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing:  10,
      childAspectRatio: 2.4,
      children: stats
          .map((s) => _StatBox(label: s['label']!, value: s['value']!))
          .toList(),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:  MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.bold,
              color:      AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color:    AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── User rating section ───────────────────────────────────────────────────────
class _UserRatingSection extends StatelessWidget {
  final double   userRating;
  final bool     ratingSubmitted;
  final void Function(double) onRatingUpdate;

  const _UserRatingSection({
    required this.userRating,
    required this.ratingSubmitted,
    required this.onRatingUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          RatingBar.builder(
            initialRating:   userRating,
            minRating:       1,
            allowHalfRating: true,
            itemCount:       5,
            itemSize:        36,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (_, __) => const Icon(
              Icons.star_rounded,
              color: AppColors.star,
            ),
            onRatingUpdate: onRatingUpdate,
          ),
          const SizedBox(height: 12),
          Text(
            ratingSubmitted
                ? 'Your rating: $userRating / 5'
                : 'Tap a star to rate this movie',
            style: TextStyle(
              fontSize: 13,
              color: ratingSubmitted ? AppColors.star : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Expandable text ───────────────────────────────────────────────────────────
class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _expanded ? null : 3,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color:    AppColors.textSecondary,
            height:   1.7,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Show less' : 'Read more',
            style: const TextStyle(
              fontSize:   12,
              color:      AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── More like this ────────────────────────────────────────────────────────────
class _MoreLikeThis extends StatelessWidget {
  final String currentMovieId;
  const _MoreLikeThis({required this.currentMovieId});

  @override
  Widget build(BuildContext context) {
    final movies = context
        .watch<MovieProvider>()
        .trendingMovies
        .where((m) => m.id != currentMovieId)
        .take(6)
        .toList();

    if (movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection:  Axis.horizontal,
        itemCount:        movies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => MovieCard(
          movie:  movies[i],
          width:  110,
          height: 160,
        ),
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize:   16,
        fontWeight: FontWeight.w600,
        color:      AppColors.textPrimary,
      ),
    );
  }
}

class _GenrePill extends StatelessWidget {
  final String label;
  const _GenrePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color:        AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color:    AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onPressed;
  const _IconActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width:  48,
        height: 48,
        decoration: BoxDecoration(
          color:        AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}