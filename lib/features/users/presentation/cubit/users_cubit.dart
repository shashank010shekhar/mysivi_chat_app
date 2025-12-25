import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/add_user_usecase.dart';
import '../../../../core/errors/error_handler.dart';
import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  final GetUsersUseCase _getUsersUseCase;
  final AddUserUseCase _addUserUseCase;

  UsersCubit(this._getUsersUseCase, this._addUserUseCase) : super(const UsersState()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final users = await _getUsersUseCase();
      emit(state.copyWith(users: users, isLoading: false, error: null));
    } catch (e) {
      final appException = ErrorHandler.handleError(e);
      emit(state.copyWith(
        isLoading: false,
        error: ErrorHandler.getErrorMessage(appException),
      ));
    }
  }

  Future<void> addUser(String name) async {
    if (name.trim().isEmpty) {
      emit(state.copyWith(error: 'Please enter a valid name'));
      return;
    }

    emit(state.copyWith(error: null));
    try {
      await _addUserUseCase(name.trim());
      await loadUsers();
    } catch (e) {
      final appException = ErrorHandler.handleError(e);
      emit(state.copyWith(
        error: ErrorHandler.getErrorMessage(appException),
      ));
    }
  }

  void saveScrollPosition(double position) {
    emit(state.copyWith(scrollPosition: position));
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}

