import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset('assets/loading.json', width: 200, height: 200),
    );
  }
}
