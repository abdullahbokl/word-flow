import 'package:flutter/material.dart';
import 'package:wordflow/core/constants/app_strings.dart';
import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/core/widgets/app_text.dart';
import 'package:wordflow/core/widgets/app_text_field.dart';

class EditWordDialog extends StatefulWidget {
  const EditWordDialog({required this.word, super.key});
  final WordEntity word;

  @override
  State<EditWordDialog> createState() => _EditWordDialogState();
}

class _EditWordDialogState extends State<EditWordDialog> {
  late final _wordCtrl = TextEditingController(text: widget.word.text);
  late final _meaningCtrl = TextEditingController(text: widget.word.meaning);
  late final List<TextEditingController> _defCtrls;
  late final List<TextEditingController> _exCtrls;
  late final List<TextEditingController> _transCtrls;
  late final List<TextEditingController> _synCtrls;

  @override
  void initState() {
    super.initState();
    _defCtrls = _initCtrls(widget.word.definitions);
    _exCtrls = _initCtrls(widget.word.examples);
    _transCtrls = _initCtrls(widget.word.translations);
    _synCtrls = _initCtrls(widget.word.synonyms);
  }

  List<TextEditingController> _initCtrls(List<String>? initial) {
    if (initial == null || initial.isEmpty) {
      return [TextEditingController()];
    }
    return initial.map((e) => TextEditingController(text: e)).toList();
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _meaningCtrl.dispose();
    for (final c in _defCtrls) {
      c.dispose();
    }
    for (final c in _exCtrls) {
      c.dispose();
    }
    for (final c in _transCtrls) {
      c.dispose();
    }
    for (final c in _synCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addItem(List<TextEditingController> ctrls) {
    setState(() {
      ctrls.add(TextEditingController());
    });
  }

  void _removeItem(List<TextEditingController> ctrls, int index) {
    setState(() {
      ctrls.removeAt(index).dispose();
      if (ctrls.isEmpty) {
        ctrls.add(TextEditingController());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const AppText.title(AppStrings.editWord),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _wordCtrl,
                label: 'Word',
                hint: 'Enter word...',
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildSection('Definitions', _defCtrls, 'e.g. A small animal...'),
              const SizedBox(height: 24),
              _buildSection('Examples', _exCtrls, 'e.g. The cat sat on the mat.'),
              const SizedBox(height: 24),
              _buildSection('Translations', _transCtrls, 'e.g. Gato, Chat...'),
              const SizedBox(height: 24),
              _buildSection('Similar Words', _synCtrls, 'e.g. feline, kitty...'),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              AppTextField(
                controller: _meaningCtrl,
                label: 'Personal Notes',
                hint: 'Any other notes...',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const AppText.body(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'text': _wordCtrl.text.trim(),
            'definitions': _getCtrlsValues(_defCtrls),
            'examples': _getCtrlsValues(_exCtrls),
            'translations': _getCtrlsValues(_transCtrls),
            'synonyms': _getCtrlsValues(_synCtrls),
            'meaning': _meaningCtrl.text.trim(),
          }),
          child: const AppText.body(AppStrings.save),
        ),
      ],
    );
  }

  List<String> _getCtrlsValues(List<TextEditingController> ctrls) {
    return ctrls
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
  }

  Widget _buildSection(
      String title, List<TextEditingController> ctrls, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body(title, fontWeight: FontWeight.bold),
        const SizedBox(height: 8),
        ...ctrls.asMap().entries.map((entry) {
          final idx = entry.key;
          final ctrl = entry.value;
          final isLast = idx == ctrls.length - 1;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: ctrl,
                    hint: hint,
                    minLines: 1,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 4),
                if (isLast)
                  IconButton(
                    onPressed: () => _addItem(ctrls),
                    icon: const Icon(Icons.add_circle,
                        color: Colors.blueAccent, size: 24),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  )
                else
                  IconButton(
                    onPressed: () => _removeItem(ctrls, idx),
                    icon: const Icon(Icons.remove_circle,
                        color: Colors.redAccent, size: 24),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                if (isLast && ctrls.length > 1)
                  IconButton(
                    onPressed: () => _removeItem(ctrls, idx),
                    icon: const Icon(Icons.remove_circle,
                        color: Colors.redAccent, size: 24),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
