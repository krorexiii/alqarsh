part of 'orders_cubit.dart';

@immutable
sealed class OrdersState {}

final class OrdersInitial extends OrdersState {}

final class OrdersLoading extends OrdersState {}

final class OrdersLoaded extends OrdersState {}

final class OrdersSaving extends OrdersState {}

final class OrdersSuccess extends OrdersState {
  final String message;

  OrdersSuccess(this.message);
}

final class OrdersError extends OrdersState {
  final String message;

  OrdersError(this.message);
}
