import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

class UsersState extends Equatable {
  final List<UserEntity> users;
  final bool isLoading;
  final String? error;
  final double? scrollPosition;

  const UsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.scrollPosition,
  });

  UsersState copyWith({
    List<UserEntity>? users,
    bool? isLoading,
    String? error,
    double? scrollPosition,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      scrollPosition: scrollPosition ?? this.scrollPosition,
    );
  }

  @override
  List<Object?> get props => [users, isLoading, error, scrollPosition];
}

