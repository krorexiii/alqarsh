import 'package:alkhafajdashboard/view/widget/dashboardDrawer.dart';
import 'package:flutter/material.dart';

import '../../widget/myAppbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DashboardDrawer(currentRoute: 'home'),
      backgroundColor: const Color(0xfff6f7fb),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Builder(
                builder: (context) => const MyAppbar(
                  title: "لوحة التحكم",
                  isBack: false,
                  actions: [],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'مرحباً بك في لوحة التحكم',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'استخدم القائمة الجانبية للتنقل بين كل الصفحات الإدارية بنفس هوية بصرية موحدة ومنظمة.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              children: const [
                                _DashboardStatCard(
                                  title: 'واجهة موحدة',
                                  subtitle: 'Drawer مشترك لكل الصفحات',
                                  icon: Icons.dashboard_outlined,
                                ),
                                _DashboardStatCard(
                                  title: 'تنقل أسرع',
                                  subtitle: 'كل الصفحات في مكان واحد',
                                  icon: Icons.alt_route_outlined,
                                ),
                                _DashboardStatCard(
                                  title: 'هوية ثابتة',
                                  subtitle: 'نفس الأسلوب البصري في كامل النظام',
                                  icon: Icons.palette_outlined,
                                ),
                                _DashboardStatCard(
                                  title: 'إدارة الطلبات',
                                  subtitle: 'تحويل الطلبات حسب أقرب موقع',
                                  icon: Icons.receipt_long_outlined,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'وصول سريع',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'من خلال زر القائمة أعلى الصفحة يمكنك الوصول لأي قسم إداري مباشرة.',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 18),
                            Expanded(
                              child: ListView(
                                children: const [
                                  _QuickAccessTile(
                                    icon: Icons.receipt_long_outlined,
                                    title: 'إدارة الطلبات',
                                  ),
                                  _QuickAccessTile(
                                    icon: Icons.people_outline,
                                    title: 'إدارة المستخدمين',
                                  ),
                                  _QuickAccessTile(
                                    icon: Icons.photo_library_outlined,
                                    title: 'إدارة الإعلانات',
                                  ),
                                  _QuickAccessTile(
                                    icon: Icons.category_outlined,
                                    title: 'إدارة التصنيفات',
                                  ),
                                  _QuickAccessTile(
                                    icon: Icons.inventory_2_outlined,
                                    title: 'إدارة المنتجات',
                                  ),
                                  _QuickAccessTile(
                                    icon: Icons.view_module_outlined,
                                    title: 'إدارة الأقسام',
                                  ),
                                  _QuickAccessTile(
                                    icon: Icons.local_shipping_outlined,
                                    title: 'مناطق التوصيل',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
}

class _DashboardStatCard extends StatelessWidget {
  const _DashboardStatCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.indigo, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
