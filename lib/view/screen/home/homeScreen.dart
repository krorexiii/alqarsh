import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/bannerAds/bannerAdsScreen.dart';
import 'package:alkhafajdashboard/view/screen/categories/categoriesScreen.dart';
import 'package:alkhafajdashboard/view/screen/discount_codes/discountCodesScreen.dart';
import 'package:alkhafajdashboard/view/screen/delivery_zones/deliveryZonesScreen.dart';
import 'package:alkhafajdashboard/view/screen/items/itemsScreen.dart';
import 'package:alkhafajdashboard/view/screen/notifications/notificationsScreen.dart';
import 'package:alkhafajdashboard/view/screen/orders/ordersScreen.dart';
import 'package:alkhafajdashboard/view/screen/parts/partsScreen.dart';
import 'package:alkhafajdashboard/view/screen/users/usersScreen.dart';
import 'package:alkhafajdashboard/view/widget/dashboard_scaffold.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      currentRoute: 'home',
      title: 'لوحة التحكم',
      subtitle:
          'إدارة حديثة ومرتبة للمتجر بالكامل: الطلبات، المنتجات، المحتوى، المستخدمون والإشعارات ضمن تجربة عربية احترافية.',
      child: ListView(
        children: <Widget>[
          const _HomeHero(),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool compact = constraints.maxWidth < 1120;
              if (compact) {
                return Column(
                  children: const <Widget>[
                    _MetricsGrid(),
                    SizedBox(height: 22),
                    _HomeChecklist(),
                    SizedBox(height: 22),
                    _QuickLaunchGrid(),
                  ],
                );
              }

              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 5, child: _QuickLaunchGrid()),
                  SizedBox(width: 22),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: <Widget>[
                        _MetricsGrid(),
                        SizedBox(height: 22),
                        _HomeChecklist(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: ConstVar.brandGradient,
        borderRadius: BorderRadius.circular(34),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: ConstVar.pColor.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 760;
          final Widget textSide = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    MyText(
                      'نسخة إدارة احترافية',
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const MyText(
                'كل أدوات الإدارة في مساحة واحدة واضحة وسريعة.',
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
              const SizedBox(height: 10),
              MyText(
                'ابدأ من الطلبات أو المنتجات، وحرّك كل شيء من واجهة موحّدة تليق بالمتجر وتدعم العربية بالكامل.',
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 17,
                height: 1.4,
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  MyButton(
                    text: 'إدارة الطلبات',
                    icon: Icons.receipt_long_rounded,
                    variant: MyButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const OrdersScreen(),
                      ),
                    ),
                  ),
                  MyButton(
                    text: 'إدارة المنتجات',
                    icon: Icons.inventory_2_rounded,
                    variant: MyButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const ItemsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );

          final Widget visualSide = Container(
            width: compact ? double.infinity : 320,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _MiniBadge(
                  icon: Icons.bolt_rounded,
                  title: 'تنقل أسرع',
                  subtitle: 'وصول مباشر لكل قسم',
                ),
                SizedBox(height: 12),
                _MiniBadge(
                  icon: Icons.checklist_rtl_rounded,
                  title: 'نظام مرتب',
                  subtitle: 'واجهات موحّدة ومقروءة',
                ),
                SizedBox(height: 12),
                _MiniBadge(
                  icon: Icons.translate_rounded,
                  title: 'عربي مضبوط',
                  subtitle: 'RTL وخط موحّد من الجذر',
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                textSide,
                const SizedBox(height: 18),
                visualSide,
              ],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(flex: 6, child: textSide),
              const SizedBox(width: 18),
              Expanded(flex: 4, child: visualSide),
            ],
          );
        },
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MyText(
                  title,
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
                const SizedBox(height: 4),
                MyText(subtitle, color: Colors.white70, fontSize: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _MetricCard(
                title: 'نظام موحّد',
                value: '10',
                caption: 'أقسام رئيسية',
                icon: Icons.dashboard_rounded,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _MetricCard(
                title: 'إدارة مرنة',
                value: '100%',
                caption: 'تجربة عربية',
                icon: Icons.auto_fix_high_rounded,
              ),
            ),
          ],
        ),
        SizedBox(height: 14),
        Row(
          children: <Widget>[
            Expanded(
              child: _MetricCard(
                title: 'وصول مباشر',
                value: '1',
                caption: 'شريط تنقل واضح',
                icon: Icons.route_rounded,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _MetricCard(
                title: 'هوية بصرية',
                value: 'جديدة',
                caption: 'ألوان وبطاقات احترافية',
                icon: Icons.palette_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
  });

  final String title;
  final String value;
  final String caption;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return MyCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ConstVar.panelSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: ConstVar.pColor),
          ),
          const SizedBox(height: 18),
          MyText(
            title,
            fontSize: 17,
            color: ConstVar.textMuted,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 8),
          MyText(value, fontSize: 28, fontWeight: FontWeight.w900),
          const SizedBox(height: 4),
          MyText(caption, fontSize: 14, color: ConstVar.textFaint),
        ],
      ),
    );
  }
}

