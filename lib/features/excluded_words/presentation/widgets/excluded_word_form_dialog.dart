import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/core/theme/design_tokens.dart';
import 'package:wordflow/core/widgets/app_button.dart';
import 'package:wordflow/core/widgets/app_text.dart';
import 'package:wordflow/core/widgets/app_text_field.dart';
import 'package:wordflow/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:wordflow/features/excluded_words/presentation/cubit/excluded_words_cubit.dart';

class ExcludedWordFormDialog extends StatelessWidget {
  const ExcludedWordFormDialog({this.word, super.key});

  final ExcludedWord? word;

  static void show(BuildContext context, {ExcludedWord? word}) {
    unawaited(showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ExcludedWordsCubit>(),
        child: ExcludedWordFormDialog(word: word),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: word?.word);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radius24),
      ),
      title: AppText.title(word == null ? 'Add Excluded Word' : 'Update Word'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: controller,
            hint: 'Enter word',
            autofocus: true,
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.all(AppTokens.space16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: AppText.body(
            'Cancel',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        AppButton(
          label: word == null ? 'Add' : 'Update',
          onPressed: () {
            final text = controller.text.trim();
            if (text.isNotEmpty) {
              final cubit = context.read<ExcludedWordsCubit>();
              if (word == null) {
                unawaited(cubit.addWord(text));
              } else {
                unawaited(cubit.updateWord(word!.copyWith(word: text)));
              }
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
