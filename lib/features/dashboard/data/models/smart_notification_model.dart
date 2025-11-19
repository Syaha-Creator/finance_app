import 'package:flutter/material.dart';

/// Model untuk smart notification
class SmartNotification {
  final String id;
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final DateTime timestamp;
  final NotificationType type;
  final NotificationPriority priority;

  SmartNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.timestamp,
    required this.type,
    required this.priority,
  });
}

/// Tipe notifikasi
enum NotificationType {
  budget,
  goal,
  investment,
  debt,
  spending,
  income,
  reminder,
}

/// Prioritas notifikasi
enum NotificationPriority { low, medium, high, urgent }
