import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/app/di/injection.dart';
import 'package:wordflow/core/constants/app_dimensions.dart';
import 'package:wordflow/core/widgets/app_text.dart';
import 'package:wordflow/core/widgets/page_header.dart';
import 'package:wordflow/features/excluded_words/presentation/cubit/excluded_words_cubit.dart';
import 'package:wordflow/features/excluded_words/presentation/widgets/excluded_word_form_dialog.dart';
import 'package:wordflow/features/excluded_words/presentation/widgets/excluded_word_list_view.dart';

class ExcludedWordsScreen extends StatelessWidget {
  const ExcludedWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ExcludedWordsCubit>()..loadExcludedWords(),
      child: const _ExcludedWordsView(),
    );
  }
}

class _ExcludedWordsView extends StatelessWidget {
  const _ExcludedWordsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(title: 'Excluded Words', showBackButton: true),
              SizedBox(height: 16),
              AppText.body(
                'These words will be ignored when analyzing text and will not be counted as new vocabulary.',
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Expanded(child: ExcludedWordListView()),
            ],
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () => ExcludedWordFormDialog.show(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
