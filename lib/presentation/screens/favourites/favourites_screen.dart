import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/favourites_provider.dart';
import '../../widgets/movie_card.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<FavouritesProvider>().loadFavourites(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavouritesProvider>();
    final favourites  = favProvider.favourites;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.myFavourites,
                        style: TextStyle(
                          fontSize:   22,
                          fontWeight: FontWeight.bold,
                          color:      AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${favourites.length} movie${favourites.length == 1 ? '' : 's'} saved',
                        style: const TextStyle(
                          fontSize: 13,
                          color:    AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),

                  // Sort button
                  if (favourites.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showSortSheet(context, favProvider),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:        AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.5,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.sort_rounded,
                              color: AppColors.textSecondary,
                              size:  18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Sort',
                              style: TextStyle(
                                fontSize: 12,
                                color:    AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Content ──────────────────────────────────────────
            Expanded(
              child: favProvider.isLoading
                  ? _FavouritesShimmer()
                  : favourites.isEmpty
                      ? _EmptyFavourites()
                      : RefreshIndicator(
                          color:           AppColors.primary,
                          backgroundColor: AppColors.surface,
                          onRefresh: () =>
                              context.read<FavouritesProvider>().loadFavourites(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            physics: const BouncingScrollPhysics(),
                            itemCount: favourites.length,
                            itemBuilder: (_, i) {
                              final movie = favourites[i];
                              return Dismissible(
                                key:       Key(movie.id),
                                direction: DismissDirection.endToStart,
                                background: _DismissBackground(),
                                confirmDismiss: (_) async {
                                  return await _confirmRemove(context);
                                },
                                onDismissed: (_) {
                                  context
                                      .read<FavouritesProvider>()
                                      .toggleFavourite(movie);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${movie.title} removed from favourites',
                                      ),
                                      backgroundColor: AppColors.surface,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      action: SnackBarAction(
                                        label:     'Undo',
                                        textColor: AppColors.primary,
                                        onPressed: () {
                                          context
                                              .read<FavouritesProvider>()
                                              .toggleFavourite(movie);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: MovieListCard(movie: movie),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sort bottom sheet ───────────────────────────────────────────────────────
  void _showSortSheet(BuildContext context, FavouritesProvider provider) {
    showModalBottomSheet(
      context:           context,
      backgroundColor:   AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width:  40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:        AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sort by',
                style: TextStyle(
                  fontSize:   16,
                  fontWeight: FontWeight.w600,
                  color:      AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _SortOption(
                label:    'Recently Added',
                icon:     Icons.access_time_rounded,
                selected: provider.sortBy == FavouriteSort.recentlyAdded,
                onTap: () {
                  provider.setSortBy(FavouriteSort.recentlyAdded);
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                label:    'Highest Rated',
                icon:     Icons.star_rounded,
                selected: provider.sortBy == FavouriteSort.highestRated,
                onTap: () {
                  provider.setSortBy(FavouriteSort.highestRated);
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                label:    'A → Z',
                icon:     Icons.sort_by_alpha_rounded,
                selected: provider.sortBy == FavouriteSort.alphabetical,
                onTap: () {
                  provider.setSortBy(FavouriteSort.alphabetical);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Confirm remove dialog ───────────────────────────────────────────────────
  Future<bool> _confirmRemove(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Remove from favourites?',
              style: TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w600,
                color:      AppColors.textPrimary,
              ),
            ),
            content: const Text(
              'This movie will be removed from your favourites list.',
              style: TextStyle(
                fontSize: 13,
                color:    AppColors.textMuted,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// ── Sort option tile ──────────────────────────────────────────────────────────
class _SortOption extends StatelessWidget {
  final String   label;
  final IconData icon;
  final bool     selected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap:       onTap,
      leading: Icon(
        icon,
        color: selected ? AppColors.primary : AppColors.textMuted,
        size:  20,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize:   14,
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: selected
          ? const Icon(
              Icons.check_rounded,
              color: AppColors.primary,
              size:  18,
            )
          : null,
      contentPadding: EdgeInsets.zero,
    );
  }
}

// ── Dismiss background ────────────────────────────────────────────────────────
class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:       const EdgeInsets.only(bottom: 14),
      padding:      const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color:        AppColors.error.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      alignment: Alignment.centerRight,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 24),
          SizedBox(height: 4),
          Text(
            'Remove',
            style: TextStyle(
              fontSize: 11,
              color:    AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyFavourites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width:  90,
            height: 90,
            decoration: BoxDecoration(
              color:  AppColors.surface,
              shape:  BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: AppColors.textMuted,
              size:  40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No favourites yet',
            style: TextStyle(
              fontSize:   18,
              fontWeight: FontWeight.w600,
              color:      AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Movies you favourite will\nappear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color:    AppColors.textMuted,
              height:   1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer loading ───────────────────────────────────────────────────────────
class _FavouritesShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding:     const EdgeInsets.symmetric(horizontal: 16),
      itemCount:   5,
      itemBuilder: (_, __) => Container(
        margin:  const EdgeInsets.only(bottom: 14),
        height:  120,
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}