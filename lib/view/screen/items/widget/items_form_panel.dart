import 'dart:typed_data';

import 'package:alkhafajdashboard/data/model/categoryModel.dart';
import 'package:alkhafajdashboard/data/model/itemColorModel.dart';
import 'package:alkhafajdashboard/data/model/itemImageModel.dart';
import 'package:alkhafajdashboard/data/model/itemModel.dart';
import 'package:alkhafajdashboard/data/model/itemSizeModel.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/items/cubit/items_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:alkhafajdashboard/view/widget/myTextFeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
            MyTextFeild(
              labelText: 'نسبة التخفيض %',
              controller: cubit.discountPercentController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final double price =
                    double.tryParse(cubit.priceController.text.trim()) ?? 0;
                final int percent =
                    int.tryParse(cubit.discountPercentController.text.trim()) ??
                    0;
                final double finalPrice = percent > 0
                    ? price * (1 - (percent / 100))
                    : price;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        'المعادلة: السعر بعد التخفيض = السعر الاصلي × (1 - نسبة التخفيض / 100)',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 6),
                      MyText(
                        'السعر النهائي: ${finalPrice.toStringAsFixed(2)}',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ],
                  ),
                );
              },
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
            _OptionSectionCard(
              title: 'ألوان المنتج',
              subtitle:
                  'اختر اللون من الدائرة أو الألوان السريعة، ويمكنك إضافة أكثر من لون لنفس المنتج.',
              icon: Icons.palette_outlined,
              child: _ColorOptionsEditor(cubit: cubit, isBusy: isBusy),
            ),
            const SizedBox(height: 12),
            _OptionSectionCard(
              title: 'أحجام المنتج',
              subtitle:
                  'الأحجام تظهر للعميل كخيارات اختيار قبل الإضافة إلى السلة.',
              icon: Icons.straighten_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isCompact = constraints.maxWidth < 760;
                      if (isCompact) {
                        return Column(
                          children: [
                            _OptionTextField(
                              controller: cubit.sizeNameController,
                              label: 'اسم الحجم',
                              hint: 'مثلاً: M أو 42',
                              enabled: !isBusy,
                            ),
                            const SizedBox(height: 10),
                            MyButton(
                              text: 'إضافة الحجم',
                              icon: Icons.add_circle_outline,
                              expand: true,
                              onPressed: isBusy ? null : cubit.addItemSize,
                            ),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _OptionTextField(
                              controller: cubit.sizeNameController,
                              label: 'اسم الحجم',
                              hint: 'مثلاً: M أو 42',
                              enabled: !isBusy,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 170,
                            child: MyButton(
                              text: 'إضافة الحجم',
                              icon: Icons.add_circle_outline,
                              expand: true,
                              onPressed: isBusy ? null : cubit.addItemSize,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  if (cubit.itemSizes.isEmpty)
                    const _OptionEmptyState(
                      message: 'لم يتم إضافة أحجام لهذا المنتج بعد.',
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List<Widget>.generate(cubit.itemSizes.length, (
                        index,
                      ) {
                        return _SizeOptionChip(
                          size: cubit.itemSizes[index],
                          onRemove: isBusy
                              ? null
                              : () => cubit.removeItemSizeAt(index),
                        );
                      }),
                    ),
                ],
              ),
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

class _ColorOptionsEditor extends StatelessWidget {
  const _ColorOptionsEditor({required this.cubit, required this.isBusy});

  final ItemsCubit cubit;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OptionTextField(
          controller: cubit.colorNameController,
          label: 'اسم اللون (كلمتين كحد أقصى)',
          hint: 'مثلاً: أسود أو أزرق فاتح',
          enabled: !isBusy,
        ),
        const SizedBox(height: 12),
        _ColorPickerCard(
          controller: cubit.colorHexController,
          enabled: !isBusy,
          onPickColor: cubit.setDraftColorHex,
          onClear: cubit.clearDraftColorHex,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final Widget hexField = _OptionTextField(
              controller: cubit.colorHexController,
              label: 'Hex اختياري',
              hint: '#000000',
              enabled: !isBusy,
            );

            final Widget addButton = MyButton(
              text: 'إضافة اللون',
              icon: Icons.add_circle_outline,
              expand: true,
              onPressed: isBusy ? null : cubit.addItemColor,
            );

            final bool isCompact = constraints.maxWidth < 760;
            if (isCompact) {
              return Column(
                children: [hexField, const SizedBox(height: 10), addButton],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: hexField),
                const SizedBox(width: 12),
                SizedBox(width: 190, child: addButton),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: ConstVar.pColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ConstVar.pColor.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: ConstVar.pColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'يمكنك إضافة أكثر من لون لنفس المنتج، وسيظهر كل لون كخيار مستقل للعميل.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (cubit.itemColors.isEmpty)
          const _OptionEmptyState(
            message: 'لم يتم إضافة ألوان لهذا المنتج بعد.',
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List<Widget>.generate(cubit.itemColors.length, (index) {
              return _ColorOptionChip(
                color: cubit.itemColors[index],
                onRemove: isBusy ? null : () => cubit.removeItemColorAt(index),
              );
            }),
          ),
      ],
    );
  }
}

class _ColorPickerCard extends StatelessWidget {
  const _ColorPickerCard({
    required this.controller,
    required this.enabled,
    required this.onPickColor,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String?> onPickColor;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final String hexCode = value.text.trim().toUpperCase();
        final Color previewColor = _parseHexColor(hexCode);
        final bool hasColor = _isValidHexCode(hexCode);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: hasColor ? previewColor : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            hasColor && previewColor.computeLuminance() > 0.75
                            ? Colors.grey.shade400
                            : Colors.grey.shade300,
                        width: 1.4,
                      ),
                    ),
                    child: !hasColor
                        ? Icon(
                            Icons.palette_outlined,
                            color: Colors.grey.shade500,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'اختيار اللون',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasColor
                              ? 'اللون الحالي: $hexCode'
                              : 'اختر لونًا من الدائرة أو من الألوان السريعة.',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 170,
                    child: MyButton(
                      text: hasColor ? 'تغيير اللون' : 'اختيار اللون',
                      icon: Icons.color_lens_outlined,
                      expand: true,
                      onPressed: enabled
                          ? () =>
                                _openPickerDialog(context, initialHex: hexCode)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'ألوان سريعة',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _colorPresets.map((preset) {
                  return _ColorPresetButton(
                    preset: preset,
                    isSelected: preset.hexCode == hexCode,
                    enabled: enabled,
                    onTap: () => onPickColor(preset.hexCode),
                  );
                }).toList(),
              ),
              if (hasColor) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: enabled ? onClear : null,
                    icon: const Icon(Icons.layers_clear_outlined),
                    label: const Text('مسح اللون المختار'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _openPickerDialog(
    BuildContext context, {
    required String initialHex,
  }) async {
    Color selectedColor = _isValidHexCode(initialHex)
        ? _parseHexColor(initialHex)
        : ConstVar.pColor;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('اختيار اللون'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HueRingPicker(
                      pickerColor: selectedColor,
                      onColorChanged: (Color color) {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      enableAlpha: false,
                      displayThumbColor: true,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _ColorDialogPreview(color: selectedColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _colorToHex(selectedColor),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                onPickColor(_colorToHex(selectedColor));
                Navigator.of(dialogContext).pop();
              },
              child: const Text('اعتماد'),
            ),
          ],
        );
      },
    );
  }
}

class _ColorPresetButton extends StatelessWidget {
  const _ColorPresetButton({
    required this.preset,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final _ColorPreset preset;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = _parseHexColor(preset.hexCode);
    final bool isLight = color.computeLuminance() > 0.75;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? ConstVar.pColor.withValues(alpha: 0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? ConstVar.pColor : Colors.grey.shade300,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLight ? Colors.grey.shade400 : Colors.transparent,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              preset.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDialogPreview extends StatelessWidget {
  const _ColorDialogPreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final bool isLight = color.computeLuminance() > 0.75;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isLight ? Colors.grey.shade400 : Colors.transparent,
        ),
      ),
    );
  }
}

class _OptionSectionCard extends StatelessWidget {
  const _OptionSectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: ConstVar.pColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: ConstVar.pColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(title, fontSize: 19, fontWeight: FontWeight.bold),
                    const SizedBox(height: 4),
                    MyText(subtitle, fontSize: 14, color: Colors.black54),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _OptionTextField extends StatelessWidget {
  const _OptionTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.enabled,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ConstVar.pColor, width: 1.4),
        ),
      ),
    );
  }
}

