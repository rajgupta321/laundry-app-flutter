import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usersProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance.collection('users').snapshots();
});
