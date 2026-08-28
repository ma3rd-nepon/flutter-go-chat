import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/novacore.dart';
import '../../../ui/novakit.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../core/router/app_router.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';

import 'screens/auth_landing_page.dart';
import 'screens/auth_authorize_page.dart';
import 'screens/auth_email_page.dart';
import 'screens/auth_otp_page.dart';
import 'screens/auth_password_page.dart';
import 'screens/auth_profile_page.dart';
import 'widgets/auth_page_body.dart';

abstract final class _Page {
  static const landing = 0;
  static const authorizing = 1;
  static const email = 2;
  static const otp = 3;
  static const password = 4;
  static const profile = 5;
  static const count = 5;
}

const _bodyHeights = <int, double>{
  _Page.landing: 210,
  _Page.authorizing: 250,
  _Page.email: 310,
  _Page.otp: 300,
  _Page.password: 320,
  _Page.profile: 360,
};

class AuthLayout extends StatefulWidget {
  const AuthLayout({super.key});

  @override
  State<AuthLayout> createState() => _AuthLayoutState();
}

class _AuthLayoutState extends State<AuthLayout> {
  late final PageController _headerController;
  int _currentPage = _Page.landing;

  (String, String) _data = ('', '');

  @override
  void initState() {
    super.initState();
    _headerController = PageController(initialPage: _Page.landing);
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (_currentPage == page || page > _Page.count) return;
    setState(() => _currentPage = page);
    _headerController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300), // TODO constants to AppConst
      curve: page == _Page.authorizing || page == _Page.email ? Curves.easeOutExpo : Curves.easeInOutCubic,
    );
  }

  List<Widget> get _headers => [
    const AuthLandingHeader(),
    const AuthAuthHeader(),
    const AuthEmailHeader(),
    AuthOtpHeader(
      maskedEmail: _data.$1.isNotEmpty
          ? '${_data.$1[0]}${"*" * (_data.$1.length - 10)}${_data.$1.substring(_data.$1.length - 10)}'
          : null,
    ),
    const AuthPasswordHeader(),
    const AuthProfileHeader(),
  ];

  String _titleFor(int page) {
    switch (page) {
      case _Page.landing:
        return '';
      case _Page.authorizing:
        return 'Welcome back';
      case _Page.email:
        return 'Email check';
      case _Page.otp:
        return 'Enter the Code';
      case _Page.password:
        return 'Create the password';
      case _Page.profile:
        return 'Profile Setup'; // TODO constats to AppConst
      default:
        return '';
    }
  }

  Widget _bodyFor(int page) {
    switch (page) {
      case _Page.landing:
        return (AuthLandingBody(signUp: () => _goToPage(_Page.email), signIn: () => _goToPage(_Page.authorizing)));
      case _Page.authorizing:
        return AuthAuthBody();
      case _Page.email:
        return const AuthEmailBody();
      case _Page.otp:
        return AuthOtpBody();
      case _Page.password:
        return AuthPasswordBody();
      case _Page.profile:
        return AuthProfileBody();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // final isDesktop =
    //     MediaQuery.of(context).size.width > 800; // desktop breakpoint

    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) => current != previous,
      listener: (context, state) {
        state.when(
          initial: () => _goToPage(_Page.landing),
          loading: () {
            /* handled by individual body widgets */
          },
          authorize: () {
            _goToPage(_Page.authorizing);
          },
          otpSent: (data) {
            data = data;
            _goToPage(_Page.otp);
          },
          passwordSetup: (data) {
            data = data;
            // currentUser = user;
            _goToPage(_Page.password);
          },
          profileSetup: (data) {
            data = data;
            FocusScope.of(context).unfocus(); // TODO what this
            _goToPage(_Page.profile);
          },
          authenticated: (_) => context.go(AppRoutes.home),
          error: (message, previousState) {
            AppSnackBar.show(
              // TODO own snackBar
              context,
              message: message,
              type: AppSnackBarType.error,
            );
          },
        );
      },
      builder: (context, state) {
        final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
        final bodyHeight = _bodyHeights[_currentPage] ?? 260;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: colors.background,
            appBar: AppBar(
              title: AnimatedOpacity(
                opacity: keyboardHeight > 0 ? 1.0 : 0.0,
                duration: const Duration(
                  milliseconds: 300,
                ), // TODO const to AppConst
                child: Text(_titleFor(_currentPage)),
              ),
              leading: _currentPage == _Page.landing
                  ? null
                  : IconButton(
                      onPressed: _currentPage > _Page.landing
                          ? _currentPage == _Page.email ? () => _goToPage(_Page.landing) : () => _goToPage(_currentPage - 1)
                          : null,
                      icon: const Icon(AppIcons.back),
                    ),
            ),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: keyboardHeight > 0 ? 0.0 : 1.0,
                      duration: const Duration(
                        milliseconds: 300,
                      ), // TODO consts to AppConst
                      child: PageView(
                        controller: _headerController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _headers,
                      ),
                    ),
                  ),

                  AuthBodyPanel(
                    height: bodyHeight,
                    keyboardHeight: keyboardHeight,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: 10,
                      ), // TODO consts to AppConst
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.08),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: Column(
                          children: [
                            KeyedSubtree(
                              key: ValueKey(_currentPage),
                              child: _bodyFor(_currentPage),
                            ),
                            if (_currentPage > 0)
                              _StepIndicator(
                                totalSteps: _Page.count,
                                currentStep: _currentPage,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.totalSteps, required this.currentStep});

  final int totalSteps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.surface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (i) {
        final isActive = i == currentStep;
        final isPast = i < currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: isActive ? 24.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: (isActive || isPast)
                ? primary
                : primary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(4.0),
          ),
        );
      }),
    );
  }
}
