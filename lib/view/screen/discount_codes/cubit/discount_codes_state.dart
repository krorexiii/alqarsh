part of 'discount_codes_cubit.dart';

sealed class DiscountCodesState {}

final class DiscountCodesInitial extends DiscountCodesState {}

final class DiscountCodesLoading extends DiscountCodesState {}

final class DiscountCodesLoaded extends DiscountCodesState {}

final class DiscountCodesSaving extends DiscountCodesState {}

final class DiscountCodesSuccess extends DiscountCodesState {
  final String message;

  DiscountCodesSuccess(this.message);
}

final class DiscountCodesError extends DiscountCodesState {
  final String message;

  DiscountCodesError(this.message);
}
