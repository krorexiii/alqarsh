import 'dart:typed_data';

import 'package:alkhafajdashboard/data/model/categoryModel.dart';
import 'package:alkhafajdashboard/data/model/itemImageModel.dart';
import 'package:alkhafajdashboard/data/model/itemModel.dart';
import 'package:alkhafajdashboard/data/repository.dart';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

part 'items_state.dart';

class PendingItemImage {
  PendingItemImage({
    required this.bytes,
    required this.name,
    this.isPrimary = false,
  });

  final Uint8List bytes;
  final String name;
  bool isPrimary;
}

class ItemsCubit extends Cubit<ItemsState> {
  ItemsCubit() : super(ItemsInitial());

  final Repository _repository = Repository();

  List<ItemModel> items = [];
  List<CategoryModel> categories = [];
  List<ItemImageModel> itemImages = [];

  ItemModel? selectedItem;
  CategoryModel? selectedCategoryFilter;
  String? selectedCategoryId;

  List<PendingItemImage> pendingImages = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController(
    text: '0',
  );

  bool isActive = true;
  bool includeDeleted = false;

  Future<void> initialize() async {
    emit(ItemsLoading());
    try {
      await _fetchCategoriesInternal();
      await _fetchItemsInternal();
      if (selectedItem == null && items.isNotEmpty) {
        await selectItem(items.first, emitState: false);
      } else if (selectedItem != null) {
        await _loadSelectedItemImages();
        _syncControllers();
      } else {
        startCreateNewItem(emitState: false);
      }
      emit(ItemsLoaded());
    } catch (e) {
      emit(ItemsError('فشل في تهيئة صفحة المنتجات'));
    }
  }

  Future<void> refreshData() async {
    emit(ItemsLoading());
    try {
      await _fetchCategoriesInternal();
      await _fetchItemsInternal();
      await _loadSelectedItemImages();
      _syncControllers();
      emit(ItemsLoaded());
    } catch (e) {
      emit(ItemsError('فشل في تحديث البيانات'));
    }
  }

  Future<void> fetchItems() async {
    emit(ItemsLoading());
    try {
      await _fetchItemsInternal();
      if (selectedItem == null && items.isNotEmpty) {
        await selectItem(items.first, emitState: false);
      } else {
        await _loadSelectedItemImages();
        _syncControllers();
      }
      emit(ItemsLoaded());
    } catch (e) {
      emit(ItemsError('فشل في جلب المنتجات'));
    }
  }

  Future<void> _fetchCategoriesInternal() async {
    final List<dynamic> response = await _repository.fetchCategories();
    categories = response.map((item) {
      final category = CategoryModel.fromJson(item as Map<String, dynamic>);
      final String? path = category.icon;
      return category.copyWith(
        publicUrl: path != null && path.isNotEmpty
            ? _repository.getCategoryImagePublicUrl(path)
            : null,
      );
    }).toList();

    if (selectedCategoryId != null) {
      final int index = categories.indexWhere(
        (category) => category.id == selectedCategoryId,
      );
      if (index < 0) {
        selectedCategoryId = categories.isNotEmpty ? categories.first.id : null;
      }
    } else {
      selectedCategoryId = categories.isNotEmpty ? categories.first.id : null;
    }

    if (selectedCategoryFilter != null) {
      final int filterIndex = categories.indexWhere(
        (category) => category.id == selectedCategoryFilter!.id,
      );
      selectedCategoryFilter = filterIndex >= 0
          ? categories[filterIndex]
          : null;
    }
  }

  Future<void> _fetchItemsInternal() async {
    final List<dynamic> response = selectedCategoryFilter != null
        ? await _repository.fetchItemsByCategory(
            categoryId: selectedCategoryFilter!.id!,
            includeDeleted: includeDeleted,
          )
        : await _repository.fetchItems(includeDeleted: includeDeleted);

    items = response.map((item) {
      return ItemModel.fromJson(item as Map<String, dynamic>);
    }).toList();

    if (selectedItem != null) {
      final int index = items.indexWhere((item) => item.id == selectedItem!.id);
      selectedItem = index >= 0 ? items[index] : null;
    }
  }

  Future<void> selectItem(ItemModel? item, {bool emitState = true}) async {
    selectedItem = item;
    pendingImages = [];
    _syncControllers();
    await _loadSelectedItemImages();
    if (emitState) {
      emit(ItemsLoaded());
    }
  }

  void selectCategoryFilter(CategoryModel? category) {
    selectedCategoryFilter = category;
    fetchItems();
  }

