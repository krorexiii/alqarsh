part of 'parts_cubit.dart';

@immutable
sealed class PartsState {}

final class PartsInitial extends PartsState {}

final class PartsLoading extends PartsState {}

final class PartsLoaded extends PartsState {}

final class PartsSaving extends PartsState {}

final class PartsSuccess extends PartsState {
  final String message;
  PartsSuccess(this.message);
}

final class PartsError extends PartsState {
  final String message;
  PartsError(this.message);
}
