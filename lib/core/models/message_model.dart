import 'package:equatable/equatable.dart';

enum MessageType { sender, receiver }

class MessageModel extends Equatable {
  final String id;
  final String userId;
  final String content;
  final MessageType type;
  final DateTime timestamp;

  const MessageModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.type,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, userId, content, type, timestamp];

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'content': content,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
      };

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        content: json['content'] as String,
        type: MessageType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MessageType.sender,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

