import 'package:alkhafajdashboard/data/model/categoryModel.dart';
import 'package:alkhafajdashboard/data/model/itemModel.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/items/cubit/items_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';

class ItemsListPanel extends StatelessWidget {
  const ItemsListPanel({super.key, required this.cubit, required this.isBusy});

  final ItemsCubit cubit;
  final bool isBusy;

  Future<void> _showBulkDiscountDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController(text: '10');
    final int? value = await showDialog<int>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تطبيق خصم جماعي'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'نسبة التخفيض %',
                hintText: 'مثال: 15',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  final int? percent = int.tryParse(controller.text.trim());
                  Navigator.of(context).pop(percent);
                },
                child: const Text('تطبيق'),
              ),
            ],
          ),
    );

    if (value == null) {
      return;
    }

    await cubit.applyBulkDiscountPercent(value);
  }

  @override
  Widget build(BuildContext context) {
    return MyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ConstVar.pColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ConstVar.pColor.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MyText(
                            'المنتجات الحالية',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 4),
                          MyText(
                            'إجمالي المنتجات: ${cubit.items.length}',
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    MyButton(
                      text: 'منتج جديد',
                      icon: Icons.add_box_outlined,
                      variant: MyButtonVariant.secondary,
                      onPressed: isBusy ? null : cubit.startCreateNewItem,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        value: cubit.selectedCategoryFilter?.id,
                        decoration: InputDecoration(
                          labelText: 'تصفية حسب التصنيف',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('كل التصنيفات'),
                          ),
                          ...cubit.categories.map(
                            (CategoryModel category) =>
                                DropdownMenuItem<String?>(
                                  value: category.id,
                                  child: Text(category.name ?? 'بدون اسم'),
                                ),
                          ),
                        ],
                        onChanged:
                            isBusy
                                ? null
                                : (value) {
                                  if (value == null || value.isEmpty) {
                                    cubit.clearCategoryFilter();
                                    return;
                                  }
                                  final CategoryModel? category = cubit
                                      .categories
                                      .cast<CategoryModel?>()
                                      .firstWhere(
                                        (item) => item?.id == value,
                                        orElse: () => null,
                                      );
                                  cubit.selectCategoryFilter(category);
                                },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SwitchListTile(
                        value: cubit.includeDeleted,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        title: const Text('إظهار المحذوفة'),
                        onChanged: isBusy ? null : cubit.updateIncludeDeleted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        'التحديد الجماعي: ${cubit.selectedItemsCount} منتج',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          MyButton(
                            text: 'تحديد الكل',
                            icon: Icons.select_all,
                            variant: MyButtonVariant.ghost,
                            onPressed:
                                isBusy ? null : cubit.selectAllVisibleItems,
                          ),
                          MyButton(
                            text: 'إلغاء التحديد',
                            icon: Icons.clear_all,
                            variant: MyButtonVariant.ghost,
                            onPressed: isBusy ? null : cubit.clearBulkSelection,
                          ),
                          MyButton(
                            text: 'تطبيق خصم',
                            icon: Icons.percent,
                            variant: MyButtonVariant.secondary,
                            onPressed:
                                isBusy || !cubit.hasBulkSelection
                                    ? null
                                    : () => _showBulkDiscountDialog(context),
                          ),
                          MyButton(
                            text: 'إلغاء الخصم',
                            icon: Icons.money_off,
                            variant: MyButtonVariant.secondary,
                            onPressed:
                                isBusy || !cubit.hasBulkSelection
                                    ? null
                                    : () => cubit.applyBulkDiscountPercent(0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                cubit.items.isEmpty
                    ? Container(
                      decoration: BoxDecoration(
                        color: ConstVar.pColor.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ConstVar.pColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Center(
                        child: MyText(
                          'لا توجد منتجات مطابقة حالياً.',
                          fontSize: 20,
                          color: Colors.black54,
                        ),
                      ),
                    )
                    : ListView.separated(
                      itemCount: cubit.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ItemModel item = cubit.items[index];
                        final bool isSelected =
                            cubit.selectedItem?.id == item.id;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? ConstVar.sColor.withValues(alpha: 0.18)
                                    : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? ConstVar.sColor
                                      : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: isBusy ? null : () => cubit.selectItem(item),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color:
                                          item.isDeleted == true
                                              ? Colors.red.shade50
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color:
                                            item.isDeleted == true
                                                ? Colors.red.shade200
                                                : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Icon(
                                      item.isDeleted == true
                                          ? Icons.delete_outline
                                          : item.isActive == true
                                          ? Icons.inventory_2_outlined
                                          : Icons.inventory_outlined,
                                      color:
                                          item.isDeleted == true
                                              ? Colors.red.shade400
                                              : item.isActive == true
                                              ? Colors.green.shade600
                                              : Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: MyText(
                                                item.title ?? 'منتج بدون اسم',
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Checkbox(
                                              value: cubit.isItemSelected(item),
                                              onChanged:
                                                  isBusy ||
                                                          item.isDeleted == true
                                                      ? null
                                                      : (_) => cubit
                                                          .toggleItemSelection(
                                                            item,
                                                          ),
                                            ),
                                            _StatusChip(
                                              label:
                                                  item.isDeleted == true
                                                      ? 'محذوف'
                                                      : item.isActive == true
                                                      ? 'نشط'
                                                      : 'مخفي',
                                              color:
                                                  item.isDeleted == true
                                                      ? Colors.red
                                                      : item.isActive == true
                                                      ? Colors.green
                                                      : Colors.orange,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        MyText(
                                          cubit.getCategoryName(
                                            item.categoryId,
                                          ),
                                          fontSize: 15,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(height: 6),
                                        MyText(
                                          'السعر: ${item.price?.toStringAsFixed(2) ?? '0.00'}',
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        if (item.hasDiscount) ...[
                                          const SizedBox(height: 4),
                                          MyText(
                                            'خصم ${item.discountPercent ?? 0}% -> ${item.finalPrice.toStringAsFixed(2)}',
                                            fontSize: 14,
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ],
                                        if ((item.description ?? '')
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          MyText(
                                            item.description!,
                                            fontSize: 14,
                                            color: Colors.black45,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
