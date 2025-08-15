import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../data/models/asset_model.dart';
import '../../data/repositories/asset_repository.dart';

// 1. Provider untuk Repository
final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  // Menggunakan provider yang sudah ada dari modul lain
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return AssetRepository(firestore: firestore, firebaseAuth: firebaseAuth);
});

// 2. Provider untuk mendapatkan stream data aset
final assetsStreamProvider = StreamProvider.autoDispose<List<AssetModel>>((
  ref,
) {
  final assetRepository = ref.watch(assetRepositoryProvider);
  return assetRepository.getAssetsStream();
});

// 3. Provider untuk Controller (menangani state loading saat ada aksi)
final assetControllerProvider =
    StateNotifierProvider.autoDispose<AssetController, bool>((ref) {
      return AssetController(
        assetRepository: ref.watch(assetRepositoryProvider),
        ref: ref,
      );
    });

class AssetController extends StateNotifier<bool> {
  final AssetRepository _assetRepository;
  final Ref _ref;

  AssetController({required AssetRepository assetRepository, required Ref ref})
    : _assetRepository = assetRepository,
      _ref = ref,
      super(false);

  Future<bool> addAsset(AssetModel asset) async {
    state = true; // Set loading = true
    try {
      await _assetRepository.addAsset(asset);
      _ref.invalidate(assetsStreamProvider); // FIX: Invalidate to refresh UI
      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      return false;
    }
  }

  Future<bool> updateAsset(AssetModel asset) async {
    state = true;
    try {
      await _assetRepository.updateAsset(asset);
      _ref.invalidate(assetsStreamProvider); // FIX: Invalidate to refresh UI
      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      return false;
    }
  }

  Future<bool> deleteAsset(String assetId) async {
    state = true;
    try {
      await _assetRepository.deleteAsset(assetId);
      _ref.invalidate(assetsStreamProvider); // FIX: Invalidate to refresh UI
      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      return false;
    }
  }
}
