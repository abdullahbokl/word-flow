import 'package:flutter/material.dart';
import 'package:word_flow/features/authentication/presentation/widgets/auth_status_widgets.dart';

class GuestUserStatus extends StatelessWidget {

  const GuestUserStatus({
    super.key,
    required this.isCompact,
    required this.onSignIn,
  });
  final bool isCompact;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final label = Text(
      'Guest Workspace',
      style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_circle_outlined, size: 16, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              label,
            ],
          ),
          const SizedBox(height: 8),
          ActionButton(label: 'Sign in', onTap: onSignIn),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.account_circle_outlined, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        label,
        const SizedBox(width: 12),
        ActionButton(label: 'Sign in', onTap: onSignIn),
      ],
    );
  }
}
