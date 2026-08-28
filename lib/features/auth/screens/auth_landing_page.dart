import 'package:flutter/material.dart';

import '../../../core/novacore.dart';
import '../../../ui/novakit.dart';

class AuthLandingHeader extends StatefulWidget {
  const AuthLandingHeader({super.key});

  @override
  State<AuthLandingHeader> createState() => _AuthLandingHeaderState();
}

class _AuthLandingHeaderState extends State<AuthLandingHeader> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300)
    )..repeat(reverse: true);

    _scale = Tween(
      begin: 1.0,
      end: 1.08
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemePalette colors = context.colors;
    return Column(
      mainAxisAlignment: .center,
      children: [
        ScaleTransition(
          scale: _scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: .circle,
              gradient: const LinearGradient(
                begin: .topLeft,
                end: .bottomRight,
                colors: [
                  Color.fromARGB(255, 209, 92, 255), // что за хуйня ебаная
                  Color.fromARGB(255, 152, 25, 255)
                ]
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.4),
                  blurRadius: 40.0,
                  spreadRadius: 8.0
                )
              ]
            ),
            child: Icon(
              AppIcons.flame,
              size: 60.0,
              color: Colors.white
            )
          )
        ),
        const SizedBox(height: 24),
        Text(
          'supernova',
          style: context.textStyles.displayLarge?.copyWith(
            height: 1.1,
            letterSpacing: -0.5
          ),
          textAlign: .center,
        ),
        const SizedBox(height: 12),
        Text(
          'bem bem bem',
          style: context.textStyles.bodyLarge?.copyWith(
            color: context.colors.textSecondary,
            fontSize: 16,
          ),
          textAlign: .center,
        )
      ],
    );
  }
}

class AuthLandingBody extends StatelessWidget {
  const AuthLandingBody({super.key, required this.signIn, required this.signUp});

  final VoidCallback signIn;
  final VoidCallback signUp;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Padding(
      padding:.fromLTRB(28, 48, 28, 32),
      child: Column(
        mainAxisSize: .min,
        children: [
          NovaButton(
            onPressed: signIn,
            child: Text('Sign In')
          ),

          const SizedBox(height: 2),
        
          TextButton(
            onPressed: signUp,
            child: Text(
              'New user? Sign up',
              style: context.textStyles.labelSmall?.copyWith(
                color: colors.textDisabled
              ),
              textAlign: .center,
            )
          ),

        ]
      )
    );
  }
}