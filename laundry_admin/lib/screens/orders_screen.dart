import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/orders_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String selectedFilter = "all";
  String searchQuery = ""; // for search bar

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Orders Management")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;

              return Column(
                children: [
                  // SEARCH BAR
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search by Order ID",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                        vertical: isTablet ? 16 : 12,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val.trim();
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // FILTER BUTTONS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        filterButton("all", isTablet),
                        filterButton("pending", isTablet),
                        filterButton("picked", isTablet),
                        filterButton("delivered", isTablet),
                        filterButton("cancelled", isTablet),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ORDERS LIST
                  Expanded(
                    child: ordersAsync.when(
                      data: (snapshot) {
                        final docs = snapshot.docs.where((order) {
                          final matchesFilter =
                              selectedFilter == "all" ||
                              order['status'] == selectedFilter;
                          final matchesSearch =
                              searchQuery.isEmpty ||
                              order.id.toLowerCase().contains(
                                searchQuery.toLowerCase(),
                              );
                          return matchesFilter && matchesSearch;
                        }).toList();

                        if (docs.isEmpty) {
                          return const Center(child: Text("No orders found"));
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data();

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: isTablet ? 4 : 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 24 : 16,
                                  vertical: isTablet ? 16 : 10,
                                ),
                                title: Text(
                                  "${data['serviceName']}",
                                  style: TextStyle(
                                    fontSize: isTablet ? 20 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    "Order ID: ${docs[index].id}\n"
                                    "Date: ${data['date']} • Time: ${data['time']}\n"
                                    "Status: ${data['status']}",
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: isTablet ? 20 : 16,
                                ),
                                onTap: () {
                                  context.push(
                                    '/orderDetails',
                                    extra: {
                                      'id': docs[index].id,
                                      'serviceName': data['serviceName'],
                                      'status': data['status'],
                                      'date': data['date'],
                                      'time': data['time'],
                                      'price': data['price'],
                                      'userId': data['userId'],
                                      'customerInfo':
                                          data['customerInfo'] ?? {},
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text("Error: $e")),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // FILTER BUTTON WIDGET
  Widget filterButton(String status, bool isTablet) {
    bool active = selectedFilter == status;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? Colors.blue : Colors.grey.shade300,
        foregroundColor: active ? Colors.white : Colors.black,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 28 : 20,
          vertical: isTablet ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () {
        setState(() {
          selectedFilter = status;
        });
      },
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isTablet ? 18 : 14,
        ),
      ),
    );
  }
}
