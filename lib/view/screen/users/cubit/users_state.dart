part of 'users_cubit.dart';

@immutable
sealed class UsersState {}

final class UsersInitial extends UsersState {}

final class UsersLoading extends UsersState {}

final class UsersError extends UsersState {
  final String message;
  UsersError(this.message);
}

final class UsersSuccess extends UsersState {}

final class UsersLoaded extends UsersState {}
