import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../dashboard/presentation/pages/main_page.dart';
import '../providers/auth_providers.dart';
import 'login_page.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const MainPage();
        }

        return const LoginPage();
      },

      error:
          (err, stack) =>
              Scaffold(body: Center(child: Text('Terjadi error: $err'))),

      loading:
          () =>
              const Scaffold(body: Center(child: CoreLoadingState())),
    );
  }
}
