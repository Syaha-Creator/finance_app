import 'package:flutter/material.dart';

class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroup({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