class _OptionEmptyState extends StatelessWidget {
  const _OptionEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
      ),
    );
  }
}

class _ColorOptionChip extends StatelessWidget {
  const _ColorOptionChip({required this.color, required this.onRemove});

  final ItemColorModel color;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ColorSwatch(hexCode: color.hexCode),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                color.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if ((color.hexCode ?? '').isNotEmpty)
                Text(
                  color.hexCode!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 16, color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeOptionChip extends StatelessWidget {
  const _SizeOptionChip({required this.size, required this.onRemove});

  final ItemSizeModel size;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: ConstVar.pColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.straighten_outlined,
              size: 18,
              color: ConstVar.pColor,
            ),
          ),
          const SizedBox(width: 10),
          Text(size.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 16, color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.hexCode});

  final String? hexCode;

  @override
  Widget build(BuildContext context) {
    final Color fillColor = _parseHexColor(hexCode);
    final bool hasVisibleColor = fillColor != Colors.transparent;
    final bool isLight = hasVisibleColor && fillColor.computeLuminance() > 0.75;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isLight ? Colors.grey.shade400 : Colors.transparent,
        ),
      ),
      child: !hasVisibleColor
          ? Icon(Icons.palette_outlined, size: 18, color: Colors.grey[600])
          : null,
    );
  }
}

