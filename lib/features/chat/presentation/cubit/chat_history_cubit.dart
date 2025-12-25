import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_chat_sessions_usecase.dart';
import '../../../../core/errors/error_handler.dart';
import 'chat_history_state.dart';

class ChatHistoryCubit extends Cubit<ChatHistoryState> {
  final GetChatSessionsUseCase _getChatSessionsUseCase;

  ChatHistoryCubit(this._getChatSessionsUseCase) : super(const ChatHistoryState()) {
    loadChatSessions();
  }

  Future<void> loadChatSessions() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final sessions = await _getChatSessionsUseCase();
      emit(state.copyWith(sessions: sessions, isLoading: false, error: null));
    } catch (e) {
      final appException = ErrorHandler.handleError(e);
      emit(state.copyWith(
        isLoading: false,
        error: ErrorHandler.getErrorMessage(appException),
      ));
    }
  }

  void saveScrollPosition(double position) {
    emit(state.copyWith(scrollPosition: position));
  }

  void refresh() {
    loadChatSessions();
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}

