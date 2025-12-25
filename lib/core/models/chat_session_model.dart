import 'package:equatable/equatable.dart';

class ChatSessionModel extends Equatable {
  final String userId;
  final String userName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  const ChatSessionModel({
    required this.userId,
    required this.userName,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  String get userInitial => userName.isNotEmpty ? userName[0].toUpperCase() : '?';

  @override
  List<Object?> get props => [userId, userName, lastMessage, lastMessageTime, unreadCount];

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime?.toIso8601String(),
        'unreadCount': unreadCount,
      };

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) => ChatSessionModel(
        userId: json['userId'] as String,
        userName: json['userName'] as String,
        lastMessage: json['lastMessage'] as String?,
        lastMessageTime: json['lastMessageTime'] != null
            ? DateTime.parse(json['lastMessageTime'] as String)
            : null,
        unreadCount: json['unreadCount'] as int? ?? 0,
      );

  ChatSessionModel copyWith({
    String? userId,
    String? userName,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) =>
      ChatSessionModel(
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,
        unreadCount: unreadCount ?? this.unreadCount,
      );
}

