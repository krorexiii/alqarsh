import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  const MyText(
    this.text, {
    super.key,
    this.color,
    double? fontSize,
    double? size,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
  }) : fontSize = fontSize ?? size;

  final String? text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle =
        Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: color ?? ConstVar.textPrimary,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: height,
        ) ??
        TextStyle(
          color: color ?? ConstVar.textPrimary,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: height,
          fontFamily: 'Zain',
        );

    return Text(
      text ?? '',
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: baseStyle,
    );
  }
}
