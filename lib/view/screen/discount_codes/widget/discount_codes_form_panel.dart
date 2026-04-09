import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/discount_codes/cubit/discount_codes_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:alkhafajdashboard/view/widget/myTextFeild.dart';
import 'package:flutter/material.dart';

class DiscountCodesFormPanel extends StatelessWidget {
  const DiscountCodesFormPanel({
    super.key,
    required this.cubit,
    required this.isBusy,
  });

  final DiscountCodesCubit cubit;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final bool isEditing = cubit.selectedDiscountCode != null;
    final String previewCode = cubit.codeController.text.trim().isEmpty
        ? 'PROMO2026'
        : cubit.codeController.text.trim().toUpperCase();
    final String previewDiscount = cubit.selectedDiscountType == 'percent'
        ? '${cubit.discountPercentController.text.trim().isEmpty ? '0' : cubit.discountPercentController.text.trim()}%'
        : '${cubit.discountAmountController.text.trim().isEmpty ? '0' : cubit.discountAmountController.text.trim()} د.ع';

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
                    isEditing ? 'تعديل البرومو كود' : 'إنشاء برومو كود جديد',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 4),
                  MyText(
                    isEditing
                        ? 'حدّث تفاصيل الكود وصلاحيته وحدود استخدامه ثم احفظ التعديلات.'
                        : 'أدخل الكود وقيمة الخصم والصلاحية وعدد مرات الاستخدام ثم احفظه.',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: ConstVar.brandGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    previewCode,
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PreviewBadge(label: 'الخصم', value: previewDiscount),
                      _PreviewBadge(
                        label: 'الحد الأدنى',
                        value:
                            '${cubit.minPurchaseController.text.trim().isEmpty ? '0' : cubit.minPurchaseController.text.trim()} د.ع',
                      ),
                      _PreviewBadge(
                        label: 'الصلاحية',
                        value:
                            '${cubit.expiryDate.year}/${cubit.expiryDate.month.toString().padLeft(2, '0')}/${cubit.expiryDate.day.toString().padLeft(2, '0')}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            MyTextFeild(
              labelText: 'رمز الخصم',
              controller: cubit.codeController,
              onChanged: (_) => cubit.notifyFormChanged(),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              key: ValueKey<String>(cubit.selectedDiscountType),
              initialValue: cubit.selectedDiscountType,
              onChanged: isBusy ? null : cubit.setDiscountType,
              decoration: const InputDecoration(labelText: 'نوع الخصم'),
              items: const [
                DropdownMenuItem(value: 'percent', child: Text('نسبة مئوية')),
                DropdownMenuItem(value: 'amount', child: Text('مبلغ ثابت')),
              ],
            ),
            if (cubit.selectedDiscountType == 'percent')
              MyTextFeild(
                labelText: 'نسبة الخصم',
                controller: cubit.discountPercentController,
                keyboardType: TextInputType.number,
                onChanged: (_) => cubit.notifyFormChanged(),
              )
            else
              MyTextFeild(
                labelText: 'قيمة الخصم',
                controller: cubit.discountAmountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => cubit.notifyFormChanged(),
              ),
            MyTextFeild(
              labelText: 'الحد الأدنى للشراء',
              controller: cubit.minPurchaseController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => cubit.notifyFormChanged(),
            ),
            MyTextFeild(
              labelText: 'الحد الأعلى للخصم (اختياري)',
              controller: cubit.maxDiscountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => cubit.notifyFormChanged(),
            ),
            MyTextFeild(
              labelText: 'عدد مرات الاستخدام (اختياري)',
              controller: cubit.limitCountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => cubit.notifyFormChanged(),
            ),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isBusy
                  ? null
                  : () async {
                      final DateTime now = DateTime.now();
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: cubit.expiryDate,
                        firstDate: DateTime(now.year, now.month, now.day),
                        lastDate: DateTime(now.year + 5),
                      );
                      if (picked != null) {
                        cubit.setExpiryDate(picked);
                      }
                    },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: ConstVar.panelSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: ConstVar.pColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MyText(
                            'تاريخ انتهاء الصلاحية',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                          const SizedBox(height: 4),
                          MyText(
                            '${cubit.expiryDate.year}/${cubit.expiryDate.month.toString().padLeft(2, '0')}/${cubit.expiryDate.day.toString().padLeft(2, '0')}',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              value: cubit.isActive,
              onChanged: isBusy ? null : cubit.setIsActive,
              title: const Text('الكود مفعل'),
              subtitle: Text(
                cubit.isActive
                    ? 'سيظهر كود الخصم للاستخدام في التطبيق'
                    : 'الكود محفوظ لكن غير مفعل حاليًا',
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            MyButton(
              text: isEditing ? 'حفظ التعديلات' : 'إضافة البرومو كود',
              icon: isEditing ? Icons.save_outlined : Icons.add_circle_outline,
              expand: true,
              variant: MyButtonVariant.primary,
              onPressed: isBusy ? null : cubit.saveDiscountCode,
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
                      onPressed: isBusy
                          ? null
                          : cubit.startCreatingNewDiscountCode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyButton(
                      text: 'حذف الكود',
                      icon: Icons.delete_outline,
                      variant: MyButtonVariant.danger,
                      expand: true,
                      onPressed: isBusy
                          ? null
                          : cubit.deleteSelectedDiscountCode,
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

class _PreviewBadge extends StatelessWidget {
  const _PreviewBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            label,
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 4),
          MyText(
            value,
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ],
      ),
    );
  }
}
