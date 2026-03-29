import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/core/di/injection.dart';
import 'package:word_flow/features/word_learning/presentation/blocs/workspace_cubit.dart';
import 'package:word_flow/features/word_learning/presentation/blocs/workspace_state.dart';
import 'package:word_flow/features/word_learning/presentation/widgets/workspace_background.dart';
import 'package:word_flow/features/word_learning/presentation/widgets/workspace_body.dart';
import 'package:word_flow/features/word_learning/presentation/widgets/workspace_listeners.dart';

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
              SafeArea(child: _WorkspaceContent(controller: _controller)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceContent extends StatelessWidget {
  const _WorkspaceContent({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceCubit, WorkspaceState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) => WorkspaceBody(controller: controller),
    );
  }
}
