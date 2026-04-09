import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.badge = 'نسخة الإدارة',
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstVar.bgColor,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: ConstVar.heroGradient),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -90,
              right: -60,
              child: _Orb(
                size: 280,
                color: ConstVar.sColor.withValues(alpha: 0.14),
              ),
            ),
            Positioned(
              bottom: -90,
              left: -40,
              child: _Orb(
                size: 300,
                color: ConstVar.pColor.withValues(alpha: 0.09),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            final bool compact = constraints.maxWidth < 860;

                            final Widget hero = Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                gradient: ConstVar.brandGradient,
                                borderRadius: BorderRadius.circular(36),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: ConstVar.pColor.withValues(
                                      alpha: 0.24,
                                    ),
                                    blurRadius: 30,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.14,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        MyText(
                                          badge,
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  MyText(
                                    title,
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                  const SizedBox(height: 12),
                                  MyText(
                                    subtitle,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 18,
                                    height: 1.45,
                                  ),
                                  const SizedBox(height: 28),
                                  const _HeroPoint(
                                    icon: Icons.dashboard_customize_rounded,
                                    title: 'لوحة إدارة موحّدة',
                                    subtitle: 'نفس الهوية البصرية لكل الأقسام',
                                  ),
                                  const SizedBox(height: 12),
                                  const _HeroPoint(
                                    icon: Icons.translate_rounded,
                                    title: 'عربي مضبوط بالكامل',
                                    subtitle: 'اتجاه RTL وخط موحّد من الجذر',
                                  ),
                                  const SizedBox(height: 12),
                                  const _HeroPoint(
                                    icon: Icons.security_rounded,
                                    title: 'وصول آمن وسريع',
                                    subtitle:
                                        'تجربة دخول أو استعادة بسيطة وواضحة',
                                  ),
                                ],
                              ),
                            );

                            final Widget formCard = Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.88),
                                ),
                                boxShadow: ConstVar.softShadow,
                              ),
                              child: child,
                            );

                            if (compact) {
                              return Column(
                                children: <Widget>[
                                  hero,
                                  const SizedBox(height: 18),
                                  formCard,
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(flex: 6, child: hero),
                                const SizedBox(width: 22),
                                Expanded(flex: 5, child: formCard),
                              ],
                            );
                          },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPoint extends StatelessWidget {
  const _HeroPoint({
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
            width: 46,
            height: 46,
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

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
