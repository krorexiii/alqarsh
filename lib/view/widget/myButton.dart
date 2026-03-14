import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';

enum MyButtonVariant { primary, secondary, danger, ghost }

class MyButton extends StatelessWidget {
  const MyButton({
    Key? key,
    this.onPressed,
    this.text,
    this.icon,
    this.variant = MyButtonVariant.primary,
    this.expand = false,
    this.padding,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final String? text;
  final IconData? icon;
  final MyButtonVariant variant;
  final bool expand;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    final _ButtonStyle style = _resolveStyle();

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: expand ? double.infinity : null,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade300 : style.backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: style.borderColor == null
              ? null
              : Border.all(color: style.borderColor!, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: isDisabled ? Colors.transparent : style.shadowColor,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isDisabled
                    ? Colors.grey.shade600
                    : style.foregroundColor,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: MyText(
                text ?? ' أضغط هنا',
                color: isDisabled
                    ? Colors.grey.shade600
                    : style.foregroundColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ButtonStyle _resolveStyle() {
    switch (variant) {
      case MyButtonVariant.secondary:
        return _ButtonStyle(
          backgroundColor: Colors.white,
          foregroundColor: Colors.indigo,
          borderColor: Colors.indigo.withValues(alpha: 0.45),
          shadowColor: Colors.indigo.withValues(alpha: 0.08),
        );
      case MyButtonVariant.danger:
        return _ButtonStyle(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          borderColor: null,
          shadowColor: Colors.red.withValues(alpha: 0.2),
        );
      case MyButtonVariant.ghost:
        return _ButtonStyle(
          backgroundColor: Colors.grey.shade100,
          foregroundColor: Colors.black87,
          borderColor: Colors.grey.shade300,
          shadowColor: Colors.transparent,
        );
      case MyButtonVariant.primary:
        return _ButtonStyle(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          borderColor: null,
          shadowColor: Colors.black26,
        );
    }
  }
}

class _ButtonStyle {
  const _ButtonStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.shadowColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final Color shadowColor;
}
