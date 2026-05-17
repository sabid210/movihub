import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/movie_provider.dart';
import '../../providers/favourites_provider.dart';
import '../../widgets/movie_card.dart';
import '../favourites/favourites_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeBody(),
    SearchScreen(),
    FavouritesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MovieProvider>().fetchAllMovies();
      context.read<FavouritesProvider>().loadFavourites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index:    _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── Bottom navigation bar ─────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex:        currentIndex,
        onTap:               onTap,
        backgroundColor:     Colors.transparent,
        elevation:           0,
        type:                BottomNavigationBarType.fixed,
        selectedItemColor:   AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        selectedLabelStyle: const TextStyle(
          fontSize:   11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon:       Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label:      AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search_rounded),
            label:      AppStrings.search,
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.favorite_border_rounded),
            activeIcon: Icon(Icons.favorite_rounded),
            label:      AppStrings.favourites,
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label:      AppStrings.profile,
          ),
        ],
      ),
    );
  }
}

// ── Home body ─────────────────────────────────────────────────────────────────
class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  int _selectedGenreIndex = 0;

  final List<String> _genres = [
    'All', 'Action', 'Drama', 'Sci-Fi', 'Horror', 'Comedy', 'Fantasy',
  ];

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MovieProvider>();

    return SafeArea(
      child: RefreshIndicator(
        color:           AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () => context.read<MovieProvider>().fetchAllMovies(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── App bar ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: const TextStyle(
                              fontSize: 13,
                              color:    AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: const TextSpan(children: [
                              TextSpan(
                                text: 'Movi',
                                style: TextStyle(
                                  fontSize:   22,
                                  fontWeight: FontWeight.bold,
                                  color:      AppColors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: 'Hub',
                                style: TextStyle(
                                  fontSize:   22,
                                  fontWeight: FontWeight.bold,
                                  color:      AppColors.primary,
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width:  42,
                      height: 42,
                      decoration: BoxDecoration(
                        color:        AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border,
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.textSecondary,
                        size:  22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Genre chips ───────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  itemCount: _genres.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final selected = i == _selectedGenreIndex;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedGenreIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical:   6,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.border,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          _genres[i],
                          style: TextStyle(
                            fontSize:   12,
                            fontWeight: FontWeight.w500,
                            color: selected
                                ? Colors.white
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Featured banner ───────────────────────────────
            SliverToBoxAdapter(
              child: movies.isLoading
                  ? _FeaturedShimmer()
                  : movies.featuredMovie != null
                      ? MovieFeaturedCard(movie: movies.featuredMovie!)
                      : const SizedBox.shrink(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Trending Now ──────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                title:    AppStrings.trending,
                onSeeAll: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260,
                child: movies.isLoading
                    ? _HorizontalShimmer()
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        itemCount: movies.trendingMovies.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            MovieCard(movie: movies.trendingMovies[i]),
                      ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ── New Releases ──────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                title:    AppStrings.newRelease,
                onSeeAll: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260,
                child: movies.isLoading
                    ? _HorizontalShimmer()
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        itemCount: movies.newReleases.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            MovieCard(movie: movies.newReleases[i]),
                      ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ── Top Rated ─────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                title:    AppStrings.topRated,
                onSeeAll: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260,
                child: movies.isLoading
                    ? _HorizontalShimmer()
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        itemCount: movies.topRatedMovies.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            MovieCard(movie: movies.topRatedMovies[i]),
                      ),
              ),
            ),

            // ── Error state ───────────────────────────────────
            if (movies.error != null)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: AppColors.textMuted,
                          size:  40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          movies.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color:    AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () =>
                              context.read<MovieProvider>().fetchAllMovies(),
                          child: const Text(
                            'Try again',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String    title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w600,
              color:      AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              AppStrings.seeAll,
              style: TextStyle(
                fontSize: 12,
                color:    AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer placeholders ──────────────────────────────────────────────────────
class _FeaturedShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.symmetric(horizontal: 16),
      height:  200,
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _HorizontalShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding:         const EdgeInsets.symmetric(horizontal: 16),
      itemCount:       4,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width:  130,
            height: 195,
            decoration: BoxDecoration(
              color:        AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width:  100,
            height: 12,
            decoration: BoxDecoration(
              color:        AppColors.surface,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}