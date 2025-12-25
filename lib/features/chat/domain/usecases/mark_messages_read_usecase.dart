import '../repositories/chat_repository.dart';

class MarkMessagesReadUseCase {
  final ChatRepository _repository;

  MarkMessagesReadUseCase(this._repository);

  Future<void> call(String userId) async {
    return await _repository.markMessagesAsRead(userId);
  }
}

