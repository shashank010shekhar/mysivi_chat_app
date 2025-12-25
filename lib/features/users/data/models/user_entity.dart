import 'package:equatable/equatable.dart';

enum UserStatus { online, offline }

class UserEntity extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final UserStatus status;
  final DateTime? lastActive;

  const UserEntity({
    required this.id,
    required this.name,
    required this.createdAt,
    this.status = UserStatus.offline,
    this.lastActive,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  @override
  List<Object?> get props => [id, name, createdAt, status, lastActive];
}

