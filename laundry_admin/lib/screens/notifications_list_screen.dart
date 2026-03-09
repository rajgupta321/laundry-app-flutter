// lib/screens/notifications/notifications_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/notifications_provider.dart';
import '../../providers/users_provider.dart';

class NotificationsListScreen extends ConsumerStatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  ConsumerState<NotificationsListScreen> createState() =>
      _NotificationsListScreenState();
}

class _NotificationsListScreenState
    extends ConsumerState<NotificationsListScreen> {
  String userFilter = 'ALL';
  String readFilter = 'ALL'; // ALL / READ / UNREAD
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final allNotifs = ref.watch(notificationsStreamProvider);
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filters row
            Row(
              children: [
                Expanded(
                  child: usersAsync.when(
                    data: (snap) {
                      final items = <DropdownMenuItem<String>>[
                        const DropdownMenuItem(
                          value: 'ALL',
                          child: Text('All Users'),
                        ),
                      ];
                      for (final d in snap.docs) {
                        items.add(
                          DropdownMenuItem(
                            value: d.id,
                            child: Text(d['name'] ?? d.id),
                          ),
                        );
                      }
                      return DropdownButtonFormField<String>(
                        value: userFilter,
                        items: items,
                        onChanged: (v) =>
                            setState(() => userFilter = v ?? 'ALL'),
                        decoration: const InputDecoration(
                          labelText: 'Filter by user',
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                    loading: () => const SizedBox(
                      height: 56,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: readFilter,
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('All')),
                    DropdownMenuItem(value: 'READ', child: Text('Read')),
                    DropdownMenuItem(value: 'UNREAD', child: Text('Unread')),
                  ],
                  onChanged: (v) => setState(() => readFilter = v ?? 'ALL'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search title or message',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) =>
                        setState(() => searchText = v.toLowerCase()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // List
            Expanded(
              child: allNotifs.when(
                data: (snap) {
                  final docs = snap.docs.where((d) {
                    final matchesUser = (userFilter == 'ALL')
                        ? true
                        : d['userId'] == userFilter;
                    final matchesRead = (readFilter == 'ALL')
                        ? true
                        : (readFilter == 'READ'
                              ? (d['read'] == true)
                              : (d['read'] == false));
                    final t = (d['title'] ?? '').toString().toLowerCase();
                    final m = (d['message'] ?? '').toString().toLowerCase();
                    final matchesSearch = (searchText.isEmpty)
                        ? true
                        : (t.contains(searchText) || m.contains(searchText));
                    return matchesUser && matchesRead && matchesSearch;
                  }).toList();

                  if (docs.isEmpty)
                    return const Center(child: Text('No notifications found'));

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final d = docs[index];
                      final ts = d['dateTime'] as Timestamp?;
                      final dt = ts != null
                          ? ts.toDate().toLocal().toString()
                          : '—';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(d['title'] ?? ''),
                          subtitle: Text(
                            '${d['message'] ?? ''}\nUser: ${d['userId']}\n$dt',
                          ),
                          isThreeLine: true,
                          trailing: d['read'] == true
                              ? const Icon(Icons.mark_email_read)
                              : const Icon(Icons.mark_email_unread),
                          onTap: () {
                            // navigate to detail
                            context.go(
                              '/notificationDetail',
                              extra: {'id': d.id, 'data': d.data()},
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
