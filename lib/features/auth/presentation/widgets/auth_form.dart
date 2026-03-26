import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class AuthForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSignUp;
  final VoidCallback onSubmit;

  const AuthForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isSignUp,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(
            hintText: 'Email address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          decoration: const InputDecoration(
            hintText: 'Password',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
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
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isSignUp ? 'Create Account' : 'Sign In'),
            );
          },
        ),
      ],
    );
  }
}
