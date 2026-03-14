part of 'banner_ads_cubit.dart';

@immutable
sealed class BannerAdsState {}

final class BannerAdsInitial extends BannerAdsState {}

final class BannerAdsLoading extends BannerAdsState {}

final class BannerAdsLoaded extends BannerAdsState {}

final class BannerAdsSaving extends BannerAdsState {}

final class BannerAdsSuccess extends BannerAdsState {
  final String message;
  BannerAdsSuccess(this.message);
}

final class BannerAdsError extends BannerAdsState {
  final String message;
  BannerAdsError(this.message);
}
