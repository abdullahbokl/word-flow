import 'package:flutter/material.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/auth/presentation/widgets/auth_status_widgets.dart';
import 'package:word_flow/app/router/routes.dart';

class AuthenticatedUserStatus extends StatelessWidget {
  const AuthenticatedUserStatus({
    super.key,
    required this.user,
    required this.isCompact,
    required this.onLogOut,
  });
  final AuthUser user;
  final bool isCompact;
  final VoidCallback onLogOut;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final emailText = Text(
      user.email,
      style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: scheme.primary,
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: emailText,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ActionButton(label: 'Log out', onTap: onLogOut, isDestructive: true),
        ],
      );
    }

    return GestureDetector(
      onTap: () => const ProfileRoute().push(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline_rounded, size: 16, color: scheme.primary),
          const SizedBox(width: 8),
          Flexible(child: emailText),
        ],
      ),
    );
  }
}
