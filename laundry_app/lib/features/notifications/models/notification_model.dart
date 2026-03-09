// lib/features/notifications/data/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final bool read;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    this.read = false,
  });

  factory NotificationItem.fromMap(String id, Map<String, dynamic> data) {
    return NotificationItem(
      id: id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      read: data['read'] ?? false,
    );
  }
}
