import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';

// Import core pages directly to avoid auth/router side-effects in smoke pass
import 'package:finance_app/features/dashboard/presentation/pages/main_page.dart';
import 'package:finance_app/features/transaction/presentation/pages/transaction_page.dart';
import 'package:finance_app/features/reports/presentation/pages/reports_page.dart';
import 'package:finance_app/features/settings/presentation/pages/settings_page.dart';
import 'package:finance_app/features/asset/presentation/pages/asset_page.dart';
import 'package:finance_app/features/debt/presentation/pages/debt_page.dart';
import 'package:finance_app/features/goals/presentation/pages/goals_page.dart';
import 'package:finance_app/features/budget/presentation/pages/budget_page.dart';
import 'package:finance_app/features/bill_management/presentation/pages/bill_management_page.dart';
import 'package:finance_app/features/receipt_management/presentation/pages/receipt_management_page.dart';
import 'package:finance_app/features/investment/presentation/pages/investment_management_page.dart';
import 'package:finance_app/features/transaction/presentation/pages/recurring_transaction_page.dart';
import 'package:finance_app/features/dashboard/presentation/pages/financial_health_page.dart';
// Providers to override in tests (to avoid Firebase in smoke run)
import 'package:finance_app/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finance_app/features/asset/presentation/providers/asset_provider.dart';
import 'package:finance_app/features/debt/presentation/providers/debt_provider.dart';
import 'package:finance_app/features/transaction/presentation/providers/recurring_transaction_provider.dart';
import 'package:finance_app/features/goals/presentation/providers/goal_provider.dart';
import 'package:finance_app/features/budget/presentation/providers/budget_providers.dart';
import 'package:finance_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:finance_app/features/bill_management/presentation/providers/bill_provider.dart';
import 'package:finance_app/features/receipt_management/presentation/providers/receipt_provider.dart';
import 'package:finance_app/features/investment/presentation/providers/investment_provider.dart';
import 'package:finance_app/features/financial_health/application/financial_health_service.dart';
import 'package:finance_app/features/financial_health/domain/entities/financial_health_analysis.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/features/settings/data/repositories/settings_repository.dart';
import 'package:finance_app/core/data/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finance_app/features/settings/data/models/setting_model.dart';
import 'dart:async';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Bounded settle to avoid timeouts from endless animations/streams
  Future<void> pumpUntilStable(
    WidgetTester tester, {
    int maxPumps = 20,
    Duration step = const Duration(milliseconds: 150),
  }) async {
    for (var i = 0; i < maxPumps; i++) {
      await tester.pump(step);
      final binding = tester.binding;
      final hasTransientCallbacks = binding.transientCallbackCount > 0;
      final hasScheduledFrame = binding.hasScheduledFrame;
      if (!hasTransientCallbacks && !hasScheduledFrame) {
        break;
      }
    }
  }

  group('Navigation smoke', () {
    testWidgets('MainPage renders and FAB opens add menu', (tester) async {
      final overrides = _testOverrides();
      await tester.pumpWidget(
        _TestApp(home: const MainPage(), overrides: overrides),
      );
      await pumpUntilStable(tester);
      expect(find.byType(MainPage), findsOneWidget);

      // Open FAB add menu
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await pumpUntilStable(tester);
      // Expect bottom sheet visible (by presence of a common action text)
      expect(find.textContaining('Tambah'), findsWidgets);
      // Close sheet by dragging it down (modal has enableDrag true)
      await tester.drag(find.byType(BottomSheet), const Offset(0, 500));
      await pumpUntilStable(tester);
    });

    group('Core sections build without crash', () {
      final overrides = _testOverrides();
      final cases = <String, Widget Function()>{
        'TransactionPage': () => const TransactionPage(),
        'ReportsPage': () => const ReportsPage(),
        'SettingsPage': () => const SettingsPage(),
        'AssetPage': () => const AssetPage(),
        'DebtPage': () => const DebtPage(),
        'GoalsPage': () => const GoalsPage(),
        'BudgetPage': () => const BudgetPage(),
        'BillManagementPage': () => const BillManagementPage(),
        'ReceiptManagementPage': () => const ReceiptManagementPage(),
        'InvestmentManagementPage': () => const InvestmentManagementPage(),
        'RecurringTransactionPage': () => const RecurringTransactionPage(),
        'FinancialHealthPage': () => const FinancialHealthPage(),
      };

      cases.forEach((name, builder) {
        testWidgets('builds: $name', (tester) async {
          final page = builder();
          await tester.pumpWidget(_TestApp(home: page, overrides: overrides));
          // SettingsPage may take longer due to NetworkImage loading
          await pumpUntilStable(
            tester,
            maxPumps: name == 'SettingsPage' ? 40 : 20,
            step:
                name == 'SettingsPage'
                    ? const Duration(milliseconds: 200)
                    : const Duration(milliseconds: 150),
          );
          expect(
            find.byWidget(page),
            findsOneWidget,
            reason: 'Failed while building $name',
          );
        });
      });
    });
  });
}

