import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/thousand_input_formatter.dart';

class CoreAmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final Color? primaryColor;
  final double? borderRadius;
  final String prefixText;

  const CoreAmountInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.primaryColor,
    this.borderRadius,
    this.prefixText = 'Rp ',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandInputFormatter(),
            ],
            validator: validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  return null;
                },
            decoration: InputDecoration(
        labelText: label,
              hintText: hint ?? 'Masukkan jumlah',
              prefixText: prefixText,
              prefixStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(
                Icons.attach_money,
          color: Colors.grey.shade600,
                size: 20,
              ),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
    );
  }
}

