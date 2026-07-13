import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_go_chat/core/services/app_scope/scope.dart';
import 'package:flutter_go_chat/core/services/page_manager.dart';

class _ParticleEffectHost extends StatefulWidget {
  const _ParticleEffectHost({required this.onEffectChanged, super.key});

  final ValueChanged<String?> onEffectChanged;

  @override
  State<_ParticleEffectHost> createState() => _ParticleEffectHostState();
}

class _ParticleEffectHostState extends State<_ParticleEffectHost> {
  String? particleEffectId = 'snow';

  void changeEffect(String? id) {
    setState(() {
      particleEffectId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      authController: AuthController(),
      uiController: UIController(),
      navController: NavigationController(),
      settingsController: SettingsController(),
      child: _ParticleEffectConsumer(onEffectChanged: widget.onEffectChanged),
    );
  }
}

class _ParticleEffectConsumer extends StatelessWidget {
  const _ParticleEffectConsumer({super.key, required this.onEffectChanged});

  final ValueChanged<String?> onEffectChanged;

  @override
  Widget build(BuildContext context) {
    final manager = AppScope.of(context);
    onEffectChanged(manager.settingsController.particleEffectId);
    return const SizedBox.shrink();
  }
}

void main() {
  testWidgets('changing particle effect updates dependent widgets', (tester) async {
    String? observedEffect;
    final hostKey = GlobalKey<_ParticleEffectHostState>();

    await tester.pumpWidget(
      MaterialApp(
        home: _ParticleEffectHost(
          key: hostKey,
          onEffectChanged: (effect) {
            observedEffect = effect;
          },
        ),
      ),
    );

    expect(observedEffect, 'snow');

    hostKey.currentState!.changeEffect('rain');
    await tester.pump();

    expect(observedEffect, 'rain');
  });
}
