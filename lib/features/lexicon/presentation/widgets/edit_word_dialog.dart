import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/domain/entities/word_entity.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_text_field.dart';

class EditWordDialog extends StatefulWidget {
  const EditWordDialog({required this.word, super.key});
  final WordEntity word;

  @override
  State<EditWordDialog> createState() => _EditWordDialogState();
}

class _EditWordDialogState extends State<EditWordDialog> {
  late final _ctrl = TextEditingController(text: widget.word.text);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const AppText.title(AppStrings.editWord),
      content: AppTextField(
        controller: _ctrl,
        autofocus: true,
        hint: AppStrings.enterWord,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => Navigator.pop(context, _ctrl.text.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const AppText.body(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _ctrl.text.trim()),
          child: const AppText.body(AppStrings.save),
        ),
      ],
    );
  }
}
