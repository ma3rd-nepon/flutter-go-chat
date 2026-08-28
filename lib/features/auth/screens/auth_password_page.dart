import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/novacore.dart';
import '../../../ui/novakit.dart';
import '../widgets/auth_page_header.dart';
import '../widgets/password_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class AuthPasswordHeader extends StatelessWidget {
  const AuthPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPageHeader(
      icon: AppIcons.user,
      title: 'Your Password',
      subtitle: 'Enter the 8-symbols password with 1 or more digits.',
    );
  }
}

class AuthPasswordBody extends StatefulWidget {
  const AuthPasswordBody({super.key});

  @override
  State<AuthPasswordBody> createState() => _AuthPasswordBodyState();
}

class _AuthPasswordBodyState extends State<AuthPasswordBody> {
  (String, String) newData = ('', '');
  bool _isLoading = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();

    final state = context.read<AuthCubit>().state;
    if (state is AuthPasswordSetup) { newData = state.data; } else { debugPrint('state not psswd'); }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _submit() async {
    // debugPrint('newData = ${newData.$1} - ${newData.$2}');
    await context.read<AuthCubit>().createPassword(data: newData);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ts = context.textStyles;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        state.when(
          initial: () => setState(() => _isLoading = false),
          loading: () => setState(() => _isLoading = true),
          authorize: () => setState(() => _isLoading = false),
          otpSent: (_) => setState(() => _isLoading = false),
          passwordSetup: (_) => setState(() => _isLoading = false),
          profileSetup: (_) => setState(() => _isLoading = false),
          authenticated: (_) => setState(() => _isLoading = false),
          error: (a, b) => setState(() => _isLoading = false),
        );
      },
      child: Padding(
        padding: .fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: .min,
          children: [
            const SizedBox(height: 2),

            PasswordField(
              labelText: "Create your great password, don't forget it!",
              onDetailsChanged: (password) {
                setState(() {
                  newData = (newData.$1, password);
                });
              },
              onValidChanged: (valid) {
                setState(() {
                  _isValid = valid;
                });
              },
            ),

            const SizedBox(height: 10),

            NovaButton(
              onPressed: _submit,
              child: _isLoading
                  ? SizedBox(height: 10, width: 10, child: CircularProgressIndicator.adaptive())
                  : Text(
                      'Submit password',
                      style: ts.titleMedium?.copyWith(
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