class _HomeChecklist extends StatelessWidget {
  const _HomeChecklist();

  @override
  Widget build(BuildContext context) {
    return MyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          MyText(
            'قائمة العمل السريعة',
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
          SizedBox(height: 8),
          MyText(
            'ابدأ من هذه المهام اليومية لتبقى الإدارة مرتبة وواضحة.',
            fontSize: 15,
            color: ConstVar.textMuted,
          ),
          SizedBox(height: 18),
          _ChecklistTile(
            title: 'مراجعة الطلبات الجديدة وتوزيعها',
            subtitle: 'ابدأ من شاشة الطلبات وتأكد من الحالات المعلقة',
          ),
          _ChecklistTile(
            title: 'تحديث المنتجات والعروض',
            subtitle: 'أضف المنتجات أو عدّل الخصومات والصور',
          ),
          _ChecklistTile(
            title: 'مراجعة البانرات والإشعارات',
            subtitle: 'حافظ على الواجهة التسويقية نشطة ومحدّثة',
          ),
          _ChecklistTile(
            title: 'تأكيد مناطق التوصيل والمستخدمين',
            subtitle: 'راجع الأدوار وأسعار التوصيل حسب المدينة',
          ),
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ConstVar.panelSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ConstVar.borderColor),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: ConstVar.accentGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MyText(title, fontSize: 17, fontWeight: FontWeight.w800),
                  const SizedBox(height: 4),
                  MyText(subtitle, fontSize: 14, color: ConstVar.textMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLaunchGrid extends StatelessWidget {
  const _QuickLaunchGrid();

  @override
  Widget build(BuildContext context) {
    const List<_LaunchItem> items = <_LaunchItem>[
      _LaunchItem(
        title: 'الطلبات',
        subtitle: 'تتبع الحالة والتجهيز',
        icon: Icons.receipt_long_rounded,
        destination: OrdersScreen(),
      ),
      _LaunchItem(
        title: 'المنتجات',
        subtitle: 'تعديل التفاصيل والأسعار',
        icon: Icons.inventory_2_rounded,
        destination: ItemsScreen(),
      ),
      _LaunchItem(
        title: 'التصنيفات',
        subtitle: 'تنظيم بنية المتجر',
        icon: Icons.category_rounded,
        destination: CategoriesScreen(),
      ),
      _LaunchItem(
        title: 'الإعلانات',
        subtitle: 'إدارة البانرات',
        icon: Icons.photo_library_rounded,
        destination: BannerAdsScreen(),
      ),
      _LaunchItem(
        title: 'الأقسام',
        subtitle: 'عناصر الواجهة الرئيسية',
        icon: Icons.view_module_rounded,
        destination: PartsScreen(),
      ),
      _LaunchItem(
        title: 'المستخدمون',
        subtitle: 'إدارة الصلاحيات',
        icon: Icons.people_alt_rounded,
        destination: UsersScreen(),
      ),
      _LaunchItem(
        title: 'أكواد الخصم',
        subtitle: 'إنشاء البرومو كود والعروض',
        icon: Icons.local_offer_rounded,
        destination: DiscountCodesScreen(),
      ),
      _LaunchItem(
        title: 'مناطق التوصيل',
        subtitle: 'التسعير حسب المدينة',
        icon: Icons.local_shipping_rounded,
        destination: DeliveryZonesScreen(),
      ),
      _LaunchItem(
        title: 'الإشعارات',
        subtitle: 'إرسال حملات وتنبيهات',
        icon: Icons.notifications_active_rounded,
        destination: NotificationsScreen(),
      ),
    ];

    return MyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const MyText(
            'الوصول السريع',
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
          const SizedBox(height: 8),
          const MyText(
            'كل قسم مصمم كمساحة عمل مستقلة لكن ضمن نفس الهوية البصرية.',
            fontSize: 15,
            color: ConstVar.textMuted,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: items
                .map(
                  (_LaunchItem item) => _LaunchCard(
                    item: item,
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(builder: (_) => item.destination),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LaunchCard extends StatelessWidget {
  const _LaunchCard({required this.item, required this.onTap});

  final _LaunchItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: ConstVar.panelSoft,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ConstVar.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: ConstVar.brandGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(item.icon, color: Colors.white),
                ),
                const SizedBox(height: 18),
                MyText(item.title, fontSize: 20, fontWeight: FontWeight.w900),
                const SizedBox(height: 6),
                MyText(
                  item.subtitle,
                  fontSize: 14,
                  color: ConstVar.textMuted,
                  height: 1.35,
                ),
                const SizedBox(height: 18),
                const Row(
                  children: <Widget>[
                    MyText(
                      'فتح القسم',
                      fontSize: 15,
                      color: ConstVar.pColor,
                      fontWeight: FontWeight.w800,
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14,
                      color: ConstVar.pColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LaunchItem {
  const _LaunchItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.destination,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget destination;
}
