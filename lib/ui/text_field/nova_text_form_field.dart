import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';
import 'nova_text_field.dart';

class NovaTextFormField extends FormField<String> {
  NovaTextFormField({
    super.key,
    required BuildContext context,
    TextEditingController? controller,
    String? label,
    bool obscureText = false,
    super.validator,
    String? initialValue,
  }) : super(
          initialValue: controller?.text ?? initialValue ?? '',
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                NovaTextField(
                  controller: controller,
                  label: label,
                  obscureText: obscureText,
                  onChanged: field.didChange,
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(
                        fontFamily: AppFonts.monoFont,
                        fontSize: 11,
                        color: context.colors.error,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}