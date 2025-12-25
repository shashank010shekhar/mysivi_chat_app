import 'package:equatable/equatable.dart';

class ChatSessionEntity extends Equatable {
  final String userId;
  final String userName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  const ChatSessionEntity({
    required this.userId,
    required this.userName,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  String get userInitial => userName.isNotEmpty ? userName[0].toUpperCase() : '?';

  @override
  List<Object?> get props => [userId, userName, lastMessage, lastMessageTime, unreadCount];
}

