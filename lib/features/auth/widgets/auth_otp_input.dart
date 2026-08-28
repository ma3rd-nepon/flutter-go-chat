import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/theme/theme_extension.dart';

class AuthOtpInput extends StatelessWidget {
  const AuthOtpInput({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.hasError = false,
    required this.controller
  });

  final PinInputController controller;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
  
    return MaterialPinField(
      pinController: controller,
      length: 6,
      keyboardType: .number,
      onCompleted: onCompleted,
      onChanged: onChanged,
      theme: MaterialPinTheme(
        shape: .outlined,
        cellSize: Size(46, 54),
        spacing: 8,
        borderRadius: .circular(12),
        borderWidth: 1.5,
        focusedBorderWidth: 2.0,

        fillColor: colors.surface,
        borderColor: colors.border,

        filledFillColor: colors.surfaceElevated,
        filledBorderColor: colors.borderActive,

        focusedFillColor: colors.surfaceSelected,
        focusedBorderColor: colors.borderActive,

        errorColor: colors.error,
        errorBorderColor: colors.error,

        textStyle: context.textStyles.headlineLarge?.copyWith(
          color: colors.textPrimary,
          fontSize: 20
        )
      )
    );
  }
}