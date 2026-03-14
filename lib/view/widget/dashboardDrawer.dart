import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/bannerAds/bannerAdsScreen.dart';
import 'package:alkhafajdashboard/view/screen/categories/categoriesScreen.dart';
import 'package:alkhafajdashboard/view/screen/delivery_zones/deliveryZonesScreen.dart';
import 'package:alkhafajdashboard/view/screen/home/homeScreen.dart';
import 'package:alkhafajdashboard/view/screen/items/itemsScreen.dart';
import 'package:alkhafajdashboard/view/screen/orders/ordersScreen.dart';
import 'package:alkhafajdashboard/view/screen/parts/partsScreen.dart';
import 'package:alkhafajdashboard/view/screen/users/usersScreen.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 310,
      child: Container(
        color: const Color(0xfff6f7fb),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ConstVar.pColor,
                    ConstVar.pColor.withValues(alpha: 0.82),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.dashboard_customize_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const MyText(
                    'لوحة التحكم',
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 6),
                  MyText(
                    'تنقل سريع ومنظم بين كل الصفحات الإدارية',
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  _DrawerTile(
                    title: 'الرئيسية',
                    icon: Icons.home_outlined,
                    isSelected: currentRoute == 'home',
                    onTap: () => _openPage(context, 'home', const HomeScreen()),
                  ),
                  _DrawerTile(
                    title: 'إدارة الطلبات',
                    icon: Icons.receipt_long_outlined,
                    isSelected: currentRoute == 'orders',
                    onTap: () =>
                        _openPage(context, 'orders', const OrdersScreen()),
                  ),
                  _DrawerTile(
                    title: 'إدارة المستخدمين',
                    icon: Icons.people_outline,
                    isSelected: currentRoute == 'users',
                    onTap: () => _openPage(context, 'users', UsersScreen()),
                  ),
                  _DrawerTile(
                    title: 'إدارة الإعلانات',
                    icon: Icons.photo_library_outlined,
                    isSelected: currentRoute == 'banner_ads',
                    onTap: () => _openPage(
                      context,
                      'banner_ads',
                      const BannerAdsScreen(),
                    ),
                  ),
                  _DrawerTile(
                    title: 'إدارة التصنيفات',
                    icon: Icons.category_outlined,
                    isSelected: currentRoute == 'categories',
                    onTap: () => _openPage(
                      context,
                      'categories',
                      const CategoriesScreen(),
                    ),
                  ),
                  _DrawerTile(
                    title: 'إدارة المنتجات',
                    icon: Icons.inventory_2_outlined,
                    isSelected: currentRoute == 'items',
                    onTap: () =>
                        _openPage(context, 'items', const ItemsScreen()),
                  ),
                  _DrawerTile(
                    title: 'إدارة الأقسام',
                    icon: Icons.view_module_outlined,
                    isSelected: currentRoute == 'parts',
                    onTap: () =>
                        _openPage(context, 'parts', const PartsScreen()),
                  ),
                  _DrawerTile(
                    title: 'مناطق التوصيل',
                    icon: Icons.local_shipping_outlined,
                    isSelected: currentRoute == 'delivery_zones',
                    onTap: () => _openPage(
                      context,
                      'delivery_zones',
                      const DeliveryZonesScreen(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: ConstVar.pColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.store_mall_directory_outlined,
                        color: ConstVar.pColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: MyText(
                        'واجهة موحدة بهوية بصرية ثابتة لكل صفحات الإدارة',
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
    ).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? ConstVar.sColor.withValues(alpha: 0.22)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ConstVar.sColor : Colors.grey.shade200,
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onTap: onTap,
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.95)
                  : ConstVar.pColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? ConstVar.pColor : ConstVar.pColor,
            ),
          ),
          title: MyText(
            title,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
