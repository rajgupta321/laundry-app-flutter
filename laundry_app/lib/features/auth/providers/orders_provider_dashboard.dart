import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Order model for Dashboard
class DashboardOrder {
  final String id;
  final String status;

  DashboardOrder({required this.id, required this.status});

  factory DashboardOrder.fromMap(Map<String, dynamic> data, String docId) {
    return DashboardOrder(id: docId, status: data['status'] ?? 'pending');
  }
}

/// Order model for OrdersList & OrderDetails
class FullOrder {
  final String id;
  final String serviceName;
  final String status;
  final DateTime dateTime;
  final Map<String, dynamic>? customerInfo;

  FullOrder({
    required this.id,
    required this.serviceName,
    required this.status,
    required this.dateTime,
    this.customerInfo,
  });

  factory FullOrder.fromMap(Map<String, dynamic> data, String docId) {
    return FullOrder(
      id: docId,
      serviceName: data['serviceName'] ?? 'Unknown Service',
      status: data['status'] ?? 'pending',
      dateTime: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      customerInfo: data['customerInfo'] != null
          ? Map<String, dynamic>.from(data['customerInfo'])
          : null,
    );
  }
}

/// Provider for Dashboard
final dashboardOrdersProvider = StreamProvider<List<DashboardOrder>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('orders')
      .where('userId', isEqualTo: user.uid)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => DashboardOrder.fromMap(doc.data(), doc.id))
            .toList(),
      );
});

/// Provider for OrdersList & OrderDetails
final ordersProvider = StreamProvider<List<FullOrder>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('orders')
      .where('userId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => FullOrder.fromMap(doc.data(), doc.id))
            .toList(),
      );
});
