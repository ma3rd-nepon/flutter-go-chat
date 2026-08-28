import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';

import '../../../core/novacore.dart';
import '../../../ui/novakit.dart';
import '../widgets/auth_page_header.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class AuthProfileHeader extends StatelessWidget {
  const AuthProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPageHeader(
      icon: AppIcons.user,
      title: 'Your Profile',
      subtitle: 'Choose photo and name that friends can recognise you.',
    );
  }
}

class AuthProfileBody extends StatefulWidget {
  const AuthProfileBody({super.key});

  @override
  State<AuthProfileBody> createState() => _AuthProfileBodyState();
}

class _AuthProfileBodyState extends State<AuthProfileBody> {
  final _nameController = TextEditingController();
  // String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Future<void> _pickImage() {
  //   final picker = ImagePicker();
  //   final picked = await picker.pickImage(
  //     source: .gallery,
  //     maxWidth: 512,
  //     maxHeight: 512,
  //     imageQuality: 85
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       _imagePath = picked.path;
  //     });
  //   }
  // }

  Future<void> _submit() async {
    // final photoPath = _imagePath;
    final state = context.read<AuthCubit>().state;
    if (state is AuthProfileSetupState) {
      final data = state.data;
      await context.read<AuthCubit>().submitProfile(
        displayName: _nameController.text.trim(),
        photoPath: 'not implemented',
        data: data,
      );
    }
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
            Row(
              children: [
                // Photo picker
                GestureDetector(
                  onTap: () {},
                  child: Stack(
                    alignment: .bottomRight,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: .circle,
                          color:
                              !_isLoading // _imagePath != null
                              ? colors.iconSecondary.withValues(alpha: 0.2)
                              : Colors.white,
                          border: .all(color: colors.border, width: 2.5),
                          // image: _imagePath != null
                          //     ? DecorationImage(
                          //       image: FileImage(File(_imagePath!)),
                          //       fit: .cover
                          //     )
                          //     : null // icon
                        ),
                        child: Icon(
                          AppIcons.user,
                          size: 44,
                          color: colors.iconPrimary.withValues(alpha: 0.8),
                        ),
                      ),

                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: .circle,
                          color: colors.iconActive,
                        ),
                        child: Icon(
                          AppIcons.addPhoto,
                          size: 16,
                          color: colors.primaryVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Avatar Presets
                // Expanded(
                //   child: GestureDetector(

                //   )
                // )
              ],
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              textCapitalization: .words,
              textInputAction: .done,
              onSubmitted: (_) => _submit(),
              style: ts.bodyLarge?.copyWith(
                color: colors.textTertiary,
                fontSize: 16,
                fontWeight: .w500,
              ),
              cursorColor: colors.secondaryVariant,
              decoration: InputDecoration(
                hintText: 'Display name',
                hintStyle: ts.bodyLarge?.copyWith(
                  color: colors.textHint,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: colors.inputBackground,
                contentPadding: const .symmetric(horizontal: 16, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: .circular(14),
                  borderSide: BorderSide(color: colors.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: .circular(14),
                  borderSide: BorderSide(color: colors.borderActive, width: 2),
                ),
                border: OutlineInputBorder(borderRadius: .circular(14)),
                prefixIcon: Icon(
                  AppIcons.badge,
                  color: colors.iconDisabled,
                ),
              ),
            ),

            const SizedBox(height: 20),

            NovaButton(
              onPressed: _submit,
              child: _isLoading
                  ? SizedBox(height: 10, width: 10, child: CircularProgressIndicator.adaptive())
                  : Text(
                      'Create account',
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
