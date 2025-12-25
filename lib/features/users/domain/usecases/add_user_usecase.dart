import '../repositories/users_repository.dart';

class AddUserUseCase {
  final UsersRepository _repository;

  AddUserUseCase(this._repository);

  Future<void> call(String name) async {
    return await _repository.addUser(name);
  }
}

