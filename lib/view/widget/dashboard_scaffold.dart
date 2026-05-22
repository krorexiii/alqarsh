import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/widget/dashboardDrawer.dart';
import 'package:flutter/material.dart';

class DashboardScaffold extends StatelessWidget {
  const DashboardScaffold({
    super.key,
    required this.currentRoute,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions = const <Widget>[],
    this.showDrawer = true,
    this.isBack = false,
    this.padding = const EdgeInsets.all(24),
  });

  final String currentRoute;
  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;
  final bool showDrawer;
  final bool isBack;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: showDrawer ? DashboardDrawer(currentRoute: currentRoute) : null,
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: ConstVar.heroGradient),
        child: Stack(
          children: <Widget>[
            const _BackgroundOrbs(),
            SafeArea(
              child: Padding(
                padding: padding,
                child: _ContentArea(
                  title: title,
                  subtitle: subtitle,
                  actions: actions,
                  isBack: isBack,
                  showMenuButton: showDrawer,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentArea extends StatelessWidget {
  const _ContentArea({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.child,
    required this.isBack,
    required this.showMenuButton,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget child;
  final bool isBack;
  final bool showMenuButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Builder(
          builder: (BuildContext context) => _DashboardHeader(
            title: title,
            subtitle: subtitle,
            actions: actions,
            isBack: isBack,
            showMenuButton: showMenuButton,
          ),
        ),
        const SizedBox(height: 22),
        Expanded(child: child),
      ],
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.isBack,
    required this.showMenuButton,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;
  final bool isBack;
  final bool showMenuButton;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
        boxShadow: ConstVar.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _LeadingButton(isBack: isBack, showMenuButton: showMenuButton),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: ConstVar.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (actions.isNotEmpty) ...<Widget>[
            const SizedBox(width: 16),
            Wrap(spacing: 10, runSpacing: 10, children: actions),
          ],
        ],
      ),
    );
  }
}

class _LeadingButton extends StatelessWidget {
  const _LeadingButton({required this.isBack, required this.showMenuButton});

  final bool isBack;
  final bool showMenuButton;

  @override
  Widget build(BuildContext context) {
    final IconData icon = isBack
        ? Icons.arrow_forward_rounded
        : showMenuButton
        ? Icons.menu_rounded
        : Icons.menu_rounded;

    return InkWell(
      onTap: isBack
          ? () => Navigator.of(context).maybePop()
          : showMenuButton
          ? () => Scaffold.of(context).openDrawer()
          : null,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: isBack ? ConstVar.accentGradient : ConstVar.brandGradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: ConstVar.softShadow,
        ),
        child: Icon(icon, color: Colors.black, size: 30),
      ),
    );
  }
}

class _BackgroundOrbs extends StatelessWidget {
  const _BackgroundOrbs();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -80,
            right: -20,
            child: _Orb(
              size: 240,
              color: ConstVar.sColor.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            top: 110,
            left: -80,
            child: _Orb(
              size: 220,
              color: ConstVar.pColor.withValues(alpha: 0.09),
            ),
          ),
          Positioned(
            bottom: -70,
            left: 140,
            child: _Orb(
              size: 260,
              color: ConstVar.pColor.withValues(alpha: 0.06),
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
