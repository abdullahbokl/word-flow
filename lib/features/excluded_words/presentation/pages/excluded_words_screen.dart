import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/app/di/injection.dart';
import 'package:wordflow/core/theme/app_colors.dart';
import 'package:wordflow/core/theme/design_tokens.dart';
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
      create: (context) {
        final cubit = sl<ExcludedWordsCubit>();
        unawaited(cubit.loadExcludedWords());
        return cubit;
      },
      child: const _ExcludedWordsView(),
    );
  }
}

class _ExcludedWordsView extends StatelessWidget {
  const _ExcludedWordsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(title: 'Excluded Words', showBackButton: true)
                  .animate()
                  .fadeIn(duration: AppTokens.durNormal)
                  .slideX(begin: -0.1),
              const SizedBox(height: AppTokens.space16),
              AppText.body(
                'These words will be ignored when analyzing text and will not be counted as new vocabulary.',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ).animate().fadeIn(delay: 100.ms, duration: AppTokens.durNormal),
              const SizedBox(height: AppTokens.space24),
              const Expanded(child: ExcludedWordListView()),
            ],
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () => ExcludedWordFormDialog.show(context),
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded),
        ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}
