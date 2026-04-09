import 'package:flutter/material.dart';

import '../../utils/constVar.dart';
import 'myText.dart';

class MyAppbar extends StatelessWidget {
  const MyAppbar({
    super.key,
    required this.title,
    required this.isBack,
    required this.actions,
    this.subtitle,
  });

  final String title;
  final List<Widget> actions;
  final bool isBack;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
        boxShadow: ConstVar.softShadow,
      ),
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: isBack
                ? () => Navigator.of(context).maybePop()
                : () => Scaffold.of(context).openDrawer(),
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                gradient: isBack
                    ? ConstVar.accentGradient
                    : ConstVar.brandGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isBack ? Icons.arrow_forward_rounded : Icons.grid_view_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MyText(title, fontSize: 28, fontWeight: FontWeight.w900),
                if ((subtitle ?? '').trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  MyText(subtitle!, fontSize: 15, color: ConstVar.textMuted),
                ],
              ],
            ),
          ),
          if (actions.isNotEmpty) ...<Widget>[
            const SizedBox(width: 12),
            Wrap(spacing: 10, runSpacing: 10, children: actions),
          ],
        ],
      ),
    );
  }
}
