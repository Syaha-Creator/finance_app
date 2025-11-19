import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/base_controller.dart';

/// Helper function to create a controller provider for BaseController subclasses.
///
/// This reduces boilerplate when creating controller providers.
///
/// Example:
/// ```dart
/// final assetControllerProvider = createControllerProvider<AssetController>(
///   (ref) => AssetController(
///     assetRepository: ref.watch(assetRepositoryProvider),
///     ref: ref,
///   ),
/// );
/// ```
AutoDisposeStateNotifierProvider<Controller, AsyncValue<void>>
    createControllerProvider<Controller extends BaseController>(
  Controller Function(Ref ref) factory,
) {
  return StateNotifierProvider.autoDispose<Controller, AsyncValue<void>>(
    (ref) => factory(ref),
  );
}

