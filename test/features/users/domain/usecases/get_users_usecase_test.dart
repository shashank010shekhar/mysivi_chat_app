import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mysivi_chat_app/features/users/domain/entities/user_entity.dart';
import 'package:mysivi_chat_app/features/users/domain/repositories/users_repository.dart';
import 'package:mysivi_chat_app/features/users/domain/usecases/get_users_usecase.dart';

import 'get_users_usecase_test.mocks.dart';

@GenerateMocks([UsersRepository])
void main() {
  late GetUsersUseCase useCase;
  late MockUsersRepository mockRepository;

  setUp(() {
    mockRepository = MockUsersRepository();
    useCase = GetUsersUseCase(mockRepository);
  });

  final tUsers = [
    UserEntity(
      id: '1',
      name: 'John Doe',
      createdAt: DateTime.now(),
      status: UserStatus.online,
      lastActive: DateTime.now(),
    ),
    UserEntity(
      id: '2',
      name: 'Jane Smith',
      createdAt: DateTime.now(),
      status: UserStatus.offline,
      lastActive: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  test('should get users from the repository', () async {
    // arrange
    when(mockRepository.getUsers()).thenAnswer((_) async => tUsers);

    // act
    final result = await useCase();

    // assert
    expect(result, equals(tUsers));
    verify(mockRepository.getUsers());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return empty list when repository returns empty list', () async {
    // arrange
    when(mockRepository.getUsers()).thenAnswer((_) async => []);

    // act
    final result = await useCase();

    // assert
    expect(result, isEmpty);
    verify(mockRepository.getUsers());
  });
}

