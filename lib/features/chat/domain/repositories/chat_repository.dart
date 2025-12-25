import '../entities/message_entity.dart';
import '../entities/chat_session_entity.dart';

abstract class ChatRepository {
  Future<List<MessageEntity>> getMessages(String userId);
  Future<void> sendMessage(String userId, String content);
  Future<String> fetchReceiverMessage();
  Future<void> saveReceiverMessage(String userId, String content);
  Future<List<ChatSessionEntity>> getChatSessions();
  Future<void> updateChatSession(String userId, String userName, String? lastMessage);
  Future<void> markMessagesAsRead(String userId);
  
  Future<String?> fetchWordMeaning(String word);
}

