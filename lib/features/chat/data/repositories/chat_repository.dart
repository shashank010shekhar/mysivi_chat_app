import '../../../../core/models/message_model.dart' as core;
import '../../../../core/models/chat_session_model.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../../domain/repositories/chat_repository.dart' as domain;

class ChatRepositoryImpl implements domain.ChatRepository {
  final StorageService _storageService = getIt<StorageService>();
  final ApiService _apiService = getIt<ApiService>();

  @override
  Future<List<MessageEntity>> getMessages(String userId) async {
    final messages = await _storageService.getMessages(userId);
    final messageEntities = messages.map((m) => MessageEntity(
          id: m.id,
          userId: m.userId,
          content: m.content,
          type: m.type == core.MessageType.sender
              ? MessageType.sender
              : MessageType.receiver,
          timestamp: m.timestamp,
        )).toList();
    
    // Sort messages by timestamp ascending (oldest first, newest last)
    messageEntities.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return messageEntities;
  }

  @override
  Future<void> sendMessage(String userId, String content) async {
    final messages = await _storageService.getMessages(userId);
    final newMessage = core.MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      content: content,
      type: core.MessageType.sender,
      timestamp: DateTime.now(),
    );
    messages.add(newMessage);
    await _storageService.saveMessages(userId, messages);
  }

  @override
  Future<String> fetchReceiverMessage() async {
    return await _apiService.fetchRandomMessage();
  }

  @override
  Future<void> saveReceiverMessage(String userId, String content) async {
    final messages = await _storageService.getMessages(userId);
    final newMessage = core.MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      content: content,
      type: core.MessageType.receiver,
      timestamp: DateTime.now(),
    );
    messages.add(newMessage);
    await _storageService.saveMessages(userId, messages);
  }

  @override
  Future<List<ChatSessionEntity>> getChatSessions() async {
    final sessions = await _storageService.getChatSessions();
    return Future.wait(sessions.map((s) async {
      // Calculate unread count: count receiver messages after the last sender message
      final messages = await _storageService.getMessages(s.userId);
      int unreadCount = 0;
      
      if (messages.isNotEmpty) {
        // Sort messages by timestamp
        final sortedMessages = List.from(messages)..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        // Find the last sender message timestamp
        DateTime? lastSenderTime;
        for (var msg in sortedMessages.reversed) {
          if (msg.type == core.MessageType.sender) {
            lastSenderTime = msg.timestamp;
            break;
          }
        }
        
        // Count receiver messages after the last sender message
        if (lastSenderTime != null) {
          unreadCount = sortedMessages.where((msg) => 
            msg.type == core.MessageType.receiver && 
            msg.timestamp.isAfter(lastSenderTime!)
          ).length;
        } else {
          // If no sender messages, count all receiver messages
          unreadCount = sortedMessages.where((msg) => 
            msg.type == core.MessageType.receiver
          ).length;
        }
      }
      
      return ChatSessionEntity(
        userId: s.userId,
        userName: s.userName,
        lastMessage: s.lastMessage,
        lastMessageTime: s.lastMessageTime,
        unreadCount: unreadCount,
      );
    }));
  }

  @override
  Future<void> updateChatSession(String userId, String userName, String? lastMessage) async {
    final sessions = await _storageService.getChatSessions();
    final existingIndex = sessions.indexWhere((s) => s.userId == userId);
    
    final updatedSession = ChatSessionModel(
      userId: userId,
      userName: userName,
      lastMessage: lastMessage,
      lastMessageTime: DateTime.now(),
    );

    if (existingIndex >= 0) {
      sessions[existingIndex] = updatedSession;
    } else {
      sessions.add(updatedSession);
    }

    await _storageService.saveChatSessions(sessions);
  }

  @override
  Future<String?> fetchWordMeaning(String word) async {
    return await _apiService.fetchWordMeaning(word);
  }

  @override
  Future<void> markMessagesAsRead(String userId) async {
    final messages = await _storageService.getMessages(userId);
    
    if (messages.isNotEmpty) {
      // Get the latest message timestamp
      final sortedMessages = List.from(messages)..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final latestMessage = sortedMessages.last;
      
      // Send a dummy "read receipt" sender message with current timestamp
      // This ensures that when unread count is calculated, the last sender message
      // will be at least as recent as all receiver messages, making unread count 0
      final readReceiptMessage = core.MessageModel(
        id: 'read_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        content: '', // Empty content, this is just a read marker
        type: core.MessageType.sender,
        timestamp: DateTime.now().isAfter(latestMessage.timestamp) 
            ? DateTime.now() 
            : latestMessage.timestamp.add(const Duration(milliseconds: 1)),
      );
      
      // Check if a read receipt already exists (to avoid duplicates)
      final existingReadReceipt = messages.any((m) => m.id.startsWith('read_'));
      if (!existingReadReceipt) {
        messages.add(readReceiptMessage);
        await _storageService.saveMessages(userId, messages);
      } else {
        // Update existing read receipt timestamp
        final readReceiptIndex = messages.indexWhere((m) => m.id.startsWith('read_'));
        if (readReceiptIndex >= 0) {
          messages[readReceiptIndex] = readReceiptMessage;
          await _storageService.saveMessages(userId, messages);
        }
      }
    }
  }
}

