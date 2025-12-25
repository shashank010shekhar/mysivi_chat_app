import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_session_entity.dart';

class ChatHistoryState extends Equatable {
  final List<ChatSessionEntity> sessions;
  final bool isLoading;
  final String? error;
  final double? scrollPosition;

  const ChatHistoryState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
    this.scrollPosition,
  });

  ChatHistoryState copyWith({
    List<ChatSessionEntity>? sessions,
    bool? isLoading,
    String? error,
    double? scrollPosition,
  }) {
    return ChatHistoryState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      scrollPosition: scrollPosition ?? this.scrollPosition,
    );
  }

  @override
  List<Object?> get props => [sessions, isLoading, error, scrollPosition];
}

