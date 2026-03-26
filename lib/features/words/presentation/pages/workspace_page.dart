import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../cubit/workspace_cubit.dart';
import '../cubit/workspace_state.dart';
import '../widgets/workspace_background.dart';
import '../widgets/workspace_body.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class WorkspacePage extends StatefulWidget {
  final WorkspaceCubit? cubit;

  const WorkspacePage({super.key, this.cubit});

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  late final TextEditingController _controller;
  late final WorkspaceCubit _cubit;
  late final bool _ownsCubit;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _cubit = widget.cubit ?? getIt<WorkspaceCubit>();
    _ownsCubit = widget.cubit == null;
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_ownsCubit) {
      _cubit.close();
    }
    super.dispose();
  }

  void _clear(BuildContext context) {
    _controller.clear();
    _cubit.analyze('');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: Stack(
          children: [
            const WorkspaceBackground(),
            SafeArea(
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  final userId = authState.maybeMap(
                    authenticated: (s) => s.user.id,
                    orElse: () => null,
                  );

                  return BlocBuilder<WorkspaceCubit, WorkspaceState>(
                    builder: (context, state) {
                      return WorkspaceBody(
                        state: state,
                        summary: _cubit.summary,
                        controller: _controller,
                        onAnalyze: () => _cubit.analyze(_controller.text, userId: userId),
                        onClear: () => _clear(context),
                        onToggle: (text) => _cubit.toggleKnown(text, userId: userId),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
