import '../entities/chat_session_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatSessionsUseCase {
  final ChatRepository _repository;

  GetChatSessionsUseCase(this._repository);

  Future<List<ChatSessionEntity>> call() async {
    return await _repository.getChatSessions();
  }
}

