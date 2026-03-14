import 'dart:typed_data';

import 'package:alkhafajdashboard/data/model/categoryModel.dart';
import 'package:alkhafajdashboard/data/model/itemImageModel.dart';
import 'package:alkhafajdashboard/data/model/itemModel.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/items/cubit/items_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:alkhafajdashboard/view/widget/myTextFeild.dart';
import 'package:flutter/material.dart';

class ItemsFormPanel extends StatelessWidget {
  const ItemsFormPanel({super.key, required this.cubit, required this.isBusy});

  final ItemsCubit cubit;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final ItemModel? selectedItem = cubit.selectedItem;
    final bool isEditing = selectedItem != null;

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
                    isEditing ? 'تعديل المنتج' : 'إضافة منتج جديد',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 4),
                  MyText(
                    isEditing
                        ? 'عدل بيانات المنتج، أضف الصور أو غيّر حالته ثم احفظ.'
                        : 'أدخل بيانات المنتج، حدّد التصنيف وارفع صورة واحدة أو عدة صور دفعة واحدة.',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _HeroPreviewCard(
              bytes: cubit.pendingImages.isNotEmpty
                  ? cubit.pendingImages.first.bytes
                  : null,
              imageUrl: cubit.itemImages.isNotEmpty
                  ? cubit.itemImages
                        .firstWhere(
                          (item) => item.isPrimary == true,
                          orElse: () => cubit.itemImages.first,
                        )
                        .publicUrl
                  : null,
              title: cubit.titleController.text,
              priceText: cubit.priceController.text,
              categoryName: cubit.getCategoryName(cubit.selectedCategoryId),
            ),
            const SizedBox(height: 16),
            MyTextFeild(
              labelText: 'اسم المنتج',
              controller: cubit.titleController,
            ),
            MyTextFeild(
              labelText: 'الوصف',
              controller: cubit.descriptionController,
            ),
            MyTextFeild(
              labelText: 'السعر',
              controller: cubit.priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: cubit.selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'التصنيف',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              items: cubit.categories
                  .map(
                    (CategoryModel category) => DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category.name ?? 'بدون اسم'),
                    ),
                  )
                  .toList(),
              onChanged: isBusy ? null : cubit.setCategoryId,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('المنتج نشط'),
              subtitle: const Text('إذا كان مغلقاً سيظهر كمخفي داخل القائمة'),
              value: cubit.isActive,
              onChanged: isBusy ? null : cubit.updateItemActiveStatus,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    text: cubit.pendingImages.isEmpty
                        ? 'اختيار صور للمنتج'
                        : 'إضافة صور أخرى',
                    icon: Icons.upload_file_outlined,
                    variant: MyButtonVariant.secondary,
                    expand: true,
                    onPressed: isBusy ? null : cubit.pickItemImage,
                  ),
                ),
              ],
            ),
            if (cubit.pendingImages.isNotEmpty) ...[
              const SizedBox(height: 8),
              const MyText(
                'الصور المحددة للرفع',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              ...List.generate(cubit.pendingImages.length, (index) {
                final pendingImage = cubit.pendingImages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PendingImageTile(
                    image: pendingImage,
                    index: index,
                    isBusy: isBusy,
                    onSetPrimary: () => cubit.setPendingImagePrimary(index),
                    onRemove: () => cubit.removePendingImageAt(index),
                  ),
                );
              }),
            ],
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
                      cubit.pendingImages.isEmpty
                          ? 'لا توجد صور جديدة محددة حالياً'
                          : 'تم اختيار ${cubit.pendingImages.length} صورة جاهزة للرفع',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            MyButton(
              text: isEditing ? 'حفظ التعديلات' : 'إضافة المنتج',
              icon: isEditing ? Icons.save_outlined : Icons.add_circle_outline,
              expand: true,
              variant: MyButtonVariant.primary,
              onPressed: isBusy ? null : cubit.saveItem,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    text: 'إلغاء التحديد',
                    icon: Icons.close_rounded,
                    variant: MyButtonVariant.ghost,
                    expand: true,
                    onPressed: isBusy ? null : cubit.startCreateNewItem,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MyButton(
                    text: isEditing && selectedItem.isDeleted == true
                        ? 'استعادة المنتج'
                        : 'أرشفة المنتج',
                    icon: isEditing && selectedItem.isDeleted == true
                        ? Icons.restore
                        : Icons.archive_outlined,
                    variant: MyButtonVariant.secondary,
                    expand: true,
                    onPressed: !isEditing || isBusy
                        ? null
                        : selectedItem.isDeleted == true
                        ? cubit.restoreSelectedItem
                        : cubit.deleteSelectedItem,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MyButton(
              text: 'حذف نهائي',
              icon: Icons.delete_forever_outlined,
              variant: MyButtonVariant.danger,
              expand: true,
              onPressed: !isEditing || isBusy
                  ? null
                  : () => cubit.deleteSelectedItem(permanent: true),
            ),
            const SizedBox(height: 20),
            _ImagesSection(cubit: cubit, isBusy: isBusy),
          ],
        ),
      ),
    );
  }
}

