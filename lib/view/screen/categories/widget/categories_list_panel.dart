import 'package:alkhafajdashboard/data/model/categoryModel.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/categories/cubit/categories_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';

class CategoriesListPanel extends StatelessWidget {
  const CategoriesListPanel({
    super.key,
    required this.cubit,
    required this.isBusy,
  });

  final CategoriesCubit cubit;
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
                        'التصنيفات الحالية',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        'إجمالي التصنيفات: ${cubit.categories.length}',
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                MyButton(
                  text: 'تصنيف جديد',
                  icon: Icons.add_business_outlined,
                  variant: MyButtonVariant.secondary,
                  onPressed: isBusy ? null : cubit.startCreatingNewCategory,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: cubit.categories.isEmpty
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
                        'لا توجد تصنيفات بعد، ابدأ بإضافة تصنيف جديد.',
                        fontSize: 20,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: cubit.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final CategoryModel category = cubit.categories[index];
                      final bool isSelected =
                          cubit.selectedCategory?.id == category.id;

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
                              : () => cubit.selectCategory(category),
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
                                  clipBehavior: Clip.antiAlias,
                                  child: _CategoryImage(
                                    imageUrl: category.publicUrl,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        category.name ?? 'تصنيف بدون اسم',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      const SizedBox(height: 4),
                                      MyText(
                                        category.icon?.isNotEmpty == true
                                            ? category.icon!
                                            : 'بدون صورة',
                                        fontSize: 14,
                                        color: Colors.black45,
                                      ),
                                      const SizedBox(height: 6),
                                      MyText(
                                        category.id ?? '',
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

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: Icon(Icons.image_outlined, color: Colors.grey.shade500),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade500),
      ),
    );
  }
}
