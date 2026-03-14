part of 'delivery_zones_cubit.dart';

@immutable
sealed class DeliveryZonesState {}

final class DeliveryZonesInitial extends DeliveryZonesState {}

final class DeliveryZonesLoading extends DeliveryZonesState {}

final class DeliveryZonesLoaded extends DeliveryZonesState {}

final class DeliveryZonesSaving extends DeliveryZonesState {}

final class DeliveryZonesSuccess extends DeliveryZonesState {
  final String message;
  DeliveryZonesSuccess(this.message);
}

final class DeliveryZonesError extends DeliveryZonesState {
  final String message;
  DeliveryZonesError(this.message);
}
