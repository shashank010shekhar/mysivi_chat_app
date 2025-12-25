import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mysivi_chat_app/core/services/storage_service.dart';
import 'package:mysivi_chat_app/core/services/api_service.dart';
import 'package:mysivi_chat_app/core/di/injection_container.dart';
import 'package:mysivi_chat_app/features/users/data/repositories/users_repository.dart';
import 'package:mysivi_chat_app/features/users/domain/usecases/get_users_usecase.dart';
import 'package:mysivi_chat_app/features/chat/data/repositories/chat_repository.dart';
import 'package:mysivi_chat_app/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:mysivi_chat_app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:mysivi_chat_app/features/chat/domain/usecases/get_chat_sessions_usecase.dart';
import 'package:mysivi_chat_app/features/users/domain/repositories/users_repository.dart' as users_domain;
import 'package:mysivi_chat_app/features/chat/domain/repositories/chat_repository.dart' as chat_domain;

/// Integration test for complete chat flow
/// Tests the interaction between multiple layers without breaking architecture
void main() {
  late StorageService storageService;
  late ApiService apiService;
  late UsersRepositoryImpl usersRepository;
  late ChatRepositoryImpl chatRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    
    // Initialize services
    storageService = StorageService();
    apiService = ApiService();
    
    // Register in GetIt for dependency injection
    if (getIt.isRegistered<StorageService>()) {
      getIt.unregister<StorageService>();
    }
    if (getIt.isRegistered<ApiService>()) {
      getIt.unregister<ApiService>();
    }
    
    getIt.registerSingleton<StorageService>(storageService);
    getIt.registerSingleton<ApiService>(apiService);
    
    // Initialize repositories
    usersRepository = UsersRepositoryImpl();
    chatRepository = ChatRepositoryImpl();
  });

  tearDown(() {
    if (getIt.isRegistered<StorageService>()) {
      getIt.unregister<StorageService>();
    }
    if (getIt.isRegistered<ApiService>()) {
      getIt.unregister<ApiService>();
    }
  });

  group('Complete Chat Flow Integration Tests', () {
    test('should add user, send message, and retrieve chat session', () async {
      // Arrange
      const userId = 'user123';
      const userName = 'John Doe';
      const messageContent = 'Hello, world!';

      // Act - Add user
      await usersRepository.addUser(userName);
      final getUsersUseCase = GetUsersUseCase(usersRepository as users_domain.UsersRepository);
      final users = await getUsersUseCase();
      
      expect(users.isNotEmpty, true);
      expect(users.any((u) => u.name == userName), true);

      // Act - Send message
      final sendMessageUseCase = SendMessageUseCase(chatRepository as chat_domain.ChatRepository);
      await sendMessageUseCase(userId, messageContent);
      
      // Act - Update chat session
      await chatRepository.updateChatSession(userId, userName, messageContent);

      // Act - Get messages
      final getMessagesUseCase = GetMessagesUseCase(chatRepository as chat_domain.ChatRepository);
      final messages = await getMessagesUseCase(userId);
      
      expect(messages.isNotEmpty, true);
      expect(messages.any((m) => m.content == messageContent), true);

      // Act - Get chat sessions
      final getChatSessionsUseCase = GetChatSessionsUseCase(chatRepository as chat_domain.ChatRepository);
      final sessions = await getChatSessionsUseCase();
      
      expect(sessions.isNotEmpty, true);
      expect(sessions.any((s) => s.userId == userId), true);
    });

    test('should handle multiple messages in a conversation', () async {
      // Arrange
      const userId = 'user456';
      const userName = 'Jane Smith';
      final messages = ['Hello', 'How are you?', 'Goodbye'];

      // Act - Send multiple messages
      final sendMessageUseCase = SendMessageUseCase(chatRepository as chat_domain.ChatRepository);
      for (final message in messages) {
        await sendMessageUseCase(userId, message);
        await chatRepository.updateChatSession(userId, userName, message);
      }

      // Act - Retrieve all messages
      final getMessagesUseCase = GetMessagesUseCase(chatRepository as chat_domain.ChatRepository);
      final retrievedMessages = await getMessagesUseCase(userId);

      // Assert
      expect(retrievedMessages.length, messages.length);
      for (var i = 0; i < messages.length; i++) {
        expect(retrievedMessages[i].content, messages[i]);
      }
    });

    test('should maintain data persistence across operations', () async {
      // Arrange
      const userId = 'user789';
      const userName = 'Test User';
      const message = 'Persistent message';

      // Act - Create and save data
      await usersRepository.addUser(userName);
      final sendMessageUseCase = SendMessageUseCase(chatRepository as chat_domain.ChatRepository);
      await sendMessageUseCase(userId, message);
      await chatRepository.updateChatSession(userId, userName, message);

      // Act - Create new instances (simulating app restart)
      final newStorageService = StorageService();
      if (getIt.isRegistered<StorageService>()) {
        getIt.unregister<StorageService>();
      }
      getIt.registerSingleton<StorageService>(newStorageService);
      final newUsersRepository = UsersRepositoryImpl();
      final newChatRepository = ChatRepositoryImpl();

      // Act - Retrieve data with new instances
      final getUsersUseCase = GetUsersUseCase(newUsersRepository as users_domain.UsersRepository);
      final users = await getUsersUseCase();
      
      final getMessagesUseCase = GetMessagesUseCase(newChatRepository as chat_domain.ChatRepository);
      final retrievedMessages = await getMessagesUseCase(userId);

      // Assert - Data should persist
      expect(users.isNotEmpty, true);
      expect(retrievedMessages.isNotEmpty, true);
      expect(retrievedMessages.any((m) => m.content == message), true);
    });
  });
}

