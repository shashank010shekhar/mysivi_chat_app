import 'package:equatable/equatable.dart';
import '../../domain/entities/message_entity.dart';

class ChatScreenState extends Equatable {
  final List<MessageEntity> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final String userId;
  final String userName;

  const ChatScreenState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
    required this.userId,
    required this.userName,
  });

  ChatScreenState copyWith({
    List<MessageEntity>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
    String? userId,
    String? userName,
  }) {
    return ChatScreenState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error ?? this.error,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, isSending, error, userId, userName];
}

