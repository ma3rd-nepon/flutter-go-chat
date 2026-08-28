import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/novacore.dart';
import '../../../ui/novakit.dart';
import '../widgets/auth_page_header.dart';
import '../widgets/auth_otp_input.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class AuthOtpHeader extends StatelessWidget {
  const AuthOtpHeader({super.key, this.maskedEmail});

  final String? maskedEmail;

  @override
  Widget build(BuildContext context) {
    return AuthPageHeader(
      icon: AppIcons.verified,
      title: 'Enter the Code',
      subtitle: maskedEmail != null
          ? 'We sent a 6-digit code to \n$maskedEmail'
          : 'We sent you a 6-digit verification code',
    );
  }
}

class AuthOtpBody extends StatefulWidget {
  const AuthOtpBody({super.key});

  @override
  State<AuthOtpBody> createState() => _AuthOtpBodyState();
}

class _AuthOtpBodyState extends State<AuthOtpBody> {
  String _enteredOtp = '';
  (String, String)? data;
  bool _isLoading = false;
  bool _hasError = false;
  int _resendCountdown = 30;

  final PinInputController pinController = PinInputController();

  @override
  void initState() {
    super.initState();
    _startCountDown();

    final state = context.read<AuthCubit>().state;
    if (state is AuthOtpSentState) data = state.data;
  }

  void _startCountDown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _resendCountdown == 0) return;
      setState(() => _resendCountdown--);
      _startCountDown();
    });
  }

  Future<void> _verify() async {
    setState(() => _hasError = false);
    await context.read<AuthCubit>().verifyOtp(
      otp: _enteredOtp,
      data: data!,
    );
  }

  Future<void> _resend() async {
    if (_resendCountdown > 0) return;
    setState(() {
      _resendCountdown = 30;
      _enteredOtp = '';
      pinController.clear();
    });
    _startCountDown();
    await context.read<AuthCubit>().submitEmail(data: data!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () => setState(() {
            _isLoading = true;
            _hasError = false;
          }),
          authorize: () => setState(() => _isLoading = false),
          otpSent: (_) => setState(() => _isLoading = false),
          passwordSetup: (_) => setState(() => _isLoading = false),
          profileSetup: (_) => setState(() => _isLoading = false),
          authenticated: (_) => setState(() => _isLoading = false),
          error: (a, b) => setState(() {
            _isLoading = false;
            _hasError = true;
          }),
        );
      },
      child: Padding(
        padding: .fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: .min,
          children: [
            AuthOtpInput(
              hasError: _hasError,
              onCompleted: (otp) {
                setState(() => _enteredOtp = otp);
                _verify();
              },
              onChanged: (otp) => setState(() => _enteredOtp = otp),
              controller: pinController
            ),

            if (_hasError) ...[
              const SizedBox(height: 4),

              Text(
                'Sorry! This code is invalid.',
                style: context.textStyles.bodySmall?.copyWith(
                  color: colors.error,
                  fontWeight: .w500,
                ),
              ),
            ],

            const SizedBox(height: 20),

            NovaButton(
              onPressed: _verify,
              child: _isLoading
                  ? SizedBox(height: 10, width: 10, child: CircularProgressIndicator.adaptive())
                  : Text(
                      'Verify',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: .w500,
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: _resend,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _resendCountdown > 0
                    ? Text(
                        key: const ValueKey('countdown'),
                        'Resend code in $_resendCountdown seconds.',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: colors.textDisabled,
                        ),
                      )
                    : Text(
                        key: const ValueKey('resend'),
                        'Resend code',
                        style: context.textStyles.bodySmall?.copyWith(
                          fontWeight: .w600,
                          color: colors.textPrimary,
                          decoration: .underline,
                          decorationColor: colors.textSecondary,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
