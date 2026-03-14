import 'dart:typed_data';

import 'package:alkhafajdashboard/data/model/categoryModel.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/categories/cubit/categories_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:alkhafajdashboard/view/widget/myTextFeild.dart';
import 'package:flutter/material.dart';

class CategoriesFormPanel extends StatelessWidget {
  const CategoriesFormPanel({
    super.key,
    required this.cubit,
    required this.isBusy,
  });

  final CategoriesCubit cubit;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final CategoryModel? selectedCategory = cubit.selectedCategory;
    final bool isEditing = selectedCategory != null;

    return MyCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isEditing
                    ? ConstVar.sColor.withValues(alpha: 0.16)
                    : ConstVar.pColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isEditing
                      ? ConstVar.sColor.withValues(alpha: 0.7)
                      : ConstVar.pColor.withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    isEditing ? 'تعديل التصنيف' : 'إنشاء تصنيف جديد',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 4),
                  MyText(
                    isEditing
                        ? 'يمكنك تعديل اسم التصنيف أو تغيير الصورة ثم حفظ التعديلات.'
                        : 'أدخل اسم التصنيف واختر صورة تمثل الأيقونة ثم احفظه لإضافته إلى القائمة.',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PreviewCard(
              bytes: cubit.selectedImageBytes,
              networkUrl: selectedCategory?.publicUrl,
              imagePath: selectedCategory?.icon,
              name: cubit.nameController.text,
            ),
            const SizedBox(height: 16),
            MyTextFeild(
              labelText: 'اسم التصنيف',
              controller: cubit.nameController,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    text: cubit.selectedImageBytes == null
                        ? 'اختيار صورة'
                        : 'تغيير الصورة',
                    icon: Icons.upload_file_outlined,
                    variant: MyButtonVariant.secondary,
                    expand: true,
                    onPressed: isBusy ? null : cubit.pickCategoryImage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image_outlined, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MyText(
                      cubit.selectedImageName ??
                          selectedCategory?.icon ??
                          'لم يتم اختيار صورة بعد',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            MyButton(
              text: isEditing ? 'حفظ التعديلات' : 'إضافة التصنيف',
              icon: isEditing ? Icons.save_outlined : Icons.add_circle_outline,
              expand: true,
              variant: MyButtonVariant.primary,
              onPressed: isBusy ? null : cubit.saveCategory,
            ),
            const SizedBox(height: 12),
            if (isEditing)
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      text: 'إلغاء التحديد',
                      icon: Icons.close_rounded,
                      variant: MyButtonVariant.ghost,
                      expand: true,
                      onPressed: isBusy ? null : cubit.startCreatingNewCategory,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyButton(
                      text: 'حذف التصنيف',
                      icon: Icons.delete_outline,
                      variant: MyButtonVariant.danger,
                      expand: true,
                      onPressed: isBusy ? null : cubit.deleteSelectedCategory,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.bytes,
    required this.networkUrl,
    required this.imagePath,
    required this.name,
  });

  final Uint8List? bytes;
  final String? networkUrl;
  final String? imagePath;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ConstVar.pColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ConstVar.pColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: _PreviewImage(bytes: bytes, networkUrl: networkUrl),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  name.isEmpty ? 'اسم التصنيف سيظهر هنا' : name,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                MyText(
                  imagePath == null || imagePath!.isEmpty
                      ? 'لا توجد صورة مضافة'
                      : imagePath!,
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({required this.bytes, required this.networkUrl});

  final Uint8List? bytes;
  final String? networkUrl;

  @override
  Widget build(BuildContext context) {
    if (bytes != null) {
      return Image.memory(bytes!, fit: BoxFit.cover, width: double.infinity);
    }

    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return Image.network(
        networkUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          size: 34,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}
