import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../../features/transaction/data/models/transaction_model.dart';
import '../../features/transaction/presentation/pages/transaction_detail_page.dart';
import '../../features/transaction/presentation/pages/add_edit_transaction_page.dart';
import '../../features/transaction/presentation/pages/add_transaction_with_goal_page.dart';
import '../../features/transaction/presentation/pages/edit_transaction_with_goal_page.dart';
import '../../features/transaction/presentation/pages/transaction_page.dart';
import '../../features/asset/presentation/pages/add_edit_asset_page.dart';
import '../../features/asset/presentation/pages/asset_page.dart';
import '../../features/debt/presentation/pages/add_edit_debt_page.dart';
import '../../features/debt/presentation/pages/debt_page.dart';
import '../../features/goals/presentation/pages/add_edit_goal_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/goals/presentation/pages/goal_detail_page.dart';
import '../../features/budget/presentation/pages/budget_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/edit_profile_page.dart';
import '../../features/bill_management/presentation/pages/bill_management_page.dart';
import '../../features/bill_management/presentation/pages/add_edit_bill_page.dart';
import '../../features/receipt_management/presentation/pages/receipt_management_page.dart';
import '../../features/receipt_management/presentation/pages/add_receipt_page.dart';
import '../../features/investment/presentation/pages/investment_management_page.dart';
import '../../features/investment/presentation/pages/add_edit_investment_page.dart';
import '../../features/authentication/presentation/pages/auth_wrapper.dart';
import '../../features/dashboard/presentation/pages/main_page.dart';
import '../../features/transaction/presentation/pages/recurring_transaction_page.dart';
import '../../features/transaction/presentation/pages/add_edit_recurring_page.dart';
import '../../features/dashboard/presentation/pages/financial_health_page.dart';
import '../services/local_notification_service.dart';
import 'route_paths.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      LocalNotificationService.navigatorKey;

  static GoRouter buildRouter() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RoutePaths.auth,
      refreshListenable: _GoRouterRefreshStream(
        FirebaseAuth.instance.authStateChanges(),
      ),
      redirect: (context, state) {
        final bool loggedIn = FirebaseAuth.instance.currentUser != null;
        final String loc = state.matchedLocation;
        final bool atAuth = loc == RoutePaths.auth;
        if (!loggedIn && !atAuth) return RoutePaths.auth;
        if (loggedIn && atAuth) return RoutePaths.main;
        return null;
      },
      routes: [
        GoRoute(
          path: RoutePaths.auth,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const AuthWrapper()),
        ),
        GoRoute(
          name: 'main',
          path: RoutePaths.main,
          pageBuilder:
              (context, state) => _buildFadeSlidePage(state, const MainPage()),
        ),
        GoRoute(
          path: RoutePaths.transactions,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const TransactionPage()),
        ),
        GoRoute(
          path: RoutePaths.goalDetail,
          pageBuilder:
              (context, state) => _buildFadeSlidePage(
                state,
                GoalDetailPage(goal: state.extra as dynamic),
              ),
        ),
        GoRoute(
          path: RoutePaths.goals,
          pageBuilder:
              (context, state) => _buildFadeSlidePage(state, const GoalsPage()),
        ),
        GoRoute(
          path: RoutePaths.assets,
          pageBuilder:
              (context, state) => _buildFadeSlidePage(state, const AssetPage()),
        ),
        GoRoute(
          path: RoutePaths.debt,
          pageBuilder:
              (context, state) => _buildFadeSlidePage(state, const DebtPage()),
        ),
        GoRoute(
          path: RoutePaths.budget,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const BudgetPage()),
        ),
        GoRoute(
          path: RoutePaths.reports,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const ReportsPage()),
        ),
        GoRoute(
          path: RoutePaths.financialHealth,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const FinancialHealthPage()),
        ),
        GoRoute(
          path: RoutePaths.bills,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const BillManagementPage()),
        ),
        GoRoute(
          path: RoutePaths.receipts,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const ReceiptManagementPage()),
        ),
        GoRoute(
          path: RoutePaths.investments,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const InvestmentManagementPage()),
        ),
        GoRoute(
          path: RoutePaths.recurringTransactions,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const RecurringTransactionPage()),
        ),
        GoRoute(
          path: RoutePaths.addEditRecurring,
          pageBuilder:
              (context, state) => _buildFadeSlidePage(
                state,
                AddEditRecurringPage(
                  recurringTransaction: state.extra as dynamic,
                ),
              ),
        ),
        // Add routes for add/edit flows
        GoRoute(
          path: RoutePaths.addTransaction,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const AddEditTransactionPage()),
        ),
        GoRoute(
          path: RoutePaths.addTransactionWithGoal,
          pageBuilder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            return _buildFadeSlidePage(
              state,
              AddTransactionWithGoalPage(
                transactionType:
                    args?['transactionType'] as TransactionType? ??
                    TransactionType.expense,
                goalId: args?['goalId'] as String?,
                goalName: args?['goalName'] as String?,
              ),
            );
          },
        ),
        GoRoute(
          path: RoutePaths.editTransactionWithGoal,
          pageBuilder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            return _buildFadeSlidePage(
              state,
              _buildEditWithGoalOrFallback(args),
            );
          },
        ),
        GoRoute(
          path: RoutePaths.addAsset,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const AddEditAssetPage()),
        ),
        GoRoute(
          path: RoutePaths.addDebt,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const AddEditDebtPage()),
        ),
        GoRoute(
          path: RoutePaths.addGoal,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const AddEditGoalPage()),
        ),
        GoRoute(
          path: RoutePaths.addBill,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const AddEditBillPage()),
        ),
        GoRoute(
          path: RoutePaths.addReceipt,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const AddReceiptPage()),
        ),
        GoRoute(
          path: RoutePaths.addInvestment,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const AddEditInvestmentPage()),
        ),
        GoRoute(
          path: RoutePaths.editProfile,
          pageBuilder:
              (context, state) =>
                  _buildFadeSlidePage(state, const EditProfilePage()),
        ),
        // Detail route using extra arg
        GoRoute(
          path: RoutePaths.transactionDetail,
          pageBuilder:
              (context, state) => _buildFadeSlidePage(
                state,
                _buildTransactionDetailOrFallback(state),
              ),
        ),
      ],
    );
  }

  static CustomTransitionPage<dynamic> _buildFadeSlidePage(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<dynamic>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curved);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  static Widget _buildTransactionDetailOrFallback(GoRouterState state) {
    final extra = state.extra;
    if (extra is TransactionModel) {
      return TransactionDetailPage(transaction: extra);
    }
    // Fallback: show transactions list if no transaction provided
    return const TransactionPage();
  }

  static Widget _buildEditWithGoalOrFallback(Map<String, dynamic>? args) {
    final tx = args?['transaction'];
    if (tx is TransactionModel) {
      return EditTransactionWithGoalPage(
        transaction: tx,
        goalId: args?['goalId'] as String?,
        goalName: args?['goalName'] as String?,
      );
    }
    // Fallback to add-with-goal when no transaction provided
    final type =
        args?['transactionType'] as TransactionType? ?? TransactionType.expense;
    return AddTransactionWithGoalPage(
      transactionType: type,
      goalId: args?['goalId'] as String?,
      goalName: args?['goalName'] as String?,
    );
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
