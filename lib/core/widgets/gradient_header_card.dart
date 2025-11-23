import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable gradient header card widget
///
/// Mengurangi duplikasi untuk header dengan gradient yang digunakan di banyak form pages
class GradientHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color>? gradientColors;
  final Color? iconBackgroundColor;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const GradientHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.gradientColors,
    this.iconBackgroundColor,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = gradientColors ?? [
      AppColors.primary,
      AppColors.primaryLight,
      AppColors.primaryDark,
    ];

    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconBackgroundColor ?? Colors.white).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (iconBackgroundColor ?? Colors.white).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

