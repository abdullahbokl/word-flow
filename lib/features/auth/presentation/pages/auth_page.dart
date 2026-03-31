import 'package:flutter/material.dart';
import 'package:word_flow/features/auth/presentation/widgets/auth_bottom_sheet.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      body: const Center(
        child: SingleChildScrollView(child: AuthBottomSheet()),
      ),
    );
  }
}
