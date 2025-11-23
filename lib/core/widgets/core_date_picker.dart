import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class CoreDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String label;
  final String? hint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final Color? primaryColor;
  final double? borderRadius;
  final String? errorText;
  final VoidCallback? onClear;

  const CoreDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.label,
    this.hint,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.primaryColor,
    this.borderRadius,
    this.errorText,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = primaryColor ?? AppColors.primary;

    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate ?? selectedDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime(2101),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: color),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint ?? 'Pilih tanggal',
          prefixIcon: Icon(
            Icons.calendar_today_outlined,
            color: Colors.grey.shade600,
            size: 20,
          ),
          suffixIcon:
              selectedDate != null && onClear != null
                  ? IconButton(
                    onPressed: onClear,
                    icon: Icon(
                      Icons.clear,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(24, 24),
                    ),
                  )
                  : null,
          errorText: errorText,
        ),
        child: Text(
          selectedDate == null
              ? (hint ?? 'Pilih tanggal')
              : DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate!),
          style: theme.textTheme.bodyLarge?.copyWith(
            color:
                selectedDate == null
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
