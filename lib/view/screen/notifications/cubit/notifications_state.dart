part of 'notifications_cubit.dart';

@immutable
sealed class NotificationsState {}

final class NotificationsInitial extends NotificationsState {}

final class NotificationsLoading extends NotificationsState {}

final class NotificationsLoaded extends NotificationsState {}

final class NotificationsSending extends NotificationsState {}

final class NotificationsSuccess extends NotificationsState {
  final String message;

  NotificationsSuccess(this.message);
}

final class NotificationsError extends NotificationsState {
  final String message;

  NotificationsError(this.message);
}
