import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../utils/logger.dart';

/// Service untuk Firebase Remote Config
/// Digunakan untuk feature flags, A/B testing, dan dynamic configuration
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _initialized = false;

  /// Get Remote Config instance
  FirebaseRemoteConfig get remoteConfig => _remoteConfig;

  /// Initialize Remote Config service
  Future<void> init() async {
    if (_initialized) {
      AppLogger.info('Remote Config already initialized');
      return;
    }

    try {
      // Set default values (fallback jika remote config belum di-fetch)
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      // Set default values
      await _remoteConfig.setDefaults(_getDefaultValues());

      // Fetch and activate
      await fetchAndActivate();

      _initialized = true;
      AppLogger.info('Remote Config initialized successfully');
    } catch (e) {
      AppLogger.error('Error initializing Remote Config', e);
      _initialized = false;
    }
  }

  /// Get default values untuk Remote Config
  Map<String, dynamic> _getDefaultValues() {
    return {
      // Feature flags
      'enable_smart_notifications': true,
      'enable_financial_health_score': true,
      'enable_auto_budget_suggestions': true,
      'enable_receipt_ocr': true,
      'enable_investment_tracking': true,

      // Notification settings
      'notification_budget_warning_threshold': 0.8, // 80%
      'notification_goal_reminder_days': 7,
      'notification_debt_reminder_days': 3,
      'max_daily_notifications': 10,

      // App settings
      'default_currency': 'IDR',
      'default_date_format': 'dd/MM/yyyy',
      'enable_dark_mode': false,
      'enable_biometric_auth': false,

      // Performance settings
      'cache_duration_hours': 24,
      'max_transactions_per_page': 50,
      'enable_offline_mode': true,

      // UI/UX settings
      'enable_animations': true,
      'enable_haptic_feedback': true,
      'chart_refresh_interval_seconds': 30,

      // A/B Testing flags
      'ab_test_variant': 'control', // control, variant_a, variant_b
      'enable_new_dashboard_design': false,
      'enable_new_transaction_flow': false,
    };
  }

  /// Fetch and activate Remote Config
  Future<bool> fetchAndActivate() async {
    try {
      final activated = await _remoteConfig.fetchAndActivate();
      AppLogger.info('Remote Config fetched and activated: $activated');
      return activated;
    } catch (e) {
      AppLogger.error('Error fetching Remote Config', e);
      return false;
    }
  }

  /// Force fetch (bypass cache)
  Future<void> fetch() async {
    try {
      await _remoteConfig.fetch();
      await _remoteConfig.activate();
      AppLogger.info('Remote Config force fetched');
    } catch (e) {
      AppLogger.error('Error force fetching Remote Config', e);
    }
  }

  // ========== Feature Flags ==========

  /// Check if feature is enabled
  bool isFeatureEnabled(String featureKey) {
    try {
      return _remoteConfig.getBool(featureKey);
    } catch (e) {
      AppLogger.error('Error getting feature flag: $featureKey', e);
      // Return default value from defaults map
      final defaults = _getDefaultValues();
      return defaults[featureKey] as bool? ?? false;
    }
  }

  /// Get feature flag value with default
  bool getFeatureFlag(String featureKey, {bool defaultValue = false}) {
    try {
      return _remoteConfig.getBool(featureKey);
    } catch (e) {
      AppLogger.error('Error getting feature flag: $featureKey', e);
      return defaultValue;
    }
  }

  // ========== Smart Notifications Feature Flags ==========

  bool get enableSmartNotifications =>
      getFeatureFlag('enable_smart_notifications', defaultValue: true);

  bool get enableFinancialHealthScore =>
      getFeatureFlag('enable_financial_health_score', defaultValue: true);

  bool get enableAutoBudgetSuggestions =>
      getFeatureFlag('enable_auto_budget_suggestions', defaultValue: true);

  bool get enableReceiptOCR =>
      getFeatureFlag('enable_receipt_ocr', defaultValue: true);

  bool get enableInvestmentTracking =>
      getFeatureFlag('enable_investment_tracking', defaultValue: true);

  // ========== Notification Settings ==========

  double get budgetWarningThreshold =>
      _remoteConfig.getDouble('notification_budget_warning_threshold');

  int get goalReminderDays =>
      _remoteConfig.getInt('notification_goal_reminder_days');

  int get debtReminderDays =>
      _remoteConfig.getInt('notification_debt_reminder_days');

  int get maxDailyNotifications =>
      _remoteConfig.getInt('max_daily_notifications');

  // ========== App Settings ==========

  String get defaultCurrency => _remoteConfig.getString('default_currency');

  String get defaultDateFormat =>
      _remoteConfig.getString('default_date_format');

  bool get enableDarkMode =>
      getFeatureFlag('enable_dark_mode', defaultValue: false);

  bool get enableBiometricAuth =>
      getFeatureFlag('enable_biometric_auth', defaultValue: false);

  // ========== Performance Settings ==========

  int get cacheDurationHours => _remoteConfig.getInt('cache_duration_hours');

  int get maxTransactionsPerPage =>
      _remoteConfig.getInt('max_transactions_per_page');

  bool get enableOfflineMode =>
      getFeatureFlag('enable_offline_mode', defaultValue: true);

  // ========== UI/UX Settings ==========

  bool get enableAnimations =>
      getFeatureFlag('enable_animations', defaultValue: true);

  bool get enableHapticFeedback =>
      getFeatureFlag('enable_haptic_feedback', defaultValue: true);

  int get chartRefreshIntervalSeconds =>
      _remoteConfig.getInt('chart_refresh_interval_seconds');

  // ========== A/B Testing ==========

  String get abTestVariant => _remoteConfig.getString('ab_test_variant');

  bool get enableNewDashboardDesign =>
      getFeatureFlag('enable_new_dashboard_design', defaultValue: false);

  bool get enableNewTransactionFlow =>
      getFeatureFlag('enable_new_transaction_flow', defaultValue: false);

  // ========== Generic Getters ==========

  /// Get string value
  String getString(String key, {String defaultValue = ''}) {
    try {
      return _remoteConfig.getString(key);
    } catch (e) {
      AppLogger.error('Error getting string: $key', e);
      return defaultValue;
    }
  }

  /// Get int value
  int getInt(String key, {int defaultValue = 0}) {
    try {
      return _remoteConfig.getInt(key);
    } catch (e) {
      AppLogger.error('Error getting int: $key', e);
      return defaultValue;
    }
  }

  /// Get double value
  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return _remoteConfig.getDouble(key);
    } catch (e) {
      AppLogger.error('Error getting double: $key', e);
      return defaultValue;
    }
  }

  /// Get bool value
  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _remoteConfig.getBool(key);
    } catch (e) {
      AppLogger.error('Error getting bool: $key', e);
      return defaultValue;
    }
  }

  /// Get all parameters as map
  Map<String, dynamic> getAllParameters() {
    final all = _remoteConfig.getAll();
    return all.map((key, value) => MapEntry(key, value.asString()));
  }

  /// Check if Remote Config is initialized
  bool get isInitialized => _initialized;

  /// Get last fetch time
  DateTime get lastFetchTime => _remoteConfig.lastFetchTime;

  /// Get last fetch status
  RemoteConfigFetchStatus get lastFetchStatus => _remoteConfig.lastFetchStatus;
}
