import "package:flutter/material.dart";

class PasswordField extends StatefulWidget {
  const PasswordField({super.key});
  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _obscured,
      decoration: InputDecoration(
        hintText: 'Enter password',
        suffixIcon: IconButton(
          icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ),
    );
  }
}
