import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_model.dart';

class ChatRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<ChatMessage>> getMessages(String userId) {
    return firestore
        .collection("chats")
        .doc(userId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChatMessage.fromDoc(doc)).toList(),
        );
  }

  Future<void> sendMessage({
    required String userId,
    required String senderId,
    required String message,
  }) async {
    await firestore
        .collection("chats")
        .doc(userId)
        .collection("messages")
        .add(
          ChatMessage(
            id: "",
            senderId: senderId,
            message: message,
            timestamp: DateTime.now(),
          ).toMap(),
        );
  }
}
