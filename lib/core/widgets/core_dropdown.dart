import 'package:flutter/material.dart';

class CoreDropdown<T> extends StatelessWidget {
  final T? value;
  final ValueChanged<T?> onChanged;
  final String label;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final String? Function(T?)? validator;
  final IconData? icon;
  final Color? primaryColor;
  final double? borderRadius;

  const CoreDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.items,
    this.hint,
    this.validator,
    this.icon,
    this.primaryColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<T>(
            onChanged: onChanged,
            validator: validator,
            items: items,
            initialValue: value,
            decoration: InputDecoration(
        labelText: label,
              hintText: hint ?? 'Pilih $label',
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: Colors.grey.shade600,
                size: 20,
              )
            : null,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            dropdownColor: theme.colorScheme.surface,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
    );
  }
}
