import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base controller class that provides common functionality for all controllers.
///
/// This class provides:
/// - Common state management pattern with AsyncValue
/// - Helper method for executing operations with loading/error handling
/// - Automatic provider invalidation
abstract class BaseController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  BaseController({required this.ref}) : super(const AsyncValue.data(null));

  /// Executes an async operation with automatic loading and error handling.
  ///
  /// [action] - The async operation to execute
  /// [providersToInvalidate] - List of providers to invalidate after successful operation
  Future<void> executeWithLoading(
    Future<void> Function() action, {
    required List<ProviderOrFamily> providersToInvalidate,
  }) async {
    state = const AsyncValue.loading();
    try {
      await action();
      for (final provider in providersToInvalidate) {
        ref.invalidate(provider);
      }
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
