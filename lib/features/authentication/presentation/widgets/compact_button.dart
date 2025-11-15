import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CompactButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? height;
  final List<Color>? gradientColors;
  final Color? shadowColor;
  final double? borderRadius;

  const CompactButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 48,
    this.gradientColors,
    this.shadowColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        const [AppColors.primary, AppColors.primaryLight];
    final shadow = shadowColor ?? colors.first;
    final radius = borderRadius ?? 16.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: shadow.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: shadow.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(radius),
          child: Center(child: child),
        ),
      ),
    );
  }
}
