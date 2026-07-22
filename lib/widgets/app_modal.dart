import 'package:flutter/material.dart';

enum AppModalType { success, error, warning, confirmation }

class AppModal {
  static Future<bool?> show(
    BuildContext context, {
    required AppModalType type,
    required String title,
    required String message,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
    bool showCancelButton = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        final icon = _iconForType(type);
        final accentColor = _colorForType(type, colorScheme);

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (type == AppModalType.confirmation || showCancelButton)
                      TextButton(
                        onPressed: () {
                          onCancel?.call();
                          Navigator.of(dialogContext).pop(false);
                        },
                        child: Text(cancelText),
                      ),
                    if (type == AppModalType.confirmation || showCancelButton)
                      const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      onPressed: () {
                        onConfirm?.call();
                        Navigator.of(dialogContext).pop(true);
                      },
                      child: Text(confirmText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static IconData _iconForType(AppModalType type) {
    if (type == AppModalType.success) {
      return Icons.check_circle_rounded;
    }
    if (type == AppModalType.error) {
      return Icons.error_rounded;
    }
    if (type == AppModalType.warning) {
      return Icons.warning_amber_rounded;
    }
    return Icons.help_outline_rounded;
  }

  static Color _colorForType(AppModalType type, ColorScheme colorScheme) {
    if (type == AppModalType.success) {
      return colorScheme.primary;
    }
    if (type == AppModalType.error) {
      return colorScheme.error;
    }
    if (type == AppModalType.warning) {
      return Colors.orange.shade700;
    }
    return colorScheme.secondary;
  }
}
