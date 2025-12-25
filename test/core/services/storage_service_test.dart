import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mysivi_chat_app/core/models/user_model.dart';
import 'package:mysivi_chat_app/core/models/message_model.dart';
import 'package:mysivi_chat_app/core/models/chat_session_model.dart';
import 'package:mysivi_chat_app/core/services/storage_service.dart';

void main() {
  late StorageService storageService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = StorageService();
  });

  group('Users', () {
    test('should return empty list when no users stored', () async {
      // act
      final result = await storageService.getUsers();

      // assert
      expect(result, isEmpty);
    });

    test('should save and retrieve users', () async {
      // arrange
      final users = [
        UserModel(
          id: '1',
          name: 'John Doe',
          createdAt: DateTime.now(),
        ),
      ];

      // act
      await storageService.saveUsers(users);
      final result = await storageService.getUsers();

      // assert
      expect(result.length, 1);
      expect(result[0].name, 'John Doe');
    });
  });

  group('Messages', () {
    test('should return empty list when no messages stored', () async {
      // act
      final result = await storageService.getMessages('user1');

      // assert
      expect(result, isEmpty);
    });

    test('should save and retrieve messages', () async {
      // arrange
      const userId = 'user1';
      final messages = [
        MessageModel(
          id: '1',
          userId: userId,
          content: 'Hello',
          type: MessageType.sender,
          timestamp: DateTime.now(),
        ),
      ];

      // act
      await storageService.saveMessages(userId, messages);
      final result = await storageService.getMessages(userId);

      // assert
      expect(result.length, 1);
      expect(result[0].content, 'Hello');
    });
  });

  group('Chat Sessions', () {
    test('should return empty list when no sessions stored', () async {
      // act
      final result = await storageService.getChatSessions();

      // assert
      expect(result, isEmpty);
    });

    test('should save and retrieve chat sessions', () async {
      // arrange
      final sessions = [
        ChatSessionModel(
          userId: 'user1',
          userName: 'John Doe',
          lastMessage: 'Hello',
          lastMessageTime: DateTime.now(),
        ),
      ];

      // act
      await storageService.saveChatSessions(sessions);
      final result = await storageService.getChatSessions();

      // assert
      expect(result.length, 1);
      expect(result[0].userName, 'John Doe');
    });
  });
}

