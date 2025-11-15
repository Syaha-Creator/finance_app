import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  final Animation<double>? scaleAnimation;
  final double? logoSize;

  const AuthLogo({super.key, this.scaleAnimation, this.logoSize = 80});

  @override
  Widget build(BuildContext context) {
    Widget logoWidget = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 4,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Image.asset(
          'assets/finance_app_logo.png',
          height: logoSize,
          width: logoSize,
        ),
      ),
    );

    if (scaleAnimation != null) {
      return ScaleTransition(scale: scaleAnimation!, child: logoWidget);
    }

    return logoWidget;
  }
}
