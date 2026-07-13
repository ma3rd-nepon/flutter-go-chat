import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/services/app_scope/scope.dart';
import 'package:flutter_go_chat/core/extensions/l10n_extension.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({super.key});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    final g = AppScope.of(context);

    final error = ModalRoute.of(context)!.settings.arguments as String;
    final child = Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: .center,
            crossAxisAlignment: .center,
            children: [
              Text(context.l10n.unexpectError(error)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => g.redirect(context, "/main_ui", null),
                child: Text(context.l10n.toMain),
              ),
            ],
          ),
        ),
      ),
    );

    return g.isDesktop(context)
        ? child
        : PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              g.goBack(context);
            },

            child: child,
          );
  }
}
