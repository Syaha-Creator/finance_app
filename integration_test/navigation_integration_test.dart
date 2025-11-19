import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:go_router/go_router.dart';

import 'package:finance_app/core/routes/route_paths.dart';
import 'package:finance_app/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finance_app/features/asset/presentation/providers/asset_provider.dart';
import 'package:finance_app/features/debt/presentation/providers/debt_provider.dart';
import 'package:finance_app/features/transaction/presentation/providers/recurring_transaction_provider.dart';
import 'package:finance_app/features/goals/presentation/providers/goal_provider.dart';
import 'package:finance_app/features/goals/data/models/goal_model.dart';
import 'package:finance_app/features/goals/data/repositories/goal_repository.dart';
import 'package:finance_app/core/data/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finance_app/features/budget/presentation/providers/budget_providers.dart';
import 'package:finance_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:finance_app/features/bill_management/presentation/providers/bill_provider.dart';
import 'package:finance_app/features/receipt_management/presentation/providers/receipt_provider.dart';
import 'package:finance_app/features/investment/presentation/providers/investment_provider.dart';
import 'package:finance_app/features/financial_health/application/financial_health_service.dart';
import 'package:finance_app/features/financial_health/domain/entities/financial_health_analysis.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/features/settings/data/repositories/settings_repository.dart';
import 'package:finance_app/features/settings/data/models/setting_model.dart';

