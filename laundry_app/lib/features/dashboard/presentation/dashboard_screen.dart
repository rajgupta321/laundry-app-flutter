// UI-only enhanced version of your DashboardScreen
// ⚠️ Logic, providers, navigation untouched

import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/orders_provider_dashboard.dart';
import '../../auth/providers/user_provider.dart';
import '../../customer_info/providers/customer_info_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final size = MediaQuery.of(context).size;
    final customerInfo = ref.watch(customerInfoProvider);

    final userName =
        (customerInfo == null ||
            customerInfo['name'] == null ||
            customerInfo['name'].toString().trim().isEmpty)
        ? 'Hello, User'
        : customerInfo['name'];

    final ordersAsync = ref.watch(ordersProvider);
    final userDataAsync = ref.watch(userDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: ordersAsync.when(
        data: (orders) {
          final total = orders.length;
          final delivered = orders.where((o) => o.status == 'delivered').length;
          final pending = orders.where((o) => o.status == 'pending').length;
          final cancelled = orders.where((o) => o.status == 'cancelled').length;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // HEADER
                Container(
                  width: size.width,
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF3F3CFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.push('/notification'),
                            icon: const Icon(
                              Icons.notifications_active,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // PROFILE CARD
                      InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => context.push('/profile'),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 34,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        userDataAsync.when(
                                          data: (_) {
                                            final house =
                                                customerInfo?['house'];
                                            final area = customerInfo?['area'];
                                            final city = customerInfo?['city'];
                                            final state =
                                                customerInfo?['state'];
                                            final pincode =
                                                customerInfo?['pincode'];

                                            final isEmpty =
                                                (house == null ||
                                                    house.isEmpty) &&
                                                (area == null ||
                                                    area.isEmpty) &&
                                                (city == null ||
                                                    city.isEmpty) &&
                                                (state == null ||
                                                    state.isEmpty) &&
                                                (pincode == null ||
                                                    pincode.isEmpty);

                                            final address = isEmpty
                                                ? 'Save Address'
                                                : '$house, $area, $city';

                                            return Text(
                                              address,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: isEmpty
                                                    ? Colors.amberAccent
                                                    : Colors.white70,
                                                fontWeight: isEmpty
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            );
                                          },
                                          loading: () => const Text(
                                            'Loading address...',
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                          error: (_, __) => const Text(
                                            'Address unavailable',
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user?.phoneNumber ?? '+91 XXXXXXXX',
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirm Logout'),
                                          content: const Text(
                                            'Are you sure you want to log out?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Logout'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await FirebaseAuth.instance.signOut();
                                        ref.invalidate(customerInfoProvider);
                                        ref.invalidate(userDataProvider);
                                        ref.invalidate(ordersProvider);
                                        SystemNavigator.pop();
                                      }
                                    },
                                    child: const Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ORDER SUMMARY
                _SectionTitle(title: 'Your Orders Summary'),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.25,
                        ),
                    children: [
                      _StatCard(
                        label: 'Total Orders',
                        value: '$total',
                        color: const Color(0xFF6C63FF),
                      ),
                      _StatCard(
                        label: 'Delivered',
                        value: '$delivered',
                        color: Colors.green,
                      ),
                      _StatCard(
                        label: 'Pending',
                        value: '$pending',
                        color: Colors.orange,
                      ),
                      _StatCard(
                        label: 'Cancelled',
                        value: '$cancelled',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // QUICK ACTIONS
                _SectionTitle(title: 'Quick Actions'),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ActionCard(
                        title: 'Book Service',
                        icon: Icons.add_circle_outline,
                        onTap: () => context.push('/services'),
                      ),
                      _ActionCard(
                        title: 'My Orders',
                        icon: Icons.receipt_long,
                        onTap: () => context.push('/ordersList'),
                      ),
                      _ActionCard(
                        title: 'Support',
                        icon: Icons.support_agent,
                        onTap: () => context.push('/chat'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

// ------------------ UI COMPONENTS ------------------

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 14)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Color(0x14000000), blurRadius: 12),
              ],
            ),
            child: Icon(icon, size: 30, color: Colors.deepPurple),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
