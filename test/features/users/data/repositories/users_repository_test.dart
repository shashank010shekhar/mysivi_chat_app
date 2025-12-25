import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mysivi_chat_app/core/services/storage_service.dart';
import 'package:mysivi_chat_app/core/models/user_model.dart';
import 'package:mysivi_chat_app/core/di/injection_container.dart';
import 'package:mysivi_chat_app/features/users/data/repositories/users_repository.dart';
import 'package:mysivi_chat_app/features/users/domain/entities/user_entity.dart';

import 'users_repository_test.mocks.dart';

@GenerateMocks([StorageService])
void main() {
  late UsersRepositoryImpl repository;
  late MockStorageService mockStorageService;

  setUp(() {
    mockStorageService = MockStorageService();
    // Register mock in GetIt for testing
    if (getIt.isRegistered<StorageService>()) {
      getIt.unregister<StorageService>();
    }
    getIt.registerSingleton<StorageService>(mockStorageService);
    repository = UsersRepositoryImpl();
  });

  tearDown(() {
    if (getIt.isRegistered<StorageService>()) {
      getIt.unregister<StorageService>();
    }
  });

  test('should return list of UserEntity from storage', () async {
    // arrange
    final tUsers = [
      UserModel(
        id: '1',
        name: 'John Doe',
        createdAt: DateTime.now(),
      ),
    ];
    when(mockStorageService.getUsers()).thenAnswer((_) async => tUsers);

    // act
    final result = await repository.getUsers();

    // assert
    expect(result, isA<List<UserEntity>>());
    expect(result.length, 1);
    expect(result[0].name, 'John Doe');
    verify(mockStorageService.getUsers()).called(1);
  });

  test('should add user through storage service', () async {
    // arrange
    when(mockStorageService.getUsers()).thenAnswer((_) async => []);
    when(mockStorageService.saveUsers(any)).thenAnswer((_) async => {});

    // act
    await repository.addUser('Jane Smith');

    // assert
    verify(mockStorageService.getUsers()).called(1);
    verify(mockStorageService.saveUsers(any)).called(1);
  });
}

