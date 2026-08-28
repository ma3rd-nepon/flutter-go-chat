import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubit/home_cubit.dart';
import '../../../cubit/home_state.dart';

import '../../../../../core/novacore.dart';
import '../../../../../ui/novakit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (cntxt, state) {
        if (state is HomeLoadedState) {
          final user = state.user;

          return Scaffold(
            body: SafeArea(
              child: Align(
                alignment: .topStart,
                child: SingleChildScrollView(
                  child: SelectableText("""
Your Profile
ID: ${user.id}
email: ${user.email}
Username: ${user.username}
Name: ${user.displayName}
Bio: ${user.bio}
Status: ${user.status}
Quote: ${user.quote}
Last seen: ${user.lastSeen}
"""),
                ),
              ),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
