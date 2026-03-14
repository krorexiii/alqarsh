import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyTextFeild extends StatefulWidget {
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
  });
  final String? labelText;
  final bool? obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Function()? onTap;
  final Function()? onEnter;
  final IconData? icon;
  final bool? isReadOnly;

  @override
  _MyTextFeildState createState() => _MyTextFeildState();
}

class _MyTextFeildState extends State<MyTextFeild> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText ?? false,
        readOnly: widget.isReadOnly ?? false,

        onChanged: widget.onChanged,
        onTap: widget.onTap,
        onEditingComplete: widget.onEnter,

        validator: (value) => value == null || value.isEmpty
            ? 'يرجى إدخال ${widget.labelText}'
            : null,
        decoration: InputDecoration(
          prefixIcon: widget.icon != null
              ? Icon(widget.icon, color: Colors.indigo)
              : null,
          labelText: widget.labelText,
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }
}
