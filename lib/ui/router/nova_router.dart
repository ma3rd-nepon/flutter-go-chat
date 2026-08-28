import 'package:flutter/widgets.dart';

class NovaRouter {
  static Route<T> _route<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  static void push(BuildContext context, Widget page) {
    Navigator.of(context).push(_route(page));
  }

  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }
}