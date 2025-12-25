import '../repositories/chat_repository.dart';

class SaveReceiverMessageUseCase {
  final ChatRepository _repository;

  SaveReceiverMessageUseCase(this._repository);

  Future<void> call(String userId, String content) async {
    return await _repository.saveReceiverMessage(userId, content);
  }
}

