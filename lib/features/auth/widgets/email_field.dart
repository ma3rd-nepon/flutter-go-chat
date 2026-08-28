import 'package:flutter/material.dart';

import '../../../core/theme/theme_extension.dart';

// abstract class EmailCode {
//   static const gmail = "@gmail.com";
//   static const yandex = "@yandex.ru";
//   static const mail = "@mail.ru";
//   static const rambler = "@rambler.ru";
//   static const outlook = "@outlook.com";
//   static const proton = "@proton.me";
//   static const icloud = "@icloud.com";
//   static const tutanota = "@tutanota.com";
// }

enum EmailCode {
  gmail('@gmail.com'),
  yandex('@yandex.ru'),
  mail('@mail.ru'),
  rambler('@rambler.ru'),
  outlook('@outlook.com'),
  proton('@proton.me'),
  icloud('@icloud.com'),
  tutanota('@tutanota.com');

  final String code;
  const EmailCode(this.code);
}

class EmailField extends StatefulWidget {
  const EmailField({
    super.key,
    this.labelText,
    // this.initialEmailCode = .gmail,
    this.onChanged,
    this.onValidChanged,
    this.onDetailsChanged,
    this.validator
  });

  final String? labelText;
  // final EmailCode initialEmailCode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onValidChanged;
  final void Function(String email)? onDetailsChanged;

  final FormFieldValidator<String>? validator;

  @override
  State<EmailField> createState() => _EmailFieldState();

}

class _EmailFieldState extends State<EmailField> {
  // late EmailCode _currentCode;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();

    // _currentCode = widget.initialEmailCode;
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onDetailsChanged?.call(_controller.text.trim());
      }
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.removeListener(_onTextChange);
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() => _isFocused = _focusNode.hasFocus);

  void _onTextChange() {
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]{1,64}@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    // final fullEmail = '${_controller.text.trim()}${_currentCode.code}';
    final fullEmail = _controller.text.trim();
    final bool valid = emailRegex.hasMatch(fullEmail);

    if (valid != _isValid) {
      _isValid = valid;
      // if (valid) FocusScope.of(context).unfocus();
      widget.onValidChanged?.call(valid);
    }

    widget.onChanged?.call(fullEmail);
    widget.onDetailsChanged?.call(_controller.text.trim());
    setState(() {});
  }

  // void _onEmailCodeSelected(EmailCode code) {
  //   setState(() {
  //     _currentCode = code;
  //     _controller.clear();
  //     _isValid = false;
  //     widget.onValidChanged?.call(false);
  //   });
  // }

  String get _fullEmail => _controller.text.trim();

  String _buildHint() {
    return 'exampleMail@example.com';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FormField<String>(
      validator: 
      widget.validator ?? 
      (value) {
        if (_controller.text.isEmpty) {
          return 'Sorry, email is required.';
        }
        if (!_isValid) {
          return 'Your email is incorrect.';
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
                  letterSpacing: 0.8
                )
              ),
              const SizedBox(height: 8)
            ],

            Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: _StringField(
                    controller: _controller,
                    focusNode: _focusNode,
                    hintText: _buildHint(),
                    isFocused: _isFocused,
                    maxLength: 64,
                    hasError: field.hasError,
                    onChanged: (_) => field.didChange(_fullEmail)
                  )
                ),

                // const SizedBox(width: 8),

                // _EmailCodeField(
                //   code: _currentCode,
                //   onTap: () => _openEmailPicker(context),
                //   hasError: field.hasError,
                //   isFocused: _isFocused,
                // )
              ],
            ),

            if (field.hasError) ...[
              const SizedBox(height: 8),
              Text(
                field.errorText!,
                style: context.textStyles.bodySmall?.copyWith(
                  color: colors.error,
                  fontSize: 12
                )
              )
            ],
          ]
        );
      }
    );
  }

  // void _openEmailPicker(BuildContext context) {}
}

class _StringField extends StatelessWidget {
  const _StringField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.maxLength,
    required this.isFocused,
    required this.hasError,
    this.onChanged
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final int maxLength;
  final bool isFocused;
  final bool hasError;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: .phone,
      textInputAction: .done,
      maxLength: maxLength,
      // inputFormatters: [FilteringTextInputFormatter.digitsOnly]
      onChanged: onChanged,
      style: context.textStyles.bodyMedium?.copyWith(
        color: colors.textPrimary,
        fontWeight: .w500,
      ),
      cursorColor: colors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '',
        hintStyle: context.textStyles.bodyMedium?.copyWith(
          color: colors.textHint
        ),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const .symmetric(
          horizontal: 16,
          vertical: 12
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasError ? colors.error : colors.border,
            width: 1.5
          )
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: .circular(14),
          borderSide: BorderSide(
            color: hasError ? colors.error : colors.primary,
            width: 2
          )
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: .circular(14),
          borderSide: BorderSide(
            color: colors.error,
            width: 1.5
          )
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: .circular(14),
          borderSide: BorderSide(
            color: colors.error,
            width: 2
          )
        ),
        border: OutlineInputBorder(
          borderRadius: .circular(14)
        )
      ),
    );
  }
}

// class _EmailCodeField extends StatelessWidget {
//   const _EmailCodeField({
//     required this.code,
//     required this.onTap,
//     required this.hasError,
//     required this.isFocused
//   });

//   final EmailCode code;
//   final VoidCallback onTap;
//   final bool hasError;
//   final bool isFocused;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     // Unimplemented design
//     return Dropdown
//   }
// }