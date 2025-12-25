import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/update_chat_session_usecase.dart';
import '../../domain/usecases/fetch_receiver_message_usecase.dart';
import '../../domain/usecases/save_receiver_message_usecase.dart';
import '../../../../core/errors/error_handler.dart';
import 'chat_screen_state.dart';

class ChatScreenCubit extends Cubit<ChatScreenState> {
  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final UpdateChatSessionUseCase _updateChatSessionUseCase;
  final FetchReceiverMessageUseCase _fetchReceiverMessageUseCase;
  final SaveReceiverMessageUseCase _saveReceiverMessageUseCase;

  ChatScreenCubit(
    this._getMessagesUseCase,
    this._sendMessageUseCase,
    this._updateChatSessionUseCase,
    this._fetchReceiverMessageUseCase,
    this._saveReceiverMessageUseCase,
    String userId,
    String userName,
  ) : super(ChatScreenState(userId: userId, userName: userName)) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final messages = await _getMessagesUseCase(state.userId);
      // Filter out read receipt messages
      final filteredMessages = messages.where((m) => !m.id.startsWith('read_')).toList();
      emit(state.copyWith(messages: filteredMessages, isLoading: false, error: null));
    } catch (e) {
      final appException = ErrorHandler.handleError(e);
      emit(state.copyWith(
        isLoading: false,
        error: ErrorHandler.getErrorMessage(appException),
      ));
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    emit(state.copyWith(isSending: true, error: null));
    try {
      // Save sender message
      await _sendMessageUseCase(state.userId, content.trim());
      await _updateChatSessionUseCase(
        state.userId,
        state.userName,
        content.trim(),
      );

      // Fetch receiver message (with graceful error handling)
      try {
        final receiverMessage = await _fetchReceiverMessageUseCase();
        await _saveReceiverMessageUseCase(state.userId, receiverMessage);
        await _updateChatSessionUseCase(
          state.userId,
          state.userName,
          receiverMessage,
        );
      } catch (e) {
        // If fetching receiver message fails, still show the sender's message
        // This is graceful degradation - the user's message is saved
        // We can silently continue or show a non-blocking error
        // For now, we'll continue - the message was sent successfully
      }

      await loadMessages();
      emit(state.copyWith(isSending: false, error: null));
    } catch (e) {
      final appException = ErrorHandler.handleError(e);
      emit(state.copyWith(
        isSending: false,
        error: ErrorHandler.getErrorMessage(appException),
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}

