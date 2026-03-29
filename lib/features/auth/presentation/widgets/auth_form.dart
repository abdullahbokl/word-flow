import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/core/widgets/app_loader.dart';
import 'package:word_flow/core/widgets/app_text_field.dart';
import 'package:word_flow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:word_flow/features/auth/presentation/cubit/auth_state.dart';

class AuthForm extends StatelessWidget {

  const AuthForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isSignUp,
    required this.onSubmit,
  });
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSignUp;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: emailController,
          hint: 'Email address',
          prefixIcon: const Icon(Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: passwordController,
          hint: 'Password',
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          obscureText: true,
        ),
        const SizedBox(height: 32),
        BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            state.maybeMap(
              authenticated: (_) => Navigator.pop(context),
              error: (e) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message)),
              ),
              orElse: () {},
            );
          },
          builder: (context, state) {
            final isLoading = state.maybeMap(
              loading: (_) => true,
              orElse: () => false,
            );

            return FilledButton(
              onPressed: isLoading ? null : onSubmit,
              child: isLoading
                  ? const AppLoader(size: 20, color: Colors.white)
                  : Text(isSignUp ? 'Create Account' : 'Sign In'),
            );
          },
        ),
      ],
    );
  }
}
