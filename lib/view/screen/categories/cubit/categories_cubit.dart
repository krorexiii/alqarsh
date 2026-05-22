import 'dart:typed_data';

import 'package:alkhafajdashboard/data/model/categoryModel.dart';
import 'package:alkhafajdashboard/data/repository.dart';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit() : super(CategoriesInitial());

  final Repository _repository = Repository();

  List<CategoryModel> categories = [];
  CategoryModel? selectedCategory;
  Uint8List? selectedImageBytes;
  String? selectedImageName;

  final TextEditingController nameController = TextEditingController();

  Future<void> fetchCategories() async {
    emit(CategoriesLoading());
    try {
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

      if (selectedCategory != null) {
        final int index = categories.indexWhere(
          (item) => item.id == selectedCategory!.id,
        );
        selectedCategory = index >= 0 ? categories[index] : null;
      }

      if (selectedCategory == null && categories.isNotEmpty) {
        selectCategory(categories.first, emitState: false);
      } else {
        _syncControllers();
      }

      emit(CategoriesLoaded());
    } catch (e) {
      emit(CategoriesError('فشل في جلب التصنيفات'));
    }
  }

  void selectCategory(CategoryModel? category, {bool emitState = true}) {
    selectedCategory = category;
    _syncControllers();
    if (emitState) {
      emit(CategoriesLoaded());
    }
  }

  void startCreatingNewCategory() {
    selectedCategory = null;
    nameController.clear();
    selectedImageBytes = null;
    selectedImageName = null;
    emit(CategoriesLoaded());
  }

  Future<void> pickCategoryImage() async {
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
        emit(CategoriesError('تعذر قراءة ملف الصورة'));
        return;
      }

      selectedImageBytes = file.bytes;
      selectedImageName = file.name;
      emit(CategoriesLoaded());
    } catch (e) {
      emit(CategoriesError('فشل في اختيار الصورة'));
    }
  }

  Future<void> saveCategory() async {
    final String name = nameController.text.trim();

    if (name.isEmpty) {
      emit(CategoriesError('اسم التصنيف مطلوب'));
      return;
    }

    if (selectedCategory == null && selectedImageBytes == null) {
      emit(CategoriesError('اختر صورة التصنيف أولاً'));
      return;
    }

    emit(CategoriesSaving());

    try {
      String? iconPath = selectedCategory?.icon;

      if (selectedImageBytes != null && selectedImageName != null) {
        iconPath = await _repository.uploadCategoryImage(
          bytes: selectedImageBytes!,
          fileName: selectedImageName!,
        );
      }

      if (selectedCategory == null) {
        final CategoryModel category = CategoryModel(
          shopId: _repository.supabaseApi.shopId,
          name: name,
          icon: iconPath,
        );
        await _repository.addCategory(category: category);
        await fetchCategories();
        startCreatingNewCategory();
        emit(CategoriesSuccess('تم إنشاء التصنيف بنجاح'));
        return;
      }

      final CategoryModel updatedCategory = selectedCategory!.copyWith(
        name: name,
        icon: iconPath,
      );

      await _repository.updateCategory(category: updatedCategory);
      selectedCategory = updatedCategory;
      selectedImageBytes = null;
      selectedImageName = null;
      await fetchCategories();
      emit(CategoriesSuccess('تم تحديث التصنيف بنجاح'));
    } catch (e) {
      emit(CategoriesError('فشل في حفظ التصنيف'));
    }
  }

  Future<void> deleteSelectedCategory() async {
    if (selectedCategory == null) {
      emit(CategoriesError('اختر تصنيفاً للحذف أولاً'));
      return;
    }

    emit(CategoriesSaving());
    try {
      await _repository.deleteCategory(category: selectedCategory!);
      selectedCategory = null;
      await fetchCategories();
      nameController.clear();
      selectedImageBytes = null;
      selectedImageName = null;
      emit(CategoriesSuccess('تم حذف التصنيف'));
    } catch (e) {
      print('Error deleting category: $e');
      emit(CategoriesError('فشل في حذف التصنيف'));
    }
  }

  void _syncControllers() {
    nameController.text = selectedCategory?.name ?? '';
  }

  @override
  Future<void> close() {
    nameController.dispose();
    return super.close();
  }
}
