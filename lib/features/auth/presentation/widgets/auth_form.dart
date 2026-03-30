import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/core/widgets/app_loader.dart';
import 'package:word_flow/core/widgets/app_text_field.dart';
import 'package:word_flow/features/auth/domain/validators/auth_validators.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_state.dart';
import 'package:word_flow/features/auth/presentation/blocs/migration_cubit.dart';
import 'package:word_flow/features/auth/presentation/blocs/migration_state.dart';

class AuthForm extends StatefulWidget {
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
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  String? _emailError;
  String? _passwordError;
  String? _rateLimitError;
  Timer? _cooldownTimer;

  void _validateEmail(String value) {
    if (value.isEmpty) {
      setState(() => _emailError = null);
      return;
    }
    setState(() {
      _emailError = EmailValidator.validate(value.trim()).fold(
        (failure) => failure.message,
        (_) => null,
      );
    });
  }

  void _validatePassword(String value) {
    if (value.isEmpty) {
      setState(() => _passwordError = null);
      return;
    }
    setState(() {
      _passwordError = PasswordValidator.validate(value).fold(
        (failure) => failure.message,
        (_) => null,
      );
    });
  }

  void _startCooldown(Duration duration) {
    _cooldownTimer?.cancel();
    var secondsRemaining = duration.inSeconds;
    
    void updateError() {
      if (secondsRemaining <= 0) {
        setState(() => _rateLimitError = null);
        _cooldownTimer?.cancel();
      } else {
        setState(() {
          _rateLimitError = 'Too many attempts. Try again in ${secondsRemaining}s';
        });
      }
    }

    updateError();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsRemaining--;
      updateError();
    });
  }

  bool get _hasErrors => _emailError != null || _passwordError != null || _rateLimitError != null;
  bool get _canSubmit =>
      widget.emailController.text.isNotEmpty &&
      widget.passwordController.text.isNotEmpty &&
      !_hasErrors;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: widget.emailController,
          hint: 'Email address',
          prefixIcon: const Icon(Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
          onChanged: _validateEmail,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: widget.passwordController,
          hint: 'Password',
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          obscureText: true,
          errorText: _passwordError,
          onChanged: _validatePassword,
        ),
        if (_rateLimitError != null) ...[
          const SizedBox(height: 16),
          Text(
            _rateLimitError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 32),
        MultiBlocListener(
          listeners: [
            BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                state.maybeMap(
                  authenticated: (_) => Navigator.pop(context),
                  rateLimited: (s) => _startCooldown(s.cooldown),
                  error: (e) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message)),
                  ),
                  orElse: () {},
                );
              },
            ),
            BlocListener<MigrationCubit, MigrationState>(
              listener: (context, state) {
                state.maybeMap(
                  success: (_) => Navigator.pop(context),
                  rateLimited: (s) => _startCooldown(s.cooldown),
                  error: (e) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message)),
                  ),
                  orElse: () {},
                );
              },
            ),
          ],
          child: BlocBuilder<MigrationCubit, MigrationState>(
            builder: (context, state) {
              final isLoading = state.maybeMap(
                loading: (_) => true,
                orElse: () => false,
              );

              return FilledButton(
                onPressed: (isLoading || !_canSubmit) ? null : widget.onSubmit,
                child: isLoading
                    ? const AppLoader(size: 20, color: Colors.white)
                    : Text(widget.isSignUp ? 'Create Account' : 'Sign In'),
              );
            },
          ),
        ),
      ],
    );
  }
}
