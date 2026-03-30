import 'package:flutter/material.dart';

class DatabaseRecoveryDialog extends StatelessWidget {
  const DatabaseRecoveryDialog({
    super.key,
    required this.onTryAgain,
    required this.onResetAppData,
  });

  final VoidCallback onTryAgain;
  final VoidCallback onResetAppData;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Database Access Failed'),
      content: const Text(
        'Database access failed. Your data may need to be reset.',
      ),
      actions: [
        TextButton(onPressed: onTryAgain, child: const Text('Try Again')),
        FilledButton(
          onPressed: onResetAppData,
          child: const Text('Reset App Data'),
        ),
      ],
    );
  }
}
