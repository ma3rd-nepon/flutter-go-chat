import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/novacore.dart';
import '../../../ui/novakit.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_page_header.dart';
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';

class AuthAuthHeader extends StatelessWidget {
  const AuthAuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPageHeader(
      icon: AppIcons.login,
      title: 'Welcome back',
      subtitle: "123",
    );
  }
}

class AuthAuthBody extends StatefulWidget {
  const AuthAuthBody({super.key});

  @override
  State<AuthAuthBody> createState() => _AuthAuthBodyState();
}

class _AuthAuthBodyState extends State<AuthAuthBody> {
  String _email = '';
  String _password = '';
  (bool, bool) _validity = (false, false);
  bool _isLoading = false;

  bool isValid() { return _validity.$1 && _validity.$2; }

  Future<void> _submit() async {
    await context.read<AuthCubit>().signIn(data: (_email, _password));
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
          otpSent: (data) => setState(() => _isLoading = false),
          passwordSetup: (data) => setState(() => _isLoading = false),
          profileSetup: (data) => setState(() => _isLoading = false),
          authenticated: (user) => setState(() => _isLoading = false),
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
              onValidChanged: (valid) {
                setState(() {
                  _validity = (valid, _validity.$2);
                });
              },
            ),

            const SizedBox(height: 10),

            PasswordField(
              onDetailsChanged: (psswd) {
                setState(() {
                  _password = psswd;
                });
              },
              onValidChanged: (valid) {
                setState(() {
                  _validity = (_validity.$1, valid);
                });
              },
            ),

            const SizedBox(height: 20),

            NovaButton(
              onPressed: isValid() ? _submit : null,
              child: _isLoading
                  ? SizedBox(height: 10, width: 10, child: CircularProgressIndicator.adaptive())
                  : Text(
                      'Sign in',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: .bold,
                        color: colors.textPrimary,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
