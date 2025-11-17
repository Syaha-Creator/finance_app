import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../data/models/asset_model.dart';
import '../../data/repositories/asset_repository.dart';

final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  return AssetRepository(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

final assetsStreamProvider = StreamProvider.autoDispose<List<AssetModel>>((
  ref,
) {
  final assetRepository = ref.watch(assetRepositoryProvider);
  return assetRepository.getAssetsStream();
});

final assetNotifierProvider =
    StateNotifierProvider.autoDispose<AssetController, AsyncValue<void>>((ref) {
      return AssetController(
        assetRepository: ref.watch(assetRepositoryProvider),
        ref: ref,
      );
    });

class AssetController extends StateNotifier<AsyncValue<void>> {
  final AssetRepository _assetRepository;
  final Ref _ref;

  AssetController({required AssetRepository assetRepository, required Ref ref})
    : _assetRepository = assetRepository,
      _ref = ref,
      super(const AsyncValue.data(null));

  Future<void> addAsset(AssetModel asset) async {
    state = const AsyncValue.loading();
    try {
      await _assetRepository.addAsset(asset);
      _ref.invalidate(assetsStreamProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateAsset(AssetModel asset) async {
    state = const AsyncValue.loading();
    try {
      await _assetRepository.updateAsset(asset);
      _ref.invalidate(assetsStreamProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteAsset(String assetId) async {
    state = const AsyncValue.loading();
    try {
      await _assetRepository.deleteAsset(assetId);
      _ref.invalidate(assetsStreamProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
