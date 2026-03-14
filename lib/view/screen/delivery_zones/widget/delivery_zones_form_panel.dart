import 'package:alkhafajdashboard/data/model/deliveryZoneModel.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/delivery_zones/cubit/delivery_zones_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:alkhafajdashboard/view/widget/myTextFeild.dart';
import 'package:flutter/material.dart';

class DeliveryZonesFormPanel extends StatelessWidget {
  const DeliveryZonesFormPanel({
    super.key,
    required this.cubit,
    required this.isBusy,
  });

  final DeliveryZonesCubit cubit;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final DeliveryZoneModel? selectedDeliveryZone = cubit.selectedDeliveryZone;
    final bool isEditing = selectedDeliveryZone != null;

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
                    isEditing
                        ? 'تعديل منطقة التوصيل'
                        : 'إنشاء منطقة توصيل جديدة',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 4),
                  MyText(
                    isEditing
                        ? 'يمكنك تعديل اسم المدينة أو سعر التوصيل ثم حفظ التعديلات.'
                        : 'أدخل اسم المدينة وسعر التوصيل ثم احفظها لإضافتها إلى القائمة.',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PreviewCard(
              city: cubit.cityController.text,
              price: cubit.priceController.text,
            ),
            const SizedBox(height: 16),
            MyTextFeild(
              labelText: 'اسم المدينة',
              controller: cubit.cityController,
            ),
            MyTextFeild(
              labelText: 'سعر التوصيل',
              controller: cubit.priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 20),
            MyButton(
              text: isEditing ? 'حفظ التعديلات' : 'إضافة المنطقة',
              icon: isEditing ? Icons.save_outlined : Icons.add_circle_outline,
              expand: true,
              variant: MyButtonVariant.primary,
              onPressed: isBusy ? null : cubit.saveDeliveryZone,
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
                          : cubit.startCreatingNewDeliveryZone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyButton(
                      text: 'حذف المنطقة',
                      icon: Icons.delete_outline,
                      variant: MyButtonVariant.danger,
                      expand: true,
                      onPressed: isBusy
                          ? null
                          : cubit.deleteSelectedDeliveryZone,
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
  const _PreviewCard({required this.city, required this.price});

  final String city;
  final String price;

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
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 34,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  city.isEmpty ? 'اسم المدينة سيظهر هنا' : city,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                MyText(
                  'سعر التوصيل: ${price.isEmpty ? '0' : price}',
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
