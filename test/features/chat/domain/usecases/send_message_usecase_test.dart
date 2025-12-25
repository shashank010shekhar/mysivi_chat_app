import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mysivi_chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:mysivi_chat_app/features/chat/domain/usecases/send_message_usecase.dart';

import 'send_message_usecase_test.mocks.dart';

@GenerateMocks([ChatRepository])
void main() {
  late SendMessageUseCase useCase;
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    useCase = SendMessageUseCase(mockRepository);
  });

  const tUserId = 'user123';
  const tContent = 'Hello, world!';

  test('should send message through the repository', () async {
    // arrange
    when(mockRepository.sendMessage(any, any)).thenAnswer((_) async => {});

    // act
    await useCase(tUserId, tContent);

    // assert
    verify(mockRepository.sendMessage(tUserId, tContent));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw exception when repository throws', () async {
    // arrange
    when(mockRepository.sendMessage(any, any))
        .thenThrow(Exception('Failed to send message'));

    // act & assert
    expect(() => useCase(tUserId, tContent), throwsException);
    verify(mockRepository.sendMessage(tUserId, tContent));
  });
}

