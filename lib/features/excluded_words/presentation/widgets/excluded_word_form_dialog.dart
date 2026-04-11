import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexitrack/core/widgets/app_button.dart';
import 'package:lexitrack/core/widgets/app_text.dart';
import 'package:lexitrack/core/widgets/app_text_field.dart';
import 'package:lexitrack/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:lexitrack/features/excluded_words/presentation/cubit/excluded_words_cubit.dart';

class ExcludedWordFormDialog extends StatelessWidget {
  const ExcludedWordFormDialog({this.word, super.key});

  final ExcludedWord? word;

  static void show(BuildContext context, {ExcludedWord? word}) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ExcludedWordsCubit>(),
        child: ExcludedWordFormDialog(word: word),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: word?.word);
    return AlertDialog(
      title: AppText.label(word == null ? 'Add Excluded Word' : 'Update Word'),
      content: AppTextField(
        controller: controller,
        hint: 'Enter word',
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const AppText.body('Cancel'),
        ),
        AppButton(
          label: word == null ? 'Add' : 'Update',
          onPressed: () {
            final text = controller.text.trim();
            if (text.isNotEmpty) {
              final cubit = context.read<ExcludedWordsCubit>();
              if (word == null) {
                cubit.addWord(text);
              } else {
                cubit.updateWord(word!.copyWith(word: text));
              }
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
