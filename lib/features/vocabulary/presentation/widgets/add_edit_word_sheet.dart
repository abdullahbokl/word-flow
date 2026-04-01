import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word_entity.dart';
import 'package:word_flow/core/widgets/app_button.dart';
import 'package:word_flow/core/widgets/app_text_field.dart';

class AddEditWordSheet extends StatefulWidget {
  const AddEditWordSheet({super.key, this.word, required this.onSave});
  final WordEntity? word;
  final Function(String text, bool isKnown) onSave;

  @override
  State<AddEditWordSheet> createState() => _AddEditWordSheetState();
}

class _AddEditWordSheetState extends State<AddEditWordSheet> {
  late final TextEditingController _controller;
  late bool _isKnown;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.word?.wordText ?? '');
    _isKnown = widget.word?.isKnown ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.word == null ? Icons.add_rounded : Icons.edit_rounded,
                color: scheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.word == null ? 'Add word' : 'Edit word',
                style: textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: _controller,
            autofocus: true,
            label: 'The word',
            hint: 'Enter the word here...',
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Already Known?'),
            subtitle: const Text(
              'Mark this word as known to skip it during analysis.',
            ),
            value: _isKnown,
            onChanged: (v) => setState(() => _isKnown = v),
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: widget.word == null ? 'Add to Library' : 'Save Changes',
            icon: Icons.check_rounded,
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                widget.onSave(_controller.text.trim(), _isKnown);
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
