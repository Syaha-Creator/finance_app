import 'package:flutter/material.dart';

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
import '../../features/budget/presentation/pages/budget_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/edit_profile_page.dart';

class AppRoutes {
  AppRoutes._();

  // Route names
  static const String transactionDetail = '/transaction-detail';
  static const String addTransaction = '/add-transaction';
  static const String addTransactionWithGoal = '/add-transaction-with-goal';
  static const String editTransactionWithGoal = '/edit-transaction-with-goal';
  static const String addAsset = '/add-asset';
  static const String addDebt = '/add-debt';
  static const String addGoal = '/add-goal';
  static const String editProfile = '/edit-profile';

  // Main page routes
  static const String transactions = '/transactions';
  static const String goals = '/goals';
  static const String assets = '/assets';
  static const String debt = '/debt';
  static const String budget = '/budget';
  static const String reports = '/reports';

  // Route generator
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case transactionDetail:
        final transaction = settings.arguments as TransactionModel;
        return MaterialPageRoute(
          builder: (context) => TransactionDetailPage(transaction: transaction),
        );

      case addTransaction:
        return MaterialPageRoute(
          builder: (context) => const AddEditTransactionPage(),
        );

      case addTransactionWithGoal:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (context) => AddTransactionWithGoalPage(
                transactionType: args['transactionType'] as TransactionType,
                goalId: args['goalId'] as String?,
                goalName: args['goalName'] as String?,
              ),
        );

      case editTransactionWithGoal:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (context) => EditTransactionWithGoalPage(
                transaction: args['transaction'] as TransactionModel,
                goalId: args['goalId'] as String?,
                goalName: args['goalName'] as String?,
              ),
        );

      case addAsset:
        return MaterialPageRoute(
          builder: (context) => const AddEditAssetPage(),
        );

      case addDebt:
        return MaterialPageRoute(builder: (context) => const AddEditDebtPage());

      case addGoal:
        return MaterialPageRoute(builder: (context) => const AddEditGoalPage());

      case editProfile:
        return MaterialPageRoute(builder: (context) => const EditProfilePage());

      // Main page routes
      case transactions:
        return MaterialPageRoute(builder: (context) => const TransactionPage());
      case goals:
        return MaterialPageRoute(builder: (context) => const GoalsPage());
      case assets:
        return MaterialPageRoute(builder: (context) => const AssetPage());
      case debt:
        return MaterialPageRoute(builder: (context) => const DebtPage());
      case budget:
        return MaterialPageRoute(builder: (context) => const BudgetPage());
      case reports:
        return MaterialPageRoute(builder: (context) => const ReportsPage());

      default:
        return MaterialPageRoute(
          builder:
              (context) => const Scaffold(
                body: Center(child: Text('Route tidak ditemukan')),
              ),
        );
    }
  }
}
