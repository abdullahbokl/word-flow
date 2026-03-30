import 'package:flutter/material.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: const Center(
        child: Text(
          'Password recovery mode detected.\nImplement reset flow here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
