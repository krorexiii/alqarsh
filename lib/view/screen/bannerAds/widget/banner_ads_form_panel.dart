import 'dart:typed_data';

import 'package:alkhafajdashboard/data/model/bannerAdsModel.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/bannerAds/cubit/banner_ads_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';

class BannerAdsFormPanel extends StatelessWidget {
  const BannerAdsFormPanel({
    super.key,
    required this.cubit,
    required this.isBusy,
  });

  final BannerAdsCubit cubit;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final BannerAdsModel? selectedBanner = cubit.selectedBanner;
    final bool isEditing = selectedBanner != null;

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
                    isEditing ? 'تعديل الإعلان' : 'إنشاء إعلان جديد',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 4),
                  MyText(
                    isEditing
                        ? 'يمكنك تغيير الصورة أو حالة الإعلان ثم حفظ التعديلات.'
                        : 'اختر صورة واضحة، ثم فعّل الإعلان واحفظه لإضافته إلى القائمة.',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ImagePreview(
              bytes: cubit.selectedImageBytes,
              networkUrl: selectedBanner?.publicUrl,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    text: cubit.selectedImageBytes == null
                        ? 'اختيار صورة'
                        : 'تغيير الصورة',
                    icon: Icons.upload_file_outlined,
                    variant: MyButtonVariant.secondary,
                    expand: true,
                    onPressed: isBusy ? null : cubit.pickBannerImage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.image_outlined, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MyText(
                          cubit.selectedImageName ??
                              selectedBanner?.imagePath ??
                              'لم يتم اختيار صورة بعد',
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cubit.isActive
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: cubit.isActive ? ConstVar.pColor : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        MyText(
                          cubit.isActive
                              ? 'الإعلان مفعل وسيظهر للمستخدمين'
                              : 'الإعلان مخفي حالياً',
                          fontSize: 16,
                        ),
                        const Spacer(),
                        Switch(
                          value: cubit.isActive,
                          thumbColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? ConstVar.pColor
                                : null,
                          ),
                          onChanged: isBusy ? null : cubit.updateActiveStatus,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            MyButton(
              text: isEditing ? 'حفظ التعديلات' : 'إضافة الإعلان',
              icon: isEditing ? Icons.save_outlined : Icons.add_circle_outline,
              expand: true,
              variant: MyButtonVariant.primary,
              onPressed: isBusy ? null : cubit.saveBanner,
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
                      onPressed: isBusy ? null : cubit.startCreatingNewBanner,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyButton(
                      text: 'حذف الإعلان',
                      icon: Icons.delete_outline,
                      variant: MyButtonVariant.danger,
                      expand: true,
                      onPressed: isBusy ? null : cubit.deleteSelectedBanner,
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

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.bytes, required this.networkUrl});

  final Uint8List? bytes;
  final String? networkUrl;

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (bytes != null) {
      child = Image.memory(bytes!, fit: BoxFit.cover, width: double.infinity);
    } else if (networkUrl != null && networkUrl!.isNotEmpty) {
      child = Image.network(
        networkUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else {
      child = _placeholder();
    }

    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ConstVar.pColor.withValues(alpha: 0.25)),
        color: ConstVar.pColor.withValues(alpha: 0.03),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          size: 70,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}
