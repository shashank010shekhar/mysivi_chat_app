import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<void> call(String userId, String content) async {
    return await _repository.sendMessage(userId, content);
  }
}

