import '../repositories/chat_repository.dart';

class FetchReceiverMessageUseCase {
  final ChatRepository _repository;

  FetchReceiverMessageUseCase(this._repository);

  Future<String> call() async {
    return await _repository.fetchReceiverMessage();
  }
}

