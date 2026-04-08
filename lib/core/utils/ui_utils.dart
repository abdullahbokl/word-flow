import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../widgets/app_text.dart';

class AppUIUtils {
  static void showSnackBar(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
      ),
    );
  }

  static Future<T?> showAppDialog<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    String? confirmLabel,
    VoidCallback? onConfirm,
    String? cancelLabel,
  }) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: AppText.title(title),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: AppText.body(cancelLabel ?? AppStrings.cancel),
          ),
          if (confirmLabel != null)
            ElevatedButton(
              onPressed: () {
                onConfirm?.call();
                Navigator.pop(ctx);
              },
              child: AppText.body(confirmLabel),
            ),
        ],
      ),
    );
  }
}
