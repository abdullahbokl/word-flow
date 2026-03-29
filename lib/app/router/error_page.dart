import 'package:flutter/material.dart';
import 'package:word_flow/app/router/routes.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Oops! The page you are looking for doesn\'t exist.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error.toString(), style: const TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => const WorkspaceRoute().go(context),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
