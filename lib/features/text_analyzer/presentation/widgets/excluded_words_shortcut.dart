import 'package:flutter/material.dart';
import 'package:lexitrack/core/widgets/app_text.dart';
import 'package:lexitrack/features/excluded_words/presentation/pages/excluded_words_screen.dart';
import 'package:lexitrack/features/excluded_words/presentation/widgets/excluded_word_list_view.dart';

class ExcludedWordsShortcut extends StatelessWidget {
  const ExcludedWordsShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ShortcutButton(
            icon: Icons.visibility_outlined,
            label: 'Show Excluded',
            onTap: () => _showExcludedWordsBottomSheet(context),
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
      builder: (_) => const _ExcludedBottomSheetBody(),
    );
  }
}

class _ExcludedBottomSheetBody extends StatelessWidget {
  const _ExcludedBottomSheetBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Column(
        children: [
          AppText.label('Currently Excluded Words'),
          SizedBox(height: 16),
          Expanded(child: ExcludedWordListView()),
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor.withAlpha(50)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            AppText.caption(label),
          ],
        ),
      ),
    );
  }
}
