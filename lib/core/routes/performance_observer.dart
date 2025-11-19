import 'package:flutter/material.dart';
import 'package:firebase_performance/firebase_performance.dart';
import '../services/performance_service.dart';

/// Performance Observer untuk GoRouter
/// Track screen rendering time untuk setiap navigation
class PerformanceRouteObserver extends NavigatorObserver {
  final Map<String, Trace> _activeTraces = {};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _startTrace(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) {
      _stopTrace(oldRoute);
    }
    if (newRoute != null) {
      _startTrace(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _stopTrace(route);
  }

  void _startTrace(Route<dynamic> route) {
    final routeName = route.settings.name ?? 'unknown';
    final trace = PerformanceService().startScreenTrace(routeName);
    trace.start();
    _activeTraces[routeName] = trace;
  }

  void _stopTrace(Route<dynamic> route) {
    final routeName = route.settings.name ?? 'unknown';
    final trace = _activeTraces[routeName];
    if (trace != null) {
      trace.stop();
      _activeTraces.remove(routeName);
    }
  }
}
