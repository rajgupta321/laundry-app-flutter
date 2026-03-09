// lib/screens/notifications/notification_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationDetailScreen extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;

  const NotificationDetailScreen({
    super.key,
    required this.id,
    required this.data,
  });

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  bool isUpdating = false;

  Future<void> markRead(bool read) async {
    setState(() => isUpdating = true);
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(widget.id)
        .update({'read': read});
    setState(() => isUpdating = false);
  }

  Future<void> deleteNotification() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text(
          'Are you sure you want to delete this notification?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(widget.id)
          .delete();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    // mark read on open (optional). If you don't want auto-mark, comment this out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.data['read'] == false) {
        FirebaseFirestore.instance
            .collection('notifications')
            .doc(widget.id)
            .update({'read': true});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final ts = d['dateTime'] as Timestamp?;
    final dt = ts != null ? ts.toDate().toLocal() : null;
    return Scaffold(
      appBar: AppBar(title: Text(d['title'] ?? 'Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              d['title'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(d['message'] ?? ''),
            const SizedBox(height: 12),
            if (dt != null) Text('Sent at: ${dt.toString()}'),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: isUpdating ? null : () => markRead(true),
                  child: const Text('Mark Read'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: isUpdating ? null : () => markRead(false),
                  child: const Text('Mark Unread'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: deleteNotification,
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
