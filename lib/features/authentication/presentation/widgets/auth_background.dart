import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;
  final List<double>? gradientStops;

  const AuthBackground({
    super.key,
    required this.child,
    this.gradientColors,
    this.gradientStops,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              gradientColors ??
              [
                AppColors.primary,
                AppColors.primaryLight,
                AppColors.primaryDark,
                AppColors.primary,
              ],
          stops: gradientStops ?? const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Animated background elements
            Positioned(
              top: -80,
              right: -80,
              child: _AnimatedCircle(size: 160, alpha: 0.1),
            ),
            Positioned(
              bottom: -120,
              left: -120,
              child: _AnimatedCircle(size: 240, alpha: 0.08, scale: 0.7),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _AnimatedCircle extends StatefulWidget {
  final double size;
  final double alpha;
  final double scale;

  const _AnimatedCircle({
    required this.size,
    required this.alpha,
    this.scale = 1.0,
  });

  @override
  State<_AnimatedCircle> createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<_AnimatedCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value * widget.scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: widget.alpha),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
