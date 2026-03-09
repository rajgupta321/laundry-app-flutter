// lib/features/services/providers/services_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/service_model.dart';

final servicesProvider = StreamProvider<List<Service>>((ref) {
  return FirebaseFirestore.instance
      .collection('services')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Service.fromMap(doc.data(), doc.id))
            .toList(),
      );
});
