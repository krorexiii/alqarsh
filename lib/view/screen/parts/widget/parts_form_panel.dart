import 'package:alkhafajdashboard/data/model/itemModel.dart';
import 'package:alkhafajdashboard/data/model/partModel.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/parts/cubit/parts_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:alkhafajdashboard/view/widget/myTextFeild.dart';
import 'package:flutter/material.dart';

class PartsFormPanel extends StatelessWidget {
  const PartsFormPanel({super.key, required this.cubit, required this.isBusy});

  final PartsCubit cubit;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final PartModel? selectedPart = cubit.selectedPart;
    final bool isEditing = selectedPart != null;
    final linkedItems = cubit.linkedItemsPreview();

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
                    isEditing ? 'تعديل القسم' : 'إنشاء قسم جديد',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 4),
                  MyText(
                    isEditing
                        ? 'يمكنك تعديل بيانات القسم وربط عدة منتجات به أو إلغاء الربط.'
                        : 'أنشئ قسماً جديداً ثم اختر المنتجات التي تريد إسنادها إليه.',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SummaryCard(
              title: cubit.nameController.text,
              isActive: cubit.isActive,
              itemsCount: cubit.selectedItemIds.length,
              orderText:
                  'الترتيب الحالي: ${selectedPart?.sortOrder ?? cubit.parts.length + 1}',
            ),
            const SizedBox(height: 16),
            MyTextFeild(
              labelText: 'اسم القسم',
              controller: cubit.nameController,
            ),
            MyTextFeild(
              labelText: 'الترتيب',
              controller: cubit.sortOrderController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('القسم نشط'),
              subtitle: const Text('يمكنك إخفاء القسم مؤقتاً بدون حذفه'),
              value: cubit.isActive,
              onChanged: isBusy ? null : cubit.updateActiveStatus,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  MyText(
                    'ربط المنتجات',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 4),
                  MyText(
                    'يمكنك اختيار عدة منتجات للقسم نفسه، والمنتج نفسه يمكن ربطه مع أكثر من قسم.',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            MyTextFeild(
              labelText: 'ابحث باسم المنتج',
              onChanged: cubit.updateSearchQuery,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MyText(cubit.selectedItemsSummary(), fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 280),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: cubit.filteredItems.isEmpty
                  ? const Center(
                      child: MyText(
                        'لا توجد منتجات متاحة أو مطابقة للبحث.',
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    )
                  : ListView.separated(
                      itemCount: cubit.filteredItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 14),
                      itemBuilder: (context, index) {
                        final ItemModel item = cubit.filteredItems[index];
                        final bool isSelected = cubit.selectedItemIds.contains(
                          item.id,
                        );

                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: isSelected,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: isBusy || item.id == null
                              ? null
                              : (_) => cubit.toggleItemSelection(item.id!),
                          title: Text(item.title ?? 'منتج بدون اسم'),
                          subtitle: Text(
                            'السعر: ${item.price?.toStringAsFixed(2) ?? '0.00'}',
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            MyButton(
              text: isEditing ? 'حفظ التعديلات' : 'إضافة القسم',
              icon: isEditing ? Icons.save_outlined : Icons.add_circle_outline,
              expand: true,
              variant: MyButtonVariant.primary,
              onPressed: isBusy ? null : cubit.savePart,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    text: 'قسم جديد',
                    icon: Icons.add_box_outlined,
                    variant: MyButtonVariant.ghost,
                    expand: true,
                    onPressed: isBusy ? null : cubit.startCreatingNewPart,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MyButton(
                    text: 'حذف القسم',
                    icon: Icons.delete_outline,
                    variant: MyButtonVariant.danger,
                    expand: true,
                    onPressed: !isEditing || isBusy
                        ? null
                        : cubit.deleteSelectedPart,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const MyText(
              'المنتجات المرتبطة حالياً',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            if (linkedItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const MyText(
                  'لا توجد منتجات مرتبطة بهذا القسم حالياً.',
                  fontSize: 16,
                  color: Colors.black54,
                ),
              )
            else
              Column(
                children: linkedItems
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _LinkedItemTile(item: item),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.isActive,
    required this.itemsCount,
    required this.orderText,
  });

  final String title;
  final bool isActive;
  final int itemsCount;
  final String orderText;

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
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? Colors.grey.shade300 : Colors.orange.shade200,
              ),
            ),
            child: Icon(
              isActive
                  ? Icons.view_module_outlined
                  : Icons.visibility_off_outlined,
              color: isActive ? Colors.indigo : Colors.orange.shade600,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  title.isEmpty ? 'اسم القسم سيظهر هنا' : title,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 6),
                MyText(
                  isActive ? 'الحالة: نشط' : 'الحالة: مخفي',
                  fontSize: 15,
                  color: Colors.black54,
                ),
                const SizedBox(height: 6),
                MyText(
                  'عدد المنتجات: $itemsCount',
                  fontSize: 15,
                  color: Colors.black54,
                ),
                const SizedBox(height: 6),
                MyText(orderText, fontSize: 15, color: Colors.black45),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedItemTile extends StatelessWidget {
  const _LinkedItemTile({required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.isActive == true
                  ? Colors.white
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(
              item.isActive == true
                  ? Icons.inventory_2_outlined
                  : Icons.inventory_outlined,
              color: item.isActive == true ? Colors.indigo : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  item.title ?? 'منتج بدون اسم',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                MyText(
                  'السعر: ${item.price?.toStringAsFixed(2) ?? '0.00'}',
                  fontSize: 14,
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
