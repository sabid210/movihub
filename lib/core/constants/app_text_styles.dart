import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: 26, fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14, fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const TextStyle button = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle movieTitle = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle ratingBig = TextStyle(
    fontSize: 32, fontWeight: FontWeight.bold,
    color: AppColors.star,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10, fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
    letterSpacing: 0.3,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle chip = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}