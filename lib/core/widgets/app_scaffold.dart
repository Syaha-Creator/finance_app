import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final PreferredSizeWidget? bottom;

  const AppScaffold({
    super.key,
    this.title,
    this.actions,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar:
          title == null && actions == null && bottom == null
              ? null
              : AppBar(
                title: title != null ? Text(title!) : null,
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: theme.colorScheme.onSurface,
                centerTitle: true,
                actions: actions,
                bottom: bottom,
              ),
      backgroundColor: theme.colorScheme.surface,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
