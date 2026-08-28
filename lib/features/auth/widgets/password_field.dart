import 'package:flutter/material.dart';

import '../../../core/theme/theme_extension.dart';
import '../../../core/constants/app_icons.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.labelText,
    this.onChanged,
    this.onValidChanged,
    this.onDetailsChanged,
    this.validator,
  });

  final String? labelText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onValidChanged;
  final void Function(String email)? onDetailsChanged;

  final FormFieldValidator<String>? validator;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  final _controller = TextEditingController();
  bool _isObscured = true;
  // final _focusNode = FocusNode();
  // bool _isFocused = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();

    // _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onDetailsChanged?.call(_controller.text.trim());
      }
    });
  }

  @override
  void dispose() {
    // _focusNode.removeListener(_onFocusChange);
    // _focusNode.dispose();
    _controller.removeListener(_onTextChange);
    _controller.dispose();
    super.dispose();
  }

  // void _onFocusChange() => setState(() => _isFocused = _focusNode.hasFocus);

  void _onTextChange() {
    final RegExp passRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    final fullPass = _controller.text.trim();
    final bool valid = passRegex.hasMatch(fullPass);

    if (valid != _isValid) {
      _isValid = valid;
      // if (valid) FocusScope.of(context).unfocus();
      widget.onValidChanged?.call(valid);
    }

    widget.onChanged?.call(fullPass);
    widget.onDetailsChanged?.call(_controller.text.trim());
    setState(() {});
  }

  String get _fullPassword => _controller.text.trim();

  String _buildHint() {
    return 'Enter the password';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FormField<String>(
      validator:
          widget.validator ??
          (value) {
            if (_controller.text.isEmpty) {
              return 'Sorry, password is required.';
            }
            if (!_isValid) {
              return 'Your password is incorrect.';
            }
            return null;
          },
      builder: (field) {
        return Column(
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          children: [
            if (widget.labelText != null) ...[
              Text(
                widget.labelText!,
                style: context.textStyles.labelMedium?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: .w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
            ],

            Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    obscureText: _isObscured,
                    // focusNode: focusNode,
                    keyboardType: .visiblePassword,
                    textInputAction: .done,
                    maxLength: 20,
                    // inputFormatters: [FilteringTextInputFormatter.digitsOnly]
                    onChanged: (_) => field.didChange(_fullPassword),
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: .w500,
                    ),
                    cursorColor: colors.primary,
                    decoration: InputDecoration(
                      hintText: _buildHint(),
                      counterText: '',
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _isObscured = !_isObscured),
                        icon: Icon(_isObscured ? AppIcons.hide : AppIcons.show),
                      ),
                      hintStyle: context.textStyles.bodyMedium?.copyWith(
                        color: colors.textHint,
                      ),
                      filled: true,
                      fillColor: colors.surface,
                      contentPadding: const .symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: field.hasError ? colors.error : colors.border,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: .circular(14),
                        borderSide: BorderSide(
                          color: field.hasError ? colors.error : colors.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: .circular(14),
                        borderSide: BorderSide(color: colors.error, width: 1.5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: .circular(14),
                        borderSide: BorderSide(color: colors.error, width: 2),
                      ),
                      border: OutlineInputBorder(borderRadius: .circular(14)),
                    ),
                  ),
                ),
              ],
            ),

            if (field.hasError) ...[
              const SizedBox(height: 8),
              Text(
                field.errorText!,
                style: context.textStyles.bodySmall?.copyWith(
                  color: colors.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // void _openEmailPicker(BuildContext context) {}
}
