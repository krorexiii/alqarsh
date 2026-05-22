import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/bannerAds/bannerAdsScreen.dart';
import 'package:alkhafajdashboard/view/screen/categories/categoriesScreen.dart';
import 'package:alkhafajdashboard/view/screen/discount_codes/discountCodesScreen.dart';
import 'package:alkhafajdashboard/view/screen/delivery_zones/deliveryZonesScreen.dart';
import 'package:alkhafajdashboard/view/screen/home/homeScreen.dart';
import 'package:alkhafajdashboard/view/screen/items/itemsScreen.dart';
import 'package:alkhafajdashboard/view/screen/notifications/notificationsScreen.dart';
import 'package:alkhafajdashboard/view/screen/orders/ordersScreen.dart';
import 'package:alkhafajdashboard/view/screen/parts/partsScreen.dart';
import 'package:alkhafajdashboard/view/screen/store_locations/store_locations_screen.dart';
import 'package:alkhafajdashboard/view/screen/users/usersScreen.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screen/users/cubit/users_cubit.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 340,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 0, 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
            boxShadow: ConstVar.softShadow,
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
                decoration: BoxDecoration(
                  gradient: ConstVar.brandGradient,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(34),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const MyText(
                      'قائمة التحكم',
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    _DrawerTile(
                      title: 'الرئيسية',
                      subtitle: 'نظرة شاملة وسريعة',
                      icon: Icons.home_rounded,
                      isSelected: currentRoute == 'home',
                      onTap: () =>
                          _openPage(context, 'home', const HomeScreen()),
                    ),
                    _DrawerTile(
                      title: 'الطلبات',
                      subtitle: 'مراقبة الحالة والتجهيز',
                      icon: Icons.receipt_long_rounded,
                      isSelected: currentRoute == 'orders',
                      onTap: () =>
                          _openPage(context, 'orders', const OrdersScreen()),
                    ),
                    _DrawerTile(
                      title: 'المستخدمون',
                      subtitle: 'إدارة الصلاحيات والمواقع',
                      icon: Icons.people_alt_rounded,
                      isSelected: currentRoute == 'users',
                      onTap: () {
                        BlocProvider.of<UsersCubit>(context).fetchUsers();
                        _openPage(context, 'users', const UsersScreen());
                      },
                    ),
                    _DrawerTile(
                      title: 'الإعلانات',
                      subtitle: 'البانرات والحملات المرئية',
                      icon: Icons.photo_library_rounded,
                      isSelected: currentRoute == 'banner_ads',
                      onTap: () => _openPage(
                        context,
                        'banner_ads',
                        const BannerAdsScreen(),
                      ),
                    ),
                    _DrawerTile(
                      title: 'التصنيفات',
                      subtitle: 'تنظيم هيكل المتجر',
                      icon: Icons.category_rounded,
                      isSelected: currentRoute == 'categories',
                      onTap: () => _openPage(
                        context,
                        'categories',
                        const CategoriesScreen(),
                      ),
                    ),
                    _DrawerTile(
                      title: 'المنتجات',
                      subtitle: 'إدارة المخزون والعروض',
                      icon: Icons.inventory_2_rounded,
                      isSelected: currentRoute == 'items',
                      onTap: () =>
                          _openPage(context, 'items', const ItemsScreen()),
                    ),
                    _DrawerTile(
                      title: 'الأقسام',
                      subtitle: 'أجزاء الواجهة الرئيسية',
                      icon: Icons.view_module_rounded,
                      isSelected: currentRoute == 'parts',
                      onTap: () =>
                          _openPage(context, 'parts', const PartsScreen()),
                    ),
                    _DrawerTile(
                      title: 'أكواد الخصم',
                      subtitle: 'إدارة البرومو كود والعروض',
                      icon: Icons.local_offer_rounded,
                      isSelected: currentRoute == 'discount_codes',
                      onTap: () => _openPage(
                        context,
                        'discount_codes',
                        const DiscountCodesScreen(),
                      ),
                    ),
                    _DrawerTile(
                      title: 'مناطق التوصيل',
                      subtitle: 'التسعير حسب المدينة',
                      icon: Icons.local_shipping_rounded,
                      isSelected: currentRoute == 'delivery_zones',
                      onTap: () => _openPage(
                        context,
                        'delivery_zones',
                        const DeliveryZonesScreen(),
                      ),
                    ),
                    _DrawerTile(
                      title: 'مواقع المتجر',
                      subtitle: 'الفروع ونقاط تجهيز الطلبات',
                      icon: Icons.storefront_rounded,
                      isSelected: currentRoute == 'store_locations',
                      onTap: () => _openPage(
                        context,
                        'store_locations',
                        const StoreLocationsScreen(),
                      ),
                    ),
                    _DrawerTile(
                      title: 'الإشعارات',
                      subtitle: 'الحملات والتنبيهات',
                      icon: Icons.notifications_active_rounded,
                      isSelected: currentRoute == 'notifications',
                      onTap: () => _openPage(
                        context,
                        'notifications',
                        const NotificationsScreen(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPage(
    BuildContext context,
    String route,
    Widget page,
  ) async {
    if (currentRoute == route) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pop();
    await Future<void>.delayed(const Duration(milliseconds: 180));

    if (!context.mounted) {
      return;
    }

    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isSelected ? ConstVar.brandGradient : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected ? Colors.transparent : ConstVar.borderColor,
              ),
              boxShadow: isSelected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: ConstVar.pColor.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.18)
                        : ConstVar.panelSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : ConstVar.pColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      MyText(
                        title,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : ConstVar.textPrimary,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        subtitle,
                        fontSize: 14,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.84)
                            : ConstVar.textMuted,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.9)
                      : ConstVar.textFaint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
