import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/app/di/injection.dart';
import 'package:wordflow/core/widgets/app_text.dart';
import 'package:wordflow/features/excluded_words/presentation/cubit/excluded_words_cubit.dart';
import 'package:wordflow/features/excluded_words/presentation/pages/excluded_words_screen.dart';
import 'package:wordflow/features/excluded_words/presentation/widgets/excluded_word_list_view.dart';

class ExcludedWordsShortcut extends StatelessWidget {
  const ExcludedWordsShortcut({
    super.key,
    this.excludedWords = const [],
  });

  final List<String> excludedWords;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ShortcutButton(
            icon: Icons.visibility_outlined,
            label: 'Excluded (${excludedWords.length})',
            onTap: excludedWords.isEmpty 
                ? null 
                : () => _showExcludedWordsBottomSheet(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ShortcutButton(
            icon: Icons.settings_outlined,
            label: 'Manage Excluded',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExcludedWordsScreen()),
            ),
          ),
        ),
      ],
    );
  }

  void _showExcludedWordsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider(
        create: (context) => sl<ExcludedWordsCubit>()..loadExcludedWords(),
        child: _ExcludedBottomSheetBody(filter: excludedWords),
      ),
    );
  }
}

class _ExcludedBottomSheetBody extends StatelessWidget {
  const _ExcludedBottomSheetBody({this.filter});

  final List<String>? filter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const AppText.label('Currently Excluded Words'),
          const SizedBox(height: 16),
          Expanded(child: ExcludedWordListView(filter: filter)),
        ],
      ),
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  const _ShortcutButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onTap == null;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor.withAlpha(50)),
            borderRadius: BorderRadius.circular(12),
            color: isDisabled ? theme.disabledColor.withAlpha(20) : null,
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isDisabled ? theme.disabledColor : null),
              const SizedBox(height: 4),
              AppText.caption(
                label,
                color: isDisabled ? theme.disabledColor : null,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
