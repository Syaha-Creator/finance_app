import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CoreTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final int? maxLines;
  final Color? primaryColor;
  final double? borderRadius;
  final bool enabled;

  const CoreTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.prefixText,
    this.prefixStyle,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1,
    this.primaryColor,
    this.borderRadius,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            obscureText: obscureText,
            maxLines: maxLines,
            enabled: enabled,
            decoration: InputDecoration(
        labelText: label,
              hintText: hint,
              prefixText: prefixText,
              prefixStyle: prefixStyle ??
                  theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
              prefixIcon: icon != null
                  ? Icon(
                      icon,
                color: Colors.grey.shade600,
                      size: 20,
                    )
                  : null,
              suffixIcon: suffixIcon,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
    );
  }
}

