import 'package:alkhafajdashboard/data/model/discountCodeModel.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/discount_codes/cubit/discount_codes_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';

class DiscountCodesListPanel extends StatelessWidget {
  const DiscountCodesListPanel({
    super.key,
    required this.cubit,
    required this.isBusy,
  });

  final DiscountCodesCubit cubit;
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MyText(
                        'أكواد الخصم الحالية',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        'إجمالي الأكواد: ${cubit.discountCodes.length}',
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                MyButton(
                  text: 'كود جديد',
                  icon: Icons.add_rounded,
                  variant: MyButtonVariant.secondary,
                  onPressed: isBusy ? null : cubit.startCreatingNewDiscountCode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: cubit.discountCodes.isEmpty
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
                        'لا توجد أكواد خصم بعد، ابدأ بإضافة أول برومو كود.',
                        fontSize: 20,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: cubit.discountCodes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final DiscountCodeModel item = cubit.discountCodes[index];
                      final bool isSelected =
                          cubit.selectedDiscountCode?.id == item.id;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ConstVar.sColor.withValues(alpha: 0.16)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? ConstVar.sColor
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: isBusy
                              ? null
                              : () => cubit.selectDiscountCode(item),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: item.isActive && !item.isExpired
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.local_offer_rounded,
                                    color: item.isActive && !item.isExpired
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        item.normalizedCode,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: [
                                          _InfoBadge(text: item.discountLabel),
                                          _InfoBadge(
                                            text:
                                                'الحد الأدنى ${item.minPurchaseAmount.toStringAsFixed(0)}',
                                          ),
                                          _InfoBadge(
                                            text:
                                                'الصلاحية ${item.expiryDate.year}/${item.expiryDate.month.toString().padLeft(2, '0')}/${item.expiryDate.day.toString().padLeft(2, '0')}',
                                          ),
                                          _InfoBadge(
                                            text: item.limitCount == null
                                                ? 'غير محدود'
                                                : '${item.usedCount}/${item.limitCount} استخدام',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: item.isActive && !item.isExpired
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: MyText(
                                        item.isExpired
                                            ? 'منتهي'
                                            : item.isActive
                                            ? 'نشط'
                                            : 'متوقف',
                                        fontSize: 13,
                                        color: item.isActive && !item.isExpired
                                            ? Colors.green.shade800
                                            : Colors.red.shade800,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: ConstVar.sColor,
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

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: MyText(
        text,
        fontSize: 12,
        color: Colors.black54,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
