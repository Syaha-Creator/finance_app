import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Utility class untuk decoration patterns
/// Mengurangi duplikasi BoxDecoration yang sering digunakan
class AppDecorations {
  AppDecorations._();

  /// Standard card decoration dengan border dan shadow
  ///
  /// [borderRadius] - Default: 16
  /// [borderColor] - Default: outline dengan alpha 0.1
  /// [shadowAlpha] - Default: 0.04
  static BoxDecoration cardDecoration({
    required BuildContext context,
    double borderRadius = 16.0,
    Color? borderColor,
    double shadowAlpha = 0.04,
    Color? backgroundColor,
  }) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: backgroundColor ?? theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ??
            theme.colorScheme.outline.withValues(alpha: 0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: shadowAlpha),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Standard card decoration dengan shadow yang lebih besar (untuk header cards)
  ///
  /// [borderRadius] - Default: 20
  /// [shadowAlpha] - Default: 0.05
  static BoxDecoration headerCardDecoration({
    required BuildContext context,
    double borderRadius = 20.0,
    double shadowAlpha = 0.05,
    Color? backgroundColor,
  }) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: backgroundColor ?? theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: theme.colorScheme.outline.withValues(alpha: 0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: shadowAlpha),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Primary gradient decoration (untuk summary cards, header cards)
  static BoxDecoration primaryGradientDecoration({
    double borderRadius = 24.0,
    double shadowAlpha = 0.3,
  }) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary,
          AppColors.primaryLight,
          AppColors.primaryDark,
        ],
        stops: [0.0, 0.5, 1.0],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: shadowAlpha),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// Icon container decoration (untuk icon dengan background)
  static BoxDecoration iconContainerDecoration({
    required Color color,
    double borderRadius = 12.0,
    double alpha = 0.1,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: alpha),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: color.withValues(alpha: alpha * 2),
        width: 1,
      ),
    );
  }
}

