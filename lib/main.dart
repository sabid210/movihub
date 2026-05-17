import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'core/constants/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/movie_provider.dart';
import 'presentation/providers/favourites_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MoviHubApp());
}

class MoviHubApp extends StatelessWidget {
  const MoviHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => FavouritesProvider()),
      ],
      child: MaterialApp.router(
        title:                     'MoviHub',
        debugShowCheckedModeBanner: false,
        theme:                     AppTheme.darkTheme,
        routerConfig:              AppRoutes.router,
      ),
    );
  }
}