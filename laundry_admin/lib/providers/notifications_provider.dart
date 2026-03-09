// lib/providers/notifications_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationsCollection = FirebaseFirestore.instance.collection(
  'notifications',
);

final notificationsStreamProvider = StreamProvider.autoDispose((ref) {
  return notificationsCollection
      .orderBy('dateTime', descending: true)
      .snapshots();
});

final notificationsByUserProvider = StreamProvider.family
    .autoDispose<QuerySnapshot<Map<String, dynamic>>, String>((ref, userId) {
      return notificationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('dateTime', descending: true)
          .snapshots();
    });
