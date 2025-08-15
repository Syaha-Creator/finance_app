import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

final settingsControllerProvider =
    StateNotifierProvider.autoDispose<SettingsController, bool>((ref) {
      return SettingsController(
        settingsRepository: ref.watch(settingsRepositoryProvider),
        ref: ref,
      );
    });

class SettingsController extends StateNotifier<bool> {
  final SettingsRepository _settingsRepository;
  final Ref _ref;

  SettingsController({
    required SettingsRepository settingsRepository,
    required Ref ref,
  }) : _settingsRepository = settingsRepository,
       _ref = ref,
       super(false);

  Future<bool> _addData(String collection, String name) async {
    state = true;
    try {
      await _settingsRepository.addCustomData(collection, name);
      _ref.invalidate(expenseCategoriesProvider);
      _ref.invalidate(incomeCategoriesProvider);
      _ref.invalidate(accountsProvider);
      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      return false;
    }
  }

  Future<bool> _deleteData(String collection, String docId) async {
    state = true;
    try {
      await _settingsRepository.deleteCustomData(collection, docId);
      _ref.invalidate(expenseCategoriesProvider);
      _ref.invalidate(incomeCategoriesProvider);
      _ref.invalidate(accountsProvider);
      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      return false;
    }
  }

  Future<bool> addExpenseCategory(String name) =>
      _addData('expense_categories', name);
  Future<bool> addIncomeCategory(String name) =>
      _addData('income_categories', name);
  Future<bool> addAccount(String name) => _addData('accounts', name);

  Future<bool> deleteExpenseCategory(String docId) =>
      _deleteData('expense_categories', docId);
  Future<bool> deleteIncomeCategory(String docId) =>
      _deleteData('income_categories', docId);
  Future<bool> deleteAccount(String docId) => _deleteData('accounts', docId);
}