const List<_ColorPreset> _colorPresets = <_ColorPreset>[
  _ColorPreset(label: 'أسود', hexCode: '#000000'),
  _ColorPreset(label: 'أبيض', hexCode: '#FFFFFF'),
  _ColorPreset(label: 'أحمر', hexCode: '#E53935'),
  _ColorPreset(label: 'أزرق', hexCode: '#1E88E5'),
  _ColorPreset(label: 'أخضر', hexCode: '#43A047'),
  _ColorPreset(label: 'أصفر', hexCode: '#FDD835'),
  _ColorPreset(label: 'برتقالي', hexCode: '#FB8C00'),
  _ColorPreset(label: 'بنفسجي', hexCode: '#8E24AA'),
  _ColorPreset(label: 'وردي', hexCode: '#D81B60'),
  _ColorPreset(label: 'بني', hexCode: '#6D4C41'),
  _ColorPreset(label: 'رمادي', hexCode: '#757575'),
  _ColorPreset(label: 'ذهبي', hexCode: '#C9A227'),
];

class _ColorPreset {
  const _ColorPreset({required this.label, required this.hexCode});

  final String label;
  final String hexCode;
}

Color _parseHexColor(String? value) {
  final String? hex = value?.trim();
  if (hex == null || hex.isEmpty) {
    return Colors.transparent;
  }

  final String normalized = hex.replaceFirst('#', '');
  if (normalized.length != 6) {
    return Colors.transparent;
  }

  final int? parsed = int.tryParse('FF$normalized', radix: 16);
  if (parsed == null) {
    return Colors.transparent;
  }

  return Color(parsed);
}

bool _isValidHexCode(String? value) {
  final String? hex = value?.trim().toUpperCase();
  if (hex == null || hex.isEmpty) {
    return false;
  }
  return RegExp(r'^#[0-9A-F]{6}$').hasMatch(hex);
}

String _colorToHex(Color color) {
  final String red = (color.r * 255.0)
      .round()
      .clamp(0, 255)
      .toRadixString(16)
      .padLeft(2, '0');
  final String green = (color.g * 255.0)
      .round()
      .clamp(0, 255)
      .toRadixString(16)
      .padLeft(2, '0');
  final String blue = (color.b * 255.0)
      .round()
      .clamp(0, 255)
      .toRadixString(16)
      .padLeft(2, '0');
  return '#$red$green$blue'.toUpperCase();
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
