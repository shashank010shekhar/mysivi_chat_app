import 'package:get_it/get_it.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../features/users/data/repositories/users_repository.dart';
import '../../features/users/domain/repositories/users_repository.dart' as users_domain;
import '../../features/users/domain/usecases/get_users_usecase.dart';
import '../../features/users/domain/usecases/add_user_usecase.dart';
import '../../features/chat/data/repositories/chat_repository.dart';
import '../../features/chat/domain/repositories/chat_repository.dart' as chat_domain;
import '../../features/chat/domain/usecases/get_messages_usecase.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/domain/usecases/get_chat_sessions_usecase.dart';
import '../../features/chat/domain/usecases/mark_messages_read_usecase.dart';
import '../../features/chat/domain/usecases/update_chat_session_usecase.dart';
import '../../features/chat/domain/usecases/fetch_receiver_message_usecase.dart';
import '../../features/chat/domain/usecases/save_receiver_message_usecase.dart';
import '../../features/chat/domain/usecases/fetch_word_meaning_usecase.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Services
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<StorageService>(() => StorageService());

  // Repositories (Domain interfaces implemented by Data layer)
  getIt.registerLazySingleton<users_domain.UsersRepository>(
    () => UsersRepositoryImpl(),
  );
  getIt.registerLazySingleton<chat_domain.ChatRepository>(
    () => ChatRepositoryImpl(),
  );

  // Use Cases
  getIt.registerLazySingleton<GetUsersUseCase>(
    () => GetUsersUseCase(getIt<users_domain.UsersRepository>()),
  );
  getIt.registerLazySingleton<AddUserUseCase>(
    () => AddUserUseCase(getIt<users_domain.UsersRepository>()),
  );
  getIt.registerLazySingleton<GetMessagesUseCase>(
    () => GetMessagesUseCase(getIt<chat_domain.ChatRepository>()),
  );
  getIt.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(getIt<chat_domain.ChatRepository>()),
  );
  getIt.registerLazySingleton<GetChatSessionsUseCase>(
    () => GetChatSessionsUseCase(getIt<chat_domain.ChatRepository>()),
  );
  getIt.registerLazySingleton<MarkMessagesReadUseCase>(
    () => MarkMessagesReadUseCase(getIt<chat_domain.ChatRepository>()),
  );
  getIt.registerLazySingleton<UpdateChatSessionUseCase>(
    () => UpdateChatSessionUseCase(getIt<chat_domain.ChatRepository>()),
  );
  getIt.registerLazySingleton<FetchReceiverMessageUseCase>(
    () => FetchReceiverMessageUseCase(getIt<chat_domain.ChatRepository>()),
  );
  getIt.registerLazySingleton<SaveReceiverMessageUseCase>(
    () => SaveReceiverMessageUseCase(getIt<chat_domain.ChatRepository>()),
  );
  getIt.registerLazySingleton<FetchWordMeaningUseCase>(
    () => FetchWordMeaningUseCase(getIt<chat_domain.ChatRepository>()),
  );
}

