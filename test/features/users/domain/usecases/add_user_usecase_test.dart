import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mysivi_chat_app/features/users/domain/repositories/users_repository.dart';
import 'package:mysivi_chat_app/features/users/domain/usecases/add_user_usecase.dart';

import 'add_user_usecase_test.mocks.dart';

@GenerateMocks([UsersRepository])
void main() {
  late AddUserUseCase useCase;
  late MockUsersRepository mockRepository;

  setUp(() {
    mockRepository = MockUsersRepository();
    useCase = AddUserUseCase(mockRepository);
  });

  const tUserName = 'John Doe';

  test('should add user through the repository', () async {
    // arrange
    when(mockRepository.addUser(any)).thenAnswer((_) async => {});

    // act
    await useCase(tUserName);

    // assert
    verify(mockRepository.addUser(tUserName));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw exception when repository throws', () async {
    // arrange
    when(mockRepository.addUser(any))
        .thenThrow(Exception('Failed to add user'));

    // act & assert
    expect(() => useCase(tUserName), throwsException);
    verify(mockRepository.addUser(tUserName));
  });
}