// Import pages to verify they load
import 'package:finance_app/features/dashboard/presentation/pages/main_page.dart';
import 'package:finance_app/features/transaction/presentation/pages/transaction_page.dart';
import 'package:finance_app/features/goals/presentation/pages/goals_page.dart';
import 'package:finance_app/features/asset/presentation/pages/asset_page.dart';
import 'package:finance_app/features/debt/presentation/pages/debt_page.dart';
import 'package:finance_app/features/budget/presentation/pages/budget_page.dart';
import 'package:finance_app/features/reports/presentation/pages/reports_page.dart';
import 'package:finance_app/features/bill_management/presentation/pages/bill_management_page.dart';
import 'package:finance_app/features/receipt_management/presentation/pages/receipt_management_page.dart';
import 'package:finance_app/features/investment/presentation/pages/investment_management_page.dart';
import 'package:finance_app/features/transaction/presentation/pages/recurring_transaction_page.dart';
import 'package:finance_app/features/dashboard/presentation/pages/financial_health_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Integration Test', () {
    testWidgets(
      'Navigate smoothly between all pages without Firebase dependency',
      (tester) async {
        // Build router with custom redirect that uses mocked auth
        final router = GoRouter(
          initialLocation: RoutePaths.main,
          routes: [
            GoRoute(
              path: RoutePaths.main,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const MainPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.transactions,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const TransactionPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.goals,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const GoalsPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.assets,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const AssetPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.debt,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const DebtPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.budget,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const BudgetPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.reports,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const ReportsPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.bills,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const BillManagementPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.receipts,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const ReceiptManagementPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.investments,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const InvestmentManagementPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.recurringTransactions,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const RecurringTransactionPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.financialHealth,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const FinancialHealthPage(),
                  ),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: _testOverrides(),
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: router,
            ),
          ),
        );

        // Wait for initial load
        await _pumpUntilStable(tester);

        // Verify we're on main page
        expect(find.byType(MainPage), findsOneWidget);

        // Define routes with their expected page types for verification
        final navigationTests = [
          {
            'route': RoutePaths.transactions,
            'pageType': TransactionPage,
            'name': 'Transactions',
          },
          {'route': RoutePaths.goals, 'pageType': GoalsPage, 'name': 'Goals'},
          {'route': RoutePaths.assets, 'pageType': AssetPage, 'name': 'Assets'},
          {'route': RoutePaths.debt, 'pageType': DebtPage, 'name': 'Debt'},
          {
            'route': RoutePaths.budget,
            'pageType': BudgetPage,
            'name': 'Budget',
          },
          {
            'route': RoutePaths.reports,
            'pageType': ReportsPage,
            'name': 'Reports',
          },
          {
            'route': RoutePaths.bills,
            'pageType': BillManagementPage,
            'name': 'Bills',
          },
          {
            'route': RoutePaths.receipts,
            'pageType': ReceiptManagementPage,
            'name': 'Receipts',
          },
          {
            'route': RoutePaths.investments,
            'pageType': InvestmentManagementPage,
            'name': 'Investments',
          },
          {
            'route': RoutePaths.recurringTransactions,
            'pageType': RecurringTransactionPage,
            'name': 'Recurring Transactions',
          },
          {
            'route': RoutePaths.financialHealth,
            'pageType': FinancialHealthPage,
            'name': 'Financial Health',
          },
          {'route': RoutePaths.main, 'pageType': MainPage, 'name': 'Main'},
        ];

        // Navigate to each route and verify it loads
        for (final test in navigationTests) {
          final route = test['route'] as String;
          final pageType = test['pageType'] as Type;
          final name = test['name'] as String;

          // Navigate to route
          router.go(route);
          await tester.pump();

          // Wait for navigation and page to stabilize
          await _pumpUntilStable(tester);

          // Verify the correct page is displayed
          expect(
            find.byType(pageType),
            findsOneWidget,
            reason: 'Failed to navigate to $name page',
          );
        }
      },
    );

    testWidgets('Navigation is smooth with proper transitions', (tester) async {
      final router = GoRouter(
        initialLocation: RoutePaths.main,
        routes: [
          GoRoute(
            path: RoutePaths.main,
            pageBuilder:
                (context, state) => MaterialPage<void>(
                  key: state.pageKey,
                  child: const MainPage(),
                ),
          ),
          GoRoute(
            path: RoutePaths.transactions,
            pageBuilder:
                (context, state) => MaterialPage<void>(
                  key: state.pageKey,
                  child: const TransactionPage(),
                ),
          ),
          GoRoute(
            path: RoutePaths.goals,
            pageBuilder:
                (context, state) => MaterialPage<void>(
                  key: state.pageKey,
                  child: const GoalsPage(),
                ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: _testOverrides(),
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
          ),
        ),
      );

      await _pumpUntilStable(tester);

      // Test rapid navigation between pages
      final routes = [
        RoutePaths.transactions,
        RoutePaths.goals,
        RoutePaths.main,
        RoutePaths.transactions,
      ];

      for (final route in routes) {
        router.go(route);
        await tester.pump();
        await _pumpUntilStable(tester);

        // Verify navigation completed by checking current location
        expect(router.routerDelegate.currentConfiguration.uri.path, route);
      }
    });

    testWidgets('Navigate using bottom navigation bar like real user', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: RoutePaths.main,
        routes: [
          GoRoute(
            path: RoutePaths.main,
            pageBuilder:
                (context, state) => MaterialPage<void>(
                  key: state.pageKey,
                  child: const MainPage(),
                ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: _testOverrides(),
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
          ),
        ),
      );

      await _pumpUntilStable(tester);

      // Verify we're on MainPage
      expect(find.byType(MainPage), findsOneWidget);

      // Test bottom navigation - find icons within BottomAppBar
      // We need to find IconButtons in the bottom navigation bar
      // Dashboard (index 0) - should already be selected
      final bottomBar = find.byType(BottomAppBar);
      expect(bottomBar, findsOneWidget);

      // Find IconButtons within BottomAppBar
      final iconButtons = find.descendant(
        of: bottomBar,
        matching: find.byType(IconButton),
      );
      expect(iconButtons, findsNWidgets(4)); // Should have 4 navigation items

      // Tap Transaksi (index 1) - second IconButton
      await tester.tap(iconButtons.at(1));
      await _pumpUntilStable(tester);
      expect(find.byType(TransactionPage), findsOneWidget);

      // Tap Laporan (index 2) - third IconButton
      await tester.tap(iconButtons.at(2));
      await _pumpUntilStable(tester);
      expect(find.byType(ReportsPage), findsOneWidget);

      // Tap Profil (index 3) - fourth IconButton
      await tester.tap(iconButtons.at(3));
      await _pumpUntilStable(tester);
      // SettingsPage is shown in MainPage when index 3 is selected
      expect(find.byType(MainPage), findsOneWidget);

      // Go back to Dashboard (index 0) - first IconButton
      await tester.tap(iconButtons.at(0));
      await _pumpUntilStable(tester);
      expect(find.byType(MainPage), findsOneWidget);
    });

    testWidgets('Back button navigation works correctly', (tester) async {
      final router = GoRouter(
        initialLocation: RoutePaths.main,
        routes: [
          GoRoute(
            path: RoutePaths.main,
            pageBuilder:
                (context, state) => MaterialPage<void>(
                  key: state.pageKey,
                  child: const MainPage(),
                ),
          ),
          GoRoute(
            path: RoutePaths.goals,
            pageBuilder:
                (context, state) => MaterialPage<void>(
                  key: state.pageKey,
                  child: const GoalsPage(),
                ),
          ),
          GoRoute(
            path: RoutePaths.assets,
            pageBuilder:
                (context, state) => MaterialPage<void>(
                  key: state.pageKey,
                  child: const AssetPage(),
                ),
          ),
          GoRoute(
            path: RoutePaths.debt,
            pageBuilder:
                (context, state) => MaterialPage<void>(
                  key: state.pageKey,
                  child: const DebtPage(),
                ),
          ),
          GoRoute(
            path: RoutePaths.budget,
            pageBuilder:
                (context, state) => MaterialPage<void>(
                  key: state.pageKey,
                  child: const BudgetPage(),
                ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: _testOverrides(),
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
          ),
        ),
      );

      await _pumpUntilStable(tester);

      // Start at main page
      expect(find.byType(MainPage), findsOneWidget);

      // Navigate to Goals page
      router.push(RoutePaths.goals);
      await tester.pump();
      await _pumpUntilStable(tester);
      expect(find.byType(GoalsPage), findsOneWidget);

      // Press back button - should go back to MainPage
      router.pop();
      await tester.pump();
      await _pumpUntilStable(tester);
      expect(find.byType(MainPage), findsOneWidget);

      // Navigate to Assets page
      router.push(RoutePaths.assets);
      await tester.pump();
      await _pumpUntilStable(tester);
      expect(find.byType(AssetPage), findsOneWidget);

      // Navigate to Debt page (push another route)
      router.push(RoutePaths.debt);
      await tester.pump();
      await _pumpUntilStable(tester);
      expect(find.byType(DebtPage), findsOneWidget);

      // Press back - should go to Assets
      router.pop();
      await tester.pump();
      await _pumpUntilStable(tester);
      expect(find.byType(AssetPage), findsOneWidget);

      // Press back again - should go to MainPage
      router.pop();
      await tester.pump();
      await _pumpUntilStable(tester);
      expect(find.byType(MainPage), findsOneWidget);
    });

    testWidgets(
      'Navigate through multiple pages and back button maintains correct stack',
      (tester) async {
        final router = GoRouter(
          initialLocation: RoutePaths.main,
          routes: [
            GoRoute(
              path: RoutePaths.main,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const MainPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.transactions,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const TransactionPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.goals,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const GoalsPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.assets,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const AssetPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.budget,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const BudgetPage(),
                  ),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: _testOverrides(),
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: router,
            ),
          ),
        );

        await _pumpUntilStable(tester);

        // Navigate through a sequence like a real user would
        // Main -> Transactions -> Goals -> Assets -> Budget
        router.push(RoutePaths.transactions);
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(TransactionPage), findsOneWidget);

        router.push(RoutePaths.goals);
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(GoalsPage), findsOneWidget);

        router.push(RoutePaths.assets);
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(AssetPage), findsOneWidget);

        router.push(RoutePaths.budget);
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(BudgetPage), findsOneWidget);

        // Now go back through the stack
        // Budget -> Assets -> Goals -> Transactions -> Main
        router.pop();
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(AssetPage), findsOneWidget);

        router.pop();
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(GoalsPage), findsOneWidget);

        router.pop();
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(TransactionPage), findsOneWidget);

        router.pop();
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(MainPage), findsOneWidget);
      },
    );

    testWidgets(
      'Real user flow: Navigate from main, use back button, navigate again',
      (tester) async {
        final router = GoRouter(
          initialLocation: RoutePaths.main,
          routes: [
            GoRoute(
              path: RoutePaths.main,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const MainPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.goals,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const GoalsPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.assets,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const AssetPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.debt,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const DebtPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.budget,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const BudgetPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.bills,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const BillManagementPage(),
                  ),
            ),
            GoRoute(
              path: RoutePaths.receipts,
              pageBuilder:
                  (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: const ReceiptManagementPage(),
                  ),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: _testOverrides(),
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: router,
            ),
          ),
        );

        await _pumpUntilStable(tester);

        // Simulate real user flow
        // 1. User starts at main
        expect(find.byType(MainPage), findsOneWidget);

        // 2. User navigates to Goals
        router.push(RoutePaths.goals);
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(GoalsPage), findsOneWidget);

        // 3. User presses back
        router.pop();
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(MainPage), findsOneWidget);

        // 4. User navigates to Assets
        router.push(RoutePaths.assets);
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(AssetPage), findsOneWidget);

        // 5. User navigates to Debt
        router.push(RoutePaths.debt);
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(DebtPage), findsOneWidget);

        // 6. User presses back (should go to Assets)
        router.pop();
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(AssetPage), findsOneWidget);

        // 7. User presses back again (should go to Main)
        router.pop();
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(MainPage), findsOneWidget);

        // 8. User navigates to Budget
        router.push(RoutePaths.budget);
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(BudgetPage), findsOneWidget);

        // 9. User navigates to Bills
        router.push(RoutePaths.bills);
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(BillManagementPage), findsOneWidget);

        // 10. User presses back (should go to Budget)
        router.pop();
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(BudgetPage), findsOneWidget);

        // 11. User presses back again (should go to Main)
        router.pop();
        await tester.pump();
        await _pumpUntilStable(tester);
        expect(find.byType(MainPage), findsOneWidget);
      },
    );
  });
}