List<Override> _testOverrides() {
  final now = DateTime.now();
  return [
    // Auth
    authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
    // Transactions and related
    transactionsStreamProvider.overrideWith((ref) => Stream.value([])),
    // Assets / Debts
    assetsStreamProvider.overrideWith((ref) => Stream.value([])),
    debtsStreamProvider.overrideWith((ref) => Stream.value([])),
    // Recurring
    recurringTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),
    // Goals
    goalsWithProgressProvider.overrideWith((ref) => Stream.value([])),
    goalsStreamProvider.overrideWith((ref) => Stream.value([])),
    // Budgets - override current month family invocation
    budgetsForMonthProvider((
      year: now.year,
      month: now.month,
    )).overrideWith((ref) => Stream.value([])),
    // Bills
    billsProvider.overrideWith((ref) => Stream.value([])),
    billsSummaryProvider.overrideWith(
      (ref) => Future.value({
        'totalBills': 0,
        'pendingBills': 0,
        'paidBills': 0,
        'overdueBills': 0,
        'totalAmount': 0.0,
        'pendingAmount': 0.0,
      }),
    ),
    // Receipts
    receiptsProvider.overrideWith((ref) => Stream.value([])),
    pendingReceiptsProvider.overrideWith((ref) => Stream.value([])),
    processedReceiptsProvider.overrideWith((ref) => Stream.value([])),
    receiptsSummaryProvider.overrideWith(
      (ref) => Future.value({
        'totalReceipts': 0,
        'pendingReceipts': 0,
        'processedReceipts': 0,
        'totalAmount': 0.0,
      }),
    ),
    // Investments
    investmentsProvider.overrideWith((ref) => Stream.value([])),
    activeInvestmentsProvider.overrideWith((ref) => Stream.value([])),
    portfolioSummaryProvider.overrideWith(
      (ref) => Future.value({
        'totalInvestments': 0,
        'activeInvestments': 0,
        'totalInvested': 0.0,
        'currentValue': 0.0,
        'totalProfitLoss': 0.0,
      }),
    ),
    // Financial Health
    financialHealthAnalysisProvider.overrideWith(
      (ref) => Future.value(FinancialHealthAnalysis.empty()),
    ),
    // Settings - Categories and Accounts
    expenseCategoriesProvider.overrideWith((ref) => Stream.value([])),
    incomeCategoriesProvider.overrideWith((ref) => Stream.value([])),
    accountsProvider.overrideWith((ref) => Stream.value([])),
    // Settings Repository - Mock to avoid Firebase calls
    settingsRepositoryProvider.overrideWith((ref) => _MockSettingsRepository()),
    // Settings Controller - uses mocked repository
    settingsControllerProvider.overrideWith(
      (ref) => SettingsController(
        settingsRepository: ref.watch(settingsRepositoryProvider),
        ref: ref,
      ),
    ),
  ];
}

// Mock SettingsRepository that doesn't call Firebase
class _MockSettingsRepository extends BaseRepository implements SettingsRepository {
  _MockSettingsRepository()
      : super(
          firestore: FirebaseFirestore.instance,
          firebaseAuth: FirebaseAuth.instance,
        );

  @override
  Stream<List<CategoryModel>> getCombinedStream(String collectionName) {
    return Stream.value([]);
  }

  @override
  Future<void> addCustomData(String collectionName, String name) async {
    // No-op for tests
  }

  @override
  Future<void> deleteCustomData(String collectionName, String docId) async {
    // No-op for tests
  }
}

class _TestApp extends StatelessWidget {
  final Widget home;
  final List<Override>? overrides;
  const _TestApp({required this.home, this.overrides});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides ?? const [],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        home: Material(child: home),
      ),
    );
  }
}
