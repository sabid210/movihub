import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/movie_model.dart';

// ── Vertical card (used in horizontal scroll rows) ────────────────────────────
class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final double width;
  final double height;

  const MovieCard({
    super.key,
    required this.movie,
    this.width  = 130,
    this.height = 195,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.detail, extra: movie),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Poster ──────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl:    movie.posterUrl,
                    width:       width,
                    height:      height,
                    fit:         BoxFit.cover,
                    placeholder: (_, __) => _ShimmerBox(
                      width:  width,
                      height: height,
                    ),
                    errorWidget: (_, __, ___) => _PosterFallback(
                      width:  width,
                      height: height,
                      title:  movie.title,
                    ),
                  ),

                  // New release badge
                  if (movie.isNewRelease)
                    Positioned(
                      top:  8,
                      left: 8,
                      child: _Badge(label: 'New', color: AppColors.primary),
                    ),

                  // IMDb rating chip
                  Positioned(
                    bottom: 8,
                    right:  8,
                    child: _RatingChip(rating: movie.rating),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Title ────────────────────────────────────────────
            Text(
              movie.title,
              maxLines:  1,
              overflow:  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w500,
                color:      AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 3),

            // ── Genre · Year ──────────────────────────────────────
            Text(
              '${movie.genres.isNotEmpty ? movie.genres.first : "Movie"} · '
              '${movie.releaseDate.isNotEmpty ? movie.releaseDate.substring(0, 4) : ""}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color:    AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Horizontal card (used in search / favourites list) ────────────────────────
class MovieListCard extends StatelessWidget {
  final MovieModel movie;

  const MovieListCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.detail, extra: movie),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            // ── Poster ────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl:    movie.posterUrl,
                width:       70,
                height:      100,
                fit:         BoxFit.cover,
                placeholder: (_, __) =>
                    _ShimmerBox(width: 70, height: 100),
                errorWidget: (_, __, ___) =>
                    _PosterFallback(width: 70, height: 100, title: movie.title),
              ),
            ),

            const SizedBox(width: 14),

            // ── Info ──────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize:   15,
                      fontWeight: FontWeight.w600,
                      color:      AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Genre · Year · Runtime
                  Text(
                    '${movie.genres.isNotEmpty ? movie.genres.first : "Movie"}'
                    ' · ${movie.releaseDate.isNotEmpty ? movie.releaseDate.substring(0, 4) : ""}'
                    ' · ${movie.runtimeFormatted}',
                    style: const TextStyle(
                      fontSize: 12,
                      color:    AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Rating row
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.star,
                        size:  16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize:   13,
                          fontWeight: FontWeight.w600,
                          color:      AppColors.star,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_formatVotes(movie.voteCount)})',
                        style: const TextStyle(
                          fontSize: 11,
                          color:    AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Overview snippet
                  Text(
                    movie.overview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize:   11,
                      color:      AppColors.textMuted,
                      height:     1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatVotes(int votes) {
    if (votes >= 1000) return '${(votes / 1000).toStringAsFixed(1)}K';
    return votes.toString();
  }
}

// ── Featured banner card (hero card on home screen) ───────────────────────────
class MovieFeaturedCard extends StatelessWidget {
  final MovieModel movie;

  const MovieFeaturedCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.detail, extra: movie),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Backdrop image
              CachedNetworkImage(
                imageUrl:    movie.backdropUrl,
                fit:         BoxFit.cover,
                placeholder: (_, __) => _ShimmerBox(
                  width:  double.infinity,
                  height: 200,
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surface,
                  child: const Icon(
                    Icons.movie_rounded,
                    color: AppColors.textMuted,
                    size:  48,
                  ),
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end:   Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),

              // New release badge
              if (movie.isNewRelease)
                Positioned(
                  top:  12,
                  left: 14,
                  child: _Badge(label: 'New Release', color: AppColors.primary),
                ),

              // Bottom info
              Positioned(
                bottom: 0,
                left:   0,
                right:  0,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize:   18,
                          fontWeight: FontWeight.bold,
                          color:      Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.star,
                            size:  15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize:   13,
                              fontWeight: FontWeight.w600,
                              color:      AppColors.star,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.remove_red_eye_outlined,
                            color: AppColors.textSecondary,
                            size:  14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${movie.totalWatches} views',
                            style: const TextStyle(
                              fontSize: 12,
                              color:    AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.access_time_rounded,
                            color: AppColors.textSecondary,
                            size:  14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.runtimeFormatted,
                            style: const TextStyle(
                              fontSize: 12,
                              color:    AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private helper widgets ─────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize:   10,
          fontWeight: FontWeight.w600,
          color:      Colors.white,
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final double rating;
  const _RatingChip({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color:        Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.star, size: 11),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize:   10,
              fontWeight: FontWeight.w600,
              color:      AppColors.star,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  const _ShimmerBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:     AppColors.surface,
      highlightColor: AppColors.surfaceLight,
      child: Container(
        width:  width,
        height: height,
        color:  AppColors.surface,
      ),
    );
  }
}

class _PosterFallback extends StatelessWidget {
  final double width;
  final double height;
  final String title;
  const _PosterFallback({
    required this.width,
    required this.height,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width,
      height: height,
      color:  AppColors.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie_rounded, color: AppColors.textMuted, size: 30),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              maxLines:  2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color:    AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}