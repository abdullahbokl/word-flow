import 'package:flutter/material.dart';
import 'package:wordflow/core/constants/app_strings.dart';
import 'package:wordflow/core/widgets/app_text.dart';
import 'package:wordflow/core/widgets/app_text_field.dart';

class AddWordDialog extends StatefulWidget {
  const AddWordDialog({super.key});

  @override
  State<AddWordDialog> createState() => _AddWordDialogState();
}

class _AddWordDialogState extends State<AddWordDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const AppText.title(AppStrings.addWord),
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
          child: const AppText.body(AppStrings.add),
        ),
      ],
    );
  }
}
