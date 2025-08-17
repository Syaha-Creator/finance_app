import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - Modern Blue Theme
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryContainer = Color(0xFFDBEAFE);
  static const Color onPrimaryContainer = Color(0xFF1E3A8A);

  // Secondary Colors
  static const Color secondary = Color(0xFF059669);
  static const Color secondaryLight = Color(0xFF10B981);
  static const Color secondaryContainer = Color(0xFFD1FAE5);
  static const Color onSecondaryContainer = Color(0xFF064E3B);

  // Accent Colors
  static const Color accent = Color(0xFFD97706);
  static const Color accentLight = Color(0xFFF59E0B);
  static const Color accentContainer = Color(0xFFFEF3C7);
  static const Color onAccentContainer = Color(0xFF78350F);

  // Financial Colors
  static const Color income = Color(0xFF059669);
  static const Color expense = Color(0xFFDC2626);
  static const Color transfer = Color(0xFF2563EB);
  static const Color warning = Color(0xFFD97706);
  static const Color success = Color(0xFF059669);
  static const Color error = Color(0xFFDC2626);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightDivider = Color(0xFFF1F5F9);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkDivider = Color(0xFF334155);

  // Status Colors
  static const Color info = Color(0xFF2563EB);
  static const Color infoContainer = Color(0xFFDBEAFE);
  static const Color onInfoContainer = Color(0xFF1E3A8A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Shadows
  static List<BoxShadow> get lightCardShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get darkCardShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.25),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.15),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  // Glass Effect Colors
  static Color get glassLight => Colors.white.withValues(alpha: 0.1);
  static Color get glassDark => const Color(0xFF000000).withValues(alpha: 0.1);
  
  // Border Colors
  static Color get borderLight => const Color(0xFFE2E8F0).withValues(alpha: 0.8);
  static Color get borderDark => const Color(0xFF475569).withValues(alpha: 0.8);
}
