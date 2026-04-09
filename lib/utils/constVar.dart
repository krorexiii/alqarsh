import 'package:flutter/material.dart';

class ConstVar {
  static const Color pColor = Color(0xFF0B6E69);
  static const Color sColor = Color(0xFFF2B544);
  static const Color bgColor = Color(0xFFF4F6F2);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color panelSoft = Color(0xFFF8FBF8);
  static const Color borderColor = Color(0xFFD7E2DB);
  static const Color textPrimary = Color(0xFF16312D);
  static const Color textMuted = Color(0xFF60746F);
  static const Color textFaint = Color(0xFF8A9A95);
  static const Color successColor = Color(0xFF1C8C5E);
  static const Color dangerColor = Color(0xFFD35C4A);
  static const Color infoColor = Color(0xFF2A6B8F);

  static const LinearGradient heroGradient = LinearGradient(
    colors: <Color>[Color(0xFFF9F4E7), Color(0xFFEAF5F1), Color(0xFFF7FBF9)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: <Color>[Color(0xFF0B6E69), Color(0xFF12867F)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: <Color>[Color(0xFFF2B544), Color(0xFFF8D276)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const List<BoxShadow> softShadow = <BoxShadow>[
    BoxShadow(color: Color(0x14000000), blurRadius: 30, offset: Offset(0, 14)),
  ];

  static List<Roles> roleList = <Roles>[
    Roles(id: 'admin', name: 'ادمن'),
    Roles(id: 'staff', name: 'موظف'),
  ];
}

class Roles {
  final String id;
  final String name;

  Roles({required this.id, required this.name});
}
