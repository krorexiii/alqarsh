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
      bgColor = const Color(0xff2ecc71);
      icon = Icons.check_circle_rounded;
    case SnackbarType.error:
      bgColor = const Color(0xffe74c3c);
      icon = Icons.error_rounded;
    case SnackbarType.info:
      bgColor = const Color(0xff3498db);
      icon = Icons.info_rounded;
  }

  final snackBar = SnackBar(
    elevation: 6,
    backgroundColor: Colors.transparent,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    duration: const Duration(seconds: 4),
    content: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            child: const Icon(Icons.close, color: Colors.white70, size: 20),
          ),
        ],
      ),
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
