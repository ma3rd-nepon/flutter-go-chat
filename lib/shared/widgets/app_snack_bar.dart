import 'package:flutter/material.dart';

import '../../core/theme/theme_extension.dart';

enum AppSnackBarType { success, error, warning, info }

abstract final class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    required AppSnackBarType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final colors = context.colors;

    Color bgColor;
    switch (type) {
      case .success:
        bgColor = colors.success;
        break;
      case .error:
        bgColor = colors.error;
        break;
      case .warning:
        bgColor = colors.warning;
        break;
      case .info:
        bgColor = colors.info;
        break;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: context.textStyles.bodyMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: .w500,
            ),
          ),
          backgroundColor: bgColor,
          behavior: .floating,
          duration: duration,
          margin: .only(
            bottom: keyboardHeight > 0 ? keyboardHeight + 16 : 16,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(borderRadius: .circular(12)),
        ),
      );
  }
}
