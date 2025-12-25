import '../repositories/chat_repository.dart';

class UpdateChatSessionUseCase {
  final ChatRepository _repository;

  UpdateChatSessionUseCase(this._repository);

  Future<void> call(String userId, String userName, String? lastMessage) async {
    return await _repository.updateChatSession(userId, userName, lastMessage);
  }
}

