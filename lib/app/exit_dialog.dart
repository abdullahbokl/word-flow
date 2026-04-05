import 'package:flutter/material.dart';

Future<bool?> showExitDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Exit WordFlow?'),
      content: const Text('Are you sure you want to close the app?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Stay'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Exit'),
        ),
      ],
    ),
  );
}
