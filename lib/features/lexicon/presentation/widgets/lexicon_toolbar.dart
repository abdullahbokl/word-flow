import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lexitrack/core/constants/app_strings.dart';
import 'package:lexitrack/core/widgets/app_text_field.dart';
import 'package:lexitrack/features/lexicon/domain/entities/lexicon_stats.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_filter.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_sort.dart';
import 'package:lexitrack/features/lexicon/presentation/blocs/lexicon/lexicon_bloc.dart';
import 'package:lexitrack/features/lexicon/presentation/widgets/lexicon_stats_header.dart';
import 'package:lexitrack/features/lexicon/presentation/widgets/word_filter_bar.dart';

class LexiconToolbar extends StatelessWidget {
  const LexiconToolbar({
    required this.stats,
    required this.searchCtrl,
    required this.filter,
    required this.sort,
    required this.onSearchChanged,
    super.key,
  });

  final LexiconStats stats;
  final TextEditingController searchCtrl;
  final WordFilter filter;
  final WordSort sort;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LexiconStatsHeader(stats: stats),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppTextField(
            controller: searchCtrl,
            hint: AppStrings.searchWords,
            prefixIcon: Icons.search,
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: WordFilterBar(
            active: filter,
            onChanged: (f) => context.read<LexiconBloc>().add(FilterLexicon(f)),
            activeSort: sort,
            onSortChanged: (s) =>
                context.read<LexiconBloc>().add(SortLexicon(s)),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
