import 'dart:typed_data';

import 'package:alkhafajdashboard/data/model/bannerAdsModel.dart';
import 'package:alkhafajdashboard/data/repository.dart';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:meta/meta.dart';

part 'banner_ads_state.dart';

class BannerAdsCubit extends Cubit<BannerAdsState> {
  BannerAdsCubit() : super(BannerAdsInitial());

  final Repository _repository = Repository();

  List<BannerAdsModel> ads = [];
  BannerAdsModel? selectedBanner;
  Uint8List? selectedImageBytes;
  String? selectedImageName;
  bool isActive = true;

  Future<void> fetchBannerAds() async {
    emit(BannerAdsLoading());
    try {
      final List<dynamic> response = await _repository.fetchBannerAds();
      ads = response.map((item) {
        final banner = BannerAdsModel.fromJson(item as Map<String, dynamic>);
        final String? path = banner.imagePath;
        return banner.copyWith(
          publicUrl: path != null && path.isNotEmpty
              ? _repository.getBannerImagePublicUrl(path)
              : null,
          isActive: banner.isActive ?? true,
        );
      }).toList();
      selectedBanner ??= ads.isNotEmpty ? ads.first : null;
      syncSelectionWithCurrentBanner();
      emit(BannerAdsLoaded());
    } catch (e) {
      emit(BannerAdsError('فشل في جلب الإعلانات'));
    }
  }

  void selectBanner(BannerAdsModel? banner) {
    selectedBanner = banner;
    syncSelectionWithCurrentBanner();
    emit(BannerAdsLoaded());
  }

  void startCreatingNewBanner() {
    selectedBanner = null;
    selectedImageBytes = null;
    selectedImageName = null;
    isActive = true;
    emit(BannerAdsLoaded());
  }

  void updateActiveStatus(bool value) {
    isActive = value;
    emit(BannerAdsLoaded());
  }

  Future<void> pickBannerImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;
      if (file.bytes == null) {
        emit(BannerAdsError('تعذر قراءة ملف الصورة'));
        return;
      }

      selectedImageBytes = file.bytes;
      selectedImageName = file.name;
      emit(BannerAdsLoaded());
    } catch (e) {
      emit(BannerAdsError('فشل في اختيار الصورة'));
    }
  }

  Future<void> saveBanner() async {
    if (selectedBanner == null && selectedImageBytes == null) {
      emit(BannerAdsError('اختر صورة الإعلان أولاً'));
      return;
    }

    emit(BannerAdsSaving());

    try {
      String? imagePath = selectedBanner?.imagePath;

      if (selectedImageBytes != null && selectedImageName != null) {
        imagePath = await _repository.uploadBannerImage(
          bytes: selectedImageBytes!,
          fileName: selectedImageName!,
        );
      }

      if (imagePath == null || imagePath.isEmpty) {
        emit(BannerAdsError('تعذر تجهيز رابط الصورة'));
        return;
      }

      if (selectedBanner == null) {
        final BannerAdsModel banner = BannerAdsModel(
          shopId: _repository.supabaseApi.shopId,
          imagePath: imagePath,
          sortOrder: ads.length,
          isActive: isActive,
        );
        await _repository.addBannerAd(bannerAd: banner);
        await fetchBannerAds();
        startCreatingNewBanner();
        emit(BannerAdsSuccess('تم إنشاء الإعلان بنجاح'));
        return;
      }

      final updatedBanner = selectedBanner!.copyWith(
        imagePath: imagePath,
        isActive: isActive,
      );

      await _repository.updateBannerAd(bannerAd: updatedBanner);
      selectedBanner = updatedBanner;
      selectedImageBytes = null;
      selectedImageName = null;
      await fetchBannerAds();
      emit(BannerAdsSuccess('تم تحديث الإعلان بنجاح'));
    } catch (e) {
      print(e);
      emit(BannerAdsError('فشل في حفظ الإعلان'));
    }
  }

  Future<void> deleteSelectedBanner() async {
    if (selectedBanner == null) {
      emit(BannerAdsError('اختر إعلاناً للحذف أولاً'));
      return;
    }

    emit(BannerAdsSaving());
    try {
      await _repository.deleteBannerAd(bannerAd: selectedBanner!);
      ads.removeWhere((item) => item.id == selectedBanner!.id);
      _recalculateSortOrders();
      await _repository.updateBannerAdsOrder(ads: ads);
      selectedBanner = null;
      selectedImageBytes = null;
      selectedImageName = null;
      isActive = true;
      await fetchBannerAds();
      emit(BannerAdsSuccess('تم حذف الإعلان'));
    } catch (e) {
      emit(BannerAdsError('فشل في حذف الإعلان'));
    }
  }

  void moveBannerUp(int index) {
    if (index <= 0 || index >= ads.length) {
      return;
    }
    final item = ads.removeAt(index);
    ads.insert(index - 1, item);
    _recalculateSortOrders();
    emit(BannerAdsLoaded());
  }

  void moveBannerDown(int index) {
    if (index < 0 || index >= ads.length - 1) {
      return;
    }
    final item = ads.removeAt(index);
    ads.insert(index + 1, item);
    _recalculateSortOrders();
    emit(BannerAdsLoaded());
  }

  Future<void> persistOrder() async {
    emit(BannerAdsSaving());
    try {
      await _repository.updateBannerAdsOrder(ads: ads);
      await fetchBannerAds();
      emit(BannerAdsSuccess('تم حفظ ترتيب الإعلانات'));
    } catch (e) {
      print(e);
      emit(BannerAdsError('فشل في حفظ ترتيب الإعلانات'));
    }
  }

  void syncSelectionWithCurrentBanner() {
    if (selectedBanner != null) {
      final match = ads.where((item) => item.id == selectedBanner!.id);
      if (match.isNotEmpty) {
        selectedBanner = match.first;
      }
    }
    isActive = selectedBanner?.isActive ?? true;
  }

  void _recalculateSortOrders() {
    ads = ads.asMap().entries.map((entry) {
      return entry.value.copyWith(sortOrder: entry.key);
    }).toList();
    syncSelectionWithCurrentBanner();
  }
}
