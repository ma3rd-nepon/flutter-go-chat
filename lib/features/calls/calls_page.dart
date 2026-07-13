import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/services/app_scope/scope.dart';
import 'package:flutter_go_chat/core/extensions/l10n_extension.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final g = AppScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            context.l10n.callsCap(g.isDesktop(context) ? "Desktop" : "Mobile"),
          ),
        ),
      ),
    );
  }
}
