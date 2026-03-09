import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.orderData,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.orderData["status"];
  }

  String getStatusMessage(String status) {
    switch (status) {
      case "picked":
        return "Your order has been picked up.";
      case "in-process":
        return "Your order is now being processed.";
      case "delivered":
        return "Your order has been delivered.";
      case "cancelled":
        return "Your order has been cancelled.";
      default:
        return "Your order status has been updated.";
    }
  }

  Future<void> updateStatus() async {
    final userId = widget.orderData["userId"];

    await FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderId)
        .update({"status": selectedStatus});

    await FirebaseFirestore.instance.collection("notifications").add({
      "userId": userId,
      "title": "Order Status Updated",
      "message": getStatusMessage(selectedStatus!),
      "read": false,
      "dateTime": Timestamp.now(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order updated & notification sent!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.orderData;
    final isTablet = MediaQuery.of(context).size.width > 600;

    final titleStyle = TextStyle(
      fontSize: isTablet ? 24 : 20,
      fontWeight: FontWeight.bold,
    );
    final normalStyle = TextStyle(
      fontSize: isTablet ? 18 : 16,
      color: Colors.black87,
    );

    // Null-safe customerInfo
    final customerInfoRaw = data['customerInfo'];
    final Map<String, dynamic> customerInfo =
        (customerInfoRaw is Map<String, dynamic>) ? customerInfoRaw : {};

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              final userName = customerInfo['name'] ?? "User";
              context.push(
                '/chat',
                extra: {'userId': data['userId'], 'userName': userName},
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 30 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order ID: ${widget.orderId}",
                  style: titleStyle.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Order Summary
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Service: ${data['serviceName']}",
                          style: titleStyle,
                        ),
                        const SizedBox(height: 15),
                        Text("Date: ${data['date']}", style: normalStyle),
                        SizedBox(height: isTablet ? 10 : 8),
                        Text("Time: ${data['time']}", style: normalStyle),
                        SizedBox(height: isTablet ? 10 : 8),
                        Text("Price: ₹${data['price']}", style: normalStyle),
                        SizedBox(height: isTablet ? 10 : 8),
                        Text("User ID: ${data['userId']}", style: normalStyle),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Customer Info
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: customerInfo.isEmpty
                        ? Text("No customer info available", style: normalStyle)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Customer Info", style: titleStyle),
                              const SizedBox(height: 15),
                              Text(
                                "Name: ${customerInfo['name'] ?? '-'}",
                                style: normalStyle,
                              ),
                              SizedBox(height: isTablet ? 10 : 6),
                              Text(
                                "Phone1: ${customerInfo['phone1'] ?? '-'}",
                                style: normalStyle,
                              ),
                              if ((customerInfo['phone2'] ?? '').isNotEmpty)
                                Text(
                                  "Phone2: ${customerInfo['phone2']}",
                                  style: normalStyle,
                                ),
                              if ((customerInfo['email'] ?? '').isNotEmpty)
                                Text(
                                  "Email: ${customerInfo['email']}",
                                  style: normalStyle,
                                ),
                              SizedBox(height: isTablet ? 10 : 6),
                              Text(
                                "Address: ${customerInfo['house'] ?? ''}, ${customerInfo['area'] ?? ''}, ${customerInfo['city'] ?? ''}, ${customerInfo['state'] ?? ''} - ${customerInfo['pincode'] ?? ''}",
                                style: normalStyle,
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                // Update Status
                Text(
                  "Update Order Status",
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 16 : 12,
                      horizontal: isTablet ? 18 : 14,
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Order Status",
                      ),
                      items:
                          [
                                "pending",
                                "picked",
                                "in-process",
                                "delivered",
                                "cancelled",
                              ]
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() => selectedStatus = value);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 55 : 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: updateStatus,
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
