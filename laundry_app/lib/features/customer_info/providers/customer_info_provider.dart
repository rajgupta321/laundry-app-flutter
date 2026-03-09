// lib/features/customer_info/providers/customer_info_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';

final customerInfoProvider =
    StateNotifierProvider<CustomerInfoNotifier, Map<String, dynamic>?>(
      (ref) => CustomerInfoNotifier()..loadCustomerInfo(), // ⭐ FIX
    );

class CustomerInfoNotifier extends StateNotifier<Map<String, dynamic>?> {
  CustomerInfoNotifier() : super(null);

  final uid = FirebaseAuth.instance.currentUser?.uid;
  final users = FirebaseFirestore.instance.collection("users");

  /// Load user profile
  Future<void> loadCustomerInfo() async {
    if (uid == null) return;

    final snap = await users.doc(uid).get();

    if (snap.exists) {
      state = snap.data();
    }
  }

  /// Save / Update Customer Info (Name, Number, Address etc.)
  Future<void> saveCustomerInfo(Map<String, dynamic> data) async {
    if (uid == null) return;

    final docRef = users.doc(uid);
    final existing = await docRef.get();

    if (!existing.exists) {
      await docRef.set({
        ...data,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.set({
        ...data,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    state = {...?state, ...data};
  }

  /// ⭐ UPDATE ONLY PROFILE IMAGE (from Profile Screen)
  Future<void> updateProfileImage(String imageUrl) async {
    if (uid == null) return;

    final docRef = users.doc(uid);

    await docRef.set({
      "imageUrl": imageUrl,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Update state without touching other fields
    state = {...?state, "imageUrl": imageUrl};
  }
}
