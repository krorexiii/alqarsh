import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';

enum MyButtonVariant { primary, secondary, danger, ghost }

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    this.onPressed,
    this.text,
    this.icon,
    this.variant = MyButtonVariant.primary,
    this.expand = false,
    this.padding,
  });

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
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: expand ? double.infinity : null,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: isDisabled ? null : style.gradient,
          color: isDisabled
              ? Colors.grey.shade300
              : style.gradient == null
              ? style.backgroundColor
              : null,
          borderRadius: BorderRadius.circular(18),
          border: style.borderColor == null
              ? null
              : Border.all(color: style.borderColor!, width: 1.2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isDisabled ? Colors.transparent : style.shadowColor,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (icon != null) ...<Widget>[
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
                text ?? 'اضغط هنا',
                color: isDisabled
                    ? Colors.grey.shade600
                    : style.foregroundColor,
                fontSize: 17,
                fontWeight: FontWeight.w800,
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
          foregroundColor: ConstVar.pColor,
          borderColor: ConstVar.borderColor,
          shadowColor: ConstVar.pColor.withValues(alpha: 0.08),
        );
      case MyButtonVariant.danger:
        return _ButtonStyle(
          backgroundColor: ConstVar.dangerColor,
          foregroundColor: Colors.white,
          borderColor: null,
          shadowColor: ConstVar.dangerColor.withValues(alpha: 0.22),
        );
      case MyButtonVariant.ghost:
        return _ButtonStyle(
          backgroundColor: Colors.white.withValues(alpha: 0.78),
          foregroundColor: ConstVar.textPrimary,
          borderColor: ConstVar.borderColor,
          shadowColor: Colors.black.withValues(alpha: 0.02),
        );
      case MyButtonVariant.primary:
        return _ButtonStyle(
          backgroundColor: ConstVar.pColor,
          foregroundColor: Colors.white,
          borderColor: null,
          shadowColor: ConstVar.pColor.withValues(alpha: 0.22),
          gradient: ConstVar.brandGradient,
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
    this.gradient,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final Color shadowColor;
  final Gradient? gradient;
}
