import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/chat_model.dart';
import '../data/chat_repository.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository());

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((
  ref,
  userId,
) {
  return ref.read(chatRepositoryProvider).getMessages(userId);
});

final chatControllerProvider = Provider((ref) {
  final repo = ref.read(chatRepositoryProvider);
  return ChatController(repo: repo);
});

class ChatController {
  final ChatRepository repo;

  ChatController({required this.repo});

  Future<void> sendMessage({
    required String userId,
    required String senderId,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;
    await repo.sendMessage(
      userId: userId,
      senderId: senderId,
      message: message,
    );
  }

  // Send a test admin message
  Future<void> sendTestAdminMessage(String customerUid) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(customerUid)
        .collection('messages')
        .add({
          'senderId': 'admin',
          'message': 'Hello! How can I help you?',
          'timestamp': FieldValue.serverTimestamp(),
        });
  }
}
