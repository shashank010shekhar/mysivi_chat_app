import '../../../../core/models/user_model.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/users_repository.dart' as domain;

class UsersRepositoryImpl implements domain.UsersRepository {
  final StorageService _storageService = getIt<StorageService>();

  @override
  Future<List<UserEntity>> getUsers() async {
    final users = await _storageService.getUsers();
    final now = DateTime.now();
    return users.asMap().entries.map((entry) {
      final index = entry.key;
      final u = entry.value;
      // Randomly assign status - some online, some with different last active times
      final isOnline = index % 3 == 0 || index % 3 == 2;
      return UserEntity(
        id: u.id,
        name: u.name,
        createdAt: u.createdAt,
        status: isOnline ? UserStatus.online : UserStatus.offline,
        lastActive: isOnline
            ? now
            : now.subtract(Duration(
                minutes: (index % 5 + 1) * (index % 2 == 0 ? 1 : 60),
              )),
      );
    }).toList();
  }

  @override
  Future<void> addUser(String name) async {
    final users = await _storageService.getUsers();
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    users.add(newUser);
    await _storageService.saveUsers(users);
  }
}

