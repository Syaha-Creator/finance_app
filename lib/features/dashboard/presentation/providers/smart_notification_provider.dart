import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/remote_config_service.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../goals/presentation/providers/goal_provider.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../asset/presentation/providers/asset_provider.dart';
import '../../../debt/presentation/providers/debt_provider.dart';
import '../../application/notification_generator_service.dart';
import '../../application/notification_sender_service.dart';
import '../../data/models/smart_notification_model.dart';

// Re-export for convenience
export '../../data/models/smart_notification_model.dart';

final smartNotificationsProvider = FutureProvider<List<SmartNotification>>((
  ref,
) async {
  // Check if smart notifications feature is enabled via Remote Config
  final remoteConfig = RemoteConfigService();
  if (!remoteConfig.enableSmartNotifications) {
    return [];
  }

  // Watch all relevant data providers
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final budgetsAsync = ref.watch(
    budgetsForMonthProvider((
      year: DateTime.now().year,
      month: DateTime.now().month,
    )),
  );
  final goalsAsync = ref.watch(goalsWithProgressProvider);
  final assetsAsync = ref.watch(assetsStreamProvider);
  final debtsAsync = ref.watch(debtsStreamProvider);

  // Wait for all data to be available
  final results = await Future.wait([
    transactionsAsync.when(
      data: (data) => Future.value(data),
      loading: () => Future.value(<dynamic>[]),
      error: (_, __) => Future.value(<dynamic>[]),
    ),
    budgetsAsync.when(
      data: (data) => Future.value(data),
      loading: () => Future.value(<dynamic>[]),
      error: (_, __) => Future.value(<dynamic>[]),
    ),
    goalsAsync.when(
      data: (data) => Future.value(data),
      loading: () => Future.value(<dynamic>[]),
      error: (_, __) => Future.value(<dynamic>[]),
    ),
    assetsAsync.when(
      data: (data) => Future.value(data),
      loading: () => Future.value(<dynamic>[]),
      error: (_, __) => Future.value(<dynamic>[]),
    ),
    debtsAsync.when(
      data: (data) => Future.value(data),
      loading: () => Future.value(<dynamic>[]),
      error: (_, __) => Future.value(<dynamic>[]),
    ),
  ]);

  final transactions = results[0];
  final budgets = results[1];
  final goals = results[2];
  final assets = results[3];
  final debts = results[4];

  final notifications = NotificationGeneratorService.generateNotifications(
    transactions: transactions,
    budgets: budgets,
    goals: goals,
    assets: assets,
    debts: debts,
  );

  // Send local notifications for urgent and high priority notifications
  // Check max daily notifications limit from Remote Config
  final maxNotifications = remoteConfig.maxDailyNotifications;
  final notificationsToSend = notifications.take(maxNotifications).toList();
  NotificationSenderService.sendLocalNotifications(notificationsToSend);

  return notifications;
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(smartNotificationsProvider);
  return notificationsAsync.when(
    data: (notifications) => notifications.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
