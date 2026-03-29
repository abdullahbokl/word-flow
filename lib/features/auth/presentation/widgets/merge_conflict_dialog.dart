import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/features/auth/domain/entities/user_entity.dart';
import 'package:word_flow/features/auth/presentation/cubit/auth_cubit.dart';

class MergeConflictDialog extends StatelessWidget {

  const MergeConflictDialog({
    super.key,
    required this.user,
    required this.guestCount,
  });
  final UserEntity user;
  final int guestCount;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Merge data?'),
      content: Text(
        'You have $guestCount words in your local guest session. '
        'Would you like to merge them with your account, or discard them and load your account data?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<AuthCubit>().discardGuestAndSignIn(user);
          },
          child: const Text('Discard Guest Data'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<AuthCubit>().mergeAndSignIn(user);
          },
          child: const Text('Merge Both'),
        ),
      ],
    );
  }
}
