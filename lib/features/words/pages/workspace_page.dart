import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:word_flow/core/di/injection.dart';
import 'package:word_flow/features/words/blocs/words_cubit.dart';
import 'package:word_flow/features/words/models/analysis.dart';
import 'package:word_flow/core/widgets/app_button.dart';
import 'package:word_flow/core/widgets/app_text_field.dart';
import 'package:word_flow/core/widgets/empty_state.dart';
import 'package:word_flow/core/widgets/section_card.dart';

class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key});

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WordsCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WordFlow Workspace'),
          actions: [
            IconButton(
              icon: const Icon(Icons.library_books_rounded),
              onPressed: () => context.go('/library'),
            ),
          ],
        ),
        body: BlocConsumer<WordsCubit, WordsState>(
          listener: (context, state) {
            state.mapOrNull(
              error: (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              },
            );
          },
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SectionCard(
                      title: 'Analyze Script',
                      subtitle:
                          'Paste your video script to extract vocabulary.',
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _controller,
                            hint: 'Paste script here...',
                            maxLines: 8,
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            label: 'Analyze',
                            onPressed: () {
                              context.read<WordsCubit>().analyze(
                                _controller.text,
                                const TextAnalysisConfig(
                                  stopWords: {},
                                  language: 'english',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                state.maybeMap(
                  results: (s) => SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Results: ${s.summary.newWords} new words found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final word = s.analyzedWords[index];
                            return ListTile(
                              title: Text(word.wordText),
                              subtitle: Text('Occurrences: ${word.totalCount}'),
                              trailing: Checkbox(
                                value: word.isKnown,
                                onChanged: (_) {
                                  context.read<WordsCubit>().toggleKnown(
                                    word.wordText,
                                  );
                                },
                              ),
                            );
                          }, childCount: s.analyzedWords.length),
                        ),
                      ],
                    ),
                  ),
                  analyzing: (_) => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  orElse: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: EmptyState(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Ready to analyze',
                        subtitle: 'Your results will appear here.',
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
