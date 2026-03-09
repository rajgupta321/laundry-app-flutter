// lib/features/services/providers/booking_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookingProvider = Provider<BookingService>((ref) {
  return BookingService();
});

class BookingService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Returns the document ID of the newly created booking
  Future<String> bookService({
    required String serviceId,
    required String serviceName,
    required int price,
    required DateTime date,
    required String time,
    Map<String, dynamic>? customerInfo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final docRef = await _firestore.collection('orders').add({
      'userId': user.uid,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'price': price,
      'date': date.toIso8601String(),
      'time': time,
      "customerInfo": customerInfo,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id; // ye ID dialog me dikhayenge
  }
}
