import 'package:flutter/material.dart';
import 'package:pantrysaver/widgets/shared/app_shell.dart';

class PantryDialogs {
  static Future<void> showInfo(BuildContext context, {required String title, required String message}) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: PantryAppTheme.primary),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showConfirm(BuildContext context, {required String title, required String message, required String confirmLabel}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: PantryAppTheme.primary),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
