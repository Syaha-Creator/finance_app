import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CoreLoadingState extends StatelessWidget {
  final String? message;
  final Color? color;
  final double? size;
  final double? strokeWidth;
  final bool compact;

  const CoreLoadingState({
    super.key,
    this.message,
    this.color,
    this.size,
    this.strokeWidth,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final loadingIndicator = SizedBox(
      width: size ?? 40,
      height: size ?? 40,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth ?? (size != null && size! < 24 ? 2.5 : 3),
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );

    // Compact mode: hanya return indicator tanpa wrapper
    if (compact) {
      return loadingIndicator;
    }

    // Full mode: dengan Center dan Column (untuk loading state)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          loadingIndicator,
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