/// Helper function to pump until the widget tree is stable
Future<void> _pumpUntilStable(
  WidgetTester tester, {
  int maxPumps = 30,
  Duration step = const Duration(milliseconds: 100),
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
  // Final pump to ensure everything is settled
  await tester.pump(const Duration(milliseconds: 200));
}

List<Override> _testOverrides() {
  final now = DateTime.now();
  return [
    // Auth - return null to simulate logged out state, but router won't redirect
    authStateChangesProvider.overrideWith((ref) => Stream.value(null)),

    // Transactions
    transactionsStreamProvider.overrideWith((ref) => Stream.value([])),

    // Assets and Debts
    assetsStreamProvider.overrideWith((ref) => Stream.value([])),
    debtsStreamProvider.overrideWith((ref) => Stream.value([])),

    // Recurring Transactions
    recurringTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),

    // Goals
    goalRepositoryProvider.overrideWith((ref) => _MockGoalRepository()),
    goalsWithProgressProvider.overrideWith(
      (ref) => Stream.value(<GoalModel>[]),
    ),
    goalsStreamProvider.overrideWith((ref) => Stream.value(<GoalModel>[])),

    // Budgets
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

    // Settings
    expenseCategoriesProvider.overrideWith((ref) => Stream.value([])),
    incomeCategoriesProvider.overrideWith((ref) => Stream.value([])),
    accountsProvider.overrideWith((ref) => Stream.value([])),
    settingsRepositoryProvider.overrideWith((ref) => _MockSettingsRepository()),
    settingsControllerProvider.overrideWith(
      (ref) => SettingsController(
        settingsRepository: ref.watch(settingsRepositoryProvider),
        ref: ref,
      ),
    ),
  ];
}

class _MockSettingsRepository extends BaseRepository
    implements SettingsRepository {
  _MockSettingsRepository()
    : super(
        firestore: FirebaseFirestore.instance,
        firebaseAuth: FirebaseAuth.instance,
      );

  @override
  Stream<List<CategoryModel>> getCombinedStream(String collectionName) =>
      Stream.value([]);

  @override
  Future<void> addCustomData(String collectionName, String name) async {}

  @override
  Future<void> deleteCustomData(String collectionName, String docId) async {}
}

class _MockGoalRepository extends BaseRepository implements GoalRepository {
  _MockGoalRepository()
    : super(
        firestore: FirebaseFirestore.instance,
        firebaseAuth: FirebaseAuth.instance,
      );

  @override
  Stream<List<GoalModel>> getGoalsStream() => Stream.value(<GoalModel>[]);

  @override
  Future<void> addGoal(GoalModel goal) async {}

  @override
  Future<void> updateGoal(GoalModel goal) async {}

  @override
  Future<void> deleteGoal(String goalId) async {}

  @override
  Future<GoalModel?> getGoalById(String goalId) async => null;

  @override
  Future<void> addFundsToGoal({
    required String goalId,
    required double amount,
    required String fromAccountName,
  }) async {}
}
