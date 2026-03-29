import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:word_flow/features/auth/presentation/cubit/auth_state.dart';
import 'package:word_flow/features/auth/presentation/widgets/merge_conflict_dialog.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_cubit.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_state.dart';

class WorkspaceListeners extends StatelessWidget {

  const WorkspaceListeners({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            state.maybeMap(
              pendingMerge: (s) => showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => MergeConflictDialog(user: s.user, guestCount: s.guestWordCount),
              ),
              orElse: () {},
            );
          },
        ),
        BlocListener<WorkspaceCubit, WorkspaceState>(
          listenWhen: (prev, current) => current.maybeMap(error: (_) => true, orElse: () => false),
          listener: (context, state) {
            state.maybeMap(
              error: (e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message))),
              orElse: () {},
            );
          },
        ),
      ],
      child: child,
    );
  }
}
