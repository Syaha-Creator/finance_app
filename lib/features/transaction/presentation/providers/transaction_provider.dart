import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../settings/data/models/setting_model.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

final transactionsStreamProvider =
    StreamProvider.autoDispose<List<TransactionModel>>((ref) {
      final user = ref.watch(authStateChangesProvider).value;

      if (user == null) {
        return Stream.value([]);
      }

      return ref.watch(transactionRepositoryProvider).getTransactionsStream();
    });

final expenseCategoriesProvider =
    StreamProvider.autoDispose<List<CategoryModel>>((ref) {
      // Provider ini sekarang bergantung pada SettingsRepository
      final settingsRepo = ref.watch(settingsRepositoryProvider);
      return settingsRepo.getCombinedStream('expense_categories');
    });

final incomeCategoriesProvider =
    StreamProvider.autoDispose<List<CategoryModel>>((ref) {
      final settingsRepo = ref.watch(settingsRepositoryProvider);
      return settingsRepo.getCombinedStream('income_categories');
    });

final accountsProvider = StreamProvider.autoDispose<List<CategoryModel>>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return settingsRepo.getCombinedStream('accounts');
});