  void clearCategoryFilter() {
    selectedCategoryFilter = null;
    fetchItems();
  }

  void setCategoryId(String? categoryId) {
    selectedCategoryId = categoryId;
    emit(ItemsLoaded());
  }

  void updateItemActiveStatus(bool value) {
    isActive = value;
    emit(ItemsLoaded());
  }

  void updateIncludeDeleted(bool value) {
    includeDeleted = value;
    fetchItems();
  }

  void updateSelectedImagePrimary(bool value) {
    if (pendingImages.isEmpty) {
      return;
    }

    if (value) {
      for (final image in pendingImages) {
        image.isPrimary = false;
      }
    }

    pendingImages.first.isPrimary = value;
    emit(ItemsLoaded());
  }

  void startCreateNewItem({bool emitState = true}) {
    selectedItem = null;
    itemImages = [];
    titleController.clear();
    descriptionController.clear();
    priceController.text = '0';
    selectedCategoryId = categories.isNotEmpty ? categories.first.id : null;
    pendingImages = [];
    isActive = true;
    if (emitState) {
      emit(ItemsLoaded());
    }
  }

  Future<void> pickItemImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final pickedFiles = result.files
          .where((file) => file.bytes != null)
          .toList();

      if (pickedFiles.isEmpty) {
        emit(ItemsError('تعذر قراءة ملفات الصور المحددة'));
        return;
      }

      for (final file in pickedFiles) {
        pendingImages.add(
          PendingItemImage(
            bytes: file.bytes!,
            name: file.name,
            isPrimary: pendingImages.isEmpty && itemImages.isEmpty,
          ),
        );
      }

      if (pendingImages.where((image) => image.isPrimary).isEmpty) {
        pendingImages.first.isPrimary = itemImages.isEmpty;
      }

