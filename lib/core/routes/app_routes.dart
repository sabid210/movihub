import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/detail/movie_detail_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/favourites/favourites_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../data/models/movie_model.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash     = '/';
  static const String login      = '/login';
  static const String register   = '/register';
  static const String home       = '/home';
  static const String detail     = '/detail';
  static const String search     = '/search';
  static const String favourites = '/favourites';
  static const String profile    = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation:     AppRoutes.splash,
    debugLogDiagnostics: false,

    redirect: (context, state) {
      final user     = FirebaseAuth.instance.currentUser;
      final isAuth   = user != null;
      final loc      = state.matchedLocation;
      final isPublic = loc == AppRoutes.splash ||
          loc == AppRoutes.login ||
          loc == AppRoutes.register;

      if (!isAuth && !isPublic) return AppRoutes.login;
      if (isAuth &&
          (loc == AppRoutes.login || loc == AppRoutes.register)) {
        return AppRoutes.home;
      }
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _fadePage(
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _fadePage(
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.detail,
        pageBuilder: (context, state) {
          final movie = state.extra! as MovieModel;
          return _slideUpPage(
            state: state,
            child: MovieDetailScreen(movie: movie),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: const SearchScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.favourites,
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: const FavouritesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: const ProfileScreen(),
        ),
      ),
    ],

    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D14),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE05C5C),
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Page not found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE05C5C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  static CustomTransitionPage _fadePage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key:   state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
        child: child,
      ),
    );
  }

  static CustomTransitionPage _slidePage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key:   state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage _slideUpPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key:   state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}