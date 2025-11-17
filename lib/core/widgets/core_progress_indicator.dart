import 'package:flutter/material.dart';

/// A circular progress indicator widget with customizable properties
class CoreProgressIndicator extends StatelessWidget {
  /// The value of the progress indicator (0.0 to 1.0)
  final double value;

  /// The size of the progress indicator
  final double? size;

  /// The stroke width of the progress indicator
  final double? strokeWidth;

  /// The background color of the progress indicator
  final Color? backgroundColor;

  /// The color of the progress indicator value
  final Color? valueColor;

  const CoreProgressIndicator({
    super.key,
    required this.value,
    this.size,
    this.strokeWidth,
    this.backgroundColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorSize = size ?? 100.0;
    final stroke = strokeWidth ?? 8.0;
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final progressColor = valueColor ?? theme.colorScheme.primary;

    return SizedBox(
      width: indicatorSize,
      height: indicatorSize,
      child: CircularProgressIndicator(
        value: value.clamp(0.0, 1.0),
        strokeWidth: stroke,
        backgroundColor: bgColor,
        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
      ),
    );
  }
}

