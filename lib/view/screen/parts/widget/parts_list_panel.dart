import 'package:alkhafajdashboard/data/model/partModel.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/parts/cubit/parts_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';

class PartsListPanel extends StatelessWidget {
  const PartsListPanel({super.key, required this.cubit, required this.isBusy});

  final PartsCubit cubit;
  final bool isBusy;

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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MyText(
                        'الأقسام الحالية',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        'إجمالي الأقسام: ${cubit.parts.length}',
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        'يمكنك تحريك الأقسام لأعلى وأسفل ثم حفظ الترتيب.',
                        fontSize: 14,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    MyButton(
                      text: 'قسم جديد',
                      icon: Icons.add_box_outlined,
                      variant: MyButtonVariant.secondary,
                      onPressed: isBusy ? null : cubit.startCreatingNewPart,
                    ),
                    const SizedBox(height: 8),
                    MyButton(
                      text: 'حفظ الترتيب',
                      icon: Icons.save_outlined,
                      variant: MyButtonVariant.primary,
                      onPressed: isBusy || cubit.parts.isEmpty
                          ? null
                          : cubit.persistOrder,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: cubit.parts.isEmpty
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
                        'لا توجد أقسام بعد، ابدأ بإنشاء قسم جديد.',
                        fontSize: 20,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: cubit.parts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final PartModel part = cubit.parts[index];
                      final bool isSelected = cubit.selectedPart?.id == part.id;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ConstVar.sColor.withValues(alpha: 0.18)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? ConstVar.sColor
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: isBusy ? null : () => cubit.selectPart(part),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: part.isActive == true
                                        ? Colors.white
                                        : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: part.isActive == true
                                          ? Colors.grey.shade300
                                          : Colors.orange.shade200,
                                    ),
                                  ),
                                  child: Icon(
                                    part.isActive == true
                                        ? Icons.view_module_outlined
                                        : Icons.visibility_off_outlined,
                                    color: part.isActive == true
                                        ? Colors.indigo
                                        : Colors.orange.shade600,
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
                                              part.name ?? 'قسم بدون اسم',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          _StatusChip(
                                            label: part.isActive == true
                                                ? 'نشط'
                                                : 'مخفي',
                                            color: part.isActive == true
                                                ? Colors.green
                                                : Colors.orange,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      MyText(
                                        'الترتيب: ${part.sortOrder ?? 1}',
                                        fontSize: 15,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(height: 6),
                                      MyText(
                                        'المنتجات المرتبطة: ${cubit.selectedPart?.id == part.id ? cubit.selectedItemIds.length : '-'}',
                                        fontSize: 14,
                                        color: Colors.black45,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  children: [
                                    IconButton(
                                      onPressed: isBusy
                                          ? null
                                          : () => cubit.movePartUp(index),
                                      icon: const Icon(Icons.keyboard_arrow_up),
                                      tooltip: 'تحريك لأعلى',
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        '#${(part.sortOrder ?? index) + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: isBusy
                                          ? null
                                          : () => cubit.movePartDown(index),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                      ),
                                      tooltip: 'تحريك لأسفل',
                                    ),
                                  ],
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
