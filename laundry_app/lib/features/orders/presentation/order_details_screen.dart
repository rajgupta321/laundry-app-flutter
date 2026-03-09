import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/orders_provider_dashboard.dart';

class OrderDetailsScreen extends StatelessWidget {
  final FullOrder order;
  const OrderDetailsScreen({required this.order, super.key});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'in progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  List<_TimelineData> getTimelineData(String status) {
    return [
      _TimelineData(
        title: 'Order Placed',
        icon: Icons.check,
        color: Colors.deepPurple,
        done: true,
      ),
      _TimelineData(
        title: 'In Progress',
        icon: status.toLowerCase() == 'pending' ? Icons.circle : Icons.check,
        color: status.toLowerCase() == 'pending' ? Colors.grey : Colors.blue,
        done:
            status.toLowerCase() != 'pending' &&
            status.toLowerCase() != 'cancelled',
      ),
      _TimelineData(
        title: 'Completed',
        icon: status.toLowerCase() == 'delivered'
            ? Icons.check
            : status.toLowerCase() == 'cancelled'
            ? Icons.close
            : Icons.circle,
        color: status.toLowerCase() == 'delivered'
            ? Colors.green
            : status.toLowerCase() == 'cancelled'
            ? Colors.red
            : Colors.grey,
        done: status.toLowerCase() == 'delivered',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final timeline = getTimelineData(order.status);
    final customer = order.customerInfo;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              width: size.width,
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 30,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3F3CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Text(
                "Order Details",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ORDER CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SERVICE NAME + STATUS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.serviceName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple.shade800,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: getStatusColor(order.status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ORDER ID + COPY BUTTON
                        Row(
                          children: [
                            Text(
                              'Order ID: ${order.id}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: order.id),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.deepPurple,
                                    content: Text(
                                      'Order ID copied to clipboard',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.copy,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // DATE & TIME
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat(
                                'dd MMM yyyy, hh:mm a',
                              ).format(order.dateTime),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // TIMELINE + CUSTOMER INFO
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LEFT SIDE - TIMELINE
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: List.generate(timeline.length, (
                                  index,
                                ) {
                                  final item = timeline[index];
                                  return _TimelineTile(
                                    title: item.title,
                                    color: item.color,
                                    icon: item.icon,
                                    done: item.done,
                                    isLast: index == timeline.length - 1,
                                  );
                                }),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // RIGHT SIDE - CUSTOMER INFO
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer?['name'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      customer?['phone1'] ?? 'No Number',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${customer?['house'] ?? ''}, ${customer?['area'] ?? ''}, ${customer?['city'] ?? ''}, ${customer?['state'] ?? ''} - ${customer?['pincode'] ?? ''}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// TIMELINE TILE WIDGET
class _TimelineTile extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final bool done;
  final bool isLast;

  const _TimelineTile({
    required this.title,
    required this.color,
    required this.icon,
    required this.done,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 14),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: done ? color : Colors.grey.shade400,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: done ? FontWeight.w600 : FontWeight.normal,
              color: done ? Colors.black87 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

// TIMELINE DATA
class _TimelineData {
  final String title;
  final IconData icon;
  final Color color;
  final bool done;

  _TimelineData({
    required this.title,
    required this.icon,
    required this.color,
    required this.done,
  });
}
