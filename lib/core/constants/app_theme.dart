import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ══════════════════════════════════════════════════════════════════════════
  //  DARK THEME
  // ══════════════════════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3:            true,
      brightness:              Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.dark(
        primary:   AppColors.primary,
        secondary: AppColors.primary,
        surface:   AppColors.surface,
        error:     AppColors.error,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor:        AppColors.background,
        foregroundColor:        AppColors.textPrimary,
        elevation:              0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:          Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:     AppColors.background,
        selectedItemColor:   AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type:                BottomNavigationBarType.fixed,
        elevation:           0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation:       0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 0.8),
        ),
      ),

      cardTheme: CardThemeData(
        color:     AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: const TextStyle(
          color:    AppColors.textPrimary,
          fontSize: 13,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actionTextColor: AppColors.primary,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor:      AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation:       0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.surfaceLight;
        }),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      dividerTheme: const DividerThemeData(
        color:     AppColors.border,
        thickness: 0.5,
      ),

      listTileTheme: const ListTileThemeData(
        tileColor:      AppColors.surface,
        iconColor:      AppColors.textMuted,
        textColor:      AppColors.textPrimary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  LIGHT THEME
  // ══════════════════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3:            true,
      brightness:              Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),

      colorScheme: const ColorScheme.light(
        primary:   AppColors.primary,
        secondary: AppColors.primary,
        surface:   Colors.white,
        error:     AppColors.error,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor:        Color(0xFFF5F5F5),
        foregroundColor:        Color(0xFF1A1A1A),
        elevation:              0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:          Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:     Colors.white,
        selectedItemColor:   AppColors.primary,
        unselectedItemColor: Color(0xFF999999),
        type:                BottomNavigationBarType.fixed,
        elevation:           0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation:       0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(
          color:    Color(0xFF999999),
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),

      cardTheme: CardThemeData(
        color:     Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        contentTextStyle: const TextStyle(
          color:    Color(0xFF1A1A1A),
          fontSize: 13,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actionTextColor: AppColors.primary,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor:      Colors.white,
        modalBackgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation:       0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return const Color(0xFF999999);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return const Color(0xFFE0E0E0);
        }),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      dividerTheme: const DividerThemeData(
        color:     Color(0xFFE0E0E0),
        thickness: 0.5,
      ),

      listTileTheme: const ListTileThemeData(
        tileColor:      Colors.white,
        iconColor:      Color(0xFF666666),
        textColor:      Color(0xFF1A1A1A),
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}