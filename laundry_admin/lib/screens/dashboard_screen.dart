import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/orders_provider.dart';
import '../providers/users_provider.dart';
import '../widgets/dashboard_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () => context.push('/sendNotification'),
              icon: Icon(Icons.notification_add),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Stats Cards Section
            ordersAsync.when(
              data: (ordersSnapshot) {
                final totalOrders = ordersSnapshot.docs.length;
                final pending = ordersSnapshot.docs
                    .where((e) => e['status'] == 'pending')
                    .length;
                final picked = ordersSnapshot.docs
                    .where((e) => e['status'] == 'picked')
                    .length;
                final delivered = ordersSnapshot.docs
                    .where((e) => e['status'] == 'delivered')
                    .length;
                final cancelled = ordersSnapshot.docs
                    .where((e) => e['status'] == 'cancelled')
                    .length;

                return GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 600
                      ? 3
                      : 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    DashboardCard(
                      title: 'Total Orders',
                      value: totalOrders.toString(),
                      color: Colors.blue,
                    ),
                    DashboardCard(
                      title: 'Pending',
                      value: pending.toString(),
                      color: Colors.orange,
                    ),
                    DashboardCard(
                      title: 'Picked',
                      value: picked.toString(),
                      color: Colors.purple,
                    ),
                    DashboardCard(
                      title: 'Delivered',
                      value: delivered.toString(),
                      color: Colors.green,
                    ),
                    DashboardCard(
                      title: 'Cancelled',
                      value: cancelled.toString(),
                      color: Colors.red,
                    ),
                    usersAsync.when(
                      data: (usersSnapshot) {
                        final totalUsers = usersSnapshot.docs.length;
                        return DashboardCard(
                          title: 'Total Users',
                          value: totalUsers.toString(),
                          color: Colors.teal,
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),

            const SizedBox(height: 40),

            // Quick Navigation Cards
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              shrinkWrap: true,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                DashboardCard(
                  title: 'Orders',
                  value: '',
                  color: Colors.blue,
                  onTap: () => context.push('/orders'),
                ),
                DashboardCard(
                  title: 'Users',
                  value: '',
                  color: Colors.teal,
                  onTap: () => context.push('/users'),
                ),
                DashboardCard(
                  title: 'Notifications',
                  value: '',
                  color: Colors.orange,
                  onTap: () => context.push('/notifications'),
                ),
                DashboardCard(
                  title: 'Chat',
                  value: '',
                  color: Colors.purple,
                  onTap: () {
                    context.push('/selectUserForChat');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
