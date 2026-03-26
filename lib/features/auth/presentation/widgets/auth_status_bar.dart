import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'auth_bottom_sheet.dart';
import 'auth_status_widgets.dart';

class AuthStatusBar extends StatelessWidget {
  const AuthStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final scheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 360;

            return StatusBarWrapper(
              child: state.maybeMap(
                authenticated: (auth) {
                  final email = Text(
                    auth.user.email,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  );

                  return isCompact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_outline_rounded,
                                    size: 16, color: scheme.primary),
                                const SizedBox(width: 8),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 180),
                                  child: email,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ActionButton(
                              label: 'Log out',
                              onTap: () => context.read<AuthCubit>().logOut(),
                              isDestructive: true,
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 16, color: scheme.primary),
                            const SizedBox(width: 8),
                            Flexible(child: email),
                            const SizedBox(width: 12),
                            ActionButton(
                              label: 'Log out',
                              onTap: () => context.read<AuthCubit>().logOut(),
                              isDestructive: true,
                            ),
                          ],
                        );
                },
                orElse: () {
                  final label = Text(
                    'Guest Workspace',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  );

                  return isCompact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.account_circle_outlined,
                                    size: 16, color: scheme.onSurfaceVariant),
                                const SizedBox(width: 8),
                                label,
                              ],
                            ),
                            const SizedBox(height: 8),
                            ActionButton(
                              label: 'Sign in',
                              onTap: () => _showAuthBottomSheet(context),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.account_circle_outlined,
                                size: 16, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 8),
                            label,
                            const SizedBox(width: 12),
                            ActionButton(
                              label: 'Sign in',
                              onTap: () => _showAuthBottomSheet(context),
                            ),
                          ],
                        );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showAuthBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AuthBottomSheet(),
    );
  }
}
