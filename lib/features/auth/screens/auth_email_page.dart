import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/novacore.dart';
import '../../../ui/novakit.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_page_header.dart';
import '../widgets/email_field.dart';

class AuthEmailHeader extends StatelessWidget {
  const AuthEmailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPageHeader(
      icon: AppIcons.email,
      title: 'Your Email',
      subtitle: "We'll send a verification code to confirm your identity.",
    );
  }
}

class AuthEmailBody extends StatefulWidget {
  const AuthEmailBody({super.key});

  @override
  State<AuthEmailBody> createState() => _AuthEmailBodyState();
}

class _AuthEmailBodyState extends State<AuthEmailBody> {
  String _email = '';
  bool _isValid = false;
  bool _isLoading = false;

  Future<void> _submit() async {
    await context.read<AuthCubit>().submitEmail(data: (_email, ''));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        state.when(
          initial: () => setState(() => _isLoading = false),
          loading: () => setState(() => _isLoading = true),
          authorize: () => setState(() => _isLoading = false),
          otpSent: (email) => setState(() => _isLoading = false),
          passwordSetup: (email) => setState(() => _isLoading = false),
          profileSetup: (email) => setState(() => _isLoading = false),
          authenticated: (token) => setState(() => _isLoading = false),
          error: (message, prev) => setState(() => _isLoading = false),
        );
      },
      child: Padding(
        padding: .fromLTRB(24, 40, 24, 24),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            EmailField(
              onDetailsChanged: (email) {
                setState(() {
                  _email = email;
                });
              },
              onValidChanged: (isValid) {
                setState(() {
                  _isValid = isValid;
                });
              },
            ),

            const SizedBox(height: 20),

            NovaButton(
              onPressed: _isValid ? _submit : null,
              child: _isLoading
                  ? SizedBox(height: 10, width: 10, child: CircularProgressIndicator.adaptive())
                  : Text(
                      'Continue',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: .bold,
                        color: colors.textPrimary,
                      ),
                    ),
            ),

            const SizedBox(height: 12),

            Text(
              'By continuing you accept our Terms & Privacy Policy',
              style: context.textStyles.labelSmall?.copyWith(
                color: colors.textDisabled
              ),
              textAlign: .center,
            )
          ],
        ),
      ),
    );
  }
}
