part of 'items_cubit.dart';

@immutable
sealed class ItemsState {}

final class ItemsInitial extends ItemsState {}

final class ItemsLoading extends ItemsState {}

final class ItemsLoaded extends ItemsState {}

final class ItemsSaving extends ItemsState {}

final class ItemsSuccess extends ItemsState {
  final String message;
  ItemsSuccess(this.message);
}

final class ItemsError extends ItemsState {
  final String message;
  ItemsError(this.message);
}
