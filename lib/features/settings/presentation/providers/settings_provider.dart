import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../data/models/user_profile_model.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

final settingsControllerProvider =
    StateNotifierProvider.autoDispose<SettingsController, AsyncValue<void>>((
      ref,
    ) {
      return SettingsController(
        settingsRepository: ref.watch(settingsRepositoryProvider),
        ref: ref,
      );
    });

class SettingsController extends BaseController {
  final SettingsRepository _settingsRepository;

  SettingsController({
    required SettingsRepository settingsRepository,
    required super.ref,
  }) : _settingsRepository = settingsRepository;

  List<ProviderOrFamily> get _settingsProvidersToInvalidate => [
    expenseCategoriesProvider,
    incomeCategoriesProvider,
    accountsProvider,
  ];

  Future<void> _addData(String collection, String name) async {
    await executeWithLoading(
      () => _settingsRepository.addCustomData(collection, name),
      providersToInvalidate: _settingsProvidersToInvalidate,
    );
  }

  Future<void> _deleteData(String collection, String docId) async {
    await executeWithLoading(
      () => _settingsRepository.deleteCustomData(collection, docId),
      providersToInvalidate: _settingsProvidersToInvalidate,
    );
  }

  Future<void> addExpenseCategory(String name) =>
      _addData('expense_categories', name);
  Future<void> addIncomeCategory(String name) =>
      _addData('income_categories', name);
  Future<void> addAccount(String name) => _addData('accounts', name);

  Future<void> deleteExpenseCategory(String docId) =>
      _deleteData('expense_categories', docId);
  Future<void> deleteIncomeCategory(String docId) =>
      _deleteData('income_categories', docId);
  Future<void> deleteAccount(String docId) => _deleteData('accounts', docId);
}

// User Profile Providers
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

final userProfileStreamProvider =
    StreamProvider.autoDispose<UserProfileModel?>((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return repository.getUserProfileStream();
});

final userProfileControllerProvider =
    StateNotifierProvider.autoDispose<UserProfileController, AsyncValue<void>>((
      ref,
    ) {
      return UserProfileController(
        repository: ref.watch(userProfileRepositoryProvider),
        ref: ref,
      );
    });

class UserProfileController extends BaseController {
  final UserProfileRepository _repository;

  UserProfileController({
    required UserProfileRepository repository,
    required super.ref,
  }) : _repository = repository;

  Future<void> saveUserProfile(UserProfileModel profile) async {
    await executeWithLoading(
      () => _repository.saveUserProfile(profile),
      providersToInvalidate: [userProfileStreamProvider],
    );
  }

  Future<void> updateUserProfileFields(Map<String, dynamic> fields) async {
    await executeWithLoading(
      () => _repository.updateUserProfileFields(fields),
      providersToInvalidate: [userProfileStreamProvider],
    );
  }
}
