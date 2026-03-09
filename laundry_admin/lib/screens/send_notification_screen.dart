// lib/screens/notifications/send_notification_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/users_provider.dart';

// Reuse users_provider (we created earlier). If not present, create same as orders_provider style.
// final usersProvider = StreamProvider(...)

class SendNotificationScreen extends ConsumerStatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  ConsumerState<SendNotificationScreen> createState() =>
      _SendNotificationScreenState();
}

class _SendNotificationScreenState
    extends ConsumerState<SendNotificationScreen> {
  final titleCtrl = TextEditingController();
  final messageCtrl = TextEditingController();
  String selectedUserId = 'ALL'; // 'ALL' => broadcast
  bool isSending = false;

  @override
  void dispose() {
    titleCtrl.dispose();
    messageCtrl.dispose();
    super.dispose();
  }

  Future<void> sendToSingleUser(String userId) async {
    final doc = FirebaseFirestore.instance.collection('notifications').doc();
    await doc.set({
      'title': titleCtrl.text.trim(),
      'message': messageCtrl.text.trim(),
      'dateTime': FieldValue.serverTimestamp(),
      'read': false,
      'userId': userId,
    });
    // Optional: trigger FCM sending by Cloud Function when doc created (see notes below)
  }

  Future<void> broadcastToAllUsers() async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    final users = usersSnapshot.docs;
    if (users.isEmpty) return;

    // Firestore batch limit = 500 operations per batch.
    // We'll chunk into groups of 450 for safety.
    const int chunkSize = 450;
    final int total = users.length;
    int idx = 0;

    while (idx < total) {
      final batch = FirebaseFirestore.instance.batch();
      final end = (idx + chunkSize) > total ? total : (idx + chunkSize);
      for (int i = idx; i < end; i++) {
        final u = users[i];
        final doc = FirebaseFirestore.instance
            .collection('notifications')
            .doc();
        batch.set(doc, {
          'title': titleCtrl.text.trim(),
          'message': messageCtrl.text.trim(),
          'dateTime': FieldValue.serverTimestamp(),
          'read': false,
          'userId': u.id,
        });
      }
      await batch.commit();
      idx = end;
    }

    // Optional: if you want to send a single broadcast push via topics, call Cloud Function here
  }

  Future<void> onSendPressed() async {
    if (titleCtrl.text.trim().isEmpty || messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and message')),
      );
      return;
    }
    setState(() => isSending = true);
    try {
      if (selectedUserId == 'ALL') {
        await broadcastToAllUsers();
      } else {
        await sendToSingleUser(selectedUserId);
      }
      titleCtrl.clear();
      messageCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification sent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User selector
            usersAsync.when(
              data: (snap) {
                final items = <DropdownMenuItem<String>>[
                  const DropdownMenuItem(
                    value: 'ALL',
                    child: Text('All Users'),
                  ),
                ];
                for (final doc in snap.docs) {
                  final name = doc['name'] ?? doc.id;
                  items.add(DropdownMenuItem(value: doc.id, child: Text(name)));
                }
                return DropdownButtonFormField<String>(
                  value: selectedUserId,
                  items: items,
                  onChanged: (v) {
                    setState(() => selectedUserId = v ?? 'ALL');
                  },
                  decoration: const InputDecoration(
                    labelText: 'Send to',
                    border: OutlineInputBorder(),
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: messageCtrl,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSending ? null : onSendPressed,
                child: isSending
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Send Notification'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
