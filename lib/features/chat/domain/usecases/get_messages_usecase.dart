import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository _repository;

  GetMessagesUseCase(this._repository);

  Future<List<MessageEntity>> call(String userId) async {
    return await _repository.getMessages(userId);
  }
}

