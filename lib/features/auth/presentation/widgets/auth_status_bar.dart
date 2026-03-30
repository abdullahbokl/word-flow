import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_state.dart';
import 'package:word_flow/features/auth/presentation/widgets/auth_status_widgets.dart';
import 'package:word_flow/features/auth/presentation/widgets/authenticated_user_status.dart';
import 'package:word_flow/features/auth/presentation/widgets/guest_user_status.dart';

import 'package:word_flow/app/router/routes.dart';

class AuthStatusBar extends StatelessWidget {
  const AuthStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 360;
            return StatusBarWrapper(
              child: state.maybeMap(
                authenticated: (auth) => AuthenticatedUserStatus(
                  user: auth.user,
                  isCompact: isCompact,
                  onLogOut: () => context.read<AuthCubit>().logOut(),
                ),
                orElse: () => GuestUserStatus(
                  isCompact: isCompact,
                  onSignIn: () => const AuthRoute().pushReplacement(context),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
