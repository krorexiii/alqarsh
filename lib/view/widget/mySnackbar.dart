import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:flutter/material.dart';

enum SnackbarType { success, error, info }

void showMySnackbar(
  BuildContext context, {
  required String title,
  required String message,
  required SnackbarType type,
}) {
  final Color bgColor;
  final IconData icon;

  switch (type) {
    case SnackbarType.success:
      bgColor = ConstVar.successColor;
      icon = Icons.check_circle_rounded;
      break;
    case SnackbarType.error:
      bgColor = ConstVar.dangerColor;
      icon = Icons.error_rounded;
      break;
    case SnackbarType.info:
      bgColor = ConstVar.infoColor;
      icon = Icons.info_rounded;
      break;
  }

  final SnackBar snackBar = SnackBar(
    duration: const Duration(seconds: 4),
    content: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: bgColor.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    fontFamily: 'Zain',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Zain',
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
          ),
        ],
      ),
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
