import 'package:flutter/material.dart';

class ConstVar {
  static const Color pColor = Colors.indigo;
  static const Color sColor = Color.fromARGB(255, 255, 197, 21);

  static List<Roles> roleList = [
    Roles(id: "admin", name: "ادمن"),
    Roles(id: "staff", name: "موظف"),
  ];
}

class Roles {
  final String id;
  final String name;

  Roles({required this.id, required this.name});
}
