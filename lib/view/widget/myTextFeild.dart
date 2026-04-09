import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:flutter/material.dart';

class MyTextFeild extends StatelessWidget {
  const MyTextFeild({
    super.key,
    this.labelText,
    this.obscureText,
    this.controller,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.onEnter,
    this.icon,
    this.isReadOnly,
    this.maxLines = 1,
  });

  final String? labelText;
  final bool? obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onEnter;
  final IconData? icon;
  final bool? isReadOnly;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText ?? false,
        readOnly: isReadOnly ?? false,
        maxLines: obscureText == true ? 1 : maxLines,
        onChanged: onChanged,
        onTap: onTap,
        onEditingComplete: onEnter,
        textDirection: TextDirection.rtl,
        validator: (String? value) => value == null || value.isEmpty
            ? 'يرجى إدخال ${labelText ?? 'هذه الخانة'}'
            : null,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: icon == null
              ? null
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ConstVar.panelSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: ConstVar.pColor, size: 20),
                  ),
                ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 56,
            minHeight: 56,
          ),
        ),
      ),
    );
  }
}
