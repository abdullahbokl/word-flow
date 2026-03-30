import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/core/widgets/app_loader.dart';
import 'package:word_flow/core/widgets/word_card_widgets.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_cubit.dart';
import 'package:word_flow/features/word_learning/presentation/blocs/workspace_cubit.dart';

enum WordCardMode { workspace, library }

class WordCardBase extends StatelessWidget {
  const WordCardBase({
    super.key,
    required this.word,
    required this.mode,
    this.isPending = false,
    this.enabled = true,
    this.onEdit,
    this.onDelete,
  });

  final Object word;
  final WordCardMode mode;
  final bool isPending;
  final bool enabled;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = isKnown ? scheme.primary : scheme.secondary;
    return Semantics(
      label: '$text, count $count, ${isKnown ? "known" : "unknown"}',
      button: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: isPending ? 0.35 : 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ExcludeSemantics(child: StatusIndicator(isKnown: isKnown, color: statusColor)),
                const SizedBox(width: 14),
                Expanded(
                  child: WordInfo(text: text, count: count, isKnown: isKnown, variants: variants),
                ),
                ToggleButton(
                  isKnown: isKnown,
                  isPending: isPending,
                  onToggle: () => _onToggle(context),
                  statusColor: statusColor,
                ),
                ..._buildActions(context),
                if (isPending && mode == WordCardMode.workspace && !enabled) AppLoader(size: 16, color: statusColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get text {
    return switch (mode) {
      WordCardMode.workspace => (word as ProcessedWord).wordText,
      WordCardMode.library => (word as WordEntity).wordText,
    };
  }

  int get count {
    return switch (mode) {
      WordCardMode.workspace => (word as ProcessedWord).totalCount,
      WordCardMode.library => (word as WordEntity).totalCount,
    };
  }

  bool get isKnown {
    return switch (mode) {
      WordCardMode.workspace => (word as ProcessedWord).isKnown,
      WordCardMode.library => (word as WordEntity).isKnown,
    };
  }

  List<String> get variants {
    return switch (mode) {
      WordCardMode.workspace => (word as ProcessedWord).variants,
      WordCardMode.library => const [],
    };
  }

  void _onToggle(BuildContext context) {
    if (isPending || !enabled) return;

    switch (mode) {
      case WordCardMode.workspace:
        final workspaceWord = word as ProcessedWord;
        final userId = context.read<AuthCubit>().currentUserId;
        context.read<WorkspaceCubit>().toggleKnown(workspaceWord.wordText, userId: userId);
      case WordCardMode.library:
        final libraryWord = word as WordEntity;
        context.read<LibraryCubit>().toggleKnown(libraryWord);
    }
  }

  List<Widget> _buildActions(BuildContext context) {
    if (mode != WordCardMode.library) return const [];

    return [
      SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          icon: const Icon(Icons.edit_rounded, size: 20),
          onPressed: isPending || onEdit == null ? null : onEdit,
          tooltip: 'Edit word',
        ),
      ),
      SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          icon: Icon(
            Icons.delete_outline_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.error,
          ),
          onPressed: isPending || onDelete == null ? null : onDelete,
          tooltip: 'Delete word',
        ),
      ),
    ];
  }
}
