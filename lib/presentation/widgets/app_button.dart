import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// ── Primary filled button ─────────────────────────────────────────────────────
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double? width;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.height    = 52,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:         AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          foregroundColor:         Colors.white,
          elevation:               0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width:  22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize:     MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize:   15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Outlined / secondary button ───────────────────────────────────────────────
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double? width;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;

  const AppOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading   = false,
    this.height      = 52,
    this.width,
    this.icon,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bColor = borderColor ?? AppColors.border;
    final tColor = textColor  ?? AppColors.textSecondary;

    return SizedBox(
      width:  width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: bColor, width: 0.8),
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width:  22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(tColor),
                ),
              )
            : Row(
                mainAxisSize:      MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: tColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize:     15,
                      fontWeight:   FontWeight.w500,
                      color:        tColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Small icon + text button ──────────────────────────────────────────────────
class AppSmallButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const AppSmallButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.surfaceLight;
    final tc = textColor       ?? AppColors.textSecondary;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: tc),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w500,
                color:      tc,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Favourite toggle button ───────────────────────────────────────────────────
class FavouriteButton extends StatelessWidget {
  final bool isFavourite;
  final VoidCallback onPressed;

  const FavouriteButton({
    super.key,
    required this.isFavourite,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isFavourite
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFavourite ? AppColors.primary : AppColors.border,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: AppColors.primary,
              size:  18,
            ),
            const SizedBox(width: 6),
            Text(
              isFavourite ? AppStrings_saved : AppStrings_favourite,
              style: TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w500,
                color: isFavourite
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // inline constants to avoid extra import
  static const String AppStrings_saved      = 'Saved';
  static const String AppStrings_favourite  = 'Favourite';
}