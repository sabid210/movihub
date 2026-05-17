import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/movie_provider.dart';
import 'package:provider/provider.dart';
import '../../widgets/movie_card.dart';
import '../../../data/models/movie_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<MovieModel> _results = [];
  bool _isSearching = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isSearching = true);
    final results =
        await context.read<MovieProvider>().searchMovies(query);
    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: TextField(
                controller: _ctrl,
                onChanged: _search,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search movies...',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.border, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                  : _results.isEmpty
                      ? const Center(
                          child: Text('Search for movies...',
                              style: TextStyle(color: AppColors.textMuted)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _results.length,
                          itemBuilder: (_, i) =>
                              MovieListCard(movie: _results[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}