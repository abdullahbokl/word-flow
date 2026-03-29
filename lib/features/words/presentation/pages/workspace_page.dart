import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/app/di.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_cubit.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_state.dart';
import 'package:word_flow/features/words/presentation/widgets/workspace_background.dart';
import 'package:word_flow/features/words/presentation/widgets/workspace_body.dart';
import 'package:word_flow/features/words/presentation/widgets/workspace_listeners.dart';
import 'package:word_flow/features/auth/presentation/cubit/auth_cubit.dart';

class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key, this.cubit});
  final WorkspaceCubit? cubit;

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  late final TextEditingController _controller = TextEditingController();
  late final WorkspaceCubit _cubit = widget.cubit ?? getIt<WorkspaceCubit>();
  late final bool _ownsCubit = widget.cubit == null;

  @override
  void dispose() {
    _controller.dispose();
    if (_ownsCubit) _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: WorkspaceListeners(
          child: Stack(
            children: [
              const WorkspaceBackground(),
              SafeArea(child: _WorkspaceContent(cubit: _cubit, controller: _controller)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceContent extends StatelessWidget {
  const _WorkspaceContent({required this.cubit, required this.controller});
  final WorkspaceCubit cubit;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthCubit>().state.maybeMap(authenticated: (s) => s.user.id, orElse: () => null);
    return BlocBuilder<WorkspaceCubit, WorkspaceState>(
      builder: (context, state) => WorkspaceBody(
        state: state,
        summary: cubit.summary,
        words: cubit.words,
        pendingWordTexts: cubit.pendingKnownWords,
        isProcessing: cubit.isProcessing,
        controller: controller,
        onAnalyze: () => cubit.analyze(controller.text, userId: userId),
        onClear: () {
          controller.clear();
          cubit.analyze('');
        },
      ),
    );
  }
}
