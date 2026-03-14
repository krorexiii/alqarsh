import 'package:alkhafajdashboard/data/model/deliveryZoneModel.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/delivery_zones/cubit/delivery_zones_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';

class DeliveryZonesListPanel extends StatelessWidget {
  const DeliveryZonesListPanel({
    super.key,
    required this.cubit,
    required this.isBusy,
  });

  final DeliveryZonesCubit cubit;
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
                        'مناطق التوصيل الحالية',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        'إجمالي المناطق: ${cubit.deliveryZones.length}',
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                MyButton(
                  text: 'منطقة جديدة',
                  icon: Icons.add_location_alt_outlined,
                  variant: MyButtonVariant.secondary,
                  onPressed: isBusy ? null : cubit.startCreatingNewDeliveryZone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: cubit.deliveryZones.isEmpty
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
                        'لا توجد مناطق توصيل بعد، ابدأ بإضافة منطقة جديدة.',
                        fontSize: 20,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: cubit.deliveryZones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final DeliveryZoneModel zone = cubit.deliveryZones[index];
                      final bool isSelected =
                          cubit.selectedDeliveryZone?.id == zone.id;

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
                          onTap: isBusy
                              ? null
                              : () => cubit.selectDeliveryZone(zone),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.local_shipping_outlined,
                                    color: Colors.indigo,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        zone.city ?? 'مدينة بدون اسم',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      const SizedBox(height: 4),
                                      MyText(
                                        'السعر: ${zone.price?.toStringAsFixed(2) ?? '0.00'}',
                                        fontSize: 14,
                                        color: Colors.black45,
                                      ),
                                      const SizedBox(height: 6),
                                      MyText(
                                        zone.id?.toString() ?? '',
                                        fontSize: 12,
                                        color: Colors.black38,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: ConstVar.sColor,
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
