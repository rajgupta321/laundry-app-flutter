// lib/features/notifications/providers/notifications_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_model.dart';

final notificationsProvider = StreamProvider<List<NotificationItem>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .orderBy('dateTime', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => NotificationItem.fromMap(doc.id, doc.data()))
            .toList(),
      );
});
