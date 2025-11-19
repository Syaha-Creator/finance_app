import 'package:firebase_performance/firebase_performance.dart';
import '../utils/logger.dart';

/// Service untuk Firebase Performance Monitoring
/// Digunakan untuk monitor app performance, network requests, dan screen rendering
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final FirebasePerformance _performance = FirebasePerformance.instance;
  bool _initialized = false;

  /// Get Performance instance
  FirebasePerformance get performance => _performance;

  /// Initialize Performance Monitoring service
  Future<void> init() async {
    if (_initialized) {
      AppLogger.info('Performance Monitoring already initialized');
      return;
    }

    try {
      // Enable performance collection (default: enabled)
      // In debug mode, you might want to disable it
      // await _performance.setPerformanceCollectionEnabled(true);

      _initialized = true;
      AppLogger.info('Performance Monitoring initialized successfully');
    } catch (e) {
      AppLogger.error('Error initializing Performance Monitoring', e);
      _initialized = false;
    }
  }

  /// Start a trace for custom performance monitoring
  ///
  /// Example:
  /// ```dart
  /// final trace = PerformanceService().startTrace('load_dashboard');
  /// // ... do work ...
  /// await trace.stop();
  /// ```
  Trace startTrace(String traceName) {
    try {
      return _performance.newTrace(traceName);
    } catch (e) {
      AppLogger.error('Error starting trace: $traceName', e);
      // Return a no-op trace if error
      return _performance.newTrace('error_trace');
    }
  }

  /// Start a trace and automatically stop it after async operation
  ///
  /// Example:
  /// ```dart
  /// await PerformanceService().traceAsync('load_data', () async {
  ///   // ... async work ...
  /// });
  /// ```
  Future<T> traceAsync<T>(
    String traceName,
    Future<T> Function() operation,
  ) async {
    final trace = startTrace(traceName);
    await trace.start();
    try {
      final result = await operation();
      await trace.stop();
      return result;
    } catch (e) {
      await trace.stop();
      rethrow;
    }
  }

  /// Track HTTP request performance
  ///
  /// Example:
  /// ```dart
  /// final httpMetric = PerformanceService().newHttpMetric(
  ///   'https://api.example.com/data',
  ///   HttpMethod.Get,
  /// );
  /// await httpMetric.start();
  /// // ... make request ...
  /// httpMetric.setResponseContentType('application/json');
  /// httpMetric.setHttpResponseCode(200);
  /// await httpMetric.stop();
  /// ```
  HttpMetric newHttpMetric(String url, HttpMethod method) {
    try {
      return _performance.newHttpMetric(url, method);
    } catch (e) {
      AppLogger.error('Error creating HTTP metric: $url', e);
      // Return a no-op metric if error
      return _performance.newHttpMetric('error', HttpMethod.Get);
    }
  }

  /// Track screen rendering time
  ///
  /// Example:
  /// ```dart
  /// final screenTrace = PerformanceService().startScreenTrace('dashboard');
  /// // ... build screen ...
  /// await screenTrace.stop();
  /// ```
  Trace startScreenTrace(String screenName) {
    return startTrace('screen_$screenName');
  }

  /// Track database operation performance
  ///
  /// Example:
  /// ```dart
  /// await PerformanceService().traceDatabaseOperation('get_transactions', () async {
  ///   // ... database operation ...
  /// });
  /// ```
  Future<T> traceDatabaseOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    return traceAsync('db_$operationName', operation);
  }

  /// Track network request performance
  ///
  /// Example:
  /// ```dart
  /// await PerformanceService().traceNetworkRequest('get_user_data', () async {
  ///   // ... network request ...
  /// });
  /// ```
  Future<T> traceNetworkRequest<T>(
    String requestName,
    Future<T> Function() operation,
  ) async {
    return traceAsync('network_$requestName', operation);
  }

  /// Check if Performance Monitoring is initialized
  bool get isInitialized => _initialized;

  /// Enable/disable performance collection
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    try {
      await _performance.setPerformanceCollectionEnabled(enabled);
      AppLogger.info(
        'Performance collection ${enabled ? "enabled" : "disabled"}',
      );
    } catch (e) {
      AppLogger.error('Error setting performance collection', e);
    }
  }
}