class _PendingImageTile extends StatelessWidget {
  const _PendingImageTile({
    required this.image,
    required this.index,
    required this.isBusy,
    required this.onSetPrimary,
    required this.onRemove,
  });

  final PendingItemImage image;
  final int index;
  final bool isBusy;
  final VoidCallback onSetPrimary;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: image.isPrimary ? Colors.green.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Image.memory(image.bytes, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  'صورة جديدة ${index + 1}',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                MyText(image.name, fontSize: 13, color: Colors.black45),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              MyButton(
                text: image.isPrimary ? 'رئيسية' : 'اجعلها رئيسية',
                icon: Icons.star_outline,
                variant: MyButtonVariant.secondary,
                onPressed: isBusy || image.isPrimary ? null : onSetPrimary,
              ),
              const SizedBox(height: 8),
              MyButton(
                text: 'إزالة',
                icon: Icons.close,
                variant: MyButtonVariant.ghost,
                onPressed: isBusy ? null : onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPreviewCard extends StatelessWidget {
  const _HeroPreviewCard({
    required this.bytes,
    required this.imageUrl,
    required this.title,
    required this.priceText,
    required this.categoryName,
  });

  final Uint8List? bytes;
  final String? imageUrl;
  final String title;
  final String priceText;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ConstVar.pColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ConstVar.pColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _PreviewImage(bytes: bytes, imageUrl: imageUrl),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  title.isEmpty ? 'اسم المنتج سيظهر هنا' : title,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 6),
                MyText(
                  'التصنيف: $categoryName',
                  fontSize: 15,
                  color: Colors.black54,
                ),
                const SizedBox(height: 6),
                MyText(
                  'السعر: ${priceText.isEmpty ? '0' : priceText}',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
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
  const _PreviewImage({required this.bytes, required this.imageUrl});

  final Uint8List? bytes;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (bytes != null) {
      return Image.memory(bytes!, fit: BoxFit.cover, width: double.infinity);
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
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

class _ImagesSection extends StatelessWidget {
  const _ImagesSection({required this.cubit, required this.isBusy});

  final ItemsCubit cubit;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MyText('صور المنتج', fontSize: 20, fontWeight: FontWeight.bold),
        const SizedBox(height: 8),
        if (cubit.selectedItem == null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const MyText(
              'احفظ المنتج أولاً أو اختر منتجاً موجوداً لإدارة صوره.',
              fontSize: 16,
              color: Colors.black54,
            ),
          )
        else if (cubit.itemImages.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const MyText(
              'لا توجد صور مرفوعة لهذا المنتج بعد.',
              fontSize: 16,
              color: Colors.black54,
            ),
          )
        else
          Column(
            children: cubit.itemImages
                .map(
                  (ItemImageModel image) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ImageTile(
                      image: image,
                      isBusy: isBusy,
                      onSetPrimary: () => cubit.setPrimaryImage(image),
                      onDelete: () => cubit.deleteImage(image),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    required this.image,
    required this.isBusy,
    required this.onSetPrimary,
    required this.onDelete,
  });

  final ItemImageModel image;
  final bool isBusy;
  final VoidCallback onSetPrimary;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: image.isPrimary == true
              ? Colors.green.shade300
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: image.publicUrl != null && image.publicUrl!.isNotEmpty
                ? Image.network(
                    image.publicUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey.shade500,
                    ),
                  )
                : Icon(Icons.image_outlined, color: Colors.grey.shade500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MyText(
                        image.isPrimary == true
                            ? 'الصورة الرئيسية'
                            : 'صورة إضافية',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (image.isPrimary == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'أساسية',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                MyText(
                  image.imagePath ?? '',
                  fontSize: 13,
                  color: Colors.black45,
                ),
                const SizedBox(height: 6),
                MyText(
                  'الترتيب: ${image.sortOrder ?? 1}',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              MyButton(
                text: 'رئيسية',
                icon: Icons.star_outline,
                variant: MyButtonVariant.secondary,
                onPressed: isBusy || image.isPrimary == true
                    ? null
                    : onSetPrimary,
              ),
              const SizedBox(height: 8),
              MyButton(
                text: 'حذف',
                icon: Icons.delete_outline,
                variant: MyButtonVariant.danger,
                onPressed: isBusy ? null : onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
