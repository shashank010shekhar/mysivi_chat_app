import 'package:equatable/equatable.dart';

enum MessageType { sender, receiver }

class MessageEntity extends Equatable {
  final String id;
  final String userId;
  final String content;
  final MessageType type;
  final DateTime timestamp;

  const MessageEntity({
    required this.id,
    required this.userId,
    required this.content,
    required this.type,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, userId, content, type, timestamp];
}

