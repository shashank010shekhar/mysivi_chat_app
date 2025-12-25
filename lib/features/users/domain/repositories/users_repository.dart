import '../entities/user_entity.dart';

abstract class UsersRepository {
  Future<List<UserEntity>> getUsers();
  Future<void> addUser(String name);
}

