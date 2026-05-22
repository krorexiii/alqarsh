import 'package:alkhafajdashboard/data/model/bannerAdsModel.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/bannerAds/cubit/banner_ads_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';

class BannerAdsListPanel extends StatelessWidget {
  const BannerAdsListPanel({
    super.key,
    required this.cubit,
    required this.isBusy,
  });

  final BannerAdsCubit cubit;
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        'الإعلانات الحالية',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 4),
                      MyText(
                        'رتّب البنرات من الأعلى للأسفل ثم اضغط حفظ الترتيب.',
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.end,
                  children: [
                    MyButton(
                      text: 'حفظ الترتيب',
                      icon: Icons.save_outlined,
                      variant: MyButtonVariant.primary,
                      onPressed: isBusy ? null : cubit.persistOrder,
                    ),
                    MyButton(
                      text: 'إعلان جديد',
                      icon: Icons.add_photo_alternate_outlined,
                      variant: MyButtonVariant.secondary,
                      onPressed: isBusy ? null : cubit.startCreatingNewBanner,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: cubit.ads.isEmpty
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
                        'لا توجد إعلانات بعد، ابدأ بإضافة إعلان جديد.',
                        fontSize: 20,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: cubit.ads.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final BannerAdsModel banner = cubit.ads[index];
                      final bool isSelected =
                          cubit.selectedBanner?.id == banner.id;

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
                              : () => cubit.selectBanner(banner),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _BannerImage(
                                    imageUrl: banner.publicUrl,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        'إعلان رقم ${banner.sortOrder! + 1}',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      const SizedBox(height: 2),
                                      MyText(
                                        isSelected
                                            ? 'محدد للتعديل الآن'
                                            : 'اضغط لعرضه في لوحة التعديل',
                                        fontSize: 14,
                                        color: Colors.black45,
                                      ),
                                      const SizedBox(height: 6),
                                      MyText(
                                        banner.isActive == true
                                            ? 'مفعل'
                                            : 'مخفي',
                                        color: banner.isActive == true
                                            ? Colors.green.shade700
                                            : Colors.red.shade400,
                                        fontSize: 16,
                                      ),
                                      const SizedBox(height: 6),
                                      MyText(
                                        banner.imagePath ?? '',
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          IconButton(
                                            onPressed: isBusy
                                                ? null
                                                : () =>
                                                      cubit.moveBannerUp(index),
                                            icon: const Icon(
                                              Icons.keyboard_arrow_up_rounded,
                                            ),
                                            color: ConstVar.pColor,
                                            tooltip: 'تقديم الإعلان',
                                          ),
                                          Container(
                                            width: 32,
                                            height: 1,
                                            color: Colors.grey.shade300,
                                          ),
                                          IconButton(
                                            onPressed: isBusy
                                                ? null
                                                : () => cubit.moveBannerDown(
                                                    index,
                                                  ),
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                            ),
                                            color: ConstVar.pColor,
                                            tooltip: 'تأخير الإعلان',
                                          ),
                                        ],
                                      ),
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

class _BannerImage extends StatelessWidget {
  const _BannerImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 120,
        height: 72,
        color: Colors.grey.shade200,
        child: Icon(Icons.image_outlined, color: Colors.grey.shade500),
      );
    }

    return Image.network(
      imageUrl!,
      width: 120,
      height: 72,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 120,
        height: 72,
        color: Colors.grey.shade200,
        child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade500),
      ),
    );
  }
}
