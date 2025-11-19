import 'package:firebase_analytics/firebase_analytics.dart';
import '../utils/logger.dart';

/// Service untuk Firebase Analytics tracking
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver? _observer;

  /// Get analytics instance
  FirebaseAnalytics get analytics => _analytics;

  /// Get analytics observer untuk GoRouter
  FirebaseAnalyticsObserver? get observer => _observer;

  /// Initialize analytics service
  void init() {
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
    AppLogger.info('Analytics service initialized');
  }

  /// Log custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      AppLogger.info('Analytics event logged: $name');
    } catch (e) {
      AppLogger.error('Error logging analytics event', e);
    }
  }

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      AppLogger.info('Screen view logged: $screenName');
    } catch (e) {
      AppLogger.error('Error logging screen view', e);
    }
  }

  /// Set user property
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      AppLogger.info('User property set: $name = $value');
    } catch (e) {
      AppLogger.error('Error setting user property', e);
    }
  }

  /// Set user ID
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
      AppLogger.info('User ID set: $userId');
    } catch (e) {
      AppLogger.error('Error setting user ID', e);
    }
  }

  // ========== Finance App Specific Events ==========

  /// Log transaction created
  Future<void> logTransactionCreated({
    required String type, // 'income', 'expense', 'transfer'
    required double amount,
    String? category,
  }) async {
    await logEvent(
      name: 'transaction_created',
      parameters: {
        'transaction_type': type,
        'amount': amount,
        if (category != null) 'category': category,
      },
    );
  }

  /// Log transaction deleted
  Future<void> logTransactionDeleted({
    required String type,
    required double amount,
  }) async {
    await logEvent(
      name: 'transaction_deleted',
      parameters: {'transaction_type': type, 'amount': amount},
    );
  }

  /// Log budget created
  Future<void> logBudgetCreated({
    required String category,
    required double amount,
    required int month,
    required int year,
  }) async {
    await logEvent(
      name: 'budget_created',
      parameters: {
        'category': category,
        'amount': amount,
        'month': month,
        'year': year,
      },
    );
  }

  /// Log budget exceeded
  Future<void> logBudgetExceeded({
    required String category,
    required double budgetAmount,
    required double spentAmount,
  }) async {
    await logEvent(
      name: 'budget_exceeded',
      parameters: {
        'category': category,
        'budget_amount': budgetAmount,
        'spent_amount': spentAmount,
        'exceeded_by': spentAmount - budgetAmount,
      },
    );
  }

  /// Log goal created
  Future<void> logGoalCreated({
    required String goalName,
    required double targetAmount,
    required DateTime targetDate,
  }) async {
    await logEvent(
      name: 'goal_created',
      parameters: {
        'goal_name': goalName,
        'target_amount': targetAmount,
        'target_date': targetDate.toIso8601String(),
      },
    );
  }

  /// Log goal completed
  Future<void> logGoalCompleted({
    required String goalName,
    required double targetAmount,
    required double achievedAmount,
    required int daysToComplete,
  }) async {
    await logEvent(
      name: 'goal_completed',
      parameters: {
        'goal_name': goalName,
        'target_amount': targetAmount,
        'achieved_amount': achievedAmount,
        'days_to_complete': daysToComplete,
      },
    );
  }

  /// Log debt created
  Future<void> logDebtCreated({
    required String type, // 'payable', 'receivable'
    required double amount,
    required DateTime dueDate,
  }) async {
    await logEvent(
      name: 'debt_created',
      parameters: {
        'debt_type': type,
        'amount': amount,
        'due_date': dueDate.toIso8601String(),
      },
    );
  }

  /// Log debt paid
  Future<void> logDebtPaid({
    required String type,
    required double amount,
    required int daysOverdue,
  }) async {
    await logEvent(
      name: 'debt_paid',
      parameters: {
        'debt_type': type,
        'amount': amount,
        'days_overdue': daysOverdue,
      },
    );
  }

  /// Log asset added
  Future<void> logAssetAdded({
    required String assetType,
    required double value,
  }) async {
    await logEvent(
      name: 'asset_added',
      parameters: {'asset_type': assetType, 'value': value},
    );
  }

  /// Log bill created
  Future<void> logBillCreated({
    required String title,
    required double amount,
    required DateTime dueDate,
    required bool isRecurring,
  }) async {
    await logEvent(
      name: 'bill_created',
      parameters: {
        'title': title,
        'amount': amount,
        'due_date': dueDate.toIso8601String(),
        'is_recurring': isRecurring,
      },
    );
  }

  /// Log bill paid
  Future<void> logBillPaid({
    required String title,
    required double amount,
    required bool isOverdue,
  }) async {
    await logEvent(
      name: 'bill_paid',
      parameters: {'title': title, 'amount': amount, 'is_overdue': isOverdue},
    );
  }

  /// Log receipt scanned
  Future<void> logReceiptScanned({
    required bool success,
    String? errorMessage,
  }) async {
    await logEvent(
      name: 'receipt_scanned',
      parameters: {
        'success': success,
        if (errorMessage != null) 'error': errorMessage,
      },
    );
  }

  /// Log financial health viewed
  Future<void> logFinancialHealthViewed({required double score}) async {
    await logEvent(
      name: 'financial_health_viewed',
      parameters: {'score': score},
    );
  }

  /// Log report generated
  Future<void> logReportGenerated({
    required String reportType, // 'monthly', 'yearly', 'category'
    required String period,
  }) async {
    await logEvent(
      name: 'report_generated',
      parameters: {'report_type': reportType, 'period': period},
    );
  }

  /// Log notification received
  Future<void> logNotificationReceived({
    required String notificationType,
    required String priority,
  }) async {
    await logEvent(
      name: 'notification_received',
      parameters: {'notification_type': notificationType, 'priority': priority},
    );
  }

  /// Log notification tapped
  Future<void> logNotificationTapped({
    required String notificationType,
    required String priority,
  }) async {
    await logEvent(
      name: 'notification_tapped',
      parameters: {'notification_type': notificationType, 'priority': priority},
    );
  }

  /// Log search performed
  Future<void> logSearchPerformed({
    required String searchType, // 'transaction', 'goal', 'debt', etc.
    required String query,
    required int resultsCount,
  }) async {
    await logEvent(
      name: 'search_performed',
      parameters: {
        'search_type': searchType,
        'query': query,
        'results_count': resultsCount,
      },
    );
  }

  /// Log feature used
  Future<void> logFeatureUsed({
    required String featureName,
    Map<String, Object>? additionalParams,
  }) async {
    final parameters = <String, Object>{
      'feature_name': featureName,
      if (additionalParams != null) ...additionalParams,
    };
    await logEvent(name: 'feature_used', parameters: parameters);
  }
}
