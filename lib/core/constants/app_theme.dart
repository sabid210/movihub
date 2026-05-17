import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3:        true,
      brightness:          Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,

      // ── Color scheme ──────────────────────────────────────
      colorScheme: const ColorScheme.dark(
        primary:        AppColors.primary,
        secondary:      AppColors.primary,
        surface:        AppColors.surface,
        error:          AppColors.error,
        onPrimary:      Colors.white,
        onSecondary:    Colors.white,
        onSurface:      AppColors.textPrimary,
        onError:        Colors.white,
      ),

      // ── AppBar ────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor:  AppColors.background,
        foregroundColor:  AppColors.textPrimary,
        elevation:        0,
        centerTitle:      false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:           Colors.transparent,
          statusBarIconBrightness:  Brightness.light,
          statusBarBrightness:      Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontSize:   18,
          fontWeight: FontWeight.w600,
          color:      AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size:  22,
        ),
      ),

      // ── Bottom navigation ─────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:      AppColors.background,
        selectedItemColor:    AppColors.primary,
        unselectedItemColor:  AppColors.textHint,
        type:                 BottomNavigationBarType.fixed,
        elevation:            0,
        selectedLabelStyle: TextStyle(
          fontSize:   11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      // ── Elevated button ───────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:         AppColors.primary,
          foregroundColor:         Colors.white,
          disabledBackgroundColor: AppColors.primary,
          disabledForegroundColor: Colors.white54,
          elevation:               0,
          minimumSize:  const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize:   15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Outlined button ───────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.border, width: 0.8),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize:   15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ── Text button ───────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ── Input decoration ──────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(
          color:    AppColors.textHint,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color:    AppColors.textMuted,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical:   16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 0.8,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.2,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: 11,
          color:    AppColors.error,
        ),
      ),

      // ── Card ──────────────────────────────────────────────
      cardTheme: CardThemeData(
        color:        AppColors.surface,
        elevation:    0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Chip ──────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:   AppColors.surfaceLight,
        selectedColor:     AppColors.primary,
        disabledColor:     AppColors.surface,
        labelStyle: const TextStyle(
          fontSize: 12,
          color:    AppColors.textSecondary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 12,
          color:    Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),

      // ── Snack bar ─────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: const TextStyle(
          color:    AppColors.textPrimary,
          fontSize: 13,
        ),
        behavior:    SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actionTextColor: AppColors.primary,
      ),

      // ── Bottom sheet ──────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor:    AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
      ),

      // ── Dialog ────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation:       0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          fontSize:   18,
          fontWeight: FontWeight.w600,
          color:      AppColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 13,
          color:    AppColors.textMuted,
        ),
      ),

      // ── Divider ───────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color:     AppColors.border,
        thickness: 0.5,
        space:     0,
      ),

      // ── List tile ─────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        tileColor:       AppColors.surface,
        iconColor:       AppColors.textMuted,
        textColor:       AppColors.textPrimary,
        contentPadding:  EdgeInsets.symmetric(horizontal: 16),
      ),

      // ── Switch ────────────────────────────────────────────
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

      // ── Progress indicator ────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      // ── Icon ─────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size:  22,
      ),

      // ── Text ─────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28, fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 14, color: AppColors.textSecondary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13, color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12, color: AppColors.textMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
        labelSmall: TextStyle(
          fontSize: 10, color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}