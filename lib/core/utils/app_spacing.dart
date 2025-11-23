import 'package:flutter/material.dart';

/// Utility class untuk spacing constants
/// Mengurangi duplikasi dan memastikan konsistensi spacing di seluruh aplikasi
class AppSpacing {
  AppSpacing._();

  // Standard spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  // Common EdgeInsets
  static const EdgeInsets paddingAll = EdgeInsets.all(md);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingSymmetric = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );

  // Common SizedBox
  static const SizedBox spaceXS = SizedBox(height: xs);
  static const SizedBox spaceSM = SizedBox(height: sm);
  static const SizedBox spaceMD = SizedBox(height: md);
  static const SizedBox spaceLG = SizedBox(height: lg);
  static const SizedBox spaceXL = SizedBox(height: xl);

  // Width spacing
  static const SizedBox widthXS = SizedBox(width: xs);
  static const SizedBox widthSM = SizedBox(width: sm);
  static const SizedBox widthMD = SizedBox(width: md);
  static const SizedBox widthLG = SizedBox(width: lg);
}