      emit(ItemsLoaded());
    } catch (e) {
      emit(ItemsError('فشل في اختيار الصورة'));
    }
  }

  void removePendingImageAt(int index) {
    if (index < 0 || index >= pendingImages.length) {
      return;
    }

    final bool wasPrimary = pendingImages[index].isPrimary;
    pendingImages.removeAt(index);

    if (wasPrimary && pendingImages.isNotEmpty) {
      final bool hasExistingPrimary = itemImages.any(
        (image) => image.isPrimary == true,
      );
      pendingImages.first.isPrimary = !hasExistingPrimary;
    }

    emit(ItemsLoaded());
  }

  void setPendingImagePrimary(int index) {
    if (index < 0 || index >= pendingImages.length) {
      return;
    }

    for (final image in pendingImages) {
      image.isPrimary = false;
    }

    pendingImages[index].isPrimary = true;
    emit(ItemsLoaded());
  }

  Future<void> saveItem() async {
    final String title = titleController.text.trim();
    final String description = descriptionController.text.trim();
    final double? price = double.tryParse(priceController.text.trim());

    if (title.isEmpty) {
      emit(ItemsError('اسم المنتج مطلوب'));
      return;
    }

    if (selectedCategoryId == null || selectedCategoryId!.isEmpty) {
      emit(ItemsError('اختر تصنيفاً للمنتج'));
      return;
    }

    if (price == null || price < 0) {
      emit(ItemsError('السعر غير صالح'));
      return;
    }

    emit(ItemsSaving());

    try {
      if (selectedItem == null) {
        final ItemModel item = ItemModel(
          shopId: _repository.supabaseApi.shopId,
          categoryId: selectedCategoryId,
          title: title,
          description: description.isEmpty ? null : description,
          price: price,
          isActive: isActive,
          isDeleted: false,
        );

        await _repository.addItem(item: item);
        await _fetchItemsInternal();
        final ItemModel? createdItem = items.isNotEmpty ? items.first : null;

        if (createdItem != null && pendingImages.isNotEmpty) {
          await _uploadPendingImagesForItem(createdItem.id!);
          selectedItem = createdItem;
          await _loadSelectedItemImages();
        }

        startCreateNewItem(emitState: false);
        await fetchItems();
        emit(ItemsSuccess('تم إنشاء المنتج بنجاح'));
        return;
      }

      final ItemModel updatedItem = selectedItem!.copyWith(
        categoryId: selectedCategoryId,
        title: title,
        description: description.isEmpty ? null : description,
        price: price,
        isActive: isActive,
      );

      await _repository.updateItem(item: updatedItem);
      selectedItem = updatedItem;

      if (pendingImages.isNotEmpty) {
        await _uploadPendingImagesForItem(updatedItem.id!);
      }

      await fetchItems();
      emit(ItemsSuccess('تم تحديث المنتج بنجاح'));
    } catch (e) {
      emit(ItemsError('فشل في حفظ المنتج'));
    }
  }

  Future<void> _uploadPendingImagesForItem(int itemId) async {
    int sortOrder = itemImages.isEmpty
        ? 1
        : (itemImages
                  .map((image) => image.sortOrder ?? 0)
                  .fold<int>(0, (a, b) => a > b ? a : b) +
              1);

    final bool hasExistingPrimary = itemImages.any(
      (image) => image.isPrimary == true,
    );

    for (int index = 0; index < pendingImages.length; index++) {
      final pendingImage = pendingImages[index];
      final String imagePath = await _repository.uploadItemImage(
        bytes: pendingImage.bytes,
        fileName: pendingImage.name,
        itemId: itemId,
      );

      final ItemImageModel itemImage = ItemImageModel(
        itemId: itemId,
        imagePath: imagePath,
        sortOrder: sortOrder,
        isPrimary: hasExistingPrimary
            ? pendingImage.isPrimary
            : (index == 0 ? true : pendingImage.isPrimary),
      );

      await _repository.addItemImage(itemImage: itemImage);
      sortOrder++;
    }

    pendingImages = [];
  }

  Future<void> deleteSelectedItem({bool permanent = false}) async {
    if (selectedItem == null) {
      emit(ItemsError('اختر منتجاً للحذف أولاً'));
      return;
    }

    emit(ItemsSaving());
    try {
      if (permanent) {
        await _repository.deleteItemPermanently(itemId: selectedItem!.id!);
      } else {
        await _repository.softDeleteItem(itemId: selectedItem!.id!);
      }
      startCreateNewItem(emitState: false);
      await fetchItems();
      emit(
        ItemsSuccess(permanent ? 'تم حذف المنتج نهائياً' : 'تم أرشفة المنتج'),
      );
    } catch (e) {
      emit(ItemsError('فشل في حذف المنتج'));
    }
  }

  Future<void> restoreSelectedItem() async {
    if (selectedItem == null) {
      emit(ItemsError('اختر منتجاً للاستعادة أولاً'));
      return;
    }

    emit(ItemsSaving());
    try {
      await _repository.restoreItem(itemId: selectedItem!.id!);
      await fetchItems();
      emit(ItemsSuccess('تمت استعادة المنتج'));
    } catch (e) {
      emit(ItemsError('فشل في استعادة المنتج'));
    }
  }

  Future<void> deleteImage(ItemImageModel image) async {
    emit(ItemsSaving());
    try {
      await _repository.deleteItemImage(itemImage: image);
      await _loadSelectedItemImages();
      emit(ItemsSuccess('تم حذف الصورة'));
    } catch (e) {
      emit(ItemsError('فشل في حذف الصورة'));
    }
  }

  Future<void> setPrimaryImage(ItemImageModel image) async {
    emit(ItemsSaving());
    try {
      await _repository.updateItemImage(
        itemImage: image.copyWith(isPrimary: true),
      );
      await _loadSelectedItemImages();
      emit(ItemsSuccess('تم تعيين الصورة الرئيسية'));
    } catch (e) {
      emit(ItemsError('فشل في تحديث الصورة الرئيسية'));
    }
  }

  Future<void> _loadSelectedItemImages() async {
    if (selectedItem?.id == null) {
      itemImages = [];
      return;
    }

    final List<dynamic> response = await _repository.fetchItemImages(
      itemId: selectedItem!.id!,
    );

    itemImages = response.map((item) {
      final image = ItemImageModel.fromJson(item as Map<String, dynamic>);
      final String? path = image.imagePath;
      return image.copyWith(
        publicUrl: path != null && path.isNotEmpty
            ? _repository.getItemImagePublicUrl(path)
            : null,
      );
    }).toList();
  }

  void _syncControllers() {
    titleController.text = selectedItem?.title ?? '';
    descriptionController.text = selectedItem?.description ?? '';
    priceController.text = (selectedItem?.price ?? 0).toStringAsFixed(2);
    selectedCategoryId = selectedItem?.categoryId ?? selectedCategoryId;
    isActive = selectedItem?.isActive ?? true;
  }

  String getCategoryName(String? categoryId) {
    final CategoryModel? category = categories
        .cast<CategoryModel?>()
        .firstWhere((item) => item?.id == categoryId, orElse: () => null);
    return category?.name ?? 'غير محدد';
  }

  @override
  Future<void> close() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    return super.close();
  }
}
