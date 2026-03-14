import 'package:flutter/material.dart';

import '../../utils/constVar.dart';
import 'myText.dart';

class MyAppbar extends StatelessWidget {
  const MyAppbar({
    super.key,
    required this.title,
    required this.isBack,
    required this.actions,
  });
  final String title;
  final List<Widget> actions;
  final bool isBack;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ConstVar.pColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isBack)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back),
            )
          else
            IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu),
            ),
          Expanded(
            child: MyText(
              title,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
          ),
          Row(children: actions),
        ],
      ),
    );
  }
}
