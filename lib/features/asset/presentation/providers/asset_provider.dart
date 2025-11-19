import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/providers/repository_provider_helpers.dart';
import '../../data/models/asset_model.dart';
import '../../data/repositories/asset_repository.dart';

final assetRepositoryProvider = createRepositoryProvider<AssetRepository>(
  (firestore, auth) =>
      AssetRepository(firestore: firestore, firebaseAuth: auth),
);

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

class AssetController extends BaseController {
  final AssetRepository _assetRepository;

  AssetController({
    required AssetRepository assetRepository,
    required super.ref,
  }) : _assetRepository = assetRepository;

  Future<void> addAsset(AssetModel asset) async {
    await executeWithLoading(
      () => _assetRepository.addAsset(asset),
      providersToInvalidate: [assetsStreamProvider],
    );
  }

  Future<void> updateAsset(AssetModel asset) async {
    await executeWithLoading(
      () => _assetRepository.updateAsset(asset),
      providersToInvalidate: [assetsStreamProvider],
    );
  }

  Future<void> deleteAsset(String assetId) async {
    await executeWithLoading(
      () => _assetRepository.deleteAsset(assetId),
      providersToInvalidate: [assetsStreamProvider],
    );
  }
}
