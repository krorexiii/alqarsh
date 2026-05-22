import 'package:alkhafajdashboard/data/model/locationModel.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/store_locations/cubit/store_locations_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';

class StoreLocationsListPanel extends StatelessWidget {
  const StoreLocationsListPanel({
    super.key,
    required this.cubit,
    required this.isBusy,
  });

  final StoreLocationsCubit cubit;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return MyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
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
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const MyText(
                        'مواقع المتجر الحالية',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        'إجمالي المواقع: ${cubit.locations.length}',
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                MyButton(
                  text: 'موقع جديد',
                  icon: Icons.add_business_outlined,
                  variant: MyButtonVariant.secondary,
                  onPressed: isBusy ? null : cubit.startCreatingNewLocation,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: cubit.locations.isEmpty
                ? Container(
                    decoration: BoxDecoration(
                      color: ConstVar.pColor.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ConstVar.pColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: MyText(
                          'لا توجد مواقع متجر بعد. أضف أول فرع أو نقطة تجهيز للبدء.',
                          fontSize: 20,
                          color: Colors.black54,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: cubit.locations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final LocationModel location = cubit.locations[index];
                      final bool isSelected =
                          cubit.selectedLocation?.id == location.id;

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
                              : () => cubit.selectLocation(location),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.storefront_outlined,
                                    color: Colors.indigo,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      MyText(
                                        location.name,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      const SizedBox(height: 4),
                                      MyText(
                                        location.locationName.isEmpty
                                            ? 'بدون وصف إضافي'
                                            : location.locationName,
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(height: 8),
                                      MyText(
                                        '${location.lX.toStringAsFixed(4)}, ${location.lY.toStringAsFixed(4)}',
                                        fontSize: 13,
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
