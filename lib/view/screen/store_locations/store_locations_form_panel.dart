import 'package:alkhafajdashboard/data/model/locationModel.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/store_locations/cubit/store_locations_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:alkhafajdashboard/view/widget/myTextFeild.dart';
import 'package:flutter/material.dart';

class StoreLocationsFormPanel extends StatelessWidget {
  const StoreLocationsFormPanel({
    super.key,
    required this.cubit,
    required this.isBusy,
  });

  final StoreLocationsCubit cubit;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final LocationModel? selectedLocation = cubit.selectedLocation;
    final bool isEditing = selectedLocation != null;

    return MyCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
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
                children: <Widget>[
                  MyText(
                    isEditing ? 'تعديل موقع المتجر' : 'إضافة موقع متجر جديد',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 4),
                  MyText(
                    isEditing
                        ? 'حدّث اسم الفرع أو وصفه أو إحداثياته ثم احفظ التغييرات.'
                        : 'أضف فرعًا أو نقطة تجهيز جديدة ليتم استخدامها في الطلبات وربط الموظفين.',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _StoreLocationPreviewCard(
              name: cubit.nameController.text,
              locationName: cubit.locationNameController.text,
              latitude: cubit.latitudeController.text,
              longitude: cubit.longitudeController.text,
            ),
            const SizedBox(height: 16),
            MyTextFeild(
              labelText: 'اسم الموقع',
              controller: cubit.nameController,
              icon: Icons.store_mall_directory_outlined,
              onChanged: (_) => cubit.notifyDraftChanged(),
            ),
            MyTextFeild(
              labelText: 'وصف الموقع أو العنوان المختصر',
              controller: cubit.locationNameController,
              icon: Icons.badge_outlined,
              onChanged: (_) => cubit.notifyDraftChanged(),
            ),
            MyTextFeild(
              labelText: 'خط العرض Latitude',
              controller: cubit.latitudeController,
              icon: Icons.pin_drop_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              onChanged: (_) => cubit.notifyDraftChanged(),
            ),
            MyTextFeild(
              labelText: 'خط الطول Longitude',
              controller: cubit.longitudeController,
              icon: Icons.explore_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              onChanged: (_) => cubit.notifyDraftChanged(),
            ),
            const SizedBox(height: 20),
            MyButton(
              text: isEditing ? 'حفظ التعديلات' : 'إضافة الموقع',
              icon: isEditing ? Icons.save_outlined : Icons.add_business,
              expand: true,
              variant: MyButtonVariant.primary,
              onPressed: isBusy ? null : cubit.saveLocation,
            ),
            const SizedBox(height: 12),
            if (isEditing)
              Row(
                children: <Widget>[
                  Expanded(
                    child: MyButton(
                      text: 'إلغاء التحديد',
                      icon: Icons.close_rounded,
                      variant: MyButtonVariant.ghost,
                      expand: true,
                      onPressed: isBusy ? null : cubit.startCreatingNewLocation,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyButton(
                      text: 'حذف الموقع',
                      icon: Icons.delete_outline,
                      variant: MyButtonVariant.danger,
                      expand: true,
                      onPressed: isBusy ? null : cubit.deleteSelectedLocation,
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

class _StoreLocationPreviewCard extends StatelessWidget {
  const _StoreLocationPreviewCard({
    required this.name,
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String locationName;
  final String latitude;
  final String longitude;

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
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: 34,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MyText(
                  name.isEmpty ? 'اسم الموقع سيظهر هنا' : name,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                MyText(
                  locationName.isEmpty
                      ? 'أضف وصفًا مختصرًا للموقع'
                      : locationName,
                  fontSize: 15,
                  color: Colors.black54,
                ),
                const SizedBox(height: 8),
                MyText(
                  'الإحداثيات: ${latitude.isEmpty ? '--' : latitude} / ${longitude.isEmpty ? '--' : longitude}',
                  fontSize: 13,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
