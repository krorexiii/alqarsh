part of 'categories_cubit.dart';

@immutable
sealed class CategoriesState {}

final class CategoriesInitial extends CategoriesState {}

final class CategoriesLoading extends CategoriesState {}

final class CategoriesLoaded extends CategoriesState {}

final class CategoriesSaving extends CategoriesState {}

final class CategoriesSuccess extends CategoriesState {
  final String message;
  CategoriesSuccess(this.message);
}

final class CategoriesError extends CategoriesState {
  final String message;
  CategoriesError(this.message);
}
