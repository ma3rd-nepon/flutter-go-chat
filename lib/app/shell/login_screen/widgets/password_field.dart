import "package:flutter/material.dart";
import 'package:flutter_go_chat/core/icons/app_icons.dart';
import 'package:flutter_go_chat/core/services/app_scope/scope.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  const PasswordField({super.key, required this.controller});
  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final g = AppScope.of(context);

    return g.isDesktop(context)
        ? TextField(
            obscureText: _obscured,
            decoration: InputDecoration(
              hintText: 'Enter password', // ubrat govno
              suffixIcon: IconButton(
                icon: Icon(_obscured ? AppIcons.hide : AppIcons.show),
                onPressed: () => setState(() => _obscured = !_obscured),
              ),
            ),
          )
        : AnimatedPadding(
            duration: Duration(milliseconds: 150),
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: TextField(
              obscureText: _obscured,
              decoration: InputDecoration(
                hintText: 'Enter password',
                suffixIcon: IconButton(
                  icon: Icon(_obscured ? AppIcons.hide : AppIcons.show),
                  onPressed: () => setState(() => _obscured = !_obscured),
                ),
              ),
            ),
          );
  }
}
