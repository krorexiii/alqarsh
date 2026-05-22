part of 'store_locations_cubit.dart';

@immutable
sealed class StoreLocationsState {}

final class StoreLocationsInitial extends StoreLocationsState {}

final class StoreLocationsLoading extends StoreLocationsState {}

final class StoreLocationsLoaded extends StoreLocationsState {}

final class StoreLocationsSaving extends StoreLocationsState {}

final class StoreLocationsSuccess extends StoreLocationsState {
  StoreLocationsSuccess(this.message);

  final String message;
}

final class StoreLocationsError extends StoreLocationsState {
  StoreLocationsError(this.message);

  final String message;
}
