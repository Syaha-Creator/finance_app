import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'core/services/analytics_service.dart';
import 'core/services/app_check_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/performance_service.dart';
import 'core/services/remote_config_service.dart';

/// Top-level function untuk handle background messages
/// Harus top-level function, tidak bisa di dalam class
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message handling
  // Local notifications akan di-handle oleh onMessage handler
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Crashlytics service (must be before other services)
  CrashlyticsService().init();

  // Initialize App Check service (should be early, for security)
  await AppCheckService().init();

  // Initialize Performance Monitoring service
  await PerformanceService().init();

  // Initialize analytics service
  AnalyticsService().init();

  // Initialize Remote Config service
  await RemoteConfigService().init();

  // Initialize local notification service
  await LocalNotificationService().init();

  // Initialize FCM service
  await FCMService().init();

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MyApp()));
}
