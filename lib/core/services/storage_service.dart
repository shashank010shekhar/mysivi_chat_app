import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../models/chat_session_model.dart';
import '../errors/app_exceptions.dart';
import '../errors/error_handler.dart';

class StorageService {
  static const String _usersKey = 'users';
  static const String _messagesKey = 'messages';
  static const String _chatSessionsKey = 'chat_sessions';

  Future<List<UserModel>> getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      if (usersJson == null) return [];

      final List<dynamic> usersList = json.decode(usersJson);
      return usersList
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on FormatException {
      // Invalid JSON - return empty list gracefully
      // Could also clear corrupted data here
      return [];
    } catch (_) {
      // For storage read errors, return empty list gracefully
      // This allows the app to continue functioning
      return [];
    }
  }

  Future<void> saveUsers(List<UserModel> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = json.encode(users.map((u) => u.toJson()).toList());
      final success = await prefs.setString(_usersKey, usersJson);
      if (!success) {
        throw const StorageWriteException();
      }
    } catch (e) {
      // Re-throw as AppException for proper handling
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handleError(e);
    }
  }

  Future<List<MessageModel>> getMessages(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('$_messagesKey$userId');
      if (messagesJson == null) return [];

      final List<dynamic> messagesList = json.decode(messagesJson);
      return messagesList
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on FormatException {
      // Invalid JSON - return empty list gracefully
      return [];
    } catch (_) {
      // For storage read errors, return empty list gracefully
      return [];
    }
  }

  Future<void> saveMessages(String userId, List<MessageModel> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = json.encode(messages.map((m) => m.toJson()).toList());
      final success = await prefs.setString('$_messagesKey$userId', messagesJson);
      if (!success) {
        throw const StorageWriteException();
      }
    } catch (e) {
      // Re-throw as AppException for proper handling
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handleError(e);
    }
  }

  Future<List<ChatSessionModel>> getChatSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_chatSessionsKey);
      if (sessionsJson == null) return [];

      final List<dynamic> sessionsList = json.decode(sessionsJson);
      return sessionsList
          .map((json) => ChatSessionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on FormatException {
      // Invalid JSON - return empty list gracefully
      return [];
    } catch (_) {
      // For storage read errors, return empty list gracefully
      return [];
    }
  }

  Future<void> saveChatSessions(List<ChatSessionModel> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = json.encode(sessions.map((s) => s.toJson()).toList());
      final success = await prefs.setString(_chatSessionsKey, sessionsJson);
      if (!success) {
        throw const StorageWriteException();
      }
    } catch (e) {
      // Re-throw as AppException for proper handling
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handleError(e);
    }
  }
}

