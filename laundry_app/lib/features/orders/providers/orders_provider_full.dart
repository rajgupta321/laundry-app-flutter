// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// /// =====================
// ///   ORDER MODEL
// /// =====================
// class Order {
//   final String id;
//   final String serviceName;
//   final String status;
//   final DateTime dateTime;
//
//   Order({
//     required this.id,
//     required this.serviceName,
//     required this.status,
//     required this.dateTime,
//   });
//
//   factory Order.fromMap(Map<String, dynamic> data, String docId) {
//     // Firestore timestamp field name = createdAt
//     final Timestamp? ts = data['createdAt'];
//
//     return Order(
//       id: docId,
//       serviceName: data['serviceName'] ?? 'Unknown Service',
//       status: data['status'] ?? 'pending',
//       dateTime: ts != null ? ts.toDate() : DateTime.now(),
//     );
//   }
// }
//
// /// =====================
// ///   ORDER PROVIDER
// /// =====================
// final ordersProvider = StreamProvider<List<Order>>((ref) {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) return const Stream.empty();
//
//   return FirebaseFirestore.instance
//       .collection('orders')
//       .where('userId', isEqualTo: user.uid)
//       .orderBy('createdAt', descending: true)
//       .snapshots()
//       .map(
//         (snapshot) => snapshot.docs
//             .map((doc) => Order.fromMap(doc.data(), doc.id))
//             .toList(),
//       );
// });
