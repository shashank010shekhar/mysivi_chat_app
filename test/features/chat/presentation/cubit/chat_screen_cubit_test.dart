import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mysivi_chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:mysivi_chat_app/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:mysivi_chat_app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:mysivi_chat_app/features/chat/domain/usecases/update_chat_session_usecase.dart';
import 'package:mysivi_chat_app/features/chat/domain/usecases/fetch_receiver_message_usecase.dart';
import 'package:mysivi_chat_app/features/chat/domain/usecases/save_receiver_message_usecase.dart';
import 'package:mysivi_chat_app/features/chat/presentation/cubit/chat_screen_cubit.dart';

import 'chat_screen_cubit_test.mocks.dart';

@GenerateMocks([
  GetMessagesUseCase,
  SendMessageUseCase,
  UpdateChatSessionUseCase,
  FetchReceiverMessageUseCase,
  SaveReceiverMessageUseCase,
])
void main() {
  late MockGetMessagesUseCase mockGetMessagesUseCase;
  late MockSendMessageUseCase mockSendMessageUseCase;
  late MockUpdateChatSessionUseCase mockUpdateChatSessionUseCase;
  late MockFetchReceiverMessageUseCase mockFetchReceiverMessageUseCase;
  late MockSaveReceiverMessageUseCase mockSaveReceiverMessageUseCase;

  const tUserId = 'user123';
  const tUserName = 'John Doe';

  setUp(() {
    mockGetMessagesUseCase = MockGetMessagesUseCase();
    mockSendMessageUseCase = MockSendMessageUseCase();
    mockUpdateChatSessionUseCase = MockUpdateChatSessionUseCase();
    mockFetchReceiverMessageUseCase = MockFetchReceiverMessageUseCase();
    mockSaveReceiverMessageUseCase = MockSaveReceiverMessageUseCase();
  });

  tearDown(() {
    // Cubit will be created in each test, so we close it there if needed
  });

  final tMessages = [
    MessageEntity(
      id: '1',
      userId: tUserId,
      content: 'Hello',
      type: MessageType.sender,
      timestamp: DateTime.now(),
    ),
  ];

  test('initial state should have correct userId and userName', () async {
    // Arrange - mock the initial loadMessages call
    when(mockGetMessagesUseCase(any)).thenAnswer((_) async => []);
    
    // Act
    final testCubit = ChatScreenCubit(
      mockGetMessagesUseCase,
      mockSendMessageUseCase,
      mockUpdateChatSessionUseCase,
      mockFetchReceiverMessageUseCase,
      mockSaveReceiverMessageUseCase,
      tUserId,
      tUserName,
    );
    
    // Wait for constructor's loadMessages to complete
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Assert
    expect(testCubit.state.userId, tUserId);
    expect(testCubit.state.userName, tUserName);
    testCubit.close();
  });

  test('loads messages successfully in constructor', () async {
    // Arrange
    when(mockGetMessagesUseCase(any)).thenAnswer((_) async => tMessages);
    
    // Act - Constructor calls loadMessages()
    final testCubit = ChatScreenCubit(
      mockGetMessagesUseCase,
      mockSendMessageUseCase,
      mockUpdateChatSessionUseCase,
      mockFetchReceiverMessageUseCase,
      mockSaveReceiverMessageUseCase,
      tUserId,
      tUserName,
    );
    
    // Wait for constructor's loadMessages to complete
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Assert
    expect(testCubit.state.isLoading, false);
    expect(testCubit.state.messages, isNotEmpty);
    expect(testCubit.state.messages.length, tMessages.length);
    verify(mockGetMessagesUseCase(tUserId)).called(1);
    testCubit.close();
  });

  test('sends message successfully', () async {
    // Arrange
    when(mockSendMessageUseCase(any, any)).thenAnswer((_) async => {});
    when(mockUpdateChatSessionUseCase(any, any, any))
        .thenAnswer((_) async => {});
    when(mockFetchReceiverMessageUseCase())
        .thenAnswer((_) async => 'Response message');
    when(mockSaveReceiverMessageUseCase(any, any))
        .thenAnswer((_) async => {});
    when(mockGetMessagesUseCase(any)).thenAnswer((_) async => tMessages);
    
    // Act - Constructor calls loadMessages()
    final testCubit = ChatScreenCubit(
      mockGetMessagesUseCase,
      mockSendMessageUseCase,
      mockUpdateChatSessionUseCase,
      mockFetchReceiverMessageUseCase,
      mockSaveReceiverMessageUseCase,
      tUserId,
      tUserName,
    );
    
    // Wait for constructor's loadMessages to complete
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Act - Send message
    await testCubit.sendMessage('Hello');
    
    // Assert
    verify(mockSendMessageUseCase(tUserId, 'Hello')).called(1);
    verify(mockUpdateChatSessionUseCase(tUserId, tUserName, 'Hello'))
        .called(1);
    // loadMessages is called in constructor and after sendMessage
    verify(mockGetMessagesUseCase(tUserId)).called(greaterThan(1));
    expect(testCubit.state.isSending, false);
    testCubit.close();
  });
}

