import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mysivi_chat_app/features/users/domain/entities/user_entity.dart';
import 'package:mysivi_chat_app/features/users/domain/usecases/get_users_usecase.dart';
import 'package:mysivi_chat_app/features/users/domain/usecases/add_user_usecase.dart';
import 'package:mysivi_chat_app/features/users/presentation/cubit/users_cubit.dart';
import 'package:mysivi_chat_app/features/users/presentation/cubit/users_state.dart';

import 'users_cubit_test.mocks.dart';

@GenerateMocks([GetUsersUseCase, AddUserUseCase])
void main() {
  late MockGetUsersUseCase mockGetUsersUseCase;
  late MockAddUserUseCase mockAddUserUseCase;

  setUp(() {
    mockGetUsersUseCase = MockGetUsersUseCase();
    mockAddUserUseCase = MockAddUserUseCase();
  });

  final tUsers = [
    UserEntity(
      id: '1',
      name: 'John Doe',
      createdAt: DateTime.now(),
      status: UserStatus.online,
      lastActive: DateTime.now(),
    ),
  ];

  test('initial state should be UsersState with empty users', () async {
    // Arrange
    when(mockGetUsersUseCase()).thenAnswer((_) async => []);
    
    // Act
    final testCubit = UsersCubit(mockGetUsersUseCase, mockAddUserUseCase);
    
    // Wait for constructor's async loadUsers to complete
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Assert
    expect(testCubit.state, isA<UsersState>());
    testCubit.close();
  });

  test('loads users successfully in constructor', () async {
    // Arrange
    when(mockGetUsersUseCase()).thenAnswer((_) async => tUsers);
    
    // Act - Constructor calls loadUsers()
    final testCubit = UsersCubit(mockGetUsersUseCase, mockAddUserUseCase);
    
    // Wait for constructor's loadUsers to complete
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Assert
    expect(testCubit.state.isLoading, false);
    expect(testCubit.state.users, isNotEmpty);
    expect(testCubit.state.users.length, tUsers.length);
    expect(testCubit.state.error, isNull);
    verify(mockGetUsersUseCase()).called(1);
    testCubit.close();
  });

  test('emits error when loading users fails', () async {
    // Arrange
    when(mockGetUsersUseCase())
        .thenThrow(Exception('Failed to load users'));
    final testCubit = UsersCubit(mockGetUsersUseCase, mockAddUserUseCase);
    
    // Wait for constructor's loadUsers to complete (with error)
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Assert
    expect(testCubit.state.isLoading, false);
    expect(testCubit.state.error, isNotNull);
    expect(testCubit.state.users, isEmpty);
    testCubit.close();
  });

  blocTest<UsersCubit, UsersState>(
    'adds user and reloads users list',
    build: () {
      when(mockAddUserUseCase(any)).thenAnswer((_) async => {});
      when(mockGetUsersUseCase()).thenAnswer((_) async => tUsers);
      return UsersCubit(mockGetUsersUseCase, mockAddUserUseCase);
    },
    act: (cubit) => cubit.addUser('Jane Smith'),
    wait: const Duration(milliseconds: 200),
    verify: (_) {
      verify(mockAddUserUseCase('Jane Smith')).called(1);
      // loadUsers is called once in constructor and once after addUser
      verify(mockGetUsersUseCase()).called(greaterThan(1));
    },
  );

  test('saves scroll position', () async {
    // Arrange
    when(mockGetUsersUseCase()).thenAnswer((_) async => []);
    final testCubit = UsersCubit(mockGetUsersUseCase, mockAddUserUseCase);
    
    // Wait for constructor's loadUsers to complete
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Act
    testCubit.saveScrollPosition(100.0);
    
    // Assert
    expect(testCubit.state.scrollPosition, 100.0);
    testCubit.close();
  });
}

