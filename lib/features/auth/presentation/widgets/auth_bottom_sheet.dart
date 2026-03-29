import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:word_flow/features/auth/presentation/widgets/auth_form.dart';

class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({super.key});

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text;
    final pass = _passwordController.text;
    if (_isSignUp) {
      context.read<AuthCubit>().signUp(email, pass);
    } else {
      context.read<AuthCubit>().signIn(email, pass);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isSignUp ? 'Create Account' : 'Welcome Back',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _isSignUp
                  ? 'Sign up to sync your words across all your devices.'
                  : 'Sign in to access your saved word lists and collections.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AuthForm(
              emailController: _emailController,
              passwordController: _passwordController,
              isSignUp: _isSignUp,
              onSubmit: _submit,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _isSignUp = !_isSignUp),
              child: Text(_isSignUp
                  ? 'Already have an account? Sign In'
                  : 'Don\'t have an account? Create one'),
            ),
          ],
        ),
      ),
    );
  }
}
