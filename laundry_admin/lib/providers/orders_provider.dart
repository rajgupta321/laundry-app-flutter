// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// final ordersProvider = StreamProvider((ref) {
//   return FirebaseFirestore.instance
//       .collection('orders')
//       .orderBy('createdAt', descending: true)
//       .snapshots();
// });

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ordersProvider = StreamProvider.autoDispose((ref) {
  return FirebaseFirestore.instance
      .collection('orders')
      .orderBy('createdAt', descending: true)
      .snapshots();
});
