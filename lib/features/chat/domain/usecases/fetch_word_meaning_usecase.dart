import '../repositories/chat_repository.dart';

class FetchWordMeaningUseCase {
  final ChatRepository _repository;

  FetchWordMeaningUseCase(this._repository);

  Future<String?> call(String word) async {
    return await _repository.fetchWordMeaning(word);
  }
}

