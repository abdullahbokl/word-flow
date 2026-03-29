import 'package:flutter/material.dart';

class ScriptInputField extends StatelessWidget {

  const ScriptInputField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      minLines: 10,
      maxLines: 16,
      enableSuggestions: false,
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'Script input',
        hintText: 'Paste a script, article, or study note here...',
        helperText:
            'Large text blocks are supported and analyzed offline-first.',
        alignLabelWithHint: true,
      ),
    );
  }
}
