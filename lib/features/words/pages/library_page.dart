import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:word_flow/core/di/injection.dart';
import 'package:word_flow/features/words/blocs/words_cubit.dart';
import 'package:word_flow/core/widgets/empty_state.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WordsCubit>()..loadLibrary(refresh: true),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Vocabulary'),
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (GoRouter.of(context).canPop()) {
                    GoRouter.of(context).pop();
                  } else {
                    context.go('/');
                  }
                },
              );
            },
          ),
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
            return state.maybeMap(
              library: (s) {
                if (s.words.isEmpty) {
                  return const EmptyState(
                    icon: Icons.bookmark_border_rounded,
                    title: 'No words saved',
                    subtitle: 'Analyze a script to save words here.',
                  );
                }
                return ListView.builder(
                  itemCount: s.words.length + (s.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == s.words.length) {
                      context.read<WordsCubit>().loadLibrary();
                      return const Center(child: CircularProgressIndicator());
                    }
                    final word = s.words[index];
                    return ListTile(
                      title: Text(word.wordText),
                      subtitle: Text('Total occurrences: ${word.totalCount}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () =>
                            context.read<WordsCubit>().deleteWord(word.id),
                      ),
                    );
                  },
                );
              },
              loading: (_) => const Center(child: CircularProgressIndicator()),
              error: (e) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load library: ${e.message}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<WordsCubit>().loadLibrary(refresh: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              orElse: () => const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
